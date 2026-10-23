#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

python3 - "$ROOT" <<'PY'
import configparser
import pathlib
import shlex
import sys

root = pathlib.Path(sys.argv[1])
unit = configparser.ConfigParser(interpolation=None)
unit.read(root / "default/systemd/user/omarchy-clipboard-persist.service")
command = shlex.split(unit["Service"]["ExecStart"])

assert command[0] == "/usr/bin/wl-clip-persist"
assert command[command.index("--clipboard") + 1] == "regular"
assert "--ignore-event-on-error" in command
assert command[command.index("--all-mime-type-regex") + 1] == "^(?!x-kde-passwordManagerHint).+"
assert unit["Unit"]["ConditionEnvironment"] == "WAYLAND_DISPLAY"
assert unit["Unit"]["PartOf"] == "graphical-session.target"
assert unit["Unit"]["After"] == "graphical-session.target"
assert unit["Install"]["WantedBy"] == "graphical-session.target"
assert unit["Service"]["Restart"] == "on-failure"
assert "wl-clip-persist" in (root / "install/omarchy-base.packages").read_text().splitlines()
assert "omarchy-clipboard-persist.service" in (root / "install/user/first-run/enable-user-units.sh").read_text()
PY
pass "clipboard persistence is session-scoped, preserves formats, and excludes sensitive selections"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/bin" "$test_dir/home"

cat >"$test_dir/bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'package %s\n' "$*" >>"$OMARCHY_TEST_CALLS"
exit "${OMARCHY_TEST_PACKAGE_FAILURE:-0}"
SH

cat >"$test_dir/bin/systemctl" <<'SH'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$OMARCHY_TEST_CALLS"
if [[ $* == "--user enable --now omarchy-clipboard-persist.service" ]]; then
  mkdir -p "$HOME/.config/systemd/user/graphical-session.target.wants"
  ln -sfn "$OMARCHY_PATH/default/systemd/user/omarchy-clipboard-persist.service" \
    "$HOME/.config/systemd/user/graphical-session.target.wants/omarchy-clipboard-persist.service"
fi
SH
chmod +x "$test_dir/bin/omarchy-pkg-add" "$test_dir/bin/systemctl"

run_migration() {
  env HOME="$test_dir/home" PATH="$test_dir/bin:$PATH" OMARCHY_PATH="$ROOT" \
    OMARCHY_TEST_CALLS="$test_dir/calls" OMARCHY_TEST_PACKAGE_FAILURE="${1:-0}" \
    bash -euo pipefail "$ROOT/migrations/1792530468.sh" >"$test_dir/output"
}

run_migration
expected=$'package wl-clip-persist\nsystemctl --user daemon-reload\nsystemctl --user enable --now omarchy-clipboard-persist.service'
[[ $(<"$test_dir/calls") == "$expected" ]] || fail "migration installs the dependency before enabling persistence"
link="$test_dir/home/.config/systemd/user/graphical-session.target.wants/omarchy-clipboard-persist.service"
[[ -L $link ]] || fail "migration enables persistence for the next graphical login"
pass "migration installs and starts persistence for existing users"

rm "$test_dir/calls"
run_migration
[[ $(<"$test_dir/calls") == "$expected" && -L $link ]] || fail "reapplying the migration is idempotent"
pass "reapplying the clipboard persistence migration is idempotent"

rm "$test_dir/calls"
if run_migration 1; then
  fail "migration reports a package installation failure"
fi
[[ $(<"$test_dir/calls") == "package wl-clip-persist" ]] || fail "a failed installation cannot enable a missing dependency"
pass "migration stops before starting persistence if installation fails"
