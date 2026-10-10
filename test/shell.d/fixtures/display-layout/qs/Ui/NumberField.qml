import QtQuick
Item { implicitHeight: 30; implicitWidth: 100; property string label: ""; property int from: 1; property int to: 99; property int value: 1; signal modified(int value) }
