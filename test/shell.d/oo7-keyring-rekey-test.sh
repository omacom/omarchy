#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stubs="$test_tmp/stubs"
mkdir -p "$stubs"

stub() {
  printf '#!/bin/bash\n%s\n' "$2" >"$stubs/$1"
  chmod +x "$stubs/$1"
}

# A v1 keyring here is a file holding "key=<secret>". session-gone stands for an update
# without a desktop session. A gnome-keyring file's password sits in ~/.passwords/<name>.
stub systemctl "[[ \$* != *is-active*default.target* || ! -e $test_tmp/session-gone ]]"
stub systemd-creds "printf SEALED"
# The daemon, as in oo7 0.7.3. A converted keyring opens with the secret its file is
# keyed to, and ChangeWithMasterPassword re-keys it given that secret. A gnome-keyring
# file it hasn't converted is converted, and stamped, by either call given its password,
# and a wrong one is refused.
cat >"$stubs/python3" <<'STUB'
#!/bin/bash
dir=$HOME/.local/share/keyrings v1=$HOME/.local/share/keyrings/v1
# Converts the gnome-keyring file of collection $1 if $2 is its password.
convert() {
  [[ -f $dir/$1.keyring && ! -e $dir/$1.keyring.migrated && $2 == "$(<"$HOME/.passwords/$1")" ]] || return 1
  mkdir -p "$v1"
  echo "key=$2" >"$v1/$1.keyring"
  touch "$dir/$1.keyring.migrated"
}
case $3 in
collections)
  for f in "$v1"/*.keyring; do
    [[ -f $f ]] && echo "/org/freedesktop/secrets/collection/$(basename "$f" .keyring)"
  done
  for f in "$dir"/*.keyring; do
    [[ -f $f && ! -e $f.migrated && ! -e $v1/${f##*/} && $(head -c 12 "$f") == GnomeKeyring ]] &&
      echo "/org/freedesktop/secrets/collection/$(basename "$f" .keyring)"
  done
  ;;
opens)
  name=${4##*/} secret=$(cat)
  [[ -e $v1/$name.keyring ]] || convert "$name" "$secret" || exit 1
  [[ $(<"$v1/$name.keyring") == "key=$secret" ]]
  ;;
change)
  IFS= read -rd '' old || true; IFS= read -rd '' new || true
  name=${4##*/}
  [[ -e $v1/$name.keyring ]] || convert "$name" "$old" || exit 1
  [[ $(<"$v1/$name.keyring") == "key=$old" ]] || exit 1
  echo "key=$new" >"$v1/$name.keyring"
  ;;
esac
STUB
chmod +x "$stubs/python3"

new_home() {
  local home="$test_tmp/$1"
  mkdir -p "$home/.local/share/keyrings" "$home/.config/credstore.encrypted"
  echo sealed >"$home/.config/credstore.encrypted/oo7.keyring-encryption-password"
  echo "$home"
}

# An encrypted gnome-keyring file, with the password that opens it.
encrypted_keyring() {
  mkdir -p "$1/.passwords"
  printf 'GnomeKeyring\n\r\0\n' >"$1/.local/share/keyrings/$2.keyring"
  echo "$3" >"$1/.passwords/$2"
}

# Runs the command in a terminal, typing the given lines at its prompts.
run_rekey() {
  local home=$1
  shift
  printf '%s\n' "$@" | env -i HOME="$home" PATH="$stubs:/usr/bin" TERM=dumb \
    script -qec "$ROOT/bin/omarchy-keyring-rekey" /dev/null
}

keyed() { [[ $(<"$1/.local/share/keyrings/v1/$2.keyring") == "key=SEALED" ]]; }

# Encrypted keyrings are converted with the typed password and re-keyed to the
# credential. A password typed once is tried on the next keyring before asking, and a
# wrong one is asked again.
home=$(new_home converts)
encrypted_keyring "$home" login secret-a
encrypted_keyring "$home" work secret-a
encrypted_keyring "$home" other secret-b
echo "[keyring]" >"$home/.local/share/keyrings/Plain.keyring"
output=$(run_rekey "$home" wrong secret-a secret-b) || fail "rekey succeeds: $output"
for name in login work other; do
  keyed "$home" "$name" || fail "$name is keyed to the credential"
done
[[ ! -e $home/.local/share/keyrings/v1/Plain.keyring ]] || fail "a plain keyring is left to oo7"
(( $(grep -c 'Password for the keyring' <<<"$output") == 3 )) || fail "asks again after a wrong password, and only for a new one: $output"
pass "rekey converts encrypted keyrings and keys them to the credential"

# A keyring already converted with its own password, by an unlock prompt, is re-keyed too.
home=$(new_home prompted)
mkdir -p "$home/.local/share/keyrings/v1"
echo "key=typed" >"$home/.local/share/keyrings/v1/login.keyring"
run_rekey "$home" typed >/dev/null || fail "rekey succeeds on a converted keyring"
keyed "$home" login || fail "a keyring converted by a prompt is keyed to the credential"
pass "rekey re-keys a keyring converted with its own password"

# A keyring already keyed to the credential isn't asked about.
home=$(new_home sealed)
mkdir -p "$home/.local/share/keyrings/v1"
echo "key=SEALED" >"$home/.local/share/keyrings/v1/login.keyring"
output=$(run_rekey "$home") || fail "rekey succeeds when there's nothing to re-key"
! grep -q 'Password' <<<"$output" || fail "no password is asked for a keyring that opens with the credential: $output"
pass "rekey leaves keyrings keyed to the credential alone"

# An empty answer skips the keyring: it isn't converted or re-keyed, and the user is told.
home=$(new_home skip)
encrypted_keyring "$home" login secret-a
encrypted_keyring "$home" other secret-b
output=$(run_rekey "$home" secret-a "") || fail "rekey succeeds when a keyring is skipped"
keyed "$home" login || fail "the keyring that wasn't skipped is keyed to the credential"
[[ ! -e $home/.local/share/keyrings/v1/other.keyring ]] || fail "a skipped keyring isn't converted or replaced by an empty one"
[[ ! -e $home/.local/share/keyrings/other.keyring.migrated ]] || fail "a skipped keyring isn't stamped"
grep -q 'Skipped.*other' <<<"$output" || fail "the skip is reported: $output"
pass "rekey skips a keyring on an empty answer"

# Without a desktop session nothing is converted: it names the keyrings and fails, so
# the caller can say so, and stays quiet when there's nothing to do.
home=$(new_home no-session)
touch "$test_tmp/session-gone"
run_rekey "$home" >/dev/null || fail "nothing to re-key isn't an error"
encrypted_keyring "$home" login secret-a
if output=$(run_rekey "$home" secret-a); then
  fail "rekey without a session fails"
fi
grep -q 'login' <<<"$output" || fail "the waiting keyrings are named: $output"
[[ ! -e $home/.local/share/keyrings/v1/login.keyring ]] || fail "nothing is converted without a session"
rm "$test_tmp/session-gone"
pass "rekey waits for a session"
