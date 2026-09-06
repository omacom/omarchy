#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin" "$test_tmp/home"

cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ $1 == "brave-origin" && ${OMARCHY_TEST_BRAVE_PRESENT:-1} == "1" ]]
SH
cat >"$mock_bin/omarchy-cmd-missing" <<'SH'
#!/bin/bash
! omarchy-cmd-present "$@"
SH
for command in omarchy-pkg-add omarchy-pkg-drop sudo uwsm-app; do
  printf '#!/bin/bash\nexit 0\n' >"$mock_bin/$command"
done
chmod +x "$mock_bin"/*

export HOME="$test_tmp/home" PATH="$mock_bin:$ROOT/bin:$PATH"
extension_dir="$HOME/.config/BraveSoftware/Brave-Origin/External Extensions"
extension_file="$extension_dir/aeblfdkhhhdcdjpifhhbdiojplfjncoa.json"

bash "$ROOT/bin/omarchy-install-service-1password" >/dev/null
jq -e '.external_update_url == "https://clients2.google.com/service/update2/crx"' "$extension_file" >/dev/null ||
  fail "1Password installs its extension for Brave Origin without Chromium"
pass "1Password installs its extension for Brave Origin without Chromium"

printf '{}\n' >"$extension_dir/another-extension.json"
bash "$ROOT/bin/omarchy-remove-service-1password" >/dev/null
[[ ! -e $extension_file && -f $extension_dir/another-extension.json ]] ||
  fail "1Password removal deletes only its own Brave Origin extension"
pass "1Password removal deletes only its own Brave Origin extension"

OMARCHY_TEST_BRAVE_PRESENT=0 bash "$ROOT/bin/omarchy-install-service-1password" >/dev/null
[[ ! -e $extension_file ]] || fail "1Password skips the Brave Origin extension when the browser is absent"
pass "1Password skips the Brave Origin extension when the browser is absent"
