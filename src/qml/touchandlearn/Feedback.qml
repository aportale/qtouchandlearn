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

import QtQuick 2.0
import QtMultimedia 5.0

Item {
    id: feedback

    property string audioFileExtension
    property string audioDirectory
    property string correctSoundBaseName: audioDirectory +"correctanswer_"
    property int previousCorrectSound: -1
    property string incorrectSoundBaseName: audioDirectory + "incorrectanswer_"
    property int previousIncorrectSound: -1

    property list<SoundEffect> correctSounds: [
        SoundEffect { source: feedback.correctSoundBaseName + "01" + feedback.audioFileExtension},
        SoundEffect { source: feedback.correctSoundBaseName + "02" + feedback.audioFileExtension},
        SoundEffect { source: feedback.correctSoundBaseName + "03" + feedback.audioFileExtension},
        SoundEffect { source: feedback.correctSoundBaseName + "04" + feedback.audioFileExtension},
        SoundEffect { source: feedback.correctSoundBaseName + "05" + feedback.audioFileExtension}
    ]

    property list<SoundEffect> incorrectSounds: [
        SoundEffect { source: feedback.incorrectSoundBaseName + "01" + feedback.audioFileExtension},
        SoundEffect { source: feedback.incorrectSoundBaseName + "02" + feedback.audioFileExtension},
        SoundEffect { source: feedback.incorrectSoundBaseName + "03" + feedback.audioFileExtension},
        SoundEffect { source: feedback.incorrectSoundBaseName + "04" + feedback.audioFileExtension}
    ]

    function randomSoundIndex(sounds, currentSoundIndex)
    {
        for (;;) {
            var result = Math.floor(Math.random() * sounds.length);
            if (result !== currentSoundIndex)
                return result;
        }
    }

    function playCorrectSound()
    {
        previousCorrectSound = randomSoundIndex(correctSounds, previousCorrectSound);
        correctSounds[previousCorrectSound].play();
    }

    function playIncorrectSound()
    {
        previousIncorrectSound = randomSoundIndex(incorrectSounds, previousIncorrectSound);
        incorrectSounds[previousIncorrectSound].play();
    }
}
