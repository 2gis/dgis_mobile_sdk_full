set(PROJECT_NAME dgis_mobile_sdk_full)
set(AURORA_PLUGIN_NAME dgis_mobile_sdk_full_platform_plugin)
set(DGIS_LIBRARY_NAME dgis_c_bindings_linux)

project(${PROJECT_NAME} LANGUAGES CXX)

add_library(${AURORA_PLUGIN_NAME} SHARED)

target_sources(${AURORA_PLUGIN_NAME}
    PRIVATE
        ${CMAKE_CURRENT_LIST_DIR}/include/dgis_mobile_sdk_full/dgis_mobile_sdk_plugin_full.h
        ${CMAKE_CURRENT_LIST_DIR}/dgis_mobile_sdk_plugin_full.cpp
)

target_include_directories(${AURORA_PLUGIN_NAME}
    PUBLIC
        ${CMAKE_CURRENT_LIST_DIR}/include
)

find_package(PkgConfig REQUIRED)
find_package(Qt5 COMPONENTS Core REQUIRED)
pkg_check_modules(FlutterEmbedder REQUIRED IMPORTED_TARGET flutter-embedder)

target_link_libraries(${AURORA_PLUGIN_NAME} PUBLIC Qt5::Core)
target_link_libraries(${AURORA_PLUGIN_NAME} PUBLIC PkgConfig::FlutterEmbedder)

target_compile_definitions(${AURORA_PLUGIN_NAME} PRIVATE PLUGIN_IMPL)

target_compile_options(${AURORA_PLUGIN_NAME} PRIVATE
    -Werror
    -Wall
    -Wextra
    -Wconversion
    -Wsign-conversion
    -Wmissing-declarations
    -Wnon-virtual-dtor
    -Wold-style-cast
    -Woverloaded-virtual
    -Wno-error=deprecated-declarations
    -Wno-error=cpp
)

add_library(${DGIS_LIBRARY_NAME} SHARED IMPORTED)
set_target_properties(${DGIS_LIBRARY_NAME} PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_LIST_DIR}/data/lib/${CMAKE_SYSTEM_PROCESSOR}/libdgis_c_bindings_linux.so)
target_include_directories(${DGIS_LIBRARY_NAME} INTERFACE ${CMAKE_CURRENT_LIST_DIR}/data/include)
target_link_libraries(${AURORA_PLUGIN_NAME} PRIVATE ${DGIS_LIBRARY_NAME})