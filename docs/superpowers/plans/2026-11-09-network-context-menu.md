# Network Context Menu (Modify / Forget) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Right-clicking a Wi-Fi row in the `omarchy.network` panel opens a context menu offering Connect/Disconnect, Modify Network…, and Forget Network; Modify opens a native in-panel editor that reads and writes the saved NetworkManager profile.

**Architecture:** A new reusable `qs.Ui/ContextMenu.qml` popup; the network `Panel.qml` gains right-click handling on `NetworkRow` and a second content view (the editor) reached from the menu. All profile resolution, diffing, validation, and `nmcli` argv building live as pure functions in `Model.js` (Node-testable), so the QML stays thin. Secrets go through `nmcli connection edit` over stdin, never argv.

**Tech Stack:** QML / Quickshell (Qt 6), NetworkManager via `nmcli`, Node for `Model.js` unit tests, the omarchy shell test harness (`test/shell`).

**Spec:** `~/Projects/omarchy-network-context-menu/docs/superpowers/specs/2026-11-09-network-context-menu-design.md` (copy it into the checkout at `docs/superpowers/specs/` when starting, so it travels with the branch).

## Global Constraints

- Work off a source checkout of `https://github.com/omacom/omarchy` (default branch `quattro`). Never edit `/usr/share/omarchy` in place — it is package-owned.
- After any QML change run `omarchy-restart-shell`.
- A panel built on `KeyboardPanel` passes its card as `content: PanelKeyCatcher { … }`; ids inside are invisible outside — expose with `property alias` on the content root and read via `panel.loadedContent` (null until first open). Keep timers/data/IPC outside the content (shell-dev).
- Import the palette as `qs.Commons as Commons` and use `Commons.Color` (Qt 6.12 `Color` shadowing).
- Do not rewrite widget files wholesale with glyph-stripping tools; make targeted edits.
- A Wi-Fi secret must never appear in process argv or `/proc/*/cmdline`.
- Forget only targets `known && !connected` profiles (`Model.canForgetNetwork`).
- All `nmcli` reads/writes target the resolved profile **UUID**, never the SSID.
- Follow existing `Panel.qml` / `Model.js` naming, comment style, and the single-cursor model (`focusSection`).

## Review Focus

Inputs/conditions the spec implies but no single test pins on its own, most likely to bite a user:

1. **Duplicate profile names** — three saved profiles named `KEMENKEU` exist on this machine; editing must hit the intended UUID (the active one when connected).
2. **Connected row** — Forget must be absent for the network currently in use.
3. **No-op save** — saving an untouched form must send zero `nmcli` arguments and not reconnect.
4. **Secret handling** — the PSK must never reach argv; grep `/proc` during a save.
5. **Manual IPv4 validation** — a malformed CIDR or gateway must disable Save rather than write a broken profile.

---

### Task 1: Development checkout and test baseline

**Files:**
- Create (outside repo): `~/Work/omacom/omarchy` (the checkout)

**Interfaces:**
- Produces: a linked checkout at `$CHECKOUT` where `test/shell` runs and `omarchy dev status` reports the link.

- [ ] **Step 1: Clone the checkout**

```bash
mkdir -p ~/Work/omacom && cd ~/Work/omacom
git clone https://github.com/omacom/omarchy.git
cd omarchy && git checkout quattro
```

- [ ] **Step 2: Copy this spec into the checkout**

```bash
mkdir -p docs/superpowers/specs
cp ~/Projects/omarchy-network-context-menu/docs/superpowers/specs/2026-11-09-network-context-menu-design.md docs/superpowers/specs/
git add docs/superpowers/specs/2026-11-09-network-context-menu-design.md
git commit -m "docs: network context menu design"
```

- [ ] **Step 3: Link the checkout**

Run: `omarchy dev link ~/Work/omacom/omarchy`
Then reboot (the link takes effect after reboot). This step is manual; note the reboot in your progress log.

- [ ] **Step 4: Verify the link and baseline tests**

Run: `omarchy dev status`
Expected: `dev-link: active` pointing at the checkout.
Run: `cd ~/Work/omacom/omarchy && ./test/shell`
Expected: existing suite passes (network files among them). Record the pass count.

- [ ] **Step 5: Commit**

No file changes; the clone and link are environment setup.

---

### Task 2: `Model.js` — parse `nmcli` connections and resolve a profile UUID

**Files:**
- Modify: `shell/plugins/panels/network/Model.js`
- Test: `test/shell.d/network-test.sh` (append asserts inside the existing `run_node_test` heredoc)

**Interfaces:**
- Produces:
  - `parseNmcliConnections(output: string) -> Array<{name: string, uuid: string, active: boolean}>` — parses `nmcli -t -f NAME,UUID,ACTIVE con show`; `-t` escapes a literal `:` in a name as `\:`.
  - `resolveProfile(profiles, ssid: string, connected: boolean) -> {uuid: string, ambiguous: boolean}` — matches by `name === ssid`; when `connected`, prefers the `active` match; returns `ambiguous: true` when more than one match and none is active.

- [ ] **Step 1: Write the failing tests**

In `test/shell.d/network-test.sh`, inside the `run_node_test <<'JS' … JS` block, add:

```javascript
// Three saved profiles can share one SSID; the resolver must not pick blindly.
const conns = network.parseNmcliConnections(
  'KEMENKEU:3736ec62-6a:yes\nKEMENKEU:e95bb213-05:no\nOther:abc:no\n'
)
assertDeepEqual(conns, [
  { name: 'KEMENKEU', uuid: '3736ec62-6a', active: true },
  { name: 'KEMENKEU', uuid: 'e95bb213-05', active: false },
  { name: 'Other', uuid: 'abc', active: false }
], 'network parses nmcli connection rows')
assertDeepEqual(
  network.parseNmcliConnections('A\\:B:uuid1:no\n'),
  [{ name: 'A:B', uuid: 'uuid1', active: false }],
  'network unescapes a colon-escaped connection name'
)
assertDeepEqual(
  network.resolveProfile(conns, 'KEMENKEU', true),
  { uuid: '3736ec62-6a', ambiguous: false },
  'network resolves a connected SSID to its active profile'
)
assertDeepEqual(
  network.resolveProfile(conns, 'KEMENKEU', false),
  { uuid: '3736ec62-6a', ambiguous: true },
  'network flags a duplicate-name SSID as ambiguous when none is active'
)
assertDeepEqual(
  network.resolveProfile(conns, 'Other', false),
  { uuid: 'abc', ambiguous: false },
  'network resolves a unique SSID directly'
)
assertDeepEqual(
  network.resolveProfile(conns, 'Missing', false),
  { uuid: '', ambiguous: false },
  'network resolves an SSID with no saved profile to empty'
)
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd ~/Work/omacom/omarchy && ./test/shell 2>&1 | grep -A2 network`
Expected: FAIL — `network.parseNmcliConnections is not a function`.

- [ ] **Step 3: Implement in `Model.js`**

Add near the other parsers, before the `module.exports`-style return at the end:

```javascript
// `nmcli -t` escapes a literal ':' inside a field as '\:'; split on the
// unescaped separators and unescape each field afterwards.
function splitNmcliFields(line) {
  var fields = [], current = ""
  for (var i = 0; i < line.length; i++) {
    var ch = line[i]
    if (ch === "\\" && line[i + 1] === ":") { current += ":"; i++; continue }
    if (ch === ":") { fields.push(current); current = ""; continue }
    current += ch
  }
  fields.push(current)
  return fields
}

function parseNmcliConnections(output) {
  var lines = String(output || "").split("\n")
  var out = []
  for (var i = 0; i < lines.length; i++) {
    if (lines[i] === "") continue
    var f = splitNmcliFields(lines[i])
    out.push({ name: f[0] || "", uuid: f[1] || "", active: (f[2] || "") === "yes" })
  }
  return out
}

function resolveProfile(profiles, ssid, connected) {
  var matches = []
  for (var i = 0; i < (profiles || []).length; i++) {
    if (profiles[i] && profiles[i].name === ssid) matches.push(profiles[i])
  }
  if (matches.length === 0) return { uuid: "", ambiguous: false }
  if (connected) {
    for (var j = 0; j < matches.length; j++) {
      if (matches[j].active) return { uuid: matches[j].uuid, ambiguous: false }
    }
  }
  if (matches.length === 1) return { uuid: matches[0].uuid, ambiguous: false }
  return { uuid: matches[0].uuid, ambiguous: true }
}
```

Add `parseNmcliConnections` and `resolveProfile` to the module's exported object (the same object that exports `parseBandStatus`, `canForgetNetwork`, …).

- [ ] **Step 4: Run test to verify it passes**

Run: `cd ~/Work/omacom/omarchy && ./test/shell 2>&1 | grep -A2 network`
Expected: PASS, all new asserts `ok`.

- [ ] **Step 5: Commit**

```bash
git add shell/plugins/panels/network/Model.js test/shell.d/network-test.sh
git commit -m "feat(network): resolve nmcli profiles by uuid"
```

---

### Task 3: `Model.js` — profile settings parse, diff, validation, argv builder

**Files:**
- Modify: `shell/plugins/panels/network/Model.js`
- Test: `test/shell.d/network-test.sh`

**Interfaces:**
- Consumes: nothing new.
- Produces:
  - `parseNmcliProfile(output: string) -> object` — key/value map from `nmcli -t -f connection.autoconnect,connection.autoconnect-priority,connection.metered,ipv4.method,ipv4.addresses,ipv4.gateway,802-1x.identity con show uuid <uuid>`. A `<hidden>` value becomes `""`.
  - `editorDefaults(settings, security, securityEnum) -> {autoConnect: boolean, priority: number, metered: string, ipv4Method: string, address: string, gateway: string, identity: string, hasPsk: boolean}`. `securityEnum = {Wpa2Psk, WpaPsk, Sae, Wpa2Eap, WpaEap}` supplied by the caller.
  - `validateEditor(form) -> {ok: boolean, error: string}` — manual IPv4 needs a CIDR address (`\d+\.\d+\.\d+\.\d+/\d+`) and an optional valid gateway (`\d+\.\d+\.\d+\.\d+`); priority must be a non-negative integer.
  - `changedModArgs(uuid, before, after) -> string[]` — a full `nmcli` argv for `nmcli connection modify uuid <uuid> …` including **only changed, non-secret** keys (autoconnect, autoconnect-priority, metered, ipv4.method/addresses/gateway). Empty array when nothing changed. Never contains `psk`.
  - `needsReapply(before, after) -> boolean` — true when any `ipv4.*` key changed.

- [ ] **Step 1: Write the failing tests**

Append to the `run_node_test` block:

```javascript
const prof = network.parseNmcliProfile(
  'connection.autoconnect:yes\nconnection.autoconnect-priority:0\n' +
  'connection.metered:unknown\nipv4.method:auto\nipv4.addresses:\nipv4.gateway:\n' +
  '802-1x.identity:zulham.syafrawi\n802-11-wireless-security.psk:<hidden>\n'
)
assertEqual(prof['connection.autoconnect'], 'yes', 'network parses a profile setting')
assertEqual(prof['802-11-wireless-security.psk'], '', 'network blanks a hidden secret')

const sec = { Wpa2Psk: 3, WpaPsk: 5, Sae: 1, Wpa2Eap: 2, WpaEap: 4, Open: 10 }
assertDeepEqual(
  network.editorDefaults(prof, sec.Wpa2Eap, sec),
  { autoConnect: true, priority: 0, metered: 'unknown', ipv4Method: 'auto', address: '', gateway: '', identity: 'zulham.syafrawi', hasPsk: false },
  'network derives editor defaults from a profile'
)

assertEqual(network.validateEditor({ ipv4Method: 'manual', address: '10.0.0.5/24', gateway: '10.0.0.1', priority: 0 }).ok, true, 'network accepts a manual CIDR')
assertEqual(network.validateEditor({ ipv4Method: 'manual', address: '10.0.0.5', gateway: '', priority: 0 }).ok, false, 'network rejects a manual address without a prefix')
assertEqual(network.validateEditor({ ipv4Method: 'auto', address: '', gateway: '', priority: 0 }).ok, true, 'network accepts automatic ipv4')
assertEqual(network.validateEditor({ ipv4Method: 'auto', address: '', gateway: '', priority: -1 }).ok, false, 'network rejects a negative priority')

const noop = network.changedModArgs('uuid-1', { autoConnect: true, priority: 0, metered: 'unknown', ipv4Method: 'auto', address: '', gateway: '' },
  { autoConnect: true, priority: 0, metered: 'unknown', ipv4Method: 'auto', address: '', gateway: '' })
assertDeepEqual(noop, [], 'network sends nothing for an unchanged form')
const changed = network.changedModArgs('uuid-1', { autoConnect: true, priority: 0, metered: 'unknown', ipv4Method: 'auto', address: '', gateway: '' },
  { autoConnect: false, priority: 5, metered: 'yes', ipv4Method: 'auto', address: '', gateway: '' })
assertDeepEqual(changed, ['nmcli', 'connection', 'modify', 'uuid', 'uuid-1',
  'connection.autoconnect', 'no', 'connection.autoconnect-priority', '5', 'connection.metered', 'yes'],
  'network sends only changed non-secret keys, by uuid')
assertEqual(changed.some(a => /psk/i.test(a)), false, 'network never puts a secret in argv')
assertEqual(network.needsReapply({ ipv4Method: 'auto' }, { ipv4Method: 'manual' }), true, 'network reapplies after an ipv4 change')
assertEqual(network.needsReapply({ autoConnect: true }, { autoConnect: false }), false, 'network does not reconnect for auto-connect alone')
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd ~/Work/omacom/omarchy && ./test/shell 2>&1 | grep -A2 network`
Expected: FAIL — `network.parseNmcliProfile is not a function`.

- [ ] **Step 3: Implement in `Model.js`**

Add pure functions using `parseKeyValue` (already present) for the settings map, and build the argv in a fixed key order:

```javascript
var MOD_KEYS = [
  ['autoConnect', 'connection.autoconnect', 'bool'],
  ['priority', 'connection.autoconnect-priority', 'int'],
  ['metered', 'connection.metered', 'str'],
  ['ipv4Method', 'ipv4.method', 'str'],
  ['address', 'ipv4.addresses', 'str'],
  ['gateway', 'ipv4.gateway', 'str']
]
```

`changedModArgs` compares `before[k]`/`after[k]` per `MOD_KEYS`; for `autoConnect` emit `yes`/`no`. `parseNmcliProfile` splits lines on the first `:` and maps `<hidden>` to `""`. Export all four names.

- [ ] **Step 4: Run test to verify it passes**

Run: `cd ~/Work/omacom/omarchy && ./test/shell 2>&1 | grep -A2 network`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add shell/plugins/panels/network/Model.js test/shell.d/network-test.sh
git commit -m "feat(network): profile diff, validation, and nmcli argv builder"
```

---

### Task 4: `Ui/ContextMenu.qml` — reusable themed popup

**Files:**
- Create: `shell/Ui/ContextMenu.qml`
- Test: `test/shell.d/fixtures/context-menu/ContextMenu.qml` + `test/shell.d/context-menu-test.sh`

**Interfaces:**
- Produces:
  - `property var items: []` — array of `{key: string, label: string, danger: boolean}`
  - `property color foreground`, `property color background`, `property string fontFamily`
  - `readonly property bool popupOpen`, `function open()`, `function close()`, `function toggle()`
  - `signal activated(string key)`, `signal hovered(int index)`
  - Keyboard (while open): Up/Down/j/k move a highlight, Enter/Space emits `activated(key)`, Esc calls `close()`.

- [ ] **Step 1: Write the failing fixture**

Create `test/shell.d/fixtures/context-menu/ContextMenu.qml`: a `Quickshell` root (mirror `test/shell.d/fixtures/` style) that instantiates `qs.Ui.ContextMenu` with three items, opens it, drives Up/Enter/Esc, asserts `activated("modify")` fired with the right key and that Esc closed it, then writes `{"ok": true}` to `process.env.OMARCHY_QML_TEST_RESULT` (JSON) — matching the harness contract in `base-test.sh` `run_qml_fixture`.

- [ ] **Step 2: Write the test file**

Create `test/shell.d/context-menu-test.sh`:

```bash
#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "context menu popup"
run_qml_fixture context-menu "context menu opens, navigates, activates, and closes on escape" Ui Commons
```

- [ ] **Step 3: Run test to verify it fails**

Run: `cd ~/Work/omacom/omarchy && ./test/shell.d/context-menu-test.sh`
Expected: FAIL — `ContextMenu` type not found / result missing.

- [ ] **Step 4: Implement `shell/Ui/ContextMenu.qml`**

Create a themed `Popup` (import `QtQuick.Controls`, `qs.Commons as Commons`): a `Column` of row `Item`s using the shared hover/selected fill (`Style.hoverFillFor`), a `Keys` handler for Up/Down/j/k/Enter/Esc, `activated`/`hovered` signals, and `popupOpen`/`open`/`close`/`toggle`. Reference `Dropdown.qml` for the popup surface (`Commons.Color.popups.*`) and cursor chrome conventions.

- [ ] **Step 5: Run test to verify it passes**

Run: `cd ~/Work/omacom/omarchy && ./test/shell.d/context-menu-test.sh`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add shell/Ui/ContextMenu.qml test/shell.d/fixtures/context-menu test/shell.d/context-menu-test.sh
git commit -m "feat(ui): reusable ContextMenu popup"
```

---

### Task 5: Right-click a Wi-Fi row opens the menu; Forget wires up

**Files:**
- Modify: `shell/plugins/panels/network/Panel.qml` (`NetworkRow` region ~1764-1946, root state ~90-125)
- Test: `test/shell.d/fixtures/network-panel/menu.qml` + `test/shell.d/network-panel-menu-test.sh`

**Interfaces:**
- Consumes: `qs.Ui.ContextMenu`, `Model.canForgetNetwork`, `Model.resolveProfile`, existing `root.forget(net)`, `root.disconnectRow(ssid)`, `root.connectDirectly(ssid)`.
- Produces: root state `property string menuSsid`, `property int menuIndex`; menu built by `root.openMenu(ssid, index)`.

- [ ] **Step 1: Write the failing fixture**

Create `test/shell.d/fixtures/network-panel/menu.qml` on the `stage_panel` pattern from `network-panel-runtime-test.sh` (copy its staging env) with a mock network list containing a connected `KEMENKEU` and a known disconnected `SVI`. Simulate a right click on the `SVI` row, assert the menu opens with items `disconnect|modify|forget`, press Escape, assert it closes. Assert the connected `KEMENKEU` menu has **no** `forget` item. Write `RESULT pass` / `RESULT fail`.

- [ ] **Step 2: Write the test file**

`test/shell.d/network-panel-menu-test.sh`: source `base-test.sh`, `require_compositor`, stage and run `menu.qml`, assert `RESULT pass` and no QML errors — same shape as `network-panel-runtime-test.sh`.

- [ ] **Step 3: Run test to verify it fails**

Run: `cd ~/Work/omacom/omarchy && ./test/shell.d/network-panel-menu-test.sh`
Expected: FAIL — no right-click handler, no menu.

- [ ] **Step 4: Implement in `Panel.qml`**

- Add `ContextMenu` inside `KeyboardPanel` content (so it builds with the card), anchored beside the clicked row; items filtered: always Connect/Disconnect + `Modify Network…` (only when the row is `known`), and `Forget Network` only when `canForgetNetwork`.
- Give `rowMouse` a right-click branch (`acceptedButtons: Qt.LeftButton | Qt.RightButton`): on `Qt.RightButton`, set `root.cursorActive`, `focusSection = "wifi"`, `selectedIndex = row.index`, set `menuSsid`/`menuIndex`, open the menu.
- `onActivated(key)`: `disconnect` → `disconnectRow(menuSsid)`; `modify` → `openEditor(menuSsid)` (Task 6); `forget` → `root.forget(<row by menuSsid>)`.
- Keep the left-click branch unchanged.

- [ ] **Step 5: Run test to verify it passes**

Run: `cd ~/Work/omacom/omarchy && ./test/shell.d/network-panel-menu-test.sh`
Expected: PASS.

- [ ] **Step 6: Restart the shell and smoke test**

Run: `omarchy-restart-shell`, then right-click a known Wi-Fi row.
Expected: menu appears; Forget absent on the connected row.

- [ ] **Step 7: Commit**

```bash
git add shell/plugins/panels/network/Panel.qml test/shell.d/fixtures/network-panel/menu.qml test/shell.d/network-panel-menu-test.sh
git commit -m "feat(network): right-click context menu on wifi rows"
```

---

### Task 6: The Modify editor and its apply path

**Files:**
- Create: `shell/plugins/panels/network/Editor.qml`
- Modify: `shell/plugins/panels/network/Panel.qml` (editor view + `openEditor` + write `Process`)
- Test: `test/shell.d/fixtures/network-panel/editor.qml` + `test/shell.d/network-panel-editor-test.sh`

**Interfaces:**
- Consumes: `Model.parseNmcliProfile`, `Model.editorDefaults`, `Model.validateEditor`, `Model.changedModArgs`, `Model.needsReapply`, `Model.parseNmcliConnections`, `Model.resolveProfile`; the existing `enterpriseConnect` stdin `Process` as the secret-write precedent.
- Produces: `Editor.qml` with `property var fields`, `property bool busy`, `property string error`, `signal save(var form)`, `signal cancel()`. Panel root: `property string editingUuid`, `property string editingSsid`, `function openEditor(ssid)`, `function saveEditor(form)`.

- [ ] **Step 1: Write the failing fixture**

Create `test/shell.d/fixtures/network-panel/editor.qml` (stage_panel pattern) with an `nmcli` stub: `con show <uuid>` returns the KEMENKEU settings; `con modify` and `con edit` log their argv/stdin. Drive `openEditor('KEMENKEU')`, assert the form prefills (`autoconnect yes`, `ipv4.method auto`), toggle auto-connect off, invoke Save, assert the recorded argv is exactly `connection modify uuid <uuid> connection.autoconnect no` and that **no** arg contains a secret. Write `RESULT pass`.

- [ ] **Step 2: Write the test file**

`test/shell.d/network-panel-editor-test.sh` mirroring the menu test: stage, run, assert `RESULT pass` and no QML errors.

- [ ] **Step 3: Run test to verify it fails**

Run: `cd ~/Work/omacom/omarchy && ./test/shell.d/network-panel-editor-test.sh`
Expected: FAIL — no editor.

- [ ] **Step 4: Implement `Editor.qml`**

A `Column` form (fields from the spec table) with `TextField`/`ToggleSwitch`/`NumberField`/`Dropdown` from `qs.Ui`, a Back/Save/Cancel header, `error` line, and `save(form)`/`cancel()` signals. `save` is disabled while `!Model.validateEditor(form).ok`.

- [ ] **Step 5: Implement the panel editor view and apply path in `Panel.qml`**

- `openEditor(ssid)`: run the connection-list read, `resolveProfile`, then `nmcli -t -f … con show uuid <uuid>`; on return, set `editingUuid`/`editingSsid` and switch the content view to the editor (hide the list). When the profile is ambiguous, show the picker first.
- `saveEditor(form)`: build `changedModArgs(editingUuid, before, after)`; if non-empty, run the `Process` (argv array, no shell). If `needsReapply` and the profile is active, follow with `nmcli connection up uuid <uuid>`. Send the passphrase/identity, when changed, through a stdin `Process` running `nmcli connection edit uuid <uuid>` (the `enterpriseConnect` pattern).
- On process exit 0, return to the list and `refresh()`; on failure show `error`.

- [ ] **Step 6: Run test to verify it passes**

Run: `cd ~/Work/omacom/omarchy && ./test/shell.d/network-panel-editor-test.sh`
Expected: PASS.

- [ ] **Step 7: Restart the shell and smoke test the real profile**

Run: `omarchy-restart-shell`; right-click `KEMENKEU` → Modify; toggle Auto-connect off, Save; verify `nmcli -t -f connection.autoconnect con show uuid 3736ec62-6b68-49fa-8fed-55949fee7513` reads `no`; toggle it back on and Save.

- [ ] **Step 8: Commit**

```bash
git add shell/plugins/panels/network/Editor.qml shell/plugins/panels/network/Panel.qml test/shell.d/fixtures/network-panel/editor.qml test/shell.d/network-panel-editor-test.sh
git commit -m "feat(network): native Modify Network editor"
```

---

### Task 7: i18n, polish, and full-suite verification

**Files:**
- Modify: `default/i18n/en/shell.json` (and any other locale already carrying `network.*` keys you can safely fill)
- Test: `test/shell.d/network-test.sh` (a key-coverage assert) and the full `test/shell`

**Interfaces:**
- Consumes: the strings referenced by `Panel.qml` / `Editor.qml` / `ContextMenu.qml`.
- Produces: `network.modifyNetwork`, `network.editConnection`, `network.autoConnect`, `network.priority`, `network.ipv4Method`, `network.automatic`, `network.manual`, `network.address`, `network.save`, `network.cancel`, `network.back` in `en/shell.json`.

- [ ] **Step 1: Write the failing test**

Add to `network-test.sh` a check that every key the new code calls `Commons.I18n.t("…")` with exists in `default/i18n/en/shell.json` (parse the file in Node and assert the `network.*` keys above exist).

- [ ] **Step 2: Run test to verify it fails**

Run: `cd ~/Work/omacom/omarchy && ./test/shell 2>&1 | grep -A2 network`
Expected: FAIL — missing key.

- [ ] **Step 3: Add the strings**

Add the keys to `default/i18n/en/shell.json` (alphabetical, matching existing `network.*` entries). Reuse `network.forgetNetwork`, `network.passphrase`, `network.identity`, `network.gateway` where possible.

- [ ] **Step 4: Run the full suite**

Run: `cd ~/Work/omacom/omarchy && ./test/shell`
Expected: all files pass, including the three new ones.

- [ ] **Step 5: Secret-leak spot check**

With the editor open on a PSK network, trigger a passphrase Save and in another terminal run: `for p in /proc/[0-9]*/cmdline; do tr '\0' ' ' < "$p"; echo; done | grep -i psk`
Expected: no match with the secret.

- [ ] **Step 6: Commit**

```bash
git add default/i18n/en/shell.json test/shell.d/network-test.sh
git commit -m "feat(network): context menu and editor copy"
```

---

## Self-Review

- **Spec coverage:** trigger/row (Task 5), Modify native editor (Task 6), Forget immediate + `known && !connected` (Task 5), UUID resolution R1 (Tasks 2, 6), stdin secret path R2 (Task 6), i18n and verification plan (Task 7). Covered.
- **Type consistency:** `resolveProfile`/`parseNmcliConnections` (Task 2) are consumed by name in Task 6; `changedModArgs`/`needsReapply` (Task 3) in Task 6; `ContextMenu.items/activated` (Task 4) in Task 5. Names match.
- **Review Focus hooks:** duplicate names → Task 2 resolver test + Task 6 picker; connected Forget → Task 5 fixture; no-op save → Task 3 `changedModArgs` empty test; secret handling → Task 3 argv assert + Task 6 fixture + Task 7 spot check; manual IPv4 → Task 3 validation tests.
- **Proportion:** code blocks are limited to test assertions and one constant table; bodies are left to the implementer.

## Execution note

Task 1 Step 3 needs a reboot, which only the human can do. Everything after depends on the checkout being linked; without it, run the Node tests directly (`node` against `Model.js`) but the runtime fixtures cannot run.
