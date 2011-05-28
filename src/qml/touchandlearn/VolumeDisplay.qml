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
    property int volume: 75
    id: volumeDisplay
    width: 300
    height: 300
    color: Qt.rgba(0, 0, 0, 0.7)

    Component {
        id: delegate
        Image {
            source: "image://imageprovider/specialbutton/volumebar_" + (index + 1) * 20
            sourceSize {
                width: Math.round(volumeDisplay.width / 5 * 0.7)
                height: volumeDisplay.width * 0.7
            }
            opacity: volume >= (index + 1) * 20 ? 1 : 0.25;
        }
    }

    Row {
        anchors.centerIn: parent
        height: volumeDisplay.width
        Repeater { model: 5; delegate: delegate }
    }

    MouseArea {
        anchors.fill: parent
    }

    SequentialAnimation {
        id: fadeout
        PauseAnimation {
            duration: 850
        }
        PropertyAnimation {
            property: "opacity"
            target: volumeDisplay
            to: 0
        }
        ScriptAction {
            script: {
                Database.volumeDisplay = null;
                volumeDisplay.destroy();
            }
        }
    }

    Component.onCompleted: {
        fadeout.start();
    }

    function displayVolume()
    {
        fadeout.stop();
        opacity = 1;
        fadeout.start();
    }
}
