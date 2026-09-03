#include "SettingsCategoryModel.h"

#include <QCoreApplication>

SettingsCategoryModel::SettingsCategoryModel(SettingsRepository *repo, QObject *parent)
    : QAbstractListModel{parent}, mRepo(repo)
{
    connect(mRepo, &SettingsRepository::dataChanged, this, &SettingsCategoryModel::reload);
    reload();
}

int SettingsCategoryModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }
    return mCategories.size();
}

QVariant SettingsCategoryModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= mCategories.size()) {
        return {};
    }

    const SettingCategory &cat = mCategories.at(index.row());

    switch (role) {
    case IdRole:
        return cat.id;
    case KeyRole:
        return cat.key;
    case LabelRole:
        return QCoreApplication::translate("SettingsCategories", cat.label.toUtf8().constData());
    case IconRole:
        return cat.icon;
    case SortOrderRole:
        return cat.sortOrder;
    case ParentIdRole:
        return cat.parentId;
    default:
        return {};
    }
}

QHash<int, QByteArray> SettingsCategoryModel::roleNames() const
{
    return {
        { IdRole, "id" },
        { KeyRole, "key" },
        { LabelRole, "label" },
        { IconRole, "icon" },
        { SortOrderRole, "sortOrder" },
        { ParentIdRole, "parentId" }
    };
}

void SettingsCategoryModel::reload()
{
    beginResetModel();
    mCategories = mRepo->loadCategories();
    endResetModel();
}

int SettingsCategoryModel::idForKey(const QString &key) const
{
    for (const auto &cat : mCategories) {
        if (cat.key == key) return cat.id;
    }
    return -1;
}
