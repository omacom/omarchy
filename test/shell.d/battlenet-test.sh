#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

install_script="$ROOT/bin/omarchy-install-gaming-battlenet"
remove_script="$ROOT/bin/omarchy-remove-gaming-battlenet"

[[ ! -f $ROOT/applications/battlenet.desktop ]] || fail "Battle.net launcher is not part of default application refresh"
[[ -f $ROOT/default/applications/battlenet.desktop ]] || fail "Battle.net launcher template is available to the installer"
grep -F '$OMARCHY_PATH/default/applications/battlenet.desktop' "$install_script" >/dev/null ||
  fail "Battle.net installer installs the launcher from the installer-only template"

# The removal script must ask before deleting the prefix: the folder can hold
# games installed by other tools (Lutris keeps its Battle.net prefix there),
# and the umu / GE-Proton questions come after the prefix is already gone.

grep -nF 'gum confirm' "$remove_script" >/dev/null ||
  fail "Battle.net removal asks for confirmation"

prefix_line=$(grep -nF 'rm -rf "$PREFIX"' "$remove_script" | head -1 | cut -d: -f1)
confirm_line=$(grep -nF 'gum confirm' "$remove_script" | head -1 | cut -d: -f1)
[[ -n $prefix_line && -n $confirm_line && $confirm_line -lt $prefix_line ]] ||
  fail "Battle.net removal confirmation precedes the prefix deletion"

grep -qF 'battlenet.removePrefix' "$ROOT/default/i18n/en/cli.json" ||
  fail "Battle.net removal prompt is in the English catalog"
grep -qF 'battlenet.removeCancelled' "$ROOT/default/i18n/en/cli.json" ||
  fail "Battle.net removal cancelled message is in the English catalog"

# Behavioral check in a sandbox home: answering No deletes nothing, answering
# Yes removes the prefix, desktop entry and cached installer.

sandbox=$(mktemp -d)
trap 'rm -rf "$sandbox"' EXIT

stub_bin="$sandbox/bin"
mkdir -p "$stub_bin" "$sandbox/home/Games/battlenet/game files" "$sandbox/home/.local/share/applications" "$sandbox/home/.cache/omarchy"

cat >"$stub_bin/gum" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$GUM_LOG"
[[ $GUM_ANSWER == yes ]]
SH

cat >"$stub_bin/omarchy-i18n" <<'SH'
#!/bin/bash
printf '%s\n' "$1"
SH

cat >"$stub_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
exit 1
SH

cat >"$stub_bin/pkill" <<'SH'
#!/bin/bash
exit 1
SH

chmod +x "$stub_bin/gum" "$stub_bin/omarchy-i18n" "$stub_bin/omarchy-pkg-present" "$stub_bin/pkill"

seed_sandbox() {
  mkdir -p "$sandbox/home/Games/battlenet/game files" "$sandbox/home/.local/share/applications" "$sandbox/home/.cache/omarchy"
  printf wow >"$sandbox/home/Games/battlenet/game files/Wow.exe"
  printf launcher >"$sandbox/home/.local/share/applications/battlenet.desktop"
  printf setup >"$sandbox/home/.cache/omarchy/Battle.net-Setup.exe"
}

run_remove() {
  GUM_ANSWER=$1 GUM_LOG="$sandbox/gum.log" HOME="$sandbox/home" PATH="$stub_bin:$PATH" \
    bash "$remove_script" >/dev/null 2>&1
}

: >"$sandbox/gum.log"
seed_sandbox
run_remove no
[[ -f "$sandbox/home/Games/battlenet/game files/Wow.exe" ]] ||
  fail "Declining the Battle.net removal prompt keeps the prefix"
[[ -f "$sandbox/home/.local/share/applications/battlenet.desktop" ]] ||
  fail "Declining the Battle.net removal prompt keeps the desktop entry"
grep -qF 'battlenet.removePrefix' "$sandbox/gum.log" ||
  fail "Battle.net removal asks before deleting anything"

: >"$sandbox/gum.log"
seed_sandbox
run_remove yes
[[ ! -e "$sandbox/home/Games/battlenet" ]] ||
  fail "Accepting the Battle.net removal prompt deletes the prefix"
[[ ! -e "$sandbox/home/.local/share/applications/battlenet.desktop" ]] ||
  fail "Accepting the Battle.net removal prompt deletes the desktop entry"
[[ ! -e "$sandbox/home/.cache/omarchy/Battle.net-Setup.exe" ]] ||
  fail "Accepting the Battle.net removal prompt deletes the cached installer"

pass "Battle.net removal asks for confirmation and keeps the prefix on a declined prompt"
