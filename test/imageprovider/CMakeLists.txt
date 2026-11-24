find_package(Qt6 REQUIRED COMPONENTS Test Quick Svg)

qt_add_executable(tst_imageprovider
    tst_imageprovider.cpp
    ../../src/imageprovider.cpp
    ../../src/imageprovider.h
)
qt_add_resources(tst_imageprovider graphics
    PREFIX "/qt/qml/TouchAndLearn"
    BASE ../../src/TouchAndLearn
    FILES
        ../../src/TouchAndLearn/data/graphics/objects.svg
        ../../src/TouchAndLearn/data/graphics/lessonicons.svg
        ../../src/TouchAndLearn/data/graphics/notes.svg
        ../../src/TouchAndLearn/data/graphics/design.svg
        ../../src/TouchAndLearn/data/graphics/clocks.svg
        ../../src/TouchAndLearn/data/graphics/countables.svg
)
# A console program, so that the test output is visible
set_target_properties(tst_imageprovider PROPERTIES WIN32_EXECUTABLE FALSE MACOSX_BUNDLE FALSE)
target_include_directories(tst_imageprovider PRIVATE ../../src)
target_link_libraries(tst_imageprovider PRIVATE Qt6::Test Qt6::Quick Qt6::Svg)

add_test(NAME tst_imageprovider COMMAND tst_imageprovider)
# Without a console, QtTest on Windows writes to the debugger output, unless forced to stdout.
set_tests_properties(tst_imageprovider PROPERTIES
    ENVIRONMENT "QT_QPA_PLATFORM=offscreen;QT_FORCE_STDERR_LOGGING=1")
if(WIN32)
    # Finds the Qt DLLs also outside of Qt Creator
    set_property(TEST tst_imageprovider PROPERTY ENVIRONMENT_MODIFICATION
        "PATH=path_list_prepend:$<TARGET_FILE_DIR:Qt6::Core>")
endif()
