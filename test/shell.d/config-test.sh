#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

export PATH="$ROOT/bin:$PATH"

require_command jq
require_command lua
require_command python3

jq empty "$ROOT/config/omarchy/shell.json"
pass "default shell.json is valid JSON"

jq -e '.version == 1 and ([.bar.layout[("left", "centerBegin", "center", "centerEnd", "right")] | type == "array"] | all)' "$ROOT/config/omarchy/shell.json" >/dev/null
pass "default shell.json has versioned bar layout"

# Every CLI write goes through the normalizer, which keeps every bar section a
# list, the ones beside the center box included.
normalized=$(OMARCHY_PATH="$ROOT" bash -c 'source "$OMARCHY_PATH/bin/omarchy-shell-config" && jq -c "$NORMALIZE | .bar.layout" <<<"{\"bar\":{\"layout\":{\"centerBegin\":null}}}"')
[[ $normalized == '{"centerBegin":[],"left":[],"center":[],"centerEnd":[],"right":[]}' ]] ||
  fail "shell config normalizer keeps every bar section a list" "$normalized"
pass "shell config normalizer keeps every bar section a list"

ROOT="$ROOT" python3 <<'PY'
import json
import os
import sys
from pathlib import Path

root = Path(os.environ["ROOT"])
config = json.loads((root / "config/omarchy/shell.json").read_text())
manifests = {}
for manifest_path in (root / "shell/plugins").glob("**/*.manifest.json"):
  data = json.loads(manifest_path.read_text())
  manifests[data.get("id", "")] = (manifest_path, data)
for manifest_path in (root / "shell/plugins").glob("**/manifest.json"):
  data = json.loads(manifest_path.read_text())
  manifests[data.get("id", "")] = (manifest_path, data)

entries = []
for section in ("left", "centerBegin", "center", "centerEnd", "right"):
  entries.extend(config["bar"]["layout"][section])

missing = []
bad = []
for entry in entries:
  widget_id = entry["id"] if isinstance(entry, dict) else str(entry)
  if not widget_id.startswith("omarchy."):
    continue

  row = manifests.get(widget_id)
  if row is None:
    missing.append(widget_id)
    continue
  manifest_path, manifest = row

  if "bar-widget" not in manifest.get("kinds", []):
    bad.append(f"{widget_id}: missing bar-widget kind")
  entry_point = manifest.get("entryPoints", {}).get("barWidget")
  if not entry_point:
    bad.append(f"{widget_id}: missing barWidget entry point")
  elif not (manifest_path.parent / entry_point).exists():
    bad.append(f"{widget_id}: missing {entry_point}")

if missing or bad:
  for item in missing:
    print(f"missing manifest for {item}", file=sys.stderr)
  for item in bad:
    print(item, file=sys.stderr)
  sys.exit(1)
PY
pass "default bar widget ids resolve to manifests and entry points"

# The PKGBUILDs live in the omarchy-pkgs checkout, wherever this machine keeps it.
if find_omarchy_pkgs; then
  ROOT="$ROOT" OMARCHY_PKGS_ROOT="$OMARCHY_PKGS_ROOT" python3 <<'PY'
import os
import re
import sys
from pathlib import Path

root = Path(os.environ["ROOT"])
pkgs_root = Path(os.environ["OMARCHY_PKGS_ROOT"])
settings_pkgbuild_path = pkgs_root / "omarchy-settings/PKGBUILD"
omarchy_pkgbuild_path = pkgs_root / "omarchy/PKGBUILD"
if not settings_pkgbuild_path.exists():
  settings_pkgbuild_path = pkgs_root / "omarchy-settings-dev/PKGBUILD"
if not omarchy_pkgbuild_path.exists():
  omarchy_pkgbuild_path = pkgs_root / "omarchy-dev/PKGBUILD"
pkgbuild = settings_pkgbuild_path.read_text()
omarchy_pkgbuild = omarchy_pkgbuild_path.read_text()
errors = []
package_defaults = [
  ("default/uwsm/env.d/10-omarchy", "/usr/share/uwsm/env.d/10-omarchy", "uwsm/env"),
  ("default/uwsm/default", None, "uwsm/default"),
  ("default/environment.d/10-omarchy-fcitx.conf", "/usr/lib/environment.d/10-omarchy-fcitx.conf", "environment.d/fcitx.conf"),
  ("default/fontconfig/conf.avail/50-omarchy.conf", "/usr/share/fontconfig/conf.avail/50-omarchy.conf", "fontconfig/fonts.conf"),
  ("default/xdg-terminal-exec/hyprland-xdg-terminals.list", "/usr/share/xdg-terminal-exec/hyprland-xdg-terminals.list", "xdg-terminals.list"),
  ("default/applications/mimeapps.list", "/usr/share/applications/mimeapps.list", "mimeapps.list"),
  ("etc/fastfetch/config.jsonc", "/etc/fastfetch/config.jsonc", "fastfetch/config.jsonc"),
  ("default/systemd/user/bt-agent.service", "/usr/lib/systemd/user/bt-agent.service", "systemd/user/bt-agent.service"),
  ("default/systemd/user/omarchy-sleep-lock.service", "/usr/lib/systemd/user/omarchy-sleep-lock.service", "systemd/user/omarchy-sleep-lock.service"),
  ("default/systemd/user/omarchy-recover-internal-monitor.service", "/usr/lib/systemd/user/omarchy-recover-internal-monitor.service", "systemd/user/omarchy-recover-internal-monitor.service"),
  ("default/systemd/user/omarchy-migrate-notify.service", "/usr/lib/systemd/user/omarchy-migrate-notify.service", "systemd/user/omarchy-migrate-notify.service"),
  ("default/systemd/user/omarchy-tailscale-receive.service", "/usr/lib/systemd/user/omarchy-tailscale-receive.service", "systemd/user/omarchy-tailscale-receive.service"),
  ("default/systemd/user/omarchy-fcitx5.service", "/usr/lib/systemd/user/omarchy-fcitx5.service", "systemd/user/omarchy-fcitx5.service"),
  ("default/systemd/user/omarchy-crash-watch.service", "/usr/lib/systemd/user/omarchy-crash-watch.service", "systemd/user/omarchy-crash-watch.service"),
  ("default/systemd/zram-generator.conf.d/90-omarchy.conf", "/usr/lib/systemd/zram-generator.conf.d/90-omarchy.conf", "systemd/zram-generator.conf.d/90-omarchy.conf"),
  ("default/systemd/timesyncd.conf.d/10-omarchy.conf", "/usr/lib/systemd/timesyncd.conf.d/10-omarchy.conf", "systemd/timesyncd.conf.d/10-omarchy.conf"),
  ("default/systemd/system/plocate-updatedb.service.d/10-omarchy.conf", "/usr/lib/systemd/system/plocate-updatedb.service.d/10-omarchy.conf", "systemd/system/plocate-updatedb.service.d/10-omarchy.conf"),
  ("default/fonts/omarchy/omarchy.ttf", "/usr/share/fonts/omarchy/omarchy.ttf", "omarchy.ttf"),
  ("default/snapper/root", "/etc/snapper/config-templates/omarchy", "snapper/root"),
]

for source, destination, legacy in package_defaults:
  if not (root / source).exists():
    errors.append(f"missing package default source: {source}")
  if (root / "config" / legacy).exists():
    errors.append(f"legacy path still in config/: {legacy}")
  if destination and (source not in pkgbuild or destination not in pkgbuild):
    errors.append(f"PKGBUILD does not explicitly install {source} -> {destination}")

# A user unit has to be on the machine before anything turns it on: shipped in
# /usr/lib/systemd/user, or copied out of default/ by the command enabling it.
def installs_first(text):
  source = re.search(r'(\w+)="[^"\n]*default/systemd/user/', text)
  held = rf"|\$\{{?{source[1]}\b" if source else ""
  copy = re.search(rf"^[ \t]*(?:sudo[ \t]+)?(?:install|cp)\b[^\n]*(?:default/systemd/user/{held})", text, re.MULTILINE)
  enable = text.find("systemctl --user enable")
  return bool(copy) and (enable < 0 or copy.start() < enable)

named = 'unit="$OMARCHY_PATH/default/systemd/user/a.service"\n'
if installs_first(named + "systemctl --user enable a.service\n"):
  errors.append("unit check accepts a command that names a unit's source but never installs it")
if installs_first(named + 'systemctl --user enable a.service\ninstall -Dm644 "$unit" "$target"\n'):
  errors.append("unit check accepts a command that installs a unit after enabling it")

scripts = [path.read_text(errors="ignore") for folder in ("bin", "install", "migrations")
           for path in (root / folder).rglob("*") if path.is_file()]
for unit in sorted(path.name for path in (root / "default/systemd/user").glob("*.service")):
  if f"/usr/lib/systemd/user/{unit}" in pkgbuild:
    continue
  named = [text for text in scripts if unit in text]
  if not any(installs_first(text) for text in named):
    errors.append(f"PKGBUILD does not ship default/systemd/user/{unit} and no command installs it")
  elif any("systemctl --user enable" in text and not installs_first(text) for text in named):
    errors.append(f"{unit} is enabled without being shipped by PKGBUILD or installed first")

# Existing users have an absolute wants symlink to the old unit path, and the
# migration that repoints it only runs for users who run an update -- the
# opposite of who the notifier is for. Dropping this alias strands them.
notify_alias = 'ln -sfn omarchy-migrate-notify.service "$pkgdir/usr/lib/systemd/user/omarchy-update-user-notify.service"'
if notify_alias not in pkgbuild:
  errors.append(
    "PKGBUILD does not ship the omarchy-update-user-notify.service compatibility "
    "alias, so users who have not run migration 1785095882 lose the login notifier"
  )

alpm_hooks = [
  "00-omarchy-update-guard.hook",
  "10-omarchy-hyprland-reload-pause.hook",
  "90-omarchy-hyprland-reload-resume.hook",
]
for hook in alpm_hooks:
  source = f"default/libalpm/hooks/{hook}"
  destination = f"/usr/share/libalpm/hooks/{hook}"
  if not (root / source).exists():
    errors.append(f"missing package default source: {source}")
  if source not in omarchy_pkgbuild or destination not in omarchy_pkgbuild:
    errors.append(f"omarchy PKGBUILD does not install {source} -> {destination}")

if errors:
  print("\n".join(errors), file=sys.stderr)
  sys.exit(1)
PY
  pass "package-owned defaults live outside config"
else
  skip "package-owned defaults live outside config: needs the omarchy-pkgs checkout; set OMARCHY_PKGS_PATH to it"
fi

OMARCHY_PATH="$ROOT" lua <<'LUA'
package.loaded["default.hypr.omarchy"] = true
package.loaded["default.hypr.require_optional"] = true
package.loaded["hypr.looknfeel"] = true
package.loaded["omarchy.current.theme.hyprland"] = true
package.loaded["unrelated.module"] = true

dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bootstrap.lua")

assert(package.loaded["default.hypr.omarchy"] == nil)
assert(package.loaded["default.hypr.require_optional"] == nil)
assert(package.loaded["hypr.looknfeel"] == nil)
assert(package.loaded["omarchy.current.theme.hyprland"] == nil)
assert(package.loaded["unrelated.module"] == true)
LUA
pass "Hyprland bootstrap reloads cached Omarchy config modules"

TMPDIR=$(mktemp -d)
mkdir -p "$TMPDIR/home/.config/omarchy"
# The bar keeps its blur toggle where Hyprland reads it, under XDG_STATE_HOME,
# so that points into the test home too.
export XDG_STATE_HOME="$TMPDIR/home/.local/state"

ipc_mock_bin="$TMPDIR/ipc-mock"
mkdir -p "$ipc_mock_bin"
cat >"$ipc_mock_bin/omarchy-shell" <<'SH'
#!/bin/bash
set -euo pipefail

mkdir -p "$HOME/.local/state/omarchy"
printf '%s\n' "$*" >>"$HOME/.local/state/omarchy/shell-ipc-calls"
printf 'ok\n'
SH
chmod +x "$ipc_mock_bin/omarchy-shell"
export PATH="$ipc_mock_bin:$PATH"

cat >"$TMPDIR/home/.config/omarchy/shell.json" <<'JSON'
{
  "version": 1,
  "bar": {
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }, { "id": "omarchy.active-window" }],
      "center": [{ "id": "omarchy.clock" }, { "id": "omarchy.weather" }, { "id": "omarchy.system-update" }, { "id": "omarchy.tailscale" }],
      "right": [{ "id": "omarchy.tray" }, { "id": "omarchy.microphone" }, { "id": "omarchy.bluetooth" }]
    }
  },
  "plugins": []
}
JSON

mkdir -p "$TMPDIR/home/.config/omarchy/plugins/local.demo-bar"
cat >"$TMPDIR/home/.config/omarchy/plugins/local.demo-bar/manifest.json" <<'JSON'
{
  "schemaVersion": 1,
  "id": "local.demo-bar",
  "name": "Demo bar",
  "version": "1.0.0",
  "author": "Test",
  "description": "Replacement bar for config tests",
  "kinds": ["bar"],
  "entryPoints": { "bar": "Bar.qml" }
}
JSON
touch "$TMPDIR/home/.config/omarchy/plugins/local.demo-bar/Bar.qml"

if HOME="$TMPDIR/home" OMARCHY_PATH="$ROOT" omarchy-bar use local.nonexistent-bar 2>/dev/null; then
  fail "bar use accepted an unknown bar option"
fi
pass "bar use rejects an unknown bar option"

HOME="$TMPDIR/home" OMARCHY_PATH="$ROOT" omarchy-bar use local.demo-bar
jq -e '.bar.id == "local.demo-bar"' "$TMPDIR/home/.config/omarchy/shell.json" >/dev/null
pass "shell config selects a bar option"

HOME="$TMPDIR/home" OMARCHY_PATH="$ROOT" omarchy-bar reset
jq -e '.bar.id == null' "$TMPDIR/home/.config/omarchy/shell.json" >/dev/null
pass "shell config resets to built-in bar option"

HOME="$TMPDIR/home" OMARCHY_PATH="$ROOT" omarchy-bar move omarchy.active-window right
grep -Fqx 'shell moveBarWidget omarchy.active-window {"section":"right"}' \
  "$TMPDIR/home/.local/state/omarchy/shell-ipc-calls"
pass "bar move accepts a positional target section"

HOME="$TMPDIR/home" OMARCHY_PATH="$ROOT" omarchy-bar move omarchy.active-window left
grep -Fqx 'shell moveBarWidget omarchy.active-window {"section":"left"}' \
  "$TMPDIR/home/.local/state/omarchy/shell-ipc-calls"
pass "bar move can restore a widget with positional syntax"

if HOME="$TMPDIR/home" OMARCHY_PATH="$ROOT" omarchy-bar move omarchy.active-window left --section right 2>/dev/null; then
  fail "bar move accepted positional and flagged target sections"
fi
pass "bar move rejects conflicting target section syntax"

HOME="$TMPDIR/home" OMARCHY_PATH="$ROOT" omarchy-bar position bottom
jq -e '
  .bar.position == "bottom" and
  .plugins == []
' "$TMPDIR/home/.config/omarchy/shell.json" >/dev/null
pass "shell config sets bar position"

HOME="$TMPDIR/home" OMARCHY_PATH="$ROOT" omarchy-bar transparent true
jq -e '
  .bar.background == "none" and
  .bar.position == "bottom" and
  .plugins == []
' "$TMPDIR/home/.config/omarchy/shell.json" >/dev/null
pass "shell config sets bar transparency"

HOME="$TMPDIR/home" OMARCHY_PATH="$ROOT" omarchy-bar transparent toggle
jq -e '.bar.background == "opaque"' "$TMPDIR/home/.config/omarchy/shell.json" >/dev/null
pass "shell config toggles bar transparency"

# The bar background is opaque, glassy or none. A glassy bar needs Hyprland's
# blur, so the bar-glassy toggle follows it.
printf '#!/bin/bash\nprintf "%%s\\n" "$*" >>"%s/hyprctl.log"\n' "$TMPDIR" >"$ipc_mock_bin/hyprctl"
chmod +x "$ipc_mock_bin/hyprctl"
glass_toggle="$TMPDIR/home/.local/state/omarchy/toggles/hypr/bar-glassy.lua"
bar_background() { HOME="$TMPDIR/home" OMARCHY_PATH="$ROOT" omarchy-bar background "$@"; }

bar_background opaque >/dev/null
[[ $(bar_background) == "opaque" ]] || fail "an opaque bar background is reported"
bar_background glassy >/dev/null
jq -e '.bar.background == "glassy"' "$TMPDIR/home/.config/omarchy/shell.json" >/dev/null ||
  fail "shell config sets a glassy bar"
[[ $(bar_background) == "glassy" ]] || fail "a glassy bar background is reported"
[[ -f $glass_toggle ]] || fail "a glassy bar turns on Hyprland's blur behind it"
grep -qx 'reload' "$TMPDIR/hyprctl.log" || fail "a glassy bar reloads Hyprland"
bar_background none >/dev/null
jq -e '.bar.background == "none"' "$TMPDIR/home/.config/omarchy/shell.json" >/dev/null ||
  fail "a bar without a background is stored as none"
[[ ! -f $glass_toggle ]] || fail "a bar without a background turns Hyprland's blur off again"
pass "shell config sets the bar background, and Hyprland's blur follows a glassy one"

seen=()
for _ in 1 2 3; do
  bar_background cycle >/dev/null
  seen+=("$(bar_background)")
done
[[ ${seen[*]} == "glassy opaque none" ]] || fail "the bar background cycles from clear to glassy to opaque and around" "${seen[*]}"
if bar_background frosted 2>/dev/null; then
  fail "an unknown bar background is refused"
fi
: >"$TMPDIR/hyprctl.log"
bar_background opaque >/dev/null
[[ ! -s $TMPDIR/hyprctl.log ]] || fail "Hyprland reloads only when the bar's glass changes"
pass "the bar background cycles through its looks and refuses unknown ones"

# transparent stays for scripts written against it: true is none, false opaque.
bar_background glassy >/dev/null
HOME="$TMPDIR/home" OMARCHY_PATH="$ROOT" omarchy-bar transparent true >/dev/null
[[ $(bar_background) == "none" ]] || fail "transparent true leaves the bar without a background"
HOME="$TMPDIR/home" OMARCHY_PATH="$ROOT" omarchy-bar transparent toggle >/dev/null
[[ $(bar_background) == "opaque" ]] || fail "toggling transparency off makes the bar opaque"
# A shell.json from before background says transparent, which reads as none
# and is dropped once a background is set.
jq '.bar.transparent = true | del(.bar.background)' "$TMPDIR/home/.config/omarchy/shell.json" >"$TMPDIR/legacy.json" &&
  mv "$TMPDIR/legacy.json" "$TMPDIR/home/.config/omarchy/shell.json"
[[ $(bar_background) == "none" ]] || fail "an older transparent bar reads as no background"
bar_background glassy >/dev/null
jq -e '.bar.background == "glassy" and (.bar | has("transparent") | not)' "$TMPDIR/home/.config/omarchy/shell.json" >/dev/null ||
  fail "setting a background drops the older transparent flag"
pass "the older transparent form still sets and reads as the bar background"

# Restoring the default bar also restores its opaque background, and the blur
# behind a glassy one goes with it.
bar_background glassy >/dev/null
[[ -f $glass_toggle ]] || fail "a glassy bar has its blur on before defaults"
HOME="$TMPDIR/home" OMARCHY_PATH="$ROOT" omarchy-bar defaults >/dev/null
[[ $(bar_background) == "opaque" && ! -f $glass_toggle ]] || fail "omarchy bar defaults turns a glassy bar's blur off"
pass "restoring the default bar turns a glassy bar's blur off"

# A background set by editing shell.json gets its blur when the shell syncs it.
jq '.bar.background = "glassy"' "$TMPDIR/home/.config/omarchy/shell.json" >"$TMPDIR/edited.json" &&
  mv "$TMPDIR/edited.json" "$TMPDIR/home/.config/omarchy/shell.json"
HOME="$TMPDIR/home" OMARCHY_PATH="$ROOT" omarchy-bar sync-glass
[[ -f $glass_toggle ]] || fail "syncing a hand-edited glassy bar turns its blur on"
jq '.bar.background = "opaque"' "$TMPDIR/home/.config/omarchy/shell.json" >"$TMPDIR/edited.json" &&
  mv "$TMPDIR/edited.json" "$TMPDIR/home/.config/omarchy/shell.json"
HOME="$TMPDIR/home" OMARCHY_PATH="$ROOT" omarchy-bar sync-glass
[[ ! -f $glass_toggle ]] || fail "syncing a hand-edited opaque bar turns its blur off"
pass "a bar background edited into shell.json gets its blur synced"

# A glassy bar whose blur can't be turned on keeps the background it had.
toggles_dir="${glass_toggle%/*}"
chmod a-w "$toggles_dir"
if bar_background glassy >/dev/null 2>&1; then
  chmod u+w "$toggles_dir"
  fail "a bar whose blur can't be turned on reports failure"
fi
chmod u+w "$toggles_dir"
[[ $(bar_background) == "opaque" && ! -f $glass_toggle ]] || fail "a bar whose blur can't be turned on keeps its old background" "$(bar_background)"
pass "a bar whose blur can't change keeps its old background"

HOME="$TMPDIR/home" OMARCHY_PATH="$ROOT" omarchy-bar set omarchy.bluetooth enabled false --json
grep -Fqx 'shell setBarWidget omarchy.bluetooth enabled false {}' \
  "$TMPDIR/home/.local/state/omarchy/shell-ipc-calls"
pass "bar set accepts false JSON values"

HOME="$TMPDIR/home" OMARCHY_PATH="$ROOT" omarchy-bar set omarchy.bluetooth optional null --json
grep -Fqx 'shell setBarWidget omarchy.bluetooth optional null {}' \
  "$TMPDIR/home/.local/state/omarchy/shell-ipc-calls"
pass "bar set accepts null JSON values"

if HOME="$TMPDIR/home" OMARCHY_PATH="$ROOT" omarchy-bar set omarchy.bluetooth broken '{' --json 2>/dev/null; then
  fail "bar set accepted malformed JSON"
fi
pass "bar set rejects malformed JSON"

if HOME="$TMPDIR/home" OMARCHY_PATH="$ROOT" omarchy-bar set omarchy.bluetooth broken 'false null' --json 2>/dev/null; then
  fail "bar set accepted multiple JSON values"
fi
pass "bar set rejects multiple JSON values"

mock_bin="$TMPDIR/mock-bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/omarchy-refresh-config" <<'SH'
#!/bin/bash
set -euo pipefail

relative_path="${1:-}"
[[ -n $relative_path ]] || exit 1
mkdir -p "$HOME/.config/$(dirname "$relative_path")"
cp "$OMARCHY_PATH/config/$relative_path" "$HOME/.config/$relative_path"
SH

cat >"$mock_bin/omarchy-restart-shell" <<'SH'
#!/bin/bash
set -euo pipefail

mkdir -p "$HOME/.local/state/omarchy"
touch "$HOME/.local/state/omarchy/restart-shell-called"
SH

cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash
[[ ${OMARCHY_TEST_SHELL_DOWN:-0} == "1" ]] && exit 1
printf 'ok\n'
SH

cat >"$mock_bin/omarchy-installed-service-dropbox" <<'SH'
#!/bin/bash
set -euo pipefail

[[ ${OMARCHY_TEST_DROPBOX:-0} == "1" ]]
SH

cat >"$mock_bin/omarchy-installed-service-tailscale" <<'SH'
#!/bin/bash
set -euo pipefail

[[ ${OMARCHY_TEST_TAILSCALE:-0} == "1" ]]
SH

chmod +x "$mock_bin"/*
mock_path="$mock_bin:$ROOT/bin:$PATH"

HOME="$TMPDIR/home" OMARCHY_PATH="$ROOT" PATH="$mock_path" OMARCHY_TEST_DROPBOX=0 OMARCHY_TEST_TAILSCALE=0 omarchy-bar defaults
jq -e --slurpfile defaults "$ROOT/config/omarchy/shell.json" '
  .bar == $defaults[0].bar and
  .plugins == []
' "$TMPDIR/home/.config/omarchy/shell.json" >/dev/null
pass "bar defaults restores the stock bar"

HOME="$TMPDIR/home" OMARCHY_PATH="$ROOT" PATH="$mock_path" OMARCHY_TEST_DROPBOX=1 OMARCHY_TEST_TAILSCALE=1 omarchy-bar defaults
jq -e '
  def ids: map(.id // .);
  (.bar.layout.right | ids) as $right |
  ($right | index("omarchy.tray")) as $tray |
  ($right | index("omarchy.tailscale") == $tray + 1) and
  ($right | index("omarchy.dropbox") == $tray + 2) and
  ([.bar.layout[]] | map(ids) | add | map(select(. == "omarchy.tailscale")) | length == 1)
' "$TMPDIR/home/.config/omarchy/shell.json" >/dev/null
pass "bar defaults places plugins for running optional services"

HOME="$TMPDIR/home" OMARCHY_PATH="$ROOT" PATH="$mock_path" \
  OMARCHY_TEST_SHELL_DOWN=1 OMARCHY_TEST_DROPBOX=1 OMARCHY_TEST_TAILSCALE=1 \
  omarchy-bar defaults
jq -e '
  def ids: map(.id // .);
  (.bar.layout.right | ids) as $right |
  ($right | index("omarchy.tray")) as $tray |
  ($right | index("omarchy.tailscale") == $tray + 1) and
  ($right | index("omarchy.dropbox") == $tray + 2) and
  ([.bar.layout[]] | map(ids) | add | map(select(. == "omarchy.tailscale")) | length == 1)
' "$TMPDIR/home/.config/omarchy/shell.json" >/dev/null
pass "bar defaults places service widgets without a running shell"

HOME="$TMPDIR/home" OMARCHY_PATH="$ROOT" PATH="$mock_path" OMARCHY_TEST_DROPBOX=0 OMARCHY_TEST_TAILSCALE=0 omarchy-refresh-shell
jq -e '
  def ids: map(.id // .);
  ([.bar.layout[]] | map(ids) | add) as $all |
  ($all | index("omarchy.dropbox") == null) and
  ($all | index("omarchy.tailscale") == null)
' "$TMPDIR/home/.config/omarchy/shell.json" >/dev/null
pass "shell refresh keeps optional service widgets absent when services are unavailable"

HOME="$TMPDIR/home" OMARCHY_PATH="$ROOT" PATH="$mock_path" OMARCHY_TEST_DROPBOX=1 OMARCHY_TEST_TAILSCALE=1 omarchy-refresh-shell
jq -e '
  def ids: map(.id // .);
  (.bar.layout.right | ids) as $right |
  ($right | index("omarchy.tray")) as $tray |
  ($right | index("omarchy.tailscale") == $tray + 1) and
  ($right | index("omarchy.dropbox") == $tray + 2) and
  ([.bar.layout[]] | map(ids) | add | map(select(. == "omarchy.tailscale")) | length == 1)
' "$TMPDIR/home/.config/omarchy/shell.json" >/dev/null
[[ -f $TMPDIR/home/.local/state/omarchy/restart-shell-called ]] || fail "shell refresh restarts shell"
pass "shell refresh places optional service widgets when services are available"
