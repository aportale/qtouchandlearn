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
    property int choicesCount: 50
    signal closePressed
    id: nameTerms
    ImageMultipleChoice {
        width: parent.width
        height: parent.height
        backgroundImage: "image://imageprovider/background/background_01"
        exercisesModel: ListModel {
            id: listModel
            Component.onCompleted: createReadingListModel()
        }
        onClosePressed: nameTerms.closePressed()
    }

    function createReadingListModel()
    {
        var objects = Database.objects();
        var answersPerChoiceCount = 3;
        var listModelItems = Array(choicesCount);
        for (var i = 0; i < choicesCount; i++) {
            var correctAnswerIndex = Math.floor(Math.random() * answersPerChoiceCount);
            var currentObjectIndex;
            do {
                currentObjectIndex = Math.floor(Math.random() * objects.length);
            } while (Database.previousExerciseHasSameAnswerOnIndex(currentObjectIndex, correctAnswerIndex, listModelItems, i)
                     || Database.previousExercisesHaveSameCorrectAnswer(currentObjectIndex, Math.round(objects.length * 0.5), listModelItems, i));
            var object = objects[currentObjectIndex];
            var answers = Array(answersPerChoiceCount);
            answers[correctAnswerIndex] = object;
            for (var j = 0; j < answersPerChoiceCount; j++) {
                if (j != correctAnswerIndex) {
                    var wrongAnswerObjectIndex;
                    do {
                        wrongAnswerObjectIndex = Math.floor(Math.random() * objects.length);
                    } while (wrongAnswerObjectIndex == currentObjectIndex
                             || Database.previousExerciseHasSameAnswerOnIndex(wrongAnswerObjectIndex, j, listModelItems, i)
                             || Database.currentAnswersContainObjectIndex(wrongAnswerObjectIndex, j, answers))
                    answers[j] = objects[wrongAnswerObjectIndex];
                }
            }
            for (var a = 0; a < answers.length; a++)
                answers[a].ImageSource = "image://imageprovider/object/" + answers[a].Id;
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
