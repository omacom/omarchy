QT += core qml
QT -= gui
TEMPLATE = lib
CONFIG += plugin c++17 release
TARGET = shortcutsearch
HEADERS += search_model.h
SOURCES += search_model.cpp plugin.cpp
QMAKE_CXXFLAGS += -Wall -Wextra -Werror -pedantic
