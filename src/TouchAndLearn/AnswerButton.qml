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
        // We need to manually horizonally center the text, because in wrongAnswerAnimation,
        // the x of the text is changed, which would not work if we use an anchor layout.
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

    // MainMenu disables the screen before it unloads it. The Loader invalidates the QML context
    // of the screen before it deletes the screen. A ScriptAction that runs in between would warn
    // "QQmlExpression: Attempted to evaluate an expression in an invalid context".
    onEnabledChanged: {
        if (!enabled) {
            contentChangeAnimation.stop();
            correctAnswerAnimation.stop();
            wrongAnswerAnimation.stop();
        }
    }

    SequentialAnimation {
        id: contentChangeAnimation
        // The label is empty before the first text arrives. Then there is nothing to blend
        // out, so only the stagger pause runs before the blend in. blendOut is set before each
        // start and must not be bound to label.text: the animation itself sets label.text, and
        // the NumberAnimations would pick up the changed durations while running and replay
        // the blend out and in.
        property bool blendOut
        readonly property int blendOutPause: blendOut ? button.blendOutDelay + button.staggerDelay : 0
        readonly property int blendOutDuration: blendOut ? button.blendDuration : 0
        readonly property int blendInPause: blendOut ? button.blendInDelay : 0
        ScriptAction {
            script: button.answerChoice.blockClicks = true
        }
        PauseAnimation {
            duration: contentChangeAnimation.blendOutPause
        }
        // This animation runs while the ImageView scrolls. It uses NumberAnimations instead of
        // Animators: Animators run on the render thread, which then renders additional frames
        // and lets the scroll animation of the ImageView advance only on every second frame.
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
                easing.type: Easing.InQuad
            }
        }
        PauseAnimation {
            duration: contentChangeAnimation.blendInPause
        }
        PauseAnimation {
            duration: button.staggerDelay
        }
        ScriptAction { // PropertyAction would fail here, and set the prior text
            script: label.text = button.text
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
        ScriptAction {
            script: {
                button.answerChoice.blockClicks = false;
                button.contentChangeAnimationFinished();
            }
        }
    }
    SequentialAnimation {
        id: correctAnswerAnimation
        ScriptAction {
            script: {
                if (typeof(feedback) === "object")
                    feedback.playCorrectSound();
                button.answerChoice.blockClicks = true;
                particles.burst(20);
            }
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
        ScriptAction {
            script: {
                button.answerChoice.blockClicks = false;
                button.correctlyPressed();
            }
        }
    }
    SequentialAnimation {
        id: wrongAnswerAnimation
        ParallelAnimation {
            SequentialAnimation {
                PropertyAction {
                    target: rect
                    property: "color"
                    value: button.wrongStateColor
                }
                ScriptAction {
                    script: {
                        if (typeof(feedback) === "object")
                            feedback.playIncorrectSound();
                        if (button.correctionImageSource.length) {
                            correctionImage.sourceSize.height = button.correctionImageSize
                            correctionImage.sourceSize.width = button.correctionImageSize
                            correctionImage.source = button.correctionImageSource
                        }
                    }
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
        ScriptAction {
            script: {
                correctionImage.source = "";
                button.incorrectlyPressed();
            }
        }
    }
}
