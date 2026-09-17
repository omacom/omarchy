import QtQuick
import Quickshell
import Quickshell.Io
import "PluginRuntime.js" as Runtime

// Path and argv adaptation only. Ward independently admits every broker call;
// the trusted backend independently checks host-owned installation mode.
QtObject {
  id: root
  required property string pluginId
  property bool isolated: true
  property string bundlePath: "/plugin"
  property var admitted: null
  readonly property var grants: isolated ? admitted : Runtime.trustedGrants()
  readonly property string dataPath: isolated ? Quickshell.env("HOME")
    : Runtime.stateHome(Quickshell.env("HOME"), Quickshell.env("XDG_STATE_HOME")) + "/omarchy/plugins/" + pluginId
  readonly property string statePath: dataPath + "/.local/state"
  readonly property string cachePath: dataPath + "/.cache"
  readonly property string configPath: dataPath + "/.config"
  readonly property string runtimePath: isolated ? Quickshell.env("XDG_RUNTIME_DIR")
    : Quickshell.env("XDG_RUNTIME_DIR") + "/omarchy/plugins/" + pluginId

  function command(argv) {
    return (isolated ? ["/bootstrap"]
      : [Quickshell.env("OMARCHY_PATH") + "/bin/omarchy-plugin-runtime", pluginId]).concat(argv)
  }

  function localCommand(argv) {
    return isolated ? ["/runtime/bin/omarchy-plugin-run-local"].concat(argv)
      : command(["--json", "--local"].concat(argv))
  }

  // A loader's scope dies with its entry, not with the last view of a plugin.
  function scope(owner) {
    return Qt.createComponent(Qt.resolvedUrl("PluginRuntime.qml")).createObject(owner, {
      pluginId: pluginId, isolated: isolated, bundlePath: bundlePath,
      admitted: admitted
    })
  }

  function launch(argv, options, structured) {
    if (!Array.isArray(argv) || !argv.length || argv.some(arg => typeof arg !== "string"))
      throw new Error("Runtime commands require a nonempty string argv array")
    return jobComponent.createObject(root, {argv: argv, options: options || {}, structured: structured})
  }

  function runLocal(argv, options) { return launch(localCommand(argv), options, true) }

  function exec(name, argv, options) {
    if (typeof name !== "string" || !name || !Array.isArray(argv))
      throw new Error("exec requires a manifest command name and an argv array")
    return launch(command(["--json", "--exec", name].concat(argv)), options, true)
  }

  function notify(title, body, options) {
    return launch(command(["--json", "--notify", title, body]), options, true)
  }
  function openUrl(url, options) {
    const mode = options && options.mode ? options.mode : "browser"
    return launch(command(["--json", "--open-url", mode, url]), options, true)
  }
  function play(path, volume, options) {
    return runLocal(["omarchy-plugin-play", path, String(volume === undefined ? 1 : volume)], options)
  }
  function http(request, options) {
    const settings = Object.assign({}, options || {}, {stdin: JSON.stringify(request)})
    return launch(command(["--json", "--http"]), settings, true)
  }

  property Component jobComponent: Component { PluginJob {} }

  function filesystemPath(name) {
    return isolated && grants.filesystem[name] ? "/grants/" + name : ""
  }
}
