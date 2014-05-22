import QtQuick 2.2

Item {
    id: main

    ListView {
        id: listview
        anchors.fill: parent
        orientation: ListView.Horizontal
        model: 100000

        delegate: Item {
            id: delegate
            width: listview.width // Must not be parent.height/width since those are 0 in the beginning
            height: listview.height
            Text {
                // Hand-centered in order to avoid non-integer image coordinates.
                property int _leftMargin: (delegate.width - width) / 2
                property int _topMargin:(delegate.height - height) / 2
                text: modelData
            }
        }
    }

    Timer {
        onTriggered: listview.incrementCurrentIndex()
        interval: 500
        running: true
    }

    Timer {
        onTriggered: {
            stage.source = (stage.source + "").indexOf("LessonClockEasy.qml") >= 0 ? "LessonClockMedium.qml" : "LessonClockEasy.qml";
        }
        interval: 800
        running: true
    }

    AnswerChoice {
        id: choice
        exerciseIndex: listview.currentIndex
    }
}
