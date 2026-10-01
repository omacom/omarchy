import QtQuick
import Quickshell
import Quickshell.Io
import "services"

ShellRoot {
  id: shell
  property string userConfigPath: Quickshell.env("HOME") + "/.config/omarchy/shell.json"
  property var builtinShellConfig: ({ version: 1, plugins: [] })
  property var defaultsConfig: builtinShellConfig
  property var shellConfig: builtinShellConfig
  property var util: ({
    isPlainObject: function(value) { return value && typeof value === "object" && !Array.isArray(value) },
    canonicalWidgetId: function(value) { return value }
  })

  ShellConfigStore { id: shellConfigStore; path: shell.userConfigPath }
  // Intentionally unwatched: the mutation must not depend on ingestion.
  FileView { id: userConfigFile; path: shell.userConfigPath; blockAllReads: true; blockWrites: true }
  FileView { id: externalWriter; path: shell.userConfigPath; blockWrites: true }

  Component.onCompleted: shellConfig = JSON.parse(userConfigFile.text())

  // The test runner injects the real shell mutation functions here.
  // MUTATION_FUNCTIONS

  IpcHandler {
    target: "config-test"
    function mutate(): string {
      return JSON.stringify({ ok: shell.mutateShellConfig(function(config) {
        config.bar = config.bar || {}
        config.bar.position = "bottom"
      }), config: shell.shellConfig, error: shellConfigStore.lastError })
    }
    function inline(): string {
      return JSON.stringify({ ok: shell.updateEntryInline("example.service", { enabled: true }),
        config: shell.shellConfig, error: shellConfigStore.lastError })
    }
    function conflict(): string {
      return JSON.stringify({ ok: shell.mutateShellConfig(function(config) {
        externalWriter.setText('{"version":1,"external":"during mutation"}\n')
        config.overwrite = true
      }), config: shell.shellConfig, error: shellConfigStore.lastError })
    }
    function throwing(): string {
      return JSON.stringify({ ok: shell.mutateShellConfig(function(config) { throw new Error("cancel") }),
        config: shell.shellConfig, error: shellConfigStore.lastError })
    }
    function noop(): string {
      return JSON.stringify({ ok: shell.mutateShellConfig(function(config) { return false }),
        config: shell.shellConfig, error: shellConfigStore.lastError })
    }
  }
}
