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

Item {
    property alias currentExerciseIndex: listview.currentIndex
    property bool grayBackground
    property string exerciseFunction
    property int answersCount
    property real imageSizeFactor: 0.61

    property int imageSourceSizeWidthHeight: (height < width ? height : width) * imageSizeFactor

    function goForward() {
             listview.incrementCurrentIndex();
    }
    id: imageview

    ListView {
        id: listview
        anchors.fill: parent
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.DragOverBounds
        highlightRangeMode: ListView.StrictlyEnforceRange
        maximumFlickVelocity: width / 2
        highlightMoveDuration: 1000
        model: 100

        delegate: Item {
            id: delegate
            width: listview.width // Must not be parent.height/width since those are 0 in the beginning
            height: listview.height
            Text {
                text: modelData
            }
        }
    }
}
