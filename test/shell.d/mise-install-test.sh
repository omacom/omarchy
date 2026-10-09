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

# Updates rerun every install, so a file the user put at one of these paths has
# to survive it. A wrapper of their own is the likely one.
own="$home/.local/bin/claude"
printf '#!/bin/sh\nexport ANTHROPIC_BASE_URL=https://proxy.example\nexec /opt/claude/bin/claude "$@"\n' >"$own"
cp "$own" "$tmpdir/own.expected"

install_wrapper claude >/dev/null 2>"$tmpdir/err" ||
  fail "leaving the user's file in place does not fail the install"
cmp -s "$own" "$tmpdir/own.expected" ||
  fail "a file Omarchy did not write is left as it was" "$(cat "$own")"
grep -Fq 'not a wrapper Omarchy wrote' "$tmpdir/err" ||
  fail "leaving it says why" "$(cat "$tmpdir/err")"

# One that only looks like Omarchy's, with the user's own change, is theirs too.
edited_wrappers=(
  $'#!/bin/bash\nmise use -g "gh" || exit 1\nexec env GH_HOST=git.example mise x "gh" -- "gh" "$@"\n'
  $'#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nexport GH_HOST=git.example\nmise use -g --quiet "gh" || exit 1\nexec mise x "gh" -- "gh" "$@"\n'
)

for edited in "${edited_wrappers[@]}"; do
  printf '%s' "$edited" >"$home/.local/bin/gh"
  install_wrapper gh >/dev/null 2>&1
  [[ $(<"$home/.local/bin/gh") == "${edited%$'\n'}" ]] ||
    fail "an edited wrapper is left as it was" "$(cat "$home/.local/bin/gh")"
done

# Reading a file into a variable drops NULs, which must not hide an edit.
printf '#!/bin/bash\nmise use -g "gh"\nexec "gh" "$@"\n\0' >"$home/.local/bin/gh"
install_wrapper gh >/dev/null 2>&1
grep -Fqx 'exec "gh" "$@"' "$home/.local/bin/gh" ||
  fail "a wrapper with a NUL in it is left as it was"

mkfifo "$home/.local/bin/copilot"
install_wrapper copilot >/dev/null 2>&1
[[ -p $home/.local/bin/copilot ]] || fail "something other than a file is left as it was"
rm -f "$home/.local/bin/gh" "$home/.local/bin/copilot"

pass "a file Omarchy did not write survives a reinstall"

# Every form the generator has written is still replaced, so updates keep moving
# old wrappers forward.
legacy_wrappers=(
  $'#!/bin/bash\nmise use -g "gh"\nexec "gh" "$@"\n'
  $'#!/bin/bash\nmise use -g "gh"\nexec mise exec "gh" -- "gh" "$@"\n'
  $'#!/bin/bash\nmise use -g "gh" || exit 1\nexec mise x "gh" -- "gh" "$@"\n'
  $'#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g "gh" || exit 1\nexec mise x "gh" -- "gh" "$@"\n'
  $'#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g --quiet "gh" || exit 1\nexec mise x "gh" -- "gh" "$@"\n'
)

for legacy in "${legacy_wrappers[@]}"; do
  printf '%s' "$legacy" >"$home/.local/bin/gh"
  install_wrapper gh >/dev/null 2>"$tmpdir/err" || fail "an older wrapper is replaced" "$(cat "$tmpdir/err")"
  grep -Fqx 'mise use -g --quiet "gh" || exit 1' "$home/.local/bin/gh" ||
    fail "an older wrapper is rewritten in the current form" "was: $legacy"$'\n'"now: $(cat "$home/.local/bin/gh")"
done

# The names install/user/mise.sh passes carry scopes, URLs and brackets.
for spec in "npm:@kitlangton/ghui ghui" "http:muse[url=https://example.com/muse.sh,bin=muse] muse"; do
  read -r package name <<<"$spec"
  install_wrapper "$package" "$name" >/dev/null
  install_wrapper "$package" "$name" >/dev/null 2>"$tmpdir/err"
  [[ -s $tmpdir/err ]] && fail "a reinstall of $name replaces its own wrapper" "$(cat "$tmpdir/err")"
done

pass "every wrapper form Omarchy has written is replaced"

# The generator has always written regular scripts. A link belongs to another
# installer or to the user, even if its target looks like an Omarchy wrapper.
# Native providers are never executed; only link text and target bytes matter.
check_link() {
  local description=$1 command=$2 link=$3 target=${4:-}
  local entry="$home/.local/bin/$command" mode
  rm -f "$entry"
  ln -s -- "$link" "$entry"
  if [[ -n $target ]]; then
    cp "$target" "$tmpdir/link-target.expected"
    mode=$(stat -c '%a' "$target")
  fi

  install_wrapper "$command" >/dev/null 2>"$tmpdir/err" || fail "$description does not stop the reinstall"
  [[ -L $entry && $(readlink "$entry") == "$link" ]] || fail "$description preserves the original link"
  grep -Fq 'not a wrapper Omarchy wrote' "$tmpdir/err" || fail "$description explains why the link is kept"
  if [[ -n $target ]]; then
    cmp -s "$target" "$tmpdir/link-target.expected" || fail "$description keeps target bytes"
    [[ $(stat -c '%a' "$target") == "$mode" ]] || fail "$description keeps target permissions"
  fi
  pass "$description"
}

native="$home/.local/share/claude/versions/fixture-native"
mkdir -p "${native%/*}"
printf 'native Claude fixture\0retained\n' >"$native"
chmod 750 "$native"
check_link "an absolute native Claude link survives reinstall" claude "$native" "$native"
check_link "a relative native Claude link survives reinstall" claude '../share/claude/versions/fixture-native' "$native"
check_link "a dangling native Claude link survives reinstall" claude '../share/claude/versions/missing-native'
[[ ! -e $home/.local/share/claude/versions/missing-native ]] || fail "a dangling link does not create its target"

linked_wrapper="$tmpdir/linked-gh-wrapper"
printf '%s' "${legacy_wrappers[0]}" >"$linked_wrapper"
chmod 750 "$linked_wrapper"
check_link "a link to an exact historical wrapper remains user-owned" gh "$linked_wrapper" "$linked_wrapper"

# A target inside Mise's installs is not evidence that Omarchy created the
# link. Preserve a user's pinned link there too.
pinned="$home/.local/share/mise/installs/codex/fixture-version/bin/codex"
mkdir -p "${pinned%/*}"
printf 'pinned Mise fixture\n' >"$pinned"
chmod 750 "$pinned"
check_link "a user link into a Mise install survives reinstall" codex "$pinned" "$pinned"

# The actual refresh leaf reruns every wrapper install. It must preserve native
# routing while continuing to refresh regular generated wrappers. Mise and
# command probes are stubs, so no package/provider operation runs.
rm -f "$home/.local/bin/claude" "$home/.local/bin/gh"
ln -s '../share/claude/versions/fixture-native' "$home/.local/bin/claude"
printf '%s' "${legacy_wrappers[0]}" >"$home/.local/bin/gh"
cp "$native" "$tmpdir/native.expected"
printf '#!/bin/bash\nexit 0\n' >"$stub_bin/omarchy-cmd-missing"
chmod +x "$stub_bin/omarchy-cmd-missing"
: >"$tmpdir/refresh.log"
HOME="$home" OMARCHY_MISE_TEST_LOG="$tmpdir/refresh.log" PATH="$stub_bin:$ROOT/bin:$PATH" \
  bash "$ROOT/install/user/mise.sh" >/dev/null 2>"$tmpdir/err"
[[ -L $home/.local/bin/claude && $(readlink "$home/.local/bin/claude") == '../share/claude/versions/fixture-native' ]] ||
  fail "refresh keeps the native Claude launcher"
cmp -s "$native" "$tmpdir/native.expected" || fail "refresh leaves native Claude bytes alone"
[[ $(stat -c '%a' "$native") == "750" ]] || fail "refresh leaves native Claude permissions alone"
grep -Fqx 'mise use -g --quiet "gh" || exit 1' "$home/.local/bin/gh" || fail "refresh still updates a regular historical wrapper"
[[ -f $home/.local/bin/opencode && ! -L $home/.local/bin/opencode && -x $home/.local/bin/opencode ]] ||
  fail "refresh still generates an absent regular wrapper"
pass "the actual Mise refresh preserves native links and refreshes regular wrappers"
