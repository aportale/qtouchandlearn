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

android {
    ANDROID_DEPLOYMENT_DEPENDENCIES = \
        jar/QtAndroid-bundled.jar \
        jar/QtAndroidAccessibility-bundled.jar \
        jar/QtMultimedia-bundled.jar \
        lib/libQt5Core.so \
        lib/libQt5Gui.so \
        lib/libQt5Network.so \
        lib/libQt5Qml.so \
        lib/libQt5Quick.so \
        lib/libQt5QuickParticles.so \
        lib/libQt5Multimedia.so \
        lib/libQt5MultimediaQuick_p.so \
        plugins/audio/libqtaudio_opensles.so \
        qml/QtQuick/Particles.2/qmldir \
        qml/QtQuick/Particles.2/libparticlesplugin.so \
        qml/QtQuick/Window.2/qmldir \
        qml/QtQuick/Window.2/libwindowplugin.so \
        qml/QtQuick.2/qmldir \
        qml/QtQuick.2/libqtquick2plugin.so \
        qml/QtMultimedia/libdeclarative_multimedia.so \
        qml/QtMultimedia/qmldir

    exists($$[QT_INSTALL_PREFIX]/lib/libQt5Widgets.so):ANDROID_DEPLOYMENT_DEPENDENCIES += lib/libQt5Widgets.so
    exists($$[QT_INSTALL_PREFIX]/plugins/platforms/android/libqtforandroidGL.so) {
        # Qt < 5.3
        ANDROID_DEPLOYMENT_DEPENDENCIES += /plugins/platforms/android/libqtforandroidGL.so
    } else {
        # Qt >= 5.3
        ANDROID_DEPLOYMENT_DEPENDENCIES += /plugins/platforms/android/libqtforandroid.so
    }
    ANDROID_DEPLOYMENT_DEPENDENCIES += lib/libQt5Svg.so

    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

    OTHER_FILES += \
        android/AndroidManifest.xml
}

ios {
    # ./configure -xplatform macx-ios-clang -sdk iphoneos -release -developer-build -confirm-license -opensource -skip qttranslations -skip qtwebkit -skip qtserialport -skip qtimageformats -skip qtxmlpatterns -nomake tests -no-widgets -no-qml-debug -no-sql-sqlite -no-gif -no-libjpeg -no-dbus -D QT_NO_BIG_CODECS -D QT_NO_CSSPARSER -D QT_NO_PDF -D QT_NO_TEXTHTMLPARSER -D QT_NO_COLORNAMES -D QT_NO_PICTURE -D QT_NO_FTP -D QT_NO_TEXTODFWRITER

    QMAKE_INFO_PLIST = ios/Info.plist
    QTPLUGIN.audio=qtaudio_coreaudio
    QTPLUGIN.bearer=-
    QTPLUGIN.geoservices=-
    QTPLUGIN.iconengines=-
    QTPLUGIN.imageformats=-
    QTPLUGIN.mediaservice=-
    QTPLUGIN.platforms=-
    QTPLUGIN.playlistformats=-
    QTPLUGIN.position=-
#    QTPLUGIN.qmltooling=- # QTBUG-44389
    QTPLUGIN.sensorgestures=-
    QTPLUGIN.sensors=-
    QTPLUGIN.sqldrivers=-

    ios_icon.files = $$files($$PWD/ios/AppIcon*.png)
    QMAKE_BUNDLE_DATA += ios_icon

    # QTBUG-44384
    # Manual step needed: Remove qml plugin copying from XCode Build Phase "Qt Postlink"
    window_qmldir.files = $$[QT_INSTALL_QML]/QtQuick/Window.2/qmldir
    window_qmldir.path = /qt_qml/QtQuick/Window.2
    particles_qmldir.files = $$[QT_INSTALL_QML]/QtQuick/Particles.2/qmldir
    particles_qmldir.path = /qt_qml/QtQuick/Particles.2
    QMAKE_BUNDLE_DATA += window_qmldir particles_qmldir
}

winrt {
    # WINRT_MANIFEST = winrt/AppxManifest.in
    # Experimental: Add custom deployment step in Qt Creator.
    #   Command: %{sourceDir}\winrt\CreateAppxManifestMap.cmd
    #   Arguments: %{sourceDir} %{buildDir} %{Env:QTDIR}

    WINRT_MANIFEST.name = "Touch'n'learn"
    WINRT_MANIFEST.version = 1.2.0.0
    WINRT_MANIFEST.background = $${LITERAL_HASH}00a2ff
    WINRT_MANIFEST.publisher = "Alessandro Portale"
    WINRT_MANIFEST.publisherid = "CN=" # Can be found in store take-in page
    WINRT_MANIFEST.phone_product_id = "90a78d40-3ab7-4de6-8458-9a4c283eb5cc"
    WINRT_MANIFEST.identity = "50991AlessandroPortale.Touchnlearn"
    WINRT_MANIFEST.rotation_preference = portrait
    WINRT_MANIFEST.logo_store = winrt/assets/StoreLogo.png
    WINRT_MANIFEST.logo_small = winrt/assets/SmallLogo.png
    WINRT_MANIFEST.logo_large = winrt/assets/Logo.png
    WINRT_MANIFEST.splash_screen = winrt/assets/SplashScreen.png

    WINRT_MANIFEST.logo_44x44 = winrt/assets/SmallLogo.png
    WINRT_MANIFEST.logo_71x71 = winrt/assets/Square71x71Logo.png
    WINRT_MANIFEST.logo_480x800 = winrt/assets/SplashScreen.png

    CONFIG += windeployqt

    audio.files = winrt/audio/*
    audio.path = data/audio
    INSTALLS += audio
}

RESOURCES = \
    graphics.qrc \
    qml.qrc \
    translations.qrc

!winrt:RESOURCES += audio.qrc

DEFINES += \
    QT_USE_FAST_CONCATENATION \
    QT_USE_FAST_OPERATOR_PLUS

VERSION = 1.1

macx:ICON = touchandlearn.icns

SOURCES += \
    main.cpp \
    imageprovider.cpp \
    settings.cpp

HEADERS += \
    imageprovider.h \
    settings.h

QT += multimedia svg qml quick


# Default rules for deployment.
include(deployment.pri)
