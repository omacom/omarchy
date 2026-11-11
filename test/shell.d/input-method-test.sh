#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

OMARCHY_PATH="$ROOT" python "$ROOT/test/shell.d/input-method-checks.py"

# Input-language shortcut: menu parsing, saving, and the Hyprland binding.
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

export HOME="$TMPDIR/home"
export OMARCHY_PATH="$ROOT"
export XDG_CONFIG_HOME="$TMPDIR/home/.config"
mkdir -p "$HOME/.config/omarchy"

CONFIG_FILE="$HOME/.config/omarchy/keyboard-shortcut"
MENU="$ROOT/bin/omarchy-menu-keyboard-shortcuts"

# ---- Fake menu picker and hyprctl, living entirely in the temp dir. ----
# The menu command finds omarchy-menu-select through $OMARCHY_PATH, so point it
# at a throwaway tree instead of replacing the real binary in the repo.
MENU_ROOT="$TMPDIR/menu-root"
mkdir -p "$MENU_ROOT/bin" "$TMPDIR/stubs"

# Records what the menu was called with and returns FAKE_PICK_ROW (an exact row
# as shown, tick and padding included) or "cancels" when it is empty, like
# pressing Escape. Like the real picker it takes a prompt followed by rows only.
cat > "$MENU_ROOT/bin/omarchy-menu-select" <<'EOF'
#!/bin/bash
printf '%s\n' "$@" > "$FAKE_ARGS_FILE"
[[ -n ${FAKE_PICK_ROW:-} ]] || exit 1
printf '%s\n' "$FAKE_PICK_ROW"
EOF
chmod +x "$MENU_ROOT/bin/omarchy-menu-select"

cat > "$TMPDIR/stubs/hyprctl" <<'EOF'
#!/bin/bash
echo "$*" >> "$HYPRCTL_LOG"
EOF
chmod +x "$TMPDIR/stubs/hyprctl"

# omarchy-i18n returns the English string for the test key
cat > "$TMPDIR/stubs/omarchy-i18n" <<'EOF'
#!/bin/bash
if [[ $1 == "keyboard.inputLanguageShortcut" ]]; then
  echo "Input language shortcut"
else
  echo "$1"
fi
EOF
chmod +x "$TMPDIR/stubs/omarchy-i18n"

export FAKE_ARGS_FILE="$TMPDIR/menu-args"
export HYPRCTL_LOG="$TMPDIR/hyprctl.log"
export PATH="$TMPDIR/stubs:$PATH"

# Run the menu against the fake picker. Usage: run_menu [pick-row]
run_menu() {
  : > "$HYPRCTL_LOG"
  FAKE_PICK_ROW="${1:-}" OMARCHY_PATH="$MENU_ROOT" "$MENU" 2>&1
}

stored_choice() {
  local stored
  IFS= read -r stored < "$CONFIG_FILE" || true
  stored="${stored#"${stored%%[![:space:]]*}"}"
  stored="${stored%"${stored##*[![:space:]]}"}"
  printf '%s' "$stored"
}

CHOICES=("ALT + SHIFT" "LEFT ALT" "SUPER + I")

# ---- The menu shows the prompt and the three shortcuts, and nothing else. ----
printf 'SUPER + I\n' > "$CONFIG_FILE"
run_menu >/dev/null || true
mapfile -t args < "$FAKE_ARGS_FILE"
[[ ${args[0]} == "Input language shortcut" ]] || fail "menu prompt: ${args[0]}"
(( ${#args[@]} == 4 )) || fail "menu has the prompt plus exactly 3 rows, got: ${args[*]}"
for arg in "${args[@]}"; do
  [[ $arg != --* ]] || fail "menu must not pass flags to omarchy-menu-select, they show up as rows: $arg"
done

# ---- The active shortcut, and only that one, carries a tick after its name. ----
for current in "${CHOICES[@]}"; do
  printf '%s\n' "$current" > "$CONFIG_FILE"
  run_menu >/dev/null || true
  mapfile -t args < "$FAKE_ARGS_FILE"
  ticks=0
  for row in "${args[@]:1}"; do
    if [[ $row == $current" ✓" ]]; then
      ticks=$((ticks + 1))
    elif [[ $row == *"✓"* ]]; then
      fail "only the active shortcut is ticked ($current active): $row"
    fi
  done
  (( ticks == 1 )) || fail "active shortcut $current is ticked once, got $ticks: ${args[*]}"
done

# ---- Unknown, blank or whitespace-only config behaves as the default (ticked). ----
for bogus in "BOGUS" "   " "  ALT + SHIFT  "; do
  printf '%s\n' "$bogus" > "$CONFIG_FILE"
  run_menu >/dev/null || true
  mapfile -t args < "$FAKE_ARGS_FILE"
  expected="SUPER + I"
  [[ $bogus == "  ALT + SHIFT  " ]] && expected="ALT + SHIFT"
  grep -Fxq "$expected ✓" "$FAKE_ARGS_FILE" || fail "config '$bogus' ticks $expected: ${args[*]}"
done

# ---- The old "LEFT ALT + RIGHT ALT" name is shown as "LEFT ALT", and rewritten on pick. ----
printf 'LEFT ALT + RIGHT ALT\n' > "$CONFIG_FILE"
run_menu >/dev/null || true
grep -Fxq "LEFT ALT ✓" "$FAKE_ARGS_FILE" || fail "the old name ticks LEFT ALT: $(tr '\n' '|' < "$FAKE_ARGS_FILE")"
run_menu "LEFT ALT ✓" >/dev/null || fail "re-picking LEFT ALT over the old name succeeds"
[[ $(stored_choice) == "LEFT ALT" ]] || fail "the old name is rewritten to LEFT ALT: $(stored_choice)"

# ---- Picking any row, ticked or not, stores the bare shortcut name. ----
for choice in "${CHOICES[@]}"; do
  for row in "$choice ✓" "$choice" "  $choice  "; do
    printf 'BOGUS\n' > "$CONFIG_FILE"
    out="$(run_menu "$row")" || fail "picking '$row' succeeds: $out"
    [[ $(stored_choice) == $choice ]] || fail "picking '$row' stored: $(stored_choice)"
    grep -Fxq "reload" "$HYPRCTL_LOG" || fail "picking '$row' reloads Hyprland"
    grep -Fq "set to $choice" <<<"$out" || fail "picking '$row' reports the change: $out"
  done
done

# ---- Re-picking the active shortcut is a no-op: no rewrite, no reload. ----
printf 'ALT + SHIFT\n' > "$CONFIG_FILE"
run_menu "ALT + SHIFT ✓" >/dev/null || fail "re-picking the active shortcut succeeds"
[[ $(stored_choice) == "ALT + SHIFT" ]] || fail "re-picking keeps the choice"
[[ ! -s $HYPRCTL_LOG ]] || fail "re-picking the active shortcut does not reload Hyprland"

# ---- Escape leaves the config alone and is not an error. ----
printf 'LEFT ALT\n' > "$CONFIG_FILE"
run_menu "" >/dev/null || fail "cancelling the menu is not an error"
[[ $(stored_choice) == "LEFT ALT" ]] || fail "cancelling keeps the choice: $(stored_choice)"
[[ ! -s $HYPRCTL_LOG ]] || fail "cancelling does not reload Hyprland"

# ---- A row that isn't a known shortcut is rejected and nothing is stored. ----
printf 'SUPER + I\n' > "$CONFIG_FILE"
if run_menu "--selected ✓" >/dev/null 2>&1; then
  fail "an unknown row is rejected"
fi
[[ $(stored_choice) == "SUPER + I" ]] || fail "an unknown row leaves the config alone"

# ---- The default file is created when missing or empty, with SUPER + I. ----
for setup in missing empty; do
  rm -f "$CONFIG_FILE"
  [[ $setup == "empty" ]] && : > "$CONFIG_FILE"
  run_menu "" >/dev/null || true
  [[ -s $CONFIG_FILE ]] || fail "default shortcut file not created ($setup)"
  grep -Fxq "SUPER + I" "$CONFIG_FILE" || fail "default is SUPER + I ($setup)"
done

# ---- The Lua binding reads the file and emits the right key. ----
list_bindings() {
  lua -e '
    package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

    local bindings = {}

    local function proxy()
      return setmetatable({}, {
        __index = function(self, key)
          local value = proxy()
          rawset(self, key, value)
          return value
        end,
        __call = function()
          return {}
        end,
      })
    end

    local dsp = proxy()
    rawset(dsp, "global", function(name) return { global = name } end)
    rawset(dsp, "exec_cmd", function(command) return { exec = command } end)

    hl = setmetatable({
      dsp = dsp,
      bind = function(keys, dispatcher, opts)
        local kind, target = "other", ""
        if type(dispatcher) == "table" and dispatcher.global then
          kind, target = "global", dispatcher.global
        elseif type(dispatcher) == "table" and dispatcher.exec then
          kind, target = "exec", dispatcher.exec
        end
        print(kind .. "\t" .. target .. "\t" .. ((opts or {}).description or "") .. "\trelease=" .. tostring((opts or {}).release == true))
      end,
    }, {
      __index = function()
        return function() return {} end
      end,
    })

    require("default.hypr.helpers")

    o.bind = function(keys, desc, dispatcher)
      table.insert(bindings, keys .. "\t" .. (desc or ""))
    end
    o.rebind = o.bind

    dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bindings/input-method.lua")

    for _, b in ipairs(bindings) do print(b) end
  '
}

expect_primary_binding() {
  local file_content="$1" expected="$2" label="$3"
  printf '%b' "$file_content" > "$CONFIG_FILE"
  local bindings
  bindings="$(list_bindings 2>&1)" || fail "$label: the binding file errored: $bindings"
  grep -Fxq "$expected	Switch input language" <<<"$bindings" || fail "$label: $bindings"
  grep -Fxq "SUPER + SHIFT + I	Switch input language back" <<<"$bindings" || fail "$label: back toggle always present: $bindings"
}

expect_primary_binding 'ALT + SHIFT\n' "ALT + SHIFT" "ALT + SHIFT binding"

# LEFT ALT is a release binding on Left Alt alone, bound straight through hl.bind.
expect_left_alt() {
  local file_content="$1" label="$2"
  printf '%b' "$file_content" > "$CONFIG_FILE"
  local bindings
  bindings="$(list_bindings 2>&1)" || fail "$label: the binding file errored: $bindings"
  grep -Fxq $'exec\tomarchy-input-method cycle\tSwitch input language\trelease=true' <<<"$bindings" ||
    fail "$label: Left Alt is bound on release: $bindings"
  ! grep -Fq "Alt_R" <<<"$bindings" || fail "$label: Right Alt is not involved: $bindings"
  ! grep -Fxq "SUPER + I	Switch input language" <<<"$bindings" || fail "$label: no other primary binding: $bindings"
  grep -Fxq "SUPER + SHIFT + I	Switch input language back" <<<"$bindings" || fail "$label: back toggle always present: $bindings"
}
expect_left_alt 'LEFT ALT\n' "LEFT ALT binding"
expect_left_alt '  LEFT ALT  \n' "LEFT ALT with surrounding whitespace"
expect_left_alt 'LEFT ALT + RIGHT ALT\n' "the old LEFT ALT + RIGHT ALT name maps to LEFT ALT"

expect_primary_binding 'SUPER + I\n' "SUPER + I" "SUPER + I binding"
expect_primary_binding '  ALT + SHIFT  \n' "ALT + SHIFT" "surrounding whitespace is ignored"
expect_primary_binding 'ALT + SHIFT' "ALT + SHIFT" "a missing trailing newline is fine"
expect_primary_binding '' "SUPER + I" "an empty file falls back to the default instead of crashing"
expect_primary_binding '\n' "SUPER + I" "a blank file falls back to the default"
expect_primary_binding 'BOGUS\n' "SUPER + I" "an unknown value falls back to the default"
rm -f "$CONFIG_FILE"
bindings="$(list_bindings 2>&1)" || fail "a missing file: the binding file errored: $bindings"
grep -Fxq "SUPER + I	Switch input language" <<<"$bindings" || fail "a missing file falls back to the default: $bindings"

pass "input language shortcut menu, tick, binding, and first-run default all behave correctly"
