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
    property alias currentExerciseIndex: listview.currentIndex

    function goForward() {
        listview.incrementCurrentIndex();
    }
    id: imageview

    ListView {
        id: listview
        anchors.fill: parent
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.DragOverBounds
        model: 100000

        delegate: Item {
            id: delegate
            width: listview.width // Must not be parent.height/width since those are 0 in the beginning
            height: listview.height
            Text {
                // Hand-centered in order to avoid non-integer image coordinates.
                property int _leftMargin: (delegate.width - width) / 2
                property int _topMargin:(delegate.height - height) / 2
                text: modelData
            }
        }
    }

    Timer {
        onTriggered: listview.incrementCurrentIndex()
        interval: 500
        running: true
    }

    Timer {
        onTriggered: {
            stage.source = (stage.source + "").indexOf("LessonClockEasy.qml") >= 0 ? "LessonClockMedium.qml" : "LessonClockEasy.qml";
        }
        interval: 800
        running: true
    }
}
