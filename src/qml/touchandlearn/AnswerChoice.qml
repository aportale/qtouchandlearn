import QtQuick 2.2

Item {
    property int exerciseIndex

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
