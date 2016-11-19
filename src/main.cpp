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
#include <QtCore/QDir>
#include <QtCore/QTranslator>
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlApplicationEngine>
#include <QtQml>

#include "imageprovider.h"
#include "settings.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setOrganizationName("CasaPortale");
    QCoreApplication::setOrganizationDomain("casaportale.de");
    QCoreApplication::setApplicationName(QLatin1String("Touch'n'learn"));

    QGuiApplication app(argc, argv);
    const QString assetsPrefix = QLatin1String(":/");
    const QString dataPath = assetsPrefix + QLatin1String("data");

    const QString translation = QLocale::system().name();
    QTranslator translator;
    translator.load(translation, dataPath + QLatin1String("/translations"));
    QGuiApplication::installTranslator(&translator);

    // Registering dummy type to allow QML import of TouchAndLearn 1.0
    qmlRegisterType<QObject>("TouchAndLearn", 1, 0, "QObject");

    Settings settings; // Needs to be instantiated before engine, in order to be destructed after it
    QQmlApplicationEngine engine;
    engine.addImageProvider(QLatin1String("imageprovider"), new ImageProvider);
    engine.rootContext()->setContextProperty(QLatin1String("settings"), &settings);
    const QString textFontFamily =
#ifdef Q_OS_IOS
            QSysInfo::macVersion() <= QSysInfo::MV_IOS_6_1 ? QLatin1String("Arial") : // Workaround for QTBUG-44254
#endif
            QString();
    engine.rootContext()->setContextProperty(QLatin1String("textFontFamily"), textFontFamily);
    engine.load(QUrl(QLatin1String("qrc:///qml/touchandlearn/main.qml"))); // Needs to be "qrc:///" -> QTBUG-42102

    ImageProvider::setDataPath(dataPath + QLatin1String("/graphics"));
    ImageProvider::init();

    return app.exec();
}
