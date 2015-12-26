// main.cpp

#include <QGuiApplication>
#include <QQmlEngine>
#include <QQmlComponent>
#include <QtCore>
#include <QtGui>
#include <QtQuick>
#include <QtNetwork>
#include "timemanager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Main QML
    QUrl qmlSource("qrc:/main.qml");

    // Register custom QML element
    qmlRegisterType<TimeManager>("TimeManager", 3, 14, "TimezoneInfo");

    QQmlEngine *engine = new QQmlEngine();
    app.connect(engine, SIGNAL(quit()), SLOT(quit()));

    // Other possible QML files that are used
    engine->addImportPath("qrc:/other");

    QQmlComponent *component = new QQmlComponent(engine);
    component->loadUrl(qmlSource);
    if (!component->isReady())
    {
        qWarning("%s", qPrintable(component->errorString()));
        return -1;
    }
    QObject *object = component->create();

    // The object is expected to be a Window, thus typed as one
    QQuickWindow *window = qobject_cast<QQuickWindow *>(object);
    window->show();

    return app.exec();
}
