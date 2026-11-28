#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT

fake_home="$work_dir/home"
hooks="$fake_home/.config/omarchy/hooks"
mkdir -p "$hooks/theme-set.d" "$work_dir/bin"

# Stands in for ImageMagick's import, which a Python hook's `import colorsys`
# line reaches when bash parses the file, and which then waits for a click.
cat >"$work_dir/bin/import" <<SH
#!/bin/bash
touch "$work_dir/import-ran"
SH
chmod +x "$work_dir/bin/import"

# A non-bash interpreter, so the hook only works when its shebang is honoured.
cat >"$work_dir/interpreter" <<SH
#!/bin/bash
printf '%s\n' "\$2" >"$work_dir/interpreted"
SH
chmod +x "$work_dir/interpreter"

cat >"$hooks/theme-set.d/10-foreign" <<SH
#!$work_dir/interpreter
import colorsys
SH
chmod +x "$hooks/theme-set.d/10-foreign"

PATH="$work_dir/bin:$PATH" HOME="$fake_home" "$ROOT/bin/omarchy-hook" theme-set ethereal >/dev/null
[[ ! -e $work_dir/import-ran ]] ||
  fail "omarchy hook does not run an executable hook through bash"
[[ $(<"$work_dir/interpreted") == "ethereal" ]] ||
  fail "omarchy hook runs an executable hook under its shebang with its arguments"
pass "omarchy hook runs an executable hook under its shebang"

rm -f "$hooks/theme-set.d/10-foreign" "$work_dir/interpreted"

# The flat hook file beside the .d directory is dispatched the same way.
cat >"$hooks/font-set" <<SH
#!$work_dir/interpreter
import colorsys
SH
chmod +x "$hooks/font-set"

PATH="$work_dir/bin:$PATH" HOME="$fake_home" "$ROOT/bin/omarchy-hook" font-set iosevka >/dev/null
[[ ! -e $work_dir/import-ran && $(<"$work_dir/interpreted") == "iosevka" ]] ||
  fail "omarchy hook runs an executable flat hook under its shebang"
pass "omarchy hook runs an executable flat hook under its shebang"

# An executable hook without a shebang still runs as a shell script.
cat >"$hooks/theme-set.d/20-no-shebang" <<'SH'
touch "$HOME/no-shebang-ran"
SH
chmod +x "$hooks/theme-set.d/20-no-shebang"

# A renamed .sample is not executable and still runs through bash.
cat >"$hooks/theme-set.d/30-not-executable" <<'SH'
#!/bin/bash
touch "$HOME/not-executable-ran"
SH
chmod -x "$hooks/theme-set.d/30-not-executable"

HOME="$fake_home" "$ROOT/bin/omarchy-hook" theme-set ethereal >/dev/null
[[ -f $fake_home/no-shebang-ran ]] ||
  fail "omarchy hook runs an executable hook without a shebang"
pass "omarchy hook runs an executable hook without a shebang"
[[ -f $fake_home/not-executable-ran ]] ||
  fail "omarchy hook runs a hook that is not executable through bash"
pass "omarchy hook runs a hook that is not executable through bash"
