#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "shell runtime smoke test"

fail_with_log() {
  local description="$1"
  sed -n '1,240p' "$SCRATCH_LOG" >&2
  fail "$description"
}

setup_scratch_shell

# Every plugin under ~/.config/omarchy/plugins hot-reloads, whoever wrote it.
hot_reload_id="acme.hot-reload"
hot_reload_dir="$SCRATCH_HOME/.config/omarchy/plugins/$hot_reload_id"
mkdir -p "$hot_reload_dir"
cat >"$hot_reload_dir/manifest.json" <<JSON
{
  "schemaVersion": 1,
  "id": "$hot_reload_id",
  "name": "Before Hot Reload",
  "version": "1.0.0",
  "kinds": ["overlay"],
  "entryPoints": {"overlay": "Overlay.qml"},
  "omarchy": {"clonedFrom": "omarchy.emojis"}
}
JSON
cat >"$hot_reload_dir/Overlay.qml" <<'QML'
import QtQuick

Item {
  function open(payloadJson) {}
  function close() {}
}
QML

# A keepLoaded service must keep its instance (and in-memory state) across a
# plugin rescan. The marker below can only survive if the object does.
keep_service_id="acme.keep-service"
keep_service_dir="$SCRATCH_HOME/.config/omarchy/plugins/$keep_service_id"
mkdir -p "$keep_service_dir"
cat >"$keep_service_dir/manifest.json" <<JSON
{
  "schemaVersion": 1,
  "id": "$keep_service_id",
  "name": "Keep Service",
  "version": "1.0.0",
  "kinds": ["service"],
  "keepLoaded": true,
  "entryPoints": {"service": "Service.qml"}
}
JSON
cat >"$keep_service_dir/Service.qml" <<'QML'
import QtQuick
import Quickshell.Io

Item {
  property string marker: ""

  IpcHandler {
    target: "acme-keep"

    function set(value: string): string {
      marker = value
      return "ok"
    }

    function get(): string {
      return marker
    }
  }
}
QML

# A replacement bar must not receive a generic factory for another plugin's
# live service, and its barConfig must be a detached snapshot on both initial
# injection and later host-config updates.
victim_service_id="acme.victim-service"
victim_service_dir="$SCRATCH_HOME/.config/omarchy/plugins/$victim_service_id"
mkdir -p "$victim_service_dir"
cat >"$victim_service_dir/manifest.json" <<JSON
{
  "schemaVersion": 1,
  "id": "$victim_service_id",
  "name": "Victim Service",
  "version": "1.0.0",
  "kinds": ["service"],
  "entryPoints": {"service": "Service.qml"}
}
JSON
cat >"$victim_service_dir/Service.qml" <<'QML'
import QtQuick

Item {
  property string privateValue: "victim-secret"
}
QML

# A clone of the built-in media service exercises both supported service paths:
# its own widget receives the raw companion service under the trusted bar, while
# a replacement bar receives only the narrow media proxy resolved to the clone.
media_clone_id="acme.media-clone"
media_clone_dir="$SCRATCH_HOME/.config/omarchy/plugins/$media_clone_id"
mkdir -p "$media_clone_dir"
cat >"$media_clone_dir/manifest.json" <<JSON
{
  "schemaVersion": 1,
  "id": "$media_clone_id",
  "name": "Media Clone",
  "version": "1.0.0",
  "kinds": ["service", "bar-widget"],
  "entryPoints": {"service": "Service.qml", "barWidget": "BarWidget.qml"},
  "barWidget": {"defaultSection": "center"},
  "omarchy": {"clonedFrom": "omarchy.media"}
}
JSON
cat >"$media_clone_dir/Service.qml" <<'QML'
import QtQuick
import Quickshell.Io

Item {
  id: root
  property string marker: "clone-service"
  property bool enabled: true
  property var activePlayer: null
  property var sourcePlayers: []
  property var shell: null

  function runAction(action, showFeedback, targetKey) {}
  function playerKey(player) { return "" }
  function selectPlayer(playerKey) {}

  IpcHandler {
    target: "acme-media-clone-service"
    function ping(): string { return marker }
    function summonOsd(): string {
      return root.shell && root.shell.summon("omarchy.osd", "{}") ? "true" : "false"
    }
  }
}
QML
cat >"$media_clone_dir/BarWidget.qml" <<'QML'
import QtQuick
import Quickshell.Io

Item {
  id: root
  property var bar: null

  IpcHandler {
    target: "acme-media-clone-widget"
    function probeOwnService(): string {
      var service = root.bar && root.bar.shell
        ? root.bar.shell.firstPartyServiceFor("omarchy.media") : null
      return JSON.stringify({
        reachable: !!service,
        marker: service ? String(service.marker || "") : ""
      })
    }
  }
}
QML

review_bar_id="acme.review-bar"
review_bar_dir="$SCRATCH_HOME/.config/omarchy/plugins/$review_bar_id"
mkdir -p "$review_bar_dir"
cat >"$review_bar_dir/manifest.json" <<JSON
{
  "schemaVersion": 1,
  "id": "$review_bar_id",
  "name": "Review Bar",
  "version": "1.0.0",
  "kinds": ["bar", "service"],
  "keepLoaded": true,
  "entryPoints": {"bar": "Bar.qml", "service": "Service.qml"}
}
JSON
cat >"$review_bar_dir/Bar.qml" <<'QML'
import QtQuick
import Quickshell.Io

Item {
  id: root

  property var shell: null
  property var barConfig: ({})

  IpcHandler {
    target: "acme-review-bar"

    function probeVictim(): string {
      var genericFactory = root.shell
        && typeof root.shell.pluginShellForId === "function"
      var entryFacade = root.shell
        && typeof root.shell.pluginShellForBarEntry === "function"
        ? root.shell.pluginShellForBarEntry("probe", "acme.victim-service") : null
      var victim = entryFacade && typeof entryFacade.serviceFor === "function"
        ? entryFacade.serviceFor("acme.victim-service") : null
      return JSON.stringify({
        genericFactory: !!genericFactory,
        entryFacade: !!entryFacade,
        victimServiceReachable: !!victim
      })
    }

    function snapshot(): string {
      return JSON.stringify(root.barConfig || {})
    }

    function probeMediaProxy(): string {
      var service = root.shell
        ? root.shell.firstPartyServiceFor("omarchy.media") : null
      return JSON.stringify({ reachable: !!service, enabled: service ? service.enabled === true : false })
    }

    function probeMediaWidgetSummon(): string {
      var entryFacade = root.shell
        && typeof root.shell.pluginShellForBarEntry === "function"
        ? root.shell.pluginShellForBarEntry("probe-media", "acme.media-clone") : null
      return JSON.stringify({
        entryFacade: !!entryFacade,
        osdSummoned: entryFacade ? entryFacade.summon("omarchy.osd", "{}") : false,
        foreignSummoned: entryFacade ? entryFacade.summon("omarchy.lock", "{}") : false
      })
    }

    function mutateSnapshot(): string {
      if (root.barConfig && root.barConfig.layout
          && root.barConfig.layout.left && root.barConfig.layout.left.length > 0)
        root.barConfig.layout.left[0].id = "tampered.by.review-bar"
      return snapshot()
    }
  }
}
QML
cat >"$review_bar_dir/Service.qml" <<'QML'
import QtQuick
import Quickshell.Io

Item {
  id: root
  property var shell: null
  property var retainedShell: null

  onShellChanged: if (!retainedShell && shell) retainedShell = shell

  function mutationAllowed(candidate) {
    if (!candidate) return false
    try {
      return typeof candidate.mutateShellConfig === "function"
        && candidate.mutateShellConfig(function(config) {}) === true
    } catch (e) {
      return false
    }
  }

  IpcHandler {
    target: "acme-review-capability"
    function probe(): string {
      return JSON.stringify({
        currentAllowed: root.mutationAllowed(root.shell),
        retainedAllowed: root.mutationAllowed(root.retainedShell)
      })
    }
  }
}
QML

cat >"$SCRATCH_BIN/omarchy-update-available" <<'SH'
#!/bin/bash
echo "Omarchy update available (test)"
exit 0
SH
chmod +x "$SCRATCH_BIN/omarchy-update-available"

cat >"$SCRATCH_BIN/curl" <<'SH'
#!/bin/bash

case "${*: -1}" in
  *'?format=j1')
    printf '{"current_condition":[{"weatherCode":"113","temp_F":"72"}]}\n'
    ;;
  *'?format=%l')
    printf 'Test City, Test Region\n'
    ;;
  *)
    exit 1
    ;;
esac
SH
chmod +x "$SCRATCH_BIN/curl"

# Counts the transparent bar's wallpaper samples.
text_color_calls="$SCRATCH_DIR/text-color.calls"
cat >"$SCRATCH_BIN/omarchy-bar-text-color" <<SH
#!/bin/bash
echo "\$*" >>"$text_color_calls"
echo "#ffffff"
SH
chmod +x "$SCRATCH_BIN/omarchy-bar-text-color"

state_dir="$SCRATCH_HOME/.local/state/omarchy"
mkdir -p "$state_dir/current/theme"
: >"$state_dir/current/theme/a.png"
: >"$state_dir/current/theme/b.png"
ln -s "$state_dir/current/theme/a.png" "$state_dir/current/background"

start_scratch_shell
wait_scratch_shell

plugins=""
for _ in {1..80}; do
  plugins=$(scratch_ipc shell listPlugins 2>/dev/null || true)
  if jq -e 'length > 0' <<<"$plugins" >/dev/null 2>&1; then
    break
  fi
  if ! kill -0 "$SCRATCH_PID" 2>/dev/null; then
    fail_with_log "test shell exited before plugins were listed"
  fi
  sleep 0.1
done

jq -e '
  map(.id) as $ids |
  all(["omarchy.menu", "omarchy.notifications", "omarchy.clock", "omarchy.osd"][]; $ids | index(.)) and
  all(.[]; (.kinds | type == "array") and (.enabled | type == "boolean") and (.canDisable | type == "boolean") and (.firstParty | type == "boolean") and (.clonedFrom | type == "string")) and
  ([.[].name] == ([.[].name] | sort))
' <<<"$plugins" >/dev/null || {
  printf 'Plugins:\n%s\n' "$plugins" | jq . >&2
  fail_with_log "shell IPC lists plugin metadata"
}
pass "shell IPC lists plugin metadata"

# Plugins save their own state beside current/. That must not make the
# transparent bar sample the wallpaper again; repointing the background must.
text_color_count() {
  if [[ -f $text_color_calls ]]; then
    wc -l <"$text_color_calls"
  else
    echo 0
  fi
}

bar_background() {
  HOME="$SCRATCH_HOME" OMARCHY_PATH="$SCRATCH_ROOT" PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-bar" background "$@"
}

# Elsewhen saves its first-run cities once its probe returns, and that save
# writes the shell's whole config back to shell.json. Landing after an edit
# from outside the shell, it puts the old config back, so wait for it before
# editing shell.json. A machine slower than a desktop returns the probe late.
wait_for_elsewhen_cities() {
  local saved='any(.bar.layout[][]; .id? == "omarchy.elsewhen" and .cities? != null)'
  local config="$SCRATCH_HOME/.config/omarchy/shell.json"

  for _ in {1..300}; do
    jq -e "$saved" "$config" >/dev/null 2>&1 && return 0
    kill -0 "$SCRATCH_PID" 2>/dev/null || fail_with_log "test shell exited before Elsewhen saved its cities"
    sleep 0.1
  done
  fail_with_log "Elsewhen saves its first-run cities before shell.json is edited"
}

wait_for_elsewhen_cities
bar_background none >/dev/null
for _ in {1..50}; do
  (( $(text_color_count) > 0 )) && break
  sleep 0.1
done
(( $(text_color_count) > 0 )) || fail_with_log "transparent bar samples the wallpaper when turned on"
sleep 0.5
before=$(text_color_count)

printf '{}' >"$state_dir/unrelated.tmp"
mv "$state_dir/unrelated.tmp" "$state_dir/unrelated.json"
sleep 1
(( $(text_color_count) == before )) ||
  fail_with_log "unrelated state writes re-sample the wallpaper (was $before, now $(text_color_count))"

ln -nsf "$state_dir/current/theme/b.png" "$state_dir/current/background"
for _ in {1..50}; do
  (( $(text_color_count) > before )) && break
  sleep 0.1
done
(( $(text_color_count) > before )) || fail_with_log "repointing the background re-samples the wallpaper"
bar_background opaque >/dev/null
pass "unrelated state writes leave the transparent bar alone"

jq '.name = "After Hot Reload"' "$hot_reload_dir/manifest.json" >"$hot_reload_dir/manifest.json.tmp"
mv "$hot_reload_dir/manifest.json.tmp" "$hot_reload_dir/manifest.json"

hot_reload_name=""
for _ in {1..80}; do
  hot_reload_name=$(scratch_ipc shell listPlugins 2>/dev/null |
    jq -r --arg id "$hot_reload_id" '.[] | select(.id == $id) | .name' 2>/dev/null || true)
  [[ $hot_reload_name == "After Hot Reload" ]] && break
  if ! kill -0 "$SCRATCH_PID" 2>/dev/null; then
    fail_with_log "test shell exited while reloading a changed installed plugin"
  fi
  sleep 0.1
done
[[ $hot_reload_name == "After Hot Reload" ]] ||
  fail_with_log "installed plugin changes reload without an explicit rescan"
pass "installed plugin changes reload without an explicit rescan"

[[ $(scratch_ipc shell setPluginEnabled "$hot_reload_id" true) == "ok" ]] ||
  fail_with_log "installed plugin could not be enabled"
[[ $(scratch_ipc shell summon omarchy.emojis "{}") == "ok" ]] ||
  fail_with_log "calls to a cloned source id do not reach its enabled clone"
scratch_ipc_quiet shell hide omarchy.emojis >/dev/null
scratch_ipc_quiet shell setPluginEnabled "$hot_reload_id" false >/dev/null
pass "shell IPC routes built-in ids to enabled clones"

shell_config=$(scratch_ipc shell listShellConfig)
jq -e '
  .version == 1 and
  (.bar.layout.left | type == "array") and
  (.bar.layout.center | type == "array") and
  (.bar.layout.right | type == "array")
' <<<"$shell_config" >/dev/null || {
  printf 'Shell config:\n%s\n' "$shell_config" | jq . >&2
  fail_with_log "shell IPC returns effective shell config"
}
pass "shell IPC returns effective shell config"

[[ $(scratch_ipc shell summon omarchy.menu '{"menu":"apps"}') == "ok" ]] || fail_with_log "shell IPC summons menu apps overlay"
scratch_ipc_quiet shell hide omarchy.menu >/dev/null
[[ $(scratch_ipc shell summon missing.plugin "{}") == "unknown" ]] || fail_with_log "shell IPC rejects unknown plugin"
pass "shell IPC summon and hide contract works"

[[ $(scratch_ipc notifications ping) == "ok" ]] || fail_with_log "notifications IPC responds"
[[ $(scratch_ipc notifications setDnd false) == "off" ]] || fail_with_log "notifications IPC toggles DND"
[[ $(scratch_ipc media ping) == "ok" ]] || fail_with_log "media IPC responds"
jq -e '.hasPlayer | type == "boolean"' <<<"$(scratch_ipc media status)" >/dev/null || fail_with_log "media IPC returns status JSON"
jq -e '.enabled | type == "boolean"' <<<"$(scratch_ipc idle status)" >/dev/null || fail_with_log "idle IPC returns status JSON"
jq -e '.locked | type == "boolean"' <<<"$(scratch_ipc lock status)" >/dev/null || fail_with_log "lock IPC returns status JSON"
[[ $(scratch_ipc shell setPluginEnabled "$keep_service_id" true) == "ok" ]] ||
  fail_with_log "keepLoaded fixture service could not be enabled"
keep_marker_set=""
for _ in {1..80}; do
  keep_marker_set=$(scratch_ipc acme-keep set "survived" 2>/dev/null || true)
  [[ $keep_marker_set == "ok" ]] && break
  sleep 0.1
done
[[ $keep_marker_set == "ok" ]] || fail_with_log "keepLoaded fixture service IPC responds"
[[ $(scratch_ipc image-selector ping) == "ok" ]] || fail_with_log "image selector IPC responds"
[[ $(scratch_ipc osd ping) == "ok" ]] || fail_with_log "OSD IPC responds"
[[ $(scratch_ipc osd show '{"message":"Runtime smoke","duration":0}') == "ok" ]] || fail_with_log "OSD IPC opens"
[[ $(scratch_ipc osd close) == "ok" ]] || fail_with_log "OSD IPC closes"
pass "plugin IPC contracts respond"

scratch_ipc_quiet shell rescanPlugins >/dev/null
selector_rows_b64=$(printf '%s\t%s' "$SCRATCH_DIR/selector.png" "$SCRATCH_DIR/selector.png" | base64 -w 0)
selector_selection_file=$(mktemp "$SCRATCH_DIR/selector-selection.XXXXXX")
selector_done_file=$(mktemp "$SCRATCH_DIR/selector-done.XXXXXX")
rm -f "$selector_done_file"
selector_open=""
for _ in {1..80}; do
  selector_open=$(scratch_ipc image-selector open "" "$selector_rows_b64" "" "$selector_selection_file" "$selector_done_file" false false 2>/dev/null || true)
  if [[ $selector_open == "ok" ]]; then
    break
  fi
  if ! kill -0 "$SCRATCH_PID" 2>/dev/null; then
    fail_with_log "test shell exited during plugin rescan"
  fi
  sleep 0.1
done
[[ $selector_open == "ok" ]] || fail_with_log "image selector IPC survives plugin rescan"
scratch_ipc_quiet image-selector cancel "$selector_done_file" >/dev/null
rm -f "$selector_selection_file" "$selector_done_file"
pass "image selector IPC survives plugin rescan"

lock_status_after=$(scratch_ipc lock status) || fail_with_log "lock IPC answers after plugin rescan"
jq -e '.locked | type == "boolean"' <<<"$lock_status_after" >/dev/null || fail_with_log "lock IPC survives plugin rescan"
lock_event_after=$(jq -r '.lastEvent // empty' <<<"$lock_status_after")
[[ $lock_event_after != lock-stranded* ]] ||
  fail_with_log "plugin rescan does not strand the session lock ($lock_event_after)"
# A recreated instance would answer with a fresh, empty marker.
[[ $(scratch_ipc acme-keep get) == "survived" ]] ||
  fail_with_log "plugin rescan keeps the keepLoaded service instance mounted"
pass "keepLoaded service instance survives plugin rescan"

# Dropping the service entry point from the manifest must drop the kept
# instance instead of leaving a zombie behind.
jq 'del(.keepLoaded) | .kinds = ["overlay"] | .entryPoints = {"overlay": "Service.qml"}' \
  "$keep_service_dir/manifest.json" >"$keep_service_dir/manifest.json.tmp"
mv "$keep_service_dir/manifest.json.tmp" "$keep_service_dir/manifest.json"
keep_gone=""
for _ in {1..80}; do
  keep_gone=$(scratch_ipc acme-keep get 2>/dev/null || true)
  [[ $keep_gone != "survived" ]] && break
  sleep 0.1
done
[[ $keep_gone != "survived" ]] ||
  fail_with_log "kept service is dropped when its plugin stops declaring a service"
pass "kept service is dropped when its plugin stops declaring a service"

default_layout=$(jq -c '.bar.layout' "$ROOT/config/omarchy/shell.json")

geometry=""
for _ in {1..80}; do
  geometry=$(scratch_ipc shell debugBarGeometry 2>/dev/null || true)
  if jq -e --argjson layout "$default_layout" '
    . as $rows | all([$layout[]] | add | .[]; (.id // .) as $id | any($rows[]; .id == $id))
  ' <<<"$geometry" >/dev/null 2>&1; then
    break
  fi
  if ! kill -0 "$SCRATCH_PID" 2>/dev/null; then
    fail_with_log "test shell exited before default bar geometry settled"
  fi
  sleep 0.1
done

if [[ -z $geometry ]]; then
  fail_with_log "debug bar geometry returned output"
fi

# Every widget the default config places gets a slot in the section it names.
# Some hide on a machine without their hardware, but whatever shows has a size,
# and the menu, workspaces and clock always show.
jq -e --argjson layout "$default_layout" '
  . as $rows |
  all($layout | to_entries[]; .key as $section |
    all(.value[]; (.id // .) as $id | any($rows[]; .id == $id and .section == $section))) and
  all($rows[] | select(.visible == true); .width > 0 and .height > 0) and
  all("omarchy.menu", "omarchy.workspaces", "omarchy.clock"; . as $id | any($rows[]; .id == $id and .visible == true))
' <<<"$geometry" >/dev/null || {
  printf 'Geometry:\n' >&2
  jq . <<<"$geometry" >&2
  fail_with_log "default bar layout renders each widget in its configured section"
}
pass "default bar layout renders each widget in its configured section"

for panel_id in omarchy.audio omarchy.bluetooth omarchy.monitor omarchy.network omarchy.power; do
  scratch_ipc "$panel_id" open >/dev/null || fail_with_log "direct panel IPC opens $panel_id"
  scratch_ipc "$panel_id" close >/dev/null || fail_with_log "direct panel IPC closes $panel_id"
done
pass "direct panel IPC opens and closes default panels"

# Each widget registers its IPC handler once per bar, and the bar is
# instantiated once per screen, so Quickshell reports one collision per screen
# past the first. Anything beyond that is two instances on the same screen —
# the shape duplicate component loads produced, where a sync pass that ran
# while a widget's asynchronous load was still in flight started a second one.
# Checked before the reload below, which rebuilds widgets by design.
screens=$(hyprctl -j monitors 2>/dev/null | jq 'length' 2>/dev/null || true)
[[ $screens =~ ^[0-9]+$ ]] && (( screens > 0 )) || screens=1
# No matches is the good case, and pipefail would otherwise abort the run.
worst=$(grep -oE "another handler is registered for target [a-z.-]+" "$SCRATCH_LOG" |
  sort | uniq -c | sort -rn | head -1 | awk '{print $1}' || true)
worst=${worst:-0}
if (( worst > screens - 1 )); then
  { grep "another handler is registered for target" "$SCRATCH_LOG" | sed 's/^/  /' | head -20 >&2; } || true
  fail_with_log "each widget registers its IPC handler once per screen (saw $worst for $screens screen(s))"
fi
pass "each widget registers its IPC handler once per screen"

# The power panel used to close itself synchronously inside its own
# opened-change handler (no battery: open, then close at once), which
# QML reports as a binding loop for Panel.opened. Opening every panel
# above must not bring it back.
if grep -q 'Binding loop detected for property "opened"' "$SCRATCH_LOG"; then
  grep "Binding loop" "$SCRATCH_LOG" | sed 's/^/  /' | head -5 >&2
  fail_with_log "panel opens have no binding loop for opened"
fi
pass "panel opens have no binding loop for opened"

# The platform FileViews (audio hints, display cutouts) must load without a
# binding loop: a binding that reads text() and the flag its own load
# handlers write loops on every shell start.
if grep -q 'Binding loop detected for property "hints"\|Binding loop detected for property "displayCutouts"' "$SCRATCH_LOG"; then
  grep "Binding loop" "$SCRATCH_LOG" | sed 's/^/  /' | head -5 >&2
  fail_with_log "shell start has no platform FileView binding loops"
fi
pass "shell start has no platform FileView binding loops"

HOME="$SCRATCH_HOME" OMARCHY_PATH="$SCRATCH_ROOT" PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-plugin-disable" omarchy.audio

for _ in {1..80}; do
  shell_config=$(scratch_ipc shell listShellConfig 2>/dev/null || true)
  geometry=$(scratch_ipc shell debugBarGeometry 2>/dev/null || true)
  if jq -e 'all(.bar.layout.right[]; (.id // .) != "omarchy.audio")' <<<"$shell_config" >/dev/null 2>&1 && \
     jq -e 'all(.[]; .id != "omarchy.audio")' <<<"$geometry" >/dev/null 2>&1; then
    break
  fi
  if ! kill -0 "$SCRATCH_PID" 2>/dev/null; then
    fail_with_log "test shell exited before reloaded bar geometry settled"
  fi
  sleep 0.1
done

jq -e 'all(.bar.layout.right[]; (.id // .) != "omarchy.audio")' <<<"$shell_config" >/dev/null || {
  printf 'Shell config after reload:\n%s\n' "$shell_config" | jq . >&2
  fail_with_log "plugin disable reloads shell config"
}

jq -e 'all(.[]; .id != "omarchy.audio")' <<<"$geometry" >/dev/null || {
  printf 'Geometry after reload:\n' >&2
  jq . <<<"$geometry" >&2
  fail_with_log "runtime bar layout updates after shell config reload"
}

pass "bar remove reloads shell config and updates bar layout"

# 'bar put' is what migrations use to place a newly shipped widget, so it has
# to place one that is missing and leave one that is already there alone,
# however often it runs. The widget it puts must be missing from the default
# bar (omarchy.microphone is): 'put' leaves a widget that is already on the
# bar where it is, so putting one the defaults already carry (as
# omarchy.keyboard-layout is, in right) can never move it into center.
bar_put() {
  HOME="$SCRATCH_HOME" OMARCHY_PATH="$SCRATCH_ROOT" PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-bar" put "$@"
}

center_ids() {
  jq -c '[.bar.layout.center[] | .id // .]' <<<"$(scratch_ipc shell listShellConfig)"
}

bar_put omarchy.microphone --after omarchy.clock >/dev/null
for _ in {1..80}; do
  [[ $(center_ids) == *omarchy.microphone* ]] && break
  kill -0 "$SCRATCH_PID" 2>/dev/null || fail_with_log "test shell exited while putting a bar widget"
  sleep 0.1
done

jq -e '
  [.bar.layout.center[] | .id // .] as $ids
  | ($ids | index("omarchy.clock")) as $clock
  | ($ids | index("omarchy.microphone")) as $widget
  | $clock != null and $widget == $clock + 1
' <<<"$(scratch_ipc shell listShellConfig)" >/dev/null ||
  fail_with_log "bar put places a widget after the one it names ($(center_ids))"
pass "bar put places a widget after the one it names"

placed=$(center_ids)
bar_put omarchy.microphone --section right >/dev/null
sleep 0.5
[[ $(center_ids) == "$placed" ]] ||
  fail_with_log "bar put left a widget already on the bar alone (was $placed, now $(center_ids))"
jq -e 'all(.bar.layout.right[]; (.id // .) != "omarchy.microphone")' \
  <<<"$(scratch_ipc shell listShellConfig)" >/dev/null ||
  fail_with_log "bar put added a second copy of a widget already on the bar"
pass "bar put leaves a widget already on the bar alone"

# A hand edit that drops the closing brace puts the shell on the defaults,
# which have no omarchy.microphone. A bar change then applies for the session
# only, leaving the file as the user left it until they fix it.
config="$SCRATCH_HOME/.config/omarchy/shell.json"
wait_for_elsewhen_cities
sed -i '$ d' "$config"
cp "$config" "$SCRATCH_DIR/broken.json"
for _ in {1..80}; do
  [[ $(center_ids) != *omarchy.microphone* ]] && break
  kill -0 "$SCRATCH_PID" 2>/dev/null || fail_with_log "test shell exited while reading an unreadable shell.json"
  sleep 0.1
done
[[ $(center_ids) != *omarchy.microphone* ]] || fail_with_log "shell falls back to defaults on an unreadable shell.json"
[[ $(scratch_ipc shell setBarWidget omarchy.clock format '"HH:mm"' '{}') == "ok" ]] ||
  fail_with_log "bar widget setting is applied while shell.json is unreadable"
jq -e 'any(.bar.layout[][]; .id? == "omarchy.clock" and .format? == "HH:mm")' \
  <<<"$(scratch_ipc shell listShellConfig)" >/dev/null ||
  fail_with_log "a bar change still applies in memory while shell.json is unreadable"
sleep 0.5
cmp -s "$config" "$SCRATCH_DIR/broken.json" || fail "a bar change leaves an unreadable shell.json as the user left it" "$(cat "$config")"
pass "a bar change leaves an unreadable shell.json as the user left it"

printf '}\n' >>"$config"
for _ in {1..80}; do
  [[ $(center_ids) == *omarchy.microphone* ]] && break
  kill -0 "$SCRATCH_PID" 2>/dev/null || fail_with_log "test shell exited while reading a fixed shell.json"
  sleep 0.1
done
[[ $(scratch_ipc shell setBarWidget omarchy.clock format '"H:mm"' '{}') == "ok" ]] ||
  fail_with_log "bar widget setting is applied once shell.json is fixed"
saved='any(.bar.layout[][]; (.id? // .) == "omarchy.microphone") and any(.bar.layout[][]; .id? == "omarchy.clock" and .format? == "H:mm")'
for _ in {1..40}; do
  jq -e "$saved" "$config" >/dev/null 2>&1 && break
  sleep 0.1
done
jq -e "$saved" "$config" >/dev/null || fail "a bar change is saved again once shell.json is fixed" "$(cat "$config")"
pass "a bar change is saved again once shell.json is fixed"

# Run the replacement-bar probes last: switching bar loaders can transiently
# leave bar-aware panels without a visual host, which should not add noise to
# the default-bar assertions above.
[[ $(scratch_ipc shell setPluginEnabled "$media_clone_id" true) == "ok" ]] ||
  fail_with_log "media clone fixture could not be enabled"
clone_widget_probe=""
for _ in {1..80}; do
  clone_widget_probe=$(scratch_ipc acme-media-clone-widget probeOwnService 2>/dev/null || true)
  if jq -e '.reachable == true and .marker == "clone-service"' \
    <<<"$clone_widget_probe" >/dev/null 2>&1; then
    break
  fi
  sleep 0.1
done
jq -e '.reachable == true and .marker == "clone-service"' \
  <<<"$clone_widget_probe" >/dev/null || {
  printf 'Clone own-service probe: %s\n' "$clone_widget_probe" >&2
  fail_with_log "a cloned widget resolves its source id to its own companion service"
}
pass "trusted bar gives a cloned widget its own companion service"

[[ $(scratch_ipc acme-media-clone-service summonOsd) == "true" ]] ||
  fail_with_log "a cloned media service cannot summon its existing OSD target"
pass "a cloned built-in service retains its auxiliary UI integration"

[[ $(scratch_ipc shell setPluginEnabled "$victim_service_id" true) == "ok" ]] ||
  fail_with_log "victim service fixture could not be enabled"
[[ $(scratch_ipc shell enablePlugin "$review_bar_id" '{}') == "ok" ]] ||
  fail_with_log "replacement-bar fixture could not be enabled"

review_probe=""
for _ in {1..80}; do
  review_probe=$(scratch_ipc acme-review-bar probeVictim 2>/dev/null || true)
  if jq -e '.genericFactory == false and .entryFacade == false and .victimServiceReachable == false' \
    <<<"$review_probe" >/dev/null 2>&1; then
    break
  fi
  if ! kill -0 "$SCRATCH_PID" 2>/dev/null; then
    fail_with_log "test shell exited while loading the replacement-bar fixture"
  fi
  sleep 0.1
done
jq -e '.genericFactory == false and .entryFacade == false and .victimServiceReachable == false' \
  <<<"$review_probe" >/dev/null || {
  printf 'Replacement-bar service probe: %s\n' "$review_probe" >&2
  fail_with_log "replacement bar cannot recover another plugin's live service"
}

media_proxy_probe=$(scratch_ipc acme-review-bar probeMediaProxy)
jq -e '.reachable == true and .enabled == true' <<<"$media_proxy_probe" >/dev/null || {
  printf 'Replacement-bar media proxy probe: %s\n' "$media_proxy_probe" >&2
  fail_with_log "replacement-bar service proxies resolve enabled clones"
}

media_summon_probe=$(scratch_ipc acme-review-bar probeMediaWidgetSummon)
jq -e '.entryFacade == true and .osdSummoned == true and .foreignSummoned == false' \
  <<<"$media_summon_probe" >/dev/null || {
  printf 'Replacement-bar media summon probe: %s\n' "$media_summon_probe" >&2
  fail_with_log "replacement-bar clone facades retain only their auxiliary UI integration"
}

bar_config_before=$(scratch_ipc shell listShellConfig | jq -c '.bar')
scratch_ipc acme-review-bar mutateSnapshot >/dev/null
bar_config_after=$(scratch_ipc shell listShellConfig | jq -c '.bar')
[[ $bar_config_after == "$bar_config_before" ]] ||
  fail_with_log "replacement bar mutated the initially injected host configuration"

[[ $(scratch_ipc shell setBarWidget omarchy.clock format '"HH:mm:ss"' '{}') == "ok" ]] ||
  fail_with_log "host bar configuration could not be updated for snapshot testing"
updated_snapshot=""
for _ in {1..80}; do
  updated_snapshot=$(scratch_ipc acme-review-bar snapshot 2>/dev/null || true)
  if jq -e 'any(.layout.center[]; (.id // .) == "omarchy.clock" and .format == "HH:mm:ss")' \
    <<<"$updated_snapshot" >/dev/null 2>&1; then
    break
  fi
  sleep 0.1
done
jq -e 'any(.layout.center[]; (.id // .) == "omarchy.clock" and .format == "HH:mm:ss")' \
  <<<"$updated_snapshot" >/dev/null ||
  fail_with_log "replacement bar did not receive the refreshed configuration snapshot"
bar_config_before=$(scratch_ipc shell listShellConfig | jq -c '.bar')
scratch_ipc acme-review-bar mutateSnapshot >/dev/null
bar_config_after=$(scratch_ipc shell listShellConfig | jq -c '.bar')
[[ $bar_config_after == "$bar_config_before" ]] ||
  fail_with_log "replacement bar mutated a refreshed host configuration"

pass "replacement-bar service and configuration boundaries hold at runtime"

capability_before=$(scratch_ipc acme-review-capability probe)
jq -e '.currentAllowed == true and .retainedAllowed == true' \
  <<<"$capability_before" >/dev/null ||
  fail_with_log "bar service fixture did not initially receive bar capabilities"

# Keep the same enabled plugin ID and service instance while dropping the bar
# kind. Both the currently injected facade and a reference retained by the
# plugin must lose the old configuration capability after the manifest rescan.
jq '.kinds = ["service"] | .entryPoints = {"service": "Service.qml"}' \
  "$review_bar_dir/manifest.json" >"$review_bar_dir/manifest.json.tmp"
mv "$review_bar_dir/manifest.json.tmp" "$review_bar_dir/manifest.json"
capability_after=""
for _ in {1..80}; do
  capability_after=$(scratch_ipc acme-review-capability probe 2>/dev/null || true)
  if jq -e '.currentAllowed == false and .retainedAllowed == false' \
    <<<"$capability_after" >/dev/null 2>&1; then
    break
  fi
  if ! kill -0 "$SCRATCH_PID" 2>/dev/null; then
    fail_with_log "test shell exited while revoking changed manifest capabilities"
  fi
  sleep 0.1
done
jq -e '.currentAllowed == false and .retainedAllowed == false' \
  <<<"$capability_after" >/dev/null || {
  printf 'Capability revocation probe: %s\n' "$capability_after" >&2
  fail_with_log "cached plugin facades revoke capabilities removed from the manifest"
}
pass "manifest reload revokes cached facade capabilities"
