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
    width: parent.width
    height: parent.height
    color: "#000"
    property color normalStateColor: "#fff"
    property color pressedStateColor: "#ee8"
    property string selecedLesson

    ListModel {
        id: lessonModel
        ListElement {
            name: QT_TR_NOOP("Read the first letter")
            imageLabel: "robot"
            imageLabelFunction: 2
            component: "LessonFirstLetter"
            button: "read_initial_letters"
        }
        ListElement {
            name: QT_TR_NOOP("Read words")
            imageLabel: "robot"
            imageLabelFunction: 1
            component: "LessonNameTerms"
            button: "read_words"
        }
        ListElement {
            name: QT_TR_NOOP("Count to 5")
            imageLabel: 3
            imageLabelFunction: 0
            component: "LessonCountEasy"
            button: "count_easy"
        }
        ListElement {
            name: QT_TR_NOOP("Count and read to 5")
            imageLabel: "three"
            imageLabelFunction: 3
            component: "LessonCountReadEasy"
            button: "count_and_read_easy"
        }
        ListElement {
            name: QT_TR_NOOP("Count to 20")
            imageLabel: 9
            imageLabelFunction: 0
            component: "LessonCountHard"
            button: "count_hard"
        }
        ListElement {
            name: QT_TR_NOOP("Count and read to 20")
            imageLabel: "nine"
            imageLabelFunction: 3
            component: "LessonCountReadHard"
            button: "count_and_read_hard"
        }
    }

    Component {
        id: delegate
        Item {
            height: Math.round(menu.width * 0.4)
            width: menu.width

            Rectangle {
                id: rectangle
                anchors.fill: parent
            }

            Image {
                source: "image://imageprovider/specialbutton/" + button
                sourceSize.width: parent.width
                sourceSize.height: parent.height
            }

            Text {
                text: (imageLabelFunction == 1) ? qsTranslate("Objects", imageLabel)
                    : (imageLabelFunction == 2) ? qsTranslate("Objects", imageLabel)[0]
                    : (imageLabelFunction == 3) ? qsTranslate("Numbers", imageLabel)
                    : imageLabel;
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: parent.height * 0.2
                width: Math.round(parent.width * 0.27)
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.margins: Math.round(parent.width * 0.055)
            }

            Text {
                text: name
                wrapMode: "WordWrap"
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: parent.height * 0.2
                width: Math.round(parent.width * 0.51)
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: Math.round(parent.width * 0.1)
            }

            MouseArea {
                onPressed: rectangle.color = pressedStateColor;
                onCanceled: rectangle.color = normalStateColor;
                onClicked: {
                    rectangle.color = pressedStateColor;
                    selecedLesson = component;
                }
                anchors.fill: parent
            }
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: list.height
        width: parent.width

        Column {
            id: list
            anchors.left: parent.left
            anchors.right: parent.right
            Repeater {
                model: lessonModel
                delegate: delegate
            }
        }
    }
}
