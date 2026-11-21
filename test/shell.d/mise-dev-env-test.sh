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

mise_config="$test_tmp/etc/mise/config.toml"
miserc="$test_home/.config/mise/miserc.toml"
export OMARCHY_MISE_CONFIG_PATH="$mise_config"

# Each dev env and the default tool it relies on. Python also installs Python
# itself, through the user's config.
envs=(
  "node node"
  "python uv"
)

# When Omarchy declares the tool system-wide, setup installs that version and
# leaves the user config alone. mise skips the declarations for a user who
# removed the preinstalls, and nothing declares the tool without Omarchy's
# config; either way it goes in the user's own config, and an opt-out stays.
for scenario in declared opted-out undeclared; do
  mkdir -p "$(dirname "$mise_config")"
  cp "$ROOT/etc/mise/conf.d/omarchy-tools.toml" "$mise_config"
  rm -f "$miserc"

  case $scenario in
    opted-out)
      mkdir -p "$(dirname "$miserc")"
      printf 'ignored_config_paths = ["%s"]\n' "$mise_config" >"$miserc"
      cp "$miserc" "$test_tmp/expected-miserc"
      ;;
    undeclared)
      rm "$mise_config"
      ;;
  esac

  for entry in "${envs[@]}"; do
    read -r env tool <<<"$entry"
    if [[ $scenario == "declared" ]]; then
      expected="install $tool"
      unexpected="use --global $tool"
    else
      expected="use --global $tool"
      unexpected="install $tool"
    fi

    : >"$mise_log"
    bash "$ROOT/bin/omarchy-install-dev-env" "$env" >/dev/null

    grep -Fx "$expected" "$mise_log" >/dev/null ||
      fail "$env setup runs '$expected' when $tool is $scenario" "$(<"$mise_log")"
    if grep -Fx "$unexpected" "$mise_log" >/dev/null; then
      fail "$env setup skips '$unexpected' when $tool is $scenario" "$(<"$mise_log")"
    fi
    if [[ $env == "python" ]]; then
      grep -Fx 'use --global python@latest' "$mise_log" >/dev/null ||
        fail "python setup installs Python through mise when $tool is $scenario" "$(<"$mise_log")"
    fi
    if [[ $scenario == "opted-out" ]]; then
      cmp -s "$miserc" "$test_tmp/expected-miserc" || fail "$env setup keeps the preinstall opt-out"
    fi
    pass "$env setup handles $tool when $scenario"
  done
done

touch "$test_home/.local/bin/uv" "$test_home/.local/bin/uvx" "$test_home/.cargo/bin/uv"
: >"$mise_log"
bash "$ROOT/bin/omarchy-remove-dev-env" python >/dev/null
grep -Fx 'uninstall python --all' "$mise_log" >/dev/null || fail "Python removal uninstalls mise Python"
grep -Fx 'rm -g python' "$mise_log" >/dev/null || fail "Python removal removes the global Python declaration"
grep -q 'uv' "$mise_log" && fail "Python removal does not remove the independent uv tool"
[[ -e $test_home/.local/bin/uv && -e $test_home/.local/bin/uvx && -e $test_home/.cargo/bin/uv ]] ||
  fail "Python removal preserves uv commands"
pass "Python removal preserves the default uv tool"

# Old shared SDKs and new isolated SDKs need different mise uninstall modes.
shared_root="$test_tmp/shared-dotnet"
installs="$test_home/.local/share/mise/installs/dotnet"
mkdir -p "$shared_root/sdk/10.0.100" "$installs/10.0.101/sdk/10.0.101"
ln -s "$shared_root" "$installs/10.0.100"
export OMARCHY_TEST_DOTNET_INSTALLS
OMARCHY_TEST_DOTNET_INSTALLS=$(jq -nc --arg shared "$installs/10.0.100" --arg isolated "$installs/10.0.101" \
  '[{install_path: $shared}, {install_path: $isolated}]')
cat >"$mock_bin/mise" <<'SH'
#!/bin/bash
printf '%s|%s|%s\n' "${MISE_DOTNET_ISOLATED-unset}" "${MISE_DOTNET_ROOT-unset}" "$*" >>"$OMARCHY_TEST_MISE_LOG"
if [[ $1 == "ls" ]]; then
  printf '%s\n' "$OMARCHY_TEST_DOTNET_INSTALLS"
elif [[ $2 == "dotnet@10.0.100" && ${OMARCHY_TEST_UNINSTALL_FAIL:-} == 1 ]]; then
  exit 1
fi
SH
: >"$mise_log"
bash "$ROOT/bin/omarchy-remove-dev-env" dotnet >/dev/null
grep -Fx "false|$shared_root|uninstall dotnet@10.0.100" "$mise_log" >/dev/null ||
  fail ".NET removal uninstalls legacy SDKs in shared mode using their actual root"
grep -Fx 'unset|unset|uninstall dotnet --all' "$mise_log" >/dev/null ||
  fail ".NET removal leaves isolated SDKs to the normal uninstall"
grep -Fx 'unset|unset|rm -g dotnet' "$mise_log" >/dev/null ||
  fail ".NET removal removes the global tool declaration"
if grep -F 'uninstall dotnet@10.0.101' "$mise_log" >/dev/null; then
  fail ".NET removal does not treat a real isolated directory as shared"
fi
pass ".NET removal handles mixed shared and isolated SDKs"

: >"$mise_log"
if OMARCHY_TEST_UNINSTALL_FAIL=1 bash "$ROOT/bin/omarchy-remove-dev-env" dotnet >/dev/null 2>&1; then
  fail ".NET removal reports a failed legacy uninstall"
fi
if grep -F 'rm -g dotnet' "$mise_log" >/dev/null; then
  fail ".NET removal preserves the declaration when a legacy uninstall fails"
fi
pass ".NET removal stops when a legacy uninstall fails"
