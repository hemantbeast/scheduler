#ifndef SETTINGSITEMMODEL_H
#define SETTINGSITEMMODEL_H

#include <QAbstractListModel>
#include <QJsonArray>
#include <QJsonDocument>
#include <QList>
#include <QModelIndex>
#include <QObject>
#include <QSqlQuery>
#include <QString>
#include <QStringList>
#include <QVariant>

#include "SettingItem.h"
#include "SettingsRepository.h"

class SettingsItemModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(int categoryId READ categoryId WRITE setCategoryId NOTIFY categoryIdChanged)

public:
    explicit SettingsItemModel(SettingsRepository *repo, QObject *parent = nullptr);

    enum Roles {
        IdRole = Qt::UserRole + 1,
        KeyRole,
        LabelRole,
        TypeRole,
        DataTypeRole,
        ScreenTypeRole,
        CustomScreenRole,
        ValueRole,
        DefaultValueRole,
        MinRole,
        MaxRole,
        StepRole,
        UnitRole,
        OptionsRole,
        MaxLengthRole,
        DescriptionRole,
        IsReadOnlyRole
    };
    Q_ENUM(Roles)

    // QAbstractItemModel interface
    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;
    QHash<int, QByteArray> roleNames() const override;

    int categoryId() const;
    void setCategoryId(int id);

    Q_INVOKABLE void setValue(const QString &key, const QVariant &value);

    Q_INVOKABLE void resetCategory();

    Q_INVOKABLE void reload();

signals:
    void categoryIdChanged();
    void settingChanged(const QString &key, const QVariant &newValue);

private:
    SettingsRepository *mRepo;

    QList<SettingItem> mItems;

    int mCategoryId = -1;

    int indexOfKey(const QString &key) const;

    void updateValue(const QString &key, const QVariant &value);
};

#endif // SETTINGSITEMMODEL_H
