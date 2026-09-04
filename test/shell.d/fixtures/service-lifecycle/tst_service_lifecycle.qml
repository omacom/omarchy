import QtQuick
import QtTest
import "services"
import "services/AuthServiceStore.js" as AuthServiceStore

Item {
  id: shell
  width: 1
  height: 1

  property string omarchyPath: "/test/omarchy"
  property var barWidgetRegistry: ({})
  property bool pluginReloading: false
  property var destroyedServices: []
  property var replacement: null
  property var constructionHook: function() {}
  property var injectionHook: function() {}
  property QtObject pluginRegistry: QtObject {
    property var installedPlugins: ({})
    function isEnabled(id) { return !!installedPlugins[id] }
    function entryPointUrl(manifest, kind) { return String(Qt.resolvedUrl(manifest.entryPoints[kind])) }
    // No clone aliasing in these fixtures; every id already names itself.
    function resolveEnabledId(id) { return id }
  }

  Item {
    id: serviceHost
    function serviceConstructed() { shell.constructionHook() }
    function serviceDestroyed(name) { shell.destroyedServices.push(name) }
  }
  function serviceInjected() { injectionHook() }

  // PRODUCTION_SERVICE_LOADER

  TestCase {
    name: "ServiceLifecycle"
    when: windowShown

    function install(file) {
      // First-party so pluginShellFor/pluginRegistryFor/pluginBarWidgetRegistryFor/
      // publicPluginManifest take their identity short-circuit instead of the
      // scoped-plugin-API path, which needs real QML Components this isolated
      // fixture cannot resolve. That wrapping is orthogonal to the
      // load-ownership behavior under test here.
      var manifest = { id: "test", kinds: ["service"], entryPoints: { service: file }, __isFirstParty: true }
      shell.pluginRegistry.installedPlugins = { test: manifest }
      return manifest
    }

    function init() {
      shell.constructionHook = function() {}
      shell.injectionHook = function() {}
      shell.unloadPluginServices()
      wait(0)
      shell.destroyedServices = []
      shell.replacement = null
      shell.pluginRegistry.installedPlugins = ({})
    }

    function cleanup() {
      shell.unloadPluginServices()
      wait(0)
    }

    function replaceService() {
      shell.unloadPluginServices()
      install("Service.qml")
      shell.replacement = shell.ensureService("test")
    }

    function test_component_cleanup_preserves_created_service() {
      var manifest = install("Service.qml")
      var inst = shell.ensureService("test")
      verify(inst !== null)
      compare(inst.manifest, manifest)
      compare(inst.shell, shell)
      compare(inst.omarchyPath, shell.omarchyPath)
      // Component.destroy() is deferred by Qt; cross an event-loop turn before
      // asserting that destroying the factory did not destroy its instance.
      wait(10)
      compare(shell.serviceFor("test"), inst)
      compare(inst.objectName, "service")
      compare(shell.destroyedServices.length, 0)
      compare(inst.observedHostPath, "/test/omarchy")
      shell.omarchyPath = "/test/updated-omarchy"
      compare(inst.observedHostPath, "/test/updated-omarchy")
      shell.omarchyPath = "/test/omarchy"
      shell.unloadPluginServices()
      wait(10)
      compare(shell.destroyedServices.length, 1)
      compare(shell.destroyedServices[0], "service")
    }

    function test_release_disconnects_real_status_signal() {
      var comp = Qt.createComponent("Service.qml", Component.PreferSynchronous)
      compare(comp.status, Component.Ready)
      var calls = 0
      var callback = function() { calls++ }
      comp.statusChanged.connect(callback)
      comp.statusChanged(comp.status)
      compare(calls, 1)
      var load = { component: comp, finalize: callback, connected: true, done: false }
      shell._serviceLoads = { test: load }
      shell._releaseServiceLoad("test", load)
      comp.statusChanged(comp.status)
      compare(calls, 1)
      wait(0)
      compare(Object.keys(shell._serviceLoads).length, 0)
    }

    function test_reload_from_component_completion_preserves_replacement() {
      install("ConstructorReload.qml")
      shell.constructionHook = replaceService
      shell.ensureService("test")
      verify(shell.replacement !== null)
      wait(10)
      compare(shell.serviceFor("test"), shell.replacement)
      compare(shell.replacement.objectName, "service")
      compare(shell.destroyedServices.length, 1)
      compare(shell.destroyedServices[0], "constructor")
    }

    function test_reload_from_property_change_preserves_replacement() {
      install("InjectionReload.qml")
      shell.injectionHook = replaceService
      shell.ensureService("test")
      verify(shell.replacement !== null)
      wait(10)
      compare(shell.serviceFor("test"), shell.replacement)
      compare(shell.replacement.objectName, "service")
      compare(shell.destroyedServices.length, 1)
      compare(shell.destroyedServices[0], "injection")
    }
  }
}
