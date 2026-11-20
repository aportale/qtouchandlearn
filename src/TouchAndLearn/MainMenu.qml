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

import QtQuick
import "database.js" as Database

Rectangle {
    id: mainWindow
    color: "#000"

    readonly property StageScreen stageScreen: stage.item as StageScreen

    function handleVolumeChange(volume: int): void
    {
        Database.currentVolume = volume;
        AnswerSounds.volume = volume / 100;
        if (!volumeDisplay.active)
            volumeDisplay.active = true;
        else
            volumeDisplay.displayCurrentVolume();
    }

    focus: true
    Keys.onPressed: function(event: KeyEvent): void {
        if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape) {
            if (!stageScreen) { // Next screen is still loading
                event.accepted = true;
                return;
            }
            if (stageScreen.backLesson.length > 0)
                stageScreen.selectedLesson = stageScreen.backLesson;
            else
                Qt.quit();
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
        target: mainWindow.stageScreen
        id: connection
        function onSelectedLessonChanged(): void {
            mainWindow.switchToScreen("Lesson" + mainWindow.stageScreen.selectedLesson)
        }
    }

    Rectangle {
        anchors.fill: parent
        id: courtain
        color: "#000"
        opacity: 1
        z: 1
    }

    // Screens load asynchronously, so the UI keeps repainting while they are built.
    // The opaque curtain covers the stage until onLoaded starts screenBlendIn.
    Loader {
        id: stage
        width: parent.width
        height: parent.height
        asynchronous: true
        onLoaded: {
            screenBlendIn.start();
        }
    }

    Loader {
        id: volumeDisplay
        width: parent.width
        height: parent.height
        active: false
        sourceComponent: VolumeDisplay {}

        onLoaded: {
            displayCurrentVolume();
        }

        function displayCurrentVolume(): void
        {
            (volumeDisplay.item as VolumeDisplay).volume = Database.currentVolume;
            volumeDisplayBlendOut.stop();
            opacity = 1;
            volumeDisplayBlendOut.start();
        }

        // The animations act in signal handlers instead of in ScriptActions. qmlcachegen does
        // not compile the script of a ScriptAction to C++. It then also skips all bindings and
        // signal handlers of the file that it processes after that script.
        SequentialAnimation {
            id: volumeDisplayBlendOut
            // The last step sets reachedEnd. This animation contains an Animator, and Qt emits
            // finished also when stop() stops such an animation. displayCurrentVolume() stops
            // it, and then the volume display must stay.
            property bool reachedEnd
            onStarted: reachedEnd = false
            onReachedEndChanged: {
                if (reachedEnd)
                    volumeDisplay.active = false;
            }
            PauseAnimation {
                duration: 850
            }
            OpacityAnimator {
                target: volumeDisplay
                from: 1
                to: 0
                duration: 350
            }
            PropertyAction {
                target: volumeDisplayBlendOut
                property: "reachedEnd"
                value: true
            }
        }
    }

    function switchToScreen(screen: string): void
    {
        Database.lessonData = [];
        Database.currentScreen = screen;
        Database.persistence.writeAll(); // TODO: Remove this hack. See https://together.jolla.com/question/49775/componentondestruction-of-applicationwindow-not-called/
        if (stage.status === Loader.Null) {
            stage.sourceComponent = Qt.createComponent("TouchAndLearn", screen);
        } else {
            // The old screen ignores input and stops its animations while it blends out.
            if (stageScreen)
                stageScreen.leaving = true;
            screenBlendOut.start();
        }
    }

    SequentialAnimation {
        id: screenBlendOut
        onFinished: stage.sourceComponent = Qt.createComponent("TouchAndLearn", Database.currentScreen)
        OpacityAnimator {
            target: courtain
            from: 0
            to: 1
            duration: 180
        }
    }

    SequentialAnimation {
        id: screenBlendIn
        OpacityAnimator {
            target: courtain
            from: 1
            to: 0
            duration: 180
        }
    }

    Timer {
        interval: 1
        running: true
        onTriggered: {
            Database.data.initCaches();
            mainWindow.switchToScreen("LessonMenu");
        }
    }

    Component.onCompleted: {
        Database.settings = Settings; // database.js is a ".pragma library" script, which does not see the imports of this file
        Database.persistence.readCurrentLessonsOfGroups();
        Database.currentVolume = Database.persistence.readVolume();
        AnswerSounds.volume = Database.currentVolume / 100;
    }

    Component.onDestruction: {
        Database.persistence.writeAll();
    }
}
