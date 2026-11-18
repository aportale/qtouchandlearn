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

pragma ComponentBehavior: Bound

import QtQuick 2.2
import "database.js" as Database

StageScreen {
    id: menu
    readonly property color normalStateColor: "#fff"
    readonly property color pressedStateColor: "#ee8"
    property string currentLesson: Database.currentLessonOfCurrentGroup()
    readonly property int backButtonSize: (height < width ? height : width) * 0.2
    readonly property bool portaitLayout: width < (height * 1.5)
    backLesson: currentLesson

    Rectangle {
        anchors.fill: parent
        color: "#000"
    }

    Component {
        id: lessonDelegate
        Item {
            id: lessonItem
            required property int index
            readonly property int _height: width * 0.4
            height: _height
            width: menu.width / grid.columns

            Rectangle {
                id: rectangle
                anchors.fill: parent
                color: mouseArea.pressed ? menu.pressedStateColor : menu.normalStateColor
            }

            Image {
                readonly property int _anchors_margins: parent.height * 0.15
                source: "image://imageprovider/specialbutton/activemarker"
                sourceSize { height: parent.height * 0.15; width: parent.height * 0.15 }
                opacity: Database.lessonsOfCurrentGroup()[lessonItem.index].Id === menu.currentLesson ? 1 : 0;
                anchors { right: parent.right; top: parent.top; margins: _anchors_margins; }
            }

            Image {
                source: "image://imageprovider/lessonicon/" + Database.lessonsOfCurrentGroup()[lessonItem.index].Id + "/" + lessonItem.index
                sourceSize { width: parent.width; height: parent.height }
            }

            Text {
                readonly property int _width: parent.width * 0.28
                readonly property int _x: parent.height * 0.21
                readonly property int _y: parent.height * 0.65
                text: Database.lessonsOfCurrentGroup()[lessonItem.index].ImageLabel
                horizontalAlignment: Text.AlignHCenter
                fontSizeMode: Text.HorizontalFit
                minimumPixelSize: 8
                font.pixelSize: parent.height * 0.14
                width: _width
                x: _x
                y: _y
            }

            Text {
                readonly property int _width: parent.width * 0.51
                readonly property int _anchors_margins: parent.width * 0.1
                text: Database.lessonsOfCurrentGroup()[lessonItem.index].DisplayName
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                fontSizeMode: Text.Fit
                minimumPixelSize: 8
                font.pixelSize: parent.height * 0.175
                width: _width
                height: parent.height * 0.8
                anchors { right: parent.right; verticalCenter: parent.verticalCenter; margins: _anchors_margins }
            }

            MouseArea {
                id: mouseArea
                onClicked: {
                    rectangle.color = menu.pressedStateColor;
                    var theLesson = Database.lessonsOfCurrentGroup()[lessonItem.index].Id;
                    Database.setCurrentLessonOfGroup(Database.currentLessonGroup.Id, theLesson);
                    menu.selectedLesson = theLesson;
                }
                anchors.fill: parent
            }
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: backButton.height + grid.height
        width: parent.width

        Item {
            id: backButton
            readonly property int _height: menu.backButtonSize * 0.75
            width: menu.backButtonSize
            height: _height
            anchors {
                top: parent.top
                right: menu.portaitLayout ? parent.right : undefined
                left: menu.portaitLayout ? undefined : parent.left
            }
            Image {
                readonly property int _sourceSize: parent.width * 0.7
                anchors { centerIn: parent }
                sourceSize { width: _sourceSize; height: _sourceSize; }
                source: "image://imageprovider/specialbutton/backbutton"
            }
            MouseArea {
                anchors.fill: parent
                onClicked: menu.selectedLesson = menu.backLesson
            }
        }

        Grid {
            id: grid
            columns: menu.portaitLayout ? 1 : 2
            anchors { top: backButton.bottom; left: parent.left; right: parent.right }
            Repeater {
                id: lessons
                model: Database.lessonsOfCurrentGroup().length
                delegate: lessonDelegate
            }
        }
    }
}
