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
# without a desktop session. A keyring's password sits in passwords/<name>.
stub systemctl "[[ \$* != *is-active*default.target* || ! -e $test_tmp/session-gone ]]"
stub systemd-creds "printf SEALED"
stub oo7-cli "[[ \$1 == --secret && \$3 == migrate ]] || exit 2
file=\$4 name=\${4##*/}; name=\${name%.keyring}
[[ \$2 == \"\$(<$test_tmp/passwords/\$name)\" ]] || exit 1
mkdir -p \"\${file%/*}/v1\"
echo \"key=\$2\" >\"\${file%/*}/v1/\$name.keyring\""
# The daemon: a collection is locked while its file isn't keyed to the credential,
# and ChangeWithMasterPassword re-keys it when given its current secret.
stub python3 "v1=\$HOME/.local/share/keyrings/v1
case \$3 in
locked)
  for f in \"\$v1\"/*.keyring; do
    [[ -f \$f && \$(<\"\$f\") != key=SEALED ]] && echo \"/org/freedesktop/secrets/collection/\$(basename \"\$f\" .keyring)\"
  done
  ;;
change)
  IFS= read -rd '' old || true; IFS= read -rd '' new || true
  f=\"\$v1/\${4##*/}.keyring\"
  [[ \$(<\"\$f\") == \"key=\$old\" ]] || exit 1
  echo \"key=\$new\" >\"\$f\"
  ;;
esac"

new_home() {
  local home="$test_tmp/$1"
  mkdir -p "$home/.local/share/keyrings" "$home/.config/credstore.encrypted"
  echo sealed >"$home/.config/credstore.encrypted/oo7.keyring-encryption-password"
  echo "$home"
}

# An encrypted gnome-keyring file, with the password that opens it.
encrypted_keyring() {
  mkdir -p "$test_tmp/passwords"
  printf 'GnomeKeyring\n\r\0\n' >"$1/.local/share/keyrings/$2.keyring"
  echo "$3" >"$test_tmp/passwords/$2"
}

# Runs the command in a terminal, typing the given lines at its prompts.
run_rekey() {
  local home=$1
  shift
  printf '%s\n' "$@" | env -i HOME="$home" PATH="$stubs:/usr/bin" TERM=dumb \
    script -qec "$ROOT/bin/omarchy-keyring-rekey" /dev/null
}

keyed() { [[ $(<"$1/.local/share/keyrings/v1/$2.keyring") == "key=SEALED" ]]; }

# Encrypted keyrings are converted with the typed password, stamped so oo7 doesn't
# load them twice, and re-keyed to the credential. A password typed once is tried
# on the next keyring before asking, and a wrong one is asked again.
home=$(new_home converts)
encrypted_keyring "$home" login secret-a
encrypted_keyring "$home" work secret-a
encrypted_keyring "$home" other secret-b
echo "[keyring]" >"$home/.local/share/keyrings/Plain.keyring"
output=$(run_rekey "$home" wrong secret-a secret-b) || fail "rekey succeeds: $output"
for name in login work other; do
  keyed "$home" "$name" || fail "$name is keyed to the credential"
  [[ -e $home/.local/share/keyrings/$name.keyring.migrated ]] || fail "$name is stamped as converted"
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

# An empty answer skips the keyring: it isn't converted or stamped, and the user is told.
home=$(new_home skip)
encrypted_keyring "$home" login secret-a
output=$(run_rekey "$home" "") || fail "rekey succeeds when a keyring is skipped"
[[ ! -e $home/.local/share/keyrings/v1/login.keyring ]] || fail "a skipped keyring isn't converted"
[[ ! -e $home/.local/share/keyrings/login.keyring.migrated ]] || fail "a skipped keyring isn't stamped"
grep -q 'Skipped.*login' <<<"$output" || fail "the skip is reported: $output"
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
