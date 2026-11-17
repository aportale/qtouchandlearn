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

#include <QtCore/QDebug>
#include <QtCore/QDir>
#include <QtCore/QLocale>
#include <QtCore/QTranslator>
#include <QtGui/QGuiApplication>
#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include <QtQml/QQmlExtensionPlugin>

#include "imageprovider.h"
#include "settings.h"

// The static plugin of the QML module in TouchAndLearn/. It is not the plugin in
// TouchAndLearnPlugin/. The reference keeps the linker from dropping the module.
Q_IMPORT_QML_PLUGIN(TouchAndLearnPlugin)

int main(int argc, char *argv[])
{
    // We only play WAV files. Turn off the FFmpeg backend's hardware codec check,
    // which slows down startup. These variables are not public Qt API.
    if (!qEnvironmentVariableIsSet("QT_FFMPEG_DECODING_HW_DEVICE_TYPES"))
        qputenv("QT_FFMPEG_DECODING_HW_DEVICE_TYPES", ",");
    if (!qEnvironmentVariableIsSet("QT_FFMPEG_ENCODING_HW_DEVICE_TYPES"))
        qputenv("QT_FFMPEG_ENCODING_HW_DEVICE_TYPES", ",");

    QCoreApplication::setOrganizationName("CasaPortale");
    QCoreApplication::setOrganizationDomain("casaportale.de");
    QCoreApplication::setApplicationName(QLatin1String("Touch'n'learn"));

    QGuiApplication app(argc, argv);
    const QString assetsPrefix = QLatin1String(":/qt/qml/TouchAndLearn/");
    const QString dataPath = assetsPrefix + QLatin1String("data");

    const QString translation = QLocale::system().name();
    QTranslator translator;
    if (!translator.load(translation, dataPath + QLatin1String("/translations")))
        qWarning() << "Could not load translation" << translation;
    QGuiApplication::installTranslator(&translator);

    Settings settings; // Needs to be instantiated before engine, in order to be destructed after it
    QQmlApplicationEngine engine;
    engine.addImageProvider(QLatin1String("imageprovider"), new ImageProvider);
    engine.rootContext()->setContextProperty(QLatin1String("settings"), &settings);
    engine.loadFromModule("TouchAndLearn", "Main");

    ImageProvider::setDataPath(dataPath + QLatin1String("/graphics"));
    ImageProvider::init();

    return app.exec();
}
