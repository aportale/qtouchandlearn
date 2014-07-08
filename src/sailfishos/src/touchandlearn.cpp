/*
    Touch'n'learn - Fun and easy mobile lessons for kids
    Copyright (C) 2010 - 2013 by Alessandro Portale
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

#include <QtQuick>
#include <sailfishapp.h>

#include "imageprovider.h"
#include "settings.h"

int main(int argc, char *argv[])
{
    // Registering dummy type to allow QML import of TouchAndLearn 1.0
    qmlRegisterType<QObject>("TouchAndLearn", 1, 0, "QObject");

    QGuiApplication *app = SailfishApp::application(argc, argv);
    QQuickView *view = SailfishApp::createView();

    const QString dataPath = SailfishApp::pathTo(QLatin1String("data")).toLocalFile();

    const QString translation = QLocale::system().name();
    QTranslator translator;
    translator.load(translation, dataPath + QLatin1String("/translations"));
    QGuiApplication::installTranslator(&translator);

    ImageProvider imageProvider;
    view->engine()->addImageProvider(QLatin1String("imageprovider"), &imageProvider);
    Settings settings;
    view->engine()->rootContext()->setContextProperty(QStringLiteral("settings"), &settings);

    ImageProvider::setDataPath(dataPath + QLatin1String("/graphics"));
    ImageProvider::init();

    const qreal devicePixelRatio = qApp->devicePixelRatio();
    view->engine()->rootContext()->setContextProperty(QStringLiteral("devicePixelRatio"), devicePixelRatio);
    view->engine()->rootContext()->setContextProperty(QStringLiteral("devicePixelRatioScale"), 1 / devicePixelRatio);

    view->setSource(SailfishApp::pathTo(QLatin1Literal("qml/main-sailfishos.qml")));
    view->show();
    return app->exec();
}
