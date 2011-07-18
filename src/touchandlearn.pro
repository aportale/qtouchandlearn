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

android:DEFINES += ASSETS_VIA_QRC

contains(DEFINES, ASSETS_VIA_QRC) {
    RESOURCES = touchandlearn.qrc
} else {
    folder_01.source = qml/touchandlearn
    folder_01.target = qml
    folder_02.source = data
    DEPLOYMENTFOLDERS = folder_01 folder_02
}

DEFINES += \
    QT_USE_FAST_CONCATENATION \
    QT_USE_FAST_OPERATOR_PLUS

symbian {
    TARGET.UID3 = 0xE10d63ca
    # TARGET.UID3 = 0x20045CB7
    # vendorinfo = "%{\"SolApps\"}" ":\"SolApps\""
    CONFIG += mobility
    MOBILITY += multimedia
    LIBS += -lremconcoreapi -lremconinterfacebase
}
VERSION = 1.1

SOURCES += main.cpp \
    imageprovider.cpp \
    feedback.cpp

HEADERS += \
    imageprovider.h \
    feedback.h

QT += svg

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()
