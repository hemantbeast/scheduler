#include "timermanager.h"

TimerManager::TimerManager(ScheduleModel *model, QObject *parent)
    : QObject{parent}, schedule(model)
{
    timer = new QTimer(this);
    connect(timer, &QTimer::timeout, this, &TimerManager::processSchedules);

    timer->start(1000);
}

int TimerManager::currentMode()
{
    return mCurrentMode;
}

void TimerManager::setCurrentMode(const int &index)
{
    mUserMode = index;
}

int TimerManager::secondsRemaining()
{
    return mSecondsRemaining;
}

int TimerManager::totalDuration()
{
    return mTotalDuration;
}

QString TimerManager::nextScheduleName()
{
    return mNextScheduleName;
}

int TimerManager::activeScheduleId()
{
    return mActiveScheduleId;
}

QString TimerManager::activeScheduleName()
{
    return mActiveScheduleName;
}

void TimerManager::stopTimer()
{
    bool isRunning = timer->isActive();

    if (isRunning) {
        timer->stop();
    }

    mSecondsRemaining = 0;
    mTotalDuration = 1;

    emit timerUpdated();
}

void TimerManager::processSchedules()
{
    if (!schedule) {
        return;
    }

    QDateTime now = QDateTime::currentDateTime();
    bool scheduleRunning = false;

    qint64 minimumTimeDifference = std::numeric_limits<qint64>::max();
    int shortestRunningDuration = std::numeric_limits<int>::max();
    QString upcomingName = "";
    int activeId = -1;
    QString activeName = "";

    const QList<ScheduleItem> &schedules = schedule->getSchedulesList();

    for (const auto &item : schedules) {
        if (!item.isEnabled) {
            continue;
        }

        QDateTime effectiveStart = calculateNextOccurance(item, now);
        if (!effectiveStart.isValid()) continue;

        QDateTime endTime = effectiveStart.addSecs(item.timer);

        if (now >= effectiveStart && now < endTime) {
            int currentTotalSeconds = item.timer;

            if (!scheduleRunning || currentTotalSeconds < shortestRunningDuration) {
                mSecondsRemaining = static_cast<int>(now.secsTo(endTime));
                mTotalDuration = currentTotalSeconds;
                mCurrentMode = mUserMode != -1 ? mUserMode : mapModeToIndex(item.mode);
                activeId = item.id;
                activeName = item.name;

                shortestRunningDuration = currentTotalSeconds;
                scheduleRunning = true;
            }
        }
        else if (effectiveStart > now) {
            qint64 diff = now.secsTo(effectiveStart);

            if (diff < minimumTimeDifference) {
                minimumTimeDifference = diff;
                upcomingName = item.name;
            }
        }
    }

    if (mWasRunning && !scheduleRunning) {
        emit timerCompleted();
    }

    if (!scheduleRunning) {
        mSecondsRemaining = 0;
        mTotalDuration = 1;
        mUserMode = -1;
        mActiveScheduleId = -1;
        mActiveScheduleName = "";
    } else {
        mActiveScheduleId = activeId;
        mActiveScheduleName = activeName;
    }

    mWasRunning = scheduleRunning;
    mNextScheduleName = upcomingName;
    emit timerUpdated();
}

int TimerManager::mapModeToIndex(const QString &modeStr)
{
    QString upper = modeStr.toUpper();

    if (upper == "COOL") return 1;
    if (upper == "DRY") return 2;
    return 0;
}

QDateTime TimerManager::calculateNextOccurance(const ScheduleItem &item, const QDateTime &now)
{
    QTime timeOfDay = item.startTime.time();
    QDate baseDate = now.date();
    QDateTime target(baseDate, timeOfDay);

    switch (item.repeatType) {
    case 0:
        return item.startTime;

    case 1:
        if (target.addSecs(item.timer) <= now) {
            target = target.addDays(1);
        }
        return target;

    case 2: {
        if (item.repeatDays.isEmpty()) return QDateTime();

        QList<int> parsedDays;
        QStringList dayTokens = item.repeatDays.split(',', Qt::SkipEmptyParts);

        for (const QString &token : dayTokens) {
            bool ok;
            int day = token.trimmed().toInt(&ok);

            if (ok) {
                parsedDays.append(day);
            }
        }

        if (parsedDays.isEmpty()) return QDateTime();

        QDateTime closestMatch;
        qint64 minSecs = std::numeric_limits<qint64>::max();

        for (int daysAhead = 0; daysAhead < 7; ++daysAhead) {
            QDateTime candidate = target.addDays(daysAhead);

            int candidateDayIdx = candidate.date().dayOfWeek() - 1;

            if (parsedDays.contains(candidateDayIdx)) {
                if (daysAhead == 0 && candidate.addSecs(item.timer) <= now) {
                    candidate = candidate.addDays(7);
                }

                qint64 diff = now.secsTo(candidate);
                if (diff < minSecs) {
                    minSecs = diff;
                    closestMatch = candidate;
                }
            }
        }
        return closestMatch;
    }

    case 3:
        target = QDateTime(QDate(now.date().year(), now.date().month(), item.startTime.date().day()), timeOfDay);
        if (target.addSecs(item.timer) <= now) {
            target = target.addMonths(1);
        }
        return target;

    default:
        return item.startTime;
    }
}

QString TimerManager::previewNextOccurrence(const QString &mode, const QDateTime &startTime,
                                             int timer, int repeatType, const QString &repeatDays)
{
    if (!startTime.isValid()) return "";

    QDateTime now = QDateTime::currentDateTime();

    ScheduleItem tempItem;
    tempItem.id = -1;
    tempItem.name = "";
    tempItem.mode = mode;
    tempItem.startTime = startTime;
    tempItem.timer = timer;
    tempItem.isEnabled = true;
    tempItem.repeatType = repeatType;
    tempItem.repeatDays = repeatDays;

    QDateTime nextOccurrence = calculateNextOccurance(tempItem, now);

    if (!nextOccurrence.isValid()) return "";

    QDate today = now.date();
    QDate tomorrow = today.addDays(1);
    QDate nextDate = nextOccurrence.date();
    QTime nextTime = nextOccurrence.time();

    QString timeStr = nextTime.toString("h:mm AP");

    if (nextDate == today) {
        return "Today at " + timeStr;
    } else if (nextDate == tomorrow) {
        return "Tomorrow at " + timeStr;
    } else {
        switch (repeatType) {
        case 1:
            return "Every day at " + timeStr;

        case 2: {
            if (repeatDays.isEmpty()) return "Weekly at " + timeStr;

            QStringList dayLabels = {"Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"};
            QStringList selectedDays;
            QStringList tokens = repeatDays.split(',', Qt::SkipEmptyParts);

            for (const QString &token : tokens) {
                bool ok;
                int idx = token.trimmed().toInt(&ok);
                if (ok && idx >= 0 && idx < 7) {
                    selectedDays.append(dayLabels[idx]);
                }
            }

            if (selectedDays.isEmpty()) return "Weekly at " + timeStr;
            return "Every " + selectedDays.join(", ") + " at " + timeStr;
        }

        case 3: {
            int day = nextDate.day();
            QString suffix = "th";
            if (day % 10 == 1 && day != 11) suffix = "st";
            else if (day % 10 == 2 && day != 12) suffix = "nd";
            else if (day % 10 == 3 && day != 13) suffix = "rd";

            return "Every " + QString::number(day) + suffix + " of the month at " + timeStr;
        }

        default:
            return nextDate.toString("MMM d, yyyy") + " at " + timeStr;
        }
    }
}
