#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const serviceQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')
const lockViewQml = fs.readFileSync(path.join(root, 'shell/plugins/lock/LockView.qml'), 'utf8')
const setup = fs.readFileSync(path.join(root, 'bin/omarchy-setup-security-face'), 'utf8')
const remove = fs.readFileSync(path.join(root, 'bin/omarchy-remove-security-face'), 'utf8')
const menu = fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8')

assert(
  /config: "omarchy-lock-face"/.test(serviceQml),
  'lock service has a dedicated omarchy-lock-face PamContext'
)
assert(
  /root\.startFace\(false\)/.test(serviceQml),
  'face auth starts when the session lock becomes secure'
)
assert(
  /facelock is-enrolled --quiet/.test(serviceQml),
  'face affordance is gated on facelock is-enrolled --quiet'
)
assert(
  /abort_if_ssh = false/.test(setup),
  'setup disables abort_if_ssh so Quickshell PamContext can open the camera'
)
assert(
  /ReadWritePaths=\/etc\/facelock/.test(setup),
  'setup lets the sandboxed daemon write encryption keys under /etc/facelock'
)
assert(
  /--service omarchy-lock-face/.test(setup) && /--service omarchy-lock-face/.test(remove),
  'setup and removal wire the omarchy-lock-face PAM service'
)
assert(
  /setup\.security\.face/.test(menu) && /remove\.security\.face/.test(menu),
  'the Omarchy menu exposes Setup and Remove Face Unlock'
)
assert(
  /signal submitFace\(\)/.test(lockViewQml),
  'empty Enter on the lock field can start a face scan'
)
assert(
  /objectName: "faceIndicator"/.test(lockViewQml),
  'the lock field shows a face indicator when enrolled'
)
JS
