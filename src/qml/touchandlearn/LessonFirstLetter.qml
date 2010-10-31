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
    property alias answersPerChoiceCount: choice.answersCount
    property int choicesCount: 50
    signal closePressed
    id: nameTerms
    ImageMultipleChoice {
        id: choice
        width: parent.width
        height: parent.height
        backgroundImage: "image://imageprovider/background/background_01"
        exercisesModel: ListModel {
            id: listModel
            Component.onCompleted: createFirstLetterListModel()
        }
        onClosePressed: nameTerms.closePressed()
        answersColumsCount: 2
        answersCount: 4
        viewHeightRatio: 0.5
    }

    function imageSourceFunction(object, answerIndex) {
        var answerObjects = object.Objects;
        return "image://imageprovider/object/"
                + answerObjects[Math.floor(Math.random() * answerObjects.length)].Id;
    }

    function createFirstLetterListModel()
    {
        Database.populateMultipleChoiceModel(
                    listModel, Database.firstLetters(),
                    choicesCount, answersPerChoiceCount,
                    imageSourceFunction);
    }
}
