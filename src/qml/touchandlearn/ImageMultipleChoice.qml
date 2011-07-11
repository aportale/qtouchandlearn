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

Item {
    property alias backgroundImage: imageView.backgroundImage
    property alias imageSizeFactor: imageView.imageSizeFactor
    property alias exerciseFunction: imageView.exerciseFunction
    property alias showCorrectionImageOnButton: choice.showCorrectionImage
    property alias answersCount: choice.buttonsCount
    property alias answersColumsCount: choice.columsCount
    property real viewHeightRatio: 0.45
    property string selectedLesson

    ImageView {
        id: imageView
        anchors { top: parent.top; right: parent.right; left: parent.left }
        height: Math.round(parent.height * viewHeightRatio)
        answersCount: choice.buttonsCount
        backgroundImage: "image://imageprovider/background/background_01"

        // Theoretically unneeded, since the anchors above should do the job.
        // But without width, we get 0-values at construction time
        width: parent.width
    }

    Item {
        id: backButton
        property real backButtonSize: Math.round(Math.min(parent.width, parent.height) * 0.2)
        width: backButtonSize
        height: backButtonSize
        anchors { top: parent.top; right: parent.right }
        Image {
            property real exitImageSize: Math.round(parent.width * 0.7)
            sourceSize { width: exitImageSize; height: exitImageSize }
            anchors.centerIn: parent
            source: "image://imageprovider/specialbutton/backbutton"
        }
        MouseArea {
            anchors.fill: parent
            onPressed: selectedLesson = "Menu"
        }
    }

    Item {
        width: backButton.backButtonSize
        height: backButton.backButtonSize * 0.75
        anchors { top: backButton.bottom; right: parent.right }
        Image {
            property real optionsButtonSize: Math.round(parent.width * 0.7)
            sourceSize { width: optionsButtonSize; height: optionsButtonSize }
            anchors { horizontalCenter: parent.horizontalCenter; top: parent.top }
            source: "image://imageprovider/specialbutton/optionsbutton"
        }
        MouseArea {
            anchors.fill: parent
            onPressed: selectedLesson = "Options"
        }
    }

    AnswerChoice {
        id: choice
        anchors { top: imageView.bottom; bottom: parent.bottom; right: parent.right; left: parent.left }

        // Theoretically unneeded, since the anchors above should do the job.
        // But without width/height, we get 0-values at construction time
        height: parent.height - imageView.height
        width: parent.width

        exerciseIndex: imageView.currentExerciseIndex
        exerciseFunction: imageView.exerciseFunction
        onCorrectlyAnswered: imageView.goForward();
    }
}
