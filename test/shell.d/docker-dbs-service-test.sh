#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

grep -F 'sudo systemctl enable --now docker.service' "$ROOT/bin/omarchy-install-docker-dbs" >/dev/null ||
  fail "Docker DB installer does not enable docker.service"
pass "Docker DB installer enables docker.service when a database is chosen"

migration="$ROOT/migrations/1787864101.sh"
[[ -f $migration ]] || fail "Docker DB docker.service migration is missing"
pass "Docker DB docker.service migration exists"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"
SYSTEMCTL_LOG="$tmp_dir/systemctl-log"
DOCKER_LOG="$tmp_dir/docker-log"

cat >"$tmp_dir/bin/systemctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$SYSTEMCTL_LOG"
if [[ $1 == "is-enabled" ]]; then
  if [[ $2 == "docker.socket" && -z ${SOCKET_DISABLED:-} ]]; then
    exit 0
  else
    exit 1
  fi
fi
exit 0
SH

cat >"$tmp_dir/bin/docker" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$DOCKER_LOG"
if [[ $1 == "info" ]]; then
  exit 0
fi
if [[ $1 == "container" && $2 == "ls" ]]; then
  printf '%s\n' "postgres18"
  exit 0
fi
exit 1
SH

cat >"$tmp_dir/bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH

cat >"$tmp_dir/bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 0
SH

chmod +x "$tmp_dir/bin/systemctl" "$tmp_dir/bin/docker" "$tmp_dir/bin/sudo" "$tmp_dir/bin/omarchy-cmd-present"

PATH="$tmp_dir/bin:$PATH" \
SYSTEMCTL_LOG="$SYSTEMCTL_LOG" \
DOCKER_LOG="$DOCKER_LOG" \
  bash -euo pipefail "$migration" >/dev/null

grep -Fqx -- "enable --now docker.service" "$SYSTEMCTL_LOG" ||
  fail "migration does not enable docker.service when a Docker DB container exists"
pass "migration enables docker.service when a Docker DB container exists"

: >"$SYSTEMCTL_LOG"
: >"$DOCKER_LOG"

cat >"$tmp_dir/bin/docker" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$DOCKER_LOG"
if [[ $1 == "info" || ( $1 == "container" && $2 == "ls" ) ]]; then
  exit 0
fi
exit 1
SH
chmod +x "$tmp_dir/bin/docker"

PATH="$tmp_dir/bin:$PATH" \
SYSTEMCTL_LOG="$SYSTEMCTL_LOG" \
DOCKER_LOG="$DOCKER_LOG" \
  bash -euo pipefail "$migration" >/dev/null

if grep -Fqx -- "enable --now docker.service" "$SYSTEMCTL_LOG"; then
  fail "migration enables docker.service when no Docker DB container exists"
fi
pass "migration leaves docker.service alone when no Docker DB container exists"

: >"$SYSTEMCTL_LOG"
: >"$DOCKER_LOG"

cat >"$tmp_dir/bin/docker" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$DOCKER_LOG"
if [[ $1 == "info" ]]; then
  exit 0
else
  echo "Cannot connect to the Docker daemon" >&2
  exit 1
fi
SH
chmod +x "$tmp_dir/bin/docker"

if PATH="$tmp_dir/bin:$PATH" \
SYSTEMCTL_LOG="$SYSTEMCTL_LOG" \
DOCKER_LOG="$DOCKER_LOG" \
  bash -euo pipefail "$migration" >/dev/null 2>&1; then
  fail "migration treats a failed container query as an empty container list"
fi
if grep -Fqx -- "enable --now docker.service" "$SYSTEMCTL_LOG"; then
  fail "migration enables docker.service after a failed container query"
fi
pass "migration stays pending when the container query fails after docker info succeeds"

: >"$SYSTEMCTL_LOG"
: >"$DOCKER_LOG"

cat >"$tmp_dir/bin/docker" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$DOCKER_LOG"
if [[ $1 == "info" ]]; then
  exit 1
fi
exit 0
SH
chmod +x "$tmp_dir/bin/docker"

if PATH="$tmp_dir/bin:$PATH" \
SYSTEMCTL_LOG="$SYSTEMCTL_LOG" \
DOCKER_LOG="$DOCKER_LOG" \
  bash -euo pipefail "$migration" >/dev/null 2>&1; then
  fail "migration treats docker info failure as success"
fi
if grep -Fqx -- "enable --now docker.service" "$SYSTEMCTL_LOG"; then
  fail "migration enables docker.service after docker info failure"
fi
pass "migration stays pending when docker info fails"

: >"$SYSTEMCTL_LOG"
: >"$DOCKER_LOG"

PATH="$tmp_dir/bin:$PATH" \
SYSTEMCTL_LOG="$SYSTEMCTL_LOG" \
DOCKER_LOG="$DOCKER_LOG" \
SOCKET_DISABLED=1 \
  bash -euo pipefail "$migration" >/dev/null 2>&1 ||
  fail "migration blocks the queue when Docker is switched off"
[[ ! -s $DOCKER_LOG ]] || fail "migration starts dockerd when Docker is switched off"
pass "migration leaves Docker alone when it is switched off"

for legacy_name in postgres16 postgres17; do
  : >"$SYSTEMCTL_LOG"
  : >"$DOCKER_LOG"

  cat >"$tmp_dir/bin/docker" <<SH
#!/bin/bash
printf '%s\n' "\$*" >>"\$DOCKER_LOG"
if [[ \$1 == "info" ]]; then
  exit 0
fi
if [[ \$1 == "container" && \$2 == "ls" ]]; then
  printf '%s\n' "$legacy_name"
  exit 0
fi
exit 1
SH
  chmod +x "$tmp_dir/bin/docker"

  PATH="$tmp_dir/bin:$PATH" \
  SYSTEMCTL_LOG="$SYSTEMCTL_LOG" \
  DOCKER_LOG="$DOCKER_LOG" \
    bash -euo pipefail "$migration" >/dev/null

  grep -Fqx -- "enable --now docker.service" "$SYSTEMCTL_LOG" ||
    fail "migration does not enable docker.service for $legacy_name"
  pass "migration enables docker.service for an older $legacy_name container"
done

installer="$ROOT/bin/omarchy-install-docker-dbs"
INSTALL_LOG="$tmp_dir/install-log"

cat >"$tmp_dir/bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH

cat >"$tmp_dir/bin/docker" <<'SH'
#!/bin/bash
printf 'docker %s\n' "$*" >>"$INSTALL_LOG"
if [[ $1 == "inspect" ]]; then
  exit 1
fi
exit 0
SH

cat >"$tmp_dir/bin/systemctl" <<'SH'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$INSTALL_LOG"
exit 0
SH
chmod +x "$tmp_dir/bin/sudo" "$tmp_dir/bin/docker" "$tmp_dir/bin/systemctl"

: >"$INSTALL_LOG"
PATH="$tmp_dir/bin:$PATH" INSTALL_LOG="$INSTALL_LOG" \
  bash "$installer" Redis >/dev/null
seen_run=0
seen_enable_after_run=0
while IFS= read -r line; do
  if [[ $line == "docker run"* ]]; then
    seen_run=1
  elif [[ $line == "systemctl enable --now docker.service" ]] && (( seen_run == 1 )); then
    seen_enable_after_run=1
  fi
done <"$INSTALL_LOG"
(( seen_enable_after_run )) || fail "installer does not enable docker.service after a container is created" "$(cat "$INSTALL_LOG")"
pass "installer enables docker.service after a database container is created"

: >"$INSTALL_LOG"
PATH="$tmp_dir/bin:$PATH" INSTALL_LOG="$INSTALL_LOG" \
  bash "$installer" "" >/dev/null
if grep -Fqx -- "systemctl enable --now docker.service" "$INSTALL_LOG"; then
  fail "installer enables docker.service when no database is selected"
fi
pass "installer leaves docker.service alone when no database is selected"

cat >"$tmp_dir/bin/docker" <<'SH'
#!/bin/bash
printf 'docker %s\n' "$*" >>"$INSTALL_LOG"
exit 1
SH
chmod +x "$tmp_dir/bin/docker"
: >"$INSTALL_LOG"
if PATH="$tmp_dir/bin:$PATH" INSTALL_LOG="$INSTALL_LOG" \
  bash "$installer" Redis >/dev/null 2>&1; then
  fail "installer succeeds when no database container is created"
fi
if grep -Fqx -- "systemctl enable --now docker.service" "$INSTALL_LOG"; then
  fail "installer enables docker.service when no database container is created"
fi
pass "installer leaves docker.service alone when container creation fails"

cat >"$tmp_dir/bin/docker" <<'SH'
#!/bin/bash
printf 'docker %s\n' "$*" >>"$INSTALL_LOG"
if [[ $1 == "inspect" ]]; then
  exit 1
fi
exit 0
SH
cat >"$tmp_dir/bin/systemctl" <<'SH'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$INSTALL_LOG"
exit 1
SH
chmod +x "$tmp_dir/bin/docker" "$tmp_dir/bin/systemctl"
: >"$INSTALL_LOG"
enable_output=$(PATH="$tmp_dir/bin:$PATH" INSTALL_LOG="$INSTALL_LOG" bash "$installer" Redis 2>&1) &&
  fail "installer succeeds when enabling docker.service fails"
[[ $enable_output == *"Failed to enable docker.service"* ]] ||
  fail "installer does not report a failed docker.service enable" "$enable_output"
grep -Fqx -- "systemctl enable --now docker.service" "$INSTALL_LOG" ||
  fail "installer does not attempt to enable docker.service after creating a container"
pass "installer fails when enabling docker.service fails"

cat >"$tmp_dir/bin/docker" <<'SH'
#!/bin/bash
printf 'docker %s\n' "$*" >>"$INSTALL_LOG"
if [[ $1 == "inspect" ]]; then
  exit 1
fi
if [[ $* == *"--name=redis"* ]]; then
  exit 1
fi
exit 0
SH
cat >"$tmp_dir/bin/systemctl" <<'SH'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$INSTALL_LOG"
exit 0
SH
chmod +x "$tmp_dir/bin/docker" "$tmp_dir/bin/systemctl"
: >"$INSTALL_LOG"
partial_output=$(PATH="$tmp_dir/bin:$PATH" INSTALL_LOG="$INSTALL_LOG" bash "$installer" MySQL Redis 2>&1) &&
  fail "installer succeeds when a later database fails"
[[ $partial_output == *"Not every selected database was installed."* ]] ||
  fail "installer does not report a partial database install" "$partial_output"
grep -Fqx -- "systemctl enable --now docker.service" "$INSTALL_LOG" ||
  fail "installer does not enable docker.service when another selected database exists"
pass "installer fails a partial install after enabling docker.service for the database that exists"

cat >"$tmp_dir/bin/docker" <<'SH'
#!/bin/bash
printf 'docker %s\n' "$*" >>"$INSTALL_LOG"
if [[ $1 == "inspect" && $2 == "--type" && $4 == "redis" ]]; then
  exit 0
fi
if [[ $1 == "inspect" && $4 == "--format" && $6 == "redis" ]]; then
  printf '%s\n' "redis:7 unless-stopped running"
  exit 0
fi
exit 1
SH
chmod +x "$tmp_dir/bin/docker"
: >"$INSTALL_LOG"
PATH="$tmp_dir/bin:$PATH" INSTALL_LOG="$INSTALL_LOG" \
  bash "$installer" Redis >/dev/null
grep -Fqx -- "systemctl enable --now docker.service" "$INSTALL_LOG" ||
  fail "installer does not enable docker.service when the container already exists"
if grep -F -- "docker run" "$INSTALL_LOG"; then
  fail "installer recreates a database container that already exists"
fi
if grep -F -- "docker start" "$INSTALL_LOG"; then
  fail "installer starts a database container that is already running"
fi
pass "installer enables docker.service for a database container that already exists"

cat >"$tmp_dir/bin/docker" <<'SH'
#!/bin/bash
printf 'docker %s\n' "$*" >>"$INSTALL_LOG"
if [[ $1 == "inspect" && $2 == "--type" && $4 == "redis" ]]; then
  exit 0
fi
if [[ $1 == "inspect" && $4 == "--format" && $6 == "redis" ]]; then
  printf '%s\n' "redis:7 unless-stopped exited"
  exit 0
fi
if [[ $1 == "start" && $2 == "redis" ]]; then
  exit 0
fi
exit 1
SH
chmod +x "$tmp_dir/bin/docker"
: >"$INSTALL_LOG"
PATH="$tmp_dir/bin:$PATH" INSTALL_LOG="$INSTALL_LOG" \
  bash "$installer" Redis >/dev/null
grep -Fqx -- "docker start redis" "$INSTALL_LOG" ||
  fail "installer does not start a stopped database container" "$(cat "$INSTALL_LOG")"
grep -Fqx -- "systemctl enable --now docker.service" "$INSTALL_LOG" ||
  fail "installer does not enable docker.service for a stopped database container"
pass "installer starts a stopped database container and enables docker.service"

cat >"$tmp_dir/bin/docker" <<'SH'
#!/bin/bash
printf 'docker %s\n' "$*" >>"$INSTALL_LOG"
if [[ $1 == "inspect" && $2 == "--type" && $4 == "redis" ]]; then
  exit 0
fi
if [[ $1 == "inspect" && $4 == "--format" && $6 == "redis" ]]; then
  printf '%s unless-stopped %s\n' "${EXISTING_IMAGE:-redis:latest}" "${EXISTING_STATE:-running}"
  exit 0
fi
if [[ $1 == "start" && $2 == "redis" ]]; then
  exit 0
fi
exit 1
SH
chmod +x "$tmp_dir/bin/docker"
: >"$INSTALL_LOG"
wrong_output=$(PATH="$tmp_dir/bin:$PATH" INSTALL_LOG="$INSTALL_LOG" bash "$installer" Redis 2>&1) &&
  fail "installer accepts a container that is not the selected database"
[[ $wrong_output == *"is not this database."* ]] ||
  fail "installer does not report a conflicting container" "$wrong_output"
if grep -Fqx -- "systemctl enable --now docker.service" "$INSTALL_LOG"; then
  fail "installer enables docker.service for a container that is not the selected database"
fi
pass "installer rejects a container that is not the selected database"

: >"$INSTALL_LOG"
if PATH="$tmp_dir/bin:$PATH" INSTALL_LOG="$INSTALL_LOG" \
EXISTING_IMAGE="otheruser/redis:7" EXISTING_STATE="exited" \
  bash "$installer" Redis >/dev/null 2>&1; then
  fail "installer accepts an unrelated image repository with the expected tag"
fi
if grep -Fqx -- "docker start redis" "$INSTALL_LOG"; then
  fail "installer starts a conflicting container from an unrelated image repository"
fi
if grep -Fqx -- "systemctl enable --now docker.service" "$INSTALL_LOG"; then
  fail "installer enables docker.service for an unrelated image repository"
fi
pass "installer rejects an unrelated image repository without starting its container"

for official_image in library/redis:7 docker.io/redis:7 docker.io/library/redis:7 index.docker.io/redis:7 index.docker.io/library/redis:7; do
  : >"$INSTALL_LOG"
  PATH="$tmp_dir/bin:$PATH" INSTALL_LOG="$INSTALL_LOG" \
  EXISTING_IMAGE="$official_image" EXISTING_STATE="running" \
    bash "$installer" Redis >/dev/null 2>&1 ||
    fail "installer rejects the official Redis image alias $official_image"
  grep -Fqx -- "systemctl enable --now docker.service" "$INSTALL_LOG" ||
    fail "installer does not enable docker.service for $official_image"
  pass "installer accepts the official Redis image alias $official_image"
done
