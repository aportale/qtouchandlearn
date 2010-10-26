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
    signal closePressed
    property int rangeFrom: 1
    property int rangeTo: 20
    property int choicesCount: 50
    property bool numbersAsWords: false
    property alias answersPerChoiceCount: choice.answersCount
    property alias viewHeightRatio: choice.viewHeightRatio
    property alias showCorrectionImageOnButton: choice.showCorrectionImageOnButton
    property alias answersColumsCount: choice.answersColumsCount

    id: nameQuantities
    ImageMultipleChoice {
        id: choice
        width: parent.width
        height: parent.height
        backgroundImage: "image://imageprovider/background/background_01"
        exercisesModel: ListModel {
            id: listModel
            Component.onCompleted: createQuantitiesModel()
        }
        imageSizeFactor: 0.95
        onClosePressed: nameQuantities.closePressed()
        answersCount: answersPerChoiceCount
        showCorrectionImageOnButton: false
    }

    function createQuantitiesModel()
    {
        var objects = Database.numbers();
        var rangeLength = rangeTo - rangeFrom + 1;
        var itemTypes = ["fish", "apple"];
        var listModelItems = Array(choicesCount);
        for (var i = 0; i < choicesCount; i++) {
            var correctAnswerIndex = Math.floor(Math.random() * answersPerChoiceCount);
            var currentQuantityIndex;
            do {
                currentQuantityIndex = rangeFrom + Math.floor(Math.random() * rangeLength);
            } while (Database.previousExerciseHasSameAnswerOnIndex(currentQuantityIndex, correctAnswerIndex, listModelItems, i)
                     || Database.previousExercisesHaveSameCorrectAnswer(currentQuantityIndex, Math.round(rangeLength * 0.5), listModelItems, i));
            var object = objects[currentQuantityIndex];
            var answers = Array(answersPerChoiceCount);
            answers[correctAnswerIndex] = object;
            for (var j = 0; j < answersPerChoiceCount; j++) {
                if (j != correctAnswerIndex) {
                    var wrongAnswerQuantityIndex;
                    do {
                        wrongAnswerQuantityIndex = rangeFrom + Math.floor(Math.random() * (rangeLength - 1)) + 1; // -1/+1: avoid 0
                    } while (wrongAnswerQuantityIndex == currentQuantityIndex
                             || Database.previousExerciseHasSameAnswerOnIndex(wrongAnswerQuantityIndex, j, listModelItems, i)
                             || Database.currentAnswersContainObjectIndex(wrongAnswerQuantityIndex, j, answers))
                    answers[j] = objects[wrongAnswerQuantityIndex];
                }
            }
            for (var a = 0; a < answers.length; a++) {
                var itemType = itemTypes[i % itemTypes.length];
                answers[a].ImageSource = "image://imageprovider/quantity/" + answers[a].Id + "/" + itemType;
                if (!numbersAsWords)
                    answers[a].DisplayName = String(answers[a].Index)
            }
            var listItem = {
                Index: object.Index,
                ImageSource: answers[correctAnswerIndex].ImageSource,
                Answers: answers,
                CorrectAnswerIndex: correctAnswerIndex};
            listModelItems[i] = listItem;
            listModel.append(listItem);
        }
//        Database.dumpLesson(listModel)
    }
}
