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
#include <QtDeclarative/QDeclarativeEngine>
#include <QtDeclarative/QDeclarativeContext>

#include "qmlapplicationviewer.h"
#include "imageprovider.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QApplication::setStartDragDistance(15);

    const QString translation = QLatin1String("translation_") + QLocale::system().name();
    QTranslator translator;
    translator.load(translation, QLatin1String("data"));
    QApplication::installTranslator(&translator);

    QmlApplicationViewer viewer;
    viewer.engine()->addImageProvider(QLatin1String("imageprovider"), new ImageProvider);
    viewer.setMainQmlFile(QLatin1String("qml/touchandlearn/MainNavigation.qml"));
    viewer.setOrientation(QmlApplicationViewer::LockPortrait);

#ifdef Q_OS_SYMBIAN
    viewer.showFullScreen();
#elif defined(Q_WS_MAEMO_5) || defined(Q_WS_MAEMO_6)
    viewer.showMaximized();
#else
    if (false)
        viewer.setGeometry(100, 100, 480, 800); // N900
    else
        viewer.setGeometry(100, 100, 360, 640); // NHD
    viewer.show();
#endif

    return app.exec();
}

