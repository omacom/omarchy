#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# omarchy-system-login writes greetd's configuration: the user the login screen
# signs in and whether autologin starts their session.

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

tree="$test_tmp/root"
config="$tree/etc/greetd/config.toml"
splash=/usr/share/omarchy/default/splash

new_tree() {
  rm -rf "$tree"
  mkdir -p "$tree/etc/sddm.conf.d" "$tree/var/lib/sddm"
  printf 'root:x:0:0::/root:/bin/bash\nalice:x:1000:1000::/home/alice:/bin/bash\n' >"$tree/etc/passwd"
}

login() {
  "$ROOT/bin/omarchy-system-login" --root "$tree" "$@"
}

# The user the login screen names and the one autologin starts, "-" for none.
greeter_user() {
  sed -n "s|^command = \"$splash/greeter *\\(.*\\)\"\$|\\1|p" "$config"
}
autologin_user() {
  sed -n '/^\[initial_session\]/,$ s/^user = "\(.*\)"$/\1/p' "$config"
}

assert_login() {
  local description=$1 greeter=$2 autologin=$3
  [[ $(greeter_user) == "$greeter" && $(autologin_user) == "$autologin" ]] ||
    fail "$description" "$(cat "$config")"
  pass "$description"
}

new_tree
login alice --autologin
assert_login "a user with autologin gets the login screen and the initial session" alice alice
[[ $(sed -n '/^\[initial_session\]/,$ s/^command = //p' "$config") == "\"$splash/login-session\"" ]] ||
  fail "autologin starts the Omarchy session" "$(cat "$config")"
pass "autologin starts the Omarchy session"
[[ $(sed -n '/^\[terminal\]/,/^\[/ s/^text_mode = //p' "$config") == "false" ]] ||
  fail "greetd leaves the console in the boot splash's graphics mode" "$(cat "$config")"
pass "greetd leaves the console in the boot splash's graphics mode"

# The sessions run under Omarchy's PAM service once omarchy-settings has
# installed it, and under greetd's own until then.
session_service() {
  sed -n '/^\[general\]/,/^\[/ s/^service = //p' "$config"
}
[[ -z $(session_service) ]] || fail "greetd keeps its own PAM service until Omarchy's is installed" "$(cat "$config")"
mkdir -p "$tree/etc/pam.d"
touch "$tree/etc/pam.d/omarchy-login"
login alice --autologin
[[ $(session_service) == '"omarchy-login"' ]] || fail "sessions run under Omarchy's PAM service once it is installed" "$(cat "$config")"
pass "sessions run under Omarchy's PAM service only once it is installed"

login --no-autologin
assert_login "--no-autologin keeps the user and drops the initial session" alice ""

login alice
assert_login "a user alone gets no autologin" alice ""

if login bob 2>/dev/null; then
  fail "an account that does not exist is refused"
fi
assert_login "a refused user leaves the configuration as it was" alice ""

new_tree
printf '[Autologin]\nUser=alice\nSession=omarchy.desktop\n' >"$tree/etc/sddm.conf.d/autologin.conf"
printf '[Last]\nSession=omarchy.desktop\nUser=root\n' >"$tree/var/lib/sddm/state.conf"
login --from-sddm
assert_login "SDDM's autologin user carries over with autologin" alice alice

cleanup=omarchy-provision-autologin-once.service
mkdir -p "$tree/etc/systemd/system/graphical.target.wants"
printf '[Service]\nExecStart=/usr/bin/rm -f /etc/sddm.conf.d/autologin.conf\n' >"$tree/etc/systemd/system/$cleanup"
ln -s "../$cleanup" "$tree/etc/systemd/system/graphical.target.wants/$cleanup"
login --from-sddm
assert_login "SDDM's pending one-boot autologin does not become permanent" alice ""

rm "$tree/etc/systemd/system/graphical.target.wants/$cleanup"
login --from-sddm
assert_login "a disabled one-boot cleanup does not suppress permanent autologin" alice alice

rm "$tree/etc/sddm.conf.d/autologin.conf"
printf '[Last]\nSession=omarchy.desktop\nUser=alice\n' >"$tree/var/lib/sddm/state.conf"
login --from-sddm
assert_login "SDDM's last user carries over without autologin" alice ""

printf '[Autologin]\nUser=carol\n' >"$tree/etc/sddm.conf.d/autologin.conf"
login --from-sddm
assert_login "an SDDM user whose account is gone leaves the login screen to nobody in particular" "" ""

new_tree
login --from-sddm
assert_login "nothing from SDDM leaves the login screen to nobody in particular" "" ""

login alice --autologin
login --reset
assert_login "--reset forgets the user and the autologin" "" ""
