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

#ifndef TOUCHANDLEARNPLUGIN_H
#define TOUCHANDLEARNPLUGIN_H

#include <QtDeclarative/qdeclarative.h>
#include <QtDeclarative/QDeclarativeExtensionPlugin>

class TouchAndLearnPlugin : public QDeclarativeExtensionPlugin
{
    Q_OBJECT

public:
    void registerTypes(const char *uri);
    void initializeEngine(QDeclarativeEngine *engine, const char *uri);
};

#endif // TOUCHANDLEARNPLUGIN_H
