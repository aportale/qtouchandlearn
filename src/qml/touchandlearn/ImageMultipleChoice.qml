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

import QtQuick 2.2
import "database.js" as Database

Item {
    id: main
    property alias backgroundImage: imageView.backgroundImage
    property bool grayBackground
    property alias imageSizeFactor: imageView.imageSizeFactor
    property alias exerciseFunction: imageView.exerciseFunction
    property alias showCorrectionImageOnButton: choice.showCorrectionImage
    property alias answersCount: choice.buttonsCount
    property alias answersColumsCount: choice.columsCount
    property real viewHeightRatio: 0.45
    property string selectedLesson

    readonly property int imageViewHeight: height * viewHeightRatio
    readonly property int backButtonSize: (height < width ? height : width) * 0.2

    function goBack()
    {
        selectedLesson = "Menu";
    }

    ImageView {
        id: imageView
        width: portaitLayout ? parent.width : Math.ceil(parent.width / 2)
        height: portaitLayout ? imageViewHeight : parent.height
        answersCount: choice.buttonsCount
        backgroundImage: "image://imageprovider/background/background_01"
        grayBackground: main.grayBackground
    }

    Item {
        id: backButton
        width: backButtonSize
        height: backButtonSize
        anchors {
            top: parent.top
            right: portaitLayout ? parent.right : undefined
            left: portaitLayout ? undefined : parent.left
        }
        Image {
            readonly property int _sourceSize: backButtonSize * 0.7
            anchors.centerIn: parent
            sourceSize { width: _sourceSize; height: _sourceSize }
            source: "image://imageprovider/specialbutton/backbutton"
            smooth: false
        }
        MouseArea {
            anchors.fill: parent
            onPressed: goBack()
        }
    }

    Item {
        readonly property int _height: backButtonSize * 0.75
        width: backButtonSize
        height: _height
        anchors {
            top: backButton.bottom
            right: portaitLayout ? parent.right : undefined
            left: portaitLayout ? undefined : parent.left
        }
        Image {
            readonly property int _sourceSize: backButtonSize * 0.7
            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
            sourceSize { width: _sourceSize; height: _sourceSize }
            source: "image://imageprovider/specialbutton/optionsbutton"
            smooth: false
        }
        MouseArea {
            anchors.fill: parent
            onPressed: selectedLesson = "Options"
        }
        visible: Database.lessonsOfCurrentGroup().length > 1
    }

    AnswerChoice {
        id: choice

        y: portaitLayout ? imageViewHeight : 0
        x: portaitLayout ? 0 : imageView.width
        height: portaitLayout ? parent.height - imageView.height : parent.height
        width: portaitLayout ? parent.width : parent.width - imageView.width

        exerciseIndex: imageView.currentExerciseIndex
        exerciseFunction: imageView.exerciseFunction
        onCorrectlyAnswered: imageView.goForward();
        grayBackground: main.grayBackground
    }
}
