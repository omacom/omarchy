// Availability for explicitly trusted plugins without a sandbox declaration.
// Named resources belong exclusively to Ward, including sandbox-native YOLO.
function trustedGrants() {
  return {storage: true, network: true, networkProxy: false,
    notifications: true, audioPlayback: true, microphone: true, audioCapture: true,
    desktopGeometry: true, openUrls: true, filesystem: {}, http: {}, exec: {},
    media: null, settings: {read: [], write: []}}
}

function stateHome(home, state) { return state || home + "/.local/state" }
