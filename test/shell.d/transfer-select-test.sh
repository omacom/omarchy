#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

export OMARCHY_PATH=$ROOT
export HOME=$WORK/home
export XDG_RUNTIME_DIR=$WORK/run
export OMARCHY_TRANSFER_CONF=$WORK/transfer.conf
STUBS=$WORK/stubs
LOG=$WORK/log
mkdir -p "$HOME/Documents" "$HOME/.config" "$XDG_RUNTIME_DIR" "$STUBS" "$LOG"
chmod 700 "$XDG_RUNTIME_DIR"
export PATH="$STUBS:$ROOT/bin:$PATH"
export LOG

# Scripted menu: each call records its args and stdin under $LOG/menu.N and
# answers with the next line of $LOG/replies (ESC = Escape, exit 1).
cat >"$STUBS/omarchy-menu-select" <<'SH'
#!/bin/bash
n=$(( $(cat "$LOG/count" 2>/dev/null || echo 0) + 1 ))
echo "$n" >"$LOG/count"
{ printf '%s\n' "$@"; echo "--stdin--"; cat; } >"$LOG/menu.$n"
reply=$(head -n1 "$LOG/replies")
sed -i 1d "$LOG/replies"
[[ $reply == "ESC" ]] && exit 1
printf '%s\n' "$reply"
SH
for c in omarchy-launch-floating-terminal-with-presentation omarchy-transfer-config; do
  printf '#!/bin/bash\necho "$0 $*" >>"$LOG/launched"\n' >"$STUBS/$c"
done
chmod +x "$STUBS"/*

write_conf() {
  cat >"$OMARCHY_TRANSFER_CONF" <<'CONF'
# header comment
[options]
# pkgs
packages = yes
wifi = no
encrypt = yes

[include]
# settings
.config
.bashrc
#.gitconfig
.ssh
Documents
#Pictures
Music
.local/share/keyrings

[exclude]
.cache
CONF
}

reset_run() { # reply...
  rm -rf "$LOG"
  mkdir -p "$LOG"
  : >"$LOG/launched"
  printf '%s\n' "$@" >"$LOG/replies"
  write_conf
}

run_select() {
  RC=0
  timeout 30 "$ROOT/bin/omarchy-transfer-select" "$@" >"$LOG/out" 2>&1 </dev/null || RC=$?
  sleep 0.3
}

equal() { # expected actual description
  [[ $1 == "$2" ]] || fail "$3" "expected '$1', got '$2'"
  pass "$3"
}

launched() { cat "$LOG/launched"; }
calls() { cat "$LOG/count" 2>/dev/null || echo 0; }
menu_has() { grep -qxF -- "$2" "$LOG/menu.$1" || fail "$3" "menu.$1 lacks line: $2"; pass "$3"; }
menu_lacks() { if grep -qxF -- "$2" "$LOG/menu.$1"; then fail "$3" "menu.$1 has line: $2"; fi; pass "$3"; }

echo "# categorizer"
source "$ROOT/bin/omarchy-transfer-select"
set +e
cat_is() { [[ $(transfer_category "$1") == "$2" ]] || fail "category of $1 is $2" "got $(transfer_category "$1")"; pass "category of $1 is $2"; }
for p in .config .local/share/applications .local/share/fonts .local/share/icons .bashrc .bash_profile .zshrc .profile .inputrc .gitconfig; do cat_is "$p" settings; done
for p in .ssh .gnupg .password-store .local/share/keyrings .ssh/id_ed25519; do cat_is "$p" secrets; done
for p in Documents Pictures Dev Projects Music .mozilla .local/share/foo; do cat_is "$p" files; done
cat_is "Documents/" files
set -e

echo "# --apply scope"
reset_run
before=$(cat "$OMARCHY_TRANSFER_CONF")
# Files page: tick Pictures and Music, untick Documents; settings/secrets must stay.
"$ROOT/bin/omarchy-transfer-select" --apply files '["Pictures\t1K","Music\t2K"]'
expected=${before/$'\nDocuments\n#Pictures\nMusic'/$'\n#Documents\nPictures\nMusic'}
equal "$expected" "$(cat "$OMARCHY_TRANSFER_CONF")" "files page changes only files entries; comments and order stay"

reset_run
"$ROOT/bin/omarchy-transfer-select" --apply settings '[".gitconfig\t1K"]'
expected=${before/$'\n.config\n.bashrc\n#.gitconfig'/$'\n#.config\n#.bashrc\n.gitconfig'}
equal "$expected" "$(cat "$OMARCHY_TRANSFER_CONF")" "settings page leaves files and secrets alone"

reset_run
"$ROOT/bin/omarchy-transfer-select" --apply secrets '[]'
expected=${before/$'\n.ssh\n'/$'\n#.ssh\n'}
expected=${expected/$'\n.local/share/keyrings'/$'\n#.local/share/keyrings'}
equal "$expected" "$(cat "$OMARCHY_TRANSFER_CONF")" "secrets page changes only secret entries"

reset_run
"$ROOT/bin/omarchy-transfer-select" --apply options '["Wi-Fi networks\tNeeds sudo"]'
expected=${before/$'packages = yes\nwifi = no\nencrypt = yes'/$'packages = no\nwifi = yes\nencrypt = no'}
equal "$expected" "$(cat "$OMARCHY_TRANSFER_CONF")" "options page changes only options"

echo "# wizard flow"
reset_run "Export with Config"
run_select
equal 0 "$RC" "start page exits 0"
grep -q "omarchy-transfer-export" "$LOG/launched" || fail "Export with Config launches the export"
pass "Export with Config launches the export"
equal "$before" "$(cat "$OMARCHY_TRANSFER_CONF")" "Export with Config leaves the config alone"
menu_has 1 "--width" "start page is a plain single select"
menu_lacks 1 "--multiple" "start page has no --multiple"

reset_run "Open Config File"
run_select
grep -q "omarchy-transfer-config" "$LOG/launched" || fail "start page Open Config File launches the config"
pass "start page Open Config File launches the config"
equal 1 "$(calls)" "start page Open Config File ends the wizard"

reset_run ESC
run_select
equal 0 "$(wc -l <"$LOG/launched")" "Escape on the start page launches nothing"

reset_run "Choose Step by Step" Next Next Back Next Next "Start Export"
run_select
equal 0 "$RC" "step by step run exits 0"
equal 7 "$(calls)" "start page plus six step pages"
menu_has 2 "Export 1/4 · Settings" "page 1 prompt"
menu_has 3 "Export 2/4 · Files" "page 2 prompt"
menu_has 4 "Export 3/4 · Keys & Secrets" "page 3 prompt"
menu_has 5 "Export 2/4 · Files" "Back returns to page 2"
menu_has 6 "Export 3/4 · Keys & Secrets" "Next after Back returns to page 3"
menu_has 7 "Export 4/4 · Options" "Next reaches the last page"
grep -q "omarchy-transfer-export" "$LOG/launched" || fail "Start Export launches the export"
pass "Start Export launches the export"
grep -qxF -- '["omarchy-transfer-select","--apply","settings"]' "$LOG/menu.2" || fail "page 1 on-change names its page"
pass "page 1 on-change names its page"
menu_lacks 2 "$(printf '\U000f004d\tBack')" "page 1 has no Back"
menu_has 3 "$(printf '\U000f004d\tBack')" "page 2 has Back"
menu_has 3 "$(printf '\U000f0054\tNext')" "page 2 has Next"
menu_has 3 "$(printf '\U000f0493\tOpen Config File')" "page 2 has Open Config File"
grep -qE '^\.config	' "$LOG/menu.2" || fail "settings rows hold .config"
pass "settings rows hold .config"
if sed -n '/--stdin--/,$p' "$LOG/menu.2" | grep -q 'Documents'; then fail "page 1 lists no files entries"; fi
pass "page 1 lists no files entries"
sed -n '/--stdin--/,$p' "$LOG/menu.3" | grep -q 'Music' || fail "user-added path lands on Files"
pass "user-added path lands on Files"
sed -n '/--stdin--/,$p' "$LOG/menu.4" | grep -q '.ssh' || fail "secrets page holds .ssh"
pass "secrets page holds .ssh"

reset_run "Choose Step by Step" Next Next Next "Open Config File"
run_select
equal 5 "$(calls)" "options page reached"
menu_has 5 "Export 4/4 · Options" "page 4 prompt"
menu_has 5 "$(printf '\U000f0207\tStart Export')" "last page offers Start Export"
menu_lacks 5 "$(printf '\U000f0054\tNext')" "last page has no Next"
grep -q "omarchy-transfer-config" "$LOG/launched" || fail "page Open Config File launches the config"
pass "page Open Config File launches the config"
if grep -q "omarchy-transfer-export" "$LOG/launched"; then fail "Open Config File does not export"; fi
pass "Open Config File does not export"

reset_run "Choose Step by Step" Next ESC
run_select
equal 0 "$(wc -l <"$LOG/launched")" "Escape on a page aborts without launching"

echo "# empty pages are skipped and renumbered"
reset_run "Choose Step by Step" Next Next
cat >"$OMARCHY_TRANSFER_CONF" <<'CONF'
[options]
packages = yes
[include]
.config
Documents
CONF
run_select
menu_has 2 "Export 1/3 · Settings" "three pages without secrets"
menu_has 3 "Export 2/3 · Files" "files is page 2 of 3"
menu_has 4 "Export 3/3 · Options" "options renumbered to 3/3"

echo "# a label returned with its subtext still matches"
reset_run "$(printf 'Choose Step by Step\tReview settings')" "$(printf 'Open Config File\tx')"
run_select
grep -q "omarchy-transfer-config" "$LOG/launched" || fail "label with subtext is matched"
pass "label with subtext is matched"
