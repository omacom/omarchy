import QtQuick

// Record the real BackgroundVideo play/pause calls without decoding media or
// creating an audio client. Native enums stay imported by BackgroundVideo.
QtObject {
  property url source: ""
  property var videoOutput: null
  property var audioOutput: null
  property int loops: 0
  property bool autoPlay: false
  property bool hasVideo: true
  property bool hasAudio: false
  property int mediaStatus: 0
  property bool playing: false
  property int plays: 0
  property int pauses: 0
  function play() { playing = true; plays++ }
  function pause() { playing = false; pauses++ }
  Component.onCompleted: { if (autoPlay) play() }
}
