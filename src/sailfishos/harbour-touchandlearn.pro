# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = harbour-touchandlearn

CONFIG += sailfishapp

SOURCES += src/touchandlearn.cpp

OTHER_FILES += \
    qml/main-sailfishos.qml \
    rpm/harbour-touchandlearn.yaml \
    rpm/harbour-touchandlearn.spec \
    harbour-touchandlearn.desktop

SOURCES += \
    ../imageprovider.cpp \
    ../settings.cpp

HEADERS += \
    ../imageprovider.h \
    ../settings.h

INCLUDEPATH += \
    ../

QT += svg

moreqml.files = $${PWD}/../qml/touchandlearn
moreqml.path = /usr/share/$${TARGET}/qml

audio.files = $${PWD}/../data/audio
audio.path = /usr/share/$${TARGET}/data

graphics.files = $${PWD}/../data/graphics
graphics.path = /usr/share/$${TARGET}/data

translations.files = $${PWD}/../data/translations
translations.path = /usr/share/$${TARGET}/data

INSTALLS += moreqml audio graphics translations
