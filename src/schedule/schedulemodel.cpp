#include "schedulemodel.h"

ScheduleModel::ScheduleModel(QObject *parent)
    : QAbstractListModel{parent}
{
    QDateTime currentTime = QDateTime::currentDateTime();

    mSchedules.append({"Living Room", "HEAT", currentTime.setTime(QTime::fromString("06:00", "HH:mm")), 1440});
    mSchedules.append({"Bedroom", "COOL", currentTime.setTime(QTime::fromString("12:00", "HH:mm")), 1800});
    mSchedules.append({"Garage", "DRY", currentTime.setTime(QTime::fromString("08:00", "HH:mm")), 900});
    mSchedules.append({"Kitchen", "COOL", currentTime.setTime(QTime::fromString("18:00", "HH:mm")), 1800});
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

    ScheduleItem* schedule = mSchedules[index.row()];

    switch (role) {
    case NameRole:
        return schedule->name;
    case ModeRole:
        return schedule->mode;
    case StartTimeRole:
        return schedule->startTime;
    case TimerRole:
        return schedule->timer;
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
    return roles;
}

void ScheduleModel::addItem(const QString &name, const QString &mode, const QDateTime &startTime, const int &timer)
{
    beginInsertRows(QModelIndex(), mSchedules.size(), mSchedules.size());
    mSchedules.append({name, mode, startTime, timer});
    endInsertRows();
}

void ScheduleModel::editItem(int index, const QString &name, const QString &mode, const QDateTime &startTime, const int &timer)
{
    if (index < 0 || index >= mSchedules.size()) {
        return;
    }

    mSchedules[index] = {name, mode, startTime, timer};
    QModelIndex modelIndex = createIndex(index, 0);

    emit dataChanged(modelIndex, modelIndex, {NameRole, ModeRole, StartTimeRole, TimerRole});
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
