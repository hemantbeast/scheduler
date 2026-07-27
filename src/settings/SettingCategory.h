#ifndef SETTINGCATEGORY_H
#define SETTINGCATEGORY_H

#include <QString>

struct SettingCategory {
    int id = 0;
    int sortOrder = 0;

    QString key;
    QString label;
    QString icon;
};

#endif
