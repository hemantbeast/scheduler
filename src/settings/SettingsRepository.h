#ifndef SETTINGSREPOSITORY_H
#define SETTINGSREPOSITORY_H

#include <QObject>
#include <QDebug>
#include <QSqlDatabase>
#include <QVariant>
#include <QSqlError>
#include <QSqlQuery>
#include <QJsonDocument>
#include <QJsonArray>
#include <QList>

#include "SettingItem.h"
#include "SettingCategory.h"
#include "utils/databasemanager.h"

class SettingsRepository : public QObject
{
    Q_OBJECT
public:
    explicit SettingsRepository(const QSqlDatabase db, QObject *parent = nullptr);

    ~SettingsRepository() override;

    bool open();

    QList<SettingCategory> loadCategories() const;

    QList<SettingItem> loadSettings(int categoryId) const;

    QVariant getValue(const QString &key) const;

    bool setValue(const QString &key, const QVariant &value);

    bool resetToDefaults(int categoryId = -1);

    Q_INVOKABLE void reload();

    void observeDatabaseChanges(DatabaseManager *dbManager);

    bool validate(const QString &key, const QVariant &value) const;

signals:
    void dataChanged();

    void settingChanged(const QString &key, const QVariant &newValue);

private:
    QSqlDatabase mDb;

    void ensureSchema();

    void seedIfEmpty();

    SettingItem rowToItem(const QSqlQuery &query) const;
};

#endif // SETTINGSREPOSITORY_H
