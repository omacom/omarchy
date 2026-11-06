#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# mise drops "tool[...]" bracket options from a key whose value is a table, so
# such a declaration installs without its options: Kiro and Devin found no
# versions at all. Backend options belong inside the table.
tools_config="$ROOT/etc/mise/conf.d/omarchy-tools.toml"
bracketed=$(awk '/^\[/ { in_tools = ($0 == "[tools]"); next } in_tools && /^"[^"]*\[[^"]*" = \{/' "$tools_config")
[[ -z $bracketed ]] || fail "no table-valued mise declaration carries bracket options" "$bracketed"
pass "mise declarations keep their backend options inside the table"

real_mise=$(PATH=/usr/local/bin:/usr/bin command -v mise || true)

# A lazy tool's first command installs it through mise's registry install when
# the registry lists that command, and that install leaves out Node, itself
# lazy, so an npm backend refuses to install. Each such tool must be kept out of
# that automatic install, leaving its first command to the lazy install, which
# installs Node with it. The real mise's registry says which tools those are.
if [[ -n $real_mise ]]; then
  mise_version=$("$real_mise" --version 2>/dev/null | cut -d' ' -f1)
fi
if [[ -z $real_mise ]]; then
  skip "mise is not installed; skipping the npm registry tool check"
elif [[ $(printf '%s\n' 2026.10.11 "$mise_version" | sort -V | head -n1) != "2026.10.11" ]]; then
  skip "mise $mise_version is older than the 2026.10.11 lazy defaults need; skipping the npm registry tool check"
else
  lazy_registry_tools=$(python3 -I -c '
import sys, tomllib
config = tomllib.load(open(sys.argv[1], "rb"))
kept_out = config.get("settings", {}).get("auto_install_disable_tools", [])
for key, spec in config["tools"].items():
  if ":" not in key and isinstance(spec, dict) and spec.get("lazy") and key not in kept_out:
    print(key)
' "$tools_config")

  registry_root="$test_tmp/registry"
  mkdir -p "$registry_root/etc/mise" "$registry_root/home"
  npm_registry_tools=""
  for tool in $lazy_registry_tools; do
    entry=$(env -i HOME="$registry_root/home" PATH=/usr/local/bin:/usr/bin MISE_SYSTEM_DIR="$registry_root/etc/mise" \
      "$real_mise" registry --json "$tool") ||
      fail "mise's registry knows Omarchy's declared tool $tool"
    if python3 -I -c 'import json, sys; entry = json.loads(sys.argv[1]); sys.exit(not (entry.get("bins") and entry["backends"][0].startswith("npm:")))' "$entry"; then
      npm_registry_tools+="$tool "
    fi
  done
  [[ -z $npm_registry_tools ]] ||
    fail "npm-backed registry tools are kept out of mise's automatic install" "first runs that fail on Node: $npm_registry_tools"
  pass "npm-backed registry tools are kept out of mise's automatic install"
fi

# Ask the real mise which backend options it resolves for each declaration that
# has some, in a throwaway home whose only config is that declaration. mise
# reports a tool's options only once it resolves a version, which takes the
# network, so the check is skipped without it.
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
