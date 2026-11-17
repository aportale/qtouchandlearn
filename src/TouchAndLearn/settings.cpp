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

#include "settings.h"

#include <QtCore/QSettings>

Settings *Settings::s_instance = nullptr;

Settings::Settings(QObject *parent)
    : QObject(parent)
{
    Q_ASSERT(!s_instance);
    s_instance = this;
    m_settings = new QSettings(this);
}

Settings::~Settings()
{
    s_instance = nullptr;
}

Settings *Settings::create(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
{
    Q_UNUSED(qmlEngine)
    Q_UNUSED(jsEngine)
    Q_ASSERT(s_instance);
    // main() owns the instance. Keep the engine from deleting it.
    QJSEngine::setObjectOwnership(s_instance, QJSEngine::CppOwnership);
    return s_instance;
}

void Settings::setValue(const QString &group, const QString &key, const QVariant &value)
{
    m_settings->beginGroup(group);
    m_settings->setValue(key, value);
    m_settings->endGroup();
}

QString Settings::value(const QString &group, const QString &key, const QString &defaultValue) const
{
    m_settings->beginGroup(group);
    const QString result = m_settings->value(key, defaultValue).toString();
    m_settings->endGroup();
    return result;
}
