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
.pragma library

var currentScreen = "";
var currentLessonGroup = null;
var lessonData = null;
var lessonDataLength = 100;
var currentVolume = 0;

function addIndicesToDict(dict)
{
    for (var i = 0; i < dict.length; i++)
        dict[i].Index = i;
    return dict;
}

var cachedObjects = null;
function objects()
{
    if (cachedObjects === null) {
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
            { Id: "cat",            DisplayName: qsTranslate("Objects", "cat") },
            { Id: "camel",          DisplayName: qsTranslate("Objects", "camel") },
            { Id: "crocodile",      DisplayName: qsTranslate("Objects", "crocodile") },
            { Id: "pig",            DisplayName: qsTranslate("Objects", "pig") }
        ]);
    }
    return cachedObjects;
}

var cachedFirstLetters = null;
function firstLetters()
{
    if (cachedFirstLetters === null) {
        var firstLettersMap = new Array();
        objects(); // initializing 'cachedObjects'
        for (var i = 0; i < cachedObjects.length; i++) {
            var firstLetter = cachedObjects[i].DisplayName[0].toUpperCase();
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
    if (cachedNumbersAsWords === null) {
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
    if (cachedNumbersAsWordsRange === null || cachedNumbersAsWordsRange.from != from || cachedNumbersAsWordsRange.to != to) {
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
    if (cachedNumbersRange === null || cachedNumbersRange.from != from || cachedNumbersRange.to != to) {
        cachedNumbersRange = [];
        for (var i = from; i <= to; ++i)
            cachedNumbersRange.push({Id: i, DisplayName: String(i)});
        cachedNumbersRange.from = from;
        cachedNumbersRange.to = to;
        addIndicesToDict(cachedNumbersRange);
    }
    return cachedNumbersRange;
}

var cachedTimes = null;
function times(minutesIntervals)
{
    if (cachedTimes === null || cachedTimes.minutesIntervals != minutesIntervals) {
        cachedTimes = [];
        var index = 0;
        for (var hour = 1; hour <= 12; hour++) {
            for (var minute = 0; minute <= 59; minute += minutesIntervals) {
                cachedTimes.push({ Index: index, Id: index, Hour: hour, Minute: minute, DisplayName: hour + ":" + (minute < 10 ? "0":"") + minute});
                index++;
            }
        }
        cachedTimes.minutesIntervals = minutesIntervals;
    }
    return cachedTimes;
}

var cachedNotes = null;
function notes()
{
    if (cachedNotes === null) {
        cachedNotes = addIndicesToDict([
           { Id: "C",       Key:  1, DisplayName: qsTranslate("Notes", "C")},
           { Id: "C sharp", Key:  2, DisplayName: qsTranslate("Notes", "C sharp")},
           { Id: "D flat",  Key:  2, DisplayName: qsTranslate("Notes", "D flat")},
           { Id: "D",       Key:  3, DisplayName: qsTranslate("Notes", "D")},
           { Id: "D sharp", Key:  4, DisplayName: qsTranslate("Notes", "D sharp")},
           { Id: "E flat",  Key:  4, DisplayName: qsTranslate("Notes", "E flat")},
           { Id: "E",       Key:  5, DisplayName: qsTranslate("Notes", "E")},
           { Id: "F flat",  Key:  5, DisplayName: qsTranslate("Notes", "F flat")},
           { Id: "E sharp", Key:  6, DisplayName: qsTranslate("Notes", "E sharp")},
           { Id: "F",       Key:  6, DisplayName: qsTranslate("Notes", "F")},
           { Id: "F sharp", Key:  7, DisplayName: qsTranslate("Notes", "F sharp")},
           { Id: "G flat",  Key:  7, DisplayName: qsTranslate("Notes", "G flat")},
           { Id: "G",       Key:  8, DisplayName: qsTranslate("Notes", "G")},
           { Id: "G sharp", Key:  9, DisplayName: qsTranslate("Notes", "G sharp")},
           { Id: "A flat",  Key:  9, DisplayName: qsTranslate("Notes", "A flat")},
           { Id: "A",       Key: 10, DisplayName: qsTranslate("Notes", "A")},
           { Id: "A sharp", Key: 11, DisplayName: qsTranslate("Notes", "A sharp")},
           { Id: "B flat",  Key: 11, DisplayName: qsTranslate("Notes", "B flat")},
           { Id: "B",       Key: 12, DisplayName: qsTranslate("Notes", "B")},
           { Id: "C flat",  Key: 12, DisplayName: qsTranslate("Notes", "C flat")}
    ]);
    }
    return cachedNotes;
}

var cachedNaturalNotes = null;
function naturalNotes()
{
    if (cachedNaturalNotes === null) {
        cachedNaturalNotes = [];
        notes(); // initializing 'cachedNotes'
        for (var i = 0; i < cachedNotes.length; i++) {
            var note = cachedNotes[i];
            if (note.Id.length == 1)
                cachedNaturalNotes.push({ Id: note.Id, Key: note.Key, DisplayName: note.DisplayName});
        }
        addIndicesToDict(cachedNaturalNotes);
    }
    return cachedNaturalNotes;
}

var cachedColors = null;
function colors()
{
    if (cachedColors === null) {
        cachedColors = addIndicesToDict([
            { Id: "#FF3030", DisplayName: qsTranslate("Colors", "red")},
            { Id: "#0AC00A", DisplayName: qsTranslate("Colors", "green")},
            { Id: "#3030FF", DisplayName: qsTranslate("Colors", "blue")},
            { Id: "#FAFAFA", DisplayName: qsTranslate("Colors", "white")},
            { Id: "#808080", DisplayName: qsTranslate("Colors", "gray")},
            { Id: "#000000", DisplayName: qsTranslate("Colors", "black")},
            { Id: "#FFE800", DisplayName: qsTranslate("Colors", "yellow")},
            { Id: "#FF8C00", DisplayName: qsTranslate("Colors", "orange")},
            { Id: "#905020", DisplayName: qsTranslate("Colors", "brown")},
            { Id: "#9F00FF", DisplayName: qsTranslate("Colors", "violet")},
            { Id: "#FFA0C0", DisplayName: qsTranslate("Colors", "pink")}
    ]);
    }
    return cachedColors;
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
    if (cachedExcerciseFunctionsDict === null) {
        cachedExcerciseFunctionsDict = {
                firstLetterExerciseFunction: firstLetterExerciseFunction,
                nameTermsExerciseFunction: nameTermsExerciseFunction,
                countEasyExerciseFunction: countEasyExerciseFunction,
                countReadEasyExerciseFunction: countReadEasyExerciseFunction,
                countHardExerciseFunction: countHardExerciseFunction,
                countReadHardExerciseFunction: countReadHardExerciseFunction,
                clockEasyExerciseFunction: clockEasyExerciseFunction,
                clockMediumExerciseFunction: clockMediumExerciseFunction,
                clockHardExerciseFunction: clockHardExerciseFunction,
                notesReadEasyExerciseFunction: notesReadEasyExerciseFunction,
                notesReadHardExerciseFunction: notesReadHardExerciseFunction,
                colorExerciseFunction: colorExerciseFunction,
                mixedEasyExercisesFunction: mixedEasyExercisesFunction,
                mixedMediumExercisesFunction: mixedMediumExercisesFunction,
                mixedHardExercisesFunction: mixedHardExercisesFunction
        };
    }
    return cachedExcerciseFunctionsDict;
}

function exercise(i, exerciseFunction, answersCount)
{
    var index = i % lessonDataLength
    if (lessonData === null)
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

var countImages = ["fish", "apple", "balloon"];
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

function clockImageSourceFunction(object, answerIndex)
{
    return "image://imageprovider/clock/" + object.Hour + "/" + object.Minute + "/" + answerIndex;
}

function clockEasyExerciseFunction(i, answersCount)
{
    createExercise(i, times(60), answersCount, clockImageSourceFunction);
}

function clockMediumExerciseFunction(i, answersCount)
{
    createExercise(i, times(30), answersCount, clockImageSourceFunction);
}

function clockHardExerciseFunction(i, answersCount)
{
    createExercise(i, times(5), answersCount, clockImageSourceFunction);
}

function notesReadImageSourceFunction(object, answerIndex)
{
    return "image://imageprovider/notes/" + object.Id;
}

function notesReadEasyExerciseFunction(i, answersCount)
{
    createExercise(i, naturalNotes(), answersCount, notesReadImageSourceFunction);
}

function notesReadHardExerciseFunction(i, answersCount)
{
    createExercise(i, notes(), answersCount, notesReadImageSourceFunction);
}

function colorImageSourceFunction(object, answerIndex)
{
    return "image://imageprovider/color/" + object.Id + "/" + answerIndex;
}

function colorExerciseFunction(i, answersCount)
{
    createExercise(i, colors(), answersCount, colorImageSourceFunction);
}

function mixedEasyExercisesFunction(i, answersCount)
{
    var lessonsCount = 4;
    switch (((i + 1) % lessonsCount) - 1) {
        case 0: countExerciseFunction(i, answersCount, 1, 5, false); break;
        case 1: firstLetterExerciseFunction(i, answersCount); break;
        case 2: clockEasyExerciseFunction(i, answersCount); break;
        default:
        case 3: notesReadEasyExerciseFunction(i, answersCount); break;
    }
}

function mixedMediumExercisesFunction(i, answersCount)
{
    var lessonsCount = 6;
    switch (((i + 1) % lessonsCount) - 1) {
        case 0: countExerciseFunction(i, answersCount, 4, 16, false); break;
        case 1: countExerciseFunction(i, answersCount, 4, 16, true); break;
        case 2: clockMediumExerciseFunction(i, answersCount); break;
        case 3: notesReadEasyExerciseFunction(i, answersCount); break;
        case 4: nameTermsExerciseFunction(i, answersCount); break;
        default:
        case 5: colorExerciseFunction(i, answersCount); break;
    }
}

function mixedHardExercisesFunction(i, answersCount)
{
    var lessonsCount = 5;
    switch (((i + 1) % lessonsCount) - 1) {
        case 0: countExerciseFunction(i, answersCount, 8, 20, false); break;
        case 1: clockHardExerciseFunction(i, answersCount); break;
        case 2: countExerciseFunction(i, answersCount, 8, 20, true); break;
        case 3: notesReadHardExerciseFunction(i, answersCount); break;
        default:
        case 4: nameTermsExerciseFunction(i, answersCount); break;
    }
}

function database()
{
    return openDatabaseSync("TouchAndLearnDB", "1.0", "TouchAndLearn settings", 10000);
}

var lessonOfGroupTableName = "LessonOfGroup";
function createLessonOfGroupTable(transaction)
{
    transaction.executeSql('CREATE TABLE IF NOT EXISTS ' + lessonOfGroupTableName + '(lessonGroup TEXT, lesson TEXT)');
}

function currentLessonOfGroup(lessonGroup, defaultLesson)
{
    return defaultLesson;
    var result = defaultLesson;
    database().transaction(function(transaction) {
        createLessonOfGroupTable(transaction);
        var rs = transaction.executeSql('SELECT * FROM ' + lessonOfGroupTableName + ' WHERE lessonGroup = "' + lessonGroup + '"');
        if (rs.rows.length == 1) {
            var dbResult = rs.rows.item(0).lesson;
            for (var group in cachedLessonMenu) {
                group = cachedLessonMenu[group];
                if (group.Id == lessonGroup) {
                    for (var lesson in group.Lessons) {
                        if (dbResult == group.Lessons[lesson].Id) {
                            result = dbResult;
                            return;
                        }
                    }
                }
            }
        }
    });
    return result;
}

function setCurrentLessonOfGroup(lessonGroup, lesson)
{
    return;
    database().transaction(function(transaction) {
        createLessonOfGroupTable(transaction);
        transaction.executeSql('DELETE FROM ' + lessonOfGroupTableName + ' WHERE lessonGroup = "' + lessonGroup + '"');
        transaction.executeSql('INSERT INTO ' + lessonOfGroupTableName + ' VALUES(?, ?)', [lessonGroup, lesson]);
    });
}

var settingsTableName = "Settings";
function createSettingsTable(transaction)
{
    transaction.executeSql('CREATE TABLE IF NOT EXISTS ' + settingsTableName + '(key TEXT, value TEXT)');
}

var volumeKeyName = "Volume";
function persistentVolume()
{
    var result = 60; // 0-100
    database().transaction(function(transaction) {
        createSettingsTable(transaction);
        var rs = transaction.executeSql('SELECT * FROM ' + settingsTableName + ' WHERE key = "' + volumeKeyName + '"');
        if (rs.rows.length == 1)
            result = parseInt(rs.rows.item(0).value);
    });
    return result;
}

function setPersistentVolume(volume)
{
    database().transaction(function(transaction) {
        createLessonOfGroupTable(transaction);
        transaction.executeSql('DELETE FROM ' + settingsTableName + ' WHERE key = "' + volumeKeyName + '"');
        transaction.executeSql('INSERT INTO ' + settingsTableName + ' VALUES(?, ?)', [volumeKeyName, volume]);
    });
}

var cachedLessonMenu = null;
function lessonMenu()
{
    if (cachedLessonMenu === null) {
        cachedLessonMenu = [ {
            Id: "Read",                 DisplayName: qsTranslate("LessonMenu", "Read"),                         ImageLabel: qsTranslate("Objects", "robot"),    DefaultLesson: 1,
            Lessons: [
                { Id: "FirstLetter",    DisplayName: qsTranslate("LessonMenu", "Read the first letter"),        ImageLabel: qsTranslate("Objects", "robot")[0] },
                { Id: "NameTerms",      DisplayName: qsTranslate("LessonMenu", "Read words"),                   ImageLabel: qsTranslate("Objects", "robot") }
            ] }, {
            Id: "Count",                DisplayName: qsTranslate("LessonMenu", "Count"),                        ImageLabel: "3",                                DefaultLesson: 0,
            Lessons: [
                { Id: "CountEasy",      DisplayName: qsTranslate("LessonMenu", "Count to 5"),                   ImageLabel: "3" },
                { Id: "CountReadEasy",  DisplayName: qsTranslate("LessonMenu", "Count and read to 5"),          ImageLabel: qsTranslate("Numbers", "three") },
                { Id: "CountHard",      DisplayName: qsTranslate("LessonMenu", "Count to 20"),                  ImageLabel: "9" },
                { Id: "CountReadHard",  DisplayName: qsTranslate("LessonMenu", "Count and read to 20"),         ImageLabel: qsTranslate("Numbers", "nine") }
            ] }, {
            Id: "Clock",                DisplayName: qsTranslate("LessonMenu", "Clock"),                        ImageLabel: "5:00",                             DefaultLesson: 1,
            Lessons: [
                { Id: "ClockEasy",      DisplayName: qsTranslate("LessonMenu", "Read the clock, full hours"),   ImageLabel: "5:00" },
                { Id: "ClockMedium",    DisplayName: qsTranslate("LessonMenu", "Read the clock, half hours"),   ImageLabel: "8:30" },
                { Id: "ClockHard",      DisplayName: qsTranslate("LessonMenu", "Read the clock"),               ImageLabel: "1:20" }
            ] }, {
            Id: "Music",                DisplayName: qsTranslate("LessonMenu", "Music"),                        ImageLabel: qsTranslate("Notes", "A"),          DefaultLesson: 1,
            Lessons: [
                { Id: "NotesReadEasy",  DisplayName: qsTranslate("LessonMenu", "Read notes, whole step"),       ImageLabel: qsTranslate("Notes", "A") },
                { Id: "NotesReadHard",  DisplayName: qsTranslate("LessonMenu", "Read notes, half-step"),        ImageLabel: qsTranslate("Notes", "A sharp") }
            ] }, {
            Id: "Color",                DisplayName: qsTranslate("LessonMenu", "Color"),                        ImageLabel: qsTranslate("Colors", "blue"),      DefaultLesson: 0,
            Lessons: [
                { Id: "ColorEasy",      DisplayName: qsTranslate("LessonMenu", "Recognize the color"),          ImageLabel: qsTranslate("Colors", "blue") }
            ] }, {
            Id: "Mixed",                DisplayName: qsTranslate("LessonMenu", "Mixed"),                        ImageLabel: "?",                                DefaultLesson: 0,
            Lessons: [
                { Id: "MixedEasy",      DisplayName: qsTranslate("LessonMenu", "Mixed lessons, easy"),          ImageLabel: "?" },
                { Id: "MixedMedium",    DisplayName: qsTranslate("LessonMenu", "Mixed lessons, medium"),        ImageLabel: "??" },
                { Id: "MixedHard",      DisplayName: qsTranslate("LessonMenu", "Mixed lessons, hard"),          ImageLabel: "???" }
            ] }
        ];
    }
    return cachedLessonMenu;
}

function lessonsOfCurrentGroup()
{
    if (currentLessonGroup === null)
        currentLessonGroup = lessonMenu()[4];
    return currentLessonGroup.Lessons;
}

function currentLessonOfCurrentGroup()
{
    return currentLessonOfGroup(currentLessonGroup.Id, currentLessonGroup.Lessons[currentLessonGroup.DefaultLesson].Id);
}
