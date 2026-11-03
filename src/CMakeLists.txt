cmake_minimum_required(VERSION 3.16)
project(touchandlearn VERSION 1.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick Svg Multimedia)

qt_add_executable(touchandlearn
    main.cpp
    imageprovider.cpp
    imageprovider.h
    settings.cpp
    settings.h
)

qt_add_resources(touchandlearn audio
    PREFIX "/"
    FILES
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

qt_add_resources(touchandlearn graphics
    PREFIX "/"
    FILES
        data/graphics/particle.png
        data/graphics/objects.svg
        data/graphics/lessonicons.svg
        data/graphics/notes.svg
        data/graphics/design.svg
        data/graphics/clocks.svg
        data/graphics/countables.svg
)

qt_add_resources(touchandlearn qml
    PREFIX "/"
    FILES
        qml/touchandlearn/AnswerButton.qml
        qml/touchandlearn/AnswerChoice.qml
        qml/touchandlearn/database.js
        qml/touchandlearn/Feedback.qml
        qml/touchandlearn/ImageMultipleChoice.qml
        qml/touchandlearn/ImageView.qml
        qml/touchandlearn/LessonClockEasy.qml
        qml/touchandlearn/LessonClockHard.qml
        qml/touchandlearn/LessonClockMedium.qml
        qml/touchandlearn/LessonColorEasy.qml
        qml/touchandlearn/LessonCountEasy.qml
        qml/touchandlearn/LessonCountHard.qml
        qml/touchandlearn/LessonCountReadEasy.qml
        qml/touchandlearn/LessonCountReadHard.qml
        qml/touchandlearn/LessonFirstLetter.qml
        qml/touchandlearn/LessonMenu.qml
        qml/touchandlearn/LessonMixedEasy.qml
        qml/touchandlearn/LessonMixedHard.qml
        qml/touchandlearn/LessonMixedMedium.qml
        qml/touchandlearn/LessonNameTerms.qml
        qml/touchandlearn/LessonNotesReadEasy.qml
        qml/touchandlearn/LessonNotesReadHard.qml
        qml/touchandlearn/LessonOptions.qml
        qml/touchandlearn/main.qml
        qml/touchandlearn/MainMenu.qml
        qml/touchandlearn/VolumeDisplay.qml
        qml/touchandlearn/Particles.qml
)

qt_add_resources(touchandlearn translations
    PREFIX "/"
    FILES
        data/translations/it.qm
        data/translations/fi.qm
        data/translations/en_US.qm
        data/translations/en_GB.qm
        data/translations/de.qm
)

target_link_libraries(touchandlearn PRIVATE
    Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::Svg Qt6::Multimedia
)

if(APPLE)
    set_target_properties(touchandlearn PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_ICON_FILE touchandlearn.icns
    )
    target_sources(touchandlearn PRIVATE touchandlearn.icns)
    set_source_files_properties(touchandlearn.icns PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
endif()

if(IOS)
    file(GLOB ios_icons ${CMAKE_CURRENT_SOURCE_DIR}/ios/AppIcon*.png)
    target_sources(touchandlearn PRIVATE ${ios_icons})
    set_source_files_properties(${ios_icons} PROPERTIES MACOSX_PACKAGE_LOCATION "")
    set_target_properties(touchandlearn PROPERTIES
        MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/ios/Info.plist
    )
endif()

if(ANDROID)
    set_target_properties(touchandlearn PROPERTIES
        QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android
    )
endif()

if(WIN32)
    set_target_properties(touchandlearn PROPERTIES WIN32_EXECUTABLE TRUE)
endif()

include(GNUInstallDirs)
install(TARGETS touchandlearn
    BUNDLE DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Optional pieces
option(TOUCHANDLEARN_BUILD_PLUGIN "Build QML plugin" OFF)
option(TOUCHANDLEARN_BUILD_TESTS "Build test programs" OFF)
if(TOUCHANDLEARN_BUILD_PLUGIN)
    add_subdirectory(TouchAndLearnPlugin)
endif()
if(TOUCHANDLEARN_BUILD_TESTS)
    add_subdirectory(../test/imageprovider test_imageprovider)
    add_subdirectory(../test/renderspeed test_renderspeed)
endif()
