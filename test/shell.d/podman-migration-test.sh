#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/bin" "$test_dir/home/.local/share/applications"
export TEST_LOG="$test_dir/calls"
export STUB_DOCKER=0 STUB_NAMES="" STUB_GROUPS=wheel STUB_WINDOWS=managed STUB_CHANGED=0 STUB_COMPLETED=valid

cat >"$test_dir/bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$TEST_LOG"
case "$1" in
  python3)
    if [[ $2 == */migrate-windows.py ]]; then
      [[ $STUB_WINDOWS != invalid ]] || exit 1
      [[ $STUB_WINDOWS != forced || $3 != --stop ]] || exit 1
    else
      cat >/dev/null
    fi ;;
  docker)
    [[ $2 == --host && $3 == unix:///var/run/docker.sock ]] || exit 2
    shift 2
    case "$2" in
      ps)
        if [[ $* == *'{{.ID}}'* ]]; then
          while read -r name; do
            [[ -z $name ]] || printf 'fixture-id-%s %s\n' "$name" "$name"
          done <<<"$STUB_NAMES"
        else
          printf '%s\n' "$STUB_NAMES"
        fi
        if [[ $STUB_CHANGED == 1 ]] && grep -q 'migrate-databases.py --check-completed' "$TEST_LOG"; then
          printf 'new-id new-container\n'
        fi ;;
      stop) [[ $3 == '-t' && $4 == 120 && $5 == omarchy-windows ]] ;;
      *) exit 2 ;;
    esac ;;
  test) exit 1 ;;
  ufw) [[ $2 != status ]] || echo 'Status: active' ;;
esac
SH
cat >"$test_dir/bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ $1 == ufw ]]
SH
cat >"$test_dir/bin/pacman" <<'SH'
#!/bin/bash
[[ $* != '-Qq' ]] || exit 0
[[ $* != '-Qq once-bin' ]] || exit 1
[[ $* == '-Qq docker' ]] || exit 2
if [[ $STUB_DOCKER == 1 ]]; then
  echo docker
else
  # pacman resolves the docker virtual package to its installed provider.
  echo podman-docker
fi
SH
cat >"$test_dir/bin/id" <<'SH'
#!/bin/bash
if [[ $1 == -u ]]; then
  echo 1000
else
  echo "$STUB_GROUPS"
fi
SH
cat >"$test_dir/bin/python3" <<'SH'
#!/bin/bash
printf 'python3 %s\n' "$*" >>"$TEST_LOG"
if [[ $* == *--check-completed* && $STUB_COMPLETED == changed ]]; then exit 1; fi
if [[ $* == *custom-project* ]]; then
  echo 'custom-project requires its own Compose definition' >&2
  exit 1
fi
SH
for name in omarchy-pkg-add omarchy-pkg-drop systemctl podman omarchy-state dbus-update-activation-environment; do
  cat >"$test_dir/bin/$name" <<'SH'
#!/bin/bash
printf '%s %s\n' "${0##*/}" "$*" >>"$TEST_LOG"
SH
done
chmod +x "$test_dir/bin"/*

run_migration() {
  : >"$TEST_LOG"
  HOME="$test_dir/home" USER=tester OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$PATH" \
    bash -euo pipefail "$ROOT/migrations/1788886195.sh" >"$test_dir/output" 2>&1
}

STUB_DOCKER=1 STUB_NAMES=$'redis\nomarchy-windows' STUB_WINDOWS=invalid
run_migration && fail "unmanaged Windows name bypassed preflight"
! grep -q 'migrate-databases.py\|--stop tester\|disable --now docker\|omarchy-pkg-drop' "$TEST_LOG" ||
  fail "invalid Windows handover changed a workload"
pass "unmanaged Windows name blocks the complete batch before any source stops"

STUB_NAMES=omarchy-windows STUB_WINDOWS=forced
run_migration && fail "forced Windows shutdown retired Docker"
! grep -q 'disable --now docker\|omarchy-pkg-drop' "$TEST_LOG" || fail "unclean Windows shutdown removed Docker"
pass "Windows shutdown failure retains the engine and leaves migration pending"
STUB_WINDOWS=managed

STUB_DOCKER=1 STUB_NAMES=$'omarchy-windows\ncustom-project'
run_migration && fail "migration discarded an unmigrated database"
! grep -q 'docker stop\|disable --now docker\|omarchy-pkg-drop' "$TEST_LOG" ||
  fail "migration stopped or removed the old engine before workload transfer"
! grep -q '^sudo pacman .*podman-docker$' "$TEST_LOG" ||
  fail "migration replaced the Docker CLI before workload transfer"
grep -q custom-project "$test_dir/output" || fail "migration did not identify the pending workload"
pass "existing workloads keep Docker and the migration pending"

STUB_NAMES=redis STUB_CHANGED=1
run_migration && fail "new Docker container was ignored before engine retirement"
! grep -q 'disable --now docker\|sudo pacman .*podman-docker' "$TEST_LOG" || fail "new inventory retired the engine"
pass "new containers during transfer keep Docker installed and available"
STUB_CHANGED=0 STUB_COMPLETED=changed
run_migration && fail "changed completed source was ignored before retirement"
! grep -q 'disable --now docker\|sudo pacman .*podman-docker' "$TEST_LOG" || fail "changed completed transfer retired Docker"
pass "resumed completed sources prevent engine retirement"
STUB_COMPLETED=valid
STUB_NAMES=omarchy-windows
run_migration || fail "Windows-only handover failed" "$(cat "$test_dir/output")"
grep -q 'sudo python3 .*migrate-windows.py --stop tester' "$TEST_LOG" || fail "Windows was not shut down gracefully"
grep -q 'sudo systemctl disable --now docker.socket docker.service' "$TEST_LOG" || fail "old engine stays enabled"
grep -q '^omarchy-state set reboot-required$' "$TEST_LOG" || fail "retired engine runtime did not flag a reboot"
! grep -q 'docker rm\|podman rm\|docker volume rm' "$TEST_LOG" || fail "handover deletes existing data"
grep -q '^omarchy-pkg-drop docker-buildx docker-compose ufw-docker lazydocker lazydocker-bin$' "$TEST_LOG" ||
  fail "retired Docker tools remain"
engine_stopped=$(grep -n '^sudo systemctl disable --now docker.socket docker.service$' "$TEST_LOG" | cut -d: -f1)
shim_installed=$(grep -n '^sudo pacman -S --needed --noconfirm --ask 4 podman-docker$' "$TEST_LOG" | cut -d: -f1)
[[ -n $shim_installed ]] && (( engine_stopped < shim_installed )) ||
  fail "Docker provider must be replaced atomically after handover"
! grep -q '^omarchy-pkg-drop docker ' "$TEST_LOG" || fail "Docker removal breaks dependent packages"
pass "Windows handover stops Docker and retains storage for Podman"

STUB_DOCKER=0 STUB_NAMES="" STUB_GROUPS='wheel docker'
printf old >"$test_dir/home/.local/share/applications/Docker.desktop"
run_migration || fail "Docker-free migration failed"
[[ ! -e $test_dir/home/.local/share/applications/Docker.desktop ]] || fail "old launcher remains"
[[ -f $test_dir/home/.local/share/applications/io.podman_desktop.PodmanDesktop.desktop ]] || fail "Podman launcher is missing"
[[ -f "$test_dir/home/.local/share/applications/Podman TUI.desktop" ]] || fail "Podman TUI launcher is missing"
grep -q '^omarchy-pkg-add podman-desktop podman-tui$' "$TEST_LOG" || fail "Podman TUI package is missing"
grep -q '^sudo gpasswd -d tester docker$' "$TEST_LOG" || fail "retired group membership remains"
grep -q '^omarchy-state set reboot-required$' "$TEST_LOG" || fail "group change did not flag a reboot"
grep -q '^systemctl --user enable --now podman.socket$' "$TEST_LOG" || fail "rootless API socket is missing"
grep -q '^dbus-update-activation-environment --systemd DOCKER_HOST$' "$TEST_LOG" || fail "Docker API activation environment was not refreshed"
pass "Docker-free retry updates the launcher, user services, Docker API environment and group state"

STUB_GROUPS=wheel
run_migration || fail "repeat migration failed"
! grep -q '^sudo docker ' "$TEST_LOG" || fail "retry still depends on Docker"
! grep -q '^sudo gpasswd ' "$TEST_LOG" || fail "retry repeats an already completed group change"
! grep -q 'systemctl start docker.socket' "$TEST_LOG" || fail "retry mistakes the Podman shim for Docker Engine"
grep -q '^sudo pacman .*podman-docker$' "$TEST_LOG" || fail "retry does not retain Docker command compatibility"
pass "completed migration can be repeated with the Docker compatibility command present"

mkdir -p "$test_dir/home/.local/state/omarchy"
touch "$test_dir/home/.local/state/omarchy/preinstalls-removed"
rm "$test_dir/home/.local/share/applications/io.podman_desktop.PodmanDesktop.desktop"
rm "$test_dir/home/.local/share/applications/Podman TUI.desktop"
run_migration || fail "preinstall opt-out migration failed"
! grep -q '^omarchy-pkg-add podman-desktop' "$TEST_LOG" || fail "migration restores opted-out container apps"
[[ ! -e $test_dir/home/.local/share/applications/io.podman_desktop.PodmanDesktop.desktop ]] || fail "migration restores an opted-out launcher"
[[ ! -e "$test_dir/home/.local/share/applications/Podman TUI.desktop" ]] || fail "migration restores an opted-out TUI launcher"
pass "migration respects the preinstalled-app opt-out"
