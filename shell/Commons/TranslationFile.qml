import QtQuick
import Quickshell.Io

// Keep watches independent of synchronous reads. FileView.reload() rebuilds
// its own watcher after notifying readers. Watch the directory as well as the
// file: atomic replacement detaches the inode watch, and a deletion before
// it is reattached must still clear the cached text.
FileView {
  id: root

  preload: false
  blockAllReads: true
  printErrors: false

  readonly property FileView watcher: FileView {
    path: root.path
    preload: false
    watchChanges: true
    printErrors: false
    onFileChanged: root.reload()
  }

  readonly property FileView directoryWatcher: FileView {
    path: root.path === "" ? "" : (root.path.slice(0, root.path.lastIndexOf("/") + 1) || ".")
    preload: false
    watchChanges: true
    printErrors: false
    onFileChanged: root.reload()
  }
}
