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

#pragma once

#include <QtCore/QObject>
#include <QtCore/QUrl>
#include <QtQml/QQmlEngine>

// Without Qt Multimedia, WebAssembly builds play the sounds with the Web Audio API.
#if !defined(TOUCHANDLEARN_USE_QTMULTIMEDIA) && defined(Q_OS_WASM)
#define TOUCHANDLEARN_USE_WEBAUDIO
#endif

#ifdef TOUCHANDLEARN_USE_QTMULTIMEDIA
class QSoundEffect;
#endif

// A short sound in QML. The QML code sets the source and the volume, and calls play().
// With TOUCHANDLEARN_USE_QTMULTIMEDIA, a QSoundEffect plays the sound. With
// TOUCHANDLEARN_USE_WEBAUDIO, the browser plays it. Without either, the sound is silent.
class Sound : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged FINAL)
    Q_PROPERTY(qreal volume READ volume WRITE setVolume NOTIFY volumeChanged FINAL)

public:
    explicit Sound(QObject *parent = nullptr);
    ~Sound() override;

    QUrl source() const;
    void setSource(const QUrl &source);

    // The volume from 0 to 1.
    qreal volume() const;
    void setVolume(qreal volume);

    Q_INVOKABLE void play();

signals:
    void sourceChanged();
    void volumeChanged();

private:
    QUrl m_source;
    qreal m_volume = 1;
#ifdef TOUCHANDLEARN_USE_QTMULTIMEDIA
    QSoundEffect *m_soundEffect;
#endif
#ifdef TOUCHANDLEARN_USE_WEBAUDIO
    // The key of the decoded sound on the JavaScript side.
    int m_id;
#endif
};
