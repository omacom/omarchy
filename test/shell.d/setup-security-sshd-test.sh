#!/bin/bash

# The user-facing SSH setup: key collection and the account's own
# authorized_keys, then one sudo -N call to the fixed root machine phase.
# The machine phase itself is exercised in sshd-key-only-migration-test.sh.

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
stub="$tmp/bin"
mkdir "$stub"
test_uid=$(id -u)

cat >"$stub/id" <<'SH'
#!/bin/bash
case ${1:-} in
-u) printf '%s\n' "$TEST_UID" ;;
*) exit 2 ;;
esac
SH
cat >"$stub/getent" <<'SH'
#!/bin/bash
[[ ${1:-} == passwd && ${2:-} == "$TEST_UID" ]] || exit 2
printf '%s:x:%s:100:Audit Test:%s:/bin/bash\n' "${TEST_ACCOUNT:-audit}" "$TEST_UID" "$HOME"
SH
cat >"$stub/curl" <<'SH'
#!/bin/bash
echo github-fetch >>"$EVENTS"
[[ ${GH_FAIL:-0} != 1 ]] || exit 1
printf %s "${GH_KEYS:-}"
SH
cat >"$stub/gum" <<'SH'
#!/bin/bash
case $1 in choose) printf '%s\n' "${GUM_CHOICE:-}" ;; input) [[ ${GUM_CANCEL:-0} != 1 ]] && printf '%s\n' "${GUM_INPUT:-}" ;; esac
SH
# The key import's replacement of authorized_keys; KEYS_SIGNAL delivers TERM
# to setup the moment the replacement has happened, before it is committed.
cat >"$stub/mv" <<'SH'
#!/bin/bash
[[ ${MV_FAIL:-0} != 1 || ${*: -1} != */authorized_keys ]] || exit 1
/usr/bin/mv "$@" || exit
[[ ${*: -1} != */authorized_keys ]] || { echo authorized-key >>"$EVENTS"; [[ ${KEYS_SIGNAL:-0} != 1 ]] || kill -TERM "$PPID"; }
SH
# sudo records every call and its separate arguments. The machine phase
# stand-in only reports ROOT_STATUS; ROOT_SIGNAL signals setup while it runs.
cat >"$stub/sudo" <<'SH'
#!/bin/bash
if [[ ${1:-} == -h ]]; then
  if [[ ${SUDO_NO_N:-0} == 1 ]]; then echo 'usage: sudo [-ABbEHnPS] [-C num] command'; else echo 'usage: sudo [-ABbEHnNPS] [-C num] command'; fi
  exit 0
fi
echo "sudo $*" >>"$EVENTS"
printf '%s\0' "$@" >>"$STATE/sudo.args"
[[ ${ROOT_SIGNAL:-0} != 1 ]] || kill -TERM "$PPID"
exit "${ROOT_STATUS:-0}"
SH
chmod +x "$stub"/*

mapped_root="$tmp/omarchy"
mkdir -p "$mapped_root/bin"
sed "s#/usr/bin/sudo#$stub/sudo#g" "$ROOT/bin/omarchy-security-functions" >"$mapped_root/bin/omarchy-security-functions"
cp "$ROOT/bin/omarchy-sshd-functions" "$mapped_root/bin/omarchy-sshd-functions"
mapped_sshd="$mapped_root/bin/omarchy-setup-security-sshd"
sed \
  -e "s#/usr/bin/getent#$stub/getent#g" \
  -e "s#/usr/bin/id#$stub/id#g" \
  -e "s#/usr/bin/sudo#$stub/sudo#g" \
  -e "s#/usr/bin/curl#$stub/curl#g" \
  -e "s#/usr/bin/gum#$stub/gum#g" \
  -e "s#/usr/bin/mv#$stub/mv#g" \
  "$ROOT/bin/omarchy-setup-security-sshd" >"$mapped_sshd"
chmod 0755 "$mapped_root/bin/"*

ssh-keygen -q -t ed25519 -N '' -f "$tmp/key"
key=$(<"$tmp/key.pub")
ssh-keygen -q -t ed25519 -N '' -f "$tmp/key2"
key2=$(<"$tmp/key2.pub")

run() {
  local name=$1; shift; local d="$tmp/$name"
  mkdir -p "$d/home" "$d/state"
  : >"$d/events"
  env HOME="$d/home" PATH="$stub:/usr/bin" OMARCHY_PATH="$mapped_root" STATE="$d/state" EVENTS="$d/events" USER=audit TEST_UID="$test_uid" \
    GH_FAIL="${GH_FAIL:-0}" GH_KEYS="${GH_KEYS:-}" GUM_CHOICE="${GUM_CHOICE:-}" GUM_INPUT="${GUM_INPUT:-}" GUM_CANCEL="${GUM_CANCEL:-0}" \
    MV_FAIL="${MV_FAIL:-0}" KEYS_SIGNAL="${KEYS_SIGNAL:-0}" SUDO_NO_N="${SUDO_NO_N:-0}" ROOT_STATUS="${ROOT_STATUS:-0}" ROOT_SIGNAL="${ROOT_SIGNAL:-0}" \
    "$mapped_sshd" "$@"
}
no_privilege() { ! grep -q '^sudo ' "$tmp/$1/events" || fail "$1 reached the machine phase" "$(cat "$tmp/$1/events")"; }
sudo_args() { local -a args; mapfile -d '' -t args <"$tmp/$1/state/sudo.args"; printf '%s\n' "${args[@]}"; }

for c in help unknown gh both; do case $c in help) a=(--help); want=0;; unknown) a=(--bad); want=2;; gh) a=(--gh-keys); want=2;; both) a=("--key=$key" --gh-keys x); want=2;; esac; if run "arg-$c" "${a[@]}" >/dev/null 2>&1; then s=0; else s=$?; fi; [[ $s == $want && ! -s $tmp/arg-$c/events ]] || fail "argument $c mutated"; done
pass "SSH arguments and help are mutation-free"

for c in gh-fail gh-empty gh-invalid prompt-cancel prompt-invalid home-symlink home-writable auth-symlink auth-dir no-update; do
  a=("--key=$key")
  case $c in gh-fail) GH_FAIL=1; a=(--gh-keys x);; gh-empty) GH_KEYS=''; a=(--gh-keys x);; gh-invalid) GH_KEYS=bad; a=(--gh-keys x);; prompt-cancel) GUM_CHOICE='Paste key manually'; GUM_CANCEL=1; a=();; prompt-invalid) GUM_CHOICE='Paste key manually'; GUM_INPUT=bad; a=();; home-symlink) mkdir -p "$tmp/$c/real-home"; ln -s "$tmp/$c/real-home" "$tmp/$c/home";; home-writable) mkdir -p "$tmp/$c/home"; chmod 0777 "$tmp/$c/home";; auth-symlink) mkdir -p "$tmp/$c/home/.ssh"; ln -s "$tmp/victim" "$tmp/$c/home/.ssh/authorized_keys";; auth-dir) mkdir -p "$tmp/$c/home/.ssh/authorized_keys";; no-update) SUDO_NO_N=1;; esac
  if run "$c" "${a[@]}" >/dev/null 2>&1; then fail "$c succeeds"; fi
  no_privilege "$c"; [[ ! -f $tmp/$c/home/.ssh/authorized_keys ]] || fail "$c authorized a key"
  unset GH_FAIL GH_KEYS GUM_CHOICE GUM_CANCEL GUM_INPUT SUDO_NO_N
done
[[ ! -e $tmp/victim ]] || fail "a symlinked authorized_keys was followed"
n=0
for opt in 'cert-authority' 'command="false"' 'from="!*,*"' 'expiry-time="20200101"' 'restrict' 'no-pty'; do
  n=$((n+1))
  if run "restricted-$n" "--key=$opt $key" >/dev/null 2>&1; then fail "restricted key accepted: $opt"; fi
  no_privilege "restricted-$n"; [[ ! -e $tmp/restricted-$n/home/.ssh/authorized_keys ]] || fail "restricted key was authorized: $opt"
done
pass "unusable keys, homes or sudo stop setup before any key import or privilege"

# One privileged call, sudo -N to the fixed machine phase with the account's
# UID and each key as its own argument; no sudo -k and nothing else.
run fresh "--key=$key" >"$tmp/fresh.out" || fail "a valid setup failed" "$(cat "$tmp/fresh.out")"
[[ $(grep -c '^sudo ' "$tmp/fresh/events") == 1 ]] || fail "setup made other than one privileged call" "$(cat "$tmp/fresh/events")"
expected=$(printf '%s\n' -N -- /usr/bin/omarchy-migrate-sshd-key-only --setup "$test_uid" -- "$key")
[[ $(sudo_args fresh) == "$expected" ]] || fail "setup did not call the machine phase through sudo -N with its UID and key" "$(sudo_args fresh)"
grep -qxF "$key" "$tmp/fresh/home/.ssh/authorized_keys" || fail "setup did not authorize the key"
[[ $(stat -c %a "$tmp/fresh/home/.ssh/authorized_keys") == 600 && $(stat -c %a "$tmp/fresh/home/.ssh") == 700 ]] || fail "authorized_keys or .ssh have the wrong mode"
n=$(grep -n authorized-key "$tmp/fresh/events" | cut -d: -f1); r=$(grep -n '^sudo ' "$tmp/fresh/events" | cut -d: -f1)
(( n < r )) || fail "the machine phase ran before the keys were authorized"
! compgen -G "$tmp/fresh/home/.ssh/.authorized_keys*" >/dev/null || fail "setup left key-import temporaries behind"
GH_KEYS="$key
bad
$key2" run github --gh-keys x >/dev/null 2>&1 || fail "a GitHub import failed"
expected=$(printf '%s\n' -N -- /usr/bin/omarchy-migrate-sshd-key-only --setup "$test_uid" -- "$key" "$key2")
[[ $(sudo_args github) == "$expected" ]] || fail "GitHub keys did not reach the machine phase as separate arguments" "$(sudo_args github)"
! grep -q '^bad$' "$tmp/github/home/.ssh/authorized_keys" || fail "an invalid GitHub line was authorized"
run flags "--key=no-agent-forwarding,no-port-forwarding $key" >/dev/null || fail "flag-only options that keep the login usable were refused"
! grep -Eq '/usr/bin/sudo +-k|sudo -k' "$ROOT/bin/omarchy-setup-security-sshd" || fail "setup still revokes a timestamp it never creates"
pass "setup authorizes the keys first, then makes exactly one sudo -N call to the fixed machine phase"

# An existing file keeps its lines, gains only the missing key, and is
# replaced atomically.
name=existing; mkdir -p "$tmp/$name/home/.ssh"; chmod 0700 "$tmp/$name/home/.ssh"; printf '# mine\n%s\n' "$key2" >"$tmp/$name/home/.ssh/authorized_keys"; chmod 0600 "$tmp/$name/home/.ssh/authorized_keys"
run "$name" "--key=$key" >/dev/null || fail "setup with an existing authorized_keys failed"
[[ $(<"$tmp/$name/home/.ssh/authorized_keys") == "$(printf '# mine\n%s\n%s' "$key2" "$key")" ]] || fail "setup changed existing authorized keys" "$(cat "$tmp/$name/home/.ssh/authorized_keys")"
run "$name" "--key=$key" >"$tmp/$name.again" || fail "a repeated setup failed"
[[ $(grep -cxF "$key" "$tmp/$name/home/.ssh/authorized_keys") == 1 ]] || fail "a repeated setup duplicated the key"
pass "an existing authorized_keys keeps its content and gains only the new key"

# Until the replacement is committed, a failure or signal restores the
# previous file exactly, or removes one that did not exist.
for pre in present absent; do
  name="keys-signal-$pre"; mkdir -p "$tmp/$name/home/.ssh"; chmod 0700 "$tmp/$name/home/.ssh"
  if [[ $pre == present ]]; then printf '# mine\n%s\n' "$key2" >"$tmp/$name/home/.ssh/authorized_keys"; chmod 0640 "$tmp/$name/home/.ssh/authorized_keys"; before=$(stat -c '%a %s' "$tmp/$name/home/.ssh/authorized_keys"; cat "$tmp/$name/home/.ssh/authorized_keys"); fi
  if KEYS_SIGNAL=1 run "$name" "--key=$key" >/dev/null 2>&1; then fail "setup interrupted during its key import reported success"; fi
  no_privilege "$name"
  if [[ $pre == present ]]; then
    [[ $(stat -c '%a %s' "$tmp/$name/home/.ssh/authorized_keys"; cat "$tmp/$name/home/.ssh/authorized_keys") == "$before" ]] || fail "an interrupted key import did not restore authorized_keys exactly"
  else
    [[ ! -e $tmp/$name/home/.ssh/authorized_keys ]] || fail "an interrupted key import left a new authorized_keys"
  fi
  ! compgen -G "$tmp/$name/home/.ssh/.authorized_keys*" >/dev/null || fail "an interrupted key import left temporaries behind"
done
name=keys-fail; mkdir -p "$tmp/$name/home/.ssh"; chmod 0700 "$tmp/$name/home/.ssh"; echo "$key2" >"$tmp/$name/home/.ssh/authorized_keys"
if MV_FAIL=1 run "$name" "--key=$key" >/dev/null 2>&1; then fail "a failed key import reported success"; fi
no_privilege "$name"; [[ $(<"$tmp/$name/home/.ssh/authorized_keys") == "$key2" ]] || fail "a failed key import changed authorized_keys"
# Imports are serialized: while another holds the account's import lock,
# setup refuses without touching anything.
name=keys-locked; mkdir -p "$tmp/$name/home/.ssh"; chmod 0700 "$tmp/$name/home/.ssh"; : >"$tmp/$name/home/.ssh/.omarchy-authorized-keys.lock"
exec {held}<"$tmp/$name/home/.ssh/.omarchy-authorized-keys.lock"; flock -n "$held"
if run "$name" "--key=$key" >"$tmp/$name.out" 2>&1; then fail "setup imported keys while another import held the lock"; fi
exec {held}<&-
no_privilege "$name"; [[ ! -e $tmp/$name/home/.ssh/authorized_keys ]] || fail "a locked-out import wrote authorized_keys"
grep -q 'Another Omarchy SSH key import is running' "$tmp/$name.out" || fail "a locked-out import did not say why" "$(cat "$tmp/$name.out")"
run "$name" "--key=$key" >/dev/null || fail "setup failed once the import lock was free"
pass "the key import is atomic, restores the previous file until it commits, and is serialized"

# Once committed, the keys stay whatever the machine phase does: its failure,
# or a signal to setup while it runs, is no proof they are no longer needed,
# and setup does not claim the server is unchanged.
for c in root-fail root-signal; do
  if [[ $c == root-fail ]]; then ROOT_STATUS=1; else ROOT_SIGNAL=1; fi
  if run "$c" "--key=$key" >"$tmp/$c.out" 2>&1; then fail "$c reported success"; fi
  unset ROOT_STATUS ROOT_SIGNAL
  grep -qxF "$key" "$tmp/$c/home/.ssh/authorized_keys" || fail "$c removed the committed key"
  [[ $(grep -c '^sudo ' "$tmp/$c/events") == 1 ]] || fail "$c made further privileged calls" "$(cat "$tmp/$c/events")"
done
grep -q 'Your keys remain authorized' "$tmp/root-fail.out" && grep -q 'do not assume the server is unchanged' "$tmp/root-fail.out" ||
  fail "a failed machine phase was not reported as such" "$(cat "$tmp/root-fail.out")"
pass "a failed or interrupted machine phase keeps the committed keys and claims nothing about the server"
