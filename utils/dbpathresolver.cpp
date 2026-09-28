#include "dbpathresolver.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonDocument>
#include <QJsonObject>
#include <QStandardPaths>
#include <QDebug>

QString DbPathResolver::lgDir()
{
    const QString base = QStandardPaths::writableLocation(QStandardPaths::GenericConfigLocation);
    return QDir(base).filePath("LG");
}

QString DbPathResolver::configFilePath()
{
    return QDir(lgDir()).filePath("deluxe.json");
}

QString DbPathResolver::defaultDatabasePath()
{
    return QDir(lgDir()).filePath("deluxe.db");
}

QString DbPathResolver::configuredDatabasePath()
{
    QFile file(configFilePath());
    if (!file.open(QIODevice::ReadOnly)) {
        return QString();
    }

    const QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    if (!doc.isObject()) {
        qWarning() << "[DbPathResolver] Invalid config JSON:" << configFilePath();
        return QString();
    }

    return doc.object().value("db_path").toString();
}

void DbPathResolver::migrateLegacyFile()
{
    const QString defaultPath = defaultDatabasePath();
    if (QFileInfo::exists(defaultPath)) {
        return;
    }

    const QString legacyPath = QDir::current().absoluteFilePath("scheduler.db");
    if (!QFileInfo::exists(legacyPath)) {
        return;
    }

    if (QFile::copy(legacyPath, defaultPath)) {
        QFile::setPermissions(defaultPath, QFileDevice::ReadOwner | QFileDevice::WriteOwner
                                               | QFileDevice::ReadUser | QFileDevice::WriteUser);
        qDebug() << "[DbPathResolver] Migrated legacy database" << legacyPath << "->" << defaultPath;
    } else {
        qWarning() << "[DbPathResolver] Failed to migrate legacy database from" << legacyPath;
    }
}

QString DbPathResolver::resolve()
{
    const QString configured = configuredDatabasePath();
    if (!configured.isEmpty()) {
        if (QFileInfo::exists(configured)) {
            qDebug() << "[DbPathResolver] Using configured database:" << configured;
            return configured;
        }

        const QFileInfo info(configured);
        QFile file(configured);
        if (QDir().mkpath(info.absolutePath()) && file.open(QIODevice::WriteOnly)) {
            file.close();
            qDebug() << "[DbPathResolver] Created configured database:" << configured;
            return configured;
        }

        qWarning() << "[DbPathResolver] Could not create configured db_path, falling back to default:"
                   << configured;
    }

    QDir().mkpath(lgDir());
    migrateLegacyFile();
    return defaultDatabasePath();
}
