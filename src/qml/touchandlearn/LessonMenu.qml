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

    Component {
        id: delegate
        Item {
            width: menu.width/2
            height: Math.round(width * 1.5)

            Rectangle {
                id: rectangle
                anchors.fill: parent
            }

            Image {
                source: "image://imageprovider/lessonicon/" + Database.cachedLessonMenu[index].Id + "/" + index
                sourceSize { width: parent.width; height: parent.height }
            }

            Text {
                text: Database.cachedLessonMenu[index].ImageLabel
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: parent.height * 0.07
                width: parent.width
                y: parent.height * 0.7
            }

            Text {
                text: Database.cachedLessonMenu[index].DisplayName
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: parent.height * 0.115
                width: parent.width
                y: parent.height * 0.19
            }

            MouseArea {
                onPressed: rectangle.color = pressedStateColor;
                onCanceled: rectangle.color = normalStateColor;
                onClicked: {
                    rectangle.color = pressedStateColor;
                    Database.currentLessonGroup = Database.cachedLessonMenu[index];
                    var currentLesson = Database.currentLessonOfCurrentGroup();
                    var lessons = Database.currentLessonGroup.Lessons;
                    for (var i = 0; i < lessons.length; i++) {
                        if (lessons[i].Id == currentLesson) {
                            selectedLesson = currentLesson;
                            break;
                        }
                    }
                    if (selectedLesson == "")
                        selectedLesson = lessons[Database.currentLessonGroup.DefaultLesson].Id;
                }
                anchors.fill: parent
            }
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: column.height
        contentY: controls.height * 0.75 // Only show a part of it. As a hint.
        width: parent.width

        Column {
            id: column
            anchors { left: parent.left; right: parent.right }

            Item {
                id: controls
                anchors { left: parent.left; right: parent.right }
                height: exitButton.height
                Item {
                    id: exitButton
                    property int exitButtonSize: Math.round(Math.min(menu.width, menu.height) * 0.18)
                    width: exitButtonSize
                    height: Math.round(exitButtonSize * 0.75)
                    anchors { top: parent.top; right: parent.right }
                    Image {
                        property real exitImageSize: Math.round(parent.width * 0.5)
                        sourceSize { width: exitImageSize; height: exitImageSize }
                        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                        source: "image://imageprovider/specialbutton/exitbutton"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: Qt.quit()
                    }
                }
            }

            Item {
                Image {
                    source: "image://imageprovider/title/spectrum"
                    sourceSize { width: titleImage.width; height: titleImage.height }
                    width: (Math.ceil(titleImage.width / 360.0) + 1) * 360
                    fillMode: Image.Tile
                    NumberAnimation on x {
                        from: 0
                        to: -360
                        duration: 2500
                        loops: Animation.Infinite
                    }
                }
                Image {
                    id: titleImage
                    source: "image://imageprovider/title/textmask"
                    sourceSize { width: menu.width; height: menu.height }
                }
                height: titleImage.height
                anchors { left: parent.left; right: parent.right }
            }

            Grid {
                columns: 2
                id: list
                anchors { left: parent.left; right: parent.right }
                Repeater {
                    model: Database.lessonMenu().length
                    delegate: delegate
                }
            }
        }
    }
}
