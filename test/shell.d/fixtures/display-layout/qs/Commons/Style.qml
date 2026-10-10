pragma Singleton
import QtQuick
QtObject { function space(n) {return n}
 property int normalBorderWidth: 1; property int cornerRadius: 2; property var font: ({family:"monospace",caption:12,body:14}); function selectedFillFor(a,b){return "lightblue"}
function hoverFillFor(a,b){return "gray"} }
