#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

# Load the real migration without dispatching any VM operation. All mount,
# credential and privileged writer work is stubbed; only parsing and the final
# archive move run for real, against files in this scratch directory.
source "$ROOT/bin/omarchy-windows-vm" help >/dev/null
LEGACY_COMPOSE_FILE="$scratch/legacy with spaces/docker-compose.yml"
COMPOSE_FILE="$scratch/protected/docker-compose.yml"
backup="$LEGACY_COMPOSE_FILE.bak"
target="$scratch/archive with spaces"
calls="$scratch/calls"
stage_failure=""

prepare_user_mount_sources() {
  echo prepare >> "$calls"
  [[ $stage_failure != "prepare" ]]
}
write_credentials() {
  echo credentials >> "$calls"
  printf '%s\0' "$@" > "$scratch/credentials-argv"
  [[ $stage_failure != "credentials" ]]
}
write_compose() {
  echo compose >> "$calls"
  printf '%s\0' "$@" > "$scratch/compose-argv"
  [[ $stage_failure != "compose" ]] || return 1
  printf 'fixture migrated compose\n' > "$COMPOSE_FILE"
}
priv() { fail "legacy archive fixtures never invoke privileged VM actions"; }

reset_fixture() {
  rm -rf "$scratch/legacy with spaces" "$scratch/protected" "$target"
  mkdir -p "$(dirname "$LEGACY_COMPOSE_FILE")" "$(dirname "$COMPOSE_FILE")" "$target"
  cat > "$LEGACY_COMPOSE_FILE" <<'COMPOSE'
services:
  windows:
    environment:
      RAM_SIZE: "16G"
      CPU_CORES: "6"
      DISK_SIZE: "128G"
      USERNAME: "legacyuser"
      PASSWORD: "fixture-password"
      TZ: "America/New_York"
    devices:
      - /dev/bus/usb:/dev/bus/usb:rshared
COMPOSE
  chmod 0600 "$LEGACY_COMPOSE_FILE"
  cp "$LEGACY_COMPOSE_FILE" "$scratch/original"
  printf 'existing destination contents must remain unchanged\n' > "$target/docker-compose.yml"
  cp "$target/docker-compose.yml" "$scratch/target-before"
  : > "$calls"
  rm -f "$scratch/credentials-argv" "$scratch/compose-argv"
  stage_failure=""
}

assert_transferred_settings() {
  [[ -f $COMPOSE_FILE ]] || fail "successful writer stage creates the fixture live compose"
  printf '%s\0' legacyuser fixture-password > "$scratch/expected"
  cmp -s "$scratch/expected" "$scratch/credentials-argv" || fail "migration transfers credential settings to its stub"
  printf '%s\0' 16G 6 128G legacyuser fixture-password America/New_York > "$scratch/expected"
  cmp -s "$scratch/expected" "$scratch/compose-argv" || fail "migration transfers all six expected settings to its writer stub"
}

assert_archive() {
  assert_transferred_settings
  [[ ! -e $LEGACY_COMPOSE_FILE && ! -L $LEGACY_COMPOSE_FILE ]] || fail "successful archival retires the legacy filename"
  [[ -f $backup && ! -L $backup ]] || fail "successful archival creates the expected regular backup file"
  cmp -s "$scratch/original" "$backup" || fail "archive preserves the exact original bytes including hand edits"
  [[ $(stat -c %a "$backup") == "600" ]] || fail "archive preserves the original private mode"
  grep -Fq "Your previous configuration is kept at $backup;" "$scratch/output" || fail "successful archival reports its exact filename"
}

# A directory destination must fail without moving inside it or clobbering its
# existing same-name file. Put these controls first so the original source
# fails before any successful migration can mask the regression.
reset_fixture
mkdir "$backup"
cp "$scratch/target-before" "$backup/docker-compose.yml"
status=0
migrate_legacy_compose > "$scratch/output" 2>&1 || status=$?
[[ -f $LEGACY_COMPOSE_FILE && ! -L $LEGACY_COMPOSE_FILE ]] || fail "directory backup keeps the original legacy filename"
cmp -s "$scratch/original" "$LEGACY_COMPOSE_FILE" || fail "directory backup keeps the original legacy bytes"
cmp -s "$scratch/target-before" "$backup/docker-compose.yml" || fail "directory backup does not clobber destination contents"
[[ -d $backup && ! -L $backup ]] || fail "directory backup remains intact"
(( status != 0 )) || fail "directory backup cannot report a successful archive"
if grep -Fq 'Your previous configuration is kept at' "$scratch/output"; then
  fail "directory backup cannot emit an archive success notice"
fi
assert_transferred_settings
pass "directory backup fails safely and preserves both the original and destination contents"

# Symlinks, including links to directories, are replaced as entries rather
# than followed. The original remains recoverable at the exact backup name.
for shape in absent file file-link dangling-link directory-link; do
  reset_fixture
  case $shape in
    file) printf 'older backup\n' > "$backup" ;;
    file-link) ln -s "$target/docker-compose.yml" "$backup" ;;
    dangling-link) ln -s "$target/missing" "$backup" ;;
    directory-link) ln -s "$target" "$backup" ;;
  esac
  migrate_legacy_compose > "$scratch/output" 2>&1 || fail "$shape backup permits legacy archival" "$(<"$scratch/output")"
  cmp -s "$scratch/target-before" "$target/docker-compose.yml" || fail "$shape backup leaves unrelated target bytes unchanged"
  [[ ! -e $target/missing ]] || fail "$shape backup does not write through a dangling link"
  assert_archive
  pass "$shape backup archives the complete legacy compose without following links"
done

# Preparatory failures must never archive or replace the recoverable original.
for stage in prepare credentials compose; do
  reset_fixture
  printf 'older backup\n' > "$backup"
  cp "$backup" "$scratch/backup-before"
  stage_failure="$stage"
  if migrate_legacy_compose > "$scratch/output" 2>&1; then
    fail "$stage failure must stop legacy migration"
  fi
  cmp -s "$scratch/original" "$LEGACY_COMPOSE_FILE" || fail "$stage failure preserves the original legacy compose"
  cmp -s "$scratch/backup-before" "$backup" || fail "$stage failure preserves the existing backup"
  [[ ! -e $COMPOSE_FILE ]] || fail "$stage failure cannot create a live compose"
  case $stage in
    prepare) [[ ! -e $scratch/credentials-argv && ! -e $scratch/compose-argv ]] || fail "preflight failure stops both later stages" ;;
    credentials) [[ ! -e $scratch/compose-argv ]] || fail "credential failure stops the writer stage" ;;
  esac
  if grep -Fq 'Your previous configuration is kept at' "$scratch/output"; then
    fail "$stage failure cannot report archive success"
  fi
  pass "$stage failure leaves the original and existing backup recoverable"
done
