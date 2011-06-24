/*
    Touch'n'learn - Fun and easy mobile lessons for kids
    Copyright (C) 2010 by Alessandro Portale
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
#include <QtGui/QApplication>
#include <QtGui/QGraphicsObject>
#include <QtDeclarative/QDeclarativeEngine>
#include <QtDeclarative/QDeclarativeContext>
#include <QtDeclarative/QDeclarativeComponent>

#include "qmlapplicationviewer.h"
#include "imageprovider.h"
#include "feedback.h"

int main(int argc, char *argv[])
{
    qputenv("QML_ENABLE_TEXT_IMAGE_CACHE", "true");
    QApplication::setStartDragDistance(15);
    QApplication::setStyle(QLatin1String("windows"));
    QApplication app(argc, argv);
    const QString assetsPrefix =
#ifdef ASSETS_VIA_QRC
            QLatin1String(":/");
#else // ASSETS_VIA_QRC
            QString();
#endif // ASSETS_VIA_QRC
    const QString dataPath = assetsPrefix + QLatin1String("data");

    const QString translation = QLatin1String("translation_") + QLocale::system().name();
    QTranslator translator;
    translator.load(translation, dataPath);
    QApplication::installTranslator(&translator);

    // Registering dummy type to allow QML import of TouchAndLearn 1.0
    qmlRegisterType<QObject>("TouchAndLearn", 1, 0, "QObject");

    QmlApplicationViewer viewer;
    viewer.engine()->addImageProvider(QLatin1String("imageprovider"), new ImageProvider);
    const QString mainQml = QLatin1String("qml/touchandlearn/main.qml");
#ifdef ASSETS_VIA_QRC
    viewer.setSource(QUrl(QLatin1String("qrc:/") + mainQml));
#else // ASSETS_VIA_QRC
    viewer.setMainQmlFile(mainQml);
#endif // ASSETS_VIA_QRC
    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationLockPortrait);

    Feedback feedback;
    viewer.rootContext()->setContextProperty("feedback", &feedback);
    QObject *rootObject = dynamic_cast<QObject*>(viewer.rootObject());
    QObject::connect(&feedback, SIGNAL(volumeChanged(QVariant)), rootObject, SLOT(handleVolumeChange(QVariant)));

#if defined(Q_WS_SIMULATOR)
    viewer.showFullScreen();
#elif !defined(Q_WS_MAEMO_5) && !defined(Q_WS_MAEMO_6) && !defined(Q_OS_SYMBIAN) && !defined(MEEGO_EDITION_HARMATTAN)
    if (false)
        viewer.setGeometry(100, 100, 480, 800); // N900
    else
        viewer.setGeometry(100, 100, 360, 640); // NHD
#endif
    viewer.showExpanded();

    ImageProvider::setDataPath(dataPath);
    ImageProvider::init();
    Feedback::setDataPath(dataPath);
    feedback.init();

    return app.exec();
}
