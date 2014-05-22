RESOURCES = touchandlearn.qrc

OTHER_FILES += \
    qml/touchandlearn/*

SOURCES += \
    main.cpp

QT += qml quick

# Default rules for deployment.
include(deployment.pri)
