#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
export HOME="$scratch/home" XDG_CONFIG_HOME="$scratch/config" OMARCHY_PATH="$ROOT"
export OFFICE_TEST_LOG="$scratch/calls.jsonl"
mkdir -p "$scratch/bin" "$HOME" "$XDG_CONFIG_HOME/omarchy/microsoft-office"
export PATH="$scratch/bin:$ROOT/bin:$PATH"

cat > "$scratch/bin/stub" <<'PY'
#!/usr/bin/python3
import json, os, pathlib, sys
name = pathlib.Path(sys.argv[0]).name
args = sys.argv[1:]
with open(os.environ['OFFICE_TEST_LOG'], 'a') as log:
    log.write(json.dumps([name, args]) + '\n')
if name == 'omarchy-cmd-missing':
    sys.exit(1)
if name == 'gum':
    if os.environ.get('OFFICE_TEST_CANCEL') == '1':
        sys.exit(1)
    if args[0] == 'confirm' and args[1].startswith('Make '):
        sys.exit(0 if os.environ.get('OFFICE_TEST_DEFAULTS') == '1' else 1)
if name == 'rclone':
    config = args[1]
    command = args[2:]
    if command[:2] == ['config', 'create']:
        pathlib.Path(config).write_text('connected')
    elif command[:2] == ['config', 'dump']:
        print(json.dumps({'office': {'type': 'onedrive', 'region': os.environ.get('OFFICE_TEST_REGION', 'global'), 'drive_id': 'fallback-drive', 'token': json.dumps({'access_token': 'test-token'})}}))
    elif command[0] == 'copyto':
        if os.environ.get('OFFICE_TEST_UPLOAD_FAIL') == '1':
            sys.exit(1)
    elif command[0] == 'lsjson':
        print(json.dumps({'ID': os.environ.get('OFFICE_TEST_ID', 'drive#item')}))
    elif command[0] == 'lsd' and os.environ.get('OFFICE_TEST_AUTH_FAIL') == '1':
        sys.exit(1)
    else:
        if command[0] not in ['lsd']:
            sys.exit('unexpected rclone operation')
if name == 'curl':
    assert sys.stdin.read() == 'Authorization: Bearer test-token\n'
    assert 'test-token' not in ' '.join(args)
    print(json.dumps({'webUrl': os.environ.get('OFFICE_TEST_URL', 'https://onedrive.live.com/edit-document')}))
PY
chmod +x "$scratch/bin/stub"
for name in rclone curl omarchy-cmd-missing omarchy-launch-webapp omarchy-notification-send gum omarchy-pkg-add omarchy-install-service-microsoft update-desktop-database xdg-mime omarchy-webapp-install; do
  ln -s stub "$scratch/bin/$name"
done

assert_calls() {
  python3 - "$OFFICE_TEST_LOG" "$1" <<'PY'
import json, sys
calls = [json.loads(line) for line in open(sys.argv[1])]
assert eval(sys.argv[2], {'calls': calls, 'all': all, 'any': any, 'len': len, 'set': set}), calls
PY
}
reset_calls() { : > "$OFFICE_TEST_LOG"; }
handler="$ROOT/bin/omarchy-webapp-handler-microsoft"
setup="$ROOT/bin/omarchy-setup-microsoft-office"
config="$XDG_CONFIG_HOME/omarchy/microsoft-office/rclone.conf"

reset_calls
for app in word excel powerpoint; do "$handler" "$app"; done
assert_calls "calls == [['omarchy-launch-webapp', ['https://' + app + '.cloud.microsoft/']] for app in ['word', 'excel', 'powerpoint']]"
pass "ordinary launchers work without rclone configuration"

file="$scratch/-Quarterly 'report' %.docx"
printf 'local original' > "$file"
reset_calls
if "$handler" word "$file" >/dev/null 2>&1; then fail "unconfigured opening fails"; fi
assert_calls "all(name != 'rclone' and name != 'curl' for name, args in calls)"
pass "unconfigured file opening explains setup without uploading"

printf 'connected' > "$config"
reset_calls
if "$handler" word "$file" "$scratch/missing.docx" >/dev/null 2>&1; then fail "invalid selection fails"; fi
assert_calls "all(name != 'rclone' for name, args in calls)"
pass "whole selection is validated before upload"

reset_calls
"$handler" word "$file"
"$handler" word "$file"
assert_calls "len(set(args[-1] for name, args in calls if name == 'rclone' and args[2] == 'copyto')) == 2"
assert_calls "all(args[3] == '--' and args[-2].endswith(\"-Quarterly 'report' %.docx\") for name, args in calls if name == 'rclone' and args[2] == 'copyto')"
assert_calls "len([1 for name, args in calls if name == 'omarchy-launch-webapp' and args == ['https://onedrive.live.com/edit-document']]) == 2"
assert_calls "all('link' not in args and 'test-token' not in ' '.join(args) for name, args in calls)"
[[ $(cat "$file") == 'local original' ]] || fail "local document stays unchanged"
pass "private cloud copies preserve names, previous edits, and local originals"

mkdir -p "$scratch/other"
cp -- "$file" "$scratch/other/$(basename -- "$file")"
reset_calls
"$handler" word "$file" "$scratch/other/$(basename -- "$file")"
assert_calls "len(set(args[-1] for name, args in calls if name == 'rclone' and args[2] == 'copyto')) == 2"
pass "same-named documents in one selection get separate cloud copies"

reset_calls
OFFICE_TEST_ID='item only' "$handler" word "$file"
assert_calls "any(name == 'curl' and '/drives/fallback-drive/items/item%20only?' in args[-1] for name, args in calls)"
pass "plain item IDs use the configured drive and URI encoding"

for failure in upload url region; do
  reset_calls
  case $failure in
  upload) export OFFICE_TEST_UPLOAD_FAIL=1 ;;
  url) export OFFICE_TEST_URL='javascript:alert(1)' ;;
  region) export OFFICE_TEST_REGION=us ;;
  esac
  if "$handler" word "$file" >/dev/null 2>&1; then fail "$failure fails safely"; fi
  assert_calls "all(name != 'omarchy-launch-webapp' for name, args in calls)"
  unset OFFICE_TEST_UPLOAD_FAIL OFFICE_TEST_URL OFFICE_TEST_REGION
  pass "$failure failure reports an error without opening the browser"
done

reset_calls
OFFICE_TEST_CANCEL=1 "$setup" >/dev/null
assert_calls "all(name == 'gum' for name, args in calls)"
pass "cancelled setup leaves packages and associations alone"

reset_calls
if OFFICE_TEST_AUTH_FAIL=1 "$setup" >/dev/null 2>&1; then fail "failed setup fails"; fi
[[ $(cat "$config") == 'connected' ]] || fail "failed reconnect preserves credentials"
assert_calls "all(name not in ['xdg-mime', 'omarchy-install-service-microsoft'] for name, args in calls)"
pass "failed authentication preserves credentials and file associations"

reset_calls
"$setup" >/dev/null
assert_calls "all(name != 'xdg-mime' for name, args in calls)"
[[ $(stat -c %a "$config") == '600' ]] || fail "credentials are private"
pass "successful setup keeps existing defaults unless opted in and protects credentials"

reset_calls
OFFICE_TEST_DEFAULTS=1 "$setup" >/dev/null
assert_calls "len([1 for name, args in calls if name == 'xdg-mime']) == 3"
pass "setup can opt into all six Office file associations"

reset_calls
"$ROOT/bin/omarchy-install-service-microsoft" >/dev/null
assert_calls "len([1 for name, args in calls if name == 'omarchy-webapp-install']) == 6"
assert_calls "all(args[3] == 'omarchy-webapp-handler-microsoft ' + app + ' %F' and args[4].endswith(';') for name, args in calls if name == 'omarchy-webapp-install' for app in ['word', 'excel', 'powerpoint'] if args[0] == 'Microsoft ' + ('PowerPoint' if app == 'powerpoint' else app.title()))"
assert_calls "all(name != 'xdg-mime' for name, args in calls)"
pass "bundle advertises Open With handlers without changing defaults"
