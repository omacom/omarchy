#!/bin/bash
#
# omarchy-parent is the parent's side of a child install: the parent password is
# root's password, sudo and polkit ask for it, and the kid account holds an
# explicit grant instead of wheel. The static half below pins the contract
# from the source; the behavioral half runs the real command as namespaced
# root where the kernel allows it.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

parent="$ROOT/bin/omarchy-parent"
leaf="$ROOT/install/config/parent.sh"

# Help never elevates: reading it must not ask for a password.
help_output=$(bash "$parent" --help)
[[ $help_output == *"omarchy-parent password"* && $help_output == *"omarchy-parent apply --user NAME"* ]] ||
  fail "omarchy-parent --help prints usage without elevating"
pass "omarchy-parent answers --help before asking for a password"

grep -q '^# omarchy:summary=' "$parent" || fail "omarchy-parent carries command metadata"
grep -Fq 'GROUP_DESCRIPTIONS[parent]=' "$ROOT/bin/omarchy" || fail "the parent group is described for the CLI listing"
pass "omarchy-parent is a documented CLI command"

# The sudoers content: rootpw and the parent prompt, nothing else.
system_rules=$(sed -n "/<<'SUDOERS'/,/^SUDOERS$/p" "$parent" | grep -vE "^(SUDOERS|.*<<'SUDOERS'|#|[[:space:]]*$)")
[[ $system_rules == $'Defaults rootpw\nDefaults passprompt="[sudo] parent password: "' ]] ||
  fail "the system sudoers drop-in carries exactly rootpw and the parent prompt" "got: $system_rules"
pass "the system sudoers drop-in makes sudo ask for the parent password"

grep -Fq "printf '%s ALL=(ALL:ALL) ALL\\n%s ALL=(root) NOPASSWD: %s\\n'" "$parent" ||
  fail "the account grant is the general grant plus one NOPASSWD line"
grep -Fq "BROWSER_POLICY_COMMAND='/usr/bin/omarchy-theme-set-browser-policy [0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]'" "$parent" ||
  fail "the re-granted passwordless action is the browser accent write, spelled as six hex digits"
shipped_rule=$(grep -v '^#' "$ROOT/etc/sudoers.d/omarchy-theme-browser")
[[ $shipped_rule == *"/usr/bin/omarchy-theme-set-browser-policy [0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]"* ]] ||
  fail "the re-grant names the same command and argument shape as the shipped wheel rule"
pass "the kid account keeps exactly the browser accent write passwordless"

# The polkit rule, evaluated the way polkitd would: one admin rule, root.
rules_js=$(sed -n "/<<'RULES'/,/^RULES$/p" "$parent" | grep -vE "^(RULES|.*<<'RULES')")
RULES_JS="$rules_js" run_node_test <<'JS'
const admins = []
const polkit = { addAdminRule: fn => admins.push(fn), addRule: () => fail('the parent rule adds no authorization rule') }
new Function('polkit', process.env.RULES_JS)(polkit)
assertEqual(admins.length, 1, 'the parent rules file registers one admin rule')
assertDeepEqual(admins[0]({ id: 'org.freedesktop.policykit.exec' }, { user: 'kid' }), ['unix-user:root'],
  'administrative prompts authenticate as root for every action and subject')
JS

# Ordering that keeps sudo usable throughout: root's password is checked
# first, the account's grant lands before the account leaves wheel, and
# nothing is written over a sudoers file that fails visudo.
apply_body=$(sed -n '/^apply_posture() {/,/^}/p' "$parent")
order() { printf '%s\n' "$apply_body" | grep -n -F "$1" | head -1 | cut -d: -f1; }
(( $(order require_root_password) < $(order 'install_sudoers omarchy-parent ') )) ||
  fail "apply checks root's password before installing rootpw"
(( $(order 'install_sudoers "omarchy-parent-$user"') < $(order 'gpasswd -d') )) ||
  fail "apply grants the account sudo before taking it out of wheel"
helper="$ROOT/install/helpers/parent.sh"
grep -Fq 'visudo -cf "$stage"' "$helper" || fail "apply validates every sudoers file with visudo before it goes live"
grep -Fq 'mktemp "$SUDOERS_DIR/.$name.XXXXXX"' "$helper" || fail "apply stages sudoers files under a dotted name sudo ignores"
pass "apply keeps a working sudo path at every step"

# Both entry points are gated on the child profile; --remove is not, so a
# machine can always be put back.
for entry in password apply; do
  body=$(sed -n "/^  $entry)/,/;;/p" "$parent")
  [[ $body == *require_child_install* ]] || fail "$entry refuses to run outside the child profile"
done
grep -Fq 'omarchy-parent apply --user "$OMARCHY_INSTALL_USER"' "$leaf" || fail "the install leaf calls apply for the install user"
grep -Fq '== "child"' "$leaf" || fail "the install leaf only applies the posture on child installs"
grep -Fq 'run_logged "$OMARCHY_INSTALL/config/parent.sh"' "$ROOT/install/config/all.sh" || fail "the install leaf is wired into system setup"
pass "the parental posture is gated on the child profile"

# faillock counts root on a child install only: the options ride on
# system-auth's preauth and authfail lines as module arguments, where an
# omarchy-settings upgrade rewriting faillock.conf cannot reach them, and the
# shipped faillock.conf stays upstream's. The functions run extracted against
# a copy of the stock stack as the install's lockout step leaves it.
! grep -q 'even_deny_root' "$ROOT/etc/security/faillock.conf" || fail "the shipped faillock.conf leaves root out of the count on every other install"
faillock_tmp=$(mktemp -d)
cat >"$faillock_tmp/system-auth" <<'PAM'
#%PAM-1.0

auth       required                    pam_faillock.so preauth silent deny=10 unlock_time=120
# Optionally use requisite above if you do not want to prompt for the password
# on locked accounts.
-auth      [success=2 default=ignore]  pam_systemd_home.so
auth       [success=1 default=bad]     pam_unix.so          try_first_pass nullok
auth       [default=die]               pam_faillock.so authfail deny=10 unlock_time=120
auth       optional                    pam_permit.so
auth       required                    pam_env.so
auth       required                    pam_faillock.so      authsucc

account    required                    pam_unix.so
PAM
stock=$(<"$faillock_tmp/system-auth")
(
  export OMARCHY_SYSTEM_AUTH="$faillock_tmp/system-auth"
  eval "$(sed -n '/^SYSTEM_AUTH=/p; /^ROOT_LOCKOUT=/p; /^lock_root_prompts() {/,/^}/p; /^unlock_root_prompts() {/,/^}/p' "$parent")"
  lock_root_prompts
  [[ $(grep -c 'pam_faillock\.so preauth silent deny=10 unlock_time=120 even_deny_root root_unlock_time=120$' "$SYSTEM_AUTH") == 1 ]] ||
    fail "apply has faillock count root before the password is checked" "$(<"$SYSTEM_AUTH")"
  [[ $(grep -c 'pam_faillock\.so authfail deny=10 unlock_time=120 even_deny_root root_unlock_time=120$' "$SYSTEM_AUTH") == 1 ]] ||
    fail "apply has faillock record root's failures" "$(<"$SYSTEM_AUTH")"
  [[ $(grep -c 'even_deny_root' "$SYSTEM_AUTH") == 2 ]] || fail "the authsucc line and the rest of the stack are untouched" "$(<"$SYSTEM_AUTH")"
  locked=$(<"$SYSTEM_AUTH")
  lock_root_prompts
  [[ $(<"$SYSTEM_AUTH") == "$locked" ]] || fail "a rerun of apply adds the options once" "$(<"$SYSTEM_AUTH")"
  unlock_root_prompts
  [[ $(<"$SYSTEM_AUTH") == "$stock" ]] || fail "apply --remove puts the stock lines back" "$(<"$SYSTEM_AUTH")"
  printf 'auth required pam_unix.so\n' >"$SYSTEM_AUTH"
  lock_root_prompts 2>"$faillock_tmp/warning" || fail "a stack without pam_faillock does not fail apply"
  grep -q '^Warning: .*pam_faillock' "$faillock_tmp/warning" || fail "a stack without pam_faillock is warned about" "$(<"$faillock_tmp/warning")"
  [[ $(<"$SYSTEM_AUTH") == 'auth required pam_unix.so' ]] || fail "a stack without pam_faillock is left alone"
)
rm -rf "$faillock_tmp"
[[ $apply_body == *lock_root_prompts* ]] || fail "apply has faillock count root"
[[ $(sed -n '/^remove_posture() {/,/^}/p' "$parent") == *unlock_root_prompts* ]] || fail "apply --remove leaves root out of the count again"
pass "faillock rate-limits the parent password on a child install only, through system-auth's module arguments"

# The text consoles: closed by apply on a child install, reopened by --remove
# or tty on, as a set that leaves tty1 to the display manager, and without
# --now inside the install chroot. The functions run extracted, with systemctl
# stubbed.
console_tmp=$(mktemp -d)
mkdir -p "$console_tmp/bin"
cat >"$console_tmp/bin/systemctl" <<'SH'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$CONSOLE_CALLS"
SH
chmod +x "$console_tmp/bin/systemctl"
export CONSOLE_CALLS="$console_tmp/calls"
(
  PATH="$console_tmp/bin:$PATH"
  for fn in console_units mask_consoles unmask_consoles; do
    script="/^$fn() {/,/^}/p"
    eval "$(sed -n "$script" "$parent")"
  done
  systemd_running() { [[ ${STUB_SYSTEMD:-running} == running ]]; }
  : >"$CONSOLE_CALLS"; mask_consoles
  [[ $(<"$CONSOLE_CALLS") == 'systemctl mask --now getty@tty2.service autovt@tty2.service getty@tty3.service autovt@tty3.service getty@tty4.service autovt@tty4.service getty@tty5.service autovt@tty5.service getty@tty6.service autovt@tty6.service' ]] ||
    fail "closing the consoles masks tty2 to tty6 and stops them on a running system" "calls: $(<"$CONSOLE_CALLS")"
  : >"$CONSOLE_CALLS"; STUB_SYSTEMD=chroot mask_consoles
  [[ $(<"$CONSOLE_CALLS") == 'systemctl mask getty@tty2.service autovt@tty2.service getty@tty3.service autovt@tty3.service getty@tty4.service autovt@tty4.service getty@tty5.service autovt@tty5.service getty@tty6.service autovt@tty6.service' ]] ||
    fail "in the install chroot the consoles are masked without --now" "calls: $(<"$CONSOLE_CALLS")"
  : >"$CONSOLE_CALLS"; unmask_consoles
  [[ $(<"$CONSOLE_CALLS") == 'systemctl unmask getty@tty2.service autovt@tty2.service getty@tty3.service autovt@tty3.service getty@tty4.service autovt@tty4.service getty@tty5.service autovt@tty5.service getty@tty6.service autovt@tty6.service' ]] ||
    fail "reopening the consoles unmasks the same units" "calls: $(<"$CONSOLE_CALLS")"
)
rm -rf "$console_tmp"
[[ $apply_body == *mask_consoles* ]] || fail "apply closes the consoles on a child install"
[[ $(sed -n '/^remove_posture() {/,/^}/p' "$parent") == *unmask_consoles* ]] || fail "apply --remove reopens the consoles"
grep -q '^  tty)' "$parent" || fail "tty is dispatched"
grep -Fq 'systemd-detect-virt --quiet --chroot' "$parent" || fail "the running-system check sees through the install chroot's bind-mounted /run"
pass "child installs close the text consoles, and tty reopens them"

# Two menu entries would hand the invoking account passwordless root, which
# on a child install is the kid's account once a parent has typed the
# password: they stay off the menu there.
menu="$ROOT/default/omarchy/omarchy-menu.jsonc"
grep -q '"setup.security.passwordless-sudo": {[^}]*"when":"! omarchy-profile-child"' "$menu" || fail "Passwordless Sudo stays off a child install's menu"
grep -q '"setup.security.sudoless-docker": {[^}]*"when":"! omarchy-profile-child && omarchy-sudo-docker --configured"' "$menu" || fail "Sudoless Docker stays off a child install's menu"
grep -q '"setup.security.fido2": {[^}]*"when":"! omarchy-profile-child"' "$menu" || fail "Fido2 setup stays off a child install's menu"
grep -q '"update.omarchy": {[^}]*"when":"! omarchy-profile-child"' "$menu" || fail "Update > Omarchy stays off a child install's menu"
grep -q '"update.channel": {[^}]*"when":"! omarchy-profile-child"' "$menu" || fail "Update > Channel stays off a child install's menu"
grep -q '"update.firmware": {[^}]*"when":"! omarchy-profile-child"' "$menu" || fail "Update > Firmware stays off a child install's menu"
grep -q '"learn.community": {[^}]*"when":"! omarchy-profile-child"' "$menu" || fail "Learn > Community stays off a child install's menu"
if grep -q '"system": {[^}]*omarchy-profile-child' "$menu"; then
  fail "System stays on a child install so lock and power remain reachable"
fi
grep -q '"update.password.parent": {[^}]*"when":"omarchy-profile-child"' "$menu" || fail "Update > Password > Parent stays on a child install"
pass "the menu keeps the grants that would land on the kid account off a child install"

# Install and Remove stay: a kid needs editors, toolchains and coding agents,
# and anything there that touches system packages goes through sudo, which asks
# for the parent password; mise toolchains and agents land in the kid's home.
! grep -q '"install": {[^}]*omarchy-profile-child' "$menu" || fail "Install is on a child install's menu"
! grep -q '"remove": {[^}]*omarchy-profile-child' "$menu" || fail "Remove is on a child install's menu"
pass "Install and Remove stay on a child install's menu, behind the parent password where they need root"

# Features plug in as omarchy-parent-<name> beside this command: help lists
# them by summary (hidden plumbing excepted), an unknown core command is handed
# to the matching one before any elevation, and a name with no command is
# refused. install_sudoers moved to the helper they all source.
dispatch_tmp=$(mktemp -d)
mkdir -p "$dispatch_tmp/bin"
cat >"$dispatch_tmp/bin/omarchy-parent-foo" <<'SH'
#!/bin/bash
# omarchy:summary=Frobnicate the kid's things
printf 'foo %s\n' "$*" >"$DISPATCH_LOG"
SH
cat >"$dispatch_tmp/bin/omarchy-parent-bar-tick" <<'SH'
#!/bin/bash
# omarchy:summary=Plumbing behind foo
# omarchy:hidden=true
SH
chmod +x "$dispatch_tmp/bin"/*
export DISPATCH_LOG="$dispatch_tmp/log"
help_output=$(OMARCHY_PATH="$dispatch_tmp" bash "$parent" --help)
[[ $help_output == *"foo       Frobnicate the kid's things"* ]] || fail "help lists feature commands by their summary" "$help_output"
[[ $help_output != *bar-tick* ]] || fail "help leaves hidden plumbing out of the feature list"
PATH="$dispatch_tmp/bin:$ROOT/bin:$PATH" OMARCHY_PATH="$dispatch_tmp" bash "$parent" foo on --user kid
[[ $(<"$DISPATCH_LOG") == "foo on --user kid" ]] || fail "a feature command receives its arguments untouched, before any elevation" "got: $(<"$DISPATCH_LOG")"
if PATH="$dispatch_tmp/bin:$ROOT/bin:$PATH" OMARCHY_PATH="$dispatch_tmp" bash "$parent" nope >/dev/null 2>&1; then
  fail "a name with no feature command is refused"
fi
rm -rf "$dispatch_tmp"
[[ -f $ROOT/install/helpers/parent.sh ]] || fail "the shared parent helper ships"
grep -Fq 'source "$OMARCHY_PATH/install/helpers/parent.sh"' "$parent" || fail "omarchy-parent sources the shared helper"
! grep -q '^install_sudoers() {' "$parent" || fail "install_sudoers lives in the helper, not in omarchy-parent"
grep -q '^install_sudoers() {' "$ROOT/install/helpers/parent.sh" || fail "the helper defines install_sudoers"
pass "omarchy-parent dispatches to feature commands and shares its sudoers installer"

# Behavioral half: the real command as namespaced root, against scratch
# sudoers and polkit directories. Every account-touching tool is stubbed; the
# sudoers files themselves are checked by the real visudo where one exists.
if ! unshare --user --map-root-user true 2>/dev/null; then
  skip "no unprivileged user namespace; skipping the omarchy-parent apply and password probes"
  exit 0
fi

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin" "$test_tmp/sudoers.d" "$test_tmp/rules.d"
export CALLS="$test_tmp/calls"
printf 'auth       required                    pam_faillock.so preauth silent deny=10 unlock_time=120\nauth       [default=die]               pam_faillock.so authfail deny=10 unlock_time=120\nauth       required                    pam_faillock.so      authsucc\n' >"$test_tmp/system-auth"

cat >"$stub_bin/passwd" <<'SH'
#!/bin/bash
echo "root ${STUB_ROOT_STATUS:-P} 09/01/2026 0 99999 7 -1"
SH
cat >"$stub_bin/gpasswd" <<'SH'
#!/bin/bash
printf 'gpasswd %s\n' "$*" >>"$CALLS"
SH
cat >"$stub_bin/id" <<'SH'
#!/bin/bash
printf '%s\n' "${STUB_GROUPS:-wheel input}"
SH
cat >"$stub_bin/getent" <<'SH'
#!/bin/bash
[[ $2 == kid ]]
SH
cat >"$stub_bin/omarchy-profile-child" <<'SH'
#!/bin/bash
[[ ${STUB_PROFILE:-child} == child ]]
SH
cat >"$stub_bin/chpasswd" <<'SH'
#!/bin/bash
printf 'chpasswd %s\n' "$(cat)" >>"$CALLS"
SH
# Console behavior is covered above. The namespaced apply probes must not
# contact the host's system manager, even on an installed child machine.
printf '#!/bin/bash\nexit 0\n' >"$stub_bin/systemctl"
cat >"$stub_bin/gum" <<'SH'
#!/bin/bash
line=$(sed -n "$(( $(cat "$GUM_COUNT") + 1 ))p" "$GUM_SCRIPT")
echo $(( $(cat "$GUM_COUNT") + 1 )) >"$GUM_COUNT"
printf '%s\n' "${line#*:}"
exit "${line%%:*}"
SH
if ! command -v visudo >/dev/null; then
  printf '#!/bin/bash\nexit 0\n' >"$stub_bin/visudo"
fi
chmod +x "$stub_bin"/*

run_parent() {
  : >"$CALLS"
  OMARCHY_SUDOERS_DIR="$test_tmp/sudoers.d" OMARCHY_POLKIT_RULES_DIR="$test_tmp/rules.d" OMARCHY_PARENT_CONF="$test_tmp/parent.conf" OMARCHY_PATH="$ROOT" \
  OMARCHY_SYSTEM_AUTH="$test_tmp/system-auth" \
  PATH="$stub_bin:$PATH" unshare --user --map-root-user bash "$parent" "$@"
}

run_parent apply --user kid >/dev/null || fail "omarchy-parent apply succeeds on a child install"
[[ $(grep -v '^#' "$test_tmp/sudoers.d/omarchy-parent") == $'Defaults rootpw\nDefaults passprompt="[sudo] parent password: "' ]] ||
  fail "apply writes the system sudoers drop-in"
[[ $(stat -c %a "$test_tmp/sudoers.d/omarchy-parent") == 440 ]] || fail "the sudoers drop-in is mode 440"
[[ $(<"$test_tmp/sudoers.d/omarchy-parent-kid") == $'kid ALL=(ALL:ALL) ALL\nkid ALL=(root) NOPASSWD: /usr/bin/omarchy-theme-set-browser-policy [0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]' ]] ||
  fail "apply writes the kid account's grant"
[[ -f $test_tmp/sudoers.d/00-omarchy-wheel ]] || fail "apply keeps %wheel meaningful for a future parent account"
grep -Fq 'return ["unix-user:root"]' "$test_tmp/rules.d/40-omarchy-parent.rules" || fail "apply writes the polkit admin rule"
[[ $(grep -c 'pam_faillock\.so \(preauth\|authfail\) .*even_deny_root root_unlock_time=120$' "$test_tmp/system-auth") == 2 ]] ||
  fail "apply has faillock count root on the live stack" "$(<"$test_tmp/system-auth")"
[[ $(<"$CALLS") == "gpasswd -d kid wheel" ]] || fail "apply takes the kid out of wheel" "calls: $(<"$CALLS")"
! ls "$test_tmp/sudoers.d"/.omarchy-parent* >/dev/null 2>&1 || fail "apply leaves no stage files behind"
pass "omarchy-parent apply installs the posture and removes the kid from wheel"

STUB_GROUPS="input" run_parent apply --user kid >/dev/null || fail "a rerun succeeds"
[[ ! -s $CALLS ]] || fail "a rerun on an account already outside wheel touches no group" "calls: $(<"$CALLS")"
pass "omarchy-parent apply is idempotent"

if STUB_ROOT_STATUS=L run_parent apply --user kid >/dev/null 2>&1; then
  fail "apply refuses when root's password is locked"
fi
if STUB_PROFILE=default run_parent apply --user kid >/dev/null 2>&1; then
  fail "apply refuses outside the child profile"
fi
pass "omarchy-parent apply refuses a locked root and a non-child install"

run_parent apply --remove --user kid >/dev/null || fail "apply --remove succeeds"
! grep -q 'even_deny_root' "$test_tmp/system-auth" || fail "apply --remove leaves root out of faillock's count" "$(<"$test_tmp/system-auth")"
[[ ! -e $test_tmp/sudoers.d/omarchy-parent && ! -e $test_tmp/sudoers.d/omarchy-parent-kid && ! -e $test_tmp/rules.d/40-omarchy-parent.rules ]] ||
  fail "apply --remove deletes what apply wrote"
pass "omarchy-parent apply --remove is the reverse of apply"

export GUM_SCRIPT="$test_tmp/gum-script" GUM_COUNT="$test_tmp/gum-count"
printf '%s\n' "0:s3cret" "0:s3cret" >"$GUM_SCRIPT"; echo 0 >"$GUM_COUNT"
SUDO_USER=kid run_parent password >/dev/null || fail "omarchy-parent password succeeds"
grep -Fxq 'chpasswd root:s3cret' "$CALLS" || fail "password sets root's password over stdin" "calls: $(<"$CALLS")"
grep -Fxq 'gpasswd -d kid wheel' "$CALLS" || fail "password applies the posture to the invoking account"
pass "omarchy-parent password sets the parent password and applies the posture"

printf '%s\n' "0:one" "0:two" >"$GUM_SCRIPT"; echo 0 >"$GUM_COUNT"
if SUDO_USER=kid run_parent password >/dev/null 2>&1; then
  fail "password rejects a mismatched confirmation"
fi
[[ ! -s $CALLS ]] || fail "a rejected password never reaches chpasswd" "calls: $(<"$CALLS")"
pass "omarchy-parent password rejects mismatched input before touching root"
