#ifndef SETTINGITEM_H
#define SETTINGITEM_H

#include <QString>
#include <QVariant>
#include <QStringList>

struct SettingItem
{
    int id = 0;
    int categoryId = 0;

    QString key;
    QString label;
    QString type;
    QString dataType;

    QVariant value;
    QVariant defaultValue;

    QString screenType;
    QString customScreen;

    // for range or slider
    double min = 0.0;
    double max = 100.0;
    double step = 1.0;
    QString unit;

    // for dropdown
    QStringList options;
    int maxLength = 256;

    QString description;
    bool isReadOnly = false;
    bool isVisible = true;
    int sortOrder = 0;
};

#endif
