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

archive_roots=(
  "$test_home/.mix/archives"
  "$test_home/.local/share/mise/installs/elixir/1.19/.mix/archives"
  "$test_home/.local/share/mise/installs/elixir/1.20/.mix/archives"
)
for archives in "${archive_roots[@]}"; do
  mkdir -p "$archives/phx_new-1.8.0" "$archives/hex-2.7.0"
done
: >"$mise_log"
bash "$ROOT/bin/omarchy-remove-dev-env" phoenix >/dev/null
for archives in "${archive_roots[@]}"; do
  [[ ! -e $archives/phx_new-1.8.0 ]] || fail "Phoenix removal drops the phx_new archive" "$archives"
  [[ -d $archives/hex-2.7.0 ]] || fail "Phoenix removal preserves Hex" "$archives"
done
[[ -s $mise_log ]] && fail "Phoenix removal leaves Elixir and Erlang installed" "$(<"$mise_log")"
pass "Phoenix removal leaves Elixir and Erlang installed"
