#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

dropin="$ROOT/etc/systemd/system/linux-modules-cleanup.service.d/10-omarchy.conf"
[[ -f $dropin ]] || fail "linux-modules-cleanup drop-in exists"

for setting in \
  '[Service]' \
  'ProtectSystem=strict' \
  'ReadWritePaths=/usr/lib/modules' \
  'ProtectHome=yes' \
  'PrivateNetwork=yes' \
  'PrivateTmp=yes' \
  'ProtectClock=yes' \
  'ProtectKernelLogs=yes' \
  'ProtectKernelTunables=yes' \
  'ProtectControlGroups=yes' \
  'ProtectHostname=yes' \
  'NoNewPrivileges=yes' \
  'CapabilityBoundingSet=~CAP_SYS_ADMIN CAP_SYS_MODULE' \
  'RestrictNamespaces=yes' \
  'RestrictSUIDSGID=yes' \
  'RestrictRealtime=yes' \
  'LockPersonality=yes' \
  'MemoryDenyWriteExecute=yes' \
  'SystemCallArchitectures=native'; do
  grep -qxF "$setting" "$dropin" || fail "cleanup profile declares $setting"
done

[[ $(grep -c '^CapabilityBoundingSet=' "$dropin") == 1 ]] ||
  fail "later capability assignments cannot restore mount or module privileges"
[[ $(grep -c '^ReadWritePaths=' "$dropin") == 1 ]] ||
  fail "cleanup has one explicit persistent write allowance"
! grep -q '^ProtectKernelModules=' "$dropin" ||
  fail "module loading is restricted without hiding the module archive"
pass "cleanup declares filesystem and capability restrictions (static, not runtime verification)"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

(
  migration="$ROOT/migrations/1788839599.sh"
  [[ -f $migration ]] || fail "existing managers reload the new cleanup profile"
  export call_log="$test_tmp/systemctl.log"

  systemctl() {
    printf '%s\n' "$*" >> "$call_log"
    case "$1" in
      show)
        if [[ ${SHOW_FAIL:-0} == "1" ]]; then return 1; fi
        printf '%s\n' "${RELOAD_NEEDED:-yes}"
        ;;
      daemon-reload) return "${RELOAD_FAIL:-0}" ;;
      *) return 99 ;;
    esac
  }

  sudo() {
    [[ $* == "systemctl daemon-reload" ]] || return 99
    "$@"
  }

  export -f systemctl sudo
  bash -euo pipefail "$migration" >/dev/null
  [[ $(<"$call_log") == $'show --property=NeedDaemonReload --value linux-modules-cleanup.service\ndaemon-reload' ]] ||
    fail "migration reloads only manager configuration, without starting cleanup"
  pass "migration reloads a cached cleanup unit"

  : > "$call_log"
  RELOAD_NEEDED=no bash -euo pipefail "$migration" >/dev/null
  [[ $(<"$call_log") == 'show --property=NeedDaemonReload --value linux-modules-cleanup.service' ]] ||
    fail "migration no-ops when the manager already has current configuration"
  pass "migration is idempotent across users and reboots"

  if RELOAD_FAIL=1 bash -euo pipefail "$migration" >/dev/null 2>&1; then
    fail "failed daemon reload leaves the migration pending"
  fi
  if SHOW_FAIL=1 bash -euo pipefail "$migration" >/dev/null 2>&1; then
    fail "failed manager query leaves the migration pending"
  fi
  if RELOAD_NEEDED=unknown bash -euo pipefail "$migration" >/dev/null 2>&1; then
    fail "unrecognized manager state leaves the migration pending"
  fi
  pass "manager query and reload failures are retryable"
)

require_command python3
python3 "$ROOT/test/shell.d/fixtures/linux-modules-cleanup.py" "$dropin"
