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

#ifndef FEEDBACK_H
#define FEEDBACK_H

#include <QtCore/QObject>
#include <QtCore/QVariant>

class QMediaPlayer;

class Feedback : public QObject
{
    Q_OBJECT

public:
    explicit Feedback(QObject *parent = 0);
    ~Feedback();

    Q_INVOKABLE void playCorrectSound() const;
    Q_INVOKABLE void playIncorrectSound() const;

    void init();
    int audioVolume() const;
    Q_INVOKABLE void setAudioVolume(int volume, bool emitChangedSignal = true);
    static void setDataPath(const QString &path);

signals:
    void volumeChanged(QVariant volume);

private:
    QList<QMediaPlayer*> m_correctSounds;
    mutable QMediaPlayer *m_previousCorrectSound;
    QList<QMediaPlayer*> m_incorrectSounds;
    mutable QMediaPlayer *m_previousIncorrectSound;
    int m_audioVolume;
};

#endif // FEEDBACK_H
