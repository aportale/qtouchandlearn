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

Item {
    id: choice
    property int exerciseIndex
    property string exerciseFunction
    property bool showCorrectionImage: true
    property bool grayBackground
    property int buttonsCount: 1
    signal correctlyAnswered
    property bool blockClicks: false

    onExerciseIndexChanged: {
        if (exerciseIndex >= 0)
            setButtonData();
    }

    function setButtonData() {
        for (var i = 0; i < buttonsCount; i++) {
            var button = repeater.itemAt(i);
            button.text = Date();
        }
    }

    Column {
        id: grid
        Repeater {
            id: repeater
            model: buttonsCount
            Item {
                property int index: modelData
                property string text

                Text {
                    id: label
                    anchors.centerIn: parent
                }

                onTextChanged: {
                    contentChangeAnimation.complete();
                    contentChangeAnimation.start();
                }

                SequentialAnimation {
                    id: contentChangeAnimation
                    ScaleAnimator {
                        target: label
                        from: 1
                        to: 0
                    }
                    ScriptAction { // PropertyAction would fail here, and set the prior text
                        script: label.text = text
                    }
                    ScaleAnimator {
                        target: label
                        from: 0
                        to: 1
                    }
                }
            }
            Component.onCompleted: setButtonData();
        }
    }
}
