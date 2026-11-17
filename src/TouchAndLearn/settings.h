/*
    Touch'n'learn - Fun and easy mobile lessons for kids
    Copyright (C) 2010 - 2014 by Alessandro Portale
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

#pragma once

#include <QtCore/QObject>
#include <QtQml/QQmlEngine>

class QSettings;

// The Settings singleton in QML. main() creates the only instance before the QML engine,
// so that it outlives the engine. MainMenu writes the settings when the engine destroys it.
class Settings : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    // No default argument: the QML engine would use a default constructor instead of create().
    explicit Settings(QObject *parent);
    ~Settings() override;

    // Called by the QML engine. Returns the instance that main() created.
    static Settings *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);

    Q_INVOKABLE void setValue(const QString &group, const QString &key, const QVariant &value);
    Q_INVOKABLE QString value(const QString &group, const QString &key, const QString &defaultValue) const;

private:
    QSettings *m_settings;
    static Settings *s_instance;
};
