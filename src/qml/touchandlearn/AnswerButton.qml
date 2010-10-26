/*
    Touch'n'learn - Fun and easy mobile lessons for kids
    Copyright (C) 2010 by Alessandro Portale
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
import Qt.labs.particles 1.0

Item {
    property int index: 0
    property string text
    property string correctionImageSource
    property bool isCorrectAnswer: false
    property color normalStateColor: "#fff"
    property color correctStateColor: "#ffa"
    property color wrongStateColor: "#f77"

    signal correctlyPressed
    signal incorrectlyPressed

    id: button
    Rectangle {
        id: rect
        anchors.fill: parent
        color: normalStateColor
    }
    Particles {
        id: particles
        anchors.fill: parent
        emissionRate: 0
        lifeSpan: 800; lifeSpanDeviation: 400
        angle: 0; angleDeviation: 360;
        velocity: 80; velocityDeviation: 30
        source:  "../../data/particle.svg" // Gets this image cached?
        clip: true
    }
    Image {
        source: "image://imageprovider/button/" + String(index)
        sourceSize.height: parent.height
        sourceSize.width: parent.width
        width: sourceSize.width
        height: sourceSize.height
    }
    Text {
        id: label
        anchors.centerIn: parent
        font.pixelSize: parent.height * 0.33
    }
    Item {
        id: correctionImageItem
        height: parent.height
        width: parent.height * 0.8
        anchors.right: parent.right
        Image {
            id: correctionImage
            anchors.centerIn: parent
            opacity: 0
        }
    }

    MouseArea {
        anchors.fill: parent
        onPressed: {
            if (isCorrectAnswer)
                correctAnswerAnimation.start();
            else
                wrongAnswerAnimation.start();
        }
    }

    onTextChanged: {
        wrongAnswerAnimation.complete();
        correctAnswerAnimation.complete();
        if (label.text.length == 0) {
            label.text = text;
        } else {
            contentChangeAnimation.complete();
            contentChangeAnimation.start();
        }
    }

    SequentialAnimation {
        id: contentChangeAnimation
        PauseAnimation {
            duration: 250 + index * 85
        }
        PropertyAnimation {
            id: fadein
            target: label
            properties: "scale, opacity"
            from: 1
            to: 0
            easing.type: Easing.InQuad
        }
        PauseAnimation {
            duration: 500 + index * 70
        }
        ScriptAction { // PropertyAction would fail here, and set the prior text
            script: label.text = text
        }
        PropertyAnimation {
            target: label
            properties: fadein.properties
            from: 0
            to: 1
            easing.type: Easing.OutBack
        }
    }
    SequentialAnimation {
        id: correctAnswerAnimation
        PropertyAction {
            target: rect
            property: "color"
            value: correctStateColor
        }
        ScriptAction {
            script: particles.burst(20);
        }
        PropertyAnimation {
            target: rect
            property: "color"
            to: normalStateColor
            duration: 700
        }
        PauseAnimation {
            duration: 300 // Wait for particles to finish
        }
        ScriptAction {
            script: correctlyPressed()
        }
    }
    SequentialAnimation {
        id: wrongAnswerAnimation
        PropertyAction {
            target: rect
            property: "color"
            value: wrongStateColor
        }
        PropertyAnimation {
            target: rect
            property: "color"
            to: normalStateColor
            duration: 400
        }
        ScriptAction {
            script: {
                if (correctionImageSource != "") {
                    correctionImage.sourceSize.height = correctionImageItem.height
                    correctionImage.sourceSize.width = correctionImageItem.width
                    correctionImage.source = correctionImageSource
                }
            }
        }
        PropertyAnimation {
            target: correctionImage
            property: "opacity"
            to: 1
            duration: correctionImageSource != "" ? 150 : 0
        }
        PauseAnimation {
            duration: correctionImageSource != "" ? 1000 : 0
        }
        PropertyAnimation {
            target: correctionImage
            property: "opacity"
            to: 0
        }
        ScriptAction {
            script: {
                correctionImage.source = ""
                incorrectlyPressed()
            }
        }
    }
}
