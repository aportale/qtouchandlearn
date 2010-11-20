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

Item {
    property alias backgroundImage: imageView.backgroundImage
    property alias imageSizeFactor: imageView.imageSizeFactor
    property alias exerciseFunction: imageView.exerciseFunction
    property alias showCorrectionImageOnButton: choice.showCorrectionImage
    property alias answersCount: choice.buttonsCount
    property alias answersColumsCount: choice.columsCount
    property bool exitButtonVisible: true
    property real viewHeightRatio: 0.45

    signal closePressed

    ImageView {
        id: imageView
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        height: Math.round(parent.height * viewHeightRatio)
        answersCount: choice.buttonsCount

        // Theoretically unneeded, since the anchors above should do the job.
        // But without width, we get 0-values at construction time
        width: parent.width
    }

    Item {
        opacity: exitButtonVisible ? 1 : 0
        property real exitButtonSize: Math.round(Math.min(parent.width, parent.height) * 0.18)
        width: exitButtonSize
        height: exitButtonSize
        anchors.top: parent.top
        anchors.right: parent.right
        Image {
            property real exitImageSize: Math.round(parent.width * 0.5)
            sourceSize.width: exitImageSize
            sourceSize.height: exitImageSize
            anchors.centerIn: parent
            source: "image://imageprovider/specialbutton/exitbutton"
        }
        MouseArea {
            anchors.fill: parent
            onPressed: closePressed()
        }
    }

    AnswerChoice {
        id: choice
        anchors.top: imageView.bottom
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left

        // Theoretically unneeded, since the anchors above should do the job.
        // But without width/height, we get 0-values at construction time
        height: parent.height - imageView.height
        width: parent.width

        exerciseIndex: imageView.currentExerciseIndex
        exerciseFunction: imageView.exerciseFunction
        onCorrectlyAnswered: imageView.goForward();
    }
}

