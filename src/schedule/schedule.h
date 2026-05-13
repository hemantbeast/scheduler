#ifndef SCHEDULE_H
#define SCHEDULE_H

#include <QObject>
#include <QVariant>
#include <QDebug>

class Schedule : public QObject
{
    Q_OBJECT
public:
    explicit Schedule(QObject *parent = nullptr);

signals:
    void added(QVariant data);
    void updated(QVariant data);
    void removed(QVariant data);
    void statusChanged(bool enabled);

public slots:
    void add(QVariant data);
    void edit(QVariant data);
    void remove(QVariant data);
    void setItemEnabled(bool enable);
};

#endif // SCHEDULE_H
