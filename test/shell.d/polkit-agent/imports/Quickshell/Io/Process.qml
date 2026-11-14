import QtQuick

// Never starts anything: the tests answer for the lid and the sensor themselves.
QtObject {
  property var command
  property bool running
  property var stdout
  property var stderr
  signal exited(int exitCode)
}
