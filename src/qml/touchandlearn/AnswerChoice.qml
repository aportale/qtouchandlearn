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
    id: choice
    property int exerciseIndex
    property string exerciseFunction
    property bool showCorrectionImage: true
    property bool grayBackground
    property int buttonsCount: 3
    property alias columsCount: grid.columns
    signal correctlyAnswered
    property bool blockClicks: false

    property int buttonSpacing: height * 0.035
    property int gridWidth: width - 2 * buttonSpacing
    property int gridHeight: height
    property int gridRows: buttonsCount / columsCount

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    onExerciseIndexChanged: {
        if (repeater.count > 1)
            setButtonData();
    }

    function setButtonData() {
        var exercise = Database.exercise(exerciseIndex, exerciseFunction, buttonsCount);
        for (var i = 0; i < buttonsCount; i++) {
            var button = repeater.itemAt(i);
            var answer = exercise.Answers[i];
            button.text = answer.DisplayName;
            if (showCorrectionImage)
                button.correctionImageSource = answer.ImageSource;
            button.isCorrectAnswer = exercise.CorrectAnswerIndex === i;
        }
    }

    Grid {
        id: grid
        columns: 1
        rows: gridRows
        width: gridWidth
        height: gridHeight
        spacing: buttonSpacing
        x: 2 * buttonSpacing
        y: buttonSpacing

        Repeater {
            id: repeater
            model: buttonsCount
            AnswerButton {
                property int _width: ((gridWidth - buttonSpacing) / columsCount) - buttonSpacing
                property int _height: (gridHeight / gridRows) - buttonSpacing
                width: _width
                height: _height
                index: modelData
                grayBackground: choice.grayBackground
                onCorrectlyPressed: correctlyAnswered();

                // Calculate next but one exercise now, where the animation is over.
                onContentChangeAnimationFinished: modelData === buttonsCount - 1 ?
                                                      Database.exercise(exerciseIndex + 2, exerciseFunction, buttonsCount) : true;
            }
            Component.onCompleted: setButtonData();
        }
    }
}
