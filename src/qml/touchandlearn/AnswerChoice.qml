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

import Qt 4.7
import "database.js" as Database

Item {
    id: choice
    property int exerciseIndex
    property string exerciseFunction
    property bool showCorrectionImage: true
    property bool grayBackground
    property int buttonsCount: 3
    property alias columsCount: grid.columns
    signal correctlyAnswered
    property bool blockClicks: false

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    onExerciseIndexChanged: {
        if (grid.resources.length > 1)
            setButtonData();
    }

    function setButtonData() {
        var exercise = Database.exercise(exerciseIndex, exerciseFunction, buttonsCount);
        for (var i = 0; i < buttonsCount; i++) {
            var button = grid.resources[i + 1];
            var answer = exercise.Answers[i];
            button.text = answer.DisplayName;
            if (showCorrectionImage)
                button.correctionImageSource = answer.ImageSource;
            button.isCorrectAnswer = exercise.CorrectAnswerIndex == i;
        }
    }

    Grid {
        id: grid
        columns: 1
        rows: Math.ceil(choice.buttonsCount / columns)
        property int buttonSpacing: Math.round(parent.height * 0.035)
        width: Math.round(parent.width - 2 * buttonSpacing)
        height: Math.round(parent.height)
        property int buttonWidth: Math.round((width - buttonSpacing) / choice.columsCount) - buttonSpacing
        property int buttonHeight: Math.round(height / rows) - buttonSpacing
        spacing: buttonSpacing
        x: 2 * buttonSpacing
        y: buttonSpacing

        Repeater {
            id: repeater
            model: buttonsCount
            AnswerButton {
                height: grid.buttonHeight
                width: grid.buttonWidth
                index: modelData
                grayBackground: choice.grayBackground
                onCorrectlyPressed: correctlyAnswered();
            }
            Component.onCompleted: setButtonData();
        }
    }
}
