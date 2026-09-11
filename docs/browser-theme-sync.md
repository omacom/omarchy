# Browser Theme Sync

Omarchy Theme Sync exposes the current desktop palette to websites through CSS variables and `window.omarchy`. Websites choose whether to use these values; the extension does not automatically restyle every site or change Chromium's toolbar theme. The extension is read-only. A page can observe the palette, but it cannot set or install desktop themes.

The runtime and regression fixtures are adapted from [omacom/omarchy-theme-sync](https://github.com/omacom/omarchy-theme-sync). The bundled copy keeps that project's palette read path and omits its `setTheme` and `installTheme` write API. The square icon is an [official Omarchy brand asset](https://omarchy.org/brand), not a grant of trademark rights. No private signing key is included or required.

## How It Works

```text
Omarchy current theme
  -> native helper watches current state
  -> extension service worker caches and broadcasts the palette
  -> content scripts write CSS variables and attributes
  -> websites read the DOM or window.omarchy
```

`bin/omarchy-browser-theme-host` watches `~/.local/state/omarchy/current/`, including replacement of the `theme` directory. It sends length-prefixed JSON through Chromium native messaging. The helper reads the theme state and runs no Omarchy commands. Every well-formed request it receives is a resync, and the reply is the same palette message.

The isolated content script receives palette messages and writes properties on `<html>`. A main-world script exposes `window.omarchy`, which reads those live properties. Nothing flows from the page back to the worker or the helper.

The extension has a stable public manifest key and ID, `ppnnomfimbfcofidkfmghapellfbgklc`. Native manifests permit only that extension origin and use the name `com.omarchy.theme`. The bundled worker is `background-1.js`; version its filename when changing the bundled worker so an older registered service worker cannot hide the update.

## Installation and Upgrades

- Fresh user provisioning registers the helper through `install/user/chromium.sh`; this does not depend on pending migrations or an existing Chromium profile.
- The default Chromium flags include `default/chromium/extensions/theme-sync`. Runtime setup uses the selected `OMARCHY_PATH` for source checkouts and packaged installs.
- An upgrade migration invokes `omarchy-install-chromium-theme-sync`. It preserves custom flags, unrelated extensions, symlinked dotfiles, and an unterminated final line. It does not run a destructive refresh or restart the browser.
- Later browser installation and explicit Chromium refresh also register the helper. Branded Chromium browsers still need to support unpacked extension loading; native registration alone does not bypass their restrictions.
- Updating the existing runtime/settings packages supplies these files through their normal `bin/`, `default/`, and `config/` packaging rules. No separate theme-sync package, repository clone, system daemon, root policy, or new sudo permission is needed.

Restart the browser after installation or migration. If manually reloading the extension, reload open pages too so their content scripts reconnect.

The installer replaces standalone entries only when their readable manifest public key identifies the same extension. It also handles the exact packaged theme-sync path when selecting a source checkout. It does not delete standalone files or infer identity from directory/display names. Missing or malformed manifests are preserved for manual cleanup. Multiple `--load-extension` directives retain Chromium's last-directive-wins behavior; earlier inactive lists are not re-enabled.

Flags are parsed with GLib through the already-shipped system Python/PyGObject packages, matching Chromium's launcher rather than interpreting each line as one argument. The merger preserves unrelated argument text and comments, quotes the updated extension argument, and validates the resulting argv. It never sources or evaluates flags. Malformed syntax fails without rewriting the flags file.

Manually loaded standalone copies may need removal in the browser's extension manager. Do not run the standalone uninstaller after takeover: it can remove the now-bundled `com.omarchy.theme` registration. The bundled installer does not rewrite browser Preferences or Secure Preferences.

## CSS API

Every valid flat key in the current `colors.toml` is exposed as `--omarchy-<key>`, with underscores changed to hyphens. A key such as `bright_green` becomes `--omarchy-bright-green`. Values update in place when the palette changes, and removed keys are cleared.

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

Always use fallback values for browsers without the extension. `<html>` also receives `data-omarchy-theme` and `data-omarchy-mode`. The extension does not set `color-scheme`, so unrelated form controls and scrollbars are not changed automatically.

## JavaScript API

Check for `window.omarchy` before calling it. The first palette arrives asynchronously; reads may initially be empty, and `onChange` fires when that first palette arrives.

| Member | Result |
| --- | --- |
| `theme` | Current theme name, or `null` before it arrives |
| `mode` | Current mode, usually `dark` or `light`, or `null` |
| `colors()` | Snapshot of all exposed colors |
| `color(name)` | One value, accepting underscores or hyphens, or `null` |
| `onChange(handler)` | Calls the handler with a frozen color snapshot; returns an unsubscribe function |

```js
const api = window.omarchy;
if (api) {
  console.log(api.theme, api.color('accent'));
  const stop = api.onChange((colors) => {
    console.log('Updated palette:', colors);
  });
  // Call stop() when the view is removed.
}
```

`omarchythemechange` is also dispatched on `document`, without event detail. Read the current values from the API or CSS. DOM values and events are visible to page scripts and are not an authentication mechanism.

## Permissions and Limits

- Reads expose the palette and theme name on every page where the content scripts run, including subframes. Custom colors can help fingerprint users; there is no per-site read opt-in.
- The manifest requests `nativeMessaging` and local `storage`. It requests no host permissions, and the worker makes no network requests.
- Native messages have a 1 MiB request cap and a 1 MiB response cap. Palette source files over 64 KiB produce an empty palette instead of unbounded data. Theme names are cut at 64 characters.
- The helper creates the watched state directory when it is missing and one lock file under `$XDG_RUNTIME_DIR`. It writes nothing else, and it never runs `omarchy-theme-set`.

A write path that lets a page switch or install themes changes the trust boundary and should be reviewed explicitly. The standalone project's write API shows what that involves: an origin allowlist in the worker, request validation in the helper, rate limits, and quota tracking.

## Validation

Run the focused integration and runtime tests:

```bash
bash test/shell.d/chromium-theme-sync-install-test.sh
bash test/shell.d/chromium-theme-sync-runtime-test.sh
```

The runtime fixtures exercise the actual content and page scripts, the worker logic, and native framing with temporary HOME and XDG paths. Native ports are mocked in the worker tests. Integration tests cover fresh setup, migration, flag preservation, same-ID takeover, symlinked configs, and retryable failures.

Before merge, exercise fresh installation and upgrade in a disposable Omarchy VM, restart Chromium, and confirm palette changes reach a real page. The unit/shell tests do not replace those live browser and package-upgrade checks. Do not run acceptance tests against the active development desktop.
