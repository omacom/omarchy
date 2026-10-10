QT += core qml testlib
QT -= gui
TEMPLATE = app
CONFIG += console c++17 release
TARGET = verify-search
HEADERS += search_model.h
SOURCES += search_model.cpp verify.cpp
QMAKE_CXXFLAGS += -Wall -Wextra -Werror -pedantic
sanitize {
  QMAKE_CXXFLAGS += -fsanitize=address,undefined -fno-omit-frame-pointer -g
  QMAKE_LFLAGS += -fsanitize=address,undefined
}
