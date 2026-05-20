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

void TimerManager::processSchedules()
{
    if (!schedule) {
        return;
    }

    QDateTime now = QDateTime::currentDateTime();
    bool scheduleRunning = false;

    // Fallback trackers for finding the next chronological event
    qint64 minimumTimeDifference = std::numeric_limits<qint64>::max();
    int shortestRunningDuration = std::numeric_limits<int>::max();
    QString upcomingName = "";

    // Access data safely from your existing mSchedules QList
    const QList<ScheduleItem> &schedules = schedule->getSchedulesList();

    for (const auto &item : schedules) {
        if (!item.isEnabled) {
            continue;
        }

        QDateTime effectiveStart = calculateNextOccurance(item, now);
        if (!effectiveStart.isValid()) continue;

        QDateTime endTime = effectiveStart.addSecs(item.timer);

        // Scenario A: Item is currently running right now
        if (now >= effectiveStart && now < endTime) {
            int currentTotalSeconds = item.timer;

            if (!scheduleRunning || currentTotalSeconds < shortestRunningDuration) {
                mSecondsRemaining = static_cast<int>(now.secsTo(endTime));
                mTotalDuration = currentTotalSeconds;
                mCurrentMode = mapModeToIndex(item.mode);

                shortestRunningDuration = currentTotalSeconds;
                scheduleRunning = true;
            }
        }
        // Scenario B: Item is in the future. Find the closest upcoming one
        else if (effectiveStart > now) {
            qint64 diff = now.secsTo(effectiveStart);

            if (diff < minimumTimeDifference) {
                minimumTimeDifference = diff;
                upcomingName = item.name;
            }
        }
    }

    // Reset properties to zero idle state if no active windows are open
    if (!scheduleRunning) {
        mSecondsRemaining = 0;
        mTotalDuration = 1;
    }

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
    case 0: // Once
        return item.startTime;

    case 1: // Daily
        // If the time has already passed today, it happens tomorrow
        if (target.addSecs(item.timer) <= now) {
            target = target.addDays(1);
        }
        return target;

    case 2: { // Weekly
        if (item.repeatDays.isEmpty()) return QDateTime();

        // 1. Parse the comma-separated string into integers
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

        // 2. Check day offsets from today (0 to 6 days into the future)
        for (int daysAhead = 0; daysAhead < 7; ++daysAhead) {
            QDateTime candidate = target.addDays(daysAhead);

            // Convert Qt dayOfWeek (1=Mon...7=Sun) to your index (0=Mon...6=Sun)
            int candidateDayIdx = candidate.date().dayOfWeek() - 1;

            if (parsedDays.contains(candidateDayIdx)) {
                // If candidate is today but the timer window already ended, skip to next week
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

    case 3: // Monthly
        // Matches the exact calendar day number (e.g., every 15th)
        target = QDateTime(QDate(now.date().year(), now.date().month(), item.startTime.date().day()), timeOfDay);
        if (target.addSecs(item.timer) <= now) {
            target = target.addMonths(1);
        }
        return target;

    default:
        return item.startTime;
    }
}
