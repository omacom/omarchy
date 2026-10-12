pragma Singleton
import QtQuick
QtObject { function space(n) {return n}
 property int normalBorderWidth: 1; property int cornerRadius: 2; property var font: ({family:"monospace",caption:12,body:14}); function selectedFillFor(a,b){return "lightblue"}
function hoverFillFor(a,b){return "gray"}
function controlFill(){return "white"}
function hoverStateColor(){return "black"}
property var spacing: ({controlHeight:30,popupRowHeight:30,dropdownWidth:100,huge:20,labelGap:2,controlPaddingX:8,md:8,controlGap:8,xxs:2,hairline:1}) }
