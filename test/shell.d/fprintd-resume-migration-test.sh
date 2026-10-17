#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

original_migration=$(grep -rl 'Install the fingerprint resume hook on existing fingerprint setups' "$ROOT/migrations" | head -n 1 || true)
[[ -n $original_migration ]] || fail "fprintd resume hook migration exists"

grep -F 'source_root=${migration_path%/migrations/*}' "$original_migration" >/dev/null ||
  fail "migration derives its source tree from the running migration"
if grep -E 'OMARCHY_FPRINTD_|OMARCHY_LOCK_FINGERPRINT_PAM' "$original_migration" >/dev/null; then
  fail "migration does not accept inherited overrides for privileged paths"
fi
pass "migration binds privileged paths to its own source tree and system destinations"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# The migration installs to a system path via sudo; stub it so the test writes
# into a temp tree instead of /usr.
stub_bin="$TMPDIR/bin"
mkdir -p "$stub_bin"
cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
[[ ${REFUSE_SUDO:-0} != 1 ]] || exit 1
exec "$@"
STUB
chmod +x "$stub_bin/sudo"
reload_log="$TMPDIR/systemctl-calls"
dropin_dst="$TMPDIR/fprintd.service.d/10-stop-timeout.conf"
applied_dropin="$TMPDIR/applied-drop-in"
cat >"$stub_bin/systemctl" <<STUB
#!/bin/bash
printf '%s\n' "\$*" >>"$reload_log"
case "\$*" in
  'show fprintd.service --property=NeedDaemonReload --value')
    [[ \${FAIL_QUERY:-0} == 0 ]] || exit 1
    if cmp -s "$dropin_dst" "$applied_dropin"; then
      echo no
    else
      echo yes
    fi
    ;;
  daemon-reload)
    [[ \${FAIL_RELOAD:-0} == 0 ]] || exit 1
    cp "$dropin_dst" "$applied_dropin"
    ;;
  *) exit 99 ;;
esac
STUB
chmod +x "$stub_bin/systemctl"

dst="$TMPDIR/system-sleep/fprintd-resume"
lock_pam="$TMPDIR/omarchy-lock-fingerprint"
isolated_root="$TMPDIR/omarchy"
migration="$isolated_root/migrations/$(basename "$original_migration")"
src="$isolated_root/default/systemd/system-sleep/fprintd-resume"
dropin_src="$isolated_root/default/systemd/system/fprintd.service.d/10-stop-timeout.conf"
mkdir -p "$(dirname "$migration")" "$(dirname "$src")" "$(dirname "$dropin_src")"
cp "$ROOT/default/systemd/system-sleep/fprintd-resume" "$src"
cp "$ROOT/default/systemd/system/fprintd.service.d/10-stop-timeout.conf" "$dropin_src"

# Keep the production source-root resolution intact while redirecting only the
# fixed system destinations in this isolated test copy.
awk \
  -v hook_dst="$dst" \
  -v timeout_dst="$dropin_dst" \
  -v lock_pam="$lock_pam" '
  $0 == "hook_dst=/usr/lib/systemd/system-sleep/fprintd-resume" {
    print "hook_dst=\"" hook_dst "\""
    next
  }
  $0 == "stop_timeout_dst=/etc/systemd/system/fprintd.service.d/10-stop-timeout.conf" {
    print "stop_timeout_dst=\"" timeout_dst "\""
    next
  }
  $0 == "lock_pam=/etc/pam.d/omarchy-lock-fingerprint" {
    print "lock_pam=\"" lock_pam "\""
    next
  }
  { print }
' "$original_migration" >"$migration"

poison_root="$TMPDIR/poison-root"
poison_src="$poison_root/default/systemd/system-sleep/fprintd-resume"
poison_dropin_src="$poison_root/default/systemd/system/fprintd.service.d/10-stop-timeout.conf"
poison_dst="$TMPDIR/poison-system-sleep/fprintd-resume"
poison_dropin_dst="$TMPDIR/poison-fprintd.service.d/10-stop-timeout.conf"
poison_lock_pam="$TMPDIR/poison-omarchy-lock-fingerprint"
mkdir -p "$(dirname "$poison_src")" "$(dirname "$poison_dropin_src")"
printf '#!/bin/bash\nprintf "inherited migration payload\\n"\n' >"$poison_src"
printf '[Service]\nTimeoutStopSec=99s\n' >"$poison_dropin_src"
: >"$poison_lock_pam"

# omarchy-migrate runs each migration with `bash -euo pipefail`; match it.
run_migration() {
  PATH="$stub_bin:$PATH" \
    OMARCHY_PATH="$poison_root" \
    OMARCHY_FPRINTD_RESUME_SRC="$poison_src" \
    OMARCHY_FPRINTD_RESUME_DST="$poison_dst" \
    OMARCHY_FPRINTD_STOP_TIMEOUT_SRC="$poison_dropin_src" \
    OMARCHY_FPRINTD_STOP_TIMEOUT_DST="$poison_dropin_dst" \
    OMARCHY_LOCK_FINGERPRINT_PAM="$poison_lock_pam" \
    bash -euo pipefail "$migration" >/dev/null
}

# The migration exits clean when its source is missing, so pin both shipped
# source paths and prove inherited path overrides cannot redirect the install.
rm -rf "$TMPDIR/system-sleep" "$TMPDIR/fprintd.service.d"
: >"$lock_pam"
run_migration || fail "migration exits clean from its bound sources"
[[ -x $dst ]] || fail "migration finds the hook at its default source path" "dst: $(stat -c '%A' "$dst" 2>/dev/null || echo missing)"
cmp -s "$dst" "$src" || fail "migration installs the shipped hook from its bound source"
cmp -s "$dropin_dst" "$dropin_src" || fail "migration installs the shipped drop-in from its bound source"
[[ ! -e $poison_dst && ! -e $poison_dropin_dst ]] || fail "inherited variables redirect the migration's privileged destinations"
pass "migration ignores inherited path overrides and installs its shipped files"

# A machine with fingerprint configured but no hook yet gets it, executable,
# plus the stop-timeout drop-in, and systemd is told about the drop-in.
: >"$lock_pam"
rm -rf "$TMPDIR/system-sleep" "$TMPDIR/fprintd.service.d"
rm -f "$applied_dropin"
: >"$reload_log"
run_migration
[[ -x $dst ]] || fail "migration installs the hook, executable" "dst: $(stat -c '%A' "$dst" 2>/dev/null || echo missing)"
pass "migration installs the hook, executable"
[[ $(stat -c '%a' "$dropin_dst" 2>/dev/null) == "644" ]] || fail "migration installs the stop-timeout drop-in" "dst: $(stat -c '%A' "$dropin_dst" 2>/dev/null || echo missing)"
grep -qx "daemon-reload" "$reload_log" || fail "migration reloads systemd after installing the drop-in" "calls: $(<"$reload_log")"
pass "migration installs the stop-timeout drop-in and reloads systemd"

rm -f "$dropin_dst"
rm -f "$applied_dropin"
: >"$reload_log"
if FAIL_RELOAD=1 run_migration; then
  fail "migration remains pending when daemon-reload fails"
fi
[[ -f $dropin_dst ]] || fail "reload failure occurs after the drop-in is installed"
run_migration
[[ $(grep -c '^daemon-reload$' "$reload_log") == 2 ]] || fail "migration retries reload even when the drop-in already exists"
pass "migration retries a failed reload after installing the drop-in"

# Existing files may precede an interrupted reload; preserve them and reload.
printf 'sentinel\n' >>"$dst"
printf '# sentinel\n' >>"$dropin_dst"
: >"$reload_log"
run_migration
grep -q sentinel "$dst" || fail "migration leaves an existing hook alone"
grep -q sentinel "$dropin_dst" || fail "migration leaves an existing drop-in alone"
grep -qx "daemon-reload" "$reload_log" || fail "migration reloads existing configuration before completing" "calls: $(<"$reload_log")"
pass "migration leaves existing files alone"

: >"$reload_log"
REFUSE_SUDO=1 run_migration || fail "later users finish an applied repair without sudo"
if grep -qx "daemon-reload" "$reload_log"; then
  fail "later users finish an applied repair without sudo"
fi
pass "later users finish an applied repair without sudo"

if FAIL_QUERY=1 run_migration; then
  fail "migration remains pending when reload state cannot be queried"
fi
pass "migration propagates reload-state query failure"

# An unnumbered drop-in may belong to the administrator; never replace it.
legacy="$TMPDIR/fprintd.service.d/stop-timeout.conf"
rm -f "$dropin_dst"; printf '[Service]\nTimeoutStopSec=15s\n' >"$legacy"
cp "$legacy" "$TMPDIR/saved-admin-timeout"
: >"$reload_log"
run_migration
cmp -s "$legacy" "$TMPDIR/saved-admin-timeout" || fail "migration preserves the administrator's unnumbered drop-in"
[[ -f $dropin_dst ]] || fail "migration installs the numbered drop-in alongside the administrator's file"
grep -qx "daemon-reload" "$reload_log" || fail "migration reloads systemd after installing the numbered drop-in"
pass "migration preserves the administrator's unnumbered drop-in"

# The drop-in is installed on its own where only the hook is already present.
rm -rf "$TMPDIR/fprintd.service.d"
run_migration
[[ -f $dropin_dst ]] || fail "migration adds the drop-in beside an existing hook"
pass "migration adds the drop-in beside an existing hook"

# No fingerprint configured -> nothing to fix, so nothing is installed.
rm -f "$lock_pam"
rm -rf "$TMPDIR/system-sleep" "$TMPDIR/fprintd.service.d"
run_migration
[[ ! -e $dst && ! -e $dropin_dst ]] || fail "migration skips machines without fingerprint configured"
pass "migration skips machines without fingerprint configured"
