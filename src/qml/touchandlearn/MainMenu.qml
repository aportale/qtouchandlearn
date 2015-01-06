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

import QtQuick 2.1
import "database.js" as Database

Rectangle {
    id: mainWindow
    color: "#000"

    property bool titleAnimationEnabled: true
    property bool portaitLayout: width < (height * 1.5)

    function handleVolumeChange(volume)
    {
        Database.currentVolume = volume;
        if (volumeDisplay.source == '')
            volumeDisplay.source = 'VolumeDisplay.qml';
        else
            volumeDisplay.displayCurrentVolume();
    }

    focus: true
    Keys.onPressed: {
        if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape) {
            if (stage.item.quitsOnBack && Qt.platform.os == "winphone")
                return;
            stage.item.goBack();
            event.accepted = true;
        } else if (event.key === Qt.Key_VolumeUp || event.key === Qt.Key_Plus) {
            handleVolumeChange(Math.min(Database.currentVolume + 20, 100));
            event.accepted = true;
        } else if (event.key === Qt.Key_VolumeDown || event.key === Qt.Key_Minus) {
            handleVolumeChange(Math.max(Database.currentVolume - 20, 0));
            event.accepted = true;
        }
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
                from: 1
                to: 0
                duration: 350
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
        Database.persistence.writeAll(); // TODO: Remove this hack. See https://together.jolla.com/question/49775/componentondestruction-of-applicationwindow-not-called/
        if (stage.source == '')
            stage.source = Database.currentScreen;
        else
            screenBlendOut.start();
    }

    SequentialAnimation {
        id: screenBlendOut
        PropertyAnimation {
            property: "opacity"
            target: courtain
            from: 0
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
            property: "opacity"
            target: courtain
            from: 1
            to: 0
            duration: 180
        }
        ScriptAction {
            script: loadingText.text = '';
        }
    }

    Timer {
        interval: 1
        running: true
        onTriggered: {
            Database.data.initCaches();
            switchToScreen("LessonMenu");
        }
    }

    Component.onCompleted: {
        Database.settings = settings; // JS with ".pragma library" cannot directly access context property
        Database.persistence.readCurrentLessonsOfGroups();
        Database.currentVolume = Database.persistence.readVolume();
    }

    Component.onDestruction: {
        Database.persistence.writeAll();
    }
}
