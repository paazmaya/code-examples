# ForExample5.pro

# Qt modules to be loaded
QT += core gui quick qml v8

# How about using new C++ features
QMAKE_CXXFLAGS += -std=c++11
CONFIG += c++11

# Default template for qmake is app
TEMPLATE = app

# C++ files
SOURCES += \
    main.cpp \
    timemanager.cpp

# Header files for C++ classes
HEADERS += \
    timemanager.h

# Other files, such as QML
OTHER_FILES += \
    main.qml

# Resources are listed in XML and compiled inside the resulting binary
RESOURCES += \
    resources.qrc
