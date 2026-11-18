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

import QtQuick 2.2
import QtMultimedia
import "database.js" as Database

Item {
    id: feedback

    property int previousCorrectSound: -1
    property int previousIncorrectSound: -1

    function audioUrl(name: string): url
    {
        return Qt.resolvedUrl("data/audio/" + name + ".wav");
    }

    property list<SoundEffect> correctSounds: [
        SoundEffect { source: feedback.audioUrl("correctanswer_01") },
        SoundEffect { source: feedback.audioUrl("correctanswer_02") },
        SoundEffect { source: feedback.audioUrl("correctanswer_03") },
        SoundEffect { source: feedback.audioUrl("correctanswer_04") },
        SoundEffect { source: feedback.audioUrl("correctanswer_05") }
    ]

    property list<SoundEffect> incorrectSounds: [
        SoundEffect { source: feedback.audioUrl("incorrectanswer_01") },
        SoundEffect { source: feedback.audioUrl("incorrectanswer_02") },
        SoundEffect { source: feedback.audioUrl("incorrectanswer_03") },
        SoundEffect { source: feedback.audioUrl("incorrectanswer_04") }
    ]

    function randomSoundIndex(sounds: list<SoundEffect>, currentSoundIndex: int): int
    {
        for (;;) {
            const result = Math.floor(Math.random() * sounds.length);
            if (result !== currentSoundIndex)
                return result;
        }
    }

    function playCorrectSound(): void
    {
        previousCorrectSound = randomSoundIndex(correctSounds, previousCorrectSound);
        var sound = correctSounds[previousCorrectSound];
        sound.volume = Database.currentVolume / 100;
        sound.play();
    }

    function playIncorrectSound(): void
    {
        previousIncorrectSound = randomSoundIndex(incorrectSounds, previousIncorrectSound);
        var sound = incorrectSounds[previousIncorrectSound];
        sound.volume = Database.currentVolume / 100;
        sound.play();
    }
}
