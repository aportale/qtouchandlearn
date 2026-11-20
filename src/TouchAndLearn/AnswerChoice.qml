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

pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: choice
    property int exerciseIndex
    required property Exercises exercises
    property bool showCorrectionImage: true
    property bool grayBackground
    property int buttonsCount: 3
    property alias columsCount: grid.columns
    signal correctlyAnswered
    final property bool blockClicks: false

    readonly property int buttonSpacing: height * 0.035
    readonly property int gridWidth: width - 2 * buttonSpacing
    readonly property int gridHeight: height
    readonly property int gridRows: Math.max(1, Math.ceil(buttonsCount / columsCount))

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    onExerciseIndexChanged: setButtonData();

    function setButtonData(): void {
        // exerciseIndex is -1 until the ListView of the ImageView sets its current index. The
        // buttons can exist before that, for example on WebAssembly, and would first show the
        // answers of a bogus exercise -1. onExerciseIndexChanged calls this function again.
        if (exerciseIndex < 0)
            return;
        // Inside an asynchronous Loader, the Repeater creates the buttons over several
        // frames. Wait until all of them exist.
        for (let j = 0; j < buttonsCount; j++) {
            if (!repeater.itemAt(j))
                return;
        }
        const correctAnswerIndex = exercises.correctAnswerIndex(exerciseIndex);
        for (let i = 0; i < buttonsCount; i++) {
            const button = repeater.itemAt(i) as AnswerButton;
            button.text = exercises.answerText(exerciseIndex, i);
            if (showCorrectionImage)
                button.correctionImageSource = exercises.answerImageSource(exerciseIndex, i);
            button.isCorrectAnswer = correctAnswerIndex === i;
        }
    }

    Grid {
        id: grid
        columns: 1
        rows: choice.gridRows
        width: choice.gridWidth
        height: choice.gridHeight
        spacing: choice.buttonSpacing
        x: 2 * choice.buttonSpacing
        y: choice.buttonSpacing

        Repeater {
            id: repeater
            model: choice.buttonsCount
            AnswerButton {
                // AnswerButton has required properties, so the Repeater passes the model
                // data only to required properties.
                required property int modelData
                readonly property int _width: ((choice.gridWidth - choice.buttonSpacing) / choice.columsCount) - choice.buttonSpacing
                readonly property int _height: (choice.gridHeight / choice.gridRows) - choice.buttonSpacing
                width: _width
                height: _height
                index: modelData
                grayBackground: choice.grayBackground
                answerChoice: choice
                onCorrectlyPressed: choice.correctlyAnswered();

                // Make the next but one exercise now, when the animation is over.
                onContentChangeAnimationFinished: {
                    if (modelData === choice.buttonsCount - 1)
                        choice.exercises.prepare(choice.exerciseIndex + 2);
                }
            }
            onItemAdded: choice.setButtonData();
        }
    }
}
