#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

home="$tmpdir/home"
stub_bin="$tmpdir/bin"
mkdir -p "$home" "$stub_bin"

# Stands in for the real mise so a generated wrapper can be run and asked what
# arguments it passed on.
cat >"$stub_bin/mise" <<'SH'
#!/bin/bash

printf 'mise' >>"$OMARCHY_MISE_TEST_LOG"
for arg in "$@"; do
  printf '\t%s' "$arg" >>"$OMARCHY_MISE_TEST_LOG"
done
printf '\n' >>"$OMARCHY_MISE_TEST_LOG"
SH
chmod +x "$stub_bin/mise"

install_wrapper() {
  HOME="$home" "$ROOT/bin/omarchy-mise-install" "$@"
}

# The ordinary case still works, and every call site in install/user/mise.sh
# passes names of this shape.
install_wrapper npm:playwright playwright >/dev/null
[[ -x $home/.local/bin/playwright ]] ||
  fail "a normal install writes an executable wrapper"

log="$tmpdir/normal.log"
: >"$log"
OMARCHY_MISE_TEST_LOG="$log" PATH="$stub_bin:$PATH" "$home/.local/bin/playwright" >/dev/null
grep -Fqx $'mise\tuse\t-g\t--quiet\tnpm:playwright' "$log" ||
  fail "the wrapper asks mise for the package it was given" "$(cat "$log")"

pass "a normal install writes a wrapper that names its package"

# A package name is data. Quoted with %q it reaches mise as one argument
# instead of being read as shell source when the wrapper runs.
install_wrapper 'npm:pkg$(touch '"$tmpdir"'/PWNED)end' hostile >/dev/null

log="$tmpdir/hostile.log"
: >"$log"
OMARCHY_MISE_TEST_LOG="$log" PATH="$stub_bin:$PATH" "$home/.local/bin/hostile" >/dev/null

[[ -e $tmpdir/PWNED ]] &&
  fail "a package name with shell characters does not run when the wrapper does" \
    "wrapper: $(cat "$home/.local/bin/hostile")"

grep -Fqx $'mise\tuse\t-g\t--quiet\tnpm:pkg$(touch '"$tmpdir"'/PWNED)end' "$log" ||
  fail "the package reaches mise whole" "$(cat "$log")"

pass "a package name with shell characters reaches mise as one argument"

# The command name is a file name under ~/.local/bin. These shapes escape it,
# hide it, make something that reads as an option, or carry characters that have
# no business in a file name. Labelled so a newline in the value does not end up
# inside the test output.
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

  if install_wrapper somepkg "$name" >/dev/null 2>"$tmpdir/err"; then
    fail "a command name with $label is refused"
  fi
  grep -Fq 'is not usable as a command name' "$tmpdir/err" ||
    fail "the refusal says why for a command name with $label" "$(cat "$tmpdir/err")"
done

pass "command names that are not plain file names are refused"

# The refusal has to land before the rm, which would otherwise delete the
# escaped path on its way to failing.
victim="$tmpdir/victim"
printf 'keep me\n' >"$victim"
if install_wrapper somepkg "../../../..$victim" >/dev/null 2>&1; then
  fail "an escaping command name is refused"
fi
[[ -f $victim ]] ||
  fail "an escaping command name removes nothing outside ~/.local/bin"

pass "an escaping command name removes nothing outside ~/.local/bin"

# A wrapper the user wrote at the same path is theirs, whatever it calls. Leaving
# it is a success, or a migration installing that command stops every one after it.
user_wrappers=(
  "an unquoted exec" $'#!/bin/sh\nexport ANTHROPIC_BASE_URL=https://my-proxy\nexec /opt/claude/bin/claude "$@"\n'
  "a quoted exec" $'#!/bin/bash\nexport ANTHROPIC_BASE_URL=https://my-proxy\nexec "/opt/claude/bin/claude" "$@"\n'
  "a pinned mise x" $'#!/bin/bash\nexport ANTHROPIC_BASE_URL=https://my-proxy\nexec mise x claude@2.0.1 -- claude "$@"\n'
  "an extra argument" $'#!/bin/bash\nmise use -g "claude" || exit 1\nexec mise x "claude" -- "claude" --model opus "$@"\n'
  "an extra command" $'#!/bin/bash\nmise use -g "claude"; export ANTHROPIC_BASE_URL=https://my-proxy\nexec mise x "claude" -- "claude" "$@"\n'
  "a redirect" $'#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g --quiet claude || exit 1\nexec mise x claude -- claude</dev/null "$@"\n'
  "a binary of its own" $'#!/bin/bash\nmise use -g "claude" || exit 1\nexec mise x "claude" -- "/opt/claude/bin/claude" "$@"\n'
)

for (( i = 0; i < ${#user_wrappers[@]}; i += 2 )); do
  label=${user_wrappers[i]}
  printf '%s' "${user_wrappers[i + 1]}" >"$home/.local/bin/claude"

  install_wrapper claude >/dev/null 2>"$tmpdir/err" ||
    fail "a user's wrapper with $label is left without failing" "$(cat "$tmpdir/err")"
  [[ $(cat "$home/.local/bin/claude") == "$(printf '%s' "${user_wrappers[i + 1]}")" ]] ||
    fail "a user's wrapper with $label is left as it was" "$(cat "$home/.local/bin/claude")"
done

pass "a user's own wrapper is left alone"

# Every form a previous install or migration wrote is still regenerated.
generated_wrappers=(
  "the current form" "$(cat "$home/.local/bin/playwright")"
  "the cooldown form" $'#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g "npm:playwright" || exit 1\nexec mise x "npm:playwright" -- "playwright" "$@"'
  "the bail-on-failure form" $'#!/bin/bash\nmise use -g "npm:playwright" || exit 1\nexec mise x "npm:playwright" -- "playwright" "$@"'
  "the mise exec form" $'#!/bin/bash\nmise use -g "npm:playwright"\nexec mise exec "npm:playwright" -- "playwright" "$@"'
  "the bare exec form" $'#!/bin/bash\nmise use -g "npm:playwright"\nexec "playwright" "$@"'
)

for (( i = 0; i < ${#generated_wrappers[@]}; i += 2 )); do
  label=${generated_wrappers[i]}
  printf '%s' "${generated_wrappers[i + 1]}" >"$home/.local/bin/playwright"

  install_wrapper npm:playwright playwright >/dev/null
  grep -Fqx 'mise use -g --quiet "npm:playwright" || exit 1' "$home/.local/bin/playwright" ||
    fail "a wrapper in $label is regenerated" "$(cat "$home/.local/bin/playwright")"
done

install_wrapper 'npm:pkg$(touch '"$tmpdir"'/PWNED)end' hostile >/dev/null 2>"$tmpdir/err"
[[ ! -s $tmpdir/err ]] ||
  fail "a wrapper with %q-quoted arguments is regenerated" "$(cat "$tmpdir/err")"

pass "a wrapper in any generated form is regenerated"

# A link is dropped, never written through into the binary it points at.
printf 'real binary\n' >"$tmpdir/real-binary"
ln -sfn "$tmpdir/real-binary" "$home/.local/bin/linked"
install_wrapper somepkg linked >/dev/null
[[ ! -L $home/.local/bin/linked && $(cat "$tmpdir/real-binary") == "real binary" ]] ||
  fail "a symlink is replaced without touching its target"

pass "a symlink is replaced without touching its target"

# A directory in the way leaves no command at all, so that is still a failure.
mkdir -p "$home/.local/bin/blocked"
if install_wrapper somepkg blocked >/dev/null 2>&1; then
  fail "a directory in the way is reported as a failure"
fi

pass "a directory in the way is reported as a failure"
