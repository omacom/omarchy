#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

home="$tmpdir/home"
stub_bin="$tmpdir/bin"
installs="$tmpdir/mise-installs"
mise_log="$tmpdir/mise-log"
argv0_bin="$tmpdir/argv0printer"
argv0_is_bash=0
mkdir -p "$home" "$stub_bin" "$installs"

# A native binary is the only way to observe argv[0]: a shebang script loses
# the forged name before line 1, which is the wrapper bug this installer fixes.
if command -v cc >/dev/null; then
  cc -o "$argv0_bin" -x c - <<'EOF'
#include <stdio.h>

int main(int argc, char **argv) {
  if (argc > 0) {
    puts(argv[0]);
  }
  return 0;
}
EOF
else
  ln -sf "$(command -v bash)" "$argv0_bin"
  argv0_is_bash=1
fi

cat >"$stub_bin/mise" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$MISE_LOG"

if [[ $1 == "use" ]]; then
  if (( ${MISE_USE_FAIL:-0} )); then
    exit 1
  fi
  exit 0
fi

if [[ $1 == "where" ]]; then
  if (( ${MISE_WHERE_FAIL:-0} )); then
    exit 1
  fi
  printf '%s\n' "$MISE_WHERE"
  exit 0
fi

exit 0
SH
chmod +x "$stub_bin/mise"

seed_tool() {
  local package=$1
  local bin=$2
  local root="$installs/$package"

  mkdir -p "$root"
  cp "$argv0_bin" "$root/$bin"
  chmod +x "$root/$bin"
}

invoke_argv0() {
  local dest=$1
  local name=$2

  if (( argv0_is_bash )); then
    bash -c 'exec -a "$1" "$2" -c "printf %s\\n \"\$BASH_ARGV0\""' _ "$name" "$dest"
  else
    bash -c 'exec -a "$1" "$2"' _ "$name" "$dest"
  fi
}

run_install() {
  HOME="$home" PATH="$stub_bin:$ROOT/bin:$PATH" \
    MISE_LOG="$mise_log" MISE_WHERE="$MISE_WHERE" \
    MISE_USE_FAIL="${MISE_USE_FAIL:-0}" MISE_WHERE_FAIL="${MISE_WHERE_FAIL:-0}" \
    "$ROOT/bin/omarchy-mise-install" "$@"
}

: >"$mise_log"
seed_tool npm:playwright playwright
MISE_WHERE="$installs/npm:playwright"
run_install npm:playwright playwright

dest="$home/.local/bin/playwright"
[[ -L $dest ]] || fail "a normal install writes a symlink, not a script"
[[ $(readlink "$dest") == "$installs/npm:playwright/playwright" ]] ||
  fail "symlink points at the real binary"
got=$(invoke_argv0 "$dest" ugrep)
[[ $got == "ugrep" ]] || fail "symlink preserves argv[0] via exec -a" "expected ugrep, got: $got"
grep -qx 'use -g --quiet npm:playwright' "$mise_log" ||
  fail "installer still calls mise use -g --quiet" "$(cat "$mise_log")"
grep -qx 'where npm:playwright' "$mise_log" ||
  fail "installer resolves the binary with mise where" "$(cat "$mise_log")"
if awk '$1 == "x" { found = 1 } END { exit found ? 0 : 1 }' "$mise_log"; then
  fail "installer no longer re-execs through mise x"
fi
pass "a normal install writes a symlink that preserves argv[0]"

# A package name is mise argv data, never shell source. Confirm it stays one
# argument and does not expand.
: >"$mise_log"
package_hostile='npm:pkg$(touch '"$tmpdir"'/PWNED)end'
seed_root="$installs/hostile-pkg"
mkdir -p "$seed_root"
cp "$argv0_bin" "$seed_root/hostile"
chmod +x "$seed_root/hostile"
MISE_WHERE="$seed_root"
run_install "$package_hostile" hostile
[[ -e $tmpdir/PWNED ]] && fail "a package name with shell characters does not run at install time"
grep -qx "use -g --quiet $package_hostile" "$mise_log" ||
  fail "the package reaches mise whole" "$(cat "$mise_log")"
pass "a package name with shell characters reaches mise as one argument"

refused=(
  "a slash" "../escaped"
  "a leading dot" ".hidden"
  "a leading dash" "-dash"
  "a newline" $'with\nnewline'
  "a tab" $'with\ttab'
)

for (( i = 0; i < ${#refused[@]}; i += 2 )); do
  label=${refused[i]}
  name=${refused[i + 1]}

  if run_install somepkg "$name" >/dev/null 2>"$tmpdir/err"; then
    fail "a command name with $label is refused"
  fi
  grep -Fq 'is not usable as a command name' "$tmpdir/err" ||
    fail "the refusal says why for a command name with $label" "$(cat "$tmpdir/err")"
done

pass "command names that are not plain file names are refused"

victim="$tmpdir/victim"
printf 'keep me\n' >"$victim"
if run_install somepkg "../../../..$victim" >/dev/null 2>&1; then
  fail "an escaping command name is refused"
fi
[[ -f $victim ]] ||
  fail "an escaping command name removes nothing outside ~/.local/bin"

pass "an escaping command name removes nothing outside ~/.local/bin"

: >"$mise_log"
mkdir -p "$installs/missing"
MISE_WHERE="$installs/missing"
if run_install missing >/dev/null 2>&1; then
  fail "missing target exits non-zero"
fi
pass "missing target exits non-zero"

: >"$mise_log"
mkdir -p "$installs/unusable"
printf '#!/bin/bash\nexit 0\n' >"$installs/unusable/unusable"
chmod a-x "$installs/unusable/unusable"
MISE_WHERE="$installs/unusable"
if run_install unusable >/dev/null 2>&1; then
  fail "unusable target exits non-zero"
fi
pass "unusable target exits non-zero"

: >"$mise_log"
MISE_WHERE="$seed_root"
MISE_USE_FAIL=1
if run_install claude >/dev/null 2>&1; then
  fail "mise use failure exits non-zero"
fi
pass "mise use failure exits non-zero"

: >"$mise_log"
MISE_USE_FAIL=0
MISE_WHERE_FAIL=1
if run_install claude >/dev/null 2>&1; then
  fail "mise where failure exits non-zero"
fi
pass "mise where failure exits non-zero"

# Replacing an old wrapper file with a symlink.
MISE_WHERE_FAIL=0
seed_tool claude claude
mkdir -p "$home/.local/bin"
rm -f "$home/.local/bin/claude"
cat >"$home/.local/bin/claude" <<'EOF'
#!/bin/bash
export MISE_MINIMUM_RELEASE_AGE=0
mise use -g --quiet "claude" || exit 1
exec mise x "claude" -- "claude" "$@"
EOF
chmod +x "$home/.local/bin/claude"
[[ -L $home/.local/bin/claude ]] && fail "precondition: old wrapper is a regular file"

: >"$mise_log"
MISE_WHERE="$installs/claude"
run_install claude

[[ -L $home/.local/bin/claude ]] || fail "installer replaces an old wrapper with a symlink"
[[ $(readlink "$home/.local/bin/claude") == "$installs/claude/claude" ]] ||
  fail "replacement symlink points at the real binary"
got=$(invoke_argv0 "$home/.local/bin/claude" ugrep)
[[ $got == "ugrep" ]] || fail "replacement symlink preserves argv[0]" "expected ugrep, got: $got"
pass "installer replaces an old wrapper with a symlink"

if HOME="$home" PATH="$stub_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-mise-install" >/dev/null 2>&1; then
  fail "missing package argument exits non-zero"
fi
pass "missing package argument exits non-zero"
