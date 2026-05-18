#ifndef STRINGHELPER_H
#define STRINGHELPER_H

#include <QObject>
#include <QString>

class StringHelper : public QObject
{
    Q_OBJECT
public:
    explicit StringHelper(QObject *parent = nullptr);

    Q_INVOKABLE QString toTitleCase(const QString &str);
};

#endif // STRINGHELPER_H
