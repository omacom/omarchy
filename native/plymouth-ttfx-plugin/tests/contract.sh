#!/bin/bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
plugin="$root/plugin.c"
state="$root/state.c"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

require_literal() {
  local needle=$1 file=$2
  grep -Fq -- "$needle" "$file" || fail "$file lacks required contract: $needle"
}

[[ -f $plugin ]] || fail "plugin.c is missing"
[[ -f $state ]] || fail "state.c is missing"
[[ -x $root/build-on-guest.sh ]] || fail "build-on-guest.sh is missing or not executable"

for callback in create_plugin destroy_plugin add_pixel_display remove_pixel_display show_splash_screen hide_splash_screen display_normal display_password display_question display_message hide_message; do
  require_literal ".$callback" "$plugin"
done

require_literal "ply_event_loop_watch_for_timeout" "$plugin"
require_literal "ply_event_loop_stop_watching_for_timeout" "$plugin"
require_literal "ply_pixel_display_set_draw_handler" "$plugin"
require_literal "ply_pixel_display_draw_area" "$plugin"
require_literal '#include "ttfx_plymouth.h"' "$plugin"
require_literal "ttfx_engine_create" "$plugin"
require_literal "ttfx_engine_draw_logo" "$plugin"
require_literal "ttfx_engine_cells" "$plugin"
require_literal "ttfx_engine_free" "$plugin"
require_literal "ttfx_engine_record_history" "$plugin"
require_literal "ttfx_engine_begin_reverse" "$plugin"
require_literal "TTFX_LOGO_MODE_REVERSE" "$plugin"
require_literal '"Outro"' "$plugin"
require_literal '"OutroMs"' "$plugin"
require_literal '"decrypt"' "$plugin"
require_literal '#define FRAME_INTERVAL_SECONDS (1.0 / 240.0)' "$plugin"
require_literal '#define ENGINE_STEPS_PER_TICK 2U' "$plugin"
require_literal '#define ENGINE_FPS 240U' "$plugin"
require_literal '#define ENGINE_WIDTH 162U' "$plugin"
require_literal '#define ENGINE_HEIGHT 20U' "$plugin"
require_literal '#define ENGINE_SEED UINT64_C(22321466108495961)' "$plugin"
require_literal '"Mode"' "$plugin"
require_literal '"fixed"' "$plugin"
require_literal '"random"' "$plugin"
require_literal '"off"' "$plugin"
require_literal "ttfx_embedded_logo" "$plugin"
require_literal "ply_entry_new" "$plugin"
require_literal "ply_entry_set_bullet_count" "$plugin"
require_literal "ply_entry_show" "$plugin"
require_literal "ply_label_new" "$plugin"
require_literal "ply_label_show" "$plugin"
require_literal "draw_static_fallback" "$plugin"

if grep -Eq 'ply_keyboard_(add|remove)_input_handler|on_keyboard_input|\.display_prompt[[:space:]]*=' "$plugin"; then
  fail "plugin must not capture keyboard/passphrase input or set display_prompt"
fi

python3 - "$plugin" <<'PY'
import re
import sys
text = open(sys.argv[1], encoding="utf-8").read()

def body(name):
    match = re.search(r"static\s+(?:void|bool)\s*\n?" + re.escape(name) + r"\s*\([^)]*\)\s*\{", text)
    if not match:
        raise SystemExit(f"FAIL: cannot find function body: {name}")
    start = match.end()
    depth = 1
    i = start
    while depth and i < len(text):
        depth += (text[i] == "{") - (text[i] == "}")
        i += 1
    if depth:
        raise SystemExit(f"FAIL: unterminated function body: {name}")
    return text[start:i - 1]

if "ttfx_engine_step" in body("on_draw") or "ttfx_engine_draw_logo" in body("on_draw") or "ttfx_engine_cells" in body("on_draw"):
    raise SystemExit("FAIL: simulation must not advance from draw callback")
for name in ("on_draw", "become_idle", "start_outro"):
    if "TTFX_LOGO_MODE_REVERSE" in body(name) or "ttfx_engine_draw_logo" in body(name):
        raise SystemExit(f"FAIL: the outro must advance from the timeout, not from {name}")
if "ttfx_engine_begin_reverse" in body("on_draw"):
    raise SystemExit("FAIL: draw must not start the outro")
timeout = body("on_timeout")
if "TTFX_LOGO_MODE_REVERSE" not in timeout or "outro_due_calls" not in timeout:
    raise SystemExit("FAIL: the outro must be driven, paced, from the timeout")
if timeout.count("ttfx_engine_draw_logo") != 1:
    raise SystemExit("FAIL: timeout must draw the logo through the single engine entry point")
if timeout.count("update_snapshot") != 1:
    raise SystemExit("FAIL: timeout must snapshot once per tick after drawing the logo")
if "damage_all_views" not in timeout:
    raise SystemExit("FAIL: timeout must damage every view")

place_prompt = body("place_prompt")
if "ttfx_view_show_prompt" not in place_prompt or place_prompt.count("ply_entry_show") != 1:
    raise SystemExit("FAIL: prompt entry show must be guarded by the per-view visibility transition")

destroy = body("destroy_plugin")
if "detach_event_loop_watch" not in destroy:
    raise SystemExit("FAIL: destroy must detach a live event-loop exit watch")
detach = body("detach_event_loop_watch")
if "ttfx_loop_detach_watch" not in detach or "ply_event_loop_stop_watching_for_exit" not in detach:
    raise SystemExit("FAIL: event-loop exit-watch detach must be state-guarded and unregister Plymouth")

show = body("show_splash_screen")
reject = show.find("ttfx_load_state_can_show")
watch = show.find("ply_event_loop_watch_for_exit")
if reject < 0 or watch < 0 or reject > watch or "return false" not in show:
    raise SystemExit("FAIL: widget readiness must reject splash before event-loop attachment")

add_display = body("add_pixel_display")
if "apply_current_prompt" not in add_display or "apply_current_message" not in add_display:
    raise SystemExit("FAIL: a new active display must inherit prompt and message state")

hide = body("hide_message")
if "ttfx_state_hide_message" not in hide or "damage_all_views" not in hide:
    raise SystemExit("FAIL: hide_message must clear state and redraw")

draw = body("on_draw")
if "animation_enabled" not in draw or "draw_grid" not in draw:
    raise SystemExit("FAIL: grid painting must be conditional on animation availability")
if draw.count("ply_label_draw_area") != 2:
    raise SystemExit("FAIL: draw must contain exactly the guarded prompt and message label calls")
for availability, label in (("prompt_label_available", "prompt_label"),
                            ("message_label_available", "message_label")):
    guard = rf"if\s*\([^)]*{availability}[^)]*\)\s*ply_label_draw_area\(view->{label},"
    if not re.search(guard, draw):
        raise SystemExit(f"FAIL: {label} draw must be guarded by {availability}")
if "draw_unlock_marker" not in draw:
    raise SystemExit("FAIL: degraded prompts need a built-in graphical unlock marker")

prompt = body("place_prompt")
failure = prompt.find("ttfx_view_degrade_prompt")
if failure < 0:
    raise SystemExit("FAIL: runtime prompt-label failure must enter degraded mode")
if prompt.find("ply_entry_set_bullet_count") > prompt.find("ttfx_view_prompt_can_show"):
    raise SystemExit("FAIL: repeated callbacks must update entry contents before skipping an unavailable label")
failure_path = prompt[failure:]
if ("ply_entry_hide" in failure_path or "enter_static_fallback" in failure_path or
        "ttfx_state_fail_rendering" in failure_path):
    raise SystemExit("FAIL: runtime prompt-label failure must not hide the entry or poison the plugin")

message = body("apply_current_message")
if "ttfx_view_degrade_message" not in message:
    raise SystemExit("FAIL: runtime message-label failure must degrade only that label")
if "ttfx_state_fail_rendering" in message:
    raise SystemExit("FAIL: runtime message-label failure must not poison the plugin")

degraded = body("enter_degraded_static_mode")
if "hide_view_prompt" in degraded or "ttfx_state_fail_rendering" in degraded:
    raise SystemExit("FAIL: degraded static mode must preserve prompt usability")

grid = body("draw_grid")
if "row < geometry->rows" not in grid or "column < geometry->columns" not in grid:
    raise SystemExit("FAIL: grid loops must use bounded per-view geometry")
if "TtfxCell" not in grid or "fg_rgba" not in grid or "bg_rgba" not in grid:
    raise SystemExit("FAIL: renderer must consume structured TTFX cell colors")
if "ttfx_frame_cell_on" in text:
    raise SystemExit("FAIL: synthetic frame generator must be removed")
PY

require_literal "-z,relro,-z,now" "$root/build-on-guest.sh"
require_literal "cargo build --locked --offline --profile plymouth" "$root/build-on-guest.sh"
require_literal "libttfx_plymouth.a" "$root/build-on-guest.sh"
require_literal "strip --strip-unneeded" "$root/build-on-guest.sh"
require_literal 'mktemp "$root/build/.plymouth-ttfx.so.XXXXXX"' "$root/build-on-guest.sh"
require_literal 'mv -f -- "$local_output" "$root/build/plymouth-ttfx.so"' "$root/build-on-guest.sh"
require_literal "void ply_entry_show" "$root/tests/stubs/ply-stubs.h"

printf 'contract: PASS\n'
