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
import TouchAndLearn 1.0

Rectangle {
    width: 360
    height: 640
    anchors.fill: parent
    id: mainWindow
    color: "#000"

    Item {
        anchors.fill: parent
        Connections {
            id: connection
            ignoreUnknownSignals: true
            onSelecedLessonChanged: switchToScreen(Database.currentScreen.selecedLesson)
            onClosePressed: switchToScreen("LessonMenu")
        }
    }

    Rectangle {
        anchors.fill: parent
        id: courtain
        color: "#000"
        opacity:  0
        z: 1
    }

    function createScreen(screen)
    {
        return Qt.createQmlObject("import Qt 4.7; " + screen + " { width: " + mainWindow.width + "; height: " + mainWindow.height + "; anchors.fill: parent; opacity: 0 }", mainWindow);
    }

    function switchToScreen(screen)
    {
        Database.previousScreen = Database.currentScreen;
        Database.currentScreen = createScreen(screen);
        connection.target = Database.currentScreen;
        if (Database.previousScreen == null)
            Database.currentScreen.opacity = 1;
        else
            screenBlender.start();
    }

    SequentialAnimation {
        id: screenBlender
        PropertyAnimation {
            id: fadein
            target: courtain
            property: "opacity"
            to: 1
            duration: 180
        }
        ScriptAction {
            script: {
                if (Database.previousScreen)
                    Database.previousScreen.destroy();
                Database.currentScreen.opacity = 1
            }
        }
        PropertyAnimation {
            target: courtain
            property: "opacity"
            to: 0
            duration: 180
        }
    }

    Timer {
        // Need to create the first with minimal delay for valid initial parent.width/height
        interval: 1
        running: true
        onTriggered: switchToScreen("LessonMenu")
    }
}
