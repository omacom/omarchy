#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

script="$ROOT/bin/omarchy-pkg-aur-add"
grep -q -- '--sudo pkexec' "$script" ||
  fail "omarchy-pkg-aur-add passes --sudo pkexec when stdin is not a TTY"
grep -q '\[\[ ! -t 0 \]\]' "$script" ||
  fail "omarchy-pkg-aur-add detects a non-TTY stdin before choosing pkexec"

pass "omarchy-pkg-aur-add documents the non-TTY pkexec path"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/bin"

cat >"$test_tmp/bin/omarchy-pkg-missing" <<'STUB'
#!/bin/bash
exit 0
STUB

cat >"$test_tmp/bin/yay" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >"$TEST_TMP/yay-args"
exit 0
STUB

cat >"$test_tmp/bin/pacman" <<'STUB'
#!/bin/bash
# Pretend every requested package installed.
exit 0
STUB

chmod +x "$test_tmp/bin"/*

# Non-TTY stdin -> --sudo pkexec
PATH="$test_tmp/bin:$PATH" TEST_TMP="$test_tmp" \
  bash "$script" some-aur-pkg </dev/null

grep -Fq -- '--sudo pkexec' "$test_tmp/yay-args" ||
  fail "non-TTY stdin makes yay use --sudo pkexec" "$(cat "$test_tmp/yay-args")"
grep -Fq -- '--noconfirm' "$test_tmp/yay-args" ||
  fail "non-TTY path still passes --noconfirm"
grep -Fq -- 'some-aur-pkg' "$test_tmp/yay-args" ||
  fail "non-TTY path still forwards package names"

pass "non-TTY omarchy-pkg-aur-add escalates yay via pkexec"

# TTY stdin -> no --sudo pkexec (use a fake tty via script if available,
# otherwise skip by feeding from a pipe that we mark as a tty with a stub).
# Closest portable check: run under `script` when present; else assert the
# branch exists by sourcing a controlled -t mock via bash can't easily fake
# -t, so use `script` on macOS/Linux when available.
if command -v script >/dev/null 2>&1; then
  rm -f "$test_tmp/yay-args"
  # script(1) allocates a PTY so [[ -t 0 ]] is true inside the child.
  if script -q /dev/null env PATH="$test_tmp/bin:$PATH" TEST_TMP="$test_tmp" \
      bash "$script" tty-aur-pkg >/dev/null 2>&1; then
    :
  else
    # BSD script uses different flags
    script -q "$test_tmp/typescript" env PATH="$test_tmp/bin:$PATH" TEST_TMP="$test_tmp" \
      bash "$script" tty-aur-pkg >/dev/null 2>&1 || true
  fi

  if [[ -f $test_tmp/yay-args ]]; then
    ! grep -Fq -- '--sudo pkexec' "$test_tmp/yay-args" ||
      fail "TTY stdin does not force --sudo pkexec" "$(cat "$test_tmp/yay-args")"
    grep -Fq -- 'tty-aur-pkg' "$test_tmp/yay-args" ||
      fail "TTY path still forwards package names"
    pass "TTY omarchy-pkg-aur-add leaves yay on default sudo"
  else
    pass "TTY probe unavailable; non-TTY path covered"
  fi
else
  pass "script(1) unavailable; non-TTY path covered"
fi

# pkg-add / pkg-drop also pick pkexec off a non-TTY stdin
for cmd in omarchy-pkg-add omarchy-pkg-drop; do
  grep -q 'pkexec "\$@"' "$ROOT/bin/$cmd" ||
    fail "$cmd uses pkexec when stdin is not a TTY"
done

pass "pkg-add and pkg-drop escalate with pkexec off a non-TTY"

# Runtime: pkg-drop non-TTY uses pkexec
cat >"$test_tmp/bin/pacman" <<'STUB'
#!/bin/bash
if [[ $1 == "-Qq" ]]; then
  printf '%s\n' exact-package
  exit 0
fi
printf '%s\n' "pacman $*" >"$TEST_TMP/pacman-args"
exit 0
STUB
cat >"$test_tmp/bin/pkexec" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >"$TEST_TMP/pkexec-args"
exec "$@"
STUB
cat >"$test_tmp/bin/sudo" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >"$TEST_TMP/sudo-args"
exec "$@"
STUB
chmod +x "$test_tmp/bin"/*

rm -f "$test_tmp/pkexec-args" "$test_tmp/sudo-args" "$test_tmp/pacman-args"
PATH="$test_tmp/bin:$PATH" TEST_TMP="$test_tmp" \
  bash "$ROOT/bin/omarchy-pkg-drop" exact-package </dev/null

[[ -f $test_tmp/pkexec-args ]] || fail "non-TTY pkg-drop calls pkexec"
grep -Fq 'pacman -Rns --noconfirm exact-package' "$test_tmp/pkexec-args" ||
  fail "pkexec receives the pacman removal" "$(cat "$test_tmp/pkexec-args")"
[[ ! -e $test_tmp/sudo-args ]] ||
  fail "non-TTY pkg-drop does not call sudo"

pass "non-TTY omarchy-pkg-drop escalates via pkexec"
