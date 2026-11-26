find_package(Qt6 REQUIRED COMPONENTS Test)
add_executable(fingerprint-test test.cpp)
target_link_libraries(fingerprint-test PRIVATE fingerprint-core Qt6::Test)
qt_add_resources(fingerprint-test ui PREFIX "/" BASE ".." FILES "../Main.qml" "../Fingerprint.qml")
qt_add_resources(fingerprint-test messages PREFIX "/i18n" BASE "../../../default/i18n/en" FILES "../../../default/i18n/en/cli.json")
add_test(NAME fingerprint COMMAND dbus-run-session -- bash
  "${CMAKE_CURRENT_SOURCE_DIR}/private-bus.sh" "$<TARGET_FILE:fingerprint-test>")
