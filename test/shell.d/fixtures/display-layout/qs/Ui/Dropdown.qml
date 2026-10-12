import QtQuick
Item { implicitHeight: 30; implicitWidth: 100; property var options: []; property string value: ""; property bool showLabel: true; signal changed(string value) }
