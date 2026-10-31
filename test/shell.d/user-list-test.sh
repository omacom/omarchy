#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

# getent serves the passwd and group databases from fixture files.
cat >"$mock_bin/getent" <<'SH'
#!/bin/bash
case "$1" in
passwd) if [[ -n ${2:-} ]]; then grep "^$2:" "$OMARCHY_TEST_PASSWD"; else cat "$OMARCHY_TEST_PASSWD"; fi ;;
group) grep "^$2:" "$OMARCHY_TEST_GROUP" ;;
*) exit 2 ;;
esac
SH

cat >"$mock_bin/loginctl" <<'SH'
#!/bin/bash
cat "$OMARCHY_TEST_SESSIONS"
SH

cat >"$mock_bin/lastlog2" <<'SH'
#!/bin/bash
cat "$OMARCHY_TEST_LASTLOG"
SH

chmod +x "$mock_bin"/*

cat >"$test_tmp/passwd" <<'EOF'
root:x:0:0::/root:/usr/bin/bash
alpm:x:970:970:Arch Linux Package Management:/:/usr/bin/nologin
nobody:x:65534:65534:Kernel Overflow User:/:/usr/bin/nologin
zoe:x:1002:1002::/home/zoe:/bin/bash
alice:x:1000:1000::/home/alice:/bin/bash
bob:x:1001:998::/home/bob:/usr/bin/zsh
svc:x:1003:1003::/home/svc:/usr/bin/nologin
locked:x:1004:1004::/home/locked:/bin/false
EOF

cat >"$test_tmp/group" <<'EOF'
wheel:x:998:alice
EOF

# loginctl list-users --json=short: bob lingers, with services but no session.
cat >"$test_tmp/sessions" <<'EOF'
[{"uid":1000,"user":"alice","linger":false,"state":"active"},{"uid":1001,"user":"bob","linger":true,"state":"lingering"}]
EOF

cat >"$test_tmp/lastlog" <<'EOF'
Username         Port     From                                       Latest
alice            tty1                                                Sun Oct 11 23:01:17 +0000 2026
zoe              ssh      10.0.2.2                                   Sat Oct 10 08:15:00 +0000 2026
EOF

cat >"$test_tmp/login.defs" <<'EOF'
UID_MIN			 1000
UID_MAX			60000
EOF

run_list() {
  TZ=UTC PATH="$mock_bin:$PATH" \
    OMARCHY_TEST_PASSWD="$test_tmp/passwd" OMARCHY_TEST_GROUP="$test_tmp/group" \
    OMARCHY_TEST_SESSIONS="$test_tmp/sessions" OMARCHY_TEST_LASTLOG="$test_tmp/lastlog" \
    OMARCHY_LOGIN_DEFS="$test_tmp/login.defs" OMARCHY_PATH="$ROOT" \
    "$ROOT/bin/omarchy-user-list" "$@"
}

output=$(run_list)
expected='USER                     ADMIN  SIGNED IN  LAST LOGIN
alice                    yes    yes        2026-10-11 23:01
bob                      yes    no         never
zoe                      no     no         2026-10-10 08:15'
[[ $output == "$expected" ]] || fail "the table lists login users sorted by name with admin, session and last login" "$output"
pass "the table lists login users sorted by name with admin, session and last login"

[[ $output != *root* && $output != *alpm* && $output != *nobody* ]] ||
  fail "system accounts outside the login UID range are left out" "$output"
[[ $output != *svc* && $output != *locked* ]] ||
  fail "accounts without a login shell are left out" "$output"
pass "only accounts a person can log in to are listed"

json=$(run_list --json)
jq -e '
  length == 3 and
  .[0] == {user: "alice", uid: 1000, admin: true, signed_in: true, last_login: "2026-10-11T23:01:17+00:00"} and
  .[1] == {user: "bob", uid: 1001, admin: true, signed_in: false, last_login: null} and
  .[2].admin == false
' <<<"$json" >/dev/null || fail "--json reports typed fields, with null for no login" "$json"
pass "--json reports typed fields, with null for no login"

# bob is an administrator through his primary group, not a wheel member line.
jq -e '.[] | select(.user == "bob") | .admin' <<<"$json" >/dev/null ||
  fail "a primary group of wheel counts as administrator" "$json"
pass "a primary group of wheel counts as administrator"

rm "$test_tmp/login.defs"
[[ $(run_list | wc -l) == 4 ]] || fail "missing login.defs falls back to the default UID range"
pass "missing login.defs falls back to the default UID range"

for i in $(seq 2000 2149); do
  printf 'user%s:x:%s:%s::/home/user%s:/bin/bash\n' "$i" "$i" "$i" "$i"
done >>"$test_tmp/passwd"
[[ $(run_list --json | jq length) == 153 ]] || fail "lists every account on a machine with many users"
pass "lists every account on a machine with many users"

if run_list --bogus 2>/dev/null; then
  fail "an unknown option is rejected"
fi
pass "an unknown option is rejected"
