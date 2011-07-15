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
var lessonData = [];
var lessonDataLength = 100;
var currentVolume = -1;

var data = {
    addIndicesToDict: function(dict)
    {
        for (var i = 0; i < dict.length; i++)
            dict[i].Index = i;
        return dict;
    },

    cachedObjects: null,
    objects: function()
    {
        if (this.cachedObjects === null) {
            this.cachedObjects = this.addIndicesToDict([
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
                { Id: "pig",            DisplayName: qsTranslate("Objects", "pig") },
                { Id: "snake",          DisplayName: qsTranslate("Objects", "snake") },
                { Id: "giraffe",        DisplayName: qsTranslate("Objects", "giraffe") }
            ]);
        }
        return this.cachedObjects;
    },

    cachedFirstLetters: null,
    firstLetters: function()
    {
        if (this.cachedFirstLetters === null) {
            var firstLettersMap = [];
            this.objects(); // initializing 'this.cachedObjects'
            for (var i = 0; i < this.cachedObjects.length; i++) {
                var firstLetter = this.cachedObjects[i].DisplayName[0].toUpperCase();
                if (firstLettersMap[firstLetter] === undefined)
                    firstLettersMap[firstLetter] = [];
                firstLettersMap[firstLetter].push(this.cachedObjects[i]);
            }
            var firstLetters = [];
            for (var letter in firstLettersMap)
                firstLetters.push({ Id: letter, DisplayName: letter, Objects: firstLettersMap[letter]});
            this.cachedFirstLetters = this.addIndicesToDict(firstLetters);
        }
        return this.cachedFirstLetters;
    },

    cachedNumbersAsWords: null,
    numbersAsWords: function()
    {
        if (this.cachedNumbersAsWords === null) {
            this.cachedNumbersAsWords = [
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
        return this.cachedNumbersAsWords;
    },

    cachedNumbersAsWordsRange: null,
    numbersAsWordsRange: function(from, to)
    {
        if (this.cachedNumbersAsWordsRange === null || this.cachedNumbersAsWordsRange.from !== from || this.cachedNumbersAsWordsRange.to !== to) {
            this.cachedNumbersAsWordsRange = [];
            this.numbersAsWords(); // initializing 'this.cachedNumbersAsWords'
            for (var i = from; i <= to; ++i)
                this.cachedNumbersAsWordsRange.push(this.cachedNumbersAsWords[i]);
            this.cachedNumbersAsWordsRange.from = from;
            this.cachedNumbersAsWordsRange.to = to;
            this.addIndicesToDict(this.cachedNumbersAsWordsRange);
        }
        return this.cachedNumbersAsWordsRange;
    },

    cachedNumbersRange: null,
    numbersRange: function(from, to)
    {
        if (this.cachedNumbersRange === null || this.cachedNumbersRange.from !== from || this.cachedNumbersRange.to !== to) {
            this.cachedNumbersRange = [];
            for (var i = from; i <= to; ++i)
                this.cachedNumbersRange.push({ Id: i, DisplayName: '' + i });
            this.cachedNumbersRange.from = from;
            this.cachedNumbersRange.to = to;
            this.addIndicesToDict(this.cachedNumbersRange);
        }
        return this.cachedNumbersRange;
    },

    cachedTimes: null,
    times: function(minutesIntervals)
    {
        if (this.cachedTimes === null || this.cachedTimes.minutesIntervals !== minutesIntervals) {
            this.cachedTimes = [];
            var index = 0;
            for (var hour = 1; hour <= 12; hour++) {
                for (var minute = 0; minute <= 59; minute += minutesIntervals) {
                    this.cachedTimes.push({ Index: index, Id: index, Hour: hour, Minute: minute, DisplayName: hour + ":" + (minute < 10 ? "0":"") + minute});
                    index++;
                }
            }
            this.cachedTimes.minutesIntervals = minutesIntervals;
        }
        return this.cachedTimes;
    },

    cachedNotes: null,
    notes: function()
    {
        if (this.cachedNotes === null) {
            this.cachedNotes = this.addIndicesToDict([
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
        return this.cachedNotes;
    },

    cachedNaturalNotes: null,
    naturalNotes: function()
    {
        if (this.cachedNaturalNotes === null) {
            this.cachedNaturalNotes = [];
            this.notes(); // initializing 'this.cachedNotes'
            for (var i = 0; i < this.cachedNotes.length; i++) {
                var note = this.cachedNotes[i];
                if (note.Id.length === 1)
                    this.cachedNaturalNotes.push({ Id: note.Id, Key: note.Key, DisplayName: note.DisplayName});
            }
            this.addIndicesToDict(this.cachedNaturalNotes);
        }
        return this.cachedNaturalNotes;
    },

    cachedMathEasy: null,
    mathEasy: function()
    {
        if (cachedMathEasy === null)
            appendAdditionExercises(cachedMathEasy, 2, 8)
        return cachedMathEasy;
    },

    cachedColors: null,
    colors: function()
    {
        if (this.cachedColors === null) {
            this.cachedColors = this.addIndicesToDict([
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
        return this.cachedColors;
    },

    initCaches: function()
    {
        this.objects();
        this.numbersAsWords();
        this.notes();
        this.naturalNotes();
        this.colors();
    }
}

var exercises = {
    previousExerciseHasSameAnswerOnIndex: function(answerObjectIndex, index, listModelItemsLength)
    {
        if (listModelItemsLength < 1)
            return false;
        return lessonData[listModelItemsLength - 1].Answers[index].Index === answerObjectIndex;
    },

    previousExercisesHaveSameCorrectAnswer: function(answerObjectIndex, uniqueAnswers, listModelItemsLength)
    {
        for (var i = Math.max(0, listModelItemsLength - uniqueAnswers); i < listModelItemsLength; i++)
            if (lessonData[i].Index === answerObjectIndex)
                return true;
        return false;
    },

    currentAnswersContainObjectIndex: function(answerObjectIndex, j, answers)
    {
        for (var i = 0; i < j; i++)
            if (answers[i].Index === answerObjectIndex)
                return true;
        return false;
    },

    createExercise: function(i, data, answersPerChoiceCount, imageSourceFunction)
    {
        var correctAnswerIndex = Math.floor(Math.random() * answersPerChoiceCount);
        var currentDataIndex;
        do {
            currentDataIndex = Math.floor(Math.random() * data.length);
        } while (this.previousExerciseHasSameAnswerOnIndex(currentDataIndex, correctAnswerIndex, i)
                 || this.previousExercisesHaveSameCorrectAnswer(currentDataIndex, Math.round(data.length * 0.5), i));
        var object = data[currentDataIndex];
        var answers = new Array(answersPerChoiceCount);
        answers[correctAnswerIndex] = object;
        for (var j = 0; j < answersPerChoiceCount; j++) {
            if (j !== correctAnswerIndex) {
                var wrongAnswerDataIndex;
                do {
                    wrongAnswerDataIndex = Math.floor(Math.random() * data.length);
                } while (wrongAnswerDataIndex === currentDataIndex
                         || this.previousExerciseHasSameAnswerOnIndex(wrongAnswerDataIndex, j, i)
                         || this.currentAnswersContainObjectIndex(wrongAnswerDataIndex, j, answers))
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
//        dumpLessonData();
    },

    firstLetterImageSourceFunction: function(object, answerIndex)
    {
        var answerObjects = object.Objects;
        return "image://imageprovider/object/"
                + answerObjects[Math.floor(Math.random() * answerObjects.length)].Id;
    },

    firstLetterExerciseFunction: function(i, answersCount)
    {
        var firstLetters = data.firstLetters();
        this.createExercise(i, firstLetters, answersCount, this.firstLetterImageSourceFunction);
    },

    nameTermsImageSourceFunction: function(object, answerIndex)
    {
        return "image://imageprovider/object/" + object.Id;
    },

    nameTermsExerciseFunction: function(i, answersCount)
    {
        var objects = data.objects();
        this.createExercise(i, objects, answersCount, this.nameTermsImageSourceFunction);
    },

    countExerciseFunction: function(i, answersCount, rangeFrom, rangeTo, numbersAsWords)
    {
        var images = ["fish", "apple", "balloon"];
        function countExeciseImageFunction(object, answerIndex)
        {
            return "image://imageprovider/quantity/" + object.Id + "/"
                  + images[answerIndex % images.length];
        };
        var numbers = numbersAsWords ? data.numbersAsWordsRange(rangeFrom, rangeTo)
                                     : data.numbersRange(rangeFrom, rangeTo);
        this.createExercise(i, numbers, answersCount, countExeciseImageFunction);
    },

    countEasyExerciseFunction: function(i, answersCount)
    {
        this.countExerciseFunction(i, answersCount, 1, 5, false);
    },

    countReadEasyExerciseFunction: function(i, answersCount)
    {
        this.countExerciseFunction(i, answersCount, 1, 5, true);
    },

    countHardExerciseFunction: function(i, answersCount)
    {
        this.countExerciseFunction(i, answersCount, 5, 20, false);
    },

    countReadHardExerciseFunction: function(i, answersCount)
    {
        this.countExerciseFunction(i, answersCount, 5, 20, true);
    },

    mathEasyExerciseFunction: function(i, answersCount)
    {
        this.createExercise(i, numbers, answersCount, countImageSourceFunction);
    },

    clockImageSourceFunction: function(object, answerIndex)
    {
        return "image://imageprovider/clock/" + object.Hour + "/" + object.Minute + "/" + answerIndex;
    },

    clockEasyExerciseFunction: function(i, answersCount)
    {
        var times = data.times(60);
        this.createExercise(i, times, answersCount, this.clockImageSourceFunction);
    },

    clockMediumExerciseFunction: function(i, answersCount)
    {
        var times = data.times(30);
        this.createExercise(i, times, answersCount, this.clockImageSourceFunction);
    },

    clockHardExerciseFunction: function(i, answersCount)
    {
        var times = data.times(5);
        this.createExercise(i, times, answersCount, this.clockImageSourceFunction);
    },

    notesReadImageSourceFunction: function(object, answerIndex)
    {
        return "image://imageprovider/notes/" + object.Id;
    },

    notesReadEasyExerciseFunction: function(i, answersCount)
    {
        var naturalNotes = data.naturalNotes();
        this.createExercise(i, naturalNotes, answersCount, this.notesReadImageSourceFunction);
    },

    notesReadHardExerciseFunction: function(i, answersCount)
    {
        var notes = data.notes();
        this.createExercise(i, notes, answersCount, this.notesReadImageSourceFunction);
    },

    colorImageSourceFunction: function(object, answerIndex)
    {
        return "image://imageprovider/color/" + object.Id + "/" + answerIndex;
    },

    colorExerciseFunction: function(i, answersCount)
    {
        var colors = data.colors();
        this.createExercise(i, colors, answersCount, this.colorImageSourceFunction);
    },

    mixedEasyExercisesFunction: function(i, answersCount)
    {
        var lessonsCount = 4;
        switch (((i + 1) % lessonsCount) - 1) {
            case 0: this.countExerciseFunction(i, answersCount, 1, 5, false); break;
            case 1: this.firstLetterExerciseFunction(i, answersCount); break;
            case 2: this.clockEasyExerciseFunction(i, answersCount); break;
            default:
            case 3: this.notesReadEasyExerciseFunction(i, answersCount); break;
        }
    },

    mixedMediumExercisesFunction: function(i, answersCount)
    {
        var lessonsCount = 6;
        switch (((i + 1) % lessonsCount) - 1) {
            case 0: this.countExerciseFunction(i, answersCount, 4, 16, false); break;
            case 1: this.countExerciseFunction(i, answersCount, 4, 16, true); break;
            case 2: this.clockMediumExerciseFunction(i, answersCount); break;
            case 3: this.notesReadEasyExerciseFunction(i, answersCount); break;
            case 4: this.nameTermsExerciseFunction(i, answersCount); break;
            default:
            case 5: this.colorExerciseFunction(i, answersCount); break;
        }
    },

    mixedHardExercisesFunction: function(i, answersCount)
    {
        var lessonsCount = 5;
        switch (((i + 1) % lessonsCount) - 1) {
            case 0: this.countExerciseFunction(i, answersCount, 8, 20, false); break;
            case 1: this.clockHardExerciseFunction(i, answersCount); break;
            case 2: this.countExerciseFunction(i, answersCount, 8, 20, true); break;
            case 3: this.notesReadHardExerciseFunction(i, answersCount); break;
            default:
            case 4: this.nameTermsExerciseFunction(i, answersCount); break;
        }
    }
}

function exercise(i, exerciseFunction, answersCount)
{
    var index = i % lessonDataLength;
    if (lessonData[index] === undefined)
        exercises[exerciseFunction](index, answersCount);
    return lessonData[index];
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

var persistence = {
    database: function()
    {
        return openDatabaseSync("TouchAndLearnDB", "1.0", "TouchAndLearn settings", 10000);
    },

    lessonOfGroupTableName: "LessonOfGroup",
    createLessonOfGroupTable: function(transaction)
    {
        transaction.executeSql('CREATE TABLE IF NOT EXISTS ' + this.lessonOfGroupTableName + '(lessonGroup TEXT, lesson TEXT)');
    },

    readCurrentLessonsOfGroups: function()
    {
        lessonMenu(); // initializing 'cachedLessonMenu'
        persistence.database().transaction(function(transaction) {
            persistence.createLessonOfGroupTable(transaction);
            var rs = transaction.executeSql('SELECT * FROM ' + persistence.lessonOfGroupTableName);
            for (var row = 0; row < rs.rows.length; row++) {
                var resultRow = rs.rows.item(row);
                var lessonGroupDb = rs.rows.item(row).lessonGroup;
                var lessonGroup = cachedLessonMenuDict[lessonGroupDb];
                if (lessonGroup === undefined)
                    continue;
                var lessonDb = rs.rows.item(row).lesson;
                var lesson = lessonGroup.LessonsDict[lessonDb];
                if (lesson === undefined)
                    continue;
                lessonGroup.CurrentLesson = lessonDb;
            }
        });
    },

    writeCurrentLessonsOfGroups: function()
    {
        persistence.database().transaction(function(transaction) {
            persistence.createLessonOfGroupTable(transaction);
            for (var group in cachedLessonMenuDict) {
                group = cachedLessonMenuDict[group];
                var lessonGroupId = group.Id;
                transaction.executeSql('DELETE FROM ' + persistence.lessonOfGroupTableName + ' WHERE lessonGroup = "' + lessonGroupId + '"');
                transaction.executeSql('INSERT INTO ' + persistence.lessonOfGroupTableName + ' VALUES(?, ?)', [lessonGroupId, group.CurrentLesson]);
            }
        });
    },

    settingsTableName: "Settings",
    createSettingsTable: function(transaction)
    {
        transaction.executeSql('CREATE TABLE IF NOT EXISTS ' + persistence.settingsTableName + '(key TEXT, value TEXT)');
    },

    volumeKeyName: "Volume",
    readVolume: function()
    {
        var result = 60; // 0-100
        persistence.database().transaction(function(transaction) {
            persistence.createSettingsTable(transaction);
            var rs = transaction.executeSql('SELECT * FROM ' + persistence.settingsTableName + ' WHERE key = "' + persistence.volumeKeyName + '"');
            if (rs.rows.length === 1)
                result = parseInt(rs.rows.item(0).value);
        });
        return result;
    },

    writeVolume: function(volume)
    {
        persistence.database().transaction(function(transaction) {
            persistence.createSettingsTable(transaction);
            transaction.executeSql('DELETE FROM ' + persistence.settingsTableName + ' WHERE key = "' + persistence.volumeKeyName + '"');
            transaction.executeSql('INSERT INTO ' + persistence.settingsTableName + ' VALUES(?, ?)', [persistence.volumeKeyName, volume]);
        });
    }
};

var cachedLessonMenu = null;
var cachedLessonMenuDict = null;
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
        cachedLessonMenuDict = {};
        for (var groupIndex = 0; groupIndex < cachedLessonMenu.length; groupIndex++) {
            var group = cachedLessonMenu[groupIndex];
            cachedLessonMenuDict[group.Id] = group;
            group.CurrentLesson = group.Lessons[group.DefaultLesson].Id;
            group.LessonsDict = {};
            for (var lessonIndex = 0; lessonIndex < group.Lessons.length; lessonIndex++) {
                var lesson = group.Lessons[lessonIndex];
                group.LessonsDict[lesson.Id] = lesson;
            }
        }
    }
    return cachedLessonMenu;
}

function lessonsOfCurrentGroup()
{
    if (currentLessonGroup === null)
        currentLessonGroup = lessonMenu()[4];
    return currentLessonGroup.Lessons;
}

function setCurrentLessonOfGroup(lessonGroup, lesson)
{
    lessonGroup = cachedLessonMenuDict[lessonGroup];
    lessonGroup.CurrentLesson = lessonGroup.LessonsDict[lesson].Id;
}

function currentLessonOfCurrentGroup()
{
    return currentLessonGroup.CurrentLesson;
}
