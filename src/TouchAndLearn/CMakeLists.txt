qt_add_library(touchandlearn_qml STATIC)
qt_add_qml_module(touchandlearn_qml
    URI TouchAndLearn
    VERSION 1.0
    SOURCES
        settings.cpp
        settings.h
    QML_FILES
        AnswerButton.qml
        AnswerChoice.qml
        database.js
        Feedback.qml
        ImageMultipleChoice.qml
        ImageView.qml
        LessonClockEasy.qml
        LessonClockHard.qml
        LessonClockMedium.qml
        LessonColorEasy.qml
        LessonCountEasy.qml
        LessonCountHard.qml
        LessonCountReadEasy.qml
        LessonCountReadHard.qml
        LessonFirstLetter.qml
        LessonMenu.qml
        LessonMixedEasy.qml
        LessonMixedHard.qml
        LessonMixedMedium.qml
        LessonNameTerms.qml
        LessonNotesReadEasy.qml
        LessonNotesReadHard.qml
        LessonOptions.qml
        Main.qml
        MainMenu.qml
        StageScreen.qml
        VolumeDisplay.qml
        Particles.qml
    RESOURCES
        data/audio/incorrectanswer_04.wav
        data/audio/incorrectanswer_03.wav
        data/audio/incorrectanswer_02.wav
        data/audio/incorrectanswer_01.wav
        data/audio/correctanswer_05.wav
        data/audio/correctanswer_04.wav
        data/audio/correctanswer_03.wav
        data/audio/correctanswer_02.wav
        data/audio/correctanswer_01.wav
        data/graphics/particle.png
        data/graphics/objects.svg
        data/graphics/lessonicons.svg
        data/graphics/notes.svg
        data/graphics/design.svg
        data/graphics/clocks.svg
        data/graphics/countables.svg
)

target_link_libraries(touchandlearn_qml PRIVATE
    Qt6::Quick Qt6::Multimedia
)
