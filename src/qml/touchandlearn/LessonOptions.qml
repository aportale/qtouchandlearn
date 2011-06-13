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
import "database.js" as Database

Rectangle {
    id: menu
    color: "#000"
    property color normalStateColor: "#fff"
    property color pressedStateColor: "#ee8"
    property string selectedLesson
    property string currentLesson: Database.currentLessonOfCurrentGroup()

    Component {
        id: delegate
        Item {
            height: Math.round(menu.width * 0.4)
            width: menu.width

            Rectangle {
                id: rectangle
                anchors.fill: parent
                color: mouseArea.pressed ? pressedStateColor : normalStateColor
            }

            Image {
                source: "image://imageprovider/specialbutton/activemarker"
                sourceSize { height: parent.height * 0.15; width: parent.height * 0.15; }
                opacity: Database.lessonsOfCurrentGroup()[index].Id == currentLesson ? 1 : 0;
                anchors { right: parent.right; top:  parent.top; margins: parent.height * 0.15; }
            }

            Image {
                source: "image://imageprovider/lessonicon/" + Database.lessonsOfCurrentGroup()[index].Id + "/" + index
                sourceSize { width: parent.width; height: parent.height }
            }

            Text {
                text: Database.lessonsOfCurrentGroup()[index].ImageLabel
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: parent.height * 0.14
                width: Math.round(parent.width * 0.3)
                anchors { left: parent.left; bottom: parent.bottom; margins: Math.round(parent.height * 0.18) }
            }

            Text {
                text: Database.lessonsOfCurrentGroup()[index].DisplayName
                wrapMode: "WordWrap"
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: parent.height * 0.175
                width: Math.round(parent.width * 0.51)
                anchors { right: parent.right; verticalCenter: parent.verticalCenter; margins: Math.round(parent.width * 0.1) }
            }

            MouseArea {
                id: mouseArea
                onClicked: {
                    rectangle.color = pressedStateColor;
                    var theLesson = Database.lessonsOfCurrentGroup()[index].Id;
                    Database.setCurrentLessonOfGroup(Database.currentLessonGroup.Id, theLesson);
                    selectedLesson = theLesson;
                }
                anchors.fill: parent
            }
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: column.height
        width: parent.width

        Column {
            id: column
            anchors { left: parent.left; right: parent.right }

            Item {
                id: controls
                anchors { left: parent.left; right: parent.right }
                height: backButton.height
                Item {
                    id: backButton
                    property int backButtonSize: Math.round(Math.min(menu.width, menu.height) * 0.18)
                    width: backButtonSize
                    height: Math.round(backButtonSize * 0.75)
                    anchors { top: parent.top; right: parent.right }
                    Image {
                        property real exitImageSize: Math.round(parent.width * 0.5)
                        sourceSize { width: exitImageSize; height: exitImageSize }
                        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                        source: "image://imageprovider/specialbutton/backbutton"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: selectedLesson = currentLesson
                    }
                }
            }

            Column {
                id: list
                anchors { left: parent.left; right: parent.right }
                Repeater {
                    model: Database.lessonsOfCurrentGroup().length
                    delegate: delegate
                }
            }
        }
    }
}
