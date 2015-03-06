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

Rectangle {
    id: menu
    color: "#000"
    property color normalStateColor: "#fff"
    property color pressedStateColor: "#ee8"
    property string selectedLesson

    property int gridMargin: portaitLayout ? 0 : width * 0.075
    property int columsCount: portaitLayout ? 2 : 3
    property int delegateWidth: (width - 2 * gridMargin) / columsCount
    property int delegateHeight: delegateWidth * 1.04
    property bool quitsOnBack: true

    function goBack()
    {
        Qt.quit();
    }

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
            }

            Text {
                property int _y: delegateHeight * 0.83
                text: Database.cachedLessonMenu[index].ImageLabel
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: delegateHeight * 0.085
                font.family: textFontFamily
                width: parent.width
                y: _y
            }

            Text {
                property int _y: delegateHeight * 0.11
                text: Database.cachedLessonMenu[index].DisplayName
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: delegateHeight * 0.1
                font.family: textFontFamily
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

    Flickable {
        anchors.fill: parent
        contentHeight: title.height + list.height
        width: parent.width

        Item {
            id: title
            Image {
                source: "image://imageprovider/title/spectrum"
                sourceSize { width: titleImage.width; height: titleImage.height}
                width: (Math.ceil(menu.width / 360) + 1) * 360
                fillMode: Image.Tile
                NumberAnimation on x {
                    from: 0
                    to: -360
                    duration: 2500
                    loops: Animation.Infinite
                    running: titleAnimationEnabled
                }
                smooth: false
            }
            Image {
                id: titleImage
                source: "image://imageprovider/title/textmask"
                sourceSize {
                    width: portaitLayout ? menu.width : menu.height * 0.65
                    height: menu.height
                }
            }
            Rectangle {
                color: "#000"
                anchors {
                    top: parent.top
                    right: parent.right
                    left: titleImage.right
                    bottom: titleImage.bottom
                }
                visible: !portaitLayout
            }

            height: titleImage.height
            anchors { left: parent.left; right: parent.right }
        }

        Grid {
            id: list
            columns: columsCount
            anchors {
                top: title.bottom
                left: parent.left
                right: parent.right
                leftMargin: gridMargin
                rightMargin: gridMargin
            }
            Repeater {
                id: menuItems
                model: Database.lessonMenu().length
                delegate: delegate
            }
        }
    }
}
