// timemanager.cpp

#include "timemanager.h"

TimeManager::TimeManager(QObject *parent) :
    QObject(parent), m_timezone("Europe/Helsinki")
{
}

QStringList TimeManager::getTimezones()
{
    QString RegKey = "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Time Zones";
    QSettings settings(RegKey, QSettings::NativeFormat);
    return settings.childGroups();
}
