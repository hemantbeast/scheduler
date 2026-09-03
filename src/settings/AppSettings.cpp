#include "AppSettings.h"

#include <QCoreApplication>
#include <QDateTime>
#include <QDebug>
#include <QHash>
#include <QTimeZone>

namespace {

const char kLanguageKey[] = "language";
const char kTimezoneKey[] = "timezone";
const char kTemperatureUnitKey[] = "temperature_unit";
const char kBrightnessKey[] = "brightness";
const char kNightModeKey[] = "night_mode";

QString cleanString(const QVariant &value, const QString &fallback)
{
    const QString s = value.toString().trimmed();
    return s.isEmpty() ? fallback : s;
}

} // namespace

AppSettings::AppSettings(SettingsRepository *repo, QQmlEngine *engine, QObject *parent)
    : QObject(parent),
      mRepo(repo),
      mEngine(engine)
{
    connect(mRepo, &SettingsRepository::settingChanged, this,
            [this](const QString &key, const QVariant &) {
                refresh(key);
            });

    connect(mRepo, &SettingsRepository::dataChanged, this, &AppSettings::refreshAll);

    connect(this, &AppSettings::languageChanged, this, &AppSettings::applyLanguage);

    refreshAll();
}

QString AppSettings::unitSymbol() const
{
    return mTemperatureUnit == QLatin1String("Fahrenheit")
               ? QStringLiteral("\u00B0F")
               : QStringLiteral("\u00B0C");
}

QVariant AppSettings::value(const QString &key) const
{
    return mRepo->getValue(key);
}

bool AppSettings::setValue(const QString &key, const QVariant &value)
{
    return mRepo->setValue(key, value);
}

QString AppSettings::formatNow(const QString &format) const
{
    const QDateTime now = QDateTime::currentDateTime();

    if (mTimezone.isEmpty()) {
        return now.toString(format);
    }

    const QTimeZone tz(mTimezone.toUtf8());

    if (!tz.isValid()) {
        qWarning() << "[AppSettings] Unknown time zone:" << mTimezone;
        return now.toString(format);
    }

    return now.toTimeZone(tz).toString(format);
}

double AppSettings::convertTemperature(double celsius) const
{
    return mTemperatureUnit == QLatin1String("Fahrenheit")
               ? celsius * 9.0 / 5.0 + 32.0
               : celsius;
}

void AppSettings::applyLanguage()
{
    const QString code = mLanguageCode.isEmpty() ? QStringLiteral("en") : mLanguageCode;

    if (mTranslator) {
        QCoreApplication::removeTranslator(mTranslator);
        mTranslator->deleteLater();
        mTranslator = nullptr;
    }

    if (code != QLatin1String("en")) {
        mTranslator = new QTranslator(this);
        const QString path = QStringLiteral(":/i18n/scheduler_%1.qm").arg(code);

        if (mTranslator->load(path)) {
            QCoreApplication::installTranslator(mTranslator);
        } else {
            qWarning() << "[AppSettings] Could not load translation:" << path;
            mTranslator->deleteLater();
            mTranslator = nullptr;
        }
    }

    if (mEngine) {
        mEngine->retranslate();
    }
}

void AppSettings::refresh(const QString &key)
{
    const QVariant raw = mRepo->getValue(key);

    if (key == QLatin1String(kLanguageKey)) {
        const QString lang = cleanString(raw, QStringLiteral("English"));
        const QString code = codeForLanguage(lang);

        if (lang != mLanguage || code != mLanguageCode) {
            mLanguage = lang;
            mLanguageCode = code;
            emit languageChanged();
        }
    } else if (key == QLatin1String(kTimezoneKey)) {
        const QString tz = cleanString(raw, QString());

        if (tz != mTimezone) {
            mTimezone = tz;
            emit timezoneChanged();
        }
    } else if (key == QLatin1String(kTemperatureUnitKey)) {
        const QString unit = cleanString(raw, QStringLiteral("Celsius"));

        if (unit != mTemperatureUnit) {
            mTemperatureUnit = unit;
            emit temperatureUnitChanged();
        }
    } else if (key == QLatin1String(kBrightnessKey)) {
        const int b = raw.isValid() ? raw.toInt() : 100;

        if (b != mBrightness) {
            mBrightness = b;
            emit brightnessChanged();
        }
    } else if (key == QLatin1String(kNightModeKey)) {
        const bool n = raw.isValid() ? raw.toBool() : false;

        if (n != mNightMode) {
            mNightMode = n;
            emit nightModeChanged();
        }
    }
}

void AppSettings::refreshAll()
{
    refresh(QLatin1String(kLanguageKey));
    refresh(QLatin1String(kTimezoneKey));
    refresh(QLatin1String(kTemperatureUnitKey));
    refresh(QLatin1String(kBrightnessKey));
    refresh(QLatin1String(kNightModeKey));
}

QString AppSettings::codeForLanguage(const QString &language)
{
    static const QHash<QString, QString> map = {
        { QStringLiteral("English"), QStringLiteral("en") },
        { QStringLiteral("Hindi"),   QStringLiteral("hi") },
        { QStringLiteral("Kannada"), QStringLiteral("kn") },
        { QStringLiteral("Tamil"),   QStringLiteral("ta") },
        { QStringLiteral("Korean"),  QStringLiteral("ko") },
    };

    return map.value(language, QStringLiteral("en"));
}
