cmake_minimum_required(VERSION 3.16)
project(touchandlearn VERSION 1.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.11 REQUIRED COMPONENTS Core Gui Qml Quick Svg LinguistTools)
qt_standard_project_setup(REQUIRES 6.11)

# Qt Multimedia plays the sounds. Qt for WebAssembly lacks it, so the default there is OFF,
# and the app plays the sounds with the Web Audio API instead. On the other platforms, the
# default is ON if Qt Multimedia is installed. Without it, the app builds and stays mute.
if(EMSCRIPTEN)
    set(use_qtmultimedia_default OFF)
else()
    find_package(Qt6 QUIET OPTIONAL_COMPONENTS Multimedia)
    if(TARGET Qt6::Multimedia)
        set(use_qtmultimedia_default ON)
    else()
        set(use_qtmultimedia_default OFF)
    endif()
endif()
option(TOUCHANDLEARN_USE_QTMULTIMEDIA "Play the sounds with Qt Multimedia" ${use_qtmultimedia_default})

if(TOUCHANDLEARN_USE_QTMULTIMEDIA)
    # Fails with an error if the option was turned on, but Qt Multimedia is missing.
    find_package(Qt6 REQUIRED COMPONENTS Multimedia)
elseif(NOT EMSCRIPTEN)
    message(STATUS "Building without Qt Multimedia. The app will be mute.")
endif()

qt_add_executable(touchandlearn
    main.cpp
    imageprovider.cpp
    imageprovider.h
)

add_subdirectory(TouchAndLearn)

target_link_libraries(touchandlearn PRIVATE
    touchandlearn_qmlplugin
    Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::Svg
)

if(TOUCHANDLEARN_USE_QTMULTIMEDIA)
    target_compile_definitions(touchandlearn PRIVATE TOUCHANDLEARN_USE_QTMULTIMEDIA)
endif()

# lrelease builds the .qm files, and main.cpp loads them from the resources.
# Build the update_translations target to update the .ts files with lupdate.
qt_add_translations(touchandlearn
    SOURCE_TARGETS touchandlearn_qml
    TS_FILES
        ../originaldata/ts/de.ts
        ../originaldata/ts/en_GB.ts
        ../originaldata/ts/en_US.ts
        ../originaldata/ts/fi.ts
        ../originaldata/ts/it.ts
    RESOURCE_PREFIX /qt/qml/TouchAndLearn/data/translations
    LUPDATE_OPTIONS -no-obsolete -locations none
    LRELEASE_OPTIONS -nounfinished -removeidentical
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
option(TOUCHANDLEARN_BUILD_TESTS "Build test programs" OFF)
if(TOUCHANDLEARN_BUILD_TESTS)
    add_subdirectory(../test/imageprovider test_imageprovider)
    add_subdirectory(../test/renderspeed test_renderspeed)
endif()
