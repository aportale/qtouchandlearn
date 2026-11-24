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

#include <QtCore/QList>
#include <QtCore/QObject>
#include <QtCore/QUrl>
#include <QtQml/QQmlEngine>

class Sound;

// Variants of a sound. play() picks a random one, never the previous one.
class RandomSound
{
public:
    // Creates a Sound for each of the sources, as a child of parent.
    RandomSound(const QList<QUrl> &sources, QObject *parent);

    // Plays a variant with the volume from 0 to 1.
    void play(qreal volume);

private:
    QList<Sound *> m_sounds;
    // The index of the variant that played last, or -1.
    int m_previousIndex = -1;
};

// QML singleton for the correct and incorrect answer sounds. The settings store the volume.
class AnswerSounds : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(int volume READ volume WRITE setVolume NOTIFY volumeChanged FINAL)

public:
    explicit AnswerSounds(QObject *parent = nullptr);

    // The volume of the sounds in percent, from 0 to 100.
    int volume() const;
    void setVolume(int volume);

    Q_INVOKABLE void playCorrect();
    Q_INVOKABLE void playIncorrect();

signals:
    void volumeChanged();

private:
    RandomSound m_correctSounds;
    RandomSound m_incorrectSounds;
    int m_volume;
};
