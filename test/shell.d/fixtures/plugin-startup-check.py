#!/usr/bin/python3
"""Run production loader/status functions in a reduced, isolated QML host.

This exercises Qt compilation, service/widget loading and both IPC paths. It
neither starts the desktop shell nor establishes disk-cache invalidation.
"""
from pathlib import Path
import subprocess, os, re, shutil, time, json, sys
repo=Path(sys.argv[1])
out=Path(sys.argv[2])
out.mkdir(exist_ok=True)
runtime=out/"run"
runtime.mkdir(mode=0o700)
(out/"runtime-path").write_text(str(runtime))
config=out/"root"
config.mkdir(exist_ok=True)
(config/"Commons").mkdir(exist_ok=True)
for f in ["ShellIpc.qml","IpcRegistry.qml"]:
    shutil.copy2(repo/"shell/Commons"/f,config/"Commons"/f)
(config/"Commons/qmldir").write_text("module qs.Commons\nShellIpc 1.0 ShellIpc.qml\nsingleton IpcRegistry 1.0 IpcRegistry.qml\n")
(config/"services").mkdir(exist_ok=True)
for f in ["AuthServiceStore.js","BarWidgetRegistry.qml"]:
    shutil.copy2(repo/"shell/services"/f,config/"services"/f)
source=(repo/"shell/shell.qml").read_text()
methods=[]
for name in ["recordPluginLoadError","pluginStartupStatus","ensureService","setPluginWidgetComponent","loadPluginWidget"]:
    match=re.search(r"  function "+name+r"\([^\n]*\) \{[\s\S]*?\n  \}",source)
    if not match: raise RuntimeError("missing production method "+name)
    methods.append(match.group())
(config/"Good.qml").write_text("""import QtQuick
import qs.Commons
Item { ShellIpc { target: "representative"; function proof(): string { return "instantiated" } } }
""")
(config/"Bad.qml").write_text("import QtQuick\nItem { ShellIpc {} }\n")
qml="""import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import "services"
import "services/AuthServiceStore.js" as AuthServiceStore
ShellRoot {
  id: shell
  property bool defaultsLoaded: true
  property bool userConfigLoaded: true
  property bool pluginScanCompleted: true
  property bool pluginReloading: false
  property var bar: ({})
  property var _services: ({})
  property var pluginWidgetComponents: ({})
  property var pluginLoadErrors: ({})
  property string omarchyPath: Quickshell.shellDir
  property var observed: []
  property var widgetInstance: null
  Item { id: serviceHost }
  property BarWidgetRegistry barWidgetRegistry: BarWidgetRegistry {}
  property QtObject pluginRegistry: QtObject {
    property bool scanning: false
    property var disabled: []
    property var installedPlugins: ({
      "required": { __isFirstParty: true, kinds: ["service"], entryPoints: {service: "Bad.qml"} },
      "local": { __isFirstParty: false, kinds: ["service"], entryPoints: {service: "Bad.qml"} },
      "widget": { __isFirstParty: true, kinds: ["bar-widget"], entryPoints: {barWidget: "Good.qml"} },
      "optional": { __isFirstParty: true, kinds: ["bar-widget"], entryPoints: {barWidget: "Bad.qml"} }
    })
    function isEnabled(id) { return disabled.indexOf(id) === -1 }
    function inBar(id) { return id === "widget" }
    function entryPointUrl(m, kind) { return "file://" + Quickshell.shellDir + "/" + m.entryPoints[kind] }
    signal pluginLoadFailed(string id, string error)
  }
  function isAuthenticationService(m, id) { return false }
  function pluginShellFor(m) { return null }
  function pluginRegistryFor(m) { return null }
  function pluginBarWidgetRegistryFor(m) { return null }
  function publicPluginManifest(m) { return m }
METHODS
  Component.onCompleted: {
    observed.push(pluginStartupStatus())
    ensureService("required")
    ensureService("local")
    observed.push(pluginStartupStatus())
    pluginRegistry.disabled = ["required"]
    observed.push(pluginStartupStatus())
    loadPluginWidget("widget", "file://" + Quickshell.shellDir + "/Good.qml", {})
    observed.push(pluginStartupStatus())
  }
  Connections {
    target: shell.barWidgetRegistry
    function onChanged() {
      Qt.callLater(function() {
        var component = shell.pluginWidgetComponents.widget.component
        shell.widgetInstance = component.createObject(serviceHost)
        shell.observed.push(shell.pluginStartupStatus())
        console.log("FINAL_STATUS", JSON.stringify({observed: shell.observed,
          instantiated: !!shell.widgetInstance,
          ipc: IpcRegistry.call("representative", "proof", [])}))
      })
    }
  }
  IpcHandler { target: "control"; function status(): string { return JSON.stringify(shell.observed) } }
}
""".replace("METHODS","\n".join(methods))
(config/"shell.qml").write_text(qml)
env=dict(os.environ,HOME=str(out/"home"),XDG_CONFIG_HOME=str(out/"config"),XDG_CACHE_HOME=str(out/"cache"),
    XDG_STATE_HOME=str(out/"state"),XDG_DATA_HOME=str(out/"data"),XDG_RUNTIME_DIR=str(runtime),
    QT_QPA_PLATFORM="offscreen",QSG_RHI_BACKEND="software",QS_NO_RELOAD_POPUP="1",QS_DISABLE_FILE_WATCHER="1")
env.pop("WAYLAND_DISPLAY",None);env.pop("HYPRLAND_INSTANCE_SIGNATURE",None)
with (out/"runtime.log").open("w") as log:
    p=subprocess.Popen(["quickshell","-p",str(config),"--no-color"],env=env,stdout=log,stderr=subprocess.STDOUT)
    try:
        deadline=time.monotonic()+10
        report=None
        while time.monotonic()<deadline:
            text=(out/"runtime.log").read_text()
            matches=re.findall(r"FINAL_STATUS (.+)",text)
            if matches:
                report=json.loads(matches[-1]); break
            if p.poll() is not None: raise RuntimeError("runtime exited "+str(p.returncode))
            time.sleep(.03)
        if report is None: raise RuntimeError("no final status")
        states=[x["state"] for x in report["observed"]]
        assert states[0]=="loading", states
        assert states[1]=="failed", report
        assert any(x["id"]=="required" and "ShellIpc is not a type" in x["error"] for x in report["observed"][1]["errors"]),report
        assert states[-1]=="ready", report
        assert report["instantiated"] and report["ipc"]=={"ran":True,"output":"instantiated"},report
        assert report["observed"][-1]["warnings"][0]["id"]=="local",report
        external = subprocess.run(["quickshell", "ipc", "-p", str(config), "call", "representative", "proof"], env=env, text=True, capture_output=True, timeout=3)
        assert external.returncode == 0 and external.stdout.strip() == "instantiated", (external.returncode, external.stdout, external.stderr)
        report["externalIpc"] = external.stdout.strip()
        (out/"ipc-targets.txt").write_text(subprocess.check_output(["quickshell", "ipc", "-p", str(config), "show"], env=env, text=True, timeout=3))
        (out/"result.json").write_text(json.dumps(report,indent=2))
        print(json.dumps(report))
    finally:
        p.terminate()
        try:p.wait(timeout=5)
        except subprocess.TimeoutExpired:p.kill();p.wait(timeout=3)
