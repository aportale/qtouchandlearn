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

#pragma once

#include <QtCore/QList>
#include <QtCore/QObject>
#include <QtCore/QStringList>
#include <QtQml/QQmlEngine>

// One exercise of a lesson: an image, and the answers for it, of which one is correct.
struct Exercise
{
    QString imageSource;
    QStringList answerTexts;
    // The image of each answer, which a button shows after a wrong answer
    QStringList answerImageSources;
    int correctAnswerIndex = -1;
    // The indices of the answers in the list of items that the exercise was made from. The
    // following exercises use them to avoid repetitions.
    QList<int> answerItems;
};

// The exercises of a lesson. Each lesson screen has its own instance, which makes each
// exercise when it is first requested. The exercises repeat after a while: the index i and
// i + 100 refer to the same exercise.
//
// The functions return strings and numbers instead of an exercise value type, because
// qmlcachegen cannot compile the access to a value type that an invokable function returns:
// a QML type that derives from Exercises could shadow the function and return anything.
class Exercises : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(Kind kind READ kind WRITE setKind NOTIFY kindChanged FINAL)
    Q_PROPERTY(int answersCount READ answersCount WRITE setAnswersCount NOTIFY answersCountChanged FINAL)

public:
    enum Kind {
        FirstLetter,
        NameTerms,
        CountEasy,
        CountReadEasy,
        CountHard,
        CountReadHard,
        ClockEasy,
        ClockMedium,
        ClockHard,
        NotesReadEasy,
        NotesReadHard,
        Color,
        MixedEasy,
        MixedMedium,
        MixedHard
    };
    Q_ENUM(Kind)

    explicit Exercises(QObject *parent = nullptr);

    Kind kind() const;
    void setKind(Kind kind);
    int answersCount() const;
    void setAnswersCount(int count);

    Q_INVOKABLE QString imageSource(int index);
    Q_INVOKABLE QString answerText(int index, int answer);
    Q_INVOKABLE QString answerImageSource(int index, int answer);
    Q_INVOKABLE int correctAnswerIndex(int index);
    // Makes the exercise in advance, so that it is ready when it is needed
    Q_INVOKABLE void prepare(int index);

signals:
    void kindChanged();
    void answersCountChanged();

private:
    // The numbers from and to of a counting exercise
    struct NumberRange
    {
        int from;
        int to;
    };

    // Returns the exercise with the index, and makes it if it does not exist yet
    const Exercise &exercise(int index);
    Exercise createExercise(int index, Kind kind) const;
    Exercise createCountExercise(int index, NumberRange range, bool asWords) const;
    void clear();

    QList<Exercise> m_exercises;
    Kind m_kind = NameTerms;
    int m_answersCount = 3;
};
