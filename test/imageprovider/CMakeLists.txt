find_package(Qt6 REQUIRED COMPONENTS Widgets Quick Svg)

qt_add_executable(tst_imageprovider
    test.cpp
    ../../src/imageprovider.cpp
    ../../src/imageprovider.h
)
qt_add_resources(tst_imageprovider graphics
    PREFIX "/"
    BASE ../../src
    FILES
        ../../src/data/graphics/particle.png
        ../../src/data/graphics/objects.svg
        ../../src/data/graphics/lessonicons.svg
        ../../src/data/graphics/notes.svg
        ../../src/data/graphics/design.svg
        ../../src/data/graphics/clocks.svg
        ../../src/data/graphics/countables.svg
)
set_target_properties(tst_imageprovider PROPERTIES AUTOMOC ON)
target_include_directories(tst_imageprovider PRIVATE ../../src)
target_link_libraries(tst_imageprovider PRIVATE Qt6::Widgets Qt6::Quick Qt6::Svg)
