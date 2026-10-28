#!/bin/bash
#
# First-boot provisioning on a child install: both passwords, root kept for
# the parent, the kid account outside wheel, the disk keyed to both. The script
# runs as root on tty1 and writes /etc by literal path, so its contract is
# pinned from the source; user_groups itself is exercised in
# sudoless-docker-posture-test.sh.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

owner="$ROOT/bin/omarchy-provision-owner"

section() { sed -n "/^$1() {/,/^}/p" "$owner"; }

grep -Fq 'omarchy-profile-child && CHILD_INSTALL=true' "$owner" ||
  fail "provisioning reads the child profile from the marker"
pass "first-boot provisioning keys on the child profile"

user_form=$(section user_form)
[[ $user_form == *'omarchy_prompt_password kid || return $?'* ]] || fail "the child form asks for the kid password in kid mode"
[[ $user_form == *'omarchy_prompt_parent_password || return $?'* ]] || fail "the child form asks for the parent password"
[[ $user_form == *'omarchy_prompt_password || return $?'* ]] || fail "a default install still asks for its one password"
[[ $user_form != *omarchy_prompt_identity* ]] || fail "the form asks nobody for a name or an email any more"
pass "the user form asks for both passwords on a child install"

confirm=$(section confirm_form)
[[ $confirm != *'${#password}'* ]] || fail "the summary no longer masks by password length"
[[ $confirm == *'Parent password,$mask'* ]] || fail "the summary shows a parent password row on a child install"
[[ $confirm == *'${parent_row}Hostname,'* ]] || fail "the parent password row sits above the hostname"
pass "the summary masks both passwords at a fixed width"

create=$(section create_user)
[[ $create == *"printf '%s:%s\\n' root \"\$parent_password\" | chpasswd"* ]] || fail "root gets the parent password on a child install"
[[ $create == *"printf '%s:%s\\n' root \"\$password\" | chpasswd"* ]] || fail "root keeps the one password on a default install"
[[ $create == *"printf '%s:%s\\n' \"\$username\" \"\$password\" | chpasswd"* ]] || fail "the account gets the kid password"
[[ $create == *'omarchy-parent apply --user "$username"'* ]] || fail "create_user applies the parental posture"
[[ $create == *'useradd -m ${groups:+-G "$groups"}'* ]] || fail "useradd tolerates an empty group list"
[[ $create == *$'if [[ -n $groups ]]; then\n      usermod -aG "$groups" "$username"'* ]] || fail "usermod runs only with a group list to add"
pass "create_user keeps root for the parent and applies the posture"

rekey=$(section rekey_luks)
[[ $rekey == *$'local -a extra_passwords\n  rekey_extra_passwords\n  luks_rekey "$device"'* ]] || fail "rekey_luks hands the parent password to the shared re-key as a slot to keep"
extras=$(section rekey_extra_passwords)
[[ $extras == *'extra_passwords=("$parent_password")'* ]] || fail "the extra passwords are the parent's"
[[ $extras == *'if ${CHILD_INSTALL:-false}; then'* ]] || fail "the disk is keyed to the parent only on a child install"
accepts=$(section rekey_accepts_password)
[[ $accepts == *$'rekey_extra_passwords\n  luks_rekey_accepts_password "$device"'* ]] || fail "the password check before the accounts change covers the parent password"
helper="$ROOT/install/provisioning/luks-rekey.sh"
grep -Fq '[[ -n $(luks_slot_for "$extra" "$device") ]] || return 1' "$helper" || fail "the shared re-key refuses a changed extra password once the staged key is retired"
grep -Fq 'Enter the same kid and parent passwords.' "$owner" || fail "a child install's refusal names both passwords"
grep -Fq 'rekey_state_put owner_slot "$owner" extra_slots "$kept" phase owner' "$helper" || fail "the shared re-key journals the extra slots it keeps"
grep -Fq '[[ $slot == "$owner" || " $extras " == *" $slot "* ]] && continue' "$helper" || fail "the shared re-key retires every slot but the ones it keeps"
grep -Fq 'luks_record_slots "$(rekey_state_get owner_slot)" "${extras_kept%% *}"' "$helper" || fail "the shared re-key records the parent slot as the second kept slot"
pass "rekey_luks keys the disk to the kid and parent passwords and keeps both"
