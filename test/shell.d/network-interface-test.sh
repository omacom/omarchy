#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const network = requireFromRoot('shell/plugins/panels/network/Model.js')
const wired = { type: 'ethernet', managed: true, connected: false, state: '', hasLink: false }
const wifi = { type: 'wifi', managed: true, connected: false, state: '' }

assertEqual(network.interfaceStatus(wired, true, ''), 'Cable unplugged', 'an unplugged NIC remains visible with its actual cable state')
assertEqual(network.interfaceStatus({ ...wired, hasLink: true }, true, ''), 'Disconnected', 'a disconnected NIC with carrier is not described as unplugged')
assertEqual(network.interfaceStatus({ ...wired, hasLink: true, connected: true }, true, ''), 'Connected', 'an active NIC reports its native state')
assertEqual(network.interfaceStatus(wifi, false, ''), 'Wi-Fi radio off', 'a disabled Wi-Fi radio is distinguished from a disconnected station')
assertEqual(network.interfaceStatus(wifi, true, ''), 'Disconnected', 'an enabled idle Wi-Fi station is disconnected')
assertEqual(network.interfaceStatus({ ...wifi, connected: true }, true, ''), 'Connected', 'a connected secondary Wi-Fi station remains connected while Ethernet carries the route')
assertEqual(network.interfaceStatus({ ...wired, managed: false }, true, ''), 'Not managed by NetworkManager', 'unmanaged interfaces do not claim a connection can be controlled')
assertEqual(network.interfaceStatus({ ...wifi, connected: true }, false, ''), 'Wi-Fi radio off', 'radio state takes precedence over a stale connected notification')
assertEqual(network.interfaceStatus({ ...wired, connected: true }, true, ''), 'Cable unplugged', 'carrier loss takes precedence over a stale connected notification')
assertEqual(network.interfaceStatus(wired, true, 'connect'), 'Connecting…', 'a pending connect never claims success')
assertEqual(network.interfaceStatus({ ...wired, connected: true, hasLink: true }, true, 'disconnect'), 'Disconnecting…', 'a pending disconnect never claims completion')
assertEqual(network.interfaceStatus(wired, true, 'configure'), 'Opening configuration…', 'configuration has a transient pending state even while unplugged')
assertEqual(network.interfaceStatus({ ...wifi, state: 'connecting' }, true, ''), 'Connecting…', 'native activation remains pending after an operation returns')
assertEqual(network.interfaceStatus({ ...wifi, connected: true, state: 'disconnecting' }, true, ''), 'Disconnecting…', 'native deactivation is not presented as connected')
JS
