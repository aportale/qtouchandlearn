/*
    Touch'n'learn - Fun and easy mobile lessons for kids
    Copyright (C) 2026 by Alessandro Portale
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

#include "sound.h"

#ifdef TOUCHANDLEARN_USE_QTMULTIMEDIA
#include <QtMultimedia/QSoundEffect>
#endif

Sound::Sound(QObject *parent)
    : QObject(parent)
#ifdef TOUCHANDLEARN_USE_QTMULTIMEDIA
    , m_soundEffect(new QSoundEffect(this))
#endif
{
}

QUrl Sound::source() const
{
    return m_source;
}

void Sound::setSource(const QUrl &source)
{
    if (source == m_source)
        return;
    m_source = source;
#ifdef TOUCHANDLEARN_USE_QTMULTIMEDIA
    m_soundEffect->setSource(source);
#endif
    emit sourceChanged();
}

qreal Sound::volume() const
{
    return m_volume;
}

void Sound::setVolume(qreal volume)
{
    if (volume == m_volume)
        return;
    m_volume = volume;
#ifdef TOUCHANDLEARN_USE_QTMULTIMEDIA
    m_soundEffect->setVolume(volume);
#endif
    emit volumeChanged();
}

void Sound::play()
{
#ifdef TOUCHANDLEARN_USE_QTMULTIMEDIA
    m_soundEffect->play();
#endif
}
