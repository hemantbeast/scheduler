#include "dashboardbackend.h"

#include <QDateTime>
#include <QDebug>
#include <QVariantMap>

namespace {
const char *kIduUnitId = "IDU-1";
const char *kOduUnitId = "ODU-1";
}

DashboardBackend::DashboardBackend(DatabaseManager *db, QObject *parent)
    : QObject{parent}, mDb(db)
{
    // Mirrors the drift DeviceStateTable schema in sys_control.
    mDb->createTable("device_state",
                     "unitId TEXT PRIMARY KEY, "
                     "unitType TEXT NOT NULL, "
                     "temperature REAL, "
                     "humidity REAL, "
                     "targetTemp REAL, "
                     "mode TEXT, "
                     "fanSpeed TEXT, "
                     "isOn INTEGER DEFAULT 1, "
                     "updatedAt TEXT NOT NULL DEFAULT ''");
    reload();
}

void DashboardBackend::reload()
{
    const QVariantList rows = mDb->fetchAll("device_state");

    bool hasData = false;
    for (const QVariant &rowVar : rows) {
        const QVariantMap row = rowVar.toMap();
        const QString unitId = row.value("unitId").toString();

        if (unitId == QLatin1String(kIduUnitId)) {
            hasData = true;
            mIndoorTemp = row.value("temperature").toDouble();
            mHumidity = row.value("humidity").toDouble();
            mTargetTemp = row.value("targetTemp").isValid() && !row.value("targetTemp").isNull()
                              ? row.value("targetTemp").toDouble() : 25.0;
            mMode = row.value("mode").isNull() ? QStringLiteral("auto") : row.value("mode").toString();
            mFanSpeed = row.value("fanSpeed").isNull() ? QStringLiteral("auto") : row.value("fanSpeed").toString();
            mIsOn = row.value("isOn").isNull() ? true : row.value("isOn").toBool();
        } else if (unitId == QLatin1String(kOduUnitId)) {
            hasData = true;
            mOutdoorTemp = row.value("temperature").toDouble();
        }
    }
    mHasData = hasData;

    emit changed();
}

void DashboardBackend::setTargetTemp(double celsius)
{
    writeField("targetTemp", qBound(15.0, celsius, 35.0));
}

void DashboardBackend::setMode(const QString &mode)
{
    writeField("mode", mode);
}

void DashboardBackend::setFanSpeed(const QString &fanSpeed)
{
    writeField("fanSpeed", fanSpeed);
}

void DashboardBackend::togglePower()
{
    writeField("isOn", !mIsOn ? 1 : 0);
}

void DashboardBackend::writeField(const QString &column, const QVariant &value)
{
    ensureIduRow();

    QVariantMap data;
    data.insert(column, value);
    data.insert("updatedAt", QDateTime::currentDateTime().toString(Qt::ISODate));

    if (!mDb->updateRecord("device_state", data, QStringLiteral("unitId = '%1'").arg(QLatin1String(kIduUnitId)))) {
        qWarning() << "[DashboardBackend] Failed to write" << column;
        return;
    }

    reload();
}

void DashboardBackend::ensureIduRow()
{
    const QVariantList rows = mDb->fetchAll("device_state", QStringLiteral("unitId = '%1'").arg(QLatin1String(kIduUnitId)));
    if (!rows.isEmpty()) {
        return;
    }

    QVariantMap row;
    row.insert("unitId", QLatin1String(kIduUnitId));
    row.insert("unitType", QStringLiteral("IDU"));
    row.insert("targetTemp", 25.0);
    row.insert("mode", QStringLiteral("auto"));
    row.insert("fanSpeed", QStringLiteral("auto"));
    row.insert("isOn", 1);
    row.insert("updatedAt", QDateTime::currentDateTime().toString(Qt::ISODate));
    mDb->insertRecord("device_state", row);
}
