pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Every ShellIpc handler, so the shell can answer an omarchy-shell call over
// its own socket instead of through a qs ipc client started per call. It
// answers only what qs ipc would: the first live, enabled handler for a
// target, and only the functions that handler declares. Those are allowed by
// name, never inferred from what a function call happens to reach: QObject
// methods such as destroy() are callable but not enumerable.
Singleton {
  id: root

  property var handlers: []

  // A bare handler's own functions (signals and hooks such as targetChanged),
  // which qs ipc never exposes and neither may the socket.
  readonly property var builtins: functionNames(bareHandler)

  IpcHandler {
    id: bareHandler
    enabled: false
  }

  function functionNames(object) {
    var names = []
    for (var key in object) {
      if (typeof object[key] === "function") names.push(key)
    }
    return names
  }

  function register(handler) {
    if (handlers.indexOf(handler) === -1) handlers.push(handler)
  }

  function unregister(handler) {
    var index = handlers.indexOf(handler)
    if (index !== -1) handlers.splice(index, 1)
  }

  function handlerFor(target) {
    for (var i = 0; i < handlers.length; i++) {
      var handler = handlers[i]
      if (handler && handler.enabled && handler.target === target) return handler
    }
    return null
  }

  // { ran: true, output } once the function ran; { ran: false } when it did
  // not (unknown target or function, wrong argument count), so the caller
  // can ask qs ipc for its exact answer without running anything twice.
  // The functions a handler declares: what it enumerates beyond a bare
  // handler, less property change signals.
  function declaredFunctions(handler) {
    return functionNames(handler).filter(function(name) {
      return builtins.indexOf(name) === -1 && !/Changed$/.test(name)
    })
  }

  function call(target, method, args) {
    var handler = handlerFor(target)
    if (!handler) return { ran: false }
    if (declaredFunctions(handler).indexOf(method) === -1) return { ran: false }
    if (handler[method].length !== args.length) return { ran: false }

    var result
    try {
      result = handler[method].apply(handler, args)
    } catch (error) {
      console.warn("ipc " + target + " " + method + " failed: " + error)
      return { ran: true, output: "" }
    }
    return { ran: true, output: result === undefined || result === null ? "" : String(result) }
  }
}
