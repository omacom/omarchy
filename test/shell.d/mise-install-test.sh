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
case $1 in
  which)
    [[ ${OMARCHY_MISE_TEST_MISSING:-0} != 1 ]] || exit 1
    printf '%s\n' "${OMARCHY_MISE_TEST_RESOLVED:-$OMARCHY_MISE_TEST_REAL_BIN}"
    ;;
  where)
    printf '%s\n' "$OMARCHY_MISE_TEST_TOOL_DIR"
    ;;
  x)
    shift 3
    export OMARCHY_MISE_TEST_ENV=from-mise
    exec "$@"
    ;;
esac
SH
export OMARCHY_MISE_TEST_TOOL_DIR="$tmpdir/tool install"
mkdir -p "$OMARCHY_MISE_TEST_TOOL_DIR"
export OMARCHY_MISE_TEST_REAL_BIN="$OMARCHY_MISE_TEST_TOOL_DIR/real tool"
cat >"$OMARCHY_MISE_TEST_REAL_BIN" <<'SH'
#!/bin/bash
[[ $OMARCHY_MISE_TEST_ENV == from-mise ]] || exit 42
if [[ ${1:-} == nested ]]; then
  exec "$OMARCHY_MISE_TEST_WRAPPER" inner
fi
printf '%s\n' "$@"
SH
chmod +x "$OMARCHY_MISE_TEST_REAL_BIN"

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

# A missing tool must not fall back to an unrelated command on PATH.
install_wrapper missing-tool missing-tool >/dev/null
cat >"$stub_bin/missing-tool" <<'SH'
#!/bin/bash
touch "$OMARCHY_MISE_TEST_UNRELATED"
SH
chmod +x "$stub_bin/missing-tool"
export OMARCHY_MISE_TEST_UNRELATED="$tmpdir/unrelated-ran"
log="$tmpdir/missing.log"
set +e
OMARCHY_MISE_TEST_LOG="$log" OMARCHY_MISE_TEST_MISSING=1 PATH="$home/.local/bin:$stub_bin:$PATH" \
  timeout 2s "$home/.local/bin/missing-tool" >"$tmpdir/out" 2>"$tmpdir/err"
status=$?
set -e
(( status == 127 )) || fail "missing binary fails fast with exit 127" "status=$status"
[[ ! -e $OMARCHY_MISE_TEST_UNRELATED ]] || fail "missing binary never runs an unrelated PATH command"
grep -Fq 'mise could not provide "missing-tool" from tool "missing-tool"' "$tmpdir/err" || fail "missing tool diagnostic names the tool"
pass "missing tool fails fast without a PATH fallback"

# Even a resolver returning this wrapper (directly or through a symlink) must
# not start a recursive mise invocation.
ln -s "$home/.local/bin/missing-tool" "$tmpdir/self-link"
for resolved in "$home/.local/bin/missing-tool" "$tmpdir/self-link" relative-path "$stub_bin/missing-tool"; do
  set +e
  OMARCHY_MISE_TEST_LOG="$log" OMARCHY_MISE_TEST_RESOLVED="$resolved" PATH="$home/.local/bin:$stub_bin:$PATH" \
    timeout 2s "$home/.local/bin/missing-tool" >"$tmpdir/out" 2>"$tmpdir/err"
  status=$?
  set -e
  (( status == 127 )) || fail "invalid or self-resolving binary fails fast" "status=$status path=$resolved"
done
pass "wrapper rejects relative paths, self-resolution, and binaries outside the tool install"

# Valid nested invocations of the same wrapper must retain mise's environment
# and succeed; no inherited recursion flag may block the inner invocation.
log="$tmpdir/nested.log"
output=$(OMARCHY_MISE_TEST_LOG="$log" OMARCHY_MISE_TEST_WRAPPER="$home/.local/bin/playwright" \
  PATH="$home/.local/bin:$stub_bin:$PATH" "$home/.local/bin/playwright" nested)
[[ $output == inner ]] || fail "a real tool can invoke its wrapper again" "$output"
pass "nested wrapper calls succeed with mise's tool environment"

output=$(OMARCHY_MISE_TEST_LOG="$log" PATH="$stub_bin:$PATH" "$home/.local/bin/playwright" 'argument with spaces' '$(literal)' '')
[[ $output == $'argument with spaces\n$(literal)' ]] || fail "absolute execution preserves argument boundaries" "$output"
grep -Fqx $'mise\twhich\t--tool\tnpm:playwright\t--\tplaywright' "$log" || fail "resolver is scoped to the requested package"
pass "package-scoped resolution preserves spaces and literal arguments"

# npm-backed tools commonly expose a symlink inside their installation.
ln -s "$OMARCHY_MISE_TEST_REAL_BIN" "$OMARCHY_MISE_TEST_TOOL_DIR/bin-link"
output=$(OMARCHY_MISE_TEST_LOG="$log" OMARCHY_MISE_TEST_RESOLVED="$OMARCHY_MISE_TEST_TOOL_DIR/bin-link" \
  PATH="$stub_bin:$PATH" "$home/.local/bin/playwright" linked)
[[ $output == linked ]] || fail "a symlink to the tool's real binary remains executable" "$output"
pass "tool-local symlinks resolve and run normally"

# Names embedded in both the resolver and error diagnostic remain shell data.
package='npm:pkg$(touch '"$tmpdir"'/PACKAGE_PWNED)end'
command='hostile$(touch COMMAND_PWNED)'
bin='bin$(touch BIN_PWNED)'
install_wrapper "$package" "$command" "$bin" >/dev/null
log="$tmpdir/hostile-missing.log"
set +e
(cd "$tmpdir"; OMARCHY_MISE_TEST_LOG="$log" OMARCHY_MISE_TEST_MISSING=1 PATH="$stub_bin:$PATH" \
  "$home/.local/bin/$command") >"$tmpdir/out" 2>"$tmpdir/err"
status=$?
set -e
(( status == 127 )) || fail "hostile missing names fail with 127"
for marker in PACKAGE_PWNED COMMAND_PWNED BIN_PWNED; do
  [[ ! -e $tmpdir/$marker ]] || fail "wrapper keeps $marker inert"
done
printf '%s: mise could not provide "%s" from tool "%s" (is it installed?)\n' "$command" "$bin" "$package" >"$tmpdir/expected.err"
cmp -s "$tmpdir/expected.err" "$tmpdir/err" || fail "diagnostic contains literal names" "$(cat "$tmpdir/err")"
printf 'mise\tuse\t-g\t--quiet\t%s\nmise\twhich\t--tool\t%s\t--\t%s\n' "$package" "$package" "$bin" >"$tmpdir/expected.log"
cmp -s "$tmpdir/expected.log" "$log" || fail "resolver receives literal hostile names" "$(cat "$log")"
pass "resolution and diagnostics keep package, command, and bin names inert"
