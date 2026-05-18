#include "stringhelper.h"


StringHelper::StringHelper(QObject *parent)
    : QObject{parent}
{}

QString StringHelper::toTitleCase(const QString &str)
{
    if (str.isEmpty()) return "";

    QString lowered = str.toLower();
    lowered[0] = lowered[0].toUpper();
    return lowered;
}
