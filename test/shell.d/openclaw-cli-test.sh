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
# OMARCHY_TEST_PACKAGE_COMMAND makes the package bring an openclaw of its own,
# the way the package before the seed did.
cat >"$mock_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'pkg-add %s\n' "$*" >>"$OMARCHY_TEST_ROOT/events"
touch "$OMARCHY_TEST_ROOT/package-installed"
if [[ -n ${OMARCHY_TEST_PACKAGE_COMMAND:-} ]]; then
  printf '#!/bin/bash\n' >"$OMARCHY_TEST_ROOT/usr-bin/openclaw"
  chmod +x "$OMARCHY_TEST_ROOT/usr-bin/openclaw"
fi
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
  start)
    printf 'systemctl %s\n' "$*" >>"$OMARCHY_TEST_ROOT/events"
    [[ -z ${OMARCHY_TEST_SYSTEMCTL_START_FAIL:-} ]] || exit 1
    touch "$HOME/active-$3"
    ;;
  is-active) [[ -e $HOME/active-$4 ]] && ! [[ $4 == openclaw-gateway.service && -s $HOME/gateway-restarting ]] ;;
  show)
    if [[ $4 == ExecStart && -n ${OMARCHY_TEST_DROPIN_EXEC:-} ]]; then
      echo "{ path=${OMARCHY_TEST_DROPIN_EXEC%% *} ; argv[]=$OMARCHY_TEST_DROPIN_EXEC ; ignore_errors=no }"
    elif [[ $4 == ExecStart ]]; then
      for dir in "$HOME/.config/systemd/user" "$HOME/Unit Files/systemd/user" "$HOME/.local/share/systemd/user"; do
        [[ -e $dir/${*: -1} ]] || continue
        exec=$(sed -n 's/^ExecStart=//p' "$dir/${*: -1}" | head -1)
        echo "{ path=${exec%% *} ; argv[]=$exec ; ignore_errors=no }"
        exit 0
      done
      echo
    elif [[ -s $HOME/gateway-restarting ]]; then echo activating
    elif [[ -e $HOME/active-${*: -1} ]]; then echo active
    else echo failed
    fi
    ;;
  is-enabled) [[ -e $HOME/enabled-$4 ]] ;;
  disable)
    printf 'systemctl %s\n' "$*" >>"$OMARCHY_TEST_ROOT/events"
    rm -f "$HOME/enabled-$3"
    ;;
esac
SH
# The running manager's unit directories over D-Bus, whatever the caller's
# environment, one of them with a space in its name.
cat >"$mock_bin/busctl" <<'SH'
#!/bin/bash
[[ -z ${OMARCHY_TEST_UNITPATH_FAIL:-} ]] || exit 1
if [[ -n ${OMARCHY_TEST_UNITPATH_PARTIAL:-} ]]; then
  echo '{"type":"as","data":["/nowhere"]}'
  exit 1
fi
if [[ -n ${OMARCHY_TEST_UNITPATH_EMPTY:-} ]]; then
  echo '{"type":"as","data":[]}'
  exit 0
fi
printf '{"type":"as","data":["%s","%s","%s"]}\n' "$HOME/.config/systemd/user" "$HOME/Unit Files/systemd/user" "$HOME/.local/share/systemd/user"
SH
# systemd-analyze works its directories out from the caller's own environment,
# not the running manager's, as the real one does.
cat >"$mock_bin/systemd-analyze" <<'SH'
#!/bin/bash
printf '%s\n' "${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user" "${XDG_DATA_HOME:-$HOME/.local/share}/systemd/user"
SH
# Waiting on a gateway takes no time here.
printf '#!/bin/bash\n' >"$mock_bin/sleep"
chmod +x "$mock_bin/"*

# Stands in for upstream's install-cli.sh: it writes the command the way the
# real one does, execing into the prefix's tools, and that command logs what
# it is asked. OMARCHY_TEST_INSTALL_BROKEN leaves a command that cannot run.
# Like upstream, `<role> install --force` rewrites the unit onto the runtime
# and starts it, OMARCHY_TEST_START_FAIL making the start fail (1 for any
# role, or the one it names), and the
# installer does that itself for a gateway it finds loaded. As upstream does
# since 2026.9.6, a rewrite keeps the Node the unit already ran unless
# --runtime-path pins one.
# `health` answers while the gateway is active, except over a stale-agent-db in
# the home: a newer runtime refuses that and exits until `doctor` migrates it
# (OMARCHY_TEST_DOCTOR_CANNOT_FIX leaves it). A gateway-starting answers once
# with health's own "still starting", which exits 0; a gateway-restarting holds
# that many failed answers while systemd waits to restart the unit, counting
# from the install when it starts as restarts-after-install; and with
# OMARCHY_TEST_GATEWAY_URL_ANSWERS another gateway an OPENCLAW_GATEWAY_URL names
# answers for it. A gateway-port is the one port the gateway listens on, where
# health otherwise asks the configured 18789.
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
  [[ -z "\${OMARCHY_TEST_START_FAIL:-}" || ( "\$OMARCHY_TEST_START_FAIL" != 1 && "\$OMARCHY_TEST_START_FAIL" != "\$1" ) ]] || exit 1
  touch "\$HOME/active-openclaw-\$1.service" "\$HOME/enabled-openclaw-\$1.service"
  [[ ! -e "\$HOME/restarts-after-install" ]] || mv "\$HOME/restarts-after-install" "\$HOME/gateway-restarting"
fi
case "\${1:-}" in
  health)
    if [[ -n "\${OMARCHY_TEST_GATEWAY_URL_ANSWERS:-}" && -n "\${OPENCLAW_GATEWAY_URL:-}" ]]; then
      echo '{"ok":true}'
      exit
    fi
    if [[ -e "\$HOME/gateway-port" && \$(cat "\$HOME/gateway-port") != "\${OPENCLAW_GATEWAY_PORT:-18789}" ]]; then
      exit 1
    fi
    if [[ -e "\$HOME/gateway-starting" ]]; then
      rm "\$HOME/gateway-starting"
      echo '{"status":"starting"}'
      exit
    fi
    if [[ -s "\$HOME/gateway-restarting" ]]; then
      echo \$(( \$(cat "\$HOME/gateway-restarting") - 1 )) >"\$HOME/gateway-restarting"
      [[ \$(cat "\$HOME/gateway-restarting") != 0 ]] || rm "\$HOME/gateway-restarting"
      exit 1
    fi
    if [[ -e "\$HOME/stale-agent-db" ]]; then
      rm -f "\$HOME/active-openclaw-gateway.service"
      exit 1
    fi
    [[ -e "\$HOME/active-openclaw-gateway.service" ]] || exit 1
    echo '{"ok":true}'
    exit
    ;;
  doctor) [[ -n "\${OMARCHY_TEST_DOCTOR_CANNOT_FIX:-}" ]] || rm -f "\$HOME/stale-agent-db" ;;
esac
exec true "$prefix/tools/node-v24.19.0/lib/node_modules/openclaw/dist/entry.js" "\$@"
EOF
chmod 755 "$prefix/bin/openclaw"
if [[ -f $HOME/.config/systemd/user/openclaw-gateway.service ]]; then
  "$prefix/bin/openclaw" gateway install --force || true
fi
SH
touch "$seed/openclaw.tgz"

# Scratch copies of the actual scripts, with only the package's path and
# /usr/local/bin swapped.
mkdir -p "$test_tmp/usr-local-bin"
for script in bin/omarchy-install-openclaw-cli migrations/1792334754.sh migrations/1790397381.sh; do
  sed -e "s|/usr/share/openclaw|$seed|g" -e "s|/usr/local/bin|$test_tmp/usr-local-bin|g" -e "s|/usr/bin/openclaw|$test_tmp/usr-bin/openclaw|g" \
    "$ROOT/$script" >"$mock_bin/${script##*/}"
done
mv "$mock_bin/1792334754.sh" "$test_tmp/migration.sh"
mv "$mock_bin/1790397381.sh" "$test_tmp/retired-migration.sh"
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
# test can drop another openclaw. The system's commands come from a directory
# of their own, so an openclaw on the machine running this is never found.
mkdir -p "$test_tmp/usr-bin" "$test_tmp/tools"
for tool in bash cat chmod cp cut env grep head jq ln mkdir mv readlink realpath rm sed sha256sum stat timeout touch true; do
  ln -s "$(type -P "$tool")" "$test_tmp/tools/$tool"
done
run() {
  HOME="$test_home" OMARCHY_TEST_ROOT="$test_tmp" MISE_SHIMS_DIR='' MISE_DATA_DIR='' XDG_DATA_HOME='' PATH="$test_tmp/usr-bin:$mock_bin:$test_home/.local/bin:$test_tmp/tools" \
    "$@" >"$test_tmp/output" 2>&1
}

# omarchy update runs migrations on a fixed system PATH, without
# /usr/local/bin, mise's shims or ~/.local/bin.
run_update() {
  HOME="$test_home" OMARCHY_TEST_ROOT="$test_tmp" MISE_SHIMS_DIR='' MISE_DATA_DIR='' XDG_DATA_HOME='' PATH="$mock_bin:$test_tmp/tools" \
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

# Until the channel serves the seed, the package is OpenClaw itself, as before
# this release: it is installed, and nothing is seeded, linked or moved.
new_home old-package
mv "$seed" "$seed.old"
run omarchy-install-openclaw-cli --check && fail "--check calls OpenClaw missing before its package is installed"
OMARCHY_TEST_PACKAGE_COMMAND=1 run omarchy-install-openclaw-cli --now || fail "--now installs a package that is still OpenClaw itself" "$(cat "$test_tmp/output")"
grep -Fxq "pkg-add openclaw" "$events" || fail "--now installs the package that is still OpenClaw" "$(cat "$events")"
grep -q "runs from its package" "$test_tmp/output" || fail "--now says OpenClaw runs from its package for now" "$(cat "$test_tmp/output")"
run omarchy-install-openclaw-cli --check || fail "--check takes a package that is still OpenClaw itself as installed"
: >"$events"
run omarchy-install-openclaw-cli --now || fail "--now accepts a package that is still OpenClaw itself" "$(cat "$test_tmp/output")"
[[ ! -s $events && ! -e $test_home/.openclaw && ! -e $command ]] ||
  fail "a package that is still OpenClaw itself is left as it is: nothing seeded, linked or moved" "$(cat "$events")"
run omarchy-install-openclaw-cli --now || fail "--now accepts an installed package that is still OpenClaw itself" "$(cat "$test_tmp/output")"
# Its command is then the one OpenClaw, and one a session would run ahead of it
# is refused as it is for the runtime.
shims="$test_home/.local/share/mise/shims"
mkdir -p "$shims"
printf '#!/bin/bash\n' >"$shims/openclaw"
chmod +x "$shims/openclaw"
run omarchy-install-openclaw-cli --check && fail "--check refuses a mise shim ahead of the package that is OpenClaw itself"
run omarchy-install-openclaw-cli --now && fail "--now refuses a mise shim ahead of the package that is OpenClaw itself"
grep -q "Another openclaw is on PATH at $shims/openclaw, which Omarchy could run instead of $test_tmp/usr-bin/openclaw" "$test_tmp/output" ||
  fail "--now names the openclaw ahead of the package's own" "$(cat "$test_tmp/output")"
rm "$shims/openclaw"
run omarchy-install-openclaw-cli --check || fail "--check takes the package again once nothing is ahead of it"
rm "$test_tmp/usr-bin/openclaw"
mv "$seed.old" "$seed"
pass "a package that is still OpenClaw itself is the installation until the seed arrives"

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
grep -q "on PATH at $test_tmp/usr-bin/openclaw" "$test_tmp/output" || fail "an openclaw earlier on PATH is named" "$(cat "$test_tmp/output")"
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

# An openclaw anywhere a session looks is refused, wherever it sits relative to
# the runtime, because the order differs between a terminal, the desktop and
# omarchy update.
new_home elsewhere
run omarchy-install-openclaw-cli --now || fail "--now sets OpenClaw up" "$(cat "$test_tmp/output")"
printf '#!/bin/bash\n' >"$test_tmp/tools/openclaw"
chmod +x "$test_tmp/tools/openclaw"
run omarchy-install-openclaw-cli --check && fail "--check calls a runtime installed with another openclaw later on PATH"
rm "$test_tmp/tools/openclaw"
run omarchy-install-openclaw-cli --check || fail "--check follows once the runtime is the only openclaw"
pass "an openclaw later on PATH than the runtime counts too"

# omarchy update's PATH finds no openclaw at all. The runtime is still what a
# session finds in ~/.local/bin, and what that PATH leaves out is still looked at.
new_home update-path
run_update omarchy-install-openclaw-cli --now || fail "--now finishes on omarchy update's PATH" "$(cat "$test_tmp/output")"
[[ $(readlink -- "$command") == "$runtime" ]] || fail "--now links the command on omarchy update's PATH"
run_update omarchy-install-openclaw-cli --check || fail "--check follows a finished install on omarchy update's PATH"
rm "$command"
run_update omarchy-install-openclaw-cli --check && fail "--check needs the command a session runs"
run_update omarchy-install-openclaw-cli --now || fail "--now relinks the command on omarchy update's PATH" "$(cat "$test_tmp/output")"
# mise's shims follow MISE_SHIMS_DIR, then MISE_DATA_DIR, then XDG_DATA_HOME,
# and every session's PATH has the default directory whichever it is.
for place in mise-shims mise-shims-dir mise-data-dir xdg-data-home default-shims-moved usr-local-bin; do
  new_home "update-path-$place"
  data_dirs=()
  case $place in
    mise-shims) other="$test_home/.local/share/mise/shims/openclaw" ;;
    mise-shims-dir)
      other="$test_home/shims/openclaw"
      data_dirs=(MISE_SHIMS_DIR="$test_home/shims" MISE_DATA_DIR="$test_home/tools/mise")
      ;;
    mise-data-dir)
      other="$test_home/tools/mise/shims/openclaw"
      data_dirs=(MISE_DATA_DIR="$test_home/tools/mise")
      ;;
    xdg-data-home)
      other="$test_home/data/mise/shims/openclaw"
      data_dirs=(XDG_DATA_HOME="$test_home/data")
      ;;
    default-shims-moved)
      other="$test_home/.local/share/mise/shims/openclaw"
      data_dirs=(MISE_DATA_DIR="$test_home/tools/mise")
      ;;
    usr-local-bin) other="$test_tmp/usr-local-bin/openclaw" ;;
  esac
  mkdir -p "${other%/*}"
  printf '#!/bin/bash\n' >"$other"
  chmod +x "$other"
  run_update env "${data_dirs[@]}" omarchy-install-openclaw-cli --now && fail "$other fails the install on omarchy update's PATH"
  grep -q "on PATH at $other" "$test_tmp/output" || fail "$other is named on omarchy update's PATH" "$(cat "$test_tmp/output")"
  [[ ! -e $test_home/.openclaw && ! -e $command && ! -s $events ]] || fail "$other is refused before anything is touched" "$(cat "$events")"
  rm "$other"
done
pass "mise's shims, wherever its data directory is, and /usr/local/bin are looked at on omarchy update's PATH, which leaves them out"

# A shim directory mise no longer uses is not where a session looks.
new_home inactive-shims
mkdir -p "$test_home/tools/mise/shims"
printf '#!/bin/bash\n' >"$test_home/tools/mise/shims/openclaw"
chmod +x "$test_home/tools/mise/shims/openclaw"
run_update env MISE_SHIMS_DIR="$test_home/shims" MISE_DATA_DIR="$test_home/tools/mise" omarchy-install-openclaw-cli --now ||
  fail "a shim directory MISE_SHIMS_DIR replaced does not block the install" "$(cat "$test_tmp/output")"
pass "only the shim directory mise uses is looked at"

# The package is installed after the first check, so an openclaw it brings is
# only seen by the last one.
new_home package-command
run omarchy-install-openclaw-cli --now || fail "--now sets OpenClaw up" "$(cat "$test_tmp/output")"
rm "$test_tmp/package-installed"
OMARCHY_TEST_PACKAGE_COMMAND=1 run omarchy-install-openclaw-cli --now && fail "an openclaw the package brings fails the install"
grep -q "is ready, but another openclaw is on PATH at $test_tmp/usr-bin/openclaw" "$test_tmp/output" || fail "an openclaw the package brings is named" "$(cat "$test_tmp/output")"
rm "$test_tmp/usr-bin/openclaw"
pass "an openclaw that appears during the install is caught before it reports success"

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
OMARCHY_TEST_START_FAIL=1 OMARCHY_TEST_SYSTEMCTL_START_FAIL=1 run omarchy-install-openclaw-cli --now && fail "a moved gateway that does not start fails the install"
grep -q "gateway does not answer after moving" "$test_tmp/output" && grep -q "is not running now" "$test_tmp/output" ||
  fail "a moved gateway that does not start is named, and so is its being stopped" "$(cat "$test_tmp/output")"
pass "a gateway that was running is running again from the runtime, or the install fails saying it is stopped"

# A run that fails after stopping the gateway leaves it stopped, and the run
# that then succeeds would otherwise take it for one the user stopped.
new_home retry
mkdir -p "$test_home/.config/systemd/user"
printf 'ExecStart=/usr/bin/node /usr/lib/node_modules/openclaw/dist/index.js gateway --port 18789\n' >"$test_home/.config/systemd/user/openclaw-gateway.service"
touch "$test_home/active-openclaw-gateway.service" "$test_home/enabled-openclaw-gateway.service"
OMARCHY_TEST_INSTALL_BROKEN=1 run omarchy-install-openclaw-cli --now && fail "a setup that does not complete fails the install"
grep -q "starts again once this completes" "$test_tmp/output" || fail "a failed run says the gateway it stopped starts again" "$(cat "$test_tmp/output")"
[[ ! -e $test_home/active-openclaw-gateway.service ]] || fail "a failed run leaves the gateway it stopped stopped"
run omarchy-install-openclaw-cli --now || fail "the next run finishes the move" "$(cat "$test_tmp/output")"
[[ -e $test_home/active-openclaw-gateway.service && ! -e $test_home/.local/state/omarchy/openclaw-stopped/gateway ]] ||
  fail "a gateway a failed run stopped is running again once a later run finishes" "$(cat "$events")"
pass "a gateway a failed run stopped is running again once a later run finishes"

# The same when upstream's installer moved the unit before the failure, so the
# later run has nothing to move.
new_home retry-moved
run omarchy-install-openclaw-cli --now || fail "--now sets OpenClaw up" "$(cat "$test_tmp/output")"
mkdir -p "$test_home/.config/systemd/user" "$test_home/.local/state/omarchy/openclaw-stopped"
printf 'ExecStart=%s/.openclaw/tools/node-v24.19.0/bin/node %s/.openclaw/tools/node-v24.19.0/lib/node_modules/openclaw/dist/index.js gateway\n' "$test_home" "$test_home" >"$test_home/.config/systemd/user/openclaw-gateway.service"
touch "$test_home/.local/state/omarchy/openclaw-stopped/gateway"
run omarchy-install-openclaw-cli --now || fail "--now finishes with a moved, stopped gateway" "$(cat "$test_tmp/output")"
[[ -e $test_home/active-openclaw-gateway.service && ! -e $test_home/.local/state/omarchy/openclaw-stopped/gateway ]] ||
  fail "a moved gateway a failed run stopped is started" "$(cat "$events")"
pass "a gateway a failed run stopped after it was moved is started too"

# A moved gateway can start and exit seconds later, refusing the agent database
# an older OpenClaw left, so one that was running has to answer, and gets one
# doctor run, with the gateway stopped, when it does not.
for case in healthy stale stuck; do
  new_home "gateway-$case"
  mkdir -p "$test_home/.config/systemd/user"
  printf 'ExecStart=/usr/bin/node /usr/lib/node_modules/openclaw/dist/index.js gateway --port 18789\n' >"$test_home/.config/systemd/user/openclaw-gateway.service"
  touch "$test_home/active-openclaw-gateway.service" "$test_home/enabled-openclaw-gateway.service"
  [[ $case == healthy ]] || touch "$test_home/stale-agent-db"
  if [[ $case == stuck ]]; then
    OMARCHY_TEST_DOCTOR_CANNOT_FIX=1 run omarchy-install-openclaw-cli --now && fail "a moved gateway that still does not answer fails the install"
    grep -q "does not answer after moving" "$test_tmp/output" && [[ -e $test_home/.local/state/omarchy/openclaw-stopped/gateway ]] ||
      fail "a moved gateway that still does not answer is named and kept for the next run" "$(cat "$test_tmp/output")"
    rm "$test_home/stale-agent-db"
    run omarchy-install-openclaw-cli --now || fail "the next run finishes once the gateway answers" "$(cat "$test_tmp/output")"
    [[ ! -e $test_home/.local/state/omarchy/openclaw-stopped/gateway ]] || fail "a gateway that answers again drops its record"
    continue
  fi
  run omarchy-install-openclaw-cli --now || fail "--now moves a running gateway ($case)" "$(cat "$test_tmp/output")"
  if [[ $case == healthy ]]; then
    ! grep -q '^runtime doctor' "$events" || fail "a moved gateway that answers is not doctored" "$(cat "$events")"
    continue
  fi
  after=$(sed -n '/^runtime gateway install/,$p' "$events" | grep -e '^systemctl --user st' -e '^runtime doctor' || true)
  [[ $after == $'systemctl --user stop openclaw-gateway.service\nruntime doctor --fix --non-interactive\nsystemctl --user start openclaw-gateway.service' ]] ||
    fail "a moved gateway that does not answer is stopped, doctored and started" "$(cat "$events")"
  [[ ! -e $test_home/stale-agent-db && -e $test_home/active-openclaw-gateway.service ]] || fail "a doctored gateway is running and answers"
done
pass "a moved gateway that was running answers again, after one doctor run if it needs one, or the install fails and keeps it for the next run"

# Only the local gateway's own "ok" counts: health exits 0 while a gateway is
# still starting, and a caller's OPENCLAW_GATEWAY_URL could name another one.
# A unit systemd is about to restart is waited for, not doctored.
moved_running_gateway() {
  new_home "$1"
  mkdir -p "$test_home/.config/systemd/user"
  printf 'ExecStart=/usr/bin/node /usr/lib/node_modules/openclaw/dist/index.js gateway --port 18789\n' >"$test_home/.config/systemd/user/openclaw-gateway.service"
  touch "$test_home/active-openclaw-gateway.service" "$test_home/enabled-openclaw-gateway.service"
}
moved_running_gateway gateway-starting
touch "$test_home/gateway-starting"
run omarchy-install-openclaw-cli --now || fail "--now waits for a gateway that is still starting" "$(cat "$test_tmp/output")"
(( $(grep -c '^runtime health' "$events") >= 2 )) && ! grep -q '^runtime doctor' "$events" ||
  fail "a gateway still starting is asked again rather than taken as serving, and is not doctored" "$(cat "$events")"
moved_running_gateway gateway-elsewhere
touch "$test_home/stale-agent-db"
OPENCLAW_GATEWAY_URL=ws://elsewhere:18789 OMARCHY_TEST_GATEWAY_URL_ANSWERS=1 run omarchy-install-openclaw-cli --now ||
  fail "--now repairs the local gateway whatever OPENCLAW_GATEWAY_URL names" "$(cat "$test_tmp/output")"
grep -q '^runtime doctor' "$events" && [[ ! -e $test_home/stale-agent-db ]] ||
  fail "another gateway answering for OPENCLAW_GATEWAY_URL does not pass for the local one" "$(cat "$events")"
moved_running_gateway gateway-restarting
echo 3 >"$test_home/restarts-after-install"
run omarchy-install-openclaw-cli --now || fail "--now waits out a gateway systemd is restarting" "$(cat "$test_tmp/output")"
(( $(grep -c '^runtime health' "$events") >= 3 )) && ! grep -q '^runtime doctor' "$events" ||
  fail "a gateway systemd is restarting is waited for, not doctored" "$(cat "$events")"
pass "only the local gateway's own answer counts, after a start or a restart in progress"

# A gateway keeps its record until it answers, so another service failing
# after it moved cannot leave a gateway that exited unrepaired.
moved_running_gateway gateway-then-node
printf 'ExecStart=/usr/bin/node /usr/lib/node_modules/openclaw/dist/index.js node\n' >"$test_home/.config/systemd/user/openclaw-node.service"
touch "$test_home/active-openclaw-node.service" "$test_home/stale-agent-db"
OMARCHY_TEST_START_FAIL=node run omarchy-install-openclaw-cli --now && fail "a node host that does not start fails the run"
grep -q '^runtime doctor' "$events" && [[ ! -e $test_home/.local/state/omarchy/openclaw-stopped/gateway && -e $test_home/.local/state/omarchy/openclaw-stopped/node ]] ||
  fail "the gateway is repaired and answers before its record goes, and the node host keeps its own" "$(cat "$events"; ls "$test_home/.local/state/omarchy/openclaw-stopped" 2>&1)"
pass "a moved gateway answers before its record goes, even when another service then fails"

# A record only repairs Omarchy's gateway: a unit the user has since replaced
# with an OpenClaw of their own is left to them. And doctor never runs beside a
# gateway that would not stop.
new_home record-foreign-unit
run omarchy-install-openclaw-cli --now || fail "--now sets OpenClaw up" "$(cat "$test_tmp/output")"
mkdir -p "$test_home/.config/systemd/user" "$test_home/.local/state/omarchy/openclaw-stopped"
printf 'ExecStart=/opt/node /home/someone/openclaw/dist/index.js gateway\n' >"$test_home/.config/systemd/user/openclaw-gateway.service"
touch "$test_home/.local/state/omarchy/openclaw-stopped/gateway" "$test_home/active-openclaw-gateway.service" "$test_home/stale-agent-db"
: >"$events"
run omarchy-install-openclaw-cli --now || fail "--now finishes beside the user's own gateway" "$(cat "$test_tmp/output")"
! grep -q '^runtime doctor\|^systemctl --user stop' "$events" || fail "a record does not stop or doctor a gateway the user replaced" "$(cat "$events")"
new_home record-stop-fails
run omarchy-install-openclaw-cli --now || fail "--now sets OpenClaw up" "$(cat "$test_tmp/output")"
mkdir -p "$test_home/.config/systemd/user" "$test_home/.local/state/omarchy/openclaw-stopped"
printf 'ExecStart=%s/.openclaw/tools/node-v24.19.0/bin/node %s/.openclaw/tools/node-v24.19.0/lib/node_modules/openclaw/dist/index.js gateway\n' "$test_home" "$test_home" >"$test_home/.config/systemd/user/openclaw-gateway.service"
touch "$test_home/.local/state/omarchy/openclaw-stopped/gateway" "$test_home/active-openclaw-gateway.service" "$test_home/stale-agent-db"
OMARCHY_TEST_STOP_FAIL=openclaw-gateway.service run omarchy-install-openclaw-cli --now && fail "a gateway that will not stop for its repair fails the run"
! grep -q '^runtime doctor' "$events" && grep -q "Could not stop the OpenClaw gateway service to repair it" "$test_tmp/output" &&
  [[ -e $test_home/.local/state/omarchy/openclaw-stopped/gateway ]] ||
  fail "doctor does not run beside a gateway that would not stop, and its record stays" "$(cat "$events")"
new_home record-relocated-unit
run omarchy-install-openclaw-cli --now || fail "--now sets OpenClaw up" "$(cat "$test_tmp/output")"
mkdir -p "$test_home/.local/share/systemd/user" "$test_home/.local/state/omarchy/openclaw-stopped"
printf 'ExecStart=%s/.openclaw/tools/node-v24.19.0/bin/node %s/.openclaw/tools/node-v24.19.0/lib/node_modules/openclaw/dist/index.js gateway\n' "$test_home" "$test_home" >"$test_home/.local/share/systemd/user/openclaw-gateway.service"
touch "$test_home/.local/state/omarchy/openclaw-stopped/gateway" "$test_home/stale-agent-db"
run omarchy-install-openclaw-cli --now || fail "--now repairs Omarchy's gateway in another unit directory" "$(cat "$test_tmp/output")"
grep -q '^runtime doctor' "$events" && [[ ! -e $test_home/stale-agent-db && ! -e $test_home/.local/state/omarchy/openclaw-stopped/gateway ]] ||
  fail "a record repairs Omarchy's gateway wherever the user manager loaded its unit from" "$(cat "$events")"
new_home record-dropin
run omarchy-install-openclaw-cli --now || fail "--now sets OpenClaw up" "$(cat "$test_tmp/output")"
mkdir -p "$test_home/.config/systemd/user" "$test_home/.local/state/omarchy/openclaw-stopped"
printf 'ExecStart=%s/.openclaw/tools/node-v24.19.0/bin/node %s/.openclaw/tools/node-v24.19.0/lib/node_modules/openclaw/dist/index.js gateway\n' "$test_home" "$test_home" >"$test_home/.config/systemd/user/openclaw-gateway.service"
touch "$test_home/.local/state/omarchy/openclaw-stopped/gateway" "$test_home/active-openclaw-gateway.service" "$test_home/stale-agent-db"
: >"$events"
OMARCHY_TEST_DROPIN_EXEC="/opt/node /home/someone/openclaw/dist/index.js gateway --port 19000" run omarchy-install-openclaw-cli --now ||
  fail "--now finishes beside a drop-in that runs another OpenClaw" "$(cat "$test_tmp/output")"
! grep -q '^runtime doctor\|^systemctl --user stop' "$events" ||
  fail "a gateway a drop-in points at another OpenClaw is not stopped or doctored" "$(cat "$events")"
new_home record-own-port
run omarchy-install-openclaw-cli --now || fail "--now sets OpenClaw up" "$(cat "$test_tmp/output")"
mkdir -p "$test_home/.config/systemd/user" "$test_home/.local/state/omarchy/openclaw-stopped"
printf 'ExecStart=%s/.openclaw/tools/node-v24.19.0/bin/node %s/.openclaw/tools/node-v24.19.0/lib/node_modules/openclaw/dist/index.js gateway --port 19000\n' "$test_home" "$test_home" >"$test_home/.config/systemd/user/openclaw-gateway.service"
touch "$test_home/.local/state/omarchy/openclaw-stopped/gateway" "$test_home/active-openclaw-gateway.service"
echo 19000 >"$test_home/gateway-port"
: >"$events"
run omarchy-install-openclaw-cli --now || fail "--now finds a gateway on the port its service names" "$(cat "$test_tmp/output")"
! grep -q '^runtime doctor\|^systemctl --user stop' "$events" && [[ ! -e $test_home/.local/state/omarchy/openclaw-stopped/gateway ]] ||
  fail "a gateway serving on its service's own port is not taken for down" "$(cat "$events")"
pass "a record repairs only Omarchy's gateway, and only once it has stopped"

# One that will not start keeps its record and fails the run, rather than the
# migration finishing with the gateway down.
new_home retry-start-fails
run omarchy-install-openclaw-cli --now || fail "--now sets OpenClaw up" "$(cat "$test_tmp/output")"
mkdir -p "$test_home/.config/systemd/user" "$test_home/.local/state/omarchy/openclaw-stopped"
printf 'ExecStart=%s/.openclaw/tools/node-v24.19.0/bin/node %s/.openclaw/tools/node-v24.19.0/lib/node_modules/openclaw/dist/index.js gateway\n' "$test_home" "$test_home" >"$test_home/.config/systemd/user/openclaw-gateway.service"
touch "$test_home/.local/state/omarchy/openclaw-stopped/gateway"
OMARCHY_TEST_SYSTEMCTL_START_FAIL=1 run omarchy-install-openclaw-cli --now && fail "a gateway that will not start again fails the run"
grep -q "Could not start the OpenClaw gateway service again" "$test_tmp/output" || fail "a gateway that will not start again is named" "$(cat "$test_tmp/output")"
[[ -e $test_home/.local/state/omarchy/openclaw-stopped/gateway ]] || fail "a gateway that will not start again keeps its record"
pass "a gateway a failed run stopped that will not start again fails the run and keeps its record"

# One the user removed since is gone: the record goes too, nothing is started,
# and the run is not stuck on a unit that no longer exists.
rm "$test_home/.config/systemd/user/openclaw-gateway.service"
: >"$events"
OMARCHY_TEST_SYSTEMCTL_START_FAIL=1 run omarchy-install-openclaw-cli --now || fail "a removed gateway does not block the run" "$(cat "$test_tmp/output")"
[[ ! -e $test_home/.local/state/omarchy/openclaw-stopped/gateway ]] && ! grep -q 'systemctl --user start' "$events" ||
  fail "a removed gateway's record goes and nothing is started" "$(cat "$events")"
pass "a gateway the user removed after a failed run is not started again and does not block the run"

# A unit moved to the other user directory is still the gateway systemd knows,
# so it is started again before its record goes.
new_home retry-relocated
run omarchy-install-openclaw-cli --now || fail "--now sets OpenClaw up" "$(cat "$test_tmp/output")"
mkdir -p "$test_home/.local/share/systemd/user" "$test_home/.local/state/omarchy/openclaw-stopped"
printf 'ExecStart=%s/.openclaw/tools/node-v24.19.0/bin/node %s/.openclaw/tools/node-v24.19.0/lib/node_modules/openclaw/dist/index.js gateway\n' "$test_home" "$test_home" >"$test_home/.local/share/systemd/user/openclaw-gateway.service"
touch "$test_home/.local/state/omarchy/openclaw-stopped/gateway"
: >"$events"
run omarchy-install-openclaw-cli --now || fail "--now finishes with a relocated, stopped gateway" "$(cat "$test_tmp/output")"
grep -Fxq 'systemctl --user start openclaw-gateway.service' "$events" && [[ -e $test_home/active-openclaw-gateway.service && ! -e $test_home/.local/state/omarchy/openclaw-stopped/gateway ]] ||
  fail "a relocated gateway a failed run stopped is started before its record goes" "$(cat "$events")"
pass "a gateway moved to another unit directory after a failed run is started again"

# A unit file that is there but cannot be read is not removed, and neither is
# one when the manager's unit directories cannot be had in full: it is tried,
# and a start that fails keeps the record.
for case in unreadable no-paths partial-paths empty-paths; do
  new_home "retry-$case"
  run omarchy-install-openclaw-cli --now || fail "--now sets OpenClaw up" "$(cat "$test_tmp/output")"
  mkdir -p "$test_home/.config/systemd/user" "$test_home/.local/state/omarchy/openclaw-stopped"
  touch "$test_home/.config/systemd/user/openclaw-gateway.service" "$test_home/.local/state/omarchy/openclaw-stopped/gateway"
  unitpath_fail='' unitpath_partial='' unitpath_empty=''
  case $case in
    unreadable) chmod 000 "$test_home/.config/systemd/user/openclaw-gateway.service" ;;
    no-paths)
      unitpath_fail=1
      rm "$test_home/.config/systemd/user/openclaw-gateway.service"
      ;;
    partial-paths) unitpath_partial=1 ;;
    empty-paths) unitpath_empty=1 ;;
  esac
  : >"$events"
  OMARCHY_TEST_UNITPATH_FAIL=$unitpath_fail OMARCHY_TEST_UNITPATH_PARTIAL=$unitpath_partial OMARCHY_TEST_UNITPATH_EMPTY=$unitpath_empty OMARCHY_TEST_SYSTEMCTL_START_FAIL=1 run omarchy-install-openclaw-cli --now &&
    fail "a gateway that is not shown removed is started, and one that will not start fails the run ($case)"
  grep -Fxq 'systemctl --user start openclaw-gateway.service' "$events" && [[ -e $test_home/.local/state/omarchy/openclaw-stopped/gateway ]] ||
    fail "a gateway that is not shown removed is tried and keeps its record ($case)" "$(cat "$events")"
  chmod 644 "$test_home/.config/systemd/user/openclaw-gateway.service" 2>/dev/null || true
done
pass "a gateway is taken for removed only when no unit directory holds it"

# The directories are the running manager's: a caller with another
# XDG_CONFIG_HOME still finds the gateway's unit and starts it.
new_home retry-caller-env
run omarchy-install-openclaw-cli --now || fail "--now sets OpenClaw up" "$(cat "$test_tmp/output")"
mkdir -p "$test_home/.config/systemd/user" "$test_home/.local/state/omarchy/openclaw-stopped"
printf 'ExecStart=%s/.openclaw/tools/node-v24.19.0/bin/node %s/.openclaw/tools/node-v24.19.0/lib/node_modules/openclaw/dist/index.js gateway\n' "$test_home" "$test_home" >"$test_home/.config/systemd/user/openclaw-gateway.service"
touch "$test_home/.local/state/omarchy/openclaw-stopped/gateway"
: >"$events"
run env XDG_CONFIG_HOME="$test_tmp/elsewhere" omarchy-install-openclaw-cli --now || fail "--now finishes from a caller with another XDG_CONFIG_HOME" "$(cat "$test_tmp/output")"
grep -Fxq 'systemctl --user start openclaw-gateway.service' "$events" && [[ ! -e $test_home/.local/state/omarchy/openclaw-stopped/gateway ]] ||
  fail "a caller with another XDG_CONFIG_HOME still starts the gateway again" "$(cat "$events")"
pass "the unit directories are the running manager's, whatever the caller's environment"

# A unit directory with a space in its name is one directory.
new_home retry-spaced
run omarchy-install-openclaw-cli --now || fail "--now sets OpenClaw up" "$(cat "$test_tmp/output")"
mkdir -p "$test_home/Unit Files/systemd/user" "$test_home/.local/state/omarchy/openclaw-stopped"
touch "$test_home/Unit Files/systemd/user/openclaw-gateway.service" "$test_home/.local/state/omarchy/openclaw-stopped/gateway"
: >"$events"
run omarchy-install-openclaw-cli --now || fail "--now finishes with a gateway in a unit directory with a space" "$(cat "$test_tmp/output")"
grep -Fxq 'systemctl --user start openclaw-gateway.service' "$events" ||
  fail "a gateway in a unit directory with a space in its name is started again" "$(cat "$events")"
pass "a unit directory with a space in its name is read as one directory"

# Each record goes as soon as its own service is back, so one that moved does
# not keep a record for a later run to act on after the user stops it.
new_home retry-partial
mkdir -p "$test_home/.config/systemd/user"
for role in gateway node; do
  printf 'ExecStart=/usr/bin/node /usr/lib/node_modules/openclaw/dist/index.js %s\n' "$role" >"$test_home/.config/systemd/user/openclaw-$role.service"
  touch "$test_home/active-openclaw-$role.service" "$test_home/enabled-openclaw-$role.service"
done
OMARCHY_TEST_START_FAIL=node run omarchy-install-openclaw-cli --now && fail "a node host that does not start fails the run"
[[ ! -e $test_home/.local/state/omarchy/openclaw-stopped/gateway && -e $test_home/.local/state/omarchy/openclaw-stopped/node ]] ||
  fail "the gateway that moved loses its record and the node host that did not keeps it" "$(ls "$test_home/.local/state/omarchy/openclaw-stopped" 2>&1)"
pass "a service that moved loses its record even when another fails"

# The record is written before the stop, so a run that cannot write it stops nothing.
new_home record-unwritable
mkdir -p "$test_home/.config/systemd/user" "$test_home/.local/state/omarchy"
printf 'ExecStart=/usr/bin/node /usr/lib/node_modules/openclaw/dist/index.js gateway --port 18789\n' >"$test_home/.config/systemd/user/openclaw-gateway.service"
touch "$test_home/active-openclaw-gateway.service" "$test_home/.local/state/omarchy/openclaw-stopped"
run omarchy-install-openclaw-cli --now && fail "a record that cannot be written fails the run"
[[ -e $test_home/active-openclaw-gateway.service ]] || fail "a run that cannot record the gateway leaves it running" "$(cat "$events")"
pass "a gateway is recorded before it is stopped"

# A machine that moved and then got the package that is OpenClaw itself back
# has an older copy ahead of its own on PATH: that is not an installation.
new_home moved-then-old-package
run omarchy-install-openclaw-cli --now || fail "--now sets OpenClaw up" "$(cat "$test_tmp/output")"
mv "$seed" "$seed.old"
printf '#!/bin/bash\n' >"$test_tmp/usr-bin/openclaw"
chmod +x "$test_tmp/usr-bin/openclaw"
run omarchy-install-openclaw-cli --check && fail "--check does not take the old package for installed after a move"
: >"$events"
run omarchy-install-openclaw-cli --now && fail "--now refuses the old package after a move"
grep -q "is OpenClaw itself again and comes first on PATH" "$test_tmp/output" || fail "--now says the old package is in the way" "$(cat "$test_tmp/output")"
[[ ! -s $events && $(readlink -- "$command") == "$runtime" ]] || fail "--now touches nothing when the old package is back" "$(cat "$events")"
rm "$test_tmp/usr-bin/openclaw"
mv "$seed.old" "$seed"
pass "after a move, the package that is OpenClaw itself again is named, not accepted"

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

# The migration moves only machines that have the package, once it is the seed.
new_home migration-none
run bash -euo pipefail "$test_tmp/migration.sh" || fail "a machine without OpenClaw has nothing to move" "$(cat "$test_tmp/output")"
[[ ! -s $events && ! -e $test_home/.openclaw ]] || fail "a machine without OpenClaw is untouched" "$(cat "$events")"

new_home migration-old
touch "$test_tmp/package-installed"
mv "$seed" "$seed.old"
run bash -euo pipefail "$test_tmp/migration.sh" || fail "an old package does not stop the update" "$(cat "$test_tmp/output")"
[[ ! -s $events && ! -e $test_home/.openclaw ]] || fail "an old package leaves the home untouched" "$(cat "$events")"
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

new_home migration-broken
touch "$test_tmp/package-installed"
OMARCHY_TEST_INSTALL_BROKEN=1 run bash -euo pipefail "$test_tmp/migration.sh" && fail "a migration whose setup failed stays pending"
pass "the migration moves a packaged OpenClaw to its runtime once the package is the seed"

# An OpenClaw of the user's own in the way is theirs to move aside. The
# migration changes nothing and finishes, so it does not stop every update.
for case in command path gateway; do
  new_home "migration-own-$case"
  touch "$test_tmp/package-installed"
  case $case in
  command)
    printf '#!/bin/bash\necho mine\n' >"$command"
    chmod +x "$command"
    ;;
  path)
    printf '#!/bin/bash\n' >"$test_tmp/usr-bin/openclaw"
    chmod +x "$test_tmp/usr-bin/openclaw"
    ;;
  gateway)
    mkdir -p "$test_home/.config/systemd/user"
    printf 'ExecStart=/opt/node %s/openclaw/dist/index.js gateway\n' "$test_home" >"$test_home/.config/systemd/user/openclaw-gateway.service"
    ;;
  esac
  run bash -euo pipefail "$test_tmp/migration.sh" ||
    fail "an OpenClaw of the user's own does not stop the update ($case)" "$(cat "$test_tmp/output")"
  grep -q "Leaving OpenClaw as it is" "$test_tmp/output" || fail "the migration says it left OpenClaw alone ($case)" "$(cat "$test_tmp/output")"
  ! grep -q '^install-cli' "$events" && [[ ! -e $test_home/.openclaw ]] ||
    fail "the migration sets nothing up beside an OpenClaw of the user's own ($case)" "$(cat "$events")"
  rm -f "$test_tmp/usr-bin/openclaw"
done
grep -q mine "$test_home/../migration-own-command/.local/bin/openclaw" || fail "the user's own command is kept"
pass "an OpenClaw of the user's own leaves the migration finished and changes nothing"

new_home migration-update
touch "$test_tmp/package-installed"
mkdir -p "$test_home/.config/systemd/user"
printf 'ExecStart=/usr/bin/node /usr/lib/node_modules/openclaw/dist/index.js gateway --port 18789\n' >"$test_home/.config/systemd/user/openclaw-gateway.service"
run_update bash -euo pipefail "$test_tmp/migration.sh" || fail "the migration finishes under omarchy update" "$(cat "$test_tmp/output")"
grep -q "^install-cli " "$events" && [[ $(readlink -- "$command") == "$runtime" ]] ||
  fail "the migration under omarchy update seeds the runtime and links the command" "$(cat "$events")"
pass "the migration finishes under omarchy update, whose PATH has no ~/.local/bin"

# 4.0.5 shipped the move as 1790397381 before the seed package and it stopped
# every update (#15804), so that one now finishes everywhere and changes nothing.
# The move is a migration of its own, which a machine that marked the old one
# done still runs.
for case in none old seeded; do
  new_home "retired-$case"
  [[ $case == none ]] || touch "$test_tmp/package-installed"
  [[ $case != old ]] || mv "$seed" "$seed.old"
  mkdir -p "$test_home/.config/systemd/user"
  printf 'ExecStart=/usr/bin/node /usr/lib/node_modules/openclaw/dist/index.js gateway --port 18789\n' >"$test_home/.config/systemd/user/openclaw-gateway.service"
  cp "$test_home/.config/systemd/user/openclaw-gateway.service" "$test_tmp/packaged-unit"
  run bash -euo pipefail "$test_tmp/retired-migration.sh" || fail "the retired migration finishes ($case)" "$(cat "$test_tmp/output")"
  [[ ! -s $events && ! -e $test_home/.openclaw ]] || fail "the retired migration changes nothing ($case)" "$(cat "$events")"
  cmp -s "$test_tmp/packaged-unit" "$test_home/.config/systemd/user/openclaw-gateway.service" ||
    fail "the retired migration leaves the packaged gateway alone ($case)"
  [[ $case != old ]] || mv "$seed.old" "$seed"
done
pass "the retired migration finishes without moving OpenClaw, with or without the seed package"
