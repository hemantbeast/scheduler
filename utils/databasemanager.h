#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QSqlError>
#include <QVariantMap>
#include <QVariantList>
#include <QDebug>
#include <QTimer>

class DatabaseManager : public QObject
{
    Q_OBJECT
public:
    explicit DatabaseManager(const QString &dbName, QObject *parent = nullptr);
    ~DatabaseManager();

    Q_INVOKABLE bool createTable(const QString &tableName, const QString &schema);

    Q_INVOKABLE int insertRecord(const QString &tableName, const QVariantMap &data);

    Q_INVOKABLE QVariantList fetchAll(const QString &tableName, const QString &whereClause = "");

    Q_INVOKABLE bool updateRecord(const QString &tableName, const QVariantMap &data, const QString &whereClause);

    Q_INVOKABLE bool deleteRecord(const QString &tableName, const QString &whereClause);

    Q_INVOKABLE bool addColumnIfNeeded(const QString &tableName, const QString &columnName, const QString &columnType);

    Q_INVOKABLE void enableExternalChangeDetection(int intervalMs = 2000);

    QSqlDatabase getDb() const {
        return mDb;
    }

signals:
    void externalDatabaseChanged();

private:
    QSqlDatabase mDb;
    int m_lastDataVersion = 0;
    QTimer *m_watcherTimer = nullptr;
};

#endif // DATABASEMANAGER_H
