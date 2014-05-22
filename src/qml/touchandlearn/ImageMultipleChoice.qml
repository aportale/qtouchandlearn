import QtQuick 2.2

Item {
    ListView {
        id: listview
        model: 100

        delegate: Item {
            id: delegate
            width: 100
            height: 100
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

    Item {
        property int exerciseIndex: listview.currentIndex
        onExerciseIndexChanged: {
            if (exerciseIndex >= 0)
                item.text = Date();
        }

        Item {
            id: item
            property string text

            onTextChanged: {
                contentChangeAnimation.complete();
                contentChangeAnimation.start();
            }

            SequentialAnimation {
                id: contentChangeAnimation
                ScaleAnimator {
                    target: item
                }
                ScriptAction {
                    script: { var foo = 1; }
                }
                ScaleAnimator {
                    target: item
                }
            }
        }
    }
}
