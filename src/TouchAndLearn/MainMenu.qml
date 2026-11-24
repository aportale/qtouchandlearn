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

Rectangle {
    id: mainWindow
    color: "#000"

    readonly property StageScreen stageScreen: stage.item as StageScreen
    // The screen that the stage shows, or that it loads after the current one blended out
    property string currentScreen

    function handleVolumeChange(volume: int): void
    {
        AnswerSounds.volume = volume;
        if (!volumeDisplay.active)
            volumeDisplay.active = true;
        else
            volumeDisplay.displayCurrentVolume();
    }

    focus: true
    Keys.onPressed: function(event: KeyEvent): void {
        if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape) {
            // The next screen is still loading, or the current one blends out and ignores input.
            if (!stageScreen || stageScreen.leaving) {
                event.accepted = true;
                return;
            }
            if (stageScreen.backLesson.length > 0)
                stageScreen.selectedLesson = stageScreen.backLesson;
            else
                Qt.quit();
            event.accepted = true;
        } else if (event.key === Qt.Key_VolumeUp || event.key === Qt.Key_Plus) {
            handleVolumeChange(Math.min(AnswerSounds.volume + 20, 100));
            event.accepted = true;
        } else if (event.key === Qt.Key_VolumeDown || event.key === Qt.Key_Minus) {
            handleVolumeChange(Math.max(AnswerSounds.volume - 20, 0));
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
        id: curtain
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
            (volumeDisplay.item as VolumeDisplay).volume = AnswerSounds.volume;
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
        currentScreen = screen;
        if (stage.status === Loader.Null) {
            stage.sourceComponent = Qt.createComponent("TouchAndLearn", screen);
        } else {
            // The old screen ignores input and stops its animations while it blends out.
            if (stageScreen)
                stageScreen.leaving = true;
            // The screen can be left while it still blends in. Stopping screenBlendIn writes
            // the current opacity back to the curtain, and screenBlendOut, which has no from
            // value, closes the curtain from there. Otherwise both animators would drive the
            // curtain at the same time.
            screenBlendIn.stop();
            screenBlendOut.start();
        }
    }

    OpacityAnimator {
        id: screenBlendOut
        target: curtain
        to: 1
        duration: 180
        onFinished: stage.sourceComponent = Qt.createComponent("TouchAndLearn", mainWindow.currentScreen)
    }

    OpacityAnimator {
        id: screenBlendIn
        target: curtain
        from: 1
        to: 0
        duration: 180
    }

    Timer {
        interval: 1
        running: true
        onTriggered: mainWindow.switchToScreen("LessonMenu")
    }
}
