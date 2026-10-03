#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export HOME="$test_tmp/home"
export OMARCHY_PATH="$ROOT"
mkdir -p "$HOME/.config/autostart"
entry="$HOME/.config/autostart/com.onepassword.OnePassword.desktop"
helper="$ROOT/bin/omarchy-refresh-1password-autostart"

assert_unchanged() {
  local description="$1"
  cp "$entry" "$test_tmp/before"
  local inode=$(stat -c %i "$entry")
  "$helper"
  cmp -s "$entry" "$test_tmp/before" || fail "$description"
  [[ $(stat -c %i "$entry") == "$inode" ]] || fail "$description" "File was replaced"
  pass "$description"
}

for executable in /opt/1Password/1password 1password; do
  printf '[Desktop Entry]\nName=1Password\nExec=%s --silent %%U\nX-Test=unchanged\n' "$executable" >"$entry"
  chmod 640 "$entry"
  printf '[Desktop Entry]\nName=1Password\nExec=%s --force-device-scale-factor=1 --silent %%U\nX-Test=unchanged\n' "$executable" >"$test_tmp/expected"
  "$helper"
  cmp -s "$entry" "$test_tmp/expected" || fail "pins $executable and preserves arguments and other lines"
  [[ $(stat -c %a "$entry") == "640" ]] || fail "preserves permissions"
  pass "pins $executable and preserves arguments, other lines, and permissions"
  assert_unchanged "running twice leaves $executable unchanged"
done

printf 'Exec=1password\n' >"$entry"
"$helper"
[[ $(cat "$entry") == "Exec=1password --force-device-scale-factor=1" ]] || fail "matches executable without arguments"
pass "matches executable without arguments"

printf 'Exec=/opt/1Password/1password --force-device-scale-factor=2 --silent %%U\n' >"$entry"
assert_unchanged "already-pinned entry remains unchanged"

printf 'Exec=1password-other --silent\nExec=/opt/1Password/1password-other\nExec=/usr/bin/1password\nTryExec=1password\n' >"$entry"
assert_unchanged "unrelated executables and keys remain unchanged"

rm "$entry"
"$helper"
[[ ! -e $entry ]] || fail "missing entry is a no-op"
pass "missing entry is a no-op"

printf 'Exec=1password --silent\n' >"$test_tmp/target"
cp "$test_tmp/target" "$test_tmp/before"
ln -s "$test_tmp/target" "$entry"
"$helper"
[[ -L $entry ]] || fail "symlink remains untouched"
cmp -s "$test_tmp/target" "$test_tmp/before" || fail "symlink target remains untouched"
pass "symlink and its target remain untouched"
rm "$entry"
mkdir "$entry"
"$helper"
[[ -d $entry ]] || fail "directory remains untouched"
rmdir "$entry"
mkfifo "$entry"
"$helper"
[[ -p $entry ]] || fail "FIFO remains untouched"
rm "$entry"
pass "non-regular entries remain untouched"

printf 'Exec=1password --silent %%U\n' >"$entry"
bash -euo pipefail "$ROOT/migrations/1790807551.sh"
cp "$entry" "$test_tmp/before"
bash -euo pipefail "$ROOT/migrations/1790807551.sh"
cmp -s "$entry" "$test_tmp/before" || fail "migration is idempotent"
[[ $(cat "$entry") == "Exec=1password --force-device-scale-factor=1 --silent %U" ]] || fail "migration calls helper"
pass "migration pins autostart and is idempotent"

mock_bin="$test_tmp/bin"
mkdir "$mock_bin"
cat >"$mock_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
[[ $* == "1password 1password-cli" ]] || exit 1
printf 'Exec=/opt/1Password/1password --silent %%U\n' >"$HOME/.config/autostart/com.onepassword.OnePassword.desktop"
SH
cat >"$mock_bin/omarchy-cmd-missing" <<'SH'
#!/bin/bash
[[ $1 == "chromium" ]]
SH
cat >"$mock_bin/setsid" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mock_bin"/*
PATH="$mock_bin:$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-install-service-1password"
[[ $(cat "$entry") == "Exec=/opt/1Password/1password --force-device-scale-factor=1 --silent %U" ]] || fail "installer pins autostart after package installation"
pass "installer pins autostart after package installation"
assert_unchanged "refresh after installation preserves contents and inode"

cat >"$mock_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
[[ $* == "1password 1password-cli" ]]
SH
cat >"$mock_bin/setsid" <<'SH'
#!/bin/bash
[[ $* == "uwsm-app -- 1password" ]] || exit 1
sleep 0.2
printf 'Exec=/opt/1Password/1password --silent %%U\n' >"$HOME/.config/autostart/com.onepassword.OnePassword.desktop"
SH
rm "$entry"
PATH="$mock_bin:$ROOT/bin:$PATH" timeout 10 bash "$ROOT/bin/omarchy-install-service-1password"
[[ $(cat "$entry") == "Exec=/opt/1Password/1password --force-device-scale-factor=1 --silent %U" ]] || fail "installer pins entry created after opening app"
pass "installer pins entry created after opening app"
assert_unchanged "refresh after delayed creation preserves contents and inode"

cat >"$mock_bin/setsid" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$mock_bin/sleep" <<'SH'
#!/bin/bash
[[ $* == "0.1" ]] || exit 1
printf '%s\n' "$1" >>"$HOME/poll-intervals"
/bin/sleep "$1"
SH
chmod +x "$mock_bin/sleep"
rm "$entry"
PATH="$mock_bin:$ROOT/bin:$PATH" timeout 10 bash "$ROOT/bin/omarchy-install-service-1password"
[[ ! -e $entry ]] || fail "installer succeeds without an autostart entry"
[[ $(wc -l <"$HOME/poll-intervals") == "30" ]] || fail "installer bounds polling to 30 short waits"
pass "installer succeeds after bounded polling without an autostart entry"

# Each mocked wait checks that the installer left the previous write untouched,
# then advances the app's in-place write by one deterministic stage.
cat >"$mock_bin/sleep" <<'SH'
#!/bin/bash
set -euo pipefail
[[ $* == "0.1" ]] || exit 1
entry="$HOME/.config/autostart/com.onepassword.OnePassword.desktop"
count=0
if [[ -f $HOME/poll-intervals ]]; then
  count=$(wc -l <"$HOME/poll-intervals")
fi
if (( count > 0 )); then
  cmp -s "$entry" "$HOME/write-snapshot"
  [[ $(stat -c %i "$entry") == "$(cat "$HOME/write-inode")" ]]
fi
printf '%s\n' "$1" >>"$HOME/poll-intervals"
stage="$HOME/stages/$(( count + 1 ))"
if [[ -f $stage ]]; then
  cat "$stage" >"$entry"
fi
cp "$entry" "$HOME/write-snapshot"
stat -c %i "$entry" >"$HOME/write-inode"
SH

for scenario in partial append no-newline late-29 late-30 timeout; do
  rm -f "$entry" "$HOME/poll-intervals"
  mkdir -p "$HOME/stages"
  rm -f "$HOME/stages/"*
  case "$scenario" in
    partial)
      : >"$HOME/stages/1"
      printf '[Desktop Entry]\nExec=' >"$HOME/stages/2"
      printf '[Desktop Entry]\nExec=1password' >"$HOME/stages/3"
      printf '[Desktop Entry]\nExec=1password --silent %%U\nX-Test=preserved\n' >"$HOME/stages/4"
      printf '[Desktop Entry]\nExec=1password --force-device-scale-factor=1 --silent %%U\nX-Test=preserved\n' >"$test_tmp/expected"
      expected_waits=5
      ;;
    append)
      printf '[Desktop Entry]\nExec=/opt/1Password/1password\n' >"$HOME/stages/1"
      printf '[Desktop Entry]\nExec=/opt/1Password/1password --silent %%U\nX-Test=' >"$HOME/stages/2"
      printf '[Desktop Entry]\nExec=/opt/1Password/1password --silent %%U\nX-Test=preserved\n' >"$HOME/stages/3"
      printf '[Desktop Entry]\nExec=/opt/1Password/1password --force-device-scale-factor=1 --silent %%U\nX-Test=preserved\n' >"$test_tmp/expected"
      expected_waits=4
      ;;
    no-newline)
      printf '[Desktop Entry]\nExec=1password --silent %%U' >"$HOME/stages/1"
      printf '[Desktop Entry]\nExec=1password --force-device-scale-factor=1 --silent %%U' >"$test_tmp/expected"
      expected_waits=2
      ;;
    late-29|late-30)
      : >"$HOME/stages/1"
      printf '[Desktop Entry]\nExec=1password --silent %%U\n' >"$HOME/stages/${scenario#late-}"
      printf '[Desktop Entry]\nExec=1password --force-device-scale-factor=1 --silent %%U\n' >"$test_tmp/expected"
      expected_waits=30
      ;;
    timeout)
      printf '[Desktop Entry]\nExec=' >"$HOME/stages/1"
      cp "$HOME/stages/1" "$test_tmp/expected"
      expected_waits=30
      ;;
  esac
  PATH="$mock_bin:$ROOT/bin:$PATH" timeout 10 bash "$ROOT/bin/omarchy-install-service-1password"
  cmp -s "$entry" "$test_tmp/expected" || fail "$scenario staged write preserves all contents"
  [[ $(wc -l <"$HOME/poll-intervals") == "$expected_waits" ]] || fail "$scenario waits for complete and stable entry"
  if [[ $scenario == "timeout" ]]; then
    [[ $(stat -c %i "$entry") == "$(cat "$HOME/write-inode")" ]] || fail "incomplete entry inode remains unchanged on timeout"
  else
    assert_unchanged "$scenario completed entry refresh preserves contents and inode"
  fi
  pass "$scenario staged write remains untouched until ready"
done

printf 'Exec=/opt/1Password/1password --silent %%U\n' >"$entry"
"$helper"
[[ $(cat "$entry") == "Exec=/opt/1Password/1password --force-device-scale-factor=1 --silent %U" ]] || fail "documented helper pins entry created after installation"
pass "documented helper pins entry created after installation"
assert_unchanged "repeated manual refresh preserves contents and inode"

[[ -z $(find "$HOME/.config/autostart" -name '*.??????' -print) ]] || fail "temporary files are cleaned up"
pass "temporary files are cleaned up"
