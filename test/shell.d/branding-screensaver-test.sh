#!/bin/bash

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=""
cleanup() {
  if [[ -n $TMPDIR && -d $TMPDIR ]]; then
    rm -rf "$TMPDIR"
  fi
}
trap cleanup EXIT

TMPDIR=$(mktemp -d)
export HOME="$TMPDIR/home"
export OMARCHY_PATH="$ROOT"

branding_dir="$HOME/.config/omarchy/branding"
mkdir -p "$branding_dir" "$TMPDIR/bin"

cat >"$TMPDIR/bin/omarchy-launch-screensaver" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$LAUNCH_LOG"
SH
chmod +x "$TMPDIR/bin/omarchy-launch-screensaver"
export LAUNCH_LOG="$TMPDIR/launch.log"
export PATH="$TMPDIR/bin:$ROOT/bin:$PATH"

run_branding() {
  "$ROOT/bin/omarchy-branding-screensaver" "$@"
}

# Omarchy Square Logo writes the braille square mark and previews it
run_branding square
[[ -f "$branding_dir/screensaver.txt" ]] || fail "square branding writes screensaver.txt"
cmp -s "$ROOT/logo-square.txt" "$branding_dir/screensaver.txt" ||
  fail "square branding copies logo-square.txt"
[[ $(wc -l <"$LAUNCH_LOG") == 1 ]] || fail "square branding previews the screensaver"

# Restore Default puts the wordmark back
run_branding reset
cmp -s "$ROOT/logo.txt" "$branding_dir/screensaver.txt" ||
  fail "restore default copies logo.txt"
[[ $(wc -l <"$LAUNCH_LOG") == 2 ]] || fail "restore default previews the screensaver"

# Unknown subcommands refuse
run_branding nonsense >/dev/null 2>&1
[[ $? -ne 0 ]] || fail "unknown branding subcommand exits nonzero"

pass "branding-screensaver sets the square logo or restores the wordmark"