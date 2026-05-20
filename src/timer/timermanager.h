#ifndef TIMERMANAGER_H
#define TIMERMANAGER_H

#include <QObject>
#include <QString>
#include <QTimer>
#include <QDateTime>

#include "src/schedule/schedulemodel.h"

class TimerManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int currentMode READ currentMode NOTIFY timerUpdated)
    Q_PROPERTY(int secondsRemaining READ secondsRemaining NOTIFY timerUpdated)
    Q_PROPERTY(int totalDuration READ totalDuration NOTIFY timerUpdated)
    Q_PROPERTY(QString nextScheduleName READ nextScheduleName NOTIFY timerUpdated)

public:
    explicit TimerManager(ScheduleModel *model, QObject *parent = nullptr);

    int currentMode();

    int secondsRemaining();

    int totalDuration();

    QString nextScheduleName();

signals:
    void timerUpdated();

public slots:
    void processSchedules();

private:
    ScheduleModel *schedule;
    QTimer *timer;

    int mCurrentMode = 0;
    int mSecondsRemaining = 0;
    int mTotalDuration = 1;
    QString mNextScheduleName = "";

    int mapModeToIndex(const QString &modeStr);
    QDateTime calculateNextOccurance(const ScheduleItem &item, const QDateTime &now);
};

#endif // TIMERMANAGER_H
