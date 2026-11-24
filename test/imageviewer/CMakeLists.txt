find_package(Qt6 REQUIRED COMPONENTS Widgets Quick Svg)

qt_add_executable(imageviewer
    test.cpp
    ../../src/imageprovider.cpp
    ../../src/imageprovider.h
)
qt_add_resources(imageviewer graphics
    PREFIX "/qt/qml/TouchAndLearn"
    BASE ../../src/TouchAndLearn
    FILES
        ../../src/TouchAndLearn/data/graphics/particle.png
        ../../src/TouchAndLearn/data/graphics/objects.svg
        ../../src/TouchAndLearn/data/graphics/lessonicons.svg
        ../../src/TouchAndLearn/data/graphics/notes.svg
        ../../src/TouchAndLearn/data/graphics/design.svg
        ../../src/TouchAndLearn/data/graphics/clocks.svg
        ../../src/TouchAndLearn/data/graphics/countables.svg
)
set_target_properties(imageviewer PROPERTIES AUTOMOC ON)
target_include_directories(imageviewer PRIVATE ../../src)
target_link_libraries(imageviewer PRIVATE Qt6::Widgets Qt6::Quick Qt6::Svg)
