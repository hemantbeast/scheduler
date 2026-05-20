#include "databasemanager.h"

DatabaseManager::DatabaseManager(const QString &dbName, QObject *parent)
    : QObject{parent}
{
    mDb = QSqlDatabase::addDatabase("QSQLITE");
    mDb.setDatabaseName(dbName);

    if (!mDb.open()) {
        qDebug() << "Error: Connection with database failed:" << mDb.lastError().text();
    } else {
        qDebug() << "Database opened successfully at:" << dbName;
    }
}

DatabaseManager::~DatabaseManager()
{
    if (mDb.isOpen()) {
        mDb.close();
    }
}

// 1. CREATE TABLE: Expects schema like "id INTEGER PRIMARY KEY, name TEXT, mode TEXT"
bool DatabaseManager::createTable(const QString &tableName, const QString &schema)
{
    QSqlQuery query;
    QString sql = QString("CREATE TABLE IF NOT EXISTS %1 (%2);").arg(tableName, schema);

    if (!query.exec(sql)) {
        qDebug() << "Create table failed:" << query.lastError().text();
        return false;
    }
    return true;
}

// 2. CREATE (INSERT) RECORD: Dynamically binds mapping keys to fields
int DatabaseManager::insertRecord(const QString &tableName, const QVariantMap &data)
{
    if (data.isEmpty()) return false;

    QStringList columns = data.keys();
    QStringList placeholders;
    for(int i = 0; i < columns.size(); ++i) placeholders << "?";

    QSqlQuery query;
    QString sql = QString("INSERT INTO %1 (%2) VALUES (%3);")
                      .arg(tableName, columns.join(", "), placeholders.join(", "));

    query.prepare(sql);
    for (const QString &col : columns) {
        query.addBindValue(data.value(col));
    }

    if (!query.exec()) {
        qDebug() << "Insert failed:" << query.lastError().text();
        return -1;
    }
    return query.lastInsertId().toInt();;
}

// 3. READ (FETCH) ALL RECORDS: Returns a list of objects/maps
QVariantList DatabaseManager::fetchAll(const QString &tableName, const QString &whereClause)
{
    QVariantList results;
    QSqlQuery query;
    QString sql = QString("SELECT * FROM %1").arg(tableName);

    if (!whereClause.isEmpty()) {
        sql += " WHERE " + whereClause;
    }

    if (!query.exec(sql)) {
        qDebug() << "Fetch failed:" << query.lastError().text();
        return results;
    }

    while (query.next()) {
        QVariantMap row;

        // Dynamically extract column headers and pair them to matching data types
        int totalCols = query.record().count();

        for (int i = 0; i < totalCols; ++i) {
            QString colName = query.record().fieldName(i);
            row[colName] = query.value(i);
        }
        results.append(row);
    }
    return results;
}

// 4. UPDATE RECORD: e.g., whereClause = "id = 5"
bool DatabaseManager::updateRecord(const QString &tableName, const QVariantMap &data, const QString &whereClause)
{
    if (data.isEmpty() || whereClause.isEmpty()) return false;

    QStringList setStatements;
    for (const QString &col : data.keys()) {
        setStatements << QString("%1 = ?").arg(col);
    }

    QSqlQuery query;
    QString sql = QString("UPDATE %1 SET %2 WHERE %3;")
                      .arg(tableName, setStatements.join(", "), whereClause);

    query.prepare(sql);
    for (const QString &col : data.keys()) {
        query.addBindValue(data.value(col));
    }

    if (!query.exec()) {
        qDebug() << "Update failed:" << query.lastError().text();
        return false;
    }
    return true;
}

// 5. DELETE RECORD
bool DatabaseManager::deleteRecord(const QString &tableName, const QString &whereClause)
{
    if (whereClause.isEmpty()) return false;

    QSqlQuery query;
    QString sql = QString("DELETE FROM %1 WHERE %2;").arg(tableName, whereClause);

    if (!query.exec(sql)) {
        qDebug() << "Delete failed:" << query.lastError().text();
        return false;
    }
    return true;
}

bool DatabaseManager::addColumnIfNeeded(const QString &tableName, const QString &columnName, const QString &columnType)
{
    QSqlQuery query;

    // Check if column already exists
    query.exec(QString("PRAGMA table_info(%1);").arg(tableName));

    while (query.next()) {
        if (query.value("name").toString() == columnName) {
            return true; // Column already exists, do nothing
        }
    }

    // Column is missing, add it
    QString alterSql = QString("ALTER TABLE %1 ADD COLUMN %2 %3;")
                           .arg(tableName, columnName, columnType);

    if (!query.exec(alterSql)) {
        qDebug() << "Failed to add column:" << query.lastError().text();
        return false;
    }
    return true;
}
