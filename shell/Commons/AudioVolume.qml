pragma Singleton
import QtQuick
import Quickshell
import "AudioVolumeModel.js" as Model

// Output volume on the linear or decibel scale (see AudioVolumeModel.js),
// shared by the audio panel and the media keys. A singleton rather than a
// relative import, so cloned copies of those plugins still find it.
Singleton {
  readonly property real floor: Model.floor

  function scale(config) { return Model.scale(config) }
  function position(volume, scale) { return Model.position(volume, scale) }
  function volume(position, scale) { return Model.volume(position, scale) }
  function step(volume, steps, scale, precise) { return Model.step(volume, steps, scale, precise) }
  function readout(volume, scale) { return Model.readout(volume, scale, I18n.t, I18n.formatNumber) }
}
