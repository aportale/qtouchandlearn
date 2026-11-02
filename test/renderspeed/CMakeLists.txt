find_package(Qt6 REQUIRED COMPONENTS Test Quick Svg)

qt_add_executable(tst_renderspeed
    tst_renderspeedtest.cpp
    ../../src/imageprovider.cpp
    ../../src/imageprovider.h
)
set_target_properties(tst_renderspeed PROPERTIES AUTOMOC ON)
target_include_directories(tst_renderspeed PRIVATE ../../src)
target_compile_definitions(tst_renderspeed PRIVATE
    SRCDIR="${CMAKE_CURRENT_SOURCE_DIR}/../../src/data")
target_link_libraries(tst_renderspeed PRIVATE Qt6::Test Qt6::Quick Qt6::Svg)
