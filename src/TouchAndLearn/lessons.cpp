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

#include "lessons.h"

#include <QtCore/QCoreApplication>
#include <QtCore/QSettings>

#include <algorithm>

using namespace Qt::StringLiterals;

static QString lessonSettingsKey(const QString &groupId)
{
    return u"LessonOfGroup/"_s + groupId;
}

static bool containsLesson(const QList<MenuEntry> &lessons, const QString &lesson)
{
    return std::ranges::any_of(lessons, [&lesson](const MenuEntry &entry) { return entry.id == lesson; });
}

Lessons::Lessons(QObject *parent)
    : QObject(parent)
{
    // The translation contexts of the former database.js keep the existing translations valid.
    const QString robot = QCoreApplication::translate("Objects", "robot");
    const QString three = QCoreApplication::translate("Numbers", "three");
    const QString nine = QCoreApplication::translate("Numbers", "nine");
    const QString a = QCoreApplication::translate("Notes", "A");
    const QString aSharp = QCoreApplication::translate("Notes", "A sharp");
    const QString blue = QCoreApplication::translate("Colors", "blue");

    // Each group starts with its default lesson as the current one.
    m_groups = {
        { { u"Read"_s, QCoreApplication::translate("LessonMenu", "Read"), robot }, {
            { u"FirstLetter"_s, QCoreApplication::translate("LessonMenu", "Read the first letter"), robot.left(1) },
            { u"NameTerms"_s, QCoreApplication::translate("LessonMenu", "Read words"), robot },
        }, u"NameTerms"_s },
        { { u"Count"_s, QCoreApplication::translate("LessonMenu", "Count"), u"3"_s }, {
            { u"CountEasy"_s, QCoreApplication::translate("LessonMenu", "Count to 5"), u"3"_s },
            { u"CountReadEasy"_s, QCoreApplication::translate("LessonMenu", "Count and read to 5"), three },
            { u"CountHard"_s, QCoreApplication::translate("LessonMenu", "Count to 20"), u"9"_s },
            { u"CountReadHard"_s, QCoreApplication::translate("LessonMenu", "Count and read to 20"), nine },
        }, u"CountEasy"_s },
        { { u"Clock"_s, QCoreApplication::translate("LessonMenu", "Clock"), u"5:00"_s }, {
            { u"ClockEasy"_s, QCoreApplication::translate("LessonMenu", "Read the clock, full hours"), u"5:00"_s },
            { u"ClockMedium"_s, QCoreApplication::translate("LessonMenu", "Read the clock, half hours"), u"8:30"_s },
            { u"ClockHard"_s, QCoreApplication::translate("LessonMenu", "Read the clock"), u"1:20"_s },
        }, u"ClockMedium"_s },
        { { u"Music"_s, QCoreApplication::translate("LessonMenu", "Music"), a }, {
            { u"NotesReadEasy"_s, QCoreApplication::translate("LessonMenu", "Read notes, whole step"), a },
            { u"NotesReadHard"_s, QCoreApplication::translate("LessonMenu", "Read notes, half-step"), aSharp },
        }, u"NotesReadHard"_s },
        { { u"Color"_s, QCoreApplication::translate("LessonMenu", "Color"), blue }, {
            { u"ColorEasy"_s, QCoreApplication::translate("LessonMenu", "Recognize the color"), blue },
        }, u"ColorEasy"_s },
        { { u"Mixed"_s, QCoreApplication::translate("LessonMenu", "Mixed"), u"?"_s }, {
            { u"MixedEasy"_s, QCoreApplication::translate("LessonMenu", "Mixed lessons, easy"), u"?"_s },
            { u"MixedMedium"_s, QCoreApplication::translate("LessonMenu", "Mixed lessons, medium"), u"??"_s },
            { u"MixedHard"_s, QCoreApplication::translate("LessonMenu", "Mixed lessons, hard"), u"???"_s },
        }, u"MixedEasy"_s },
    };

    const QSettings settings;
    for (Group &group : m_groups) {
        const QString lesson = settings.value(lessonSettingsKey(group.entry.id)).toString();
        if (containsLesson(group.lessons, lesson))
            group.currentLesson = lesson;
    }
}

// One member of each entry, like all ids
static QStringList values(const QList<MenuEntry> &entries, QString MenuEntry::*member)
{
    QStringList result(entries.size());
    std::ranges::transform(entries, result.begin(), member);
    return result;
}

QList<MenuEntry> Lessons::groupEntries() const
{
    QList<MenuEntry> result;
    for (const Group &group : m_groups)
        result.append(group.entry);
    return result;
}

QStringList Lessons::groupIds() const
{
    return values(groupEntries(), &MenuEntry::id);
}

QStringList Lessons::groupDisplayNames() const
{
    return values(groupEntries(), &MenuEntry::displayName);
}

QStringList Lessons::groupImageLabels() const
{
    return values(groupEntries(), &MenuEntry::imageLabel);
}

int Lessons::currentGroup() const
{
    return m_currentGroup;
}

void Lessons::setCurrentGroup(int index)
{
    if (index == m_currentGroup || index < 0 || index >= m_groups.size())
        return;
    const QString previousLesson = currentLesson();
    m_currentGroup = index;
    emit currentGroupChanged();
    if (currentLesson() != previousLesson)
        emit currentLessonChanged();
}

QStringList Lessons::lessonIds() const
{
    return values(m_groups.at(m_currentGroup).lessons, &MenuEntry::id);
}

QStringList Lessons::lessonDisplayNames() const
{
    return values(m_groups.at(m_currentGroup).lessons, &MenuEntry::displayName);
}

QStringList Lessons::lessonImageLabels() const
{
    return values(m_groups.at(m_currentGroup).lessons, &MenuEntry::imageLabel);
}

QString Lessons::currentLesson() const
{
    return m_groups.at(m_currentGroup).currentLesson;
}

void Lessons::setCurrentLesson(const QString &lesson)
{
    Group &group = m_groups[m_currentGroup];
    if (lesson == group.currentLesson)
        return;
    if (!containsLesson(group.lessons, lesson)) {
        qWarning("Lessons: the group %s has no lesson %s", qPrintable(group.entry.id), qPrintable(lesson));
        return;
    }
    group.currentLesson = lesson;
    QSettings().setValue(lessonSettingsKey(group.entry.id), lesson);
    emit currentLessonChanged();
}
