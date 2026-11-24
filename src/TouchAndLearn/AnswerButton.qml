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

Item {
    property int index: 0
    property string text
    property string correctionImageSource
    final property bool isCorrectAnswer: false
    property bool grayBackground: false
    // Shared by all buttons of the choice, so only one button reacts at a time
    required property AnswerChoice answerChoice
    readonly property color normalStateColor: "#fff"
    readonly property color correctStateColor: "#ffa"
    readonly property color wrongStateColor: "#f66"
    readonly property color correctionStateColor: grayBackground ? "#ccc" : "#fbb"

    readonly property int wrongAnswerShakeAmplitudeCalc: width * 0.2
    readonly property int wrongAnswerShakeAmplitudeMin: 45
    readonly property int wrongAnswerShakeAmplitude: wrongAnswerShakeAmplitudeCalc < wrongAnswerShakeAmplitudeMin ? wrongAnswerShakeAmplitudeMin : wrongAnswerShakeAmplitudeCalc
    readonly property int correctionImageSize: (height < width ? height : width) * 0.9

    // Timing of contentChangeAnimation, in milliseconds
    readonly property int blendDuration: 250
    readonly property int blendOutDelay: 250
    readonly property int blendInDelay: 350
    readonly property int staggerDelay: index * 85 // Buttons with a higher index change later

    signal correctlyPressed
    signal incorrectlyPressed
    signal contentChangeAnimationFinished

    id: button
    Rectangle {
        id: rect
        anchors.fill: parent
        color: button.normalStateColor
    }
    Particles {
        anchors.fill: parent
        id: particles
    }
    Image {
        source: "image://imageprovider/button/" + button.index
        sourceSize { height: parent.height; width: parent.width }
        smooth: false
    }
    Text {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        // Centered via x instead of anchors, because wrongAnswerAnimation animates x.
        readonly property int horizontallyCenteredX: (button.width - width) >> 1;
        x: horizontallyCenteredX;
        // Fixed width plus HorizontalFit keeps long (translated) answers inside the button.
        width: button.width * 0.95
        horizontalAlignment: Text.AlignHCenter
        fontSizeMode: Text.HorizontalFit
        minimumPixelSize: 8
        font.pixelSize: parent.height * 0.33
    }
    Image {
        id: correctionImage
        // Hand-centered in order to avoid non-integer image coordinates.
        readonly property int _leftMargin: (parent.width - width) / 2
        readonly property int _topMargin: (parent.height - height) / 2
        sourceSize { width: button.correctionImageSize; height: button.correctionImageSize }
        anchors { left: parent.left; top: parent.top; leftMargin: _leftMargin; topMargin: _topMargin; }
        opacity: 0
        smooth: false
    }

    MouseArea {
        anchors.fill: parent
        onPressed: {
            if (!button.answerChoice.blockClicks) {
                if (button.isCorrectAnswer)
                    correctAnswerAnimation.start();
                else
                    wrongAnswerAnimation.start();
            }
        }
    }

    onTextChanged: {
        if (wrongAnswerAnimation.running) {
            wrongAnswerAnimation.stop();
            label.opacity = 1;
            correctionImage.opacity = 0;
            rect.color = normalStateColor;
        }
        if (correctAnswerAnimation.running) {
            correctAnswerAnimation.stop();
            rect.color = normalStateColor;
        }

        contentChangeAnimation.complete();
        contentChangeAnimation.blendOut = label.text.length > 0;
        contentChangeAnimation.start();
    }

    // MainMenu disables the screen before unloading it. An animation handler running after the
    // Loader invalidated the context would warn "Attempted to evaluate an expression in an
    // invalid context".
    onEnabledChanged: {
        if (!enabled) {
            contentChangeAnimation.stop();
            correctAnswerAnimation.stop();
            wrongAnswerAnimation.stop();
        }
    }

    // No ScriptActions: qmlcachegen compiles neither them nor the rest of the file to C++.

    SequentialAnimation {
        id: contentChangeAnimation
        // false for the initially empty label: only the stagger pause precedes the blend in.
        // Not bound to label.text, which the animation sets, or the running animation would
        // pick up the changed durations and replay.
        property bool blendOut
        readonly property int blendOutPause: blendOut ? button.blendOutDelay + button.staggerDelay : 0
        readonly property int blendOutDuration: blendOut ? button.blendDuration : 0
        readonly property int blendInPause: blendOut ? button.blendInDelay : 0
        // Set between blend out and in to show the new text. A PropertyAction on label.text
        // would set the prior text.
        property bool showNewText
        onStarted: {
            showNewText = false;
            button.answerChoice.blockClicks = true;
        }
        onShowNewTextChanged: {
            if (showNewText)
                label.text = button.text;
        }
        onFinished: {
            button.answerChoice.blockClicks = false;
            button.contentChangeAnimationFinished();
        }
        PauseAnimation {
            duration: contentChangeAnimation.blendOutPause
        }
        // No Animators: during the ImageView scroll, their extra render thread frames would
        // make the scroll advance only every second frame.
        ParallelAnimation {
            NumberAnimation {
                target: label
                property: "scale"
                from: 1
                to: 0
                duration: contentChangeAnimation.blendOutDuration
                easing.type: Easing.InQuad
            }
            NumberAnimation {
                target: label
                property: "opacity"
                from: 1
                to: 0
                duration: contentChangeAnimation.blendOutDuration
                easing.type: Easing.OutQuad
            }
        }
        PauseAnimation {
            duration: contentChangeAnimation.blendInPause
        }
        PauseAnimation {
            duration: button.staggerDelay
        }
        PropertyAction {
            target: contentChangeAnimation
            property: "showNewText"
            value: true
        }
        ParallelAnimation {
            NumberAnimation {
                target: label
                property: "scale"
                from: 0
                to: 1
                duration: button.blendDuration
                easing.type: Easing.OutBack
            }
            NumberAnimation {
                target: label
                property: "opacity"
                from: 0
                to: 1
                duration: button.blendDuration
                easing.type: Easing.OutBack
            }
        }
    }
    SequentialAnimation {
        id: correctAnswerAnimation
        onStarted: {
            AnswerSounds.playCorrect();
            button.answerChoice.blockClicks = true;
            particles.burst(20);
        }
        onFinished: {
            button.answerChoice.blockClicks = false;
            button.correctlyPressed();
        }
        PropertyAction {
            target: rect
            property: "color"
            value: button.correctStateColor
        }
        PropertyAnimation {
            property: "color"
            target: rect
            to: button.normalStateColor
            duration: 700
        }
        PauseAnimation {
            duration: 300 // Wait for particles to finish
        }
    }
    SequentialAnimation {
        id: wrongAnswerAnimation
        // Set by the last step. With Animators inside, stop() also emits finished, and a stop
        // by onTextChanged must not report the press.
        property bool reachedEnd
        onStarted: {
            reachedEnd = false;
            AnswerSounds.playIncorrect();
            if (button.correctionImageSource.length) {
                correctionImage.sourceSize.height = button.correctionImageSize;
                correctionImage.sourceSize.width = button.correctionImageSize;
                correctionImage.source = button.correctionImageSource;
            }
        }
        onReachedEndChanged: {
            if (reachedEnd) {
                correctionImage.source = "";
                button.incorrectlyPressed();
            }
        }
        ParallelAnimation {
            SequentialAnimation {
                PropertyAction {
                    target: rect
                    property: "color"
                    value: button.wrongStateColor
                }
                PropertyAnimation {
                    property: "color"
                    target: rect
                    to: button.correctionImageSource.length ? button.correctionStateColor : button.normalStateColor
                    duration: button.correctionImageSource.length ? 450 : 600
                }
            }
            SequentialAnimation {
                XAnimator {
                    target: label
                    from: label.horizontallyCenteredX
                    to: label.horizontallyCenteredX - button.wrongAnswerShakeAmplitude
                    easing.type: Easing.InCubic
                    duration: 120
                }
                XAnimator {
                    target: label
                    from: label.horizontallyCenteredX - button.wrongAnswerShakeAmplitude
                    to: label.horizontallyCenteredX + button.wrongAnswerShakeAmplitude
                    easing.type: Easing.InOutCubic
                    duration: 220
                }
                XAnimator {
                    target: label
                    from: label.horizontallyCenteredX + button.wrongAnswerShakeAmplitude
                    to: label.horizontallyCenteredX
                    easing { type: Easing.OutBack; overshoot: 3 }
                    duration: 180
                }
            }
        }
        ParallelAnimation {
            OpacityAnimator {
                target: button.correctionImageSource.length ? correctionImage : null
                from: 0
                to: 1
            }
            OpacityAnimator {
                target: button.correctionImageSource.length ? label : null
                from: 1
                to: 0
            }
        }
        PauseAnimation {
            duration: button.correctionImageSource.length ? 1400 : 0
        }
        ParallelAnimation {
            OpacityAnimator {
                target: button.correctionImageSource.length ? correctionImage : null
                from: 1
                to: 0
            }
            OpacityAnimator {
                target: button.correctionImageSource.length ? label : null
                from: 0
                to: 1
            }
        }
        PropertyAnimation {
            property: "color"
            target: rect
            to: button.normalStateColor
            duration: 450
        }
        PropertyAction {
            target: wrongAnswerAnimation
            property: "reachedEnd"
            value: true
        }
    }
}
