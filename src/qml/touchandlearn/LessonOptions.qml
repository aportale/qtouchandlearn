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
            property int _height: menu.width * 0.4
            height: _height
            width: menu.width

            Rectangle {
                id: rectangle
                anchors.fill: parent
                color: mouseArea.pressed ? pressedStateColor : normalStateColor
            }

            Image {
                property int _anchors_margins: parent.height * 0.15
                source: "image://imageprovider/specialbutton/activemarker"
                sourceSize { height: parent.height * 0.15; width: parent.height * 0.15; }
                opacity: Database.lessonsOfCurrentGroup()[index].Id === currentLesson ? 1 : 0;
                anchors { right: parent.right; top:  parent.top; margins: _anchors_margins; }
                smooth: true
            }

            Image {
                source: "image://imageprovider/lessonicon/" + Database.lessonsOfCurrentGroup()[index].Id + "/" + index
                sourceSize { width: parent.width; height: parent.height }
                smooth: true
            }

            Text {
                property int _width: parent.width * 0.28
                property int _x: parent.height * 0.21
                property int _y: parent.height * 0.65
                text: Database.lessonsOfCurrentGroup()[index].ImageLabel
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: parent.height * 0.14
                width: _width
                x: _x
                y: _y
            }

            Text {
                property int _width: parent.width * 0.51
                property int _anchors_margins: parent.width * 0.1
                text: Database.lessonsOfCurrentGroup()[index].DisplayName
                wrapMode: "WordWrap"
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: parent.height * 0.175
                width: _width
                anchors { right: parent.right; verticalCenter: parent.verticalCenter; margins: _anchors_margins }
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
                    property int _width: menu.width * 0.2
                    property int _height: _width * 0.75
                    width: _width
                    height: _height
                    anchors { top: parent.top; right: parent.right }
                    Image {
                        // Hand-centered in order to avoid non-integer image coordinates.
                        property int _sourceSize: parent.width * 0.7
                        property int _leftMargin: (parent._width - width) / 2
                        property int _topMargin: (parent._height - height) / 2
                        anchors { left: parent.left; top: parent.top; leftMargin: _leftMargin; topMargin: _topMargin; }
                        sourceSize { width: _sourceSize; height: _sourceSize; }
                        source: "image://imageprovider/specialbutton/backbutton"
                        smooth: true
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
