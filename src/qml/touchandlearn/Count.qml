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
    signal closePressed
    property int rangeFrom: 1
    property int rangeTo: 20
    property int choicesCount: 50
    property bool numbersAsWords: false
    property alias answersPerChoiceCount: choice.answersCount
    property alias viewHeightRatio: choice.viewHeightRatio
    property alias showCorrectionImageOnButton: choice.showCorrectionImageOnButton
    property alias answersColumsCount: choice.answersColumsCount
    property alias exitButtonVisible: choice.exitButtonVisible

    id: nameQuantities
    ImageMultipleChoice {
        id: choice
        width: parent.width
        height: parent.height
        backgroundImage: "image://imageprovider/background/background_01"
        exercisesModel: ListModel {
            id: listModel
            Component.onCompleted: createQuantitiesModel()
        }
        imageSizeFactor: 0.95
        onClosePressed: nameQuantities.closePressed()
        answersCount: answersPerChoiceCount
        showCorrectionImageOnButton: false
    }

    function createQuantitiesModel()
    {
        var numbers = Database.numbers(rangeFrom, rangeTo);
        if (!numbersAsWords)
            for (var i = 0; i < numbers.length; ++i)
                numbers[i].DisplayName = String(numbers[i].Id);
        var itemTypes = ["fish", "apple"];
        Database.populateMultipleChoiceModel(
                    listModel, numbers,
                    choicesCount, answersPerChoiceCount,
                    function (object, answerIndex) { // imageSourceFunction
                        return "image://imageprovider/quantity/" + object.Id + "/"
                                + itemTypes[answerIndex % itemTypes.length];
                    });
    }
}
