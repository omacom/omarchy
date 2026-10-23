pragma Singleton
import QtQuick

// A plugin-local singleton has no host QObject parent or public shell service
// entry. Every monitor shares its requests without publishing authentication
// controls through the host's service map or its object tree.
Service {
  id: root
  property var _clients: []
  available: _clients.length > 0
  panelOpen: _clients.some(function(client) { return client.opened })
  settings: {
    var interval = 3600
    for (var i = 0; i < _clients.length; i++) {
      var client = _clients[i]
      if (!client.opened) continue
      var value = parseInt(String(client.settings.refreshIntervalSec), 10)
      interval = Math.min(interval, isFinite(value) ? Math.max(30, Math.min(3600, value)) : 300)
    }
    return { refreshIntervalSec: interval }
  }

  function attach(client) {
    if (_clients.indexOf(client) === -1) _clients = _clients.concat([client])
  }

  function detach(client) {
    _clients = _clients.filter(function(existing) { return existing !== client })
  }
}
