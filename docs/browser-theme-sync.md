# Browser Theme Sync

Omarchy Theme Sync shares desktop styling colors with websites through CSS variables and `window.omarchy`. Sharing starts **off for every site**. A browser-toolbar gesture approves an exact HTTP(S) origin; websites cannot request or grant themselves access. The extension is read-only: pages cannot switch or install desktop themes.

The integration was adapted from [omacom/omarchy-theme-sync](https://github.com/omacom/omarchy-theme-sync). The bundled version has its own per-site read policy and bounded, fixed-schema host; it does not include the standalone write API. The square icon is an [official Omarchy brand asset](https://omarchy.org/brand), not a grant of trademark rights. No private signing key is included or required.

## Approving and Stopping Sharing

1. Open a website, then click **Omarchy Theme Sync** in Chromium's extensions menu. Pin its toolbar icon if desired.
2. Accept Chromium's site-permission prompt. Only that exact origin receives colors; the toolbar shows **ON** when a fresh palette is delivered.
3. Click the icon again to stop sharing with that origin. Right-click the icon and choose **Stop sharing on all sites** to clear every approval.

An origin includes its scheme, hostname, and port. Approving `https://example.com` does not approve `http://example.com`, a subdomain, or another port. Chromium's underlying host grants span ports, but the worker separately checks exact-origin approval for every read and broadcast. Removing a browser host grant also removes affected approvals. Installer, migration, and refresh commands never create site approvals or reset a user's revocation.

Neither same-origin nor cross-origin subframes are injected or addressed directly. Same-origin frames can still inspect an approved parent's DOM through normal browser rules, and third-party scripts executing inside an approved top-level page can read that page's palette. File URLs, browser-internal pages, and incognito documents are never approved, even if the browser's extension settings permit file or incognito access. Exact colors remain a fingerprinting signal to approved sites; this is consent and data minimization, not anonymity.

No identifying page API, CSS properties, or attributes are installed on unapproved documents. Revocation clears published properties and attributes and removes the extension-owned `window.omarchy`. Already disclosed data cannot be withdrawn from a website's own memory or servers. Reload pages after an extension update or manual reload to discard old extension contexts and any old DOM state.

## Architecture and Trust Boundaries

```text
Current desktop palette
  -> bounded TOML parser and inotify event loop
  -> native messaging port
  -> worker's fresh in-memory palette
  -> exact-origin and top-frame authorization
  -> isolated script writes validated colors and mode
  -> approved page reads CSS or window.omarchy
```

`bin/omarchy-browser-theme-host` executes `default/chromium/theme-sync-host.py` through the system Python. One event loop owns native stdin, stdout, and Linux inotify descriptors. It watches both the current directory and active theme directory, including directory swaps, direct palette edits, and `light.mode` changes. Directory names containing spaces do not require text parsing. The host creates the state directory if absent, but otherwise writes no files, starts no child processes, and needs no lock file or shared `/tmp` fallback. EOF and signals close its descriptors. A lost or overflowed watch disconnects rather than presenting a permanently stale live connection.

The host accepts only bounded JSON-object frames, treats all well-formed requests as read-only resyncs, and never dispatches theme commands. Request and response frames are capped at 1 MiB; palette source readback is capped at 64 KiB. Malformed or oversized TOML produces no colors. Only known, top-level styling fields containing six-digit hex colors are exported, normalized to lowercase. Nested tables, arbitrary custom keys, CSS expressions, URLs, theme names, and other metadata are not exported.

Mode resolution follows `omarchy-theme-color`: valid `mode`, valid legacy `theme_type`, a sibling `light.mode`, background RGB sum greater than 382, then dark. Supported legacy short names and ANSI color entries map into the fixed semantic color schema. The mode is always `light` or `dark`.

The extension ID remains `ppnnomfimbfcofidkfmghapellfbgklc`, and native registration permits only that extension origin under `com.omarchy.theme`. The worker is `background-2.js`; version its filename when changing the bundled worker so an older registered worker cannot hide an update.

### Browser Permissions

- `nativeMessaging` opens the read-only native port.
- `storage` persists only approved origins. Local storage is restricted to trusted extension contexts, not content scripts. Old disk-cached palettes are removed on startup.
- `activeTab` supplies the clicked tab's URL during the browser-toolbar gesture.
- `scripting` registers isolated, top-frame scripts for approved hosts and injects the page API into an authorized document ID. Binding injection to a document prevents a navigation from reusing another document's authorization.
- `alarms` provides a 30-second reconnect retry that survives MV3 worker suspension. The alarm is removed after a fresh native palette arrives or all sharing is stopped.
- `contextMenus` supplies the browser-owned stop-everywhere action.
- Optional HTTP(S) host permissions are requested only through the toolbar gesture. There are no required host grants, static all-site content scripts, external messaging API, or network requests.

Authorization is enforced independently of script match patterns. Cached reads, native broadcasts, and main-world injection all require the same exact-origin, top-frame, non-incognito policy. Broadcast notifications cause an authorized fresh read; queued notifications cannot revive access after revocation. Palette state exists only in worker memory while the native port is live and is cleared from open pages immediately when it disconnects. A cold worker or unavailable host never supplies an old disk snapshot. Nothing from page events or `postMessage` is forwarded to the worker or host.

The browser, installed Omarchy code, local filesystem, and user-controlled extension settings remain trusted. A manifest public key identifies an unpacked extension; it is not protection against another process already running as the same OS user. Adding a website-to-desktop write path would introduce a new trust boundary and requires a separate review.

## CSS API

Approved pages receive these known color properties when their source values are valid:

- `accent`, `background`, `dark_background`, `darker_background`, `lighter_background`
- `foreground`, `dark_foreground`, `light_foreground`, `bright_foreground`, `cursor`, `muted`
- `selection`, `selection_background`, `selection_foreground`
- `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `orange`, `brown`
- `bright_red`, `bright_green`, `bright_yellow`, `bright_blue`, `bright_magenta`, `bright_cyan`

Underscores become hyphens: `bright_green` is exposed as `--omarchy-bright-green`. Removed keys are cleared. Non-hex custom values are intentionally not exported; sites should always retain fallbacks.

```css
.card {
  background: var(--omarchy-background, #101913);
  color: var(--omarchy-foreground, #a1af9c);
  border: 1px solid var(--omarchy-accent, #4a9a68);
}

html[data-omarchy-mode="light"] .card {
  box-shadow: 0 1px 4px #0002;
}
```

The root gets `data-omarchy-mode` and a sharing marker, but no theme-name attribute. The extension does not automatically restyle unrelated pages, change Chromium's toolbar theme, or set `color-scheme`.

## JavaScript API

`window.omarchy` is absent until approval and fresh delivery. Its arrival and later updates dispatch `omarchythemechange` on `document`, without event detail. Check for the API each time, including after revocation.

| Member | Result |
| --- | --- |
| `theme` | Always `null`; retained for compatibility, without disclosing private names |
| `mode` | `dark` or `light` while shared |
| `colors()` | Null-prototype snapshot of exposed colors |
| `color(name)` | One value, accepting underscores or hyphens, or `null` |
| `onChange(handler)` | Receives a frozen color snapshot; returns an unsubscribe function |

```js
function update() {
  const api = window.omarchy;
  if (api) console.log(api.mode, api.color('accent'));
}
document.addEventListener('omarchythemechange', update);
update();
```

An existing site-owned `window.omarchy` is not replaced. DOM values and events are visible to page scripts and can be spoofed by the page; they are not an authentication mechanism and should not be interpolated into HTML.

## Installation and Upgrades

- Fresh user setup registers the native host through `install/user/chromium.sh`, even before the first browser launch.
- Default Chromium flags load the extension, but loading it does not approve any site or start a native host while approvals are empty.
- Migration `1788886195.sh`, later browser installation, and Chromium refresh register the helper. Migration preserves custom flags, unrelated extensions, symlinked dotfiles, file modes, and unterminated final lines without a destructive refresh or browser restart.
- Flags are parsed through system Python/PyGObject and GLib, one physical line at a time, matching Arch's launcher. They are never sourced or evaluated. Ambiguous syntax fails without replacing the source file. The last effective extension list wins.
- Standalone entries are replaced only when their readable manifest key identifies the same extension, or they name the exact packaged alias. No standalone repository is removed, and unknown manifests are preserved. Manually loaded copies may need removal in the extension manager; do not run the standalone uninstaller after takeover because it can remove the shared native registration.
- Existing runtime/settings packaging supplies the new files. No extra package, root daemon, or sudo permission is needed. Chromium 123 or newer is required. Other Chromium-family builds must support unpacked extension loading; native registration does not bypass branded-browser restrictions.

Restart the browser after installation or migration. Fresh-install and upgrade validation in a disposable Omarchy VM and real branded-browser/platform checks remain pre-merge requirements.

## Validation and Local Tryout

```bash
bash test/shell.d/chromium-theme-sync-install-test.sh
bash test/shell.d/chromium-theme-sync-runtime-test.sh
```

The runtime tests exercise the actual native executable and main event loop, native framing, mode compatibility, directory replacement, no-child/no-lock teardown, consent and revocation, different ports, frames, incognito, stale replies, arbitrary metadata, and CSS URLs. Worker APIs are mocked; those tests do not substitute for browser permission UI checks.

For a visible local check, use a disposable profile and loopback-only page:

```bash
./test/browser-theme-sync
```

Sharing initially stays off. Approve the site through the browser icon, type `light` or `dark` plus Enter in the terminal to change the synthetic palette, then revoke sharing. The embedded frame must stay unshared. Close that temporary browser or press Ctrl+C to remove its profile, native registration, and test state. Do not sign into it.

To observe real desktop theme switches without modifying the real browser profile or theme state:

```bash
./test/browser-theme-sync --desktop
```

This variant points the temporary host at the current desktop state read-only. Change the desktop theme normally to exercise live delivery. Neither launcher mode changes installed browser flags, registrations, account data, or Omarchy configuration. Graphical acceptance tests still belong in a disposable VM, not the development desktop.
