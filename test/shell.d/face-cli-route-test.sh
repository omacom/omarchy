#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

commands=(omarchy-hw-dell-xps-ir-camera omarchy-setup-security-face omarchy-remove-security-face omarchy-face-match)

# The metadata lint test/cli applies to every bin/omarchy-* executable; hold
# the face commands to it here, where they are also tested on their own.
for command in "${commands[@]}"; do
  binary_path="$ROOT/bin/$command"
  [[ -x $binary_path ]] || fail "$command is an executable command"
  header=$(head -n 80 "$binary_path")
  grep -q '^# omarchy:summary=' <<<"$header" || fail "metadata summary is present: $binary_path"
  ! grep -q '^# omarchy:args=$' <<<"$header" || fail "metadata does not include empty args: $binary_path"
  ! grep -Eq '^# omarchy:(legacy|usage|visibility|mutates|interactive)=' <<<"$header" || fail "metadata avoids removed fields: $binary_path"
  ! grep -Eq '^# omarchy:(requires-sudo|hidden)=false$' <<<"$header" || fail "metadata omits false booleans: $binary_path"
  [[ $(head -n 1 "$binary_path") == "#!/bin/bash" ]] || fail "shebang is #!/bin/bash: $binary_path"
done
pass "all shipped commands carry slim self-documenting metadata"

# Routing is the installed dispatcher's job: run a copy of it over the
# face commands alone, the way test/cli builds its own command tables.
dispatcher="${OMARCHY_PATH:-/usr/share/omarchy}/bin/omarchy"
[[ -x $dispatcher ]] || dispatcher=$(command -v omarchy || true)
if [[ -z $dispatcher || ! -x $dispatcher ]]; then
  skip "no omarchy dispatcher on this machine; skipping route resolution"
  exit 0
fi

mkdir -p "$test_tmp/bin"
cp "$dispatcher" "$test_tmp/bin/omarchy"
cp "$ROOT"/bin/omarchy-* "$test_tmp/bin/"
chmod +x "$test_tmp/bin"/*
cli="$test_tmp/bin/omarchy"

registry=$("$cli" commands --all --json)
jq -e '.commands[] | select(.binary == "omarchy-hw-dell-xps-ir-camera" and .route == "omarchy hw dell xps ir camera" and .requires_sudo == false and .hidden == true)' <<<"$registry" >/dev/null ||
  fail "the hardware predicate routes as omarchy hw dell xps ir camera and stays hidden like omarchy-hw-fingerprint" "$registry"
jq -e '.commands[] | select(.binary == "omarchy-setup-security-face" and .route == "omarchy setup security face" and .requires_sudo == true)' <<<"$registry" >/dev/null ||
  fail "the setup wizard routes as omarchy setup security face and asks for sudo" "$registry"
jq -e '.commands[] | select(.binary == "omarchy-remove-security-face" and .route == "omarchy remove security face" and .requires_sudo == true)' <<<"$registry" >/dev/null ||
  fail "the removal wizard routes as omarchy remove security face and asks for sudo" "$registry"
jq -e '.commands[] | select(.binary == "omarchy-face-match" and .route == "omarchy face match" and .hidden == true)' <<<"$registry" >/dev/null ||
  fail "the pam_exec helper routes as omarchy face match and stays hidden like omarchy-hw-laptop-closed" "$registry"
pass "the dispatcher resolves all four routes from the filenames"

for route in "hw dell xps ir camera" "setup security face" "remove security face"; do
  # shellcheck disable=SC2086
  help=$("$cli" $route --help 2>&1) || fail "omarchy $route --help succeeds without running the command" "$help"
  grep -q "omarchy $route" <<<"$help" || fail "omarchy $route --help shows its route" "$help"
done
pass "--help renders usage for each route without executing it"

help=$("$cli" hw dell xps ir camera --help 2>&1)
! grep -q -- '--' <<<"$help" || fail "the hardware predicate takes no flags" "$help"
pass "the hardware predicate takes no flags"
