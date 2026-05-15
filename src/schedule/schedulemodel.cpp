#include "schedulemodel.h"

ScheduleModel::ScheduleModel(QObject *parent)
    : QAbstractListModel{parent}
{
    QDateTime time1 = QDateTime::currentDateTime();
    time1.setTime(QTime::fromString("06:00", "HH:mm"));

    QDateTime time2 = QDateTime::currentDateTime();
    time2.setTime(QTime::fromString("12:00", "HH:mm"));

    QDateTime time3 = QDateTime::currentDateTime();
    time3.setTime(QTime::fromString("08:00", "HH:mm"));

    QDateTime time4 = QDateTime::currentDateTime();
    time4.setTime(QTime::fromString("18:00", "HH:mm"));

    mSchedules.append({"Living Room", "HEAT", time1, 1440, true});
    mSchedules.append({"Bedroom", "COOL", time2, 1800, true});
    mSchedules.append({"Garage", "DRY", time3, 900, true});
    mSchedules.append({"Kitchen", "COOL", time4, 1800, false});
}

int ScheduleModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return mSchedules.size();
}

QVariant ScheduleModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= mSchedules.count()) {
        return QVariant();
    }

    const ScheduleItem &schedule = mSchedules[index.row()];

    switch (role) {
    case NameRole:
        return schedule.name;
    case ModeRole:
        return schedule.mode;
    case StartTimeRole:
        return schedule.startTime;
    case TimerRole:
        return schedule.timer;
    case IsEnabledRole:
        return schedule.isEnabled;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> ScheduleModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    roles[NameRole] = "name";
    roles[ModeRole] = "mode";
    roles[StartTimeRole] = "startTime";
    roles[TimerRole] = "timer";
    roles[IsEnabledRole] = "isEnabled";
    return roles;
}

void ScheduleModel::addItem(const QString &name, const QString &mode, const QDateTime &startTime, const int &timer)
{
    beginInsertRows(QModelIndex(), mSchedules.size(), mSchedules.size());
    mSchedules.append({name, mode, startTime, timer, true});
    endInsertRows();
}

void ScheduleModel::editItem(int index, const QString &name, const QString &mode, const QDateTime &startTime, const int &timer)
{
    if (index < 0 || index >= mSchedules.size()) {
        return;
    }

    const ScheduleItem &schedule = mSchedules[index];

    mSchedules[index] = {name, mode, startTime, timer, schedule.isEnabled};
    QModelIndex modelIndex = createIndex(index, 0);

    emit dataChanged(modelIndex, modelIndex, {NameRole, ModeRole, StartTimeRole, TimerRole, IsEnabledRole});
}

void ScheduleModel::removeItem(int index)
{
    if (index < 0 || index >= mSchedules.size()) {
        return;
    }

    beginRemoveRows(QModelIndex(), index, index);
    mSchedules.removeAt(index);
    endRemoveRows();
}

void ScheduleModel::setItemEnabled(int index, bool enable)
{
    if (index < 0 || index >= mSchedules.size() || mSchedules[index].isEnabled == enable) {
        return;
    }

    mSchedules[index].isEnabled = enable;
    QModelIndex modelIndex = createIndex(index, 0);

    qDebug() << "Index: " << index << " Status: " << enable;

    emit dataChanged(modelIndex, modelIndex, {IsEnabledRole});
}
