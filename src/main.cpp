/*
    Touch'n'learn - Fun and easy mobile lessons for kids
    Copyright (C) 2010, 2011 by Alessandro Portale
    http://touchandlearn.sourceforge.net

    This file is part of Touch'n'learn

    Touch'n'learn is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Touch'n'learn is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Touch'n'learn; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
*/

#include <QtCore/QLocale>
#include <QtCore/QTranslator>
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlEngine>
#include <QtQml/QQmlContext>
#include <QtQml/QQmlComponent>
#include <QtQuick/QQuickItem>
#ifdef USING_OPENGL
#include <QtOpenGL/QGLWidget>
#endif // USING_OPENGL

#include "qmlapplicationviewer.h"
#include "imageprovider.h"
#ifndef NO_FEEDBACK
#include "feedback.h"
#endif // NO_FEEDBACK

int main(int argc, char *argv[])
{
    qputenv("QML_ENABLE_TEXT_IMAGE_CACHE", "true");
    QCoreApplication::setApplicationName(QLatin1String("Touch'n'learn"));
    QGuiApplication app(argc, argv);
    const QString assetsPrefix =
#if defined(ASSETS_VIA_QRC)
            QLatin1String(":/");
#elif defined(Q_OS_MAC) // ASSETS_VIA_QRC
            QCoreApplication::applicationDirPath() + QLatin1String("/../Resources/");
#elif defined(Q_OS_BLACKBERRY)
            QLatin1String("app/native/");
#else // ASSETS_VIA_QRC
            QString();
#endif // ASSETS_VIA_QRC
    const QString dataPath = assetsPrefix + QLatin1String("data");

    const QString translation = QLocale::system().name();
    QTranslator translator;
    translator.load(translation, dataPath + QLatin1String("/translations"));
    QGuiApplication::installTranslator(&translator);

    // Registering dummy type to allow QML import of TouchAndLearn 1.0
    qmlRegisterType<QObject>("TouchAndLearn", 1, 0, "QObject");

    QmlApplicationViewer viewer;
#ifdef Q_OS_BLACKBERRY
    viewer.addImportPath(QStringLiteral("imports"));
#endif
    viewer.engine()->addImageProvider(QLatin1String("imageprovider"), new ImageProvider);
    const QString mainQml = QLatin1String("qml/touchandlearn/main.qml");
#ifdef ASSETS_VIA_QRC
    viewer.setSource(QUrl(QLatin1String("qrc:/") + mainQml));
#else // ASSETS_VIA_QRC
    viewer.setMainQmlFile(mainQml);
#endif // ASSETS_VIA_QRC
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationLockPortrait);

#ifndef NO_FEEDBACK
    Feedback::setDataPath(
#ifdef USING_QT_MOBILITY
                dataPath + QLatin1String("/audio")
#else // USING_QT_MOBILITY
                assetsPrefix + QLatin1String("mp3audio")
#endif // USING_QT_MOBILITY
    );
    Feedback feedback;
    viewer.rootContext()->setContextProperty("feedback", &feedback);
    QObject *rootObject = dynamic_cast<QObject*>(viewer.rootObject());
    QObject::connect(&feedback, SIGNAL(volumeChanged(QVariant)), rootObject, SLOT(handleVolumeChange(QVariant)));
#endif // NO_FEEDBACK

#if defined(Q_WS_SIMULATOR)
    viewer.showFullScreen();
#elif !defined(Q_WS_MAEMO_5) && !defined(Q_WS_MAEMO_6) && !defined(Q_OS_SYMBIAN) && !defined(MEEGO_EDITION_HARMATTAN) && !defined(Q_OS_BLACKBERRY)
    if (false)
        viewer.setGeometry(100, 100, 480, 800); // N900
    else
        viewer.setGeometry(100, 100, 360, 640); // NHD
#endif
    viewer.showExpanded();

    ImageProvider::setDataPath(dataPath + QLatin1String("/graphics"));
    ImageProvider::init();

    return app.exec();
}
