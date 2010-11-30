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

Item {
    property alias backgroundImage: image.source
    property alias currentExerciseIndex: listview.currentIndex
    property string exerciseFunction
    property int answersCount
    property real imageSizeFactor: 0.61
    function goForward() {
        listview.incrementCurrentIndex();
    }
    id: imageview
    Rectangle {
        id: rect
        anchors.fill: parent
        color: Qt.hsla((Math.abs(listview.contentX) % 4000) / 4000, 0.4, 0.8, 1)
    }

    Column {
        Rectangle {
            id: white
            height: Math.round((imageview.height - image.height) * 0.65);
            width: rect.width
            color: "#fff"
        }
        Image {
            property real heightToWidthRatio: 6.0
            property real sourceSizeHeight: Math.round(imageview.height * 0.3)
            property real imageWidth: sourceSizeHeight * heightToWidthRatio
            fillMode: Image.TileHorizontally
            id: image
            sourceSize.height: sourceSizeHeight
            sourceSize.width: sourceSizeHeight * heightToWidthRatio
            width: (Math.ceil(imageview.width / imageWidth) + 1) * imageWidth
            x: ((-listview.contentX - 10 * imageview.width) * 0.3) % imageWidth
            y: 0
        }
        Rectangle {
            height: imageview.height - white.height - image.height
            width: rect.width
            color: "#000"
        }
        opacity: 0.08
    }

    ListView {
        id: listview
        anchors.fill: parent
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.DragOverBounds
        highlightRangeMode: ListView.StrictlyEnforceRange
        maximumFlickVelocity: 200
        model: 100000

        delegate: Item {
            width: listview.width // Must not be parent.height/width since those are 0 in the beginning
            height: listview.height
            Image {
                function sourceSizeWidthHeight() {
                    return Math.min(parent.width, parent.height) * imageSizeFactor;
                }
                source: Database.exercise(modelData, exerciseFunction, answersCount).ImageSource
                anchors.centerIn: parent
                sourceSize.width: sourceSizeWidthHeight()
                sourceSize.height: sourceSizeWidthHeight()
            }
        }
    }

    Image {
        sourceSize.height: parent.height
        sourceSize.width: parent.width
        source: "image://imageprovider/frame/0"
    }
}
