import QtQuick

QtObject {
  enum Precision { Hours, Minutes, Seconds }
  property int precision: SystemClock.Seconds
  property date date: new Date()
}
