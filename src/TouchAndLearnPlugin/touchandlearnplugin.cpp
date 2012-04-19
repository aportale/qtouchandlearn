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

#include "touchandlearnplugin.h"
#include "imageprovider.h"
#include <QtQml/QQmlEngine>

void TouchAndLearnPlugin::registerTypes(const char *uri)
{
    // @uri TouchAndLearn
    qmlRegisterType<QObject>(uri, 1, 0, "TouchAndLearn");
}

void TouchAndLearnPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    Q_UNUSED(uri)
    const QString graphicsPath = engine->baseUrl().toLocalFile() + QLatin1String("data/graphics");
    ImageProvider::setDataPath(graphicsPath);
    engine->addImageProvider(QLatin1String("imageprovider"), new ImageProvider);
}
