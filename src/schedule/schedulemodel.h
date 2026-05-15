#ifndef SCHEDULEMODEL_H
#define SCHEDULEMODEL_H

#include <QAbstractListModel>
#include <QDebug>
#include <QObject>
#include <QString>
#include <QDateTime>
#include <QList>
#include <QVariant>

struct ScheduleItem {
    QString name;
    QString mode;
    QDateTime startTime;
    int timer;
    bool isEnabled;
};


class ScheduleModel : public QAbstractListModel
{
    Q_OBJECT

    enum ScheduleRole {
        NameRole = Qt::UserRole + 1,
        ModeRole,
        StartTimeRole,
        TimerRole,
        IsEnabledRole
    };

public:
    explicit ScheduleModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent) const;

    QVariant data(const QModelIndex &index, int role) const;

    QHash<int, QByteArray> roleNames() const;

    Q_INVOKABLE void addItem(const QString &name, const QString &mode, const QDateTime &startTime, const int &timer);

    Q_INVOKABLE void editItem(int index, const QString &name, const QString &mode, const QDateTime &startTime, const int &timer);

    Q_INVOKABLE void removeItem(int index);

    Q_INVOKABLE void setItemEnabled(int index, bool enable);

private:
    QList<ScheduleItem> mSchedules;
};

#endif // SCHEDULEMODEL_H
