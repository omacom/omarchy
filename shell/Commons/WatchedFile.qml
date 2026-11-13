import QtQuick
import Quickshell.Io

// A small local file's text, read synchronously on first use and on every
// change; bind to `text` as to FileView's text(). Every read is synchronous
// because FileView's reload() joins a background read already running, which
// would keep a deleted or replaced file's old contents. The watcher is separate
// and never reloaded: reload() reads and only then replaces its watcher, so a
// change landing between the two would be lost.
QtObject {
  id: root

  property string path: ""
  readonly property string text: reader.text()

  property FileView reader: FileView {
    path: root.path
    printErrors: false
    preload: false
    blockAllReads: true
  }

  property FileView watcher: FileView {
    path: root.path
    watchChanges: true
    printErrors: false
    preload: false
    onFileChanged: root.reader.reload()
  }
}
