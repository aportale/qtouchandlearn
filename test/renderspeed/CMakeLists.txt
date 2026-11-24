find_package(Qt6 REQUIRED COMPONENTS Test Quick Svg)

qt_add_executable(tst_renderspeed
    tst_renderspeedtest.cpp
    ../../src/imageprovider.cpp
    ../../src/imageprovider.h
)
qt_add_resources(tst_renderspeed graphics
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
set_target_properties(tst_renderspeed PROPERTIES AUTOMOC ON)
target_include_directories(tst_renderspeed PRIVATE ../../src)
target_link_libraries(tst_renderspeed PRIVATE Qt6::Test Qt6::Quick Qt6::Svg)
