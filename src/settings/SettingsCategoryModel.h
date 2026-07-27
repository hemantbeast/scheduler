#ifndef SETTINGSCATEGORYMODEL_H
#define SETTINGSCATEGORYMODEL_H

#include <QAbstractListModel>
#include "SettingCategory.h"
#include "SettingsRepository.h"

class SettingsCategoryModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit SettingsCategoryModel(SettingsRepository *repo, QObject *parent = nullptr);

    enum Roles {
        IdRole = Qt::UserRole + 1,
        KeyRole,
        LabelRole,
        IconRole,
        SortOrderRole
    };
    Q_ENUM(Roles)

    // QAbstractItemModel interface
    int rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void reload();

private:
    SettingsRepository *mRepo;
    QList<SettingCategory> mCategories;
};

#endif // SETTINGSCATEGORYMODEL_H
