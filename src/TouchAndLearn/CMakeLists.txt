qt_add_library(touchandlearn_qml STATIC)
qt_add_qml_module(touchandlearn_qml
    URI TouchAndLearn
    VERSION 1.0
    SOURCES
        answersounds.cpp
        answersounds.h
        color.cpp
        color.h
        exercises.cpp
        exercises.h
        lessons.cpp
        lessons.h
    QML_FILES
        AnswerButton.qml
        AnswerChoice.qml
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
        data/graphics/particle.png
        data/graphics/objects.svg
        data/graphics/lessonicons.svg
        data/graphics/notes.svg
        data/graphics/design.svg
        data/graphics/clocks.svg
        data/graphics/countables.svg
)

target_link_libraries(touchandlearn_qml PRIVATE
    Qt6::Quick
)

# qmlsc (commercial Qt Quick Compiler Extensions) replaces qmlcachegen and has these two modes.
if(TARGET Qt6::qmlsc)
    # Static mode skips the checks for QML properties that shadow C++ properties.
    # Never shadow a base type property, or qmlsc generates invalid code.
    set_property(TARGET touchandlearn_qml APPEND PROPERTY QT_QMLCACHEGEN_ARGUMENTS --static)

    # Direct mode calls the C++ types directly, mostly via private headers, so link the private
    # modules of all C++ types used in QML. A Qt update can break this, hence the silenced warning.
    set(QT_NO_PRIVATE_MODULE_WARNING ON)
    find_package(Qt6 REQUIRED COMPONENTS QmlPrivate QuickPrivate QuickParticlesPrivate)
    target_link_libraries(touchandlearn_qml PRIVATE
        Qt6::QmlPrivate
        Qt6::QuickPrivate
        Qt6::QuickParticlesPrivate
    )
    set_property(TARGET touchandlearn_qml APPEND PROPERTY QT_QMLCACHEGEN_ARGUMENTS --direct-calls)
endif()

if(TOUCHANDLEARN_USE_QTMULTIMEDIA)
    target_link_libraries(touchandlearn_qml PRIVATE Qt6::Multimedia)
    target_compile_definitions(touchandlearn_qml PRIVATE TOUCHANDLEARN_USE_QTMULTIMEDIA)
endif()

# The sounds are needed only if Qt Multimedia or, on WebAssembly, the Web Audio API plays them.
if(TOUCHANDLEARN_USE_QTMULTIMEDIA OR EMSCRIPTEN)
    qt_target_qml_sources(touchandlearn_qml
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
    )
endif()
