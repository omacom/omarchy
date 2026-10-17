#!/bin/bash

# --config must not swallow the argument that follows it. Both keybindings
# menus parsed `--config` with a bare `shift; config_file="$1"`, so
# `omarchy-menu-tmux-keybindings --config --print` quietly ate the --print
# flag and opened the interactive menu instead of printing, and a bare
# `--config` with no value silently fell back to the default config.

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

tmpdir=$(mktemp -d) && [[ -n $tmpdir && -d $tmpdir ]] || \
  fail "the test gets a temporary directory to stub the backends in"
trap 'rm -rf "$tmpdir"' EXIT

stub_bin="$tmpdir/bin"
oroot="$tmpdir/oroot"
mkdir -p "$stub_bin" "$oroot/config/tmux"
touch "$oroot/config/tmux/tmux.conf"

# The interactive path is what the bug took: record it instead of opening it.
cat >"$stub_bin/omarchy-menu-select" <<'EOF'
#!/bin/bash
printf 'interactive-menu-opened\n' >>"$SELECT_LOG"
exit 0
EOF

# Emulates the multiplexed tmux invocation the script sends, and records which
# config file it was asked to source.
cat >"$stub_bin/tmux" <<'EOF'
#!/bin/bash
args=("$@")
i=0
n=${#args[@]}
while (( i < n )); do
  case "${args[i]}" in
    source-file)
      printf '%s\n' "${args[i+1]}" >>"$TMUX_SOURCE_LOG"
      i=$((i + 2)) ;;
    show-options)
      case "${args[i+2]}" in
        prefix) printf 'prefix C-b\n' ;;
        prefix2) printf 'prefix2 None\n' ;;
      esac
      i=$((i + 3)) ;;
    list-keys)
      table=""; pfx=""
      j=$((i + 1))
      while (( j < n )) && [[ ${args[j]} != ";" ]]; do
        case "${args[j]}" in
          -T) table="${args[j+1]}"; j=$((j + 2)) ;;
          -P) pfx="${args[j+1]}"; j=$((j + 2)) ;;
          *) j=$((j + 1)) ;;
        esac
      done
      printf '%s c new-window\n' "$pfx"
      i=$((j + 1)) ;;
    *) i=$((i + 1)) ;;
  esac
done
exit 0
EOF

cat >"$stub_bin/herdr" <<'EOF'
#!/bin/bash
if [[ $1 == "--default-config" ]]; then
  printf '# [keys]\n# goto_top = "ctrl-home"\n# quit = "q"\n'
fi
exit 0
EOF

cat >"$stub_bin/hyprctl" <<'EOF'
#!/bin/bash
exit 1
EOF

chmod +x "$stub_bin/omarchy-menu-select" "$stub_bin/tmux" "$stub_bin/herdr" "$stub_bin/hyprctl"

export PATH="$stub_bin:$PATH"
export OMARCHY_PATH="$oroot"
export SELECT_LOG="$tmpdir/select.log" TMUX_SOURCE_LOG="$tmpdir/tmux-source.log"

for script in omarchy-menu-tmux-keybindings omarchy-menu-herdr-keybindings; do
  name=${script#omarchy-menu-}

  # --config with no value is a usage error, not a silent default.
  : >"$SELECT_LOG"
  out=$("$ROOT/bin/$script" --config 2>"$tmpdir/stderr") && status=0 || status=$?
  (( status != 0 )) || fail "$name errors when --config has no value"
  grep -q -- "--config requires a value" "$tmpdir/stderr" ||
    fail "$name explains the missing --config value" "$(<"$tmpdir/stderr")"
  [[ ! -s $SELECT_LOG ]] || fail "$name does not open the menu on a --config usage error"
  pass "$name rejects a valueless --config instead of silently using the default"

  # --config must not eat a following flag: --print still has to print.
  : >"$SELECT_LOG"
  out=$("$ROOT/bin/$script" --config --print 2>"$tmpdir/stderr") && status=0 || status=$?
  (( status != 0 )) || fail "$name errors when --config swallows --print"
  grep -q -- "--config requires a value" "$tmpdir/stderr" ||
    fail "$name explains that --print is not a config path" "$(<"$tmpdir/stderr")"
  [[ ! -s $SELECT_LOG ]] || fail "$name does not open the menu when --config swallows --print"
  pass "$name refuses to treat --print as the --config value"

  # An unknown flag is a usage error, not a config path.
  : >"$SELECT_LOG"
  out=$("$ROOT/bin/$script" --bogus 2>"$tmpdir/stderr") && status=0 || status=$?
  (( status != 0 )) || fail "$name errors on an unknown option"
  grep -q -- "unknown option" "$tmpdir/stderr" ||
    fail "$name names the unknown option" "$(<"$tmpdir/stderr")"
  [[ ! -s $SELECT_LOG ]] || fail "$name does not open the menu on an unknown option"
  pass "$name rejects an unknown option instead of treating it as a config path"

  # The documented shapes keep working: --print prints, --config <file> --print
  # prints from that file.
  out=$("$ROOT/bin/$script" --print 2>/dev/null) && status=0 || status=$?
  (( status == 0 )) || fail "$name --print still exits zero"
  [[ -n $out ]] || fail "$name --print still prints its bindings"
  [[ ! -s $SELECT_LOG ]] || fail "$name --print does not open the interactive menu"
  pass "$name --print keeps printing without opening the menu"
done

# The tmux script sources exactly the file --config names.
touch "$tmpdir/my-tmux.conf"
: >"$TMUX_SOURCE_LOG"
"$ROOT/bin/omarchy-menu-tmux-keybindings" --config "$tmpdir/my-tmux.conf" --print >/dev/null 2>&1
[[ $(<"$TMUX_SOURCE_LOG") == "$tmpdir/my-tmux.conf" ]] ||
  fail "tmux keybindings sources the --config file" "$(<"$TMUX_SOURCE_LOG")"
pass "tmux keybindings sources the file --config names"
