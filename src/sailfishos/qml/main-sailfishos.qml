/*
    Touch'n'learn - Fun and easy mobile lessons for kids
    Copyright (C) 2010 - 2013 by Alessandro Portale
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
import Sailfish.Silica 1.0
import QtMultimedia 5.0

import "touchandlearn"
import "touchandlearn/database.js" as Database

ApplicationWindow
{
    id: window

    MainMenu {
        id: mainMenu
        property int screenWidth: window.width
        property int screenHeight: window.height
        width: screenWidth
        height: screenHeight
        titleAnimationEnabled: false
    }

    Feedback {
        id: feedback
        audioFileExtension: ".wav"
        audioDirectory: Qt.resolvedUrl("../data/audio/")
    }

    cover: CoverBackground {
        anchors.fill: parent
        Image {
            source: "cover.png"
        }
    }

    Component.onDestruction: {
        Database.persistence.writeAll();
    }
}
