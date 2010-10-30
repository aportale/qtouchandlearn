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

var previousScreen = null;
var currentScreen = null;

function addIndicesToDict(dict)
{
    for (var i = 0; i < dict.length; i++)
        dict[i].Index = i;
    return dict;
}

var cachedObjects = null;
function objects()
{
    if (cachedObjects == null) {
        cachedObjects = addIndicesToDict([
            { Id: "banana",         DisplayName: qsTranslate("Objects", "banana")},
            { Id: "elephant",       DisplayName: qsTranslate("Objects", "elephant") },
            { Id: "robot",          DisplayName: qsTranslate("Objects", "robot") },
            { Id: "flower",         DisplayName: qsTranslate("Objects", "flower") },
            { Id: "fish",           DisplayName: qsTranslate("Objects", "fish") },
            { Id: "rooster",        DisplayName: qsTranslate("Objects", "rooster") },
            { Id: "airplane",       DisplayName: qsTranslate("Objects", "airplane") },
            { Id: "candle",         DisplayName: qsTranslate("Objects", "candle") },
            { Id: "scissors",       DisplayName: qsTranslate("Objects", "scissors") },
            { Id: "key",            DisplayName: qsTranslate("Objects", "key") }
        ]);
    }
    return cachedObjects
}

var cachedNumbers = null;
function numbers()
{
    if (cachedNumbers == null) {
        cachedNumbers = addIndicesToDict([
            { Id:  0,   DisplayName: qsTranslate("Numbers", "zero")},
            { Id:  1,   DisplayName: qsTranslate("Numbers", "one") },
            { Id:  2,   DisplayName: qsTranslate("Numbers", "two") },
            { Id:  3,   DisplayName: qsTranslate("Numbers", "three") },
            { Id:  4,   DisplayName: qsTranslate("Numbers", "four") },
            { Id:  5,   DisplayName: qsTranslate("Numbers", "five") },
            { Id:  6,   DisplayName: qsTranslate("Numbers", "six") },
            { Id:  7,   DisplayName: qsTranslate("Numbers", "seven") },
            { Id:  8,   DisplayName: qsTranslate("Numbers", "eight") },
            { Id:  9,   DisplayName: qsTranslate("Numbers", "nine") },
            { Id: 10,   DisplayName: qsTranslate("Numbers", "ten") },
            { Id: 11,   DisplayName: qsTranslate("Numbers", "eleven") },
            { Id: 12,   DisplayName: qsTranslate("Numbers", "twelve") },
            { Id: 13,   DisplayName: qsTranslate("Numbers", "thirteen") },
            { Id: 14,   DisplayName: qsTranslate("Numbers", "fourteen") },
            { Id: 15,   DisplayName: qsTranslate("Numbers", "fifteen") },
            { Id: 16,   DisplayName: qsTranslate("Numbers", "sixteen") },
            { Id: 17,   DisplayName: qsTranslate("Numbers", "seventeen") },
            { Id: 18,   DisplayName: qsTranslate("Numbers", "eighteen") },
            { Id: 19,   DisplayName: qsTranslate("Numbers", "nineteen") },
            { Id: 20,   DisplayName: qsTranslate("Numbers", "twenty") }
        ]);
    }
    return cachedNumbers;
}

function previousExerciseHasSameAnswerOnIndex(answerObjectIndex, index, listModelItems, listModelItemsLength)
{
    if (listModelItemsLength < 1)
        return false;
    return listModelItems[listModelItemsLength - 1].Answers[index].Index === answerObjectIndex;
}

function previousExercisesHaveSameCorrectAnswer(answerObjectIndex, uniqueAnswers, listModelItems, listModelItemsLength)
{
    for (var i = Math.max(0, listModelItemsLength - uniqueAnswers); i < listModelItemsLength; i++)
        if (listModelItems[i].Index === answerObjectIndex)
            return true;
    return false;
}

function currentAnswersContainObjectIndex(answerObjectIndex, j, answers)
{
    for (var i = 0; i < j; i++)
        if (answers[i].Index === answerObjectIndex)
            return true;
    return false;
}

function dumpLesson(lesson)
{
    console.log("** Lesson (count: " + lesson.count + ")");
    for (var i = 0; i < lesson.count; i++)
        dumpExcercise(lesson.get(i));
}

function dumpExcercise(exercise)
{
    var output = "  ";
    for (var i = 0; i < exercise.Answers.count; i++) {
        var answer = exercise.Answers.get(i).DisplayName;
        if (i === exercise.CorrectAnswerIndex)
            answer = "_" + answer + "_";
        output += " " + answer
    }
    console.log(output + "  " + exercise.Answers.get(exercise.CorrectAnswerIndex).ImageSource);
}
