#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mkdir -p "$mock_bin"
ln -s "$ROOT/bin/omarchy-cmd-hermes-home" "$mock_bin/omarchy-cmd-hermes-home"

cat >"$mock_bin/omarchy-pkg-drop" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >>"$OMARCHY_TEST_DROP_LOG"
SH

# The CLI teardown is the installer's own, exercised in hermes-cli-test.sh; here
# it is mocked to a logger so this test stays about what Remove Hermes does with
# ~/.hermes, and to keep real mise out of a run with HOME pointed at a fixture.
cat >"$mock_bin/omarchy-install-hermes-cli" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >>"$OMARCHY_TEST_INSTALLER_LOG"
printf '%s\n' "$HERMES_HOME" >"$OMARCHY_TEST_HOME_LOG"
exit "${OMARCHY_TEST_INSTALLER_STATUS:-0}"
SH

# The remover asks through gum whether the user's data should go too. The stub
# answers "no" unless a test says otherwise, and logs every call: a real gum
# would hang a test run, and one that answered "yes" on its own would be the
# very data loss the default-no exists to prevent.
cat >"$mock_bin/gum" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >>"$OMARCHY_TEST_GUM_LOG"
exit "${OMARCHY_TEST_GUM_STATUS:-1}"
SH
cat >"$mock_bin/systemctl" <<'SH'
#!/bin/bash
echo "systemctl $*" >>"$OMARCHY_TEST_SYSTEMCTL_LOG"
SH

chmod +x "$mock_bin"/*

seed_install() {
  rm -rf "$test_home"
  mkdir -p "$test_home/.hermes/hermes-agent" "$test_home/.hermes/bootstrap-cache" \
    "$test_home/.hermes/bin" "$test_home/.hermes/node/bin" \
    "$test_home/.hermes/memories" "$test_home/.hermes/sessions" \
    "$test_home/.config/Hermes" "$test_home/.local/bin"
  printf 'chat\n' >"$test_home/.hermes/sessions/one.json"
  printf 'memory\n' >"$test_home/.hermes/memories/one.md"
  printf 'soul\n' >"$test_home/.hermes/SOUL.md"
  printf 'uv\n' >"$test_home/.hermes/bin/uv"
  ln -sf "$test_home/.hermes/node/bin/node" "$test_home/.local/bin/node"
  ln -sf "$test_home/.hermes/node/bin/npm" "$test_home/.local/bin/npm"
  ln -sf /usr/bin/npx "$test_home/.local/bin/npx"
  printf 'node\n' >"$test_home/.hermes/node/bin/node"
  printf '{"schemaVersion":1,"pinnedCommit":"e624e9fde561e1add9388384012b295fde669ade"}\n' >"$test_home/.hermes/hermes-agent/.hermes-bootstrap-complete"
  git init -q -b main "$test_home/.hermes/hermes-agent"
  git -C "$test_home/.hermes/hermes-agent" remote add origin https://github.com/NousResearch/hermes-agent.git
  printf '.omarchy-hermes-desktop\n.hermes-bootstrap-complete\n' >>"$test_home/.hermes/hermes-agent/.git/info/exclude"
  echo upstream >"$test_home/.hermes/hermes-agent/README.md"
  git -C "$test_home/.hermes/hermes-agent" add README.md
  git -C "$test_home/.hermes/hermes-agent" -c user.name=Fixture -c user.email=fixture@example.invalid commit --quiet -m baseline
  git -C "$test_home/.hermes/hermes-agent" update-ref refs/remotes/origin/main HEAD
}

# </dev/null pins stdin off a terminal, so these runs exercise the
# non-interactive path no matter where the suite itself is running.
remove() {
  : >"$test_tmp/installer-log"
  : >"$test_tmp/gum-log"
  : >"$test_tmp/systemctl-log"
  OMARCHY_TEST_DROP_LOG="$test_tmp/drop-log" \
    OMARCHY_TEST_INSTALLER_LOG="$test_tmp/installer-log" \
    OMARCHY_TEST_HOME_LOG="$test_tmp/home-log" \
    OMARCHY_TEST_INSTALLER_STATUS="${OMARCHY_TEST_INSTALLER_STATUS:-0}" \
    OMARCHY_TEST_SYSTEMCTL_LOG="$test_tmp/systemctl-log" \
    OMARCHY_TEST_GUM_LOG="$test_tmp/gum-log" \
    HERMES_HOME="${OMARCHY_TEST_HERMES_HOME:-$test_home/.hermes}" \
    XDG_DATA_HOME="$test_home/.local/share" \
    HOME="$test_home" PATH="$mock_bin:$PATH" \
    bash "$ROOT/bin/omarchy-remove-ai-hermes" </dev/null >/dev/null 2>&1
}

# script(1) puts the remover on a pty, which is the only way -t 0 answers true
# without a person at a real one; the stubbed gum then supplies the answer.
remove_tty() {
  : >"$test_tmp/installer-log"
  : >"$test_tmp/gum-log"
  : >"$test_tmp/systemctl-log"
  OMARCHY_TEST_DROP_LOG="$test_tmp/drop-log" \
    OMARCHY_TEST_INSTALLER_LOG="$test_tmp/installer-log" \
    OMARCHY_TEST_HOME_LOG="$test_tmp/home-log" \
    OMARCHY_TEST_SYSTEMCTL_LOG="$test_tmp/systemctl-log" \
    OMARCHY_TEST_GUM_LOG="$test_tmp/gum-log" \
    OMARCHY_TEST_GUM_STATUS="${OMARCHY_TEST_GUM_STATUS:-1}" \
    HERMES_HOME="${OMARCHY_TEST_HERMES_HOME:-$test_home/.hermes}" \
    XDG_DATA_HOME="$test_home/.local/share" \
    HOME="$test_home" PATH="$mock_bin:$PATH" \
    script -qec "bash '$ROOT/bin/omarchy-remove-ai-hermes'" /dev/null >/dev/null 2>&1
}

# The app brings its own uv and its own node; both are runtime, not data.
seed_install
printf '%s\n' '#!/usr/bin/env bash' 'unset PYTHONPATH' 'unset PYTHONHOME' "exec \"$test_home/.hermes/hermes-agent/venv/bin/python\" \"$test_home/.hermes/hermes-agent/hermes\" \"\$@\"" \
  >"$test_home/.local/bin/hermes"
remove || fail "remove succeeds"
[[ ! -d $test_home/.hermes/hermes-agent ]] || fail "the runtime checkout is removed"
[[ ! -d $test_home/.hermes/bin ]] || fail "the uv the app installed is removed"
[[ ! -d $test_home/.hermes/node ]] || fail "the node the app installed is removed"
pass "removal takes the whole runtime the app installed"

grep -Fxq 'systemctl --user stop omarchy-hermes-theme.service' "$test_tmp/systemctl-log" ||
  fail "the unit the installer left waiting to hand over the theme is stopped" "$(cat "$test_tmp/systemctl-log")"
pass "removal stops the installer's theme hand-over"

[[ -d $test_home/.config/Hermes ]] ||
  fail "gateway connections, tokens and settings survive removal"
pass "removal keeps the app's connections and settings"

# -L, not -e: a dangling symlink fails -e while very much still being there.
[[ ! -L $test_home/.local/bin/node ]] || fail "a node symlink into ~/.hermes is removed"
[[ ! -L $test_home/.local/bin/npm ]] || fail "an npm symlink into ~/.hermes is removed"
[[ -L $test_home/.local/bin/npx ]] || fail "an npx symlink pointing elsewhere survives"
pass "removal clears only the managed Node links it stranded"

[[ -f $test_home/.hermes/sessions/one.json ]] || fail "chats survive removal"
[[ -f $test_home/.hermes/memories/one.md ]] || fail "memories survive removal"
[[ -f $test_home/.hermes/SOUL.md ]] || fail "SOUL.md survives removal"
pass "removal keeps what belongs to the user"

# Without a terminal there is nobody to ask, so gum must not even be reached:
# a gum that answered "yes" on its own would be a data loss.
[[ ! -s $test_tmp/gum-log ]] ||
  fail "removal does not ask about the user's data without a terminal"
pass "removal keeps the user's data unasked when there is no terminal"

[[ ! -e $test_home/.local/bin/hermes ]] || fail "the app's own hermes command is removed"
pass "removal takes the command the app installed"

# Removal also asks the installer to tear down a mise CLI the app superseded, so
# a copy left from before the app took over does not linger once Hermes is gone.
tr '\0' '\n' <"$test_tmp/installer-log" | grep -qx -- '--remove' ||
  fail "removal asks the installer to tear down its own CLI"
pass "removal tears down the mise CLI through the installer"

# A hermes command the app did not write survives even when the app did install
# a runtime of its own.
seed_install
printf '%s\n' "#!/bin/bash" "exec /usr/local/bin/my-own-hermes \"\$@\"" \
  >"$test_home/.local/bin/hermes"
remove || fail "remove succeeds with a foreign hermes present"
[[ -f $test_home/.local/bin/hermes ]] ||
  fail "a hermes command the app did not write survives removal"
pass "removal leaves a hermes it does not own"

# Installed but never launched. The app provisions its runtime on first launch
# and marks it complete when it lands, so without that marker everything under
# ~/.hermes predates the app -- an official install, or one built by hand -- and
# the paths are identical either way. Dropping the package is the whole job.
seed_install
rm -f "$test_home/.hermes/hermes-agent/.hermes-bootstrap-complete"
printf 'my local edit\n' >"$test_home/.hermes/hermes-agent/PATCH"
printf '%s\n' '#!/usr/bin/env bash' 'unset PYTHONPATH' 'unset PYTHONHOME' "exec \"$test_home/.hermes/hermes-agent/venv/bin/python\" \"$test_home/.hermes/hermes-agent/hermes\" \"\$@\"" \
  >"$test_home/.local/bin/hermes"
remove || fail "remove succeeds when the app never finished installing Hermes"
# The stranded pre-desktop CLI is exactly the interrupted-install case, so the
# teardown must be asked for here too, not only when the app's runtime landed.
tr '\0' '\n' <"$test_tmp/installer-log" | grep -qx -- '--remove' ||
  fail "removal tears down the CLI even when the app never finished installing"
[[ -d $test_home/.hermes/hermes-agent ]] ||
  fail "a Hermes runtime the app never installed survives removal"
[[ -f $test_home/.hermes/hermes-agent/PATCH ]] ||
  fail "local changes to a runtime the app never installed survive removal"
[[ -d $test_home/.hermes/bin && -d $test_home/.hermes/node ]] ||
  fail "the rest of a runtime the app never installed survives removal"
[[ -f $test_home/.local/bin/hermes ]] ||
  fail "the command a runtime the app never installed put on PATH survives removal"
[[ -L $test_home/.local/bin/node ]] ||
  fail "node links belonging to a runtime the app never installed survive removal"
pass "removal leaves a Hermes the app never installed"

# ~/.hermes carries a dot, so a pattern rather than a plain string would also
# claim a wrapper pointing at a sibling directory that merely looks like it.
seed_install
mkdir -p "$test_home/xhermes/bin"
sibling_body="#!/bin/bash
exec $test_home/xhermes/bin/hermes \"\$@\""
printf '%s\n' "$sibling_body" >"$test_home/.local/bin/hermes"
remove || fail "remove succeeds with a wrapper pointing at a sibling directory"
[[ -f $test_home/.local/bin/hermes && $(cat "$test_home/.local/bin/hermes") == "$sibling_body" ]] ||
  fail "a wrapper pointing at ~/xhermes is not mistaken for one pointing into ~/.hermes"
pass "removal matches the runtime path as a plain string"

# On a terminal the user is asked, default no: declining leaves every piece of
# data where it was.
seed_install
remove_tty || fail "remove succeeds when the data question is declined"
tr '\0' '\n' <"$test_tmp/gum-log" | grep -qx 'confirm' ||
  fail "removal asks about the user's data on a terminal"
[[ -f $test_home/.hermes/sessions/one.json && -d $test_home/.config/Hermes ]] ||
  fail "declining the question keeps the user's data"
pass "removal asks on a terminal and declining keeps the data"

# An explicit yes is the one path that takes the data too.
seed_install
OMARCHY_TEST_GUM_STATUS=0 remove_tty || fail "remove succeeds when the data goes too"
[[ ! -e $test_home/.hermes && ! -e $test_home/.config/Hermes ]] ||
  fail "a yes deletes ~/.hermes and ~/.config/Hermes"
pass "removal deletes the user's data only on an explicit yes"

# Without the bootstrap marker the runtime is not the app's to take unasked,
# but the data question is still the user's to answer: declining keeps the
# whole tree -- runtime included -- untouched.
seed_install
rm -f "$test_home/.hermes/hermes-agent/.hermes-bootstrap-complete"
remove_tty || fail "remove succeeds when the app never installed Hermes"
tr '\0' '\n' <"$test_tmp/gum-log" | grep -qx 'confirm' ||
  fail "removal still asks about the data without the bootstrap marker"
[[ -d $test_home/.hermes/hermes-agent && -d $test_home/.config/Hermes ]] ||
  fail "declining keeps a Hermes the app never installed"
pass "removal asks without the marker and declining keeps everything"

# The prompt names ~/.hermes itself, so a yes takes the whole tree there too,
# unowned runtime and all -- that is what was asked and answered.
seed_install
rm -f "$test_home/.hermes/hermes-agent/.hermes-bootstrap-complete"
OMARCHY_TEST_GUM_STATUS=0 remove_tty ||
  fail "remove succeeds when the data goes too without the marker"
[[ ! -e $test_home/.hermes && ! -e $test_home/.config/Hermes ]] ||
  fail "a yes takes ~/.hermes whole when the marker never appeared"
pass "removal honors a yes on the named paths without the marker"

# A failed CLI teardown retains the runtime and its ownership receipt so a
# later retry still has the evidence needed to remove the predecessor.
seed_install
printf '%s\n' '#!/usr/bin/env bash' 'unset PYTHONPATH' 'unset PYTHONHOME' "exec \"$test_home/.hermes/hermes-agent/venv/bin/python\" \"$test_home/.hermes/hermes-agent/hermes\" \"\$@\"" \
  >"$test_home/.local/bin/hermes"
OMARCHY_TEST_INSTALLER_STATUS=1 remove && fail "a failed CLI teardown surfaces in the exit code"
[[ -d $test_home/.hermes/hermes-agent && -f $test_home/.local/bin/hermes ]] ||
  fail "a failed CLI teardown preserves the runtime and launcher for retry"
pass "a failed CLI teardown retains the runtime for retry"

seed_native() {
  seed_install
  native_home=${1:-$test_home/.hermes}
  if [[ $native_home != "$test_home/.hermes" ]]; then
    mv "$test_home/.hermes" "$native_home"
  fi
  native_root="$native_home/hermes-agent"
  rm -f "$native_root/.hermes-bootstrap-complete"
  echo ready >"$native_root/.omarchy-hermes-desktop"
  for name in hermes hermes-agent hermes-acp; do
    case "$name" in
      hermes) args="\"$native_root/hermes\"" ;;
      hermes-agent) args="\"$native_root/run_agent.py\"" ;;
      hermes-acp) args="\"$native_root/hermes\" acp" ;;
    esac
    printf '%s\n' '#!/usr/bin/env bash' 'unset PYTHONPATH' 'unset PYTHONHOME' \
      "exec \"$native_root/venv/bin/python\" $args \"\$@\"" >"$test_home/.local/bin/$name"
  done
  desktop_entry="$test_home/.local/share/applications/hermes.desktop"
  mkdir -p "$(dirname "$desktop_entry")"
  cat >"$desktop_entry" <<EOF
[Desktop Entry]
Type=Application
Name=Hermes
GenericName=Hermes Desktop
Comment=Launch Hermes Desktop
Exec="$test_home/.local/bin/hermes" desktop
Icon=hermes
Terminal=false
Categories=Utility;
StartupNotify=true
StartupWMClass=Hermes
EOF
}

seed_native
remove || fail "native removal succeeds"
[[ ! -e $native_root && ! -e $desktop_entry ]] || fail "native runtime and generated desktop entry are removed"
for name in hermes hermes-agent hermes-acp; do
  [[ ! -e $test_home/.local/bin/$name ]] || fail "generated $name wrapper is removed"
done
[[ -f $native_home/sessions/one.json ]] || fail "native removal retains user data"
pass "native runtime removal clears generated launchers and retains data"

seed_native
echo pending >"$native_root/.omarchy-hermes-desktop"
remove || fail "interrupted native setup can be removed"
[[ ! -e $native_root ]] || fail "the owned partial runtime is removed"
pass "native removal also handles an interrupted setup"

seed_native
printf '# custom wrapper mentioning %s\n' "$native_root" >>"$test_home/.local/bin/hermes"
remove || fail "native removal tolerates customized launchers"
[[ -e $test_home/.local/bin/hermes && -e $desktop_entry ]] || fail "custom wrapper and its desktop entry are preserved"
pass "native removal preserves a customized wrapper even when it targets this runtime"

seed_native
sed -i 's/^Icon=hermes$/Icon=my-custom-icon/' "$desktop_entry"
remove || fail "native removal tolerates a customized desktop entry"
[[ -e $desktop_entry ]] || fail "a customized desktop icon is preserved"
pass "native removal preserves a customized desktop entry"

seed_native "$test_home/custom hermes"
mkdir -p "$test_home/.hermes/hermes-agent"
echo keep >"$test_home/.hermes/hermes-agent/unrelated"
OMARCHY_TEST_HERMES_HOME="$native_home" remove || fail "native removal supports a custom data home"
[[ ! -e $native_root && ! -e $desktop_entry ]] || fail "custom native runtime and launcher are removed"
[[ -f $native_home/sessions/one.json && -f $test_home/.hermes/hermes-agent/unrelated ]] || fail "custom removal preserves user data and the default home"
pass "native removal follows HERMES_HOME and leaves other installations alone"

for shared_home in "$test_home/.hermes" "$test_home/custom hermes"; do
  seed_native "$shared_home"
  mkdir -p "$shared_home/profiles/coder"
  echo 'profile chat' >"$shared_home/profiles/coder/session.json"
  OMARCHY_TEST_HERMES_HOME="$shared_home/profiles/coder/" remove || fail "profile removal succeeds"
  [[ ! -e $native_root && ! -e $desktop_entry ]] || fail "profile removal targets the shared runtime and generated launcher"
  [[ -f $shared_home/profiles/coder/session.json && -f $shared_home/sessions/one.json ]] || fail "profile removal preserves root and profile data"
  [[ $(cat "$test_tmp/home-log") == "$shared_home" ]] || fail "CLI removal receives the same shared home"
done
pass "profile removal targets the shared default or custom installation and preserves profile data"

seed_install
git -C "$test_home/.hermes/hermes-agent" remote set-url origin https://github.com/example/hermes-agent.git
remove || fail "removal succeeds with a foreign checkout"
[[ -d $test_home/.hermes/hermes-agent ]] || fail "a legacy marker with a foreign remote is preserved"
pass "legacy removal requires known package provenance"

seed_native
echo 'local edit' >>"$native_root/README.md"
remove || fail "native removal tolerates a development checkout"
[[ -f $native_root/README.md && -f $test_home/.local/bin/hermes && -f $desktop_entry ]] || fail "local changes retain the runtime and launchers"
grep -qF 'local edit' "$native_root/README.md" || fail "local source edits survive"
pass "native removal preserves source edits and their launchers"

seed_native
echo 'new source' >"$native_root/local.py"
remove || fail "native removal tolerates untracked source"
[[ -f $native_root/local.py && -f $test_home/.local/bin/hermes ]] || fail "untracked work retains runtime and launchers"
pass "native removal preserves untracked source"

seed_native
external_worktree="$test_tmp/external-worktree"
git -C "$native_root" worktree add --quiet --detach "$external_worktree"
remove || fail "native removal tolerates an external worktree"
[[ -d $native_root/.git && -f $desktop_entry && -f $test_home/.local/bin/hermes ]] || fail "linked worktrees retain Git metadata and launchers"
git -C "$external_worktree" status --porcelain >/dev/null || fail "the external worktree's Git metadata remains usable"
pass "native removal preserves metadata used by another worktree"

seed_native
external_runtime="$test_tmp/external-runtime"
mv "$native_root" "$external_runtime"
ln -s "$external_runtime" "$native_root"
remove || fail "native removal tolerates a symlinked runtime"
[[ -L $native_root && -f $external_runtime/README.md && -f $test_home/.local/bin/hermes && -f $desktop_entry ]] || fail "symlinked runtime and launchers are retained"
pass "native removal preserves a symlinked runtime"

seed_native
echo 'committed local work' >>"$native_root/README.md"
git -C "$native_root" add README.md
git -C "$native_root" -c user.name=Fixture -c user.email=fixture@example.invalid commit --quiet -m 'local work'
local_head=$(git -C "$native_root" rev-parse HEAD)
remove || fail "native removal tolerates unpublished commits"
[[ -f $test_home/.local/bin/hermes && -f $desktop_entry ]] || fail "unpublished commits retain their launchers"
[[ $(git -C "$native_root" rev-parse HEAD) == "$local_head" ]] || fail "clean unpublished history is retained"
pass "native removal preserves clean unpublished commits"

seed_native
git -C "$native_root" branch my-local-branch
remove || fail "native removal tolerates an unpublished branch"
git -C "$native_root" show-ref --verify --quiet refs/heads/my-local-branch || fail "an unpushed branch is retained even at a published commit"
[[ -f $test_home/.local/bin/hermes ]] || fail "an unpublished branch retains its launcher"
pass "native removal preserves a local branch at a published commit"

seed_native
echo 'stashed work' >>"$native_root/README.md"
git -C "$native_root" -c user.name=Fixture -c user.email=fixture@example.invalid stash push --quiet
remove || fail "native removal tolerates stashed work"
git -C "$native_root" show-ref --verify --quiet refs/stash || fail "stashed work survives removal"
[[ -f $desktop_entry ]] || fail "stashed work retains its launcher"
pass "native removal preserves stashed work"

seed_native
printf '%s\n' 'pipx:hermes-agent[extras=all]' >"$native_root/.git/omarchy-mise-predecessor"
OMARCHY_TEST_INSTALLER_STATUS=1 remove && fail "failed native predecessor cleanup reaches the caller"
[[ -f $native_root/.git/omarchy-mise-predecessor && -f $desktop_entry && -f $test_home/.local/bin/hermes ]] || fail "failed cleanup preserves native runtime ownership and launchers"
[[ -f $native_home/sessions/one.json ]] || fail "failed cleanup retains user data"
pass "failed native predecessor cleanup preserves the receipt for retry"

OMARCHY_TEST_INSTALLER_STATUS=1 OMARCHY_TEST_GUM_STATUS=0 remove_tty && fail "failed cleanup is reported on a terminal too"
[[ ! -s $test_tmp/gum-log && -f $native_root/.git/omarchy-mise-predecessor && -f $native_home/sessions/one.json ]] || fail "failed cleanup must not offer to delete its receipt and user data"
pass "failed predecessor cleanup skips the data deletion question"

seed_native
git -C "$native_root" update-ref -d refs/remotes/origin/main
remove || fail "native removal tolerates missing publication evidence"
[[ -f $native_root/README.md && -f $desktop_entry ]] || fail "unknown local history is retained without a fetched remote"
pass "native removal requires evidence that local history is published"
