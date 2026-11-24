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

static QString lessonSettingsKey(const QString &groupId)
{
    return QLatin1String("LessonOfGroup/") + groupId;
}

static bool containsLesson(const QList<MenuEntry> &lessons, const QString &lesson)
{
    return std::any_of(lessons.cbegin(), lessons.cend(),
                       [&lesson](const MenuEntry &entry) { return entry.id == lesson; });
}

static MenuEntry menuEntry(const QString &id, const QString &displayName, const QString &imageLabel)
{
    MenuEntry entry;
    entry.id = id;
    entry.displayName = displayName;
    entry.imageLabel = imageLabel;
    return entry;
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
        { menuEntry("Read", QCoreApplication::translate("LessonMenu", "Read"), robot), {
            menuEntry("FirstLetter", QCoreApplication::translate("LessonMenu", "Read the first letter"), robot.left(1)),
            menuEntry("NameTerms", QCoreApplication::translate("LessonMenu", "Read words"), robot),
        }, "NameTerms" },
        { menuEntry("Count", QCoreApplication::translate("LessonMenu", "Count"), "3"), {
            menuEntry("CountEasy", QCoreApplication::translate("LessonMenu", "Count to 5"), "3"),
            menuEntry("CountReadEasy", QCoreApplication::translate("LessonMenu", "Count and read to 5"), three),
            menuEntry("CountHard", QCoreApplication::translate("LessonMenu", "Count to 20"), "9"),
            menuEntry("CountReadHard", QCoreApplication::translate("LessonMenu", "Count and read to 20"), nine),
        }, "CountEasy" },
        { menuEntry("Clock", QCoreApplication::translate("LessonMenu", "Clock"), "5:00"), {
            menuEntry("ClockEasy", QCoreApplication::translate("LessonMenu", "Read the clock, full hours"), "5:00"),
            menuEntry("ClockMedium", QCoreApplication::translate("LessonMenu", "Read the clock, half hours"), "8:30"),
            menuEntry("ClockHard", QCoreApplication::translate("LessonMenu", "Read the clock"), "1:20"),
        }, "ClockMedium" },
        { menuEntry("Music", QCoreApplication::translate("LessonMenu", "Music"), a), {
            menuEntry("NotesReadEasy", QCoreApplication::translate("LessonMenu", "Read notes, whole step"), a),
            menuEntry("NotesReadHard", QCoreApplication::translate("LessonMenu", "Read notes, half-step"), aSharp),
        }, "NotesReadHard" },
        { menuEntry("Color", QCoreApplication::translate("LessonMenu", "Color"), blue), {
            menuEntry("ColorEasy", QCoreApplication::translate("LessonMenu", "Recognize the color"), blue),
        }, "ColorEasy" },
        { menuEntry("Mixed", QCoreApplication::translate("LessonMenu", "Mixed"), "?"), {
            menuEntry("MixedEasy", QCoreApplication::translate("LessonMenu", "Mixed lessons, easy"), "?"),
            menuEntry("MixedMedium", QCoreApplication::translate("LessonMenu", "Mixed lessons, medium"), "??"),
            menuEntry("MixedHard", QCoreApplication::translate("LessonMenu", "Mixed lessons, hard"), "???"),
        }, "MixedEasy" },
    };

    const QSettings settings;
    for (Group &group : m_groups) {
        const QString lesson = settings.value(lessonSettingsKey(group.entry.id)).toString();
        if (containsLesson(group.lessons, lesson))
            group.currentLesson = lesson;
    }
}

static QStringList ids(const QList<MenuEntry> &entries)
{
    QStringList result;
    for (const MenuEntry &entry : entries)
        result.append(entry.id);
    return result;
}

static QStringList displayNames(const QList<MenuEntry> &entries)
{
    QStringList result;
    for (const MenuEntry &entry : entries)
        result.append(entry.displayName);
    return result;
}

static QStringList imageLabels(const QList<MenuEntry> &entries)
{
    QStringList result;
    for (const MenuEntry &entry : entries)
        result.append(entry.imageLabel);
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
    return ids(groupEntries());
}

QStringList Lessons::groupDisplayNames() const
{
    return displayNames(groupEntries());
}

QStringList Lessons::groupImageLabels() const
{
    return imageLabels(groupEntries());
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
    return ids(m_groups.at(m_currentGroup).lessons);
}

QStringList Lessons::lessonDisplayNames() const
{
    return displayNames(m_groups.at(m_currentGroup).lessons);
}

QStringList Lessons::lessonImageLabels() const
{
    return imageLabels(m_groups.at(m_currentGroup).lessons);
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
