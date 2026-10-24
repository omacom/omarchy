#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup_ad="$ROOT/bin/omarchy-setup-ad"
apply_sssd="$ROOT/bin/omarchy-apply-sssd"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls"
sssd_conf="$test_tmp/sssd.conf"
joined="$test_tmp/joined"
mkdir -p "$stub_bin"

# The commands that reach the machine are stubs that log their arguments; the
# scripts under test are the real ones. The sudo stub answers for sssd.conf,
# which lives in a root-only directory the real file is read from.
cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$CALL_LOG"
args=("${@//\/etc\/sssd\/sssd.conf/$SSSD_CONF}")

case ${args[0]} in
  cat) cat "${args[@]:1}" ;;
  stat) [[ ${args[2]} == "%a" ]] && echo 640 || echo root:sssd ;;
  install) cp "${args[-2]}" "${args[-1]}" ;;
  realm) touch "$JOINED" ;;
  *) ;;
esac
STUB

cat >"$stub_bin/realm" <<'STUB'
#!/bin/bash
printf 'realm %s\n' "$*" >>"$CALL_LOG"
case $1 in
  discover) [[ ${REALM_DISCOVER_FAILS:-} != "1" ]] ;;
  list) [[ ! -e $JOINED ]] || echo example.corp ;;
esac
STUB

cat >"$stub_bin/hostnamectl" <<'STUB'
#!/bin/bash
echo workstation.example.corp
STUB

cat >"$stub_bin/gum" <<'STUB'
#!/bin/bash
exit 1
STUB

cat >"$stub_bin/omarchy-i18n" <<'STUB'
#!/bin/bash
echo "$1"
STUB

for command in omarchy-pkg-add omarchy-pkg-aur-add omarchy-apply-sssd omarchy-apply-lock; do
  cat >"$stub_bin/$command" <<'STUB'
#!/bin/bash
printf '%s %s\n' "${0##*/}" "$*" >>"$CALL_LOG"
STUB
done
chmod +x "$stub_bin"/*

write_sssd_conf() {
  cat >"$sssd_conf" <<'CONF'

[sssd]
domains = example.corp
config_file_version = 2
services = nss, pam

[domain/example.corp]
default_shell = /bin/bash
fallback_homedir = /home/%u@%d
id_provider = ad
use_fully_qualified_names = True
access_provider = ad

[pam]
pam_verbosity = 1
CONF
}

run_setup() {
  set +e
  output=$(env PATH="$stub_bin:/usr/bin:/bin" CALL_LOG="$calls" SSSD_CONF="$sssd_conf" JOINED="$joined" \
    REALM_DISCOVER_FAILS="${REALM_DISCOVER_FAILS:-}" bash "$setup_ad" "$@" 2>&1)
  status=$?
  set -e
}

reset_setup() {
  : >"$calls"
  rm -f "$joined"
  write_sssd_conf
}

# Refused input must stop the command before it installs or changes anything,
# since the values end up in sssd.conf and on the realm command line.
for invalid in \
  "--domain example" \
  "--domain -example.corp" \
  "--domain exa_mple.corp" \
  "--domain example.corp --group a,b" \
  "--domain example.corp --group a=b" \
  "--domain example.corp --group -x" \
  "--domain example.corp --join-user -U" \
  "--domain example.corp --join-user a;b" \
  "--domain" \
  "--bogus"; do
  reset_setup
  # shellcheck disable=SC2086
  run_setup $invalid
  (( status == 2 )) || fail "refused input '$invalid' exits with status 2" "$output"
  [[ ! -s $calls ]] || fail "refused input '$invalid' changes nothing" "$(cat "$calls")"
done
reset_setup
run_setup --domain example.corp --group $'a\nb'
(( status == 2 )) && [[ ! -s $calls ]] || fail "a group name with a newline is refused before anything changes"
pass "invalid domain, group and account names are refused before anything changes"

reset_setup
run_setup --domain Example.Corp --group "Linux Users" --join-user admin
(( status == 0 )) || fail "joining a domain succeeds" "$output"
grep -Fx 'sudo realm join -v -U admin Example.Corp' "$calls" >/dev/null || fail "the join names the account and the domain" "$(cat "$calls")"

for step in "omarchy-pkg-add sssd krb5 samba" "omarchy-pkg-aur-add realmd adcli" "realm discover Example.Corp" \
  "sudo realm join" "sudo systemctl enable --now sssd.service" "omarchy-apply-sssd" "omarchy-apply-lock"; do
  grep -nF "$step" "$calls" >/dev/null || fail "the setup runs: $step" "$(cat "$calls")"
done
order=$(grep -nE '^(omarchy-pkg-add|omarchy-pkg-aur-add|realm discover|sudo realm join|sudo systemctl enable|omarchy-apply-sssd|omarchy-apply-lock)' "$calls" | cut -d: -f2 | cut -d' ' -f1-2 | tr '\n' ',')
[[ $order == "omarchy-pkg-add sssd,omarchy-pkg-aur-add realmd,realm discover,sudo realm,sudo systemctl,omarchy-apply-sssd ,omarchy-apply-lock ," ]] ||
  fail "packages come before the join, and SSSD is wired in after it" "$order"
pass "the setup installs, discovers, joins, then wires SSSD into the system"

for expected in 'use_fully_qualified_names = False' 'fallback_homedir = /home/%u' 'access_provider = simple' 'simple_allow_groups = Linux Users'; do
  (( $(grep -cFx "$expected" "$sssd_conf") == 1 )) || fail "sssd.conf holds exactly one: $expected" "$(cat "$sssd_conf")"
done
(( $(sed -n '/^\[domain\/example.corp\]/,/^\[pam\]/p' "$sssd_conf" | grep -c 'simple_allow_groups') == 1 )) ||
  fail "the group is set inside the domain section"
grep -Fx 'pam_verbosity = 1' "$sssd_conf" >/dev/null && grep -Fx 'id_provider = ad' "$sssd_conf" >/dev/null ||
  fail "settings the setup does not own are kept"
grep -F 'sudo install -m 640 -o root -g sssd' "$calls" >/dev/null || fail "sssd.conf keeps the mode and owner it had" "$(cat "$calls")"
pass "sssd.conf gets short names, a /home/<name> home and the group, and keeps everything else"

# Running it again with the same answers changes nothing and does not rejoin.
cp "$sssd_conf" "$test_tmp/sssd.after"
: >"$calls"
run_setup --domain example.corp --group "Linux Users" --join-user admin
(( status == 0 )) || fail "running the setup again succeeds" "$output"
if grep -F 'realm join' "$calls" >/dev/null; then
  fail "a computer that is already joined is not joined again"
fi
cmp -s "$sssd_conf" "$test_tmp/sssd.after" || fail "running the setup again leaves sssd.conf as it was"
pass "running the setup again does not rejoin and leaves sssd.conf as it was"

# Without a group the domain keeps its own access rules.
reset_setup
run_setup --domain example.corp --join-user admin
(( status == 0 )) || fail "joining without a group succeeds" "$output"
grep -Fx 'access_provider = ad' "$sssd_conf" >/dev/null && ! grep -F 'simple_allow_groups' "$sssd_conf" >/dev/null ||
  fail "no group leaves the domain's access rules alone"
pass "without a group the domain's own access rules stay"

# A domain that cannot be found, or a join that leaves no domain section, must
# not leave a half-written configuration behind.
reset_setup
REALM_DISCOVER_FAILS=1 run_setup --domain example.corp --join-user admin
(( status == 1 )) || fail "an undiscoverable domain stops the setup" "$output"
if grep -E 'realm join|install -m' "$calls" >/dev/null; then
  fail "an undiscoverable domain is not joined or configured"
fi
reset_setup
printf '[sssd]\ndomains = other.corp\n' >"$sssd_conf"
run_setup --domain example.corp --join-user admin
(( status == 1 )) || fail "a join without the domain section stops the setup" "$output"
if grep -F 'install -m' "$calls" >/dev/null; then
  fail "a configuration without the domain section is not replaced"
fi
pass "an undiscoverable domain or a missing domain section changes nothing"

# omarchy-apply-sssd: run a copy that points at scratch files, the way the lock
# helper's test does, since the real ones are under /etc and /usr.
nsswitch="$test_tmp/nsswitch.conf"
su_pam="$test_tmp/su"
pam_module="$test_tmp/pam_sss.so"
patched="$test_tmp/omarchy-apply-sssd"
sed \
  -e "s#^sssd_pam_module=.*#sssd_pam_module=$pam_module#" \
  -e "s#^nsswitch=.*#nsswitch=$nsswitch#" \
  -e "s#^su_pam=.*#su_pam=$su_pam#" \
  "$apply_sssd" >"$patched"
if grep -E '/etc/|/usr/' "$patched" | grep -vE '^\s*#' >/dev/null; then
  fail "the isolated copy points every path at scratch files"
fi

cat >"$stub_bin/systemctl" <<'STUB'
#!/bin/bash
[[ $1 == "is-enabled" ]] && (( ${SSSD_ENABLED:-1} == 1 ))
STUB
cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$CALL_LOG"
"$@"
STUB
chmod +x "$stub_bin/systemctl" "$stub_bin/sudo"

write_system_files() {
  cat >"$nsswitch" <<'CONF'
# Name Service Switch configuration file.
passwd: files systemd
group: files [SUCCESS=merge] systemd
shadow: files systemd
gshadow: files systemd
hosts: mymachines resolve files myhostname dns
netgroup: files
CONF
  cat >"$su_pam" <<'CONF'
#%PAM-1.0
auth            sufficient      pam_rootok.so
auth            required        pam_unix.so
account         required        pam_unix.so
session         required        pam_unix.so
session         required        pam_limits.so
password        include         system-auth
CONF
  : >"$pam_module"
  : >"$calls"
}

run_apply() {
  PATH="$stub_bin:/usr/bin:/bin" CALL_LOG="$calls" SSSD_ENABLED="${SSSD_ENABLED:-1}" bash "$patched"
}

# Machines without SSSD run no privileged command at all, so every update can
# call this.
write_system_files
cp "$nsswitch" "$test_tmp/nsswitch.before"
SSSD_ENABLED=0 run_apply >/dev/null || fail "a machine without SSSD enabled runs the helper without error"
rm "$pam_module"
run_apply >/dev/null || fail "a machine without the SSSD PAM module runs the helper without error"
[[ ! -s $calls ]] && cmp -s "$nsswitch" "$test_tmp/nsswitch.before" ||
  fail "a machine without SSSD set up is left alone" "$(cat "$calls")"
pass "a machine without SSSD set up is left alone and asks for no privileges"

write_system_files
run_apply >/dev/null || fail "the helper runs where SSSD is set up"
for database in passwd group shadow gshadow; do
  (( $(grep -E "^$database:" "$nsswitch" | grep -cE '[[:space:]]sss$') == 1 )) ||
    fail "$database lookups include sss" "$(cat "$nsswitch")"
done
grep -Fx 'group: files [SUCCESS=merge] systemd sss' "$nsswitch" >/dev/null || fail "the group merge rule is kept"
grep -Fx 'hosts: mymachines resolve files myhostname dns' "$nsswitch" >/dev/null &&
  grep -Fx 'netgroup: files' "$nsswitch" >/dev/null || fail "databases that are not user lookups are left alone"
(( $(grep -cE '^(auth|account|session) include system-auth$' "$su_pam") == 3 )) || fail "su asks the system stack" "$(cat "$su_pam")"
grep -Fx 'session         required        pam_limits.so' "$su_pam" >/dev/null &&
  grep -Fx 'auth            sufficient      pam_rootok.so' "$su_pam" >/dev/null || fail "the rest of su is kept"
pass "directory accounts are looked up through sss and su asks the system stack"

: >"$calls"
run_apply >/dev/null || fail "the helper runs again"
[[ ! -s $calls ]] || fail "a machine that is already set up runs no privileged command" "$(cat "$calls")"
pass "a machine that is already set up runs no privileged command"

write_system_files
sed -i 's/^passwd: files systemd$/passwd: files systemd sss/' "$nsswitch"
run_apply >/dev/null || fail "the helper runs with sss already on one database"
(( $(grep -c '^passwd: files systemd sss$' "$nsswitch") == 1 )) || fail "sss is not added twice" "$(cat "$nsswitch")"
grep -Fx 'group: files [SUCCESS=merge] systemd sss' "$nsswitch" >/dev/null || fail "the other databases still get sss"
pass "sss already present on a database is not added twice"
