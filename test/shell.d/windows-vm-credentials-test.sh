#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

python3 - <<'PY'
import os
from pathlib import Path
import subprocess
import tempfile

prefix = r'''
set -euo pipefail
set -- help
source "$ROOT/bin/omarchy-windows-vm" >/dev/null
mkdir -p "$HOME/.config/windows" "$OMARCHY_WINDOWS_DIR"
CREDENTIALS_FILE="$HOME/.config/windows/credentials"
TEST_PUBLISH_PATH=$CREDENTIALS_FILE
prepare_user_mount_sources() { :; }
check_prerequisites() { :; }
omarchy-pkg-add() { :; }
available_storage_gb() { printf 128; }
timedatectl() { printf UTC; }
sleep() { :; }
xdg-open() { :; }
gum() {
  case "$1" in
    choose)
      cat >/dev/null
      if [[ $* == *RAM* ]]; then printf 4G; else printf 64G; fi
      ;;
    input)
      if [[ $* == *CPU* ]]; then printf 2
      elif [[ $* == *username* ]]; then printf testuser
      else printf testpass
      fi
      ;;
    style | confirm) : ;;
    *) return 1 ;;
  esac
}
write_compose() { printf 'compose\n' >>"$TEST_LOG"; }
priv() { printf 'priv:%s\n' "$1" >>"$TEST_LOG"; }
'''


def run_case(name, body, status=0, setup=None):
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)
        home = root / 'home'
        home.mkdir()
        env = dict(os.environ, HOME=str(home), OMARCHY_WINDOWS_DIR=str(root / 'runtime'),
                   TEST_ROOT=str(root), TEST_LOG=str(root / 'calls'))
        if setup:
            setup(root)
        result = subprocess.run(['/bin/bash', '-c', prefix + body], env=env,
                                capture_output=True, text=True, timeout=20)
        assert result.returncode == status, (name, result.returncode, result.stdout, result.stderr)
        print('ok - ' + name)
        return result


for fixture in ('dangling-parent', 'file-parent', 'directory-destination'):
    body = r'''
case "$FIXTURE" in
  dangling-parent)
    rmdir "$HOME/.config/windows"
    ln -s "$TEST_ROOT/missing" "$HOME/.config/windows"
    ;;
  file-parent)
    rmdir "$HOME/.config/windows"
    touch "$HOME/.config/windows"
    ;;
  directory-destination) mkdir "$CREDENTIALS_FILE" ;;
esac
if (install_windows); then exit 9; fi
[[ ! -e $TEST_LOG ]]
'''.replace('$FIXTURE', fixture)
    run_case('install rejects ' + fixture + ' before privileged configuration', body)

run_case('failed Compose staging preserves existing credentials and removes private candidates', r'''
write_credentials previous oldpass
before=$(sha256sum "$CREDENTIALS_FILE")
write_compose() {
  [[ $(read_credential PASSWORD) == oldpass ]] || exit 9
  candidates=("$HOME/.config/windows"/.credentials-install.*)
  [[ ${#candidates[@]} == 1 && -f ${candidates[0]} ]] || exit 9
  [[ $(stat -c '%a' "${candidates[0]}") == 600 ]] || exit 9
  printf 'compose\n' >>"$TEST_LOG"
  return 7
}
if (install_windows); then exit 9; fi
[[ $(sha256sum "$CREDENTIALS_FILE") == "$before" ]]
[[ $(<"$TEST_LOG") == compose ]]
[[ -z $(find "$HOME/.config/windows" -name '.credentials*' -print) ]]
''')

run_case('publication failure preserves prior credentials, cleans staging and never starts VM', r'''
write_credentials previous oldpass
before=$(sha256sum "$CREDENTIALS_FILE")
mv() {
  if [[ ${!#} == "$TEST_PUBLISH_PATH" ]]; then return 1; fi
  command mv "$@"
}
if (install_windows); then exit 9; fi
[[ $(sha256sum "$CREDENTIALS_FILE") == "$before" ]]
[[ $(<"$TEST_LOG") == compose ]]
[[ -z $(find "$HOME/.config/windows" -name '.credentials*' -print) ]]
''')

run_case('install publishes staged credentials before starting VM', r'''
priv() {
  [[ $1 == up && $(read_credential PASSWORD) == testpass ]] || exit 9
  printf 'priv:up\n' >>"$TEST_LOG"
}
install_windows
[[ $(<"$TEST_LOG") == $'compose\npriv:up' ]]
[[ $(stat -c '%a' "$CREDENTIALS_FILE") == 600 ]]
[[ -z $(find "$HOME/.config/windows" -name '.credentials*' -print) ]]
''')

run_case('linked config removal deletes actual credentials and preserves unrelated target files', r'''
mv "$HOME/.config/windows" "$TEST_ROOT/config-target"
ln -s "$TEST_ROOT/config-target" "$HOME/.config/windows"
chmod 0755 "$TEST_ROOT/config-target"
write_credentials linked secret
[[ $(stat -c '%a' "$TEST_ROOT/config-target") == 700 ]]
touch "$TEST_ROOT/config-target/keep"
# These private candidates model SIGKILL/power-loss leftovers with no EXIT trap.
for candidate in .credentials-install.ABC123 .credentials.XYZ123; do
  printf 'interrupted private credentials\n' >"$TEST_ROOT/config-target/$candidate"
  chmod 0600 "$TEST_ROOT/config-target/$candidate"
done
# Cleanup must unlink a planted candidate symlink without following its target.
printf 'external data\n' >"$TEST_ROOT/candidate-victim"
ln -s "$TEST_ROOT/candidate-victim" "$TEST_ROOT/config-target/.credentials.LINK12"
migrate_legacy_compose() { return 1; }
remove_windows
[[ -z $(find "$TEST_ROOT/config-target" -name '.credentials*' -print) ]]
[[ $(<"$TEST_ROOT/candidate-victim") == 'external data' ]]
[[ ! -e $TEST_ROOT/config-target/credentials && -f $TEST_ROOT/config-target/keep ]]
[[ ! -L $HOME/.config/windows && ! -e $HOME/.config/windows ]]
''')

run_case('credential deletion failure retains the config link and reports removal failure', r'''
mv "$HOME/.config/windows" "$TEST_ROOT/config-target"
ln -s "$TEST_ROOT/config-target" "$HOME/.config/windows"
write_credentials linked secret
migrate_legacy_compose() { return 1; }
rm() {
  if [[ " $* " == *" $CREDENTIALS_FILE "* ]]; then return 1; fi
  command rm "$@"
}
if (remove_windows); then exit 9; fi
[[ -L $HOME/.config/windows && -f $TEST_ROOT/config-target/credentials ]]
''')

run_case('real and dangling legacy Compose symlinks remain untouched without migration', r'''
printf 'legacy plaintext\n' >"$TEST_ROOT/legacy-target"
for target in "$TEST_ROOT/legacy-target" "$TEST_ROOT/missing-target"; do
  ln -s "$target" "$LEGACY_COMPOSE_FILE"
  if migrate_legacy_compose; then exit 9; fi
  [[ -L $LEGACY_COMPOSE_FILE && ! -e $TEST_LOG ]]
  [[ $(<"$TEST_ROOT/legacy-target") == 'legacy plaintext' ]]
  rm "$LEGACY_COMPOSE_FILE"
done
''')
PY
