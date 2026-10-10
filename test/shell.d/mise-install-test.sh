#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

home="$tmpdir/home"
stub_bin="$tmpdir/bin"
mkdir -p "$home" "$stub_bin"

# Stands in for the real mise so install and the generated wrapper can be run
# and asked what arguments they passed on.
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
  HOME="$home" PATH="$stub_bin:$PATH" OMARCHY_MISE_TEST_LOG="$1" \
    "$ROOT/bin/omarchy-mise-install" "${@:2}"
}

# The ordinary case still works, and every call site in install/user/mise.sh
# passes names of this shape. Install pins once; the wrapper only execs.
install_log="$tmpdir/install-normal.log"
: >"$install_log"
install_wrapper "$install_log" npm:playwright playwright >/dev/null
[[ -x $home/.local/bin/playwright ]] ||
  fail "a normal install writes an executable wrapper"
grep -Fqx $'mise\tuse\t-g\t--quiet\tnpm:playwright' "$install_log" ||
  fail "install pins the package once" "$(cat "$install_log")"

run_log="$tmpdir/run-normal.log"
: >"$run_log"
OMARCHY_MISE_TEST_LOG="$run_log" PATH="$stub_bin:$PATH" "$home/.local/bin/playwright" >/dev/null
grep -Fqx $'mise\tx\tnpm:playwright\t--\tplaywright' "$run_log" ||
  fail "the wrapper only execs the package" "$(cat "$run_log")"
if grep -q $'\tuse\t' "$run_log"; then
  fail "the wrapper must not call mise use" "$(cat "$run_log")"
fi

pass "a normal install writes an exec-only wrapper that names its package"

# A package name is data. Quoted with %q it reaches mise as one argument
# instead of being read as shell source when the wrapper runs.
install_log="$tmpdir/install-hostile.log"
: >"$install_log"
install_wrapper "$install_log" 'npm:pkg$(touch '"$tmpdir"'/PWNED)end' hostile >/dev/null

run_log="$tmpdir/run-hostile.log"
: >"$run_log"
OMARCHY_MISE_TEST_LOG="$run_log" PATH="$stub_bin:$PATH" "$home/.local/bin/hostile" >/dev/null

[[ -e $tmpdir/PWNED ]] &&
  fail "a package name with shell characters does not run when the wrapper does" \
    "wrapper: $(cat "$home/.local/bin/hostile")"

grep -Fq $'mise\tx\tnpm:pkg$(touch ' "$run_log" ||
  fail "the package reaches mise whole" "$(cat "$run_log")"
grep -Fq $'\t--\thostile' "$run_log" ||
  fail "the bin reaches mise whole" "$(cat "$run_log")"
grep -Fq 'PWNED' "$run_log" ||
  fail "the hostile package name is preserved in the mise argv" "$(cat "$run_log")"

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

  if install_wrapper "$tmpdir/refused.log" somepkg "$name" >/dev/null 2>"$tmpdir/err"; then
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
if install_wrapper "$tmpdir/escape.log" somepkg "../../../..$victim" >/dev/null 2>&1; then
  fail "an escaping command name is refused"
fi
[[ -f $victim ]] ||
  fail "an escaping command name removes nothing outside ~/.local/bin"

pass "an escaping command name removes nothing outside ~/.local/bin"
