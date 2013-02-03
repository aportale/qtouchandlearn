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

import QtQuick 2.0
import "database.js" as Database

Rectangle {
    id: menu
    color: "#000"
    property color normalStateColor: "#fff"
    property color pressedStateColor: "#ee8"
    property string selectedLesson
    width: screenWidth
    height: screenHeight

    property int delegateWidth: width >> 1
    property int delegateHeight: delegateWidth * 1.15
    property int exitButtonSize: width * 0.2
    property int controlsHeight: exitButtonSize * 0.75

    Component {
        id: delegate
        Item {
            width: menu.delegateWidth
            height: menu.delegateHeight

            Rectangle {
                id: rectangle
                anchors.fill: parent
            }

            Image {
                source: "image://imageprovider/lessonicon/" + Database.cachedLessonMenu[index].Id + "/" + index
                sourceSize { width: parent.width; height: parent.height }
                smooth: true
            }

            Text {
                property int _y: delegateHeight * 0.83
                text: Database.cachedLessonMenu[index].ImageLabel
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: delegateHeight * 0.085
                width: parent.width
                y: _y
            }

            Text {
                property int _y: delegateHeight * 0.14
                text: Database.cachedLessonMenu[index].DisplayName
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: delegateHeight * 0.1
                width: parent.width
                y: _y
            }

            MouseArea {
                onPressed: rectangle.color = pressedStateColor;
                onCanceled: rectangle.color = normalStateColor;
                onClicked: {
                    rectangle.color = pressedStateColor;
                    Database.currentLessonGroup = Database.cachedLessonMenu[index];
                    selectedLesson = Database.currentLessonOfCurrentGroup();
                }
                anchors.fill: parent
            }
        }
    }

    function enableMenuItems(enable) {
        controls.enabled = enable
        for (var i = 0; i < menuItems.count; i++)
            menuItems.itemAt(i).enabled = enable
    }

    Flickable {
        property int _contentY: controlsHeight * 0.75
        contentY: _contentY // Only show a part of it. As a hint.
        anchors.fill: parent
        contentHeight: column.height
        width: parent.width

        onMovementStarted: enableMenuItems(false)
        onFlickStarted: enableMenuItems(false)
        onFlickEnded: enableMenuItems(true)
        onMovementEnded: enableMenuItems(true)

        Column {
            id: column
            anchors { left: parent.left; right: parent.right }

            Item {
                id: controls
                anchors { left: parent.left; right: parent.right }
                height: controlsHeight
                Item {
                    id: exitButton
                    width: exitButtonSize
                    height: controlsHeight
                    anchors { top: parent.top; right: parent.right }
                    Image {
                        property int _sourceSize: exitButtonSize * 0.7
                        sourceSize { width: _sourceSize; height: _sourceSize }
                        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                        source: "image://imageprovider/specialbutton/exitbutton"
                        smooth: true
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
                    width: (Math.ceil(menu.width / 360) + 1) * 360
                    fillMode: Image.Tile
                    NumberAnimation on x {
                        from: 0
                        to: -360
                        duration: 2500
                        loops: Animation.Infinite
                    }
                    smooth: false
                }
                Image {
                    id: titleImage
                    source: "image://imageprovider/title/textmask"
                    sourceSize { width: menu.width; height: menu.height }
                    smooth: true
                }
                height: titleImage.height
                anchors { left: parent.left; right: parent.right }
            }

            Grid {
                columns: 2
                id: list
                anchors { left: parent.left; right: parent.right }
                Repeater {
                    id: menuItems
                    model: Database.lessonMenu().length
                    delegate: delegate
                }
            }
        }
    }
}
