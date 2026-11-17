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

    readonly property bool portaitLayout: width < (height * 1.5)
    readonly property int imageViewHeight: height * viewHeightRatio
    readonly property int backButtonSize: (height < width ? height : width) * 0.2

    function goBack()
    {
        selectedLesson = "Menu";
    }

    ImageView {
        id: imageView
        width: main.portaitLayout ? parent.width : Math.ceil(parent.width / 2)
        height: main.portaitLayout ? main.imageViewHeight : parent.height
        answersCount: choice.buttonsCount
        backgroundImage: "image://imageprovider/background/background_01"
        grayBackground: main.grayBackground
    }

    Item {
        id: backButton
        width: main.backButtonSize
        height: main.backButtonSize
        anchors {
            top: parent.top
            right: main.portaitLayout ? parent.right : undefined
            left: main.portaitLayout ? undefined : parent.left
        }
        Image {
            readonly property int _sourceSize: main.backButtonSize * 0.7
            anchors.centerIn: parent
            sourceSize { width: _sourceSize; height: _sourceSize }
            source: "image://imageprovider/specialbutton/backbutton"
            smooth: false
        }
        MouseArea {
            anchors.fill: parent
            onPressed: main.goBack()
        }
    }

    Item {
        readonly property int _height: main.backButtonSize * 0.75
        width: main.backButtonSize
        height: _height
        anchors {
            top: backButton.bottom
            right: main.portaitLayout ? parent.right : undefined
            left: main.portaitLayout ? undefined : parent.left
        }
        Image {
            readonly property int _sourceSize: main.backButtonSize * 0.7
            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
            sourceSize { width: _sourceSize; height: _sourceSize }
            source: "image://imageprovider/specialbutton/optionsbutton"
            smooth: false
        }
        MouseArea {
            anchors.fill: parent
            onPressed: main.selectedLesson = "Options"
        }
        visible: Database.lessonsOfCurrentGroup().length > 1
    }

    AnswerChoice {
        id: choice

        y: main.portaitLayout ? main.imageViewHeight : 0
        x: main.portaitLayout ? 0 : imageView.width
        height: main.portaitLayout ? parent.height - imageView.height : parent.height
        width: main.portaitLayout ? parent.width : parent.width - imageView.width

        exerciseIndex: imageView.currentExerciseIndex
        exerciseFunction: imageView.exerciseFunction
        onCorrectlyAnswered: imageView.goForward();
        grayBackground: main.grayBackground
    }
}
