#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mock_bin="$test_tmp/bin"
export HOME="$test_tmp/home with spaces"
export PATH="$mock_bin:$HOME/.local/bin:$ROOT/bin:/usr/local/bin:/usr/bin"
export OMARCHY_TEST_MISE_LOG="$test_tmp/mise-log"
mkdir -p "$mock_bin" "$HOME/.local/bin"
cat >"$mock_bin/mise" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >>"$OMARCHY_TEST_MISE_LOG"
SH
chmod +x "$mock_bin/mise"

source "$ROOT/install/user/mise.sh"
for agent in kimi cursor-agent muse qwen dsh mcode kiro-cli freebuff kilo devin amp commandcode; do
  [[ ! -e $HOME/.local/bin/$agent ]] || fail "provisioning must not create a handwritten $agent wrapper"
done
mapfile -d '' -t args <"$OMARCHY_TEST_MISE_LOG"
[[ ${args[*]} == "reshim --system reshim" ]] ||
  fail "provisioning builds the lazy shims without installing packages or writing the user's config"
pass "provisioning leaves the lazy agent shims to mise"

# The settings package ships this, so the user's config stays theirs.
grep -Fx 'upgrade.auto_prune = false' "$ROOT/etc/mise/conf.d/omarchy.toml" >/dev/null ||
  fail "Omarchy's mise config keeps upgrades from pruning versions still in use"
pass "upgrade pruning is off in the package-owned mise config"

# mise drops "tool[...]" bracket options from a key whose value is a table, so
# such a declaration installs without its options: Kiro and Devin found no
# versions at all. Backend options belong inside the table.
tools_config="$ROOT/etc/mise/conf.d/omarchy-tools.toml"
bracketed=$(awk '/^\[/ { in_tools = ($0 == "[tools]"); next } in_tools && /^"[^"]*\[[^"]*" = \{/' "$tools_config")
[[ -z $bracketed ]] || fail "no table-valued mise declaration carries bracket options" "$bracketed"
pass "mise declarations keep their backend options inside the table"

# Ask the real mise which backend options it resolves for each declaration that
# has some, in a throwaway home whose only config is that declaration. mise
# reports a tool's options only once it resolves a version, which takes the
# network, so the check is skipped without it.
real_mise=$(PATH=/usr/local/bin:/usr/bin command -v mise || true)
if [[ -z $real_mise ]]; then
  skip "mise is not installed; skipping the backend option resolution check"
elif ! curl -sfI --max-time 5 https://registry.npmjs.org/ >/dev/null 2>&1; then
  skip "no network; skipping the backend option resolution check"
else
  # Prints each declaration's key, the tool it names, and its backend options:
  # those in brackets on the key and every table key other than the ones that
  # say how mise manages the tool.
  declared_options=$(python3 -I -c '
import sys, tomllib
managed = {"version", "lazy", "lazy_bins", "auto_update", "minimum_release_age"}
for key, spec in tomllib.load(open(sys.argv[1], "rb"))["tools"].items():
  tool, _, bracket = key.partition("[")
  options = [option.split("=")[0] for option in bracket.rstrip("]").split(",") if option]
  if isinstance(spec, dict):
    options += sorted(set(spec) - managed)
  if options:
    print(key, tool, *options, sep="\t")
' "$tools_config")
  [[ -n $declared_options ]] || fail "Omarchy declares tools with backend options"

  while IFS=$'\t' read -r key tool options; do
    mise_root="$test_tmp/real-mise/${tool//[^a-z]/-}"
    mkdir -p "$mise_root/etc/mise/conf.d" "$mise_root/home"
    { echo "[tools]"; grep -F "\"$key\" = " "$tools_config"; } >"$mise_root/etc/mise/conf.d/tools.toml"
    resolved=$(cd "$mise_root/home" && env -i HOME="$mise_root/home" PATH=/usr/local/bin:/usr/bin \
      XDG_CONFIG_HOME="$mise_root/home/.config" XDG_CACHE_HOME="$mise_root/home/.cache" \
      XDG_DATA_HOME="$mise_root/home/.local/share" XDG_STATE_HOME="$mise_root/home/.local/state" \
      MISE_SYSTEM_DIR="$mise_root/etc/mise" timeout 60 "$real_mise" tool --tool-options "$tool" 2>/dev/null || true)
    for option in $options; do
      [[ $resolved == *"$option="* ]] ||
        fail "mise resolves $option for $tool from Omarchy's declaration" "mise resolved: ${resolved:-nothing}"
    done
  done <<<"$declared_options"
  pass "mise resolves the backend options of Omarchy's declarations"
fi
