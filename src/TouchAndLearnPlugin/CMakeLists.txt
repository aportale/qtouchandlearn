find_package(Qt6 REQUIRED COMPONENTS Qml Quick Svg)

add_library(TouchAndLearnPlugin MODULE
    ../imageprovider.cpp
    ../imageprovider.h
    touchandlearnplugin.cpp
    touchandlearnplugin.h
)
set_target_properties(TouchAndLearnPlugin PROPERTIES
    AUTOMOC ON
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/TouchAndLearn
)
target_include_directories(TouchAndLearnPlugin PRIVATE ..)
target_link_libraries(TouchAndLearnPlugin PRIVATE Qt6::Qml Qt6::Quick Qt6::Svg)
configure_file(TouchAndLearn/qmldir ${CMAKE_CURRENT_BINARY_DIR}/TouchAndLearn/qmldir COPYONLY)
