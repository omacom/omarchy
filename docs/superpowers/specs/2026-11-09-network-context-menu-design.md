# Design: Modify Network & Forget Network — context menu on the Network bar widget

Date: 2026-11-09
Status: decisions made; builder-check passed with four findings folded in; awaiting approval
Target widget: `omarchy.network` — *"Wi-Fi list and connection state"*, the bar widget the user calls "Connections" (confirmed via a screenshot of the stock panel, "KEMENKEU ROUTING CRUMBS").

## Intent

The only way to act on a Wi-Fi network today is a left click on the row (connect / disconnect / passphrase prompt) plus a small trash affordance on the right edge for Forget. There is no menu, no edit path, and right click does nothing. We want a right-click context menu on a network row with two named actions: **Modify Network** (edit the saved connection in a native panel form) and **Forget Network** (delete it immediately, as today).

## Decisions (user, 2026-11-09)

- **D1 — trigger:** right click on a **Wi-Fi row** (not the bar icon). The bar icon's right click is unchanged.
- **D2 — Modify:** a **native in-panel editor** (QML form). Writes go through `nmcli` / the Quickshell networking API.
- **D3 — Forget:** **immediate delete**, no confirmation dialog.

## Current state (evidence)

- Widget `omarchy.network`: `/usr/share/omarchy/shell/plugins/panels/network/Panel.qml`.
- Row: `component NetworkRow` (`Panel.qml:1764`). Left click only: `rowMouse` `acceptedButtons: Qt.LeftButton` (`Panel.qml:1840-1874`).
- Forget: `rightMouse` (`Panel.qml:1930-1939`) → `root.forget(net)` (`Panel.qml:906`) → `network.forget()`; guarded by `Model.canForgetNetwork` (`Model.js:377-379`) = `known && !connected`.
- Inline editor precedent: passphrase prompt inside a row (`passwordPanel`, `Panel.qml:2000+`). Floating-terminal precedent: Custom DNS (`Panel.qml:775-778`).
- Networking QML types (`/usr/lib/qt6/qml/Quickshell/Networking/quickshell-network.qmltypes`): `Network` exposes `name, device, nmSettings, connected, known, state, stateChanging, connect(), connectWithPsk(psk), disconnect(), forget()`. **No UUID.** `NMSettings` is not a registered QML type — not constructible.
- `nmcli` fields available per profile: `connection.id, connection.uuid, connection.autoconnect, connection.autoconnect-priority, connection.metered, ipv4.method, ipv4.addresses, ipv4.gateway, 802-11-wireless-security.psk, 802-1x.identity`.
- No context-menu component in `qs.Ui` (`PopupCard.qml`, `Popup` available). `ConfirmDialog.qml` not needed (D3).

## Builder-check findings (verified, folded in)

1. **SSID is not a safe profile key.** This machine has **three** saved profiles named `KEMENKEU` (UUIDs `3736ec62` active, `e95bb213`, `573467b2`). `nmcli connection modify KEMENKEU …` can hit the wrong one. QML `Network` has no UUID, so the row cannot hand us one.
2. **`connectWithPsk` is a connect path,** not a profile edit — it would switch the live connection as a side effect of "edit passphrase".
3. **`Model.enterpriseConnectScript` (`Model.js:385`) runs `nmcli connection add`,** so the enterprise path creates a *new* profile instead of editing.
4. **Forget is guarded by `known && !connected`** (`Model.js:377`), so the menu must not offer to delete the live profile.

## Resolutions

### R1 — Target profiles by UUID, with a resolver

Resolve a row to an exact profile UUID in two steps: list the profiles with allowed list fields (`nmcli -t -f NAME,UUID,TYPE,ACTIVE,DEVICE connection show`), then read each Wi-Fi profile's stored SSID by UUID with the selector form (`nmcli -t -f 802-11-wireless.ssid connection show uuid <uuid>`). A row names a network by its **SSID**, and connection names are user-controlled and can repeat, so matching is **Wi-Fi-only by type**: only a profile whose `TYPE` is `802-11-wireless` can name a Wi-Fi row, and a VPN or ethernet profile whose connection name equals the SSID never matches (even by name). Among Wi-Fi profiles, match by the stored **SSID**, not by connection name; a Wi-Fi profile with no stored SSID (legacy or imported) falls back to its name. (The SSID cannot be requested from the list form — `nmcli connection show` rejects setting fields like `802-11-wireless.ssid`.) Then pick by this order:

1. **Connected row** → among the SSID matches, the saved profile whose `ACTIVE` flag is set (the row itself can be a scan-churn snapshot, so the profile's own flag decides). The panel passes the Wi-Fi device it is showing, so an active match on that device wins; with no device the first active match stands. Exact.
2. **Not connected, exactly one saved profile matches the SSID** → that UUID.
3. **Not connected, multiple matches** → the editor shows a small **profile picker** at the top (label = UUID short + a `nmcli`-derived discriminator such as the saved apn/priority), so duplicates are editable without guessing.

All reads and writes use the resolved UUID (`nmcli con show uuid …`, `nmcli con mod uuid …`), never the SSID.

### R2 — All secrets and edits go through one `nmcli` path (no argv leak, no forced reconnect)

- A small resolver `Process` caches `SSID → [{uuid, active}]` while the panel is open.
- **Non-secret keys** (autoconnect, priority, metered, ipv4.*): one `Process` with an **argv array**: `nmcli connection modify uuid <uuid> <key> <value> …`.
- **Secrets** (PSK, 802-1x.password/identity): pipe commands to `nmcli connection edit uuid <uuid>` over **stdin** (`printf 'set …\nsave\nquit\n'`), the same technique as `enterpriseConnectScript:385`. This edits in place, keeps the secret out of argv, and does **not** activate the connection.
- **Enterprise identity/password:** edit the existing UUID via the stdin path; do **not** reuse `enterpriseConnectScript` (it adds a profile).
- If the edited profile is the **currently active** one and a network-layer key changed (ipv4.*, psk), follow up with `nmcli connection up uuid <uuid>` so it takes effect. A pure profile edit on an inactive profile does not reconnect.
- Send **only changed keys** (diff against the prefilled values).

### R3 — Forget respects `known && !connected`

Menu shows Forget only when `Model.canForgetNetwork(net)`; a connected row shows Connect/Disconnect and Modify only. This keeps today's safety behavior.

## Goals

- Right-click a Wi-Fi row → themed menu: **Connect/Disconnect**, **Modify Network…** (known rows only), **Forget Network** (known && !connected).
- Modify opens a native editor for the resolved saved profile.
- Keyboard reachable; Esc closes; single-cursor model preserved.
- Never put a Wi-Fi secret in process argv.

## Non-goals

- Redesigning the panel/list.
- Editing out-of-range known networks (v1 edits a visible row).
- Moving DNS/band controls into the editor.
- Forget confirmation (decided against).

## Anti-goals (failure even if it "works")

- Two highlights at once (menu vs row cursor).
- Secret observable in `ps`/argv.
- Editing a profile other than the one the user clicked (see R1).
- Save that silently doesn't take effect, or wipes untouched fields.
- Panel freezing on a slow `nmcli` write.

## Context menu (D1)

- Right click a row → anchored `Popup`; panel root holds `menuSsid`, `menuIndex`.
- Items, filtered: Connect/Disconnect · Modify Network… (`known`) · Forget Network (`known && !connected`).
- New `qs.Ui/ContextMenu.qml`: themed `Popup`, shared hover-cursor chrome, j/k/Up/Down walk items, Enter activates, Esc closes, emits `activated(key)`. Reusable by other panels.

## Native editor (D2)

**Reachability.** Opened from the menu; the panel content switches to an editor view with a Back header keyed on `editingProfile` (uuid + name); the list hides while editing.

**Fields (v1), prefilled from `nmcli con show uuid <uuid>`:**

| Field | Widget | key | Notes |
|---|---|---|---|
| Profile | read-only / picker | `connection.uuid` | picker only when R1 case 3 |
| Security | read-only label | from `net.security` | not editable |
| Passphrase | password `TextField` | `802-11-wireless-security.psk` | PSK/SAE; blank = unchanged |
| Identity | text `TextField` | `802-1x.identity` | EAP only |
| Auto-connect | `ToggleSwitch` | `connection.autoconnect` | |
| Priority | `NumberField` | `connection.autoconnect-priority` | |
| IPv4 method | `Dropdown` Automatic/Manual | `ipv4.method` | Manual reveals the two below |
| Address | text `TextField` | `ipv4.addresses` | CIDR, e.g. `10.0.0.5/24` |
| Gateway | text `TextField` | `ipv4.gateway` | |
| Metered | `Dropdown` Unknown/Yes/No | `connection.metered` | |

Buttons: **Save** / **Cancel**. Validation: Manual IPv4 needs a valid CIDR; Save disabled otherwise. Priority is an integer.

## i18n

Add to `/usr/share/omarchy/default/i18n/<lang>/shell.json` (min `en`): `network.modifyNetwork`, `network.editConnection`, `network.autoConnect`, `network.priority`, `network.ipv4Method`, `network.automatic`, `network.manual`, `network.address`, `network.save`, `network.cancel`, `network.back`. Reuse `network.forgetNetwork, network.passphrase, network.identity, network.gateway`.

## Left to the builder

- `ContextMenu.qml` API/anchoring and placement (qs.Ui vs plugin).
- Editor view mechanics in `KeyboardPanel` (stack vs conditional content) and the Back transition.
- Whether priority/metered survive v1.
- Per-locale translations beyond `en`.

## Verification plan

- Right click a row opens the menu; left click unchanged.
- Forget via menu deletes exactly the clicked profile — check `nmcli con show` before/after (three `KEMENKEU` rows on this box make it a real test).
- Editor prefills real values; Save with no edits is a no-op.
- Toggling auto-connect flips `connection.autoconnect` on the resolved UUID.
- While saving a passphrase, `ps`/`/proc/*/cmdline` never contains the secret.
