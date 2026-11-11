#!/bin/bash
#
# Who may change what. The parent's controls in the bar take the password of
# any account in wheel, through the same check a child's lock screen uses
# (omarchy-user-functions' users_adult_check), so the two share one count of
# wrong guesses; the child's own password does not open them. Agreement mode
# needs no password. The control command acts only on the account sudo says
# is calling, never on one in an argument.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command perl

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

export OMARCHY_SCREEN_TIME_ETC="$tmp_dir/etc"
export OMARCHY_SCREEN_TIME_STATE="$tmp_dir/state"
export OMARCHY_SCREEN_TIME_RUN="$tmp_dir/run"
mkdir -p "$OMARCHY_SCREEN_TIME_ETC" "$OMARCHY_SCREEN_TIME_STATE" "$OMARCHY_SCREEN_TIME_RUN" "$tmp_dir/bin"

# A household in fixtures: two adults in wheel, kid in omarchy-child, and a
# guest in neither. Nothing here reads the real account database.
hash_of() { printf '%s' "$1" | perl -e 'local $/; my $p = <STDIN>; print crypt($p, q($6$fixture$))'; }
{
  echo "mom:x:1001:1001::/home/mom:/bin/bash"
  echo "dad:x:1002:1002::/home/dad:/bin/bash"
  echo "kid:x:1003:1003::/home/kid:/bin/bash"
  echo "guest:x:1004:1004::/home/guest:/bin/bash"
} >"$tmp_dir/passwd"
printf 'wheel:x:998:mom,dad\nomarchy-child:x:900:kid\n' >"$tmp_dir/group"
{
  echo "mom:$(hash_of 'blue kettle'):19000::::::"
  echo "dad:$(hash_of 'Søndag 7!'):19000::::::"
  echo "kid:$(hash_of 'kid-secret'):19000::::::"
  echo "guest:$(hash_of 'guest-pass'):19000::::::"
} >"$tmp_dir/shadow"

cat >"$tmp_dir/bin/getent" <<'SH'
#!/bin/bash
file=$TEST_TMP/$1
if [[ -n ${2:-} ]]; then
  awk -F: -v key="$2" '$1 == key || $3 == key { print; found = 1; exit } END { exit !found }' "$file"
else
  cat "$file"
fi
SH
cat >"$tmp_dir/bin/id" <<'SH'
#!/bin/bash
flag=$1
[[ ${2:-} == "--" ]] && shift
entry=$(awk -F: -v key="$2" '$1 == key || $3 == key { print; exit }' "$TEST_TMP/passwd")
[[ -n $entry ]] || exit 1
IFS=: read -r name _ uid _ <<<"$entry"
case $flag in
  -u) echo "$uid" ;;
  -un) echo "$name" ;;
  -nG) { echo "$name"; awk -F: -v user="$name" '{ n = split($4, m, ","); for (i = 1; i <= n; i++) if (m[i] == user) print $1 }' "$TEST_TMP/group"; } | paste -sd' ' - ;;
esac
SH
printf '#!/bin/bash\n' >"$tmp_dir/bin/logger"
chmod +x "$tmp_dir/bin/"*

export TEST_TMP=$tmp_dir USERS_SHADOW=$tmp_dir/shadow USERS_RATE_DIR=$tmp_dir/rate USERS_REFUSAL_DELAY=0
PATH="$tmp_dir/bin:$ROOT/bin:$PATH"
source omarchy-screen-time-lib

# A config with kid under a profile, so ctl will act for them.
write_config() {
  st_jq -n --arg philosophy "$1" '
    default_config | .active_profile = "kids" |
    .profiles = {kids: (default_profile | .name = "Kids" | .philosophy = $philosophy)} |
    .users = {kid: {profile: "kids"}}' | st_save_config
}
write_config limits

# ctl acts as the caller sudo names; the test sets it, sudo sets it from SUDO_UID.
ctl() { OMARCHY_SCREEN_TIME_CALLER=1003 bash "$ROOT/bin/omarchy-screen-time-ctl" "$@" || true; }
guesses=$tmp_dir/rate/adult-check-1003
forget_guesses() { rm -f "$guesses"; }
let_wait_pass() { [[ -f $guesses ]] && read -r count _ <"$guesses" && printf '%s 0\n' "$count" >"$guesses"; }

# --- the control command's own guards ---------------------------------------

grep -Fq '%omarchy-screen-time ALL=(root) NOPASSWD:' "$ROOT/etc/sudoers.d/omarchy-screen-time" ||
  fail "the sudoers grant is for the screen-time group and the ctl command only"
pass "the sudoers grant lets the group reach the control command without a password"

reply=$(printf 'blue kettle\n' | OMARCHY_SCREEN_TIME_CALLER=1004 bash "$ROOT/bin/omarchy-screen-time-ctl" grant 15 2>/dev/null || true)
[[ $(jq -r .error <<<"$reply") == not_managed ]] || fail "an account outside the roster is refused" "got: $reply"
pass "the control command refuses an account that is not in the roster"

# --- whose password ----------------------------------------------------------

reply=$(printf 'Søndag 7!\n' | ctl grant 15)
[[ $(jq -r .ok <<<"$reply") == true ]] || fail "an adult's password hands out minutes" "got: $reply"
[[ $(jq -r .granted_seconds <<<"$reply") == 900 ]] || fail "fifteen minutes is nine hundred seconds"
[[ ! -f $guesses ]] || fail "a right password leaves no count behind"
reply=$(printf 'blue kettle\n' | ctl pause)
[[ $(jq -r .ok <<<"$reply") == true ]] || fail "any adult's password will do" "got: $reply"
pass "a grown-up's password, any grown-up's, unlocks a parent action"

reply=$(printf 'kid-secret\n' | ctl grant 15)
[[ $(jq -r .error <<<"$reply") == bad_password ]] || fail "the child's own password does not open the controls" "got: $reply"
reply=$(printf 'guest-pass\n' | ctl resume)
[[ $(jq -r .error <<<"$reply") == bad_password ]] || fail "an account outside wheel does not open them either" "got: $reply"
reply=$(printf '\n' | ctl resume)
[[ $(jq -r .error <<<"$reply") == bad_password ]] || fail "no password is nobody's" "got: $reply"
pass "the child's own password, anyone else's outside wheel, or none, is refused"

# --- wrong guesses, shared with the lock screen -----------------------------

forget_guesses
for i in 1 2 3 4 5; do printf 'nope\n' | ctl grant 5 >/dev/null; done
locked=$(printf 'blue kettle\n' | ctl grant 5)
[[ $(jq -r .error <<<"$locked") == locked_out ]] || fail "five wrong guesses lock out even the right password" "got: $locked"
(($(jq -r .retry_in_seconds <<<"$locked") >= 100)) || fail "the lockout says how long to wait" "got: $locked"
pass "five wrong passwords lock the controls out, for the right one too, and say for how long"

let_wait_pass
reply=$(printf 'blue kettle\n' | ctl grant 5)
[[ $(jq -r .ok <<<"$reply") == true ]] || fail "once the wait is over the right password works" "got: $reply"
[[ ! -f $guesses ]] || fail "and it clears the count"
pass "once the wait is over a right password works and clears the count"

# The lock screen's check and the controls' are one count: guesses at the lock
# screen cost the controls too.
forget_guesses
(
  source omarchy-user-functions
  for i in 1 2 3 4 5; do users_adult_check kid "nope$i" 2>/dev/null || true; done
)
reply=$(printf 'blue kettle\n' | ctl grant 5)
[[ $(jq -r .error <<<"$reply") == locked_out ]] || fail "wrong guesses at the lock screen lock the controls out too" "got: $reply"
pass "the lock screen and the controls share one count of wrong guesses"

# Guesses fired at once queue on the check's lock: every one is counted.
forget_guesses
for i in 1 2 3 4; do
  (printf 'nope\n' | ctl grant 5 >"$tmp_dir/burst.$i") &
done
wait
read -r counted _ <"$guesses"
((counted == 4)) || fail "a burst of guesses is counted one by one" "counted $counted"
pass "parallel guesses queue and are each counted"

# --- agreement mode -------------------------------------------------------------

forget_guesses
write_config together
reply=$(printf '\n' | ctl pause)
[[ $(jq -r .ok <<<"$reply") == true ]] || fail "agreement mode pauses without a password" "got: $reply"
reply=$({ printf '\n'; printf '{"agreement_minutes": 60}'; } | ctl config patch)
[[ $(jq -r .ok <<<"$reply") == true ]] || fail "agreement mode edits its own profile without a password" "got: $reply"
reply=$({ printf '\n'; printf '{"profiles": {}}'; } | ctl config set)
[[ $(jq -r .error <<<"$reply") == bad_password ]] || fail "replacing every profile still takes a password" "got: $reply"
pass "agreement mode needs no password, except to replace every profile"

# --- the web allowlist ------------------------------------------------------------

write_config limits
forget_guesses
export OMARCHY_WEB_ALLOWLIST_DIR=$tmp_dir/web OMARCHY_WEB_ALLOWLIST_APPLY=$tmp_dir/bin/web-apply OMARCHY_WEB_ALLOWLIST_STARTER=$ROOT/default/omarchy/web-allowlist-starter
printf '#!/bin/bash\necho applied >>"$TEST_TMP/web-applied"\n' >"$tmp_dir/bin/web-apply"
chmod +x "$tmp_dir/bin/web-apply"

reply=$(ctl web get </dev/null)
[[ $reply == '{"ok":true,"enabled":false,"domains":[]}' ]] || fail "a child reads their allowlist, off and empty, without a password" "got: $reply"
reply=$({ printf 'kid-secret\n'; printf '{"enabled": false, "domains": []}'; } | ctl web set)
[[ $(jq -r .error <<<"$reply") == bad_password ]] || fail "the child can't change their allowlist" "got: $reply"
[[ ! -e $tmp_dir/web-applied ]] || fail "a refused change applies nothing"
pass "a child reads their web allowlist, and only a grown-up's password changes it"

reply=$({ printf 'blue kettle\n'; printf '{"enabled": true, "domains": []}'; } | ctl web set)
[[ $(jq -r .enabled <<<"$reply") == true ]] || fail "a grown-up turns the allowlist on" "got: $reply"
[[ $(jq -r '.domains | index("khanacademy.org") != null' <<<"$reply") == true ]] || fail "turned on empty, it starts from the shipped sites" "got: $reply"
[[ $(head -1 "$tmp_dir/web/kid") == "on" && $(stat -c %a "$tmp_dir/web/kid") == "644" ]] || fail "the list is written where the apply step reads it"
reply=$({ printf 'blue kettle\n'; printf '{"enabled": true, "domains": ["Scratch.MIT.edu", "not a domain", "evil.com/x", "scratch.mit.edu"]}'; } | ctl web set)
[[ $(jq -c .domains <<<"$reply") == '["scratch.mit.edu"]' ]] || fail "only valid domains are kept, lowercased, once each" "got: $reply"
[[ $(wc -l <"$tmp_dir/web-applied") == 2 ]] || fail "every change is applied"
reply=$({ printf 'blue kettle\n'; printf '{"enabled": false, "domains": ["scratch.mit.edu"]}'; } | ctl web set)
[[ $(head -1 "$tmp_dir/web/kid") == "off" && $(jq -r .enabled <<<"$reply") == false ]] || fail "a grown-up turns it off and keeps the list" "got: $reply"
pass "a grown-up turns the allowlist on, starting from the shipped sites, keeps only real domains, and turns it off again"

# A patch let through without a password in agreement mode, held open while a
# grown-up switches the profile to limits, is refused when it lands.
write_config together
fifo=$tmp_dir/held
mkfifo "$fifo"
ctl config patch <"$fifo" >"$tmp_dir/held.out" &
held=$!
exec {hold}>"$fifo"
printf '\n' >&$hold
sleep 1
write_config limits
printf '{"philosophy": "together"}' >&$hold
exec {hold}>&-
wait "$held"
[[ $(jq -r .error "$tmp_dir/held.out") == bad_password ]] || fail "a held agreement-mode patch is refused once the profile is limits" "$(cat "$tmp_dir/held.out")"
[[ $(st_config | st_jq -r --arg u kid 'profile_for($u).profile.philosophy') == limits ]] || fail "the grown-up's switch to limits stands"
pass "a patch let in by agreement mode and held open is refused if a grown-up switched to limits meanwhile"

# The same for an action on the day: a pause let in by agreement mode and held
# open is refused once the profile is limits.
write_config together
rm -f "$fifo"; mkfifo "$fifo"
ctl pause <"$fifo" >"$tmp_dir/held.out" &
held=$!
exec {hold}>"$fifo"
sleep 1
write_config limits
printf '\n' >&$hold
exec {hold}>&-
wait "$held"
[[ $(jq -r .error "$tmp_dir/held.out") == bad_password ]] || fail "a held agreement-mode pause is refused once the profile is limits" "$(cat "$tmp_dir/held.out")"
pass "a pause let in by agreement mode and held open is refused if a grown-up switched to limits meanwhile"
