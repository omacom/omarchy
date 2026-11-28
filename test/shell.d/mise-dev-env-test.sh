#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mise_log="$test_tmp/mise"
mkdir -p "$mock_bin" "$test_home/.local/bin" "$test_home/.cargo/bin"

cat >"$mock_bin/mise" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_MISE_LOG"
SH
chmod +x "$mock_bin/mise"

export HOME="$test_home"
export OMARCHY_TEST_MISE_LOG="$mise_log"
export PATH="$mock_bin:$ROOT/bin:$PATH"

touch "$test_home/.local/bin/uv" "$test_home/.local/bin/uvx" "$test_home/.cargo/bin/uv"
: >"$mise_log"
bash "$ROOT/bin/omarchy-remove-dev-env" python >/dev/null
grep -Fx 'uninstall python --all' "$mise_log" >/dev/null || fail "Python removal uninstalls mise Python"
grep -Fx 'rm -g python' "$mise_log" >/dev/null || fail "Python removal removes the global Python declaration"
grep -q 'uv' "$mise_log" && fail "Python removal does not remove the independent uv tool"
[[ -e $test_home/.local/bin/uv && -e $test_home/.local/bin/uvx && -e $test_home/.cargo/bin/uv ]] ||
  fail "Python removal preserves uv commands"
pass "Python removal preserves the default uv tool"

# The .NET launcher in /usr/local/bin picks the user's mise SDK over the
# runtime-only /usr/bin/dotnet, but leaves packaged apps like Pinta on it.
mkdir -p "$test_tmp/usr/bin" "$test_tmp/sdk"
printf '#!/bin/bash\necho "system $*"\n' >"$test_tmp/usr/bin/dotnet"
printf '#!/bin/bash\necho "sdk $*"\n' >"$test_tmp/sdk/dotnet"
printf '#!/bin/bash\n[[ -n $TEST_SDK ]] && echo "$TEST_SDK"\n' >"$mock_bin/mise"
sed "s#/usr/bin/dotnet#$test_tmp/usr/bin/dotnet#" "$ROOT/default/dotnet/dotnet" >"$test_tmp/dotnet"
chmod +x "$test_tmp/usr/bin/dotnet" "$test_tmp/sdk/dotnet" "$mock_bin/mise" "$test_tmp/dotnet"

[[ $(TEST_SDK="$test_tmp/sdk/dotnet" "$test_tmp/dotnet" build) == "sdk build" ]] || fail ".NET launcher runs the mise SDK"
[[ $(TEST_SDK="" "$test_tmp/dotnet" build) == "system build" ]] || fail ".NET launcher falls back without a mise SDK"
[[ $(TEST_SDK="$test_tmp/sdk/dotnet" "$test_tmp/dotnet" /usr/lib/pinta/Pinta.dll) == "system /usr/lib/pinta/Pinta.dll" ]] ||
  fail ".NET launcher keeps Pinta on the system runtime"
pass ".NET launcher prefers the mise SDK and keeps Pinta on the system runtime"

# Setup only replaces Omarchy's own launcher, and removal keeps it for other
# users. A sandbox stands a scratch /usr/local/bin in for the host's.
if ! command -v bwrap >/dev/null || ! bwrap --ro-bind / / --unshare-user true 2>/dev/null; then
  skip "user namespaces unavailable; skipping .NET launcher ownership"
  exit 0
fi

local_bin="$test_tmp/usr-local-bin"
launcher="$local_bin/dotnet"
shipped="$ROOT/default/dotnet/dotnet"
mkdir -p "$local_bin"
printf '#!/bin/bash\nexec "$@"\n' >"$mock_bin/sudo"
chmod +x "$mock_bin/sudo"
sandbox=(bwrap --ro-bind / / --bind "$test_tmp" "$test_tmp" --bind "$local_bin" /usr/local/bin --dev /dev --proc /proc --unshare-user)

"${sandbox[@]}" bash "$ROOT/bin/omarchy-install-dev-env" dotnet >/dev/null
cmp -s "$launcher" "$shipped" || fail ".NET setup installs the launcher"
pass ".NET setup installs the launcher"

"${sandbox[@]}" bash "$ROOT/bin/omarchy-remove-dev-env" dotnet >/dev/null
cmp -s "$launcher" "$shipped" || fail ".NET removal keeps the launcher other users fall back through"
pass ".NET removal keeps the launcher other users fall back through"

printf '#!/bin/sh\nexec /opt/dotnet/dotnet "$@"\n' >"$launcher"
cp "$launcher" "$test_tmp/admin-dotnet"
"${sandbox[@]}" bash "$ROOT/bin/omarchy-install-dev-env" dotnet >/dev/null 2>&1
cmp -s "$launcher" "$test_tmp/admin-dotnet" || fail ".NET setup keeps a dotnet an admin put in /usr/local/bin"
pass ".NET setup keeps a dotnet an admin put in /usr/local/bin"
