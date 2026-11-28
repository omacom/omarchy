cmake_minimum_required(VERSION 3.21)
project(omarchy_ttfx_qml LANGUAGES CXX)

# The Omarchy.Ttfx QML module: TtfxLogo, the TTFX engine's logo animation as a
# Qt Quick item that draws on the CPU (Qt Quick's software backend included).
# It links the Rust engine in native/plymouth-ttfx-engine statically, built
# offline from its vendored crates.

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick Qml)
find_package(Threads REQUIRED)
qt_standard_project_setup(REQUIRES 6.5)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(TTFX_ENGINE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../plymouth-ttfx-engine")
set(TTFX_CARGO_TARGET_DIR "${CMAKE_CURRENT_BINARY_DIR}/cargo")
set(TTFX_ENGINE_LIB "${TTFX_CARGO_TARGET_DIR}/plymouth/libttfx_plymouth.a")
find_program(CARGO cargo REQUIRED)

# Cargo runs on every build and decides itself what to rebuild, so a change
# anywhere in the engine or its vendored crates reaches the module. Cargo finds
# .cargo/config.toml, which points it at the vendored crates, from its working
# directory, not from --manifest-path.
add_custom_target(ttfx_engine_build
  COMMAND "${CARGO}" build --locked --offline --lib --profile plymouth
          --manifest-path "${TTFX_ENGINE_DIR}/Cargo.toml" --target-dir "${TTFX_CARGO_TARGET_DIR}"
  WORKING_DIRECTORY "${TTFX_ENGINE_DIR}"
  BYPRODUCTS "${TTFX_ENGINE_LIB}"
  COMMENT "Building the TTFX engine"
  USES_TERMINAL)

add_library(ttfx_engine STATIC IMPORTED)
set_target_properties(ttfx_engine PROPERTIES
  IMPORTED_LOCATION "${TTFX_ENGINE_LIB}"
  INTERFACE_INCLUDE_DIRECTORIES "${TTFX_ENGINE_DIR}/include")
add_dependencies(ttfx_engine ttfx_engine_build)

# The backing target is the plugin: one shared object next to its qmldir.
qt_add_qml_module(ttfxqml
  URI Omarchy.Ttfx
  VERSION 1.0
  PLUGIN_TARGET ttfxqml
  OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/qml/Omarchy/Ttfx"
  SOURCES ttfxlogo.cpp ttfxlogo.h)

target_link_libraries(ttfxqml PRIVATE Qt6::Quick ttfx_engine Threads::Threads ${CMAKE_DL_LIBS} m)
# Keep the engine's symbols to the plugin.
target_link_options(ttfxqml PRIVATE "LINKER:--exclude-libs,ALL" "LINKER:-z,relro" "LINKER:-z,now")
target_compile_options(ttfxqml PRIVATE -Wall -Wextra)

# Installed at Qt's own QML path, where Quickshell finds it, and where the boot
# splash's initcpio hook copies it from (etc/initcpio/install/omarchy-splash).
if(NOT DEFINED TTFX_QML_INSTALL_DIR)
  set(TTFX_QML_INSTALL_DIR "${QT6_INSTALL_QML}/Omarchy/Ttfx")
endif()
install(TARGETS ttfxqml LIBRARY DESTINATION "${TTFX_QML_INSTALL_DIR}")
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/qml/Omarchy/Ttfx/qmldir" DESTINATION "${TTFX_QML_INSTALL_DIR}")

option(TTFX_QML_TESTS "Build the smoke test (tests/run.sh)" OFF)
if(TTFX_QML_TESTS)
  qt_add_executable(ttfx-qml-smoke tests/smoke.cpp)
  target_link_libraries(ttfx-qml-smoke PRIVATE Qt6::Quick Qt6::Qml)
  add_dependencies(ttfx-qml-smoke ttfxqml)
endif()
