find_package(Qt6 REQUIRED COMPONENTS Widgets Quick Svg)

qt_add_executable(tst_imageprovider
    test.cpp
    ../../src/imageprovider.cpp
    ../../src/imageprovider.h
    ../../src/graphics.qrc
)
set_target_properties(tst_imageprovider PROPERTIES AUTOMOC ON)
target_include_directories(tst_imageprovider PRIVATE ../../src)
target_link_libraries(tst_imageprovider PRIVATE Qt6::Widgets Qt6::Quick Qt6::Svg)
