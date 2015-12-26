// timemanager.h

#ifndef TIMEMANAGER_H
#define TIMEMANAGER_H

#include <QObject>
#include <QSettings>
#include <QStringList>
#include "Windows.h"

class TimeManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString timezone
            READ timezone
            WRITE setTimezone
            NOTIFY timezoneChanged)

public:
    explicit TimeManager(QObject *parent = 0);

    Q_INVOKABLE QStringList getTimezones();

    QString timezone()
    {
        return m_timezone;
    }
    void setTimezone(QString val)
    {
        if (val != m_timezone)
        {
            m_timezone = val;
            timezoneChanged();
        }
    }

signals:
    void timezoneChanged();

private:
    QString m_timezone;
};

#endif // TIMEMANAGER_H
