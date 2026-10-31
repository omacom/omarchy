#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
copy_boundary_file bin/omarchy-channel-set
copy_boundary_file bin/omarchy-refresh-pacman
copy_boundary_file bin/omarchy-apply-pacman
copy_boundary_file bin/omarchy-update
export OMARCHY_UPDATE_LOGGED=1

# Leaving edge for stable or rc swaps omarchy-dev and omarchy-settings-dev for
# omarchy and omarchy-settings. Stable's repository listed an omarchy-dev from
# August (4.0.0.r1832) until October 2026, which predates command-scoped sudo,
# and the refresh before the swap is a downgrade-capable upgrade. Every
# privileged step is a stand-in; pacman is a model of that repository.
python3 - "$SUDO_TEST_ROOT/bin/omarchy-channel-set" "$SUDO_TEST_ROOT" <<'PY'
import sys
from pathlib import Path
p = Path(sys.argv[1])
p.write_text(p.read_text().replace('/usr/share/omarchy', sys.argv[2]))
PY

for command in omarchy-dev-link omarchy-dev-unlink omarchy-state gum git; do
  cat >"$SUDO_TEST_ROOT/bin/$command" <<'STUB'
#!/bin/bash
set -euo pipefail
step=${0##*/}
printf 'step:%s %s\n' "$step" "$*" >>"$SUDO_TEST_LOG"
case "$step" in
  omarchy-dev-link|omarchy-dev-unlink) sudo /usr/bin/true ;;
esac
STUB
  chmod +x "$SUDO_TEST_ROOT/bin/$command"
done

export SUDO_TEST_INSTALLED_FILE="$boundary_tmp/installed"
rm "$SUDO_TEST_ROOT/bin/pacman"
cat >"$SUDO_TEST_ROOT/bin/pacman" <<'STUB'
#!/bin/bash
set -euo pipefail
printf 'step:pacman %s\n' "$*" >>"$SUDO_TEST_LOG"
installed=$SUDO_TEST_INSTALLED_FILE
# Only an installed package tree carries the wrapper; a linked checkout keeps its own.
wrapper=$SUDO_TEST_ROOT/default/omarchy/sudo-no-update/sudo
case "$1" in
  -Q) cat "$installed" ;;
  -Syyuu)
    # -uu takes the repository's older omarchy-dev unless the upgrade ignores it.
    if grep -q '^omarchy-dev 4.0.0.r7052' "$installed" && [[ " $* " != *" --ignore omarchy-dev,omarchy-settings-dev "* ]]; then
      printf 'omarchy-dev 4.0.0.r1832.g23dab9e-1\nomarchy-settings-dev 4.0.0.r1832.g23dab9e-1\n' >"$installed"
      printf 'model:downgraded omarchy-dev to 4.0.0.r1832\n' >>"$SUDO_TEST_LOG"
      rm -f "$wrapper"
    fi
    ;;
  -S)
    # The swap: the release replaces the -dev pair, and it predates the wrapper too.
    if [[ ${*: -2} == "omarchy omarchy-settings" ]]; then
      printf 'omarchy 4.0.5-1\nomarchy-settings 4.0.5-1\n' >"$installed"
      rm -f "$wrapper"
    fi
    ;;
esac
STUB
chmod +x "$SUDO_TEST_ROOT/bin/pacman"

cp "$SUDO_TEST_ROOT/default/omarchy/sudo-no-update/sudo" "$boundary_tmp/saved-package-wrapper"
checkout="$SUDO_TEST_HOME/omarchy"
cp -a "$SUDO_TEST_ROOT" "$checkout"
mkdir -p "$checkout/.git" "$checkout/shell"

for source in edge dev; do
  for channel in stable rc; do
    reset_boundary
    cp "$boundary_tmp/saved-package-wrapper" "$SUDO_TEST_ROOT/default/omarchy/sudo-no-update/sudo"
    printf 'omarchy-dev 4.0.0.r7052.ga6dcc31-1\nomarchy-settings-dev 4.0.0.r7052.ga6dcc31-1\n' >"$SUDO_TEST_INSTALLED_FILE"
    root=$SUDO_TEST_ROOT
    [[ $source != "dev" ]] || root=$checkout

    status=0
    OMARCHY_PATH="$root" "$root/bin/omarchy-channel-set" "$channel" >"$boundary_tmp/output" 2>&1 || status=$?

    if grep -q '^model:downgraded' "$SUDO_TEST_LOG"; then
      fail "$source to $channel: the refresh moved omarchy-dev onto the repository's older build" "$(<"$SUDO_TEST_LOG")"
    fi
    grep -Fxq 'step:pacman -S --needed --noconfirm --ask 4 omarchy omarchy-settings' "$SUDO_TEST_LOG" ||
      fail "$source to $channel: the switch installs omarchy and omarchy-settings" "$(<"$SUDO_TEST_LOG")$(<"$boundary_tmp/output")"
    [[ $(<"$SUDO_TEST_INSTALLED_FILE") == $'omarchy 4.0.5-1\nomarchy-settings 4.0.5-1' ]] ||
      fail "$source to $channel: the machine ends on the release" "$(<"$SUDO_TEST_INSTALLED_FILE")"
    (( status == 3 )) || fail "$source to $channel: the switch stops for the release's own update (exit $status)" "$(<"$boundary_tmp/output")"
    grep -Fq "Packages are switched to omarchy 4.0.5-1, omarchy-settings 4.0.5-1." "$boundary_tmp/output" ||
      fail "$source to $channel: the stop names the release it installed" "$(<"$boundary_tmp/output")"
    grep -Fq "Run 'omarchy update' from a new terminal to finish" "$boundary_tmp/output" ||
      fail "$source to $channel: the stop says how to finish" "$(<"$boundary_tmp/output")"
    assert_boundary_cold "$source to $channel"
    pass "$source to $channel leaves omarchy-dev to the swap when the repository lists an older build, and ends on the release"
  done
done
