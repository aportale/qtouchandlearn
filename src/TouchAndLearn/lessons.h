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
#include <QtCore/QString>
#include <QtCore/QStringList>
#include <QtQml/QQmlEngine>

// A lesson group in the lesson menu, or a lesson in the lesson options. The menus show the
// icon of id, the imageLabel on the icon, and the displayName.
struct MenuEntry
{
    QString id;
    QString displayName;
    QString imageLabel;
};

// The Lessons singleton in QML. It holds the lesson groups and their lessons. Each group has a
// current lesson, which the settings store.
//
// The groups and lessons are string lists with one entry per group or lesson, instead of lists
// of a value type, because qmlcachegen cannot compile the access to a list of a value type.
class Lessons : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(QStringList groupIds READ groupIds CONSTANT FINAL)
    Q_PROPERTY(QStringList groupDisplayNames READ groupDisplayNames CONSTANT FINAL)
    Q_PROPERTY(QStringList groupImageLabels READ groupImageLabels CONSTANT FINAL)
    // The index of the group that the lesson menu selected last
    Q_PROPERTY(int currentGroup READ currentGroup WRITE setCurrentGroup NOTIFY currentGroupChanged FINAL)
    // The lessons of the current group
    Q_PROPERTY(QStringList lessonIds READ lessonIds NOTIFY currentGroupChanged FINAL)
    Q_PROPERTY(QStringList lessonDisplayNames READ lessonDisplayNames NOTIFY currentGroupChanged FINAL)
    Q_PROPERTY(QStringList lessonImageLabels READ lessonImageLabels NOTIFY currentGroupChanged FINAL)
    // The id of the current lesson of the current group
    Q_PROPERTY(QString currentLesson READ currentLesson WRITE setCurrentLesson NOTIFY currentLessonChanged FINAL)

public:
    explicit Lessons(QObject *parent = nullptr);

    QStringList groupIds() const;
    QStringList groupDisplayNames() const;
    QStringList groupImageLabels() const;
    int currentGroup() const;
    void setCurrentGroup(int index);
    QStringList lessonIds() const;
    QStringList lessonDisplayNames() const;
    QStringList lessonImageLabels() const;
    QString currentLesson() const;
    void setCurrentLesson(const QString &lesson);

signals:
    void currentGroupChanged();
    void currentLessonChanged();

private:
    QList<MenuEntry> groupEntries() const;

    struct Group
    {
        MenuEntry entry;
        QList<MenuEntry> lessons;
        QString currentLesson;
    };

    QList<Group> m_groups;
    int m_currentGroup = 4;
};
