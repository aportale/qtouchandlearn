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

import Qt 4.7
import "database.js" as Database

Rectangle {
    width: 360
    height: 640
    id: mainWindow
    color: "#000"

    function handleVolumeChange(volume)
    {
        Database.currentVolume = volume;
        if (volumeDisplay.source == '')
            volumeDisplay.source = 'VolumeDisplay.qml';
        else
            volumeDisplay.displayCurrentVolume();
    }

    Connections {
        target: stage.item
        id: connection
        ignoreUnknownSignals: true
        onSelectedLessonChanged: switchToScreen("Lesson" + stage.item.selectedLesson)
    }

    Rectangle {
        anchors.fill: parent
        id: courtain
        color: "#000"
        opacity: 1
        z: 1
        Text {
            id: loadingText
            anchors.centerIn: parent
            text: "..."
            color: "#FFF"
            font.pixelSize: 20
        }
    }

    Loader {
        id: stage
        width: parent.width
        height: parent.height
        onLoaded: {
            screenBlendIn.start();
        }
    }

    Loader {
        id: volumeDisplay
        width: parent.width
        height: parent.height

        onLoaded: {
            displayCurrentVolume();
        }

        function displayCurrentVolume()
        {
            item.volume = Database.currentVolume;
            volumeDisplayBlendOut.stop();
            opacity = 1;
            volumeDisplayBlendOut.start();
        }

        SequentialAnimation {
            id: volumeDisplayBlendOut
            PauseAnimation {
                duration: 850
            }
            PropertyAnimation {
                property: "opacity"
                target: volumeDisplay
                to: 0
            }
            ScriptAction {
                script: {
                    volumeDisplay.source = '';
                }
            }
        }
    }

    function switchToScreen(screen)
    {
        Database.lessonData = [];
        Database.currentScreen = screen + '.qml';
        if (stage.source == '')
            stage.source = Database.currentScreen;
        else
            screenBlendOut.start();
    }

    SequentialAnimation {
        id: screenBlendOut
        PropertyAnimation {
            target: courtain
            property: "opacity"
            to: 1
            duration: 180
        }
        ScriptAction {
            script: {
                stage.source = Database.currentScreen;
            }
        }
    }

    SequentialAnimation {
        id: screenBlendIn
        PropertyAnimation {
            target: courtain
            property: "opacity"
            to: 0
            duration: 180
        }
        ScriptAction {
            script: loadingText.text = '';
        }
    }

    function rotateItem(item)
    {
        item.width = height;
        item.height = width;
        item.y = height;
        item.transformOrigin = Item.TopLeft;
        item.rotation = 270;
    }

    function rotateItemsIfLandscape()
    {
        if (width > height) {
            rotateItem(stage);
            rotateItem(courtain);
        }
    }

    Timer {
        interval: 1
        running: true
        onTriggered: {
            rotateItemsIfLandscape();
            if (typeof(feedback) === "object")
                feedback.setAudioVolume(Database.persistentVolume(), false);
            switchToScreen("LessonMenu");
        }
    }

    Component.onDestruction: {
        Database.setPersistentVolume(Database.currentVolume);
    }
}
