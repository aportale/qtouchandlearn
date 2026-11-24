/*
    Touch'n'learn - Fun and easy mobile lessons for kids
    Copyright (C) 2010, 2011, 2026 by Alessandro Portale
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

#include "exercises.h"

#include <QtCore/QCoreApplication>
#include <QtCore/QRandomGenerator>

#include <algorithm>
#include <functional>
#include <initializer_list>
#include <iterator>

using namespace Qt::StringLiterals;

// The number of different exercises of a lesson, after which they repeat
static constexpr int exercisesCount = 100;

namespace {

// Something that an exercise asks for: an object, a number, a time, a note or a color
struct Item
{
    QString id;
    QString displayName;
    QStringList objectIds; // The objects that start with the letter, for the first letter exercises
    int hour = 0;
    int minute = 0;
};

// Returns the image of an item in the exercise with the index
using ImageSourceFunction = QString (*)(const Item &item, int exerciseIndex);

int randomIndex(qsizetype count)
{
    return QRandomGenerator::global()->bounded(int(count));
}

// The translation contexts of the former database.js keep the existing translations valid.

QList<Item> objects()
{
    static const char *const ids[] = {
        QT_TRANSLATE_NOOP("Objects", "banana"),
        QT_TRANSLATE_NOOP("Objects", "elephant"),
        QT_TRANSLATE_NOOP("Objects", "robot"),
        QT_TRANSLATE_NOOP("Objects", "flower"),
        QT_TRANSLATE_NOOP("Objects", "fish"),
        QT_TRANSLATE_NOOP("Objects", "rooster"),
        QT_TRANSLATE_NOOP("Objects", "airplane"),
        QT_TRANSLATE_NOOP("Objects", "candle"),
        QT_TRANSLATE_NOOP("Objects", "scissors"),
        QT_TRANSLATE_NOOP("Objects", "key"),
        QT_TRANSLATE_NOOP("Objects", "horse"),
        QT_TRANSLATE_NOOP("Objects", "dog"),
        QT_TRANSLATE_NOOP("Objects", "cat"),
        QT_TRANSLATE_NOOP("Objects", "camel"),
        QT_TRANSLATE_NOOP("Objects", "crocodile"),
        QT_TRANSLATE_NOOP("Objects", "pig"),
        QT_TRANSLATE_NOOP("Objects", "snake"),
        QT_TRANSLATE_NOOP("Objects", "giraffe"),
        QT_TRANSLATE_NOOP("Objects", "snail"),
        QT_TRANSLATE_NOOP("Objects", "hedgehog"),
    };
    QList<Item> result;
    for (const char *id : ids)
        result.append({ QString::fromLatin1(id), QCoreApplication::translate("Objects", id) });
    return result;
}

// The first letters of the translated object names, in the order of their first object
QList<Item> firstLetters()
{
    QList<Item> result;
    for (const Item &object : objects()) {
        const QString letter = object.displayName.left(1).toUpper();
        auto it = std::find_if(result.begin(), result.end(),
                               [&letter](const Item &item) { return item.id == letter; });
        if (it == result.end())
            it = result.insert(result.end(), { letter, letter });
        it->objectIds.append(object.id);
    }
    return result;
}

QList<Item> numbers(int from, int to, bool asWords)
{
    static const char *const words[] = {
        QT_TRANSLATE_NOOP("Numbers", "zero"),
        QT_TRANSLATE_NOOP("Numbers", "one"),
        QT_TRANSLATE_NOOP("Numbers", "two"),
        QT_TRANSLATE_NOOP("Numbers", "three"),
        QT_TRANSLATE_NOOP("Numbers", "four"),
        QT_TRANSLATE_NOOP("Numbers", "five"),
        QT_TRANSLATE_NOOP("Numbers", "six"),
        QT_TRANSLATE_NOOP("Numbers", "seven"),
        QT_TRANSLATE_NOOP("Numbers", "eight"),
        QT_TRANSLATE_NOOP("Numbers", "nine"),
        QT_TRANSLATE_NOOP("Numbers", "ten"),
        QT_TRANSLATE_NOOP("Numbers", "eleven"),
        QT_TRANSLATE_NOOP("Numbers", "twelve"),
        QT_TRANSLATE_NOOP("Numbers", "thirteen"),
        QT_TRANSLATE_NOOP("Numbers", "fourteen"),
        QT_TRANSLATE_NOOP("Numbers", "fifteen"),
        QT_TRANSLATE_NOOP("Numbers", "sixteen"),
        QT_TRANSLATE_NOOP("Numbers", "seventeen"),
        QT_TRANSLATE_NOOP("Numbers", "eighteen"),
        QT_TRANSLATE_NOOP("Numbers", "nineteen"),
        QT_TRANSLATE_NOOP("Numbers", "twenty"),
    };
    Q_ASSERT(from >= 0 && to < int(std::size(words)));
    QList<Item> result;
    for (int number = from; number <= to; ++number) {
        const QString id = QString::number(number);
        result.append({ id, asWords ? QCoreApplication::translate("Numbers", words[number]) : id });
    }
    return result;
}

// The times on the clock from 1:00 to 12:55, in steps of minutesInterval
QList<Item> times(int minutesInterval)
{
    QList<Item> result;
    for (int hour = 1; hour <= 12; ++hour) {
        for (int minute = 0; minute < 60; minute += minutesInterval) {
            const QString id = QString::number(result.size());
            const QString displayName = u"%1:%2"_s.arg(hour).arg(minute, 2, 10, u'0');
            result.append({ id, displayName, {}, hour, minute });
        }
    }
    return result;
}

// The notes with sharps and flats, or only the natural notes
QList<Item> notes(bool naturalOnly)
{
    static const char *const ids[] = {
        QT_TRANSLATE_NOOP("Notes", "C"),
        QT_TRANSLATE_NOOP("Notes", "C sharp"),
        QT_TRANSLATE_NOOP("Notes", "D flat"),
        QT_TRANSLATE_NOOP("Notes", "D"),
        QT_TRANSLATE_NOOP("Notes", "D sharp"),
        QT_TRANSLATE_NOOP("Notes", "E flat"),
        QT_TRANSLATE_NOOP("Notes", "E"),
        QT_TRANSLATE_NOOP("Notes", "F flat"),
        QT_TRANSLATE_NOOP("Notes", "E sharp"),
        QT_TRANSLATE_NOOP("Notes", "F"),
        QT_TRANSLATE_NOOP("Notes", "F sharp"),
        QT_TRANSLATE_NOOP("Notes", "G flat"),
        QT_TRANSLATE_NOOP("Notes", "G"),
        QT_TRANSLATE_NOOP("Notes", "G sharp"),
        QT_TRANSLATE_NOOP("Notes", "A flat"),
        QT_TRANSLATE_NOOP("Notes", "A"),
        QT_TRANSLATE_NOOP("Notes", "A sharp"),
        QT_TRANSLATE_NOOP("Notes", "B flat"),
        QT_TRANSLATE_NOOP("Notes", "B"),
        QT_TRANSLATE_NOOP("Notes", "C flat"),
    };
    QList<Item> result;
    for (const char *id : ids) {
        const QString idString = QString::fromLatin1(id);
        if (!naturalOnly || idString.size() == 1)
            result.append({ idString, QCoreApplication::translate("Notes", id) });
    }
    return result;
}

QList<Item> colors()
{
    static const struct {
        const char *id;
        const char *name;
    } colors[] = {
        { "#FF3030", QT_TRANSLATE_NOOP("Colors", "red") },
        { "#0AC00A", QT_TRANSLATE_NOOP("Colors", "green") },
        { "#3030FF", QT_TRANSLATE_NOOP("Colors", "blue") },
        { "#FAFAFA", QT_TRANSLATE_NOOP("Colors", "white") },
        { "#808080", QT_TRANSLATE_NOOP("Colors", "gray") },
        { "#000000", QT_TRANSLATE_NOOP("Colors", "black") },
        { "#FFE800", QT_TRANSLATE_NOOP("Colors", "yellow") },
        { "#FF8C00", QT_TRANSLATE_NOOP("Colors", "orange") },
        { "#905020", QT_TRANSLATE_NOOP("Colors", "brown") },
        { "#9F00FF", QT_TRANSLATE_NOOP("Colors", "violet") },
        { "#FFA0C0", QT_TRANSLATE_NOOP("Colors", "pink") },
    };
    QList<Item> result;
    for (const auto &color : colors)
        result.append({ QString::fromLatin1(color.id), QCoreApplication::translate("Colors", color.name) });
    return result;
}

// A random object that starts with the letter
QString firstLetterImageSource(const Item &item, int)
{
    return u"image://imageprovider/object/"_s + item.objectIds.at(randomIndex(item.objectIds.size()));
}

QString objectImageSource(const Item &item, int)
{
    return u"image://imageprovider/object/"_s + item.id;
}

// Fish, apples or balloons, depending on the exercise
QString quantityImageSource(const Item &item, int exerciseIndex)
{
    static constexpr QLatin1StringView countables[] = { "fish"_L1, "apple"_L1, "balloon"_L1 };
    return u"image://imageprovider/quantity/"_s + item.id + u'/'
            + countables[exerciseIndex % int(std::size(countables))];
}

QString clockImageSource(const Item &item, int exerciseIndex)
{
    return u"image://imageprovider/clock/%1/%2/%3"_s.arg(item.hour).arg(item.minute).arg(exerciseIndex);
}

QString notesImageSource(const Item &item, int)
{
    return u"image://imageprovider/notes/"_s + item.id;
}

QString colorImageSource(const Item &item, int exerciseIndex)
{
    return u"image://imageprovider/color/%1/%2"_s.arg(item.id).arg(exerciseIndex);
}

// Whether the previous exercise has the item at the same answer index
bool previousExerciseHasSameAnswer(const QList<Exercise> &exercises, int index, int answerIndex, int item)
{
    if (index < 1)
        return false;
    const Exercise &previous = exercises.at(index - 1);
    return previous.answerItems.value(answerIndex, -1) == item;
}

// Whether one of the previous exercises has the item as correct answer
bool previousExercisesHaveSameCorrectAnswer(const QList<Exercise> &exercises, int index, int previousCount, int item)
{
    for (int i = std::max(0, index - previousCount); i < index; ++i) {
        const Exercise &previous = exercises.at(i);
        if (previous.correctAnswerIndex >= 0 && previous.answerItems.at(previous.correctAnswerIndex) == item)
            return true;
    }
    return false;
}

// Makes an exercise from random items. No answer keeps its previous index, and the correct
// answer does not repeat for a while.
Exercise createExercise(const QList<Exercise> &exercises, int index, int answersCount,
                        const QList<Item> &items, ImageSourceFunction imageSource)
{
    Exercise exercise;
    exercise.correctAnswerIndex = randomIndex(answersCount);
    exercise.answerItems = QList<int>(answersCount, -1);

    const int uniqueCorrectAnswers = qRound(items.size() * 0.5);
    int correctItem;
    do {
        correctItem = randomIndex(items.size());
    } while (previousExerciseHasSameAnswer(exercises, index, exercise.correctAnswerIndex, correctItem)
             || previousExercisesHaveSameCorrectAnswer(exercises, index, uniqueCorrectAnswers, correctItem));
    exercise.answerItems[exercise.correctAnswerIndex] = correctItem;

    for (int answer = 0; answer < answersCount; ++answer) {
        if (answer == exercise.correctAnswerIndex)
            continue;
        int wrongItem;
        do {
            wrongItem = randomIndex(items.size());
        } while (wrongItem == correctItem
                 || previousExerciseHasSameAnswer(exercises, index, answer, wrongItem)
                 || exercise.answerItems.first(answer).contains(wrongItem));
        exercise.answerItems[answer] = wrongItem;
    }

    for (int item : std::as_const(exercise.answerItems)) {
        exercise.answerTexts.append(items.at(item).displayName);
        exercise.answerImageSources.append(imageSource(items.at(item), index));
    }
    exercise.imageSource = exercise.answerImageSources.at(exercise.correctAnswerIndex);
    return exercise;
}

} // namespace

Exercises::Exercises(QObject *parent)
    : QObject(parent)
{
    clear();
}

Exercises::Kind Exercises::kind() const
{
    return m_kind;
}

void Exercises::setKind(Kind kind)
{
    if (kind == m_kind)
        return;
    m_kind = kind;
    clear();
    emit kindChanged();
}

int Exercises::answersCount() const
{
    return m_answersCount;
}

void Exercises::setAnswersCount(int count)
{
    if (count == m_answersCount)
        return;
    m_answersCount = count;
    clear();
    emit answersCountChanged();
}

QString Exercises::imageSource(int index)
{
    return exercise(index).imageSource;
}

QString Exercises::answerText(int index, int answer)
{
    return exercise(index).answerTexts.value(answer);
}

QString Exercises::answerImageSource(int index, int answer)
{
    return exercise(index).answerImageSources.value(answer);
}

int Exercises::correctAnswerIndex(int index)
{
    return exercise(index).correctAnswerIndex;
}

void Exercises::prepare(int index)
{
    exercise(index);
}

const Exercise &Exercises::exercise(int index)
{
    static const Exercise invalid;
    if (index < 0)
        return invalid;
    index %= exercisesCount;
    if (m_exercises.at(index).correctAnswerIndex < 0)
        m_exercises[index] = createExercise(index, m_kind);
    return m_exercises.at(index);
}

Exercise Exercises::createExercise(int index, Kind kind) const
{
    static constexpr NumberRange countEasyRange = { 1, 5 };
    static constexpr NumberRange countHardRange = { 5, 20 };
    static constexpr NumberRange mixedMediumCountRange = { 4, 16 };
    static constexpr NumberRange mixedHardCountRange = { 8, 20 };

    // The mixed lessons take turns between other kinds of exercises, in the order of the steps.
    using Step = std::function<Exercise()>;
    const auto takeTurns = [index](std::initializer_list<Step> steps) {
        return std::data(steps)[index % int(steps.size())]();
    };

    switch (kind) {
    case FirstLetter:
        return ::createExercise(m_exercises, index, m_answersCount, firstLetters(), firstLetterImageSource);
    case NameTerms:
        return ::createExercise(m_exercises, index, m_answersCount, objects(), objectImageSource);
    case CountEasy:
        return createCountExercise(index, countEasyRange, false);
    case CountReadEasy:
        return createCountExercise(index, countEasyRange, true);
    case CountHard:
        return createCountExercise(index, countHardRange, false);
    case CountReadHard:
        return createCountExercise(index, countHardRange, true);
    case ClockEasy:
        return ::createExercise(m_exercises, index, m_answersCount, times(60), clockImageSource);
    case ClockMedium:
        return ::createExercise(m_exercises, index, m_answersCount, times(30), clockImageSource);
    case ClockHard:
        return ::createExercise(m_exercises, index, m_answersCount, times(5), clockImageSource);
    case NotesReadEasy:
        return ::createExercise(m_exercises, index, m_answersCount, notes(true), notesImageSource);
    case NotesReadHard:
        return ::createExercise(m_exercises, index, m_answersCount, notes(false), notesImageSource);
    case Color:
        return ::createExercise(m_exercises, index, m_answersCount, colors(), colorImageSource);
    case MixedEasy:
        return takeTurns({
            [&] { return createCountExercise(index, countEasyRange, false); },
            [&] { return createExercise(index, FirstLetter); },
            [&] { return createExercise(index, ClockEasy); },
            [&] { return createExercise(index, NotesReadEasy); },
        });
    case MixedMedium:
        return takeTurns({
            [&] { return createCountExercise(index, mixedMediumCountRange, false); },
            [&] { return createCountExercise(index, mixedMediumCountRange, true); },
            [&] { return createExercise(index, ClockMedium); },
            [&] { return createExercise(index, NotesReadEasy); },
            [&] { return createExercise(index, NameTerms); },
            [&] { return createExercise(index, Color); },
        });
    case MixedHard:
        return takeTurns({
            [&] { return createCountExercise(index, mixedHardCountRange, false); },
            [&] { return createExercise(index, ClockHard); },
            [&] { return createCountExercise(index, mixedHardCountRange, true); },
            [&] { return createExercise(index, NotesReadHard); },
            [&] { return createExercise(index, NameTerms); },
        });
    }
    Q_UNREACHABLE_RETURN({});
}

Exercise Exercises::createCountExercise(int index, NumberRange range, bool asWords) const
{
    return ::createExercise(m_exercises, index, m_answersCount, numbers(range.from, range.to, asWords),
                            quantityImageSource);
}

void Exercises::clear()
{
    m_exercises = QList<Exercise>(exercisesCount);
}
