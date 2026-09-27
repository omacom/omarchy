#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command unshare
t=$(mktemp -d); trap 'rm -rf -- "$t"' EXIT

unshare --user --map-root-user --mount /usr/bin/bash -s "$ROOT" "$t" <<'NAMESPACE' >"$t/namespace.out" 2>&1 || { cat "$t/namespace.out" >&2; fail "the machine phase namespace suite failed"; }
set -euo pipefail
repo=$1 t=$2; b="$t/bin"; mapped="$t/omarchy"; mkdir -p "$b" "$mapped/bin" "$t/run"; chmod 0755 "$t/run"
cat >"$b/systemctl" <<'SH'
#!/bin/bash
echo "systemctl $*" >>"$EVENTS"
case $1 in
is-active) [[ ${ACTIVE_QUERY_ERROR:-0} != 1 ]] || exit 2; [[ ${UNIT_MISSING:-0} != 1 ]] || { echo inactive; exit 4; }; [[ -e $STATE/active ]] && { echo active; exit 0; } || { echo inactive; exit 3; };;
is-enabled) [[ ${ENABLED_QUERY_ERROR:-0} != 1 ]] || exit 2; [[ ${UNIT_MISSING:-0} != 1 ]] || { echo not-found; exit 4; }; [[ ! -e $STATE/masked ]] || { echo masked; exit 1; }; [[ ! -e $STATE/enabled || ! -e $STATE/masked-runtime ]] || { echo masked-runtime; exit 1; }; [[ -e $STATE/enabled ]] && { echo enabled; exit 0; } || { echo disabled; exit 1; };;
reload) if [[ ${SLOW_RELOAD:-0} == 1 ]]; then mkdir "$STATE/held" 2>/dev/null || touch "$STATE/overlap"; sleep .15; rmdir "$STATE/held" 2>/dev/null || true; fi; [[ ${RELOAD_FAIL:-0} != 1 ]];;
disable) [[ ${DISABLE_FAIL:-0} != 1 ]] || exit 1; [[ ${2:-} != --now ]] || rm -f "$STATE/active"; [[ ${DISABLE_NOOP:-0} != 1 ]] || exit 0; if [[ -e $STATE/masked-runtime ]]; then echo "Unit sshd.service is masked, ignoring." >&2; else rm -f "$STATE/enabled"; fi;;
unmask) exit 2;;
mask) [[ ${2:-} != --runtime ]] || exit 2; [[ ${MASK_FAIL:-0} != 1 ]] || exit 1; touch "$STATE/masked";;
start) [[ ${START_FAIL:-0} != 1 ]] || exit 1; touch "$STATE/active";;
enable) [[ ${ENABLE_FAIL:-0} != 1 ]] || exit 1; touch "$STATE/enabled";;
stop) [[ ${STOP_SIGNAL:-0} != 1 ]] || kill -TERM "$PPID"; [[ ${STOP_FAIL:-0} != 1 ]] || exit 1; rm -f "$STATE/active";; esac
SH
cat >"$b/ufw" <<'SH'
#!/bin/bash
echo "ufw $*" >>"$EVENTS"
case $1 in
show) [[ ${UFW_QUERY_ERROR:-0} != 1 ]] || exit 1; [[ ! -e $STATE/rule ]] || echo "ufw limit 22/tcp comment 'omarchy-sshd'";;
limit) [[ ${LIMIT_FAIL:-0} != 1 ]] || exit 1; touch "$STATE/rule";;
--force) rm -f "$STATE/rule";;
reload) [[ ${UFW_RELOAD_SIGNAL:-0} != 1 || ! -e $STATE/rule ]] || kill -TERM "$PPID";; esac
SH
cat >"$b/getent" <<'SH'
#!/bin/bash
[[ $1 == passwd ]] || exit 2
/usr/bin/awk -F: -v uid="$2" '$3 == uid { print; found=1; exit } END { exit !found }' "$TEST_ROOT/etc/passwd"
SH
# The real setpriv cannot switch to an unmapped UID in this namespace; the
# stand-in records the switch and runs the command.
cat >"$b/setpriv" <<'SH'
#!/bin/bash
echo "setpriv $1 $2" >>"$EVENTS"
while [[ $1 != -- ]]; do shift; done; shift
exec "$@"
SH
cat >"$b/omarchy-pkg-add" <<'SH'
#!/bin/bash
echo "package $*" >>"$EVENTS"
[[ ${PACKAGE_FAIL:-0} != 1 ]]
SH
cat >"$b/omarchy-cmd-missing" <<'SH'
#!/bin/bash
[[ ${UFW_MISSING:-0} == 1 ]]
SH
# AWK_FAIL makes the Include parser print one pattern and then fail, as a
# partial read would.
cat >"$b/awk" <<'SH'
#!/bin/bash
if [[ ${AWK_FAIL:-0} == 1 && $* == *'tolower(keyword) != "include"'* ]]; then echo /etc/ssh/sshd_config.d/*.conf; exit 42; fi
exec /usr/bin/awk "$@"
SH
# FIND_FAIL makes listing an Include directory report one entry and then
# fail, as an interrupted enumeration would.
cat >"$b/find" <<'SH'
#!/bin/bash
if [[ ${FIND_FAIL:-0} == 1 && ${*: -1} == -print0 ]]; then printf '%s\0' "$1/20-trusted.conf"; exit 1; fi
exec /usr/bin/find "$@"
SH
# MARKER_LOOKUP_FAIL makes looking up the completion marker fail with an I/O
# error rather than report it present or absent.
cat >"$b/stat" <<'SH'
#!/bin/bash
if [[ ${MARKER_LOOKUP_FAIL:-0} == 1 && ${1:-} == -c && ${2:-} == %F && ${*: -1} == */1788163637 ]]; then
  echo "stat: cannot statx '${*: -1}': Input/output error" >&2; exit 1
fi
exec /usr/bin/stat "$@"
SH
# MARKER_SIGNAL delivers TERM the moment the completion marker is renamed
# into place, after the commit.
cat >"$b/mv" <<'SH'
#!/bin/bash
/usr/bin/mv "$@" || exit
[[ ${MARKER_SIGNAL:-0} != 1 || ${*: -1} != */1788163637 ]] || kill -TERM "$PPID"
SH
cat >"$b/passwd" <<'SH'
#!/bin/bash
[[ $1 == -S && $2 == -- ]] || exit 2
[[ ${PASSWD_QUERY_ERROR:-0} != 1 ]] || exit 2
status=P; [[ ${LOCKED_USER:-} != "$3" ]] || status=L
printf '%s %s 2026-01-01 -1 -1 -1 -1\n' "$3" "$status"
SH
cat >"$b/id" <<'SH'
#!/bin/bash
[[ $1 == -Gn && $2 == -- ]] || exit 2
[[ ${GROUP_QUERY_ERROR:-0} != 1 ]] || exit 2
case $3 in keyed) echo 'keyed sshers';; later) echo 'later users';; *\$) echo "$3 sshers";; *) exit 1;; esac
SH
cat >"$b/ssh-keygen" <<'SH'
#!/bin/bash
[[ ${1:-} != -A ]] || { echo hostkeys >>"$EVENTS"; exit "${HOSTKEY_FAIL:-0}"; }
exec /usr/bin/ssh-keygen "$@"
SH
cat >"$b/sshd" <<'SH'
#!/bin/bash
[[ ${1:-} != -t ]] || exit "${T_FAIL:-0}"
user=; for arg in "$@"; do [[ $arg != user=* ]] || { user=${arg#user=}; user=${user%%,*}; }; done
password=no; [[ -z ${MATCH_BAD_USER:-} || $user != "$MATCH_BAD_USER" ]] || password=yes
echo "PasswordAuthentication $password"; echo 'KbdInteractiveAuthentication no'; echo 'AuthenticationMethods publickey'; echo 'PubkeyAuthentication yes'; echo 'AuthorizedKeysFile .ssh/authorized_keys'
echo "PubkeyAcceptedAlgorithms ${ACCEPTED_ALGORITHMS:-ssh-ed25519,ecdsa-sha2-nistp256,rsa-sha2-512,rsa-sha2-256}"; echo "RequiredRSASize ${REQUIRED_RSA_SIZE:-1024}"
[[ -z ${REVOKED_KEYS:-} ]] || echo "RevokedKeys $REVOKED_KEYS"
echo "RefuseConnection ${REFUSE_CONNECTION:-no}"; echo "ForceCommand ${FORCE_COMMAND:-none}"
[[ -z ${ALLOW_USERS:-} ]] || echo "AllowUsers $ALLOW_USERS"
[[ -z ${DENY_USERS:-} ]] || echo "DenyUsers $DENY_USERS"
[[ -z ${ALLOW_GROUPS:-} ]] || echo "AllowGroups $ALLOW_GROUPS"
[[ -z ${DENY_GROUPS:-} ]] || echo "DenyGroups $DENY_GROUPS"
SH
chmod 0755 "$b"/*; cp "$repo/bin/omarchy-security-functions" "$repo/bin/omarchy-sshd-functions" "$mapped/bin/"
sed -e 's#^root_prefix=""$#root_prefix=$TEST_ROOT#' \
 -e "s#machine_lock=/run/omarchy-sshd-key-only-migration.lock#machine_lock=$t/run/lock#" \
 -e "s#-- /run#-- $t/run#g" -e "s#-L /run#-L $t/run#g" -e "s#== /run#== $t/run#g" \
 -e "s#/usr/bin/systemctl#$b/systemctl#g" -e "s#/usr/bin/ssh-keygen#$b/ssh-keygen#g" -e "s#/usr/bin/sshd#$b/sshd#g" \
 -e "s#/usr/bin/passwd#$b/passwd#g" -e "s#/usr/bin/id#$b/id#g" -e "s#/usr/bin/getent#$b/getent#g" -e "s#/usr/bin/setpriv#$b/setpriv#g" \
 -e "s#/usr/bin/omarchy-pkg-add#$b/omarchy-pkg-add#g" -e "s#/usr/bin/omarchy-cmd-missing#$b/omarchy-cmd-missing#g" -e "s#/usr/bin/ufw#$b/ufw#g" -e "s#/usr/bin/mv#$b/mv#g" -e "s#/usr/bin/stat#$b/stat#g" -e "s#/usr/bin/awk#$b/awk#g" -e "s#/usr/bin/find#$b/find#g" \
 "$repo/bin/omarchy-migrate-sshd-key-only" >"$mapped/bin/omarchy-migrate-sshd-key-only"; chmod 0755 "$mapped/bin/"*
grep -qx 'root_prefix=$TEST_ROOT' "$mapped/bin/omarchy-migrate-sshd-key-only" || { echo "test could not redirect the machine paths" >&2; exit 1; }
/usr/bin/ssh-keygen -q -t ed25519 -N '' -f "$t/key"; key=$(<"$t/key.pub")
prepare() { local d="$t/$1"; mkdir -p "$d/root/etc/ssh/sshd_config.d" "$d/root/home/keyed/.ssh" "$d/root/home/later" "$d/state"; chmod 700 "$d/root/home/"{keyed,keyed/.ssh,later}; printf '%s\n' "$key" >"$d/root/home/keyed/.ssh/authorized_keys"; chmod 600 "$d/root/home/keyed/.ssh/authorized_keys"; cat >"$d/root/etc/passwd" <<EOF
root:x:0:0:root:/root:/usr/bin/nologin
keyed:x:1000:1000:Keyed:$d/root/home/keyed:/usr/bin/bash
later:x:1001:1001:Later:$d/root/home/later:/usr/bin/bash
daemon:x:2:2:Daemon:/sbin:/usr/bin/nologin
EOF
 echo 'UID_MIN 1000' >"$d/root/etc/login.defs"; echo 'Include /etc/ssh/sshd_config.d/*.conf' >"$d/root/etc/ssh/sshd_config"; printf 'PasswordAuthentication no\nKbdInteractiveAuthentication no\n' >"$d/root/etc/ssh/sshd_config.d/10-omarchy-hardening.conf"; : >"$d/events"; }
run() { DISABLE_FAIL="${DISABLE_FAIL:-0}" DISABLE_NOOP="${DISABLE_NOOP:-0}" MASK_FAIL="${MASK_FAIL:-0}" REFUSE_CONNECTION="${REFUSE_CONNECTION:-}" FORCE_COMMAND="${FORCE_COMMAND:-}" ACCEPTED_ALGORITHMS="${ACCEPTED_ALGORITHMS:-}" REQUIRED_RSA_SIZE="${REQUIRED_RSA_SIZE:-}" REVOKED_KEYS="${REVOKED_KEYS:-}" UNIT_MISSING="${UNIT_MISSING:-0}" TEST_ROOT="$t/$1/root" STATE="$t/$1/state" EVENTS="$t/$1/events" MATCH_BAD_USER="${MATCH_BAD_USER:-}" ALLOW_USERS="${ALLOW_USERS:-}" DENY_USERS="${DENY_USERS:-}" ALLOW_GROUPS="${ALLOW_GROUPS:-}" DENY_GROUPS="${DENY_GROUPS:-}" LOCKED_USER="${LOCKED_USER:-}" PASSWD_QUERY_ERROR="${PASSWD_QUERY_ERROR:-0}" GROUP_QUERY_ERROR="${GROUP_QUERY_ERROR:-0}" ACTIVE_QUERY_ERROR="${ACTIVE_QUERY_ERROR:-0}" ENABLED_QUERY_ERROR="${ENABLED_QUERY_ERROR:-0}" SLOW_RELOAD="${SLOW_RELOAD:-0}" RELOAD_FAIL="${RELOAD_FAIL:-0}" HOSTKEY_FAIL="${HOSTKEY_FAIL:-0}" T_FAIL="${T_FAIL:-0}" "$mapped/bin/omarchy-migrate-sshd-key-only"; }
prepare shared; touch "$t/shared/state/"{active,enabled}; run shared; run shared; [[ -e $t/shared/state/active ]]; ! grep -q 'systemctl disable' "$t/shared/events"
[[ -f $t/shared/root/var/lib/omarchy/migrations/1788163637 ]] || { echo "a validated conversion did not record completion" >&2; exit 1; }
prepare no-key; rm "$t/no-key/root/home/keyed/.ssh/authorized_keys"; touch "$t/no-key/state/"{active,enabled}; run no-key; [[ ! -e $t/no-key/state/active ]]
[[ ! -e $t/no-key/root/var/lib/omarchy/migrations/1788163637 ]] || { echo "a disabled machine recorded a completed conversion" >&2; exit 1; }
prepare matched; touch "$t/matched/state/"{active,enabled}; MATCH_BAD_USER=later run matched; [[ ! -e $t/matched/state/active ]]
for rule in allow-user deny-user allow-group deny-group locked; do
  prepare "$rule"; touch "$t/$rule/state/"{active,enabled}
  case $rule in allow-user) ALLOW_USERS=later;; deny-user) DENY_USERS=keyed;; allow-group) ALLOW_GROUPS=users;; deny-group) DENY_GROUPS=sshers;; locked) LOCKED_USER=keyed;; esac
  run "$rule"; [[ ! -e $t/$rule/state/active ]] || exit 1
  unset ALLOW_USERS DENY_USERS ALLOW_GROUPS DENY_GROUPS LOCKED_USER
done
prepare admitted; touch "$t/admitted/state/"{active,enabled}; ALLOW_USERS=keyed ALLOW_GROUPS=sshers DENY_USERS=later DENY_GROUPS=users run admitted; [[ -e $t/admitted/state/active ]]
for error in passwd groups; do prepare "admission-error-$error"; touch "$t/admission-error-$error/state/"{active,enabled}; if [[ $error == passwd ]]; then PASSWD_QUERY_ERROR=1; else GROUP_QUERY_ERROR=1; fi; run "admission-error-$error"; [[ ! -e $t/admission-error-$error/state/active ]]; unset PASSWD_QUERY_ERROR GROUP_QUERY_ERROR; done
prepare query-error; touch "$t/query-error/state/"{active,enabled}; ACTIVE_QUERY_ERROR=1; if run query-error; then exit 1; fi; unset ACTIVE_QUERY_ERROR; [[ -e $t/query-error/state/active && -e $t/query-error/state/enabled && ! -e $t/query-error/root/etc/ssh/sshd_config.d/00-omarchy-key-only.conf && -e $t/query-error/root/etc/ssh/sshd_config.d/10-omarchy-hardening.conf ]]
prepare unsafe-query-error; rm "$t/unsafe-query-error/root/home/keyed/.ssh/authorized_keys"; touch "$t/unsafe-query-error/state/"{active,enabled}; ENABLED_QUERY_ERROR=1; if run unsafe-query-error; then exit 1; fi; unset ENABLED_QUERY_ERROR; [[ -e $t/unsafe-query-error/state/active && -e $t/unsafe-query-error/state/enabled ]]
prepare symlink-key; mv "$t/symlink-key/root/home/keyed/.ssh/authorized_keys" "$t/symlink-key/root/home/key"; ln -s ../key "$t/symlink-key/root/home/keyed/.ssh/authorized_keys"; touch "$t/symlink-key/state/"{active,enabled}; run symlink-key; [[ ! -e $t/symlink-key/state/active ]]
# With no Omarchy file at all, an exposed daemon, one old setup enabled
# before any key, is made key-only when an account has a usable key and
# disabled when none has; one that is neither enabled nor running is left
# alone, and an unanswered service query leaves the migration pending.
prepare bare-keyed; rm -f "$t/bare-keyed/root/etc/ssh/sshd_config.d/10-omarchy-hardening.conf"; touch "$t/bare-keyed/state/"{active,enabled}; run bare-keyed
grep -qxF 'AuthenticationMethods publickey' "$t/bare-keyed/root/etc/ssh/sshd_config.d/00-omarchy-key-only.conf" && [[ -e $t/bare-keyed/state/active && -f $t/bare-keyed/root/var/lib/omarchy/migrations/1788163637 ]] ||
  { echo "an exposed keyed daemon was not made key-only" >&2; exit 1; }
prepare bare-keyless; rm -f "$t/bare-keyless/root/etc/ssh/sshd_config.d/10-omarchy-hardening.conf" "$t/bare-keyless/root/home/keyed/.ssh/authorized_keys"; touch "$t/bare-keyless/state/enabled"; run bare-keyless
[[ ! -e $t/bare-keyless/state/enabled && ! -e $t/bare-keyless/root/etc/ssh/sshd_config.d/00-omarchy-key-only.conf ]] || { echo "an exposed keyless daemon was not disabled" >&2; exit 1; }
# A runtime mask over a persistent enablement is not idle: at the next boot
# the mask is gone. systemctl disable would ignore the masked unit, and
# lifting the mask would expose it, so a keyless one is masked persistently
# on top, never unmasked, and the result is checked.
masked_bare() { prepare "$1"; rm -f "$t/$1/root/etc/ssh/sshd_config.d/10-omarchy-hardening.conf" "$t/$1/root/home/keyed/.ssh/authorized_keys"; touch "$t/$1/state/"{enabled,masked-runtime}; }
masked_bare bare-masked; run bare-masked
[[ -e $t/bare-masked/state/masked && -e $t/bare-masked/state/masked-runtime ]] && ! grep -q '^systemctl unmask' "$t/bare-masked/events" || { echo "a runtime-masked, persistently enabled daemon was not masked persistently" >&2; exit 1; }
masked_bare bare-mask-fail; if MASK_FAIL=1 run bare-mask-fail; then echo "a failed persistent mask completed the migration" >&2; exit 1; fi
[[ ! -e $t/bare-mask-fail/state/masked && -e $t/bare-mask-fail/state/masked-runtime ]] || { echo "a failed persistent mask changed the unit" >&2; exit 1; }
# A disable systemctl reports as done but that leaves the unit able to start
# keeps the migration pending.
prepare bare-noop; rm -f "$t/bare-noop/root/etc/ssh/sshd_config.d/10-omarchy-hardening.conf" "$t/bare-noop/root/home/keyed/.ssh/authorized_keys"; touch "$t/bare-noop/state/enabled"
if DISABLE_NOOP=1 run bare-noop; then echo "a disable that left sshd enabled completed the migration" >&2; exit 1; fi
prepare bare-idle; rm -f "$t/bare-idle/root/etc/ssh/sshd_config.d/10-omarchy-hardening.conf"; run bare-idle
[[ ! -e $t/bare-idle/root/etc/ssh/sshd_config.d/00-omarchy-key-only.conf ]] && ! grep -qv '^systemctl is-' "$t/bare-idle/events" || { echo "an unexposed daemon was changed" >&2; exit 1; }
prepare bare-query; rm -f "$t/bare-query/root/etc/ssh/sshd_config.d/10-omarchy-hardening.conf"; touch "$t/bare-query/state/"{active,enabled}
if ACTIVE_QUERY_ERROR=1 run bare-query; then echo "an unknown service state completed the migration" >&2; exit 1; fi
[[ -e $t/bare-query/state/active && ! -e $t/bare-query/root/etc/ssh/sshd_config.d/00-omarchy-key-only.conf ]] || { echo "an unknown service state changed the machine" >&2; exit 1; }
# A key-only path that is not a regular file proves nothing; the migration
# disables an exposed daemon rather than trust it.
prepare keyonly-symlink; rm -f "$t/keyonly-symlink/root/etc/ssh/sshd_config.d/10-omarchy-hardening.conf"; ln -s /dev/null "$t/keyonly-symlink/root/etc/ssh/sshd_config.d/00-omarchy-key-only.conf"; touch "$t/keyonly-symlink/state/"{active,enabled}; run keyonly-symlink; [[ ! -e $t/keyonly-symlink/state/active ]] || { echo "a symlinked key-only file left sshd running" >&2; exit 1; }
# A configuration anyone but root can write proves nothing about the policy
# the daemon will read, so the migration disables rather than trusts it.
prepare quoted-include; echo 'Include "/etc/ssh/untrusted file.conf"' >>"$t/quoted-include/root/etc/ssh/sshd_config"; echo 'Port 22' >"$t/quoted-include/root/etc/ssh/untrusted file.conf"; chmod 0666 "$t/quoted-include/root/etc/ssh/untrusted file.conf"; touch "$t/quoted-include/state/"{active,enabled}; run quoted-include; [[ ! -e $t/quoted-include/state/active ]] || { echo "a quoted include of a writable file was trusted" >&2; exit 1; }
prepare writable-config; chmod 0666 "$t/writable-config/root/etc/ssh/sshd_config"; touch "$t/writable-config/state/"{active,enabled}; run writable-config; [[ ! -e $t/writable-config/state/active ]] || { echo "a writable sshd_config was trusted" >&2; exit 1; }
# Drop-ins are read in byte order: "0-admin.conf" comes before Omarchy's file
# even in a locale whose collation would ignore the dash.
prepare dropin-first; echo 'PasswordAuthentication yes' >"$t/dropin-first/root/etc/ssh/sshd_config.d/0-admin.conf"; touch "$t/dropin-first/state/"{active,enabled}; LC_ALL=en_US.UTF-8 run dropin-first; [[ ! -e $t/dropin-first/state/active ]] || { echo "a drop-in read before Omarchy's was not seen" >&2; exit 1; }
prepare stopped; touch "$t/stopped/state/enabled"; run stopped; [[ -e $t/stopped/state/enabled ]]; ! grep -q 'systemctl reload' "$t/stopped/events"
prepare reload-fail; touch "$t/reload-fail/state/"{active,enabled}; RELOAD_FAIL=1 run reload-fail; [[ ! -e $t/reload-fail/state/active && ! -e $t/reload-fail/state/enabled && -e $t/reload-fail/root/etc/ssh/sshd_config.d/00-omarchy-key-only.conf ]]
prepare syntax-fail; touch "$t/syntax-fail/state/"{active,enabled}; T_FAIL=1 run syntax-fail; [[ ! -e $t/syntax-fail/state/active && ! -e $t/syntax-fail/root/etc/ssh/sshd_config.d/00-omarchy-key-only.conf ]]
# Two machine phases never overlap: a second one while the lock is held fails
# without changing anything, and a retry afterwards completes.
prepare concurrent; touch "$t/concurrent/state/"{active,enabled}; SLOW_RELOAD=1 run concurrent & a=$!; SLOW_RELOAD=1 run concurrent & c=$!; wait "$a" || true; wait "$c" || true; [[ ! -e $t/concurrent/state/overlap ]]
run concurrent; [[ -f $t/concurrent/root/var/lib/omarchy/migrations/1788163637 ]]
prepare admin; echo 'PasswordAuthentication yes' >"$t/admin/root/etc/ssh/sshd_config.d/10-omarchy-hardening.conf"; touch "$t/admin/state/"{active,enabled}; before=$(sha256sum "$t/admin/root/etc/ssh/sshd_config.d/10-omarchy-hardening.conf"); run admin; after=$(sha256sum "$t/admin/root/etc/ssh/sshd_config.d/10-omarchy-hardening.conf"); [[ $before == "$after" && -e $t/admin/state/active && ! -s $t/admin/events ]]
# ssh-keygen -lf accepts these, but none proves a usable administrative login.
n=0
for opt in 'cert-authority' 'command="false"' 'from="!*,*"' 'expiry-time="20200101"' 'restrict' 'no-pty' 'permitopen="host:22"' ',' 'no-agent-forwarding,bogus'; do
  n=$((n+1)); prepare "restricted-$n"; printf '%s %s\n' "$opt" "$key" >"$t/restricted-$n/root/home/keyed/.ssh/authorized_keys"; touch "$t/restricted-$n/state/"{active,enabled}
  run "restricted-$n"; [[ ! -e $t/restricted-$n/state/active ]] || { echo "restricted key counted as usable: $opt" >&2; exit 1; }
done
prepare flags; printf 'no-agent-forwarding,No-Port-Forwarding %s\n' "$key" >"$t/flags/root/home/keyed/.ssh/authorized_keys"; touch "$t/flags/state/"{active,enabled}; run flags; [[ -e $t/flags/state/active ]]
# A key that parses but that the account's effective policy refuses proves no
# login: its algorithm is excluded, an RSA key is under RequiredRSASize, or the
# key is listed in RevokedKeys.
prepare algorithm; touch "$t/algorithm/state/"{active,enabled}; ACCEPTED_ALGORITHMS=ecdsa-sha2-nistp256,rsa-sha2-512 run algorithm; [[ ! -e $t/algorithm/state/active ]]
/usr/bin/ssh-keygen -q -t rsa -b 2048 -N '' -f "$t/rsa"
prepare rsa-size; cp "$t/rsa.pub" "$t/rsa-size/root/home/keyed/.ssh/authorized_keys"; touch "$t/rsa-size/state/"{active,enabled}; REQUIRED_RSA_SIZE=3072 run rsa-size; [[ ! -e $t/rsa-size/state/active ]]
prepare rsa-ok; cp "$t/rsa.pub" "$t/rsa-ok/root/home/keyed/.ssh/authorized_keys"; touch "$t/rsa-ok/state/"{active,enabled}; run rsa-ok; [[ -e $t/rsa-ok/state/active ]]
/usr/bin/ssh-keygen -q -k -f "$t/krl" "$t/key.pub"
prepare revoked; touch "$t/revoked/state/"{active,enabled}; REVOKED_KEYS="$t/krl" run revoked; [[ ! -e $t/revoked/state/active ]]
# RevokedKeys may also be a plain list of public keys, which ssh-keygen -Q
# cannot read; it must still revoke the listed key and only that one.
printf '# revoked\n%s\n' "$key" >"$t/revoked.txt"; cp "$t/rsa.pub" "$t/other-revoked.txt"
prepare revoked-text; touch "$t/revoked-text/state/"{active,enabled}; REVOKED_KEYS="$t/revoked.txt" run revoked-text; [[ ! -e $t/revoked-text/state/active ]]
prepare unrevoked-text; touch "$t/unrevoked-text/state/"{active,enabled}; REVOKED_KEYS="$t/other-revoked.txt" run unrevoked-text; [[ -e $t/unrevoked-text/state/active ]]
# sshd refuses every key when a text list has a line that is not a bare key,
# so such a list proves no login either.
printf 'this-is-not-a-key\n' >"$t/malformed-revoked.txt"; printf 'restrict %s\n' "$(<"$t/rsa.pub")" >"$t/options-revoked.txt"
printf 'ssh-ed25519 AAAA\n' >"$t/baddata-revoked.txt"
# CRLF endings are valid for sshd; the listed key is still revoked.
read -r key_type key_data _ <<<"$key"; printf '%s %s\r\n' "$key_type" "$key_data" >"$t/crlf-listed.txt"
prepare crlf-revoked; touch "$t/crlf-revoked/state/"{active,enabled}; REVOKED_KEYS="$t/crlf-listed.txt" run crlf-revoked
[[ ! -e $t/crlf-revoked/state/active ]] || { echo "a CRLF revocation list did not revoke its key" >&2; exit 1; }
for list in malformed options baddata; do
  prepare "$list-revoked"; touch "$t/$list-revoked/state/"{active,enabled}; REVOKED_KEYS="$t/$list-revoked.txt" run "$list-revoked"
  [[ ! -e $t/$list-revoked/state/active ]] || { echo "a $list revocation list was treated as revoking nothing" >&2; exit 1; }
done
# A certificate listed for some other key is a valid entry and revokes only it.
/usr/bin/ssh-keygen -q -t ed25519 -N '' -f "$t/ca"; /usr/bin/ssh-keygen -q -s "$t/ca" -I other -n other "$t/rsa.pub"
cp "$t/rsa-cert.pub" "$t/cert-revoked.txt"
prepare cert-revoked; touch "$t/cert-revoked/state/"{active,enabled}; REVOKED_KEYS="$t/cert-revoked.txt" run cert-revoked
[[ -e $t/cert-revoked/state/active ]] || { echo "a valid certificate entry was treated as a malformed revocation list" >&2; exit 1; }
# An account sshd refuses outright, or forces into a command, proves no login.
prepare refused; touch "$t/refused/state/"{active,enabled}; REFUSE_CONNECTION=yes run refused; [[ ! -e $t/refused/state/active ]]
prepare forced; touch "$t/forced/state/"{active,enabled}; FORCE_COMMAND=/usr/bin/false run forced; [[ ! -e $t/forced/state/active ]]
# Entries that are not login accounts must not decide the machine's SSH state,
# whatever their names or homes look like.
prepare system-entries; printf 'svc.name:x:2:2:Service:/var/empty:/usr/bin/nologin\nOdd Name:x:3:3::relative:/usr/bin/false\n\n' >>"$t/system-entries/root/etc/passwd"; touch "$t/system-entries/state/"{active,enabled}; run system-entries; [[ -e $t/system-entries/state/active ]]
prepare malformed-uid; echo 'broken:x:notanumber:1::/home/broken:/usr/bin/bash' >>"$t/malformed-uid/root/etc/passwd"; touch "$t/malformed-uid/state/"{active,enabled}; run malformed-uid; [[ ! -e $t/malformed-uid/state/active ]]
# openssh removed: a missing unit is not enabled, so there is nothing to disable
# and the migration completes instead of staying pending forever.
prepare unit-missing; rm "$t/unit-missing/root/home/keyed/.ssh/authorized_keys"; UNIT_MISSING=1 run unit-missing; ! grep -q 'systemctl disable' "$t/unit-missing/events"
if /usr/bin/bash "$mapped/bin/omarchy-migrate-sshd-key-only" -p >/dev/null 2>&1; then exit 1; fi

# ---- Setup's machine phase: --setup UID -- KEY... ----
/usr/bin/ssh-keygen -q -t ed25519 -N '' -f "$t/other"; other=$(<"$t/other.pub")
sprep() { prepare "$1"; rm -f "$t/$1/root/etc/ssh/sshd_config.d/10-omarchy-hardening.conf"; echo 'nologin:x:1002:1002::/home/nologin:/usr/bin/nologin' >>"$t/$1/root/etc/passwd"; }
srun() { local name=$1; shift; env -u SUDO_UID DISABLE_FAIL="${DISABLE_FAIL:-0}" TEST_ROOT="$t/$name/root" STATE="$t/$name/state" EVENTS="$t/$name/events" MATCH_BAD_USER="${MATCH_BAD_USER:-}" REFUSE_CONNECTION="${REFUSE_CONNECTION:-}" ACCEPTED_ALGORITHMS="${ACCEPTED_ALGORITHMS:-}" T_FAIL="${T_FAIL:-0}" START_FAIL="${START_FAIL:-0}" ENABLE_FAIL="${ENABLE_FAIL:-0}" STOP_FAIL="${STOP_FAIL:-0}" STOP_SIGNAL="${STOP_SIGNAL:-0}" LIMIT_FAIL="${LIMIT_FAIL:-0}" UFW_QUERY_ERROR="${UFW_QUERY_ERROR:-0}" UFW_RELOAD_SIGNAL="${UFW_RELOAD_SIGNAL:-0}" MARKER_SIGNAL="${MARKER_SIGNAL:-0}" MARKER_LOOKUP_FAIL="${MARKER_LOOKUP_FAIL:-0}" AWK_FAIL="${AWK_FAIL:-0}" FIND_FAIL="${FIND_FAIL:-0}" PACKAGE_FAIL="${PACKAGE_FAIL:-0}" ${CALLER_UID:+SUDO_UID=$CALLER_UID} "$mapped/bin/omarchy-migrate-sshd-key-only" "$@"; }
cfg() { printf '%s' "$t/$1/root/etc/ssh/sshd_config.d/00-omarchy-key-only.conf"; }
marker() { printf '%s' "$t/$1/root/var/lib/omarchy/migrations/1788163637"; }
untouched() { [[ ! -e $(cfg "$1") && ! -e $t/$1/state/active && ! -e $t/$1/state/enabled && ! -e $t/$1/state/rule && ! -e $(marker "$1") ]] || { echo "$1 changed the machine" >&2; exit 1; }; }
rolled() { untouched "$1"; ! compgen -G "$t/$1/root/etc/ssh/sshd_config.d/.00-omarchy-key-only*" >/dev/null && ! compgen -G "$t/$1/root/var/lib/omarchy/migrations/.1788163637.*" >/dev/null || { echo "$1 left staging files" >&2; exit 1; }; }

sprep s-fresh; srun s-fresh --setup 1000 -- "$key" >"$t/s-fresh.out"
[[ -e $t/s-fresh/state/active && -e $t/s-fresh/state/enabled && -e $t/s-fresh/state/rule ]] || { echo "setup did not publish sshd and its rule" >&2; exit 1; }
grep -qxF 'AuthenticationMethods publickey' "$(cfg s-fresh)" && [[ $(stat -c '%u %a' "$(cfg s-fresh)") == "0 644" ]] || { echo "setup did not install a root-owned key-only config" >&2; exit 1; }
[[ $(<"$(marker s-fresh)") == "omarchy-setup-security-sshd "* && $(stat -c '%u %a' "$(marker s-fresh)") == "0 644" ]] || { echo "setup did not commit with its own marker" >&2; exit 1; }
p=$(grep -n '^package openssh' "$t/s-fresh/events" | cut -d: -f1); q=$(grep -n '^systemctl is-active' "$t/s-fresh/events" | head -1 | cut -d: -f1); r=$(grep -n '^setpriv --reuid=1000 --regid=1000' "$t/s-fresh/events" | head -1 | cut -d: -f1)
[[ -n $p && -n $q && -n $r ]] && (( r < p && p < q )) || { echo "setup did not check the keys as the account, then install openssh, before reading service state" >&2; exit 1; }
[[ $(grep -c '^setpriv ' "$t/s-fresh/events") == 2 ]] || { echo "setup did not recheck the keys before publishing" >&2; exit 1; }
! compgen -G "$t/s-fresh/root/etc/ssh/sshd_config.d/.00-omarchy-key-only*" >/dev/null || { echo "setup left staging files" >&2; exit 1; }
echo 'ok-root - setup publishes a proven key-only sshd and commits with its marker'

# Anything but the two interfaces, a malformed UID, an unusable key or one the
# account has not authorized is refused before anything changes.
n=0
for args in '--setup 01 -- K' '--setup x -- K' '--setup 1000 K' '--setup 1000 --' '--bogus' '--setup 1000 -- R' '--setup 1000 -- N' '--setup 1000 -- O' '--setup 1001 -- K' '--setup 1002 -- K' '--setup 4242 -- K'; do
  n=$((n+1)); sprep "s-bad-$n"; read -r -a a <<<"$args"
  for i in "${!a[@]}"; do case ${a[$i]} in K) a[$i]=$key;; R) a[$i]="restrict $key";; N) a[$i]="$key"$'\n'"$other";; O) a[$i]=$other;; esac; done
  if srun "s-bad-$n" "${a[@]}" >/dev/null 2>&1; then echo "machine phase accepted: $args" >&2; exit 1; fi
  untouched "s-bad-$n"; ! grep -qv '^setpriv ' "$t/s-bad-$n/events" || { echo "machine phase acted on: $args" >&2; cat "$t/s-bad-$n/events" >&2; exit 1; }
done
sprep s-caller; if CALLER_UID=1001 srun s-caller --setup 1000 -- "$key" >/dev/null 2>&1; then echo "setup ran for an account other than sudo's caller" >&2; exit 1; fi; untouched s-caller; [[ ! -s $t/s-caller/events ]]
sprep s-symlink; mv "$t/s-symlink/root/home/keyed/.ssh/authorized_keys" "$t/s-symlink/root/home/key"; ln -s ../key "$t/s-symlink/root/home/keyed/.ssh/authorized_keys"
if srun s-symlink --setup 1000 -- "$key" >/dev/null 2>&1; then echo "setup trusted a symlinked authorized_keys" >&2; exit 1; fi; untouched s-symlink
sprep s-marker; mkdir -p "$t/s-marker/root/var/lib/omarchy/migrations"; ln -s /dev/null "$(marker s-marker)"
if srun s-marker --setup 1000 -- "$key" >/dev/null 2>&1; then echo "setup accepted a symlinked marker" >&2; exit 1; fi; [[ ! -e $(cfg s-marker) && -L $(marker s-marker) ]]
# Every configuration file sshd reads must be one only root can write, or it
# could change between the proof and the reload.
sprep s-cfg-writable; chmod 0666 "$t/s-cfg-writable/root/etc/ssh/sshd_config"
sprep s-cfg-symlink; mv "$t/s-cfg-symlink/root/etc/ssh/sshd_config" "$t/s-cfg-symlink/root/etc/ssh/real_config"; ln -s real_config "$t/s-cfg-symlink/root/etc/ssh/sshd_config"
sprep s-cfg-dropin; echo 'Port 22' >"$t/s-cfg-dropin/root/etc/ssh/sshd_config.d/20-other.conf"; chmod 0666 "$t/s-cfg-dropin/root/etc/ssh/sshd_config.d/20-other.conf"
sprep s-cfg-include; echo 'Include extra.conf' >>"$t/s-cfg-include/root/etc/ssh/sshd_config"; echo 'Include nested/*.conf' >"$t/s-cfg-include/root/etc/ssh/extra.conf"; mkdir -p "$t/s-cfg-include/root/etc/ssh/nested"; echo 'Port 22' >"$t/s-cfg-include/root/etc/ssh/nested/a.conf"; chmod 0664 "$t/s-cfg-include/root/etc/ssh/nested/a.conf"
# sshd reads quoted, escaped and "Include=" arguments too. A form the check
# cannot resolve is refused, never taken to match nothing.
sprep s-cfg-quoted; echo 'Include "/etc/ssh/untrusted file.conf"' >>"$t/s-cfg-quoted/root/etc/ssh/sshd_config"; echo 'AuthorizedKeysCommand /usr/bin/cat /tmp/attacker.pub' >"$t/s-cfg-quoted/root/etc/ssh/untrusted file.conf"; chmod 0666 "$t/s-cfg-quoted/root/etc/ssh/untrusted file.conf"
sprep s-cfg-escaped; echo 'Include /etc/ssh/untrusted\ file.conf' >>"$t/s-cfg-escaped/root/etc/ssh/sshd_config"; : >"$t/s-cfg-escaped/root/etc/ssh/untrusted file.conf"
sprep s-cfg-equals; echo 'Include=extra.conf' >>"$t/s-cfg-equals/root/etc/ssh/sshd_config"; echo 'Port 22' >"$t/s-cfg-equals/root/etc/ssh/extra.conf"; chmod 0666 "$t/s-cfg-equals/root/etc/ssh/extra.conf"
# A pattern that matches nothing yet still names where a match can appear;
# that place must be trusted, and a wildcard directory could be anywhere.
sprep s-cfg-empty; echo 'Include /etc/ssh/open.d/*.conf' >>"$t/s-cfg-empty/root/etc/ssh/sshd_config"; mkdir -p "$t/s-cfg-empty/root/etc/ssh/open.d"; chmod 0777 "$t/s-cfg-empty/root/etc/ssh/open.d"
sprep s-cfg-missing; echo 'Include /etc/ssh-extra/later/*.conf' >>"$t/s-cfg-missing/root/etc/ssh/sshd_config"; mkdir -p "$t/s-cfg-missing/root/etc/ssh-extra"; chmod 0777 "$t/s-cfg-missing/root/etc/ssh-extra"
sprep s-cfg-wild; echo 'Include /etc/ssh/*/x.conf' >>"$t/s-cfg-wild/root/etc/ssh/sshd_config"
for c in s-cfg-writable s-cfg-symlink s-cfg-dropin s-cfg-include s-cfg-quoted s-cfg-escaped s-cfg-equals s-cfg-empty s-cfg-missing s-cfg-wild; do
  if srun "$c" --setup 1000 -- "$key" >"$t/$c.out" 2>&1; then echo "setup trusted an untrusted configuration: $c" >&2; exit 1; fi
  untouched "$c"; grep -q 'is not a root-owned file only root can write' "$t/$c.out" || { echo "$c was refused for another reason" >&2; cat "$t/$c.out" >&2; exit 1; }
done
# An "Include=" ahead of the drop-in glob is read first, so precedence fails.
sprep s-cfg-eq-first; printf 'Include=/etc/ssh/early.conf\nInclude /etc/ssh/sshd_config.d/*.conf\n' >"$t/s-cfg-eq-first/root/etc/ssh/sshd_config"; echo 'AuthorizedKeysCommand /usr/bin/true' >"$t/s-cfg-eq-first/root/etc/ssh/early.conf"
if srun s-cfg-eq-first --setup 1000 -- "$key" >/dev/null 2>&1; then echo "setup accepted an Include= read before its drop-in" >&2; exit 1; fi; rolled s-cfg-eq-first
# An empty include directory only root can write is fine.
sprep s-cfg-empty-ok; echo 'Include /etc/ssh/open.d/*.conf' >>"$t/s-cfg-empty-ok/root/etc/ssh/sshd_config"; mkdir -p "$t/s-cfg-empty-ok/root/etc/ssh/open.d"
srun s-cfg-empty-ok --setup 1000 -- "$key" >/dev/null || { echo "setup refused an empty include directory only root can write" >&2; exit 1; }
# A configuration that cannot be read in full proves nothing.
sprep s-cfg-parse; AWK_FAIL=1 srun s-cfg-parse --setup 1000 -- "$key" >"$t/s-cfg-parse.out" 2>&1 && { echo "setup trusted a configuration it could not parse" >&2; exit 1; }
untouched s-cfg-parse; grep -q 'is not a root-owned file only root can write' "$t/s-cfg-parse.out" || { echo "a parser failure was refused for another reason" >&2; cat "$t/s-cfg-parse.out" >&2; exit 1; }
# Nor does a listing of an Include directory that fails part way.
# The entry it does report is a real, trusted file, so only the failed
# listing itself can refuse.
sprep s-cfg-list; echo 'Port 22' >"$t/s-cfg-list/root/etc/ssh/sshd_config.d/20-trusted.conf"; FIND_FAIL=1 srun s-cfg-list --setup 1000 -- "$key" >"$t/s-cfg-list.out" 2>&1 && { echo "setup trusted an Include directory it could not list" >&2; exit 1; }
untouched s-cfg-list; grep -q 'is not a root-owned file only root can write' "$t/s-cfg-list.out" || { echo "a listing failure was refused for another reason" >&2; cat "$t/s-cfg-list.out" >&2; exit 1; }
# The same nested include, only root-writable, is accepted.
sprep s-cfg-nested-ok; echo 'Include extra.conf' >>"$t/s-cfg-nested-ok/root/etc/ssh/sshd_config"; echo 'Include nested/*.conf' >"$t/s-cfg-nested-ok/root/etc/ssh/extra.conf"; mkdir -p "$t/s-cfg-nested-ok/root/etc/ssh/nested"; echo 'Port 22' >"$t/s-cfg-nested-ok/root/etc/ssh/nested/a.conf"
srun s-cfg-nested-ok --setup 1000 -- "$key" >/dev/null || { echo "setup refused a trusted nested include" >&2; exit 1; }
sprep s-query; UFW_QUERY_ERROR=1 srun s-query --setup 1000 -- "$key" >/dev/null 2>&1 && exit 1; untouched s-query
echo 'ok-root - setup refuses bad requests, other accounts, unsafe files and unknown firewall state before any change'

# Every failure before the commit rolls back each armed change.
n=0
for failure in T_FAIL MATCH_BAD_USER=keyed REFUSE_CONNECTION=yes ACCEPTED_ALGORITHMS=rsa-sha2-512 START_FAIL ENABLE_FAIL LIMIT_FAIL; do
  n=$((n+1)); sprep "s-fail-$n"
  if [[ $failure == *=* ]]; then export "${failure?}"; else export "$failure=1"; fi
  if srun "s-fail-$n" --setup 1000 -- "$key" >/dev/null 2>&1; then echo "setup succeeded despite $failure" >&2; exit 1; fi
  unset T_FAIL MATCH_BAD_USER REFUSE_CONNECTION ACCEPTED_ALGORITHMS START_FAIL ENABLE_FAIL LIMIT_FAIL
  rolled "s-fail-$n"
done
# An existing configuration and a running daemon get back exactly what they had.
sprep s-admin; printf 'PasswordAuthentication yes\n' >"$(cfg s-admin)"; chmod 0640 "$(cfg s-admin)"; before=$(stat -c '%a' "$(cfg s-admin)"; cat "$(cfg s-admin)"); touch "$t/s-admin/state/"{active,enabled}
if MATCH_BAD_USER=keyed srun s-admin --setup 1000 -- "$key" >/dev/null 2>&1; then exit 1; fi
[[ $(stat -c '%a' "$(cfg s-admin)"; cat "$(cfg s-admin)") == "$before" && -e $t/s-admin/state/active && -e $t/s-admin/state/enabled ]] || { echo "setup did not restore the administrator's configuration" >&2; exit 1; }
[[ $(grep '^systemctl reload' "$t/s-admin/events" | wc -l) == 1 ]] || { echo "the running daemon was not given the restored configuration" >&2; exit 1; }
# A daemon setup enabled but cannot disable keeps the key-only policy too,
# or it would start at the next boot with the restored one.
sprep s-enabled; if LIMIT_FAIL=1 DISABLE_FAIL=1 srun s-enabled --setup 1000 -- "$key" >"$t/s-enabled.out" 2>&1; then exit 1; fi
grep -qxF 'AuthenticationMethods publickey' "$(cfg s-enabled)" && [[ -e $t/s-enabled/state/enabled && ! -e $(marker s-enabled) ]] || { echo "an enabled daemon was left beneath a restored policy" >&2; exit 1; }
grep -q 'CRITICAL: SSH setup rollback was incomplete' "$t/s-enabled.out" || { echo "an incomplete rollback was not reported" >&2; exit 1; }
# A daemon setup started but cannot stop keeps the key-only policy beneath it.
sprep s-stuck; if LIMIT_FAIL=1 STOP_FAIL=1 srun s-stuck --setup 1000 -- "$key" >"$t/s-stuck.out" 2>&1; then exit 1; fi
grep -qxF 'AuthenticationMethods publickey' "$(cfg s-stuck)" && [[ -e $t/s-stuck/state/active && ! -e $(marker s-stuck) ]] || { echo "a daemon that could not be stopped was left beneath a restored policy" >&2; exit 1; }
grep -q 'CRITICAL: SSH setup rollback was incomplete' "$t/s-stuck.out" || { echo "an incomplete rollback was not reported" >&2; exit 1; }
# A stale certification is invalidated before the configuration changes, and
# a failed setup leaves none.
sprep s-stale; mkdir -p "$t/s-stale/root/var/lib/omarchy/migrations"; : >"$(marker s-stale)"; if T_FAIL=1 srun s-stale --setup 1000 -- "$key" >/dev/null 2>&1; then exit 1; fi; rolled s-stale
# A drop-in that would be read first means the key-only file cannot win.
sprep s-first; echo 'PasswordAuthentication yes' >"$t/s-first/root/etc/ssh/sshd_config.d/0-admin.conf"; if srun s-first --setup 1000 -- "$key" >/dev/null 2>&1; then exit 1; fi; rolled s-first
echo 'ok-root - setup rolls back every armed change on failure, restores administrator state, and keeps key-only beneath a daemon it cannot stop'

# The marker rename is the commit: a signal just before it rolls back, one just
# after it keeps the completed setup; a signal during rollback does not
# abandon it.
sprep s-before; if UFW_RELOAD_SIGNAL=1 srun s-before --setup 1000 -- "$key" >/dev/null 2>&1; then exit 1; fi; rolled s-before
sprep s-after; if MARKER_SIGNAL=1 srun s-after --setup 1000 -- "$key" >/dev/null 2>&1; then echo "a signalled setup reported success" >&2; exit 1; fi
grep -qxF 'AuthenticationMethods publickey' "$(cfg s-after)" && [[ -e $t/s-after/state/active && -e $t/s-after/state/rule && $(<"$(marker s-after)") == "omarchy-setup-security-sshd "* ]] || { echo "a committed setup was rolled back" >&2; exit 1; }
# Once the commit was attempted, a marker that cannot be looked up is not
# proof the commit failed: nothing is rolled back and the doubt is reported.
sprep s-lookup; if MARKER_SIGNAL=1 MARKER_LOOKUP_FAIL=1 srun s-lookup --setup 1000 -- "$key" >"$t/s-lookup.out" 2>&1; then exit 1; fi
grep -qxF 'AuthenticationMethods publickey' "$(cfg s-lookup)" && [[ -e $t/s-lookup/state/active && -e $t/s-lookup/state/rule && -e $(marker s-lookup) ]] || { echo "a marker lookup error rolled back a committed setup" >&2; exit 1; }
grep -q 'could not establish whether SSH setup completed' "$t/s-lookup.out" || { echo "an unknown commit outcome was not reported" >&2; exit 1; }
sprep s-cleanup; if LIMIT_FAIL=1 STOP_SIGNAL=1 srun s-cleanup --setup 1000 -- "$key" >/dev/null 2>&1; then exit 1; fi; rolled s-cleanup
echo 'ok-root - the marker is the commit point, and a signal during rollback does not abandon it'

# Setup shares the migration's lock and fails rather than waits while it is
# held; nothing changes, and a retry succeeds.
sprep s-busy; exec {held}>"$t/run/lock"; flock -n "$held"
if srun s-busy --setup 1000 -- "$key" >/dev/null 2>&1; then echo "setup ran while the machine lock was held" >&2; exit 1; else status=$?; fi
exec {held}>&-; (( status == 75 )); untouched s-busy; [[ ! -s $t/s-busy/events ]]
srun s-busy --setup 1000 -- "$key" >/dev/null; [[ -e $(marker s-busy) ]]
echo 'ok-root - setup and the migration never overlap'
NAMESPACE
pass "machine SSH migration preserves shared access, validates all users, serializes, and fails closed"
while IFS= read -r line; do pass "${line#ok-root - }"; done < <(grep '^ok-root - ' "$t/namespace.out")
grep -qF '/usr/bin/sudo -N -- /usr/bin/omarchy-migrate-sshd-key-only' "$ROOT/migrations/1788163637.sh" || fail "migration lacks fixed machine dispatch"
! grep -Eq 'authorized_keys|getent passwd|/usr/bin/id -u' "$ROOT/migrations/1788163637.sh" || fail "migration still uses invoking-user state"
pass "per-user migration delegates one fixed cold root machine phase"

# After the first account converted the machine, a later account without sudo
# rights must still complete: no prompt, no privileged call.
m=$(mktemp -d); trap 'rm -rf -- "$t" "$m"' EXIT
printf '#!/bin/bash\necho "sudo $*" >>"%s/calls"\n[[ ${SUDO_FAIL:-0} != 1 ]]\n' "$m" >"$m/sudo"; chmod +x "$m/sudo"
printf '#!/bin/bash\ncase $1 in is-enabled) echo "${SSHD_ENABLED_STATE:-disabled}";; is-active) echo "${SSHD_ACTIVE_STATE:-inactive}";; esac\n' >"$m/systemctl"; chmod +x "$m/systemctl"
mkdir -p "$m/etc" "$m/var"
sed -e "s#^legacy_config=/etc/ssh/sshd_config.d/10-omarchy-hardening.conf\$#legacy_config=$m/etc/10-omarchy-hardening.conf#" \
  -e "s#^key_only_config=/etc/ssh/sshd_config.d/00-omarchy-key-only.conf\$#key_only_config=$m/etc/00-omarchy-key-only.conf#" \
  -e "s#^completion_marker=/var/lib/omarchy/migrations/1788163637\$#completion_marker=$m/var/1788163637#" \
  -e "s#/usr/bin/omarchy-migrate-sshd-key-only#$m/helper#g" \
  -e "s#/usr/bin/sudo#$m/sudo#g" -e "s#/usr/bin/systemctl#$m/systemctl#g" "$ROOT/migrations/1788163637.sh" >"$m/migration"
grep -q "^legacy_config=$m/" "$m/migration" && grep -q "^key_only_config=$m/" "$m/migration" && grep -q "^completion_marker=$m/" "$m/migration" ||
  fail "test could not redirect the migration's machine paths"
# A key-only file that was never certified, such as one an interrupted setup
# left behind, must reach the root phase; once certified, it must not. Run as
# namespace root so the marker can be root-owned.
printf '#!/bin/bash\necho helper >>"%s/calls"\n' "$m" >"$m/helper"; chmod +x "$m/helper"
: >"$m/etc/00-omarchy-key-only.conf"
unshare --user --map-root-user bash -euo pipefail "$m/migration" >/dev/null || fail "an uncertified key-only file failed its migration"
grep -qx helper "$m/calls" || fail "an uncertified key-only file skipped validation" "$(cat "$m/calls" 2>/dev/null)"
: >"$m/calls"; unshare --user --map-root-user touch "$m/var/1788163637"
unshare --user --map-root-user bash -euo pipefail "$m/migration" >/dev/null || fail "a certified conversion failed its migration"
[[ ! -s $m/calls ]] || fail "a certified conversion re-entered the root phase" "$(cat "$m/calls")"
rm -f "$m/etc/00-omarchy-key-only.conf" "$m/var/1788163637" "$m/calls"
pass "an uncertified key-only file is validated and a certified conversion is not"
bash -euo pipefail "$m/migration" >/dev/null || fail "a converted machine blocks a later account without sudo"
[[ ! -e $m/calls ]] || fail "a converted machine still prompts a later account" "$(cat "$m/calls")"
pass "later accounts complete without privileges once the legacy file is gone"
# With no Omarchy file, only a daemon that may be exposed reaches the machine
# phase; an unknown service state counts as exposed.
for state in enabled:inactive disabled:active static:inactive masked-runtime:inactive unknown:unknown; do
  : >"$m/calls"
  SSHD_ENABLED_STATE=${state%%:*} SSHD_ACTIVE_STATE=${state##*:} bash -euo pipefail "$m/migration" >/dev/null || fail "an exposed daemon's migration failed"
  [[ $(<"$m/calls") == "sudo -N -- $m/helper" ]] || fail "a daemon that may be exposed ($state) skipped the machine phase" "$(cat "$m/calls")"
done
for state in disabled:inactive masked:failed not-found:inactive; do
  rm -f "$m/calls"
  SSHD_ENABLED_STATE=${state%%:*} SSHD_ACTIVE_STATE=${state##*:} bash -euo pipefail "$m/migration" >/dev/null || fail "an unexposed daemon's migration failed"
  [[ ! -e $m/calls ]] || fail "an unexposed daemon ($state) reached the machine phase" "$(cat "$m/calls")"
done
pass "with no Omarchy file, only a daemon that may be exposed reaches the machine phase"

# A pending repair makes exactly one privileged call, sudo -N to the fixed
# root phase, and nothing to revoke: no sudo -k before, after or on failure.
printf 'PasswordAuthentication no\nKbdInteractiveAuthentication no\n' >"$m/etc/10-omarchy-hardening.conf"
: >"$m/calls"
bash -euo pipefail "$m/migration" >/dev/null || fail "a pending legacy repair failed its machine phase"
[[ $(<"$m/calls") == "sudo -N -- $m/helper" ]] || fail "a pending legacy repair did not make exactly one sudo -N call" "$(cat "$m/calls")"
: >"$m/calls"
if SUDO_FAIL=1 bash -euo pipefail "$m/migration" >/dev/null 2>&1; then fail "a failed machine phase completed the migration"; fi
[[ $(<"$m/calls") == "sudo -N -- $m/helper" ]] || fail "a failed machine phase made further privileged calls" "$(cat "$m/calls")"
! grep -q 'sudo -k' "$ROOT/migrations/1788163637.sh" || fail "the migration still revokes a timestamp it never creates"
rm -f "$m/etc/10-omarchy-hardening.conf"
pass "a pending repair makes one sudo -N call to the root phase and revokes nothing"
