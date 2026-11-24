cmake_minimum_required(VERSION 3.25)
project(touchandlearn VERSION 1.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.11 REQUIRED COMPONENTS Core Gui Qml Quick Svg LinguistTools)
qt_standard_project_setup(REQUIRES 6.11)

# Default: ON if Qt Multimedia is installed. Without it, the app is mute.
# WebAssembly lacks Qt Multimedia and uses the Web Audio API instead.
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

# main.cpp loads the .qm files from the resources. update_translations updates the .ts files.
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
    target_sources(touchandlearn PRIVATE touchandlearn.rc)
endif()

# Our own HTML page runs full screen from the iOS Home Screen and blends in with the Safari bars.
# Qt's default files would overwrite it, so copy only the loader and logo. Qt Creator opens
# touchandlearn.html, a web server index.html.
if(EMSCRIPTEN)
    set_target_properties(touchandlearn PROPERTIES NO_WASM_DEFAULT_FILES TRUE)
    configure_file(wasm/index.html ${CMAKE_CURRENT_BINARY_DIR}/touchandlearn.html COPYONLY)
    configure_file(wasm/index.html ${CMAKE_CURRENT_BINARY_DIR}/index.html COPYONLY)
    configure_file(${QT6_INSTALL_PREFIX}/plugins/platforms/qtloader.js
        ${CMAKE_CURRENT_BINARY_DIR}/qtloader.js COPYONLY)
    configure_file(${QT6_INSTALL_PREFIX}/plugins/platforms/qtlogo.svg
        ${CMAKE_CURRENT_BINARY_DIR}/qtlogo.svg COPYONLY)
endif()

include(GNUInstallDirs)
install(TARGETS touchandlearn
    BUNDLE DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Installs the Qt libraries, plugins and QML modules on Windows, macOS and Linux. The other
# platforms deploy when packaging. The app shows no texts of Qt, so no Qt translations, and
# needs no QML debugging, TLS or network information plugins (excluded on Windows and Linux).
qt_generate_deploy_qml_app_script(
    TARGET touchandlearn
    OUTPUT_SCRIPT deploy_script
    NO_UNSUPPORTED_PLATFORM_ERROR
    NO_TRANSLATIONS
    EXCLUDE_PLUGIN_TYPES qmltooling tls networkinformation
)
install(SCRIPT ${deploy_script})

# Optional pieces. Default: ON, except in cross builds, whose tests cannot run on the build machine.
if(CMAKE_CROSSCOMPILING)
    set(build_tests_default OFF)
else()
    set(build_tests_default ON)
endif()
option(TOUCHANDLEARN_BUILD_TESTS "Build the tests and the image viewer" ${build_tests_default})
if(TOUCHANDLEARN_BUILD_TESTS)
    enable_testing()
    add_subdirectory(../test/imageprovider test_imageprovider)
    add_subdirectory(../test/imageviewer test_imageviewer)
endif()
