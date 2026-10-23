# Browser defaults and link routing

Omarchy keeps the selected browser in the ordinary `mimeapps.list`. Its desktop-specific `hyprland-mimeapps.list` routes HTTP and HTTPS through `omarchy-browser.desktop` so links opened by desktop portals also focus the browser window.

The system `xdg-settings set default-web-browser` writes the ordinary associations, then checks them through the desktop-specific list. It sees the routing entry rather than its own write, rolls HTTP back, and stops before setting HTTPS. HTML can already have changed at this point.

`default/xdg-utils/xdg-settings` bridges `get`, `check`, and `set` for `default-web-browser` only when both active HTTP and HTTPS handlers are Omarchy's routing entry. Those operations run the system `/usr/bin/xdg-settings` against the underlying associations with `XDG_CURRENT_DESKTOP` empty. The shell-provided `BROWSER=omarchy-launch-browser` is cleared for this path; another `BROWSER` remains an explicit override. Other properties, operations, and custom link handlers use the system utility unchanged. The bridge neither parses nor executes browser desktop entries itself.

The shared environment bootstrap exposes this directory before system utilities while keeping account command wrappers first. Existing applications need a new session to inherit that PATH. No system `xdg-settings` file is replaced. Ordinary `xdg-open` and portal lookup still see the routing entry, so the existing browser handoff and focusing path stays in place.

Chromium-family flags and Omarchy's Chromium policy no longer suppress the native default controls. A migration removes the old exact flag and the disabled-default setting from Omarchy's own hardened policy files, retaining other flags and policy keys. Firefox's existing default-check policy is unchanged: this bridge covers browsers using `xdg-settings`, not every toolkit-specific default API.

Run `test/shell.d/native-browser-default-test.sh` to reproduce the partial write with the system utility and verify the bridge against real xdg-utils in isolated XDG directories. `native-browser-default-migration-test.sh` exercises the migration without writing real policy files. The existing browser handoff tests cover link dispatch and focusing separately.
