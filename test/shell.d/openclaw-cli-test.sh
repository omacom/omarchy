#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
seed="$test_tmp/share"
events="$test_tmp/events"
mkdir -p "$mock_bin" "$seed"

cat >"$mock_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
[[ $1 == openclaw && -e $OMARCHY_TEST_ROOT/package-installed ]]
SH
cat >"$mock_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'pkg-add %s\n' "$*" >>"$OMARCHY_TEST_ROOT/events"
touch "$OMARCHY_TEST_ROOT/package-installed"
SH
# The user manager, as far as these tests need one: a service is active while
# a marker says so, and enabled likewise. Stopping clears it, except for the
# unit named in OMARCHY_TEST_STOP_FAIL.
cat >"$mock_bin/systemctl" <<'SH'
#!/bin/bash
case "$2" in
  stop)
    printf 'systemctl %s\n' "$*" >>"$OMARCHY_TEST_ROOT/events"
    [[ ${OMARCHY_TEST_STOP_FAIL:-} != "$3" ]] || exit 1
    rm -f "$HOME/active-$3"
    ;;
  is-active) [[ -e $HOME/active-$4 ]] ;;
  is-enabled) [[ -e $HOME/enabled-$4 ]] ;;
  disable)
    printf 'systemctl %s\n' "$*" >>"$OMARCHY_TEST_ROOT/events"
    rm -f "$HOME/enabled-$3"
    ;;
esac
SH
chmod +x "$mock_bin/"*

# Stands in for upstream's install-cli.sh: it writes the command the way the
# real one does, execing into the prefix's tools, and that command logs what
# it is asked. OMARCHY_TEST_INSTALL_BROKEN leaves a command that cannot run.
# Like upstream, `<role> install --force` rewrites the unit onto the runtime
# and starts it, OMARCHY_TEST_START_FAIL making the start fail, and the
# installer does that itself for a gateway it finds loaded. As upstream does
# since 2026.9.6, a rewrite keeps the Node the unit already ran unless
# --runtime-path pins one.
cat >"$seed/install-cli.sh" <<'SH'
printf 'install-cli %s%s\n' "$*" "${OPENCLAW_PROFILE:+ profile=$OPENCLAW_PROFILE}" >>"$OMARCHY_TEST_ROOT/events"
prefix=$HOME/.openclaw
mkdir -p "$prefix/bin" "$prefix/tools/node-v24.19.0/bin"
touch "$prefix/tools/node-v24.19.0/bin/node"
ln -sfn "$prefix/tools/node-v24.19.0" "$prefix/tools/node"
cat >"$prefix/bin/openclaw" <<EOF
#!/usr/bin/env bash
set -euo pipefail
[[ -z "\${OMARCHY_TEST_INSTALL_BROKEN:-}" ]] || exit 1
printf 'runtime %s%s\n' "\$*" "\${OPENCLAW_PROFILE:+ profile=\$OPENCLAW_PROFILE}" >>"$OMARCHY_TEST_ROOT/events"
if [[ \${2:-} == "install" ]]; then
  unit="\$HOME/.config/systemd/user/openclaw-\$1.service"
  node=$prefix/tools/node-v24.19.0/bin/node
  if [[ \${4:-} == "--runtime-path" ]]; then
    node=\$5
  elif [[ -f \$unit ]]; then
    node=\$(sed -n 's/^ExecStart=\([^ ]*\).*/\1/p' "\$unit")
  fi
  printf 'ExecStart=%s $prefix/tools/node-v24.19.0/lib/node_modules/openclaw/dist/index.js %s\n' "\$node" "\$1" >"\$unit"
  [[ -z "\${OMARCHY_TEST_START_FAIL:-}" ]] || exit 1
  touch "\$HOME/active-openclaw-\$1.service" "\$HOME/enabled-openclaw-\$1.service"
fi
exec true "$prefix/tools/node-v24.19.0/lib/node_modules/openclaw/dist/entry.js" "\$@"
EOF
chmod 755 "$prefix/bin/openclaw"
if [[ -f $HOME/.config/systemd/user/openclaw-gateway.service ]]; then
  "$prefix/bin/openclaw" gateway install --force || true
fi
SH
touch "$seed/openclaw.tgz"

# Scratch copies of the actual scripts, with only the package's path swapped.
for script in bin/omarchy-install-openclaw-cli migrations/1790397381.sh; do
  sed "s|/usr/share/openclaw|$seed|g" "$ROOT/$script" >"$mock_bin/${script##*/}"
done
mv "$mock_bin/1790397381.sh" "$test_tmp/migration.sh"
chmod +x "$mock_bin/omarchy-install-openclaw-cli"

new_home() {
  test_home="$test_tmp/$1"
  runtime="$test_home/.openclaw/bin/openclaw"
  command="$test_home/.local/bin/openclaw"
  mkdir -p "$test_home/.local/bin"
  rm -f "$test_tmp/package-installed"
  : >"$events"
}

# PATH puts a directory ahead of ~/.local/bin the way Omarchy's does, where a
# test can drop another openclaw.
mkdir -p "$test_tmp/usr-bin"
run() {
  HOME="$test_home" OMARCHY_TEST_ROOT="$test_tmp" PATH="$test_tmp/usr-bin:$mock_bin:$test_home/.local/bin:$PATH" \
    "$@" >"$test_tmp/output" 2>&1
}

new_home usage
run omarchy-install-openclaw-cli && fail "no mode is a usage error"
[[ ! -s $events ]] || fail "no mode installs nothing" "$(cat "$events")"
pass "every mode is named outright"

new_home fresh
run omarchy-install-openclaw-cli --check && fail "--check calls a machine without OpenClaw installed"
run omarchy-install-openclaw-cli --now || fail "--now sets OpenClaw up" "$(cat "$test_tmp/output")"
grep -Fxq "pkg-add openclaw" "$events" || fail "--now installs the package" "$(cat "$events")"
grep -Fxq "install-cli --install-method npm --prefix $test_home/.openclaw --version $seed/openclaw.tgz --no-onboard" "$events" ||
  fail "--now seeds the runtime from the packaged release" "$(cat "$events")"
[[ -L $command && $(readlink -- "$command") == "$runtime" ]] || fail "--now points the command on PATH at the runtime"
run omarchy-install-openclaw-cli --check || fail "--check follows a finished install"
pass "--now seeds a self-updating OpenClaw from the packaged release"

: >"$events"
run omarchy-install-openclaw-cli --now || fail "--now accepts a finished install" "$(cat "$test_tmp/output")"
! grep -q '^install-cli\|^pkg-add' "$events" || fail "a runtime that answers is never reseeded" "$(cat "$events")"
pass "a runtime that answers is never reseeded, whatever version its updates reached"

rm -f "$command"
ln -s "$runtime" "$command.tmp" && mv "$command.tmp" "$command"
mv "$test_home/.openclaw" "$test_home/.openclaw.gone"
run omarchy-install-openclaw-cli --check && fail "--check calls a dangling link installed"
run omarchy-install-openclaw-cli --now || fail "--now reseeds behind its own dangling link" "$(cat "$test_tmp/output")"
[[ -x $runtime && $(readlink -- "$command") == "$runtime" ]] || fail "--now reseeds behind its own dangling link"
pass "a link Omarchy left behind is rewritten, and a missing runtime reseeded"

new_home old-package
touch "$test_tmp/package-installed"
mv "$seed" "$seed.old"
run omarchy-install-openclaw-cli --now && fail "a package with no seed cannot set OpenClaw up"
grep -q "Run 'omarchy update'" "$test_tmp/output" || fail "a package with no seed says to update" "$(cat "$test_tmp/output")"
[[ ! -e $test_home/.openclaw && ! -e $command ]] || fail "a package with no seed leaves the home untouched"
mv "$seed.old" "$seed"
pass "a package that is still the runtime is refused before anything is touched"

new_home broken
OMARCHY_TEST_INSTALL_BROKEN=1 run omarchy-install-openclaw-cli --now && fail "a runtime that does not run is not a finished install"
grep -q "did not complete" "$test_tmp/output" || fail "a failed setup says so" "$(cat "$test_tmp/output")"
[[ ! -e $command ]] || fail "a failed setup puts nothing on PATH"
pass "a runtime that does not run fails the install"

new_home foreign
printf '#!/bin/bash\necho mine\n' >"$command"
chmod +x "$command"
run omarchy-install-openclaw-cli --now && fail "a command that is the user's is not replaced"
grep -q "Move it aside" "$test_tmp/output" || fail "a command that is the user's is named" "$(cat "$test_tmp/output")"
[[ ! -L $command ]] && grep -q mine "$command" || fail "a command that is the user's is kept"
run omarchy-install-openclaw-cli --check && fail "--check calls the runtime installed while the command is somebody else's"
pass "a command at the path that is the user's is kept and named"

new_home shadowed
printf '#!/bin/bash\n' >"$test_tmp/usr-bin/openclaw"
chmod +x "$test_tmp/usr-bin/openclaw"
run omarchy-install-openclaw-cli --now && fail "an openclaw earlier on PATH fails the install"
grep -q "on PATH is $test_tmp/usr-bin/openclaw" "$test_tmp/output" || fail "an openclaw earlier on PATH is named" "$(cat "$test_tmp/output")"
[[ ! -e $test_home/.openclaw && ! -e $command ]] || fail "an openclaw earlier on PATH is refused before anything is touched"
rm "$test_tmp/usr-bin/openclaw"
run omarchy-install-openclaw-cli --now || fail "--now follows once nothing shadows the runtime" "$(cat "$test_tmp/output")"
printf '#!/bin/bash\n' >"$test_tmp/usr-bin/openclaw"
chmod +x "$test_tmp/usr-bin/openclaw"
run omarchy-install-openclaw-cli --check && fail "--check calls a shadowed runtime installed"
rm "$test_tmp/usr-bin/openclaw"
run omarchy-install-openclaw-cli --check || fail "--check follows once nothing shadows the runtime"
pass "the runtime has to be the openclaw PATH finds, and anything else is refused before it is set up"

# A runtime that answers without the package still leaves --now a pacman step,
# which the default agent must not run outside a terminal.
rm "$test_tmp/package-installed"
run omarchy-install-openclaw-cli --check && fail "--check calls a runtime without its package installed"
pass "--check needs the package too, so --now never has a password to ask for unseen"

# Upstream's installer rewrites a loaded gateway service to the copy it has
# just made, so a gateway running another OpenClaw stops the seeding first.
new_home foreign-gateway
mkdir -p "$test_home/.config/systemd/user"
printf 'Environment=OPENCLAW_CONFIG_PATH=%s/.openclaw/openclaw.json\nExecStart=/opt/node %s/openclaw/dist/index.js gateway --config %s/.openclaw/openclaw.json\n' "$test_home" "$test_home" "$test_home" \
  >"$test_home/.config/systemd/user/openclaw-gateway.service"
run omarchy-install-openclaw-cli --now && fail "a gateway running another OpenClaw stops the install"
grep -q "runs another OpenClaw" "$test_tmp/output" || fail "a gateway running another OpenClaw is named" "$(cat "$test_tmp/output")"
! grep -q '^install-cli' "$events" && [[ ! -e $test_home/.openclaw ]] ||
  fail "a gateway running another OpenClaw is refused before anything is set up" "$(cat "$events")"
pass "a gateway running another OpenClaw is refused before upstream's installer can take it over"

# A gateway the old package installed runs from /usr/lib/node_modules, which
# the seed package no longer ships; one running any other OpenClaw stays.
new_home services
units="$test_home/.config/systemd/user"
mkdir -p "$units"
printf 'ExecStart=/usr/bin/node /usr/lib/node_modules/openclaw/dist/index.js gateway --port 18789\n' >"$units/openclaw-gateway.service"
printf 'ExecStart=/opt/node /home/someone/openclaw/dist/index.js node run\n' >"$units/openclaw-node.service"
touch "$test_home/active-openclaw-gateway.service" "$test_home/enabled-openclaw-gateway.service"
OPENCLAW_PROFILE=work run omarchy-install-openclaw-cli --now || fail "--now moves the old package's services" "$(cat "$test_tmp/output")"
order=$(grep -n -e '^systemctl --user stop openclaw-gateway.service$' -e '^install-cli ' -e '^runtime gateway install --force$' "$events" | cut -d: -f2- | cut -c1-11)
[[ $order == $'systemctl -\ninstall-cli\nruntime gat' ]] ||
  fail "--now stops a gateway the old package installed before seeding, then moves it" "$(cat "$events")"
! grep -q "runtime node install\|openclaw-node" "$events" || fail "--now leaves a service running another OpenClaw alone" "$(cat "$events")"
! grep -q "profile=work" <(grep -v -e '^runtime --version' "$events") ||
  fail "--now seeds and moves the default unit whatever profile the shell selects" "$(cat "$events")"
sed -n 's/^ExecStart=\([^ ]*\).*/\1/p' "$units/openclaw-gateway.service" | grep -qx "$test_home/.openclaw/tools/node-v24.19.0/bin/node" ||
  fail "--now leaves the moved gateway on the runtime's own Node" "$(cat "$units/openclaw-gateway.service")"
grep -Fxq "runtime gateway install --force --runtime-path $test_home/.openclaw/tools/node-v24.19.0/bin/node" "$events" ||
  fail "--now pins the runtime's Node when the installer kept the system one" "$(cat "$events")"
pass "a service the old package installed moves to the runtime, and only that one"

# Installing a service enables and starts it, so one the user had left stopped
# and disabled is moved and then put back that way.
new_home dormant
mkdir -p "$test_home/.config/systemd/user"
printf 'ExecStart=/usr/bin/node /usr/lib/node_modules/openclaw/dist/index.js gateway --port 18789\n' >"$test_home/.config/systemd/user/openclaw-gateway.service"
run omarchy-install-openclaw-cli --now || fail "--now moves a dormant gateway" "$(cat "$test_tmp/output")"
runs=$(sed -n 's/^ExecStart=\([^ ]*\).*/\1/p' "$test_home/.config/systemd/user/openclaw-gateway.service")
[[ $runs == "$test_home/.openclaw/tools/node-v24.19.0/bin/node" && ! -e $test_home/active-openclaw-gateway.service && ! -e $test_home/enabled-openclaw-gateway.service ]] ||
  fail "--now moves a dormant gateway and leaves it stopped and disabled" "$(cat "$events")"
pass "a gateway the user left stopped and disabled is moved and stays that way"

new_home stop-fails
mkdir -p "$test_home/.config/systemd/user"
printf 'ExecStart=/usr/bin/node /usr/lib/node_modules/openclaw/dist/index.js gateway --port 18789\n' >"$test_home/.config/systemd/user/openclaw-gateway.service"
OMARCHY_TEST_STOP_FAIL=openclaw-gateway.service run omarchy-install-openclaw-cli --now && fail "a gateway that will not stop stops the install"
grep -q "Could not stop the OpenClaw gateway service" "$test_tmp/output" || fail "a gateway that will not stop is named" "$(cat "$test_tmp/output")"
! grep -q '^install-cli' "$events" && [[ ! -e $test_home/.openclaw ]] ||
  fail "a gateway that will not stop leaves the runtime unseeded" "$(cat "$events")"
pass "a gateway that will not stop stops the install before anything is seeded"

new_home stop-partial
mkdir -p "$test_home/.config/systemd/user"
for role in gateway node; do
  printf 'ExecStart=/usr/bin/node /usr/lib/node_modules/openclaw/dist/index.js %s\n' "$role" >"$test_home/.config/systemd/user/openclaw-$role.service"
  touch "$test_home/active-openclaw-$role.service"
done
OMARCHY_TEST_STOP_FAIL=openclaw-node.service run omarchy-install-openclaw-cli --now && fail "a node host that will not stop stops the install"
grep -q "gateway service was stopped for this and is not running now" "$test_tmp/output" ||
  fail "a gateway stopped before a later stop failed is named as stopped" "$(cat "$test_tmp/output")"
pass "a service this run stopped is named whenever the run then fails"

# Upstream's installer rewrites the gateway itself and only warns when it will
# not start again, so a gateway that was running has to be running afterwards.
new_home start-fails
mkdir -p "$test_home/.config/systemd/user"
printf 'ExecStart=/usr/bin/node /usr/lib/node_modules/openclaw/dist/index.js gateway --port 18789\n' >"$test_home/.config/systemd/user/openclaw-gateway.service"
touch "$test_home/active-openclaw-gateway.service"
OMARCHY_TEST_START_FAIL=1 run omarchy-install-openclaw-cli --now && fail "a moved gateway that does not start fails the install"
grep -q "Could not move the OpenClaw gateway service" "$test_tmp/output" && grep -q "is not running now" "$test_tmp/output" ||
  fail "a moved gateway that does not start is named, and so is its being stopped" "$(cat "$test_tmp/output")"
pass "a gateway that was running is running again from the runtime, or the install fails saying it is stopped"

# With the runtime already in place nothing is seeded, so the move is Omarchy's.
new_home runtime-first
run omarchy-install-openclaw-cli --now || fail "--now sets OpenClaw up" "$(cat "$test_tmp/output")"
mkdir -p "$test_home/.config/systemd/user"
printf 'ExecStart=/usr/bin/node /usr/lib/node_modules/openclaw/dist/index.js gateway --port 18789\n' >"$test_home/.config/systemd/user/openclaw-gateway.service"
touch "$test_home/active-openclaw-gateway.service"
: >"$events"
run omarchy-install-openclaw-cli --now || fail "--now moves a gateway beside a runtime that already runs" "$(cat "$test_tmp/output")"
! grep -q '^install-cli' "$events" && grep -Fxq "runtime gateway install --force --runtime-path $test_home/.openclaw/tools/node-v24.19.0/bin/node" "$events" && [[ -e $test_home/active-openclaw-gateway.service ]] ||
  fail "--now moves a gateway beside a runtime that already runs" "$(cat "$events")"
pass "a gateway beside a runtime that already runs is moved without seeding"

# A move that stopped halfway left the runtime's code on the old package's
# /usr/bin/node; the next run finishes it, and moves a node host the same way.
new_home half-moved
run omarchy-install-openclaw-cli --now || fail "--now sets OpenClaw up" "$(cat "$test_tmp/output")"
mkdir -p "$test_home/.config/systemd/user"
printf 'ExecStart=/usr/bin/node %s/.openclaw/tools/node-v24.19.0/lib/node_modules/openclaw/dist/index.js gateway --port 18789\n' "$test_home" >"$test_home/.config/systemd/user/openclaw-gateway.service"
printf 'ExecStart=/usr/bin/node %s/.openclaw/tools/node-v24.19.0/lib/node_modules/openclaw/dist/index.js node run\n' "$test_home" >"$test_home/.config/systemd/user/openclaw-node.service"
touch "$test_home/active-openclaw-gateway.service" "$test_home/active-openclaw-node.service"
: >"$events"
run omarchy-install-openclaw-cli --now || fail "--now finishes a half-moved gateway" "$(cat "$test_tmp/output")"
for role in gateway node; do
  grep -Fxq "runtime $role install --force --runtime-path $test_home/.openclaw/tools/node-v24.19.0/bin/node" "$events" &&
    sed -n 's/^ExecStart=\([^ ]*\).*/\1/p' "$test_home/.config/systemd/user/openclaw-$role.service" | grep -qx "$test_home/.openclaw/tools/node-v24.19.0/bin/node" ||
    fail "--now finishes a half-moved $role on the runtime's own Node" "$(cat "$events")"
done
pass "a half-moved gateway and a node host end up on the runtime's own Node"

# The runtime run by any other Node or by Bun is the user's choice, not the old
# package's dependency.
new_home bun
run omarchy-install-openclaw-cli --now || fail "--now sets OpenClaw up" "$(cat "$test_tmp/output")"
mkdir -p "$test_home/.config/systemd/user"
printf 'ExecStart=/usr/bin/bun %s/.openclaw/tools/node-v24.19.0/lib/node_modules/openclaw/dist/index.js gateway --port 18789\n' "$test_home" >"$test_home/.config/systemd/user/openclaw-gateway.service"
cp "$test_home/.config/systemd/user/openclaw-gateway.service" "$test_tmp/bun-unit"
: >"$events"
run omarchy-install-openclaw-cli --now || fail "--now leaves a Bun gateway alone" "$(cat "$test_tmp/output")"
! grep -q "install --force\|^systemctl" "$events" && cmp -s "$test_tmp/bun-unit" "$test_home/.config/systemd/user/openclaw-gateway.service" ||
  fail "--now leaves a Bun gateway alone" "$(cat "$events")"
printf 'ExecStart=/usr/bin/node %s/.openclaw/custom/bridge.js\n' "$test_home" >"$test_home/.config/systemd/user/openclaw-gateway.service"
cp "$test_home/.config/systemd/user/openclaw-gateway.service" "$test_tmp/own-unit"
: >"$events"
run omarchy-install-openclaw-cli --now || fail "--now leaves a script of the user's alone" "$(cat "$test_tmp/output")"
! grep -q "install --force\|^systemctl" "$events" && cmp -s "$test_tmp/own-unit" "$test_home/.config/systemd/user/openclaw-gateway.service" ||
  fail "--now leaves a script of the user's alone" "$(cat "$events")"
pass "a gateway the user runs on Bun, or a script of their own on /usr/bin/node, is left alone"

# The migration moves only machines that have the package, and waits for the
# package that seeds.
new_home migration-none
run bash -euo pipefail "$test_tmp/migration.sh" || fail "a machine without OpenClaw has nothing to move" "$(cat "$test_tmp/output")"
[[ ! -s $events && ! -e $test_home/.openclaw ]] || fail "a machine without OpenClaw is untouched" "$(cat "$events")"

new_home migration-old
touch "$test_tmp/package-installed"
mv "$seed" "$seed.old"
run bash -euo pipefail "$test_tmp/migration.sh" && fail "an old package keeps the migration pending"
[[ ! -e $test_home/.openclaw ]] || fail "an old package leaves the home untouched"
mv "$seed.old" "$seed"

new_home migration
touch "$test_tmp/package-installed"
mkdir -p "$test_home/.config/systemd/user"
printf 'ExecStart=/usr/bin/node /usr/lib/node_modules/openclaw/dist/index.js gateway --port 18789\n' >"$test_home/.config/systemd/user/openclaw-gateway.service"
run bash -euo pipefail "$test_tmp/migration.sh" || fail "the migration moves OpenClaw" "$(cat "$test_tmp/output")"
grep -q "^install-cli " "$events" && grep -Fxq "runtime gateway install --force" "$events" ||
  fail "the migration seeds the runtime and moves the gateway to it" "$(cat "$events")"
[[ $(readlink -- "$command") == "$runtime" ]] || fail "the migration points the command at the runtime"
sed -n 's/^ExecStart=\([^ ]*\).*/\1/p' "$test_home/.config/systemd/user/openclaw-gateway.service" | grep -qx "$test_home/.openclaw/tools/node-v24.19.0/bin/node" ||
  fail "the migration leaves the gateway on the runtime's own Node, not the old package's system Node" "$(cat "$test_home/.config/systemd/user/openclaw-gateway.service")"

new_home migration-foreign
touch "$test_tmp/package-installed"
printf '#!/bin/bash\n' >"$command"
run bash -euo pipefail "$test_tmp/migration.sh" && fail "a migration that cannot finish stays pending"
pass "the migration moves a packaged OpenClaw to its runtime, and stays pending until it can"
