#include "SettingsRepository.h"

#include <QFile>
#include <QTextStream>

SettingsRepository::SettingsRepository(const QSqlDatabase db, QObject *parent)
    : QObject{parent}, mDb(db)
{

}

SettingsRepository::~SettingsRepository()
{
    if (mDb.isOpen()) {
        mDb.close();
    }
}

bool SettingsRepository::open()
{
    if (!mDb.isOpen()) {
        qWarning() << "[SettingsRepository] Cannot open DB:" << mDb.lastError().text();
        return false;
    }

    QSqlQuery pragma(mDb);
    pragma.exec("PRAGMA foreign_keys = ON");

    ensureSchema();
    seedIfEmpty();
    return true;
}

QList<SettingCategory> SettingsRepository::loadCategories() const
{
    QList<SettingCategory> list;
    QSqlQuery query(mDb);

    query.prepare(R"(
        SELECT id, key, label, icon, sort_order, parent_id
        FROM setting_categories
        WHERE parent_id IS NULL
        ORDER BY sort_order
    )");

    if (!query.exec()) {
        qWarning() << "[SettingsRepository] loadCategories error:" << query.lastError().text();
        return list;
    }

    while (query.next()) {
        SettingCategory cat;
        cat.id = query.value("id").toInt();
        cat.key = query.value("key").toString();
        cat.label = query.value("label").toString();
        cat.icon = query.value("icon").toString();
        cat.sortOrder = query.value("sort_order").toInt();
        cat.parentId = query.value("parent_id").isNull() ? -1 : query.value("parent_id").toInt();

        list.append(cat);
    }
    return list;
}

QList<SettingItem> SettingsRepository::loadSettings(int categoryId) const
{
    QList<SettingItem> list;
    QSqlQuery query(mDb);

    query.prepare(R"(
        SELECT
            s.id,
            s.category_id,
            s.key,
            s.label,
            s.type,
            s.data_type,
            s.screen_type,
            s.custom_screen,
            s.min_value,
            s.max_value,
            s.step_value,
            s.unit,
            s.options,
            s.max_length,
            s.description,
            s.is_readonly,
            s.is_visible,
            s.sort_order,
            s.default_value,
            COALESCE(sv.value, s.default_value) AS current_value
        FROM settings s
        LEFT JOIN setting_values sv ON sv.setting_key = s.key
        WHERE s.category_id = :catId
        AND s.is_visible = 1
        ORDER BY s.sort_order
    )");
    query.bindValue(":catId", categoryId);

    if (!query.exec()) {
        qWarning() << "[SettingsRepository] loadSettings error:" << query.lastError().text();
        return list;
    }

    while (query.next()) {
        SettingItem item = rowToItem(query);

        if (item.key.isEmpty() || item.type.isEmpty()) {
            qWarning() << "[SettingsRepository] Skipping malformed row, id =" << query.value("id").toInt();
            continue;
        }

        if (item.type == "range" && item.min == 0.0 && item.max == 0.0) {
            qWarning() << "[SettingsRepository] range setting" << item.key << "has min=max=0, skipping";
            continue;
        }

        list.append(item);
    }
    return list;
}

QVariant SettingsRepository::getValue(const QString &key) const
{
    QSqlQuery query(mDb);

    query.prepare(R"(
        SELECT COALESCE(sv.value, s.default_value) AS val
        FROM settings s
        LEFT JOIN setting_values sv ON sv.setting_key = s.key
        WHERE s.key = :key
    )");
    query.bindValue(":key", key);

    if (query.exec() && query.next()) {
        return query.value("val");
    }

    qWarning() << "[SettingsRepository] getValue: key not found:" << key;
    return QVariant();
}

bool SettingsRepository::setValue(const QString &key, const QVariant &value)
{
    if (!validate(key, value)) {
        return false;
    }

    QSqlQuery query(mDb);

    query.prepare(R"(
        INSERT INTO setting_values (setting_key, value)
        VALUES (:key, :val)
        ON CONFLICT(setting_key) DO UPDATE SET value = excluded.value
    )");

    query.bindValue(":key", key);
    query.bindValue(":val", value);

    if (!query.exec()) {
        qWarning() << "[SettingsRepository] setValue error:" << query.lastError().text();
        return false;
    }

    emit settingChanged(key, value);
    return true;
}

bool SettingsRepository::resetToDefaults(int categoryId)
{
    QSqlQuery query(mDb);

    if (categoryId == -1) {
        query.prepare("DELETE FROM setting_values");
    } else {
        query.prepare(R"(
            DELETE FROM setting_values
            WHERE setting_key IN (
                SELECT key FROM settings WHERE category_id = :catId
            )
        )");

        query.bindValue(":catId", categoryId);
    }

    if (!query.exec()) {
        qWarning() << "[SettingsRepository] resetToDefaults error:" << query.lastError().text();
        return false;
    }

    emit dataChanged();
    return true;
}

void SettingsRepository::reload()
{
    qDebug() << "Reloading repository and refreshing DB connection...";

    if (mDb.isOpen()) {
        mDb.close();
    }

    if (mDb.open()) {
        // Re-apply the pragma rules to the fresh connection handle
        QSqlQuery pragmaQuery(mDb);
        pragmaQuery.exec("PRAGMA journal_mode = DELETE;");
    } else {
        qDebug() << "Failed to reconnect to database during reload!";
    }

    emit dataChanged();
}

void SettingsRepository::observeDatabaseChanges(DatabaseManager *dbManager)
{
    connect(dbManager, &DatabaseManager::externalDatabaseChanged, this, [this]() {
        emit dataChanged();
    });
}

bool SettingsRepository::validate(const QString &key, const QVariant &value) const
{
    QSqlQuery query(mDb);

    query.prepare("SELECT type, data_type, min_value, max_value, "
                  "options, max_length FROM settings WHERE key = :key");
    query.bindValue(":key", key);

    if (!query.exec() || !query.next()) {
        qWarning() << "[SettingsRepository] validate: unknown key:" << key;
        return false;
    }

    const QString type = query.value("type").toString();
    const double minVal = query.value("min_value").toDouble();
    const double maxVal = query.value("max_value").toDouble();
    const int maxLen = query.value("max_length").toInt();
    const QString optsJson = query.value("options").toString();

    if (type == "range") {
        const double d = value.toDouble();

        if (d < minVal || d > maxVal) {
            qWarning() << "[SettingsRepository] validate: value" << d
                       << "out of range [" << minVal << "," << maxVal << "] for" << key;
            return false;
        }
    } else if (type == "dropdown") {
        const QJsonArray arr = QJsonDocument::fromJson(optsJson.toUtf8()).array();
        QStringList opts;

        for (const auto &v : arr) {
            opts << v.toString();
        }

        if (!opts.contains(value.toString())) {
            qWarning() << "[SettingsRepository] validate: invalid option"
                       << value.toString() << "for" << key;
            return false;
        }
    } else if (type == "input") {
        if (value.toString().length() > maxLen) {
            qWarning() << "[SettingsRepository] validate: input too long for" << key;
            return false;
        }
    }
    return true;
}

void SettingsRepository::ensureSchema()
{
    const QStringList ddlStatements = {
        R"(
            CREATE TABLE IF NOT EXISTS setting_categories (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                key TEXT NOT NULL UNIQUE,
                label TEXT NOT NULL,
                icon TEXT DEFAULT '',
                sort_order INTEGER DEFAULT 0,
                parent_id INTEGER DEFAULT NULL,
                FOREIGN KEY (parent_id) REFERENCES setting_categories(id)
            )
        )",
        R"(
            CREATE TABLE IF NOT EXISTS settings (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                category_id INTEGER NOT NULL,
                key TEXT NOT NULL UNIQUE,
                label TEXT NOT NULL,
                type TEXT NOT NULL DEFAULT 'input',
                data_type TEXT NOT NULL DEFAULT 'string',
                default_value TEXT,
                screen_type TEXT NOT NULL DEFAULT 'editor',
                custom_screen TEXT,
                min_value REAL,
                max_value REAL,
                step_value REAL DEFAULT 1,
                unit TEXT DEFAULT '',
                options TEXT DEFAULT '',
                max_length INTEGER DEFAULT 256,
                description TEXT DEFAULT '',
                is_readonly INTEGER DEFAULT 0,
                is_visible INTEGER DEFAULT 1,
                sort_order INTEGER DEFAULT 0,
                FOREIGN KEY (category_id) REFERENCES setting_categories(id)
            )
        )",
        R"(
            CREATE TABLE IF NOT EXISTS setting_values (
                setting_key TEXT PRIMARY KEY,
                value TEXT NOT NULL,
                FOREIGN KEY (setting_key) REFERENCES settings(key)
            )
        )"
    };

    for (const QString &ddl : ddlStatements) {
        QSqlQuery query(mDb);

        if (!query.exec(ddl)) {
            qWarning() << "[SettingsRepository] Schema error:" << query.lastError().text();
        }
    }
}

void SettingsRepository::seedIfEmpty()
{
    QSqlQuery countQuery(mDb);

    if (!countQuery.exec("SELECT COUNT(*) FROM setting_categories")) {
        qWarning() << "[SettingsRepository] Seed check error:" << countQuery.lastError().text();
        return;
    }

    if (countQuery.next() && countQuery.value(0).toInt() > 0) {
        return;
    }

    QFile seedFile(":/resources/seed.sql");

    if (!seedFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "[SettingsRepository] Cannot open seed resource:" << seedFile.errorString();
        return;
    }

    QStringList statements;
    QString current;

    QTextStream in(&seedFile);

    while (!in.atEnd()) {
        const QString line = in.readLine().trimmed();

        if (line.isEmpty() || line.startsWith("--")) {
            continue;
        }

        current += line + ' ';

        if (line.endsWith(';')) {
            current.chop(1);
            statements.append(current.trimmed());
            current.clear();
        }
    }

    if (!current.trimmed().isEmpty()) {
        statements.append(current.trimmed());
    }

    if (!mDb.transaction()) {
        qWarning() << "[SettingsRepository] Cannot start seed transaction:" << mDb.lastError().text();
        return;
    }

    for (const QString &stmt : statements) {
        QSqlQuery query(mDb);

        if (!query.exec(stmt)) {
            qWarning() << "[SettingsRepository] Seed error:" << query.lastError().text();
            mDb.rollback();
            return;
        }
    }

    mDb.commit();
}

SettingItem SettingsRepository::rowToItem(const QSqlQuery &query) const
{
    SettingItem item;

    item.id = query.value("id").toInt();
    item.categoryId = query.value("category_id").toInt();
    item.key = query.value("key").toString();
    item.label = query.value("label").toString();
    item.type = query.value("type").toString();
    item.dataType = query.value("data_type").toString();
    item.screenType = query.value("screen_type").toString();
    item.customScreen = query.value("custom_screen").toString();
    item.min = query.value("min_value").toDouble();
    item.max = query.value("max_value").toDouble();
    item.step = query.value("step_value").toDouble();
    item.unit = query.value("unit").toString();
    item.description = query.value("description").toString();
    item.isReadOnly = query.value("is_readonly").toInt() == 1;
    item.isVisible = query.value("is_visible").toInt() == 1;
    item.sortOrder = query.value("sort_order").toInt();
    item.maxLength = query.value("max_length").toInt();
    item.defaultValue = query.value("default_value");
    item.value = query.value("current_value");

    const QString opts = query.value("options").toString();

    if (!opts.isEmpty()) {
        const QJsonArray arr = QJsonDocument::fromJson(opts.toUtf8()).array();

        for (const auto &v : arr) {
            item.options << v.toString();
        }
    }
    return item;
}
