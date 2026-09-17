cmake_minimum_required(VERSION 3.24)
project(omarchy_plugin_view LANGUAGES CXX)
find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick OpenGL)
qt_standard_project_setup()
qt_policy(SET QTP0001 NEW)
set(CMAKE_CXX_STANDARD 17)
set(RUST_TARGET_DIR "" CACHE PATH "Cargo target directory built with qt-bridge")
set(RUST_PROFILE "debug" CACHE STRING "Cargo build profile directory (debug or release)")
if(NOT EXISTS "${RUST_TARGET_DIR}/${RUST_PROFILE}/libomarchy_ward.a")
  message(FATAL_ERROR "Build Cargo with --features qt-bridge and set RUST_TARGET_DIR")
endif()
qt_add_qml_module(omarchy_plugin_view SHARED URI Omarchy.Ward VERSION 1.0
  OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/Omarchy/Ward
  SOURCES pluginview.hpp pluginview.cpp pluginsession.hpp pluginsession.cpp)
target_include_directories(omarchy_plugin_view PRIVATE "${RUST_TARGET_DIR}/cxxbridge")
target_link_libraries(omarchy_plugin_view PRIVATE Qt6::Quick Qt6::OpenGL EGL gbm
  "${RUST_TARGET_DIR}/${RUST_PROFILE}/libomarchy_ward.a" dl pthread m)
target_compile_options(omarchy_plugin_view PRIVATE -Wall -Wextra -Werror)
set_target_properties(omarchy_plugin_viewplugin PROPERTIES INSTALL_RPATH "$ORIGIN")
install(TARGETS omarchy_plugin_view omarchy_plugin_viewplugin
  LIBRARY DESTINATION lib/qml/Omarchy/Ward)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/Omarchy/Ward/qmldir
  ${CMAKE_CURRENT_BINARY_DIR}/Omarchy/Ward/omarchy_plugin_view.qmltypes
  DESTINATION lib/qml/Omarchy/Ward)
install(PROGRAMS "${RUST_TARGET_DIR}/${RUST_PROFILE}/omarchy-ward" DESTINATION lib)
