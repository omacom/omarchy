// Qt may retain a nameless placeholder when the last Wayland output vanishes.
// Only a loss after seeing a real output arms recovery.
function initialState() {
  return { seen: false, pending: false, connected: false }
}

function update(state, names) {
  var connected = names.some(function(name) { return String(name || "").trim().length > 0 })
  return {
    seen: state.seen || connected,
    pending: state.pending || (state.seen && !connected),
    connected: connected
  }
}
