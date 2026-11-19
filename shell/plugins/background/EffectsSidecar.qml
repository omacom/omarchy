import Quickshell.Io
import QtQuick
import "EffectsModel.js" as EffectsModel

// The sidecar of the still on screen, read once for every screen, so a
// mistake in it is logged once however many monitors show it.
FileView {
  id: root

  // The still on screen, or "" while a video plays.
  property string background: ""
  // Bumped on every background change. A theme switch can put a different
  // still under the same staged path, so the sidecar is read again even when
  // its path stays the same.
  property int version: 0
  property var effects: ({})

  path: EffectsModel.sidecarPath(background)
  // Authors tune positions by editing the file; the effects follow.
  watchChanges: true
  printErrors: false
  onFileChanged: reload()
  onLoaded: {
    var parsed = EffectsModel.parse(text())
    for (var i = 0; i < parsed.warnings.length; i++) console.warn("background", path, parsed.warnings[i])
    effects = parsed.effects
  }
  onLoadFailed: effects = ({})
  // The last still's effects must not show on the next one while its sidecar
  // loads, or when it has none.
  onPathChanged: effects = ({})
  onVersionChanged: if (path) reload()
}
