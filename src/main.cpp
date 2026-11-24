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
#include <QtQml/QQmlExtensionPlugin>

#include "imageprovider.h"

// Keeps the linker from dropping the static QML module plugin in TouchAndLearn/.
Q_IMPORT_QML_PLUGIN(TouchAndLearnPlugin)

int main(int argc, char *argv[])
{
#ifdef TOUCHANDLEARN_USE_QTMULTIMEDIA
    // Skip FFmpeg's slow hardware codec check, unneeded for WAV files (not public Qt API).
    if (!qEnvironmentVariableIsSet("QT_FFMPEG_DECODING_HW_DEVICE_TYPES"))
        qputenv("QT_FFMPEG_DECODING_HW_DEVICE_TYPES", ",");
    if (!qEnvironmentVariableIsSet("QT_FFMPEG_ENCODING_HW_DEVICE_TYPES"))
        qputenv("QT_FFMPEG_ENCODING_HW_DEVICE_TYPES", ",");
#endif

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

    QQmlApplicationEngine engine;
    engine.addImageProvider(QLatin1String("imageprovider"), new ImageProvider);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, [] { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
    engine.loadFromModule("TouchAndLearn", "Main");
    // Create the singleton now instead of at the first answer, so that the sounds are loaded and,
    // on WebAssembly, the AudioContext listeners are ready to resume it at the first touch.
    if (!engine.singletonInstance<QObject *>("TouchAndLearn", "AnswerSounds"))
        qWarning() << "Could not create the AnswerSounds singleton";

    ImageProvider::setDataPath(dataPath + QLatin1String("/graphics"));
    ImageProvider::init();

    return app.exec();
}
