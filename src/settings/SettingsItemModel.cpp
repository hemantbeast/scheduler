#include "SettingsItemModel.h"

SettingsItemModel::SettingsItemModel(SettingsRepository *repo, QObject *parent)
    : QAbstractListModel{parent}, mRepo(repo)
{
    connect(mRepo, &SettingsRepository::dataChanged, this, &SettingsItemModel::reload);
    connect(mRepo, &SettingsRepository::settingChanged, this, &SettingsItemModel::updateValue);
}

int SettingsItemModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return 0;
    }
    return mItems.size();
}

QVariant SettingsItemModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= mItems.size()) {
        return {};
    }

    const SettingItem &item = mItems.at(index.row());

    switch (role) {
    case IdRole:
        return item.id;
    case KeyRole:
        return item.key;
    case LabelRole:
        return item.label;
    case TypeRole:
        return item.type;
    case DataTypeRole:
        return item.dataType;
    case ValueRole:
        return item.value;
    case DefaultValueRole:
        return item.defaultValue;
    case MinRole:
        return item.min;
    case MaxRole:
        return item.max;
    case StepRole:
        return item.step;
    case UnitRole:
        return item.unit;
    case OptionsRole:
        return item.options;
    case MaxLengthRole:
        return item.maxLength;
    case DescriptionRole:
        return item.description;
    case IsReadOnlyRole:
        return item.isReadOnly;
    default:
        return {};
    }
}

Qt::ItemFlags SettingsItemModel::flags(const QModelIndex &index) const
{
    if (!index.isValid()) {
        return Qt::NoItemFlags;
    }

    const SettingItem &item = mItems.at(index.row());
    Qt::ItemFlags fl = Qt::ItemIsEnabled | Qt::ItemIsSelectable;

    if (!item.isReadOnly) {
        fl |= Qt::ItemIsEditable;
    }

    return fl;
}

QHash<int, QByteArray> SettingsItemModel::roleNames() const
{
    return {
        { IdRole, "id" },
        { KeyRole, "key" },
        { LabelRole, "label" },
        { TypeRole, "type" },
        { DataTypeRole, "dataType" },
        { ValueRole, "value" },
        { DefaultValueRole, "defaultValue" },
        { MinRole, "min" },
        { MaxRole, "max" },
        { StepRole, "step" },
        { UnitRole, "unit" },
        { OptionsRole, "options" },
        { MaxLengthRole, "maxLength" },
        { DescriptionRole, "description" },
        { IsReadOnlyRole, "isReadOnly" },
    };
}

int SettingsItemModel::categoryId() const
{
    return mCategoryId;
}

void SettingsItemModel::setCategoryId(int id)
{
    if (mCategoryId == id) {
        return;
    }

    mCategoryId = id;
    emit categoryIdChanged();
    reload();
}

void SettingsItemModel::setValue(const QString &key, const QVariant &value)
{
    if (mRepo->setValue(key, value)) {
        emit settingChanged(key, value);
    }
}

void SettingsItemModel::resetCategory()
{
    mRepo->resetToDefaults(mCategoryId);
}

void SettingsItemModel::reload()
{
    if (mCategoryId < 0) {
        return;
    }

    beginResetModel();
    mItems = mRepo->loadSettings(mCategoryId);
    endResetModel();
}

int SettingsItemModel::indexOfKey(const QString &key) const
{
    for (int i = 0; i < mItems.size(); i++) {
        if (mItems[i].key == key) {
            return i;
        }
    }
    return -1;
}

void SettingsItemModel::updateValue(const QString &key, const QVariant &value)
{
    const int row = indexOfKey(key);

    if (row < 0) {
        return;
    }

    mItems[row].value = value;
    const QModelIndex idx = index(row);

    emit dataChanged(idx, idx, { ValueRole });
}
