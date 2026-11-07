import fs from "node:fs"
import os from "node:os"
import path from "node:path"

// OpenCode 2 refreshes custom theme files on SIGUSR2 in the TUI process.
// Never send an OS signal to the shared server: it has no theme listener.
export default {
  id: "omarchy-theme",
  setup() {
    const config = process.env.OPENCODE_CONFIG_DIR || path.join(process.env.XDG_CONFIG_HOME || path.join(os.homedir(), ".config"), "opencode")
    const dir = path.join(config, "themes")
    fs.mkdirSync(dir, { recursive: true })
    let pending
    const watcher = fs.watch(dir, () => {
      // Atomic replacements may report only a temporary filename. Re-read
      // through OpenCode's refresh handler after directory events settle.
      if (pending) clearTimeout(pending)
      pending = setTimeout(() => {
        pending = undefined
        process.emit("SIGUSR2")
      }, 250)
    })
    return () => {
      if (pending) clearTimeout(pending)
      watcher.close()
    }
  },
}
