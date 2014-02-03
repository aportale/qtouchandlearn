# Touch'n'learn - Fun and easy mobile lessons for kids
# Copyright (C) 2010, 2011 by Alessandro Portale
# http://touchandlearn.sourceforge.net
#
# This file is part of Touch'n'learn
#
# Touch'n'learn is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Touch'n'learn is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Touch'n'learn; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA

DEPLOYMENT.display_name = "Touch'n'Learn"

android {
    DEFINES += NO_FEEDBACK
    QT += sql # for QtQuick.LocalStorage
#    ANDROID_DEPLOYMENT_DEPENDENCIES = \
#        lib/libQt5Sql.so \
#        lib/libQt5Gui.so \
#        lib/libQt5Core.so \
#        plugins/platforms/android/libqtforandroidGL.so
}

contains(DEFINES, ASSETS_VIA_QRC) {
    RESOURCES = touchandlearn.qrc
} else {
    qml.source = qml/touchandlearn
    qml.target = qml
    data.source = data
    DEPLOYMENTFOLDERS = qml data
}

DEFINES += \
    QT_USE_FAST_CONCATENATION \
    QT_USE_FAST_OPERATOR_PLUS

symbian {
    TARGET.UID3 = 0xE10d63ca
    # TARGET.UID3 = 0x20045CB7
    # vendorinfo = "%{\"SolApps\"}" ":\"SolApps\""
    LIBS += -lremconcoreapi -lremconinterfacebase
}
VERSION = 1.1

DEFINES += NO_FEEDBACK
!contains(DEFINES, NO_FEEDBACK) {
    greaterThan(QT_MAJOR_VERSION, 4) {
        QT += multimedia
        DEFINES += USING_QT_MULTIMEDIA
        mp3audio.source = mp3audio
        DEPLOYMENTFOLDERS += mp3audio
    } else {
        load(mobilityconfig, true)
        contains(MOBILITY_CONFIG, multimedia) {
            CONFIG += mobility
            MOBILITY += multimedia
            DEFINES += USING_QT_MOBILITY
        } else {
            QT += phonon
            mp3audio.source = mp3audio
            DEPLOYMENTFOLDERS += mp3audio
        }
    }
    SOURCES += feedback.cpp
    HEADERS += feedback.h
}

!symbian:!maemo5:isEmpty(MEEGO_VERSION_MAJOR) {
    #QT += opengl
    #DEFINES += USING_OPENGL
}

macx:ICON = touchandlearn.icns

SOURCES += \
    main.cpp \
    imageprovider.cpp

HEADERS += \
    imageprovider.h

QT += svg

# Please do not modify the following two lines. Required for deployment.
include(qtquick2applicationviewer/qtquick2applicationviewer.pri)
qtcAddDeployment()

blackberry {
OTHER_FILES += \
    bar-descriptor.xml
}
