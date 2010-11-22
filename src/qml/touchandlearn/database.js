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
.pragma library

var previousScreen = null;
var currentScreen = null;
var lessonData = null;
var lessonDataLength = 100;

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
            { Id: "key",            DisplayName: qsTranslate("Objects", "key") },
            { Id: "horse",          DisplayName: qsTranslate("Objects", "horse") },
            { Id: "dog",            DisplayName: qsTranslate("Objects", "dog") },
            { Id: "cat",            DisplayName: qsTranslate("Objects", "cat") }
        ]);
    }
    return cachedObjects;
}

var cachedFirstLetters = null;
function firstLetters()
{
    if (cachedFirstLetters == null) {
        var firstLettersMap = new Array();
        objects(); // initializing 'cachedObjects'
        for (var i = 0; i < cachedObjects.length; i++) {
            var firstLetter = cachedObjects[i].Id[0].toUpperCase();
            if (firstLettersMap[firstLetter] === undefined)
                firstLettersMap[firstLetter] = new Array();
            firstLettersMap[firstLetter].push(cachedObjects[i]);
        }
        var firstLetters = new Array();
        for (var letter in firstLettersMap)
            firstLetters.push({ Id: letter, DisplayName: letter, Objects: firstLettersMap[letter]});
        cachedFirstLetters = addIndicesToDict(firstLetters);
    }
    return cachedFirstLetters;
}

var cachedNumbersAsWords = null;
function numbersAsWords()
{
    if (cachedNumbersAsWords == null) {
        cachedNumbersAsWords = [
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
        ];
    }
    return cachedNumbersAsWords;
}

var cachedNumbersAsWordsRange = null;
function numbersAsWordsRange(from, to)
{
    if (cachedNumbersAsWordsRange == null || cachedNumbersAsWordsRange.from != from || cachedNumbersAsWordsRange.to != to) {
        cachedNumbersAsWordsRange = [];
        numbersAsWords(); // initializing 'cachedNumbers'
        for (var i = from; i <= to; ++i)
            cachedNumbersAsWordsRange.push(cachedNumbersAsWords[i]);
        cachedNumbersAsWordsRange.from = from;
        cachedNumbersAsWordsRange.to = to;
        addIndicesToDict(cachedNumbersAsWordsRange);
    }
    return cachedNumbersAsWordsRange;
}

var cachedNumbersRange = null;
function numbersRange(from, to)
{
    if (cachedNumbersRange == null || cachedNumbersRange.from != from || cachedNumbersRange.to != to) {
        cachedNumbersRange = [];
        for (var i = from; i <= to; ++i)
            cachedNumbersRange.push({Id: i, DisplayName: String(i)});
        cachedNumbersRange.from = from;
        cachedNumbersRange.to = to;
        addIndicesToDict(cachedNumbersRange);
    }
    return cachedNumbersRange;
}

function previousExerciseHasSameAnswerOnIndex(answerObjectIndex, index,  listModelItemsLength)
{
    if (listModelItemsLength < 1)
        return false;
    return lessonData[listModelItemsLength - 1].Answers[index].Index === answerObjectIndex;
}

function previousExercisesHaveSameCorrectAnswer(answerObjectIndex, uniqueAnswers, listModelItemsLength)
{
    for (var i = Math.max(0, listModelItemsLength - uniqueAnswers); i < listModelItemsLength; i++)
        if (lessonData[i].Index === answerObjectIndex)
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

var cachedExcerciseFunctionsDict = null;
function excerciseFunctionsDict()
{
    if (cachedExcerciseFunctionsDict == null) {
        cachedExcerciseFunctionsDict = {
                firstLetterExerciseFunction: firstLetterExerciseFunction,
                nameTermsExerciseFunction: nameTermsExerciseFunction,
                countEasyExerciseFunction: countEasyExerciseFunction,
                countReadEasyExerciseFunction: countReadEasyExerciseFunction,
                countHardExerciseFunction: countHardExerciseFunction,
                countReadHardExerciseFunction: countReadHardExerciseFunction,
                mixedExercisesFunction: mixedExercisesFunction
        };
    }
    return cachedExcerciseFunctionsDict;
}

function exercise(i, exerciseFunction, answersCount)
{
    var index = i % lessonDataLength
    if (lessonData == null)
        lessonData = [];
    if (lessonData[index] === undefined)
        excerciseFunctionsDict()[exerciseFunction](index, answersCount);
    return lessonData[index];
}

function createExercise(i, data, answersPerChoiceCount, imageSourceFunction)
{
    var correctAnswerIndex = Math.floor(Math.random() * answersPerChoiceCount);
    var currentDataIndex;
    do {
        currentDataIndex = Math.floor(Math.random() * data.length);
    } while (previousExerciseHasSameAnswerOnIndex(currentDataIndex, correctAnswerIndex, i)
             || previousExercisesHaveSameCorrectAnswer(currentDataIndex, Math.round(data.length * 0.5), i));
    var object = data[currentDataIndex];
    var answers = Array(answersPerChoiceCount);
    answers[correctAnswerIndex] = object;
    for (var j = 0; j < answersPerChoiceCount; j++) {
        if (j != correctAnswerIndex) {
            var wrongAnswerDataIndex;
            do {
                wrongAnswerDataIndex = Math.floor(Math.random() * data.length);
            } while (wrongAnswerDataIndex === currentDataIndex
                     || previousExerciseHasSameAnswerOnIndex(wrongAnswerDataIndex, j, i)
                     || currentAnswersContainObjectIndex(wrongAnswerDataIndex, j, answers))
            answers[j] = data[wrongAnswerDataIndex];
        }
    }
    for (var a = 0; a < answers.length; a++)
        answers[a].ImageSource = imageSourceFunction(answers[a], i);
    var listItem = {
        Index: object.Index,
        ImageSource: answers[correctAnswerIndex].ImageSource,
        Answers: answers,
        CorrectAnswerIndex: correctAnswerIndex};
    lessonData[i] = listItem;
//    dumpLessonData();
}

function dumpLessonData()
{
    console.log("** lessonData (count: " + lessonData.length + ")");
    for (var i = 0; i < lessonData.length; i++) {
        var exercise = lessonData[i];
        var output = "  ";
        for (var j = 0; j < exercise.Answers.length; j++) {
            var answer = exercise.Answers[j].DisplayName;
            if (j === exercise.CorrectAnswerIndex)
                answer = ">" + answer + "<";
            output += " " + answer;
        }
        console.log(output + "  " + exercise.Answers[exercise.CorrectAnswerIndex].ImageSource);
    }
}

function firstLetterImageSourceFunction(object, answerIndex)
{
    var answerObjects = object.Objects;
    return "image://imageprovider/object/"
            + answerObjects[Math.floor(Math.random() * answerObjects.length)].Id;
}

function firstLetterExerciseFunction(i, answersCount)
{
    createExercise(i, firstLetters(), answersCount, firstLetterImageSourceFunction);
}

function nameTermsImageSourceFunction(object, answerIndex)
{
    return "image://imageprovider/object/" + object.Id;
}

function nameTermsExerciseFunction(i, answersCount)
{
    createExercise(i, objects(), answersCount, nameTermsImageSourceFunction);
}

var countImages = ["fish", "apple"];
function countImageSourceFunction(object, answerIndex)
{
    return "image://imageprovider/quantity/" + object.Id + "/"
            + countImages[answerIndex % countImages.length];
}

function countExerciseFunction(i, answersCount, rangeFrom, rangeTo, numbersAsWords)
{

    var numbers = numbersAsWords ? numbersAsWordsRange(rangeFrom, rangeTo)
                                 : numbersRange(rangeFrom, rangeTo);
    createExercise(i, numbers, answersCount, countImageSourceFunction);
}

function countEasyExerciseFunction(i, answersCount)
{
    countExerciseFunction(i, answersCount, 1, 5, false);
}

function countReadEasyExerciseFunction(i, answersCount)
{
    countExerciseFunction(i, answersCount, 1, 5, true);
}

function countHardExerciseFunction(i, answersCount)
{
    countExerciseFunction(i, answersCount, 5, 20, false);
}

function countReadHardExerciseFunction(i, answersCount)
{
    countExerciseFunction(i, answersCount, 5, 20, true);
}

function mixedExercisesFunction(i, answersCount)
{
    var lessonsCount = 4;
    switch (((i + 1) % lessonsCount) - 1) {
        case 0: countExerciseFunction(i, answersCount, 1, 16, false); break;
        case 1: firstLetterExerciseFunction(i, answersCount); break;
        case 2: countExerciseFunction(i, answersCount, 1, 16, true); break;
        default:
        case 3: nameTermsExerciseFunction(i, answersCount); break;
    }
}
