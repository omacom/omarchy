#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

export PATH="$ROOT/bin:$PATH"

require_command jq

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Stub sudo so helpers can run unprivileged, and omarchy-cmd-present so
# setup_zen_preferences sees jq as available. as_root is overridden after
# sourcing to strip -o/-g (temp dirs are user-owned).
mock_bin="$TMPDIR/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH

cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ ${1:-} == "jq" ]]
SH

chmod +x "$mock_bin"/*

unprivileged_as_root() {
  if [[ $1 == "install" ]]; then
    shift
    local args=()
    local skip=0
    local arg
    for arg in "$@"; do
      if (( skip )); then
        skip=0
        continue
      fi
      case $arg in
        -o|-g) skip=1 ;;
        *) args+=("$arg") ;;
      esac
    done
    command install "${args[@]}"
  else
    "$@"
  fi
}

distribution="$TMPDIR/zen-browser-bin/distribution"

# Simulate the policies the zen-browser-bin AUR package ships: DisableAppUpdate
# and DefaultSerialGuardSetting. The fix must merge Omarchy's Preferences on
# top of these, not overwrite them.
mkdir -p "$distribution"
cat >"$distribution/policies.json" <<'JSON'
{
  "policies": {
    "DisableAppUpdate": true,
    "DefaultSerialGuardSetting": 3
  }
}
JSON

PATH="$mock_bin:$PATH" OMARCHY_PATH="$ROOT" bash -c '
  source "$1/bin/omarchy-install-browser"
  as_root() {
    if [[ $1 == "install" ]]; then
      shift
      local args=() skip=0 arg
      for arg in "$@"; do
        if (( skip )); then skip=0; continue; fi
        case $arg in -o|-g) skip=1 ;; *) args+=("$arg") ;; esac
      done
      command install "${args[@]}"
    else
      "$@"
    fi
  }
  # Fixtures are user-owned, so the non-root purge would delete them.
  browser_policy_purge_dir() { :; }
  setup_zen_preferences "$2"
' bash "$ROOT" "$distribution"

[[ -f $distribution/policies.json ]] || fail "zen preferences wrote policies.json"
[[ ! -L $distribution/policies.json ]] || fail "zen preferences do not follow a planted symlink"

mode=$(stat -c '%a' "$distribution/policies.json")
[[ $mode == "644" ]] || fail "zen preferences write a 0644 policies.json" "mode=$mode"

jq -e '
  .policies.DisableAppUpdate == true and
  .policies.DefaultSerialGuardSetting == 3 and
  (.policies.Preferences."apz.overscroll.enabled".Value == true) and
  (.policies.Preferences."media.ffmpeg.vaapi.enabled".Value == true) and
  (.policies.Preferences."widget.wayland.fractional-scale.enabled".Value == true)
' "$distribution/policies.json" >/dev/null ||
  fail "zen preferences preserve package policies and add Omarchy Preferences" \
    "$(jq -c . "$distribution/policies.json")"
pass "zen preferences preserve package policies and add Omarchy Preferences"

# Without a pre-existing package policies.json, the installer falls back to a
# plain copy of Omarchy's policies.
fresh_distribution="$TMPDIR/zen-browser-bin-fresh/distribution"
PATH="$mock_bin:$PATH" OMARCHY_PATH="$ROOT" bash -c '
  source "$1/bin/omarchy-install-browser"
  as_root() {
    if [[ $1 == "install" ]]; then
      shift
      local args=() skip=0 arg
      for arg in "$@"; do
        if (( skip )); then skip=0; continue; fi
        case $arg in -o|-g) skip=1 ;; *) args+=("$arg") ;; esac
      done
      command install "${args[@]}"
    else
      "$@"
    fi
  }
  # Fixtures are user-owned, so the non-root purge would delete them.
  browser_policy_purge_dir() { :; }
  setup_zen_preferences "$2"
' bash "$ROOT" "$fresh_distribution"

jq -e '.policies.Preferences."apz.overscroll.enabled".Value == true' \
  "$fresh_distribution/policies.json" >/dev/null ||
  fail "zen preferences fall back to a plain copy without package policies"
pass "zen preferences fall back to a plain copy without package policies"

# The installer must target the path Zen actually reads from, not the
# /opt/zen-browser path from the original report.
grep -q "zen-browser-bin/distribution" "$ROOT/bin/omarchy-install-browser" ||
  fail "zen installer targets the zen-browser-bin install path"
if grep -q "opt/zen-browser/distribution" "$ROOT/bin/omarchy-install-browser"; then
  fail "zen installer still references the unused zen-browser path"
fi
pass "zen installer targets the path Zen reads from"

# Secure write: root-owned 0755 dir + 0644 file, never world-writable,
# never following a planted symlink via sudo tee.
if grep -En 'chmod a\+rw|sudo tee|setup_policy_directory' "$ROOT/bin/omarchy-install-browser" | grep -v '^.*# ' >/dev/null; then
  fail "zen installer uses secure root-owned writes, not world-writable dirs or sudo tee"
fi
grep -F 'browser_policy_setup_parent' "$ROOT/bin/omarchy-install-browser" >/dev/null ||
  fail "zen installer hardens the distribution directory to 0755 root"
grep -F 'install -m 0644' "$ROOT/bin/omarchy-install-browser" >/dev/null ||
  fail "zen installer writes a 0644 root-owned policies.json"
pass "zen installer uses secure writes"

# Default path (no explicit arg) is the path Zen reads.
grep -F '${1:-/opt/zen-browser-bin/distribution}' "$ROOT/bin/omarchy-install-browser" >/dev/null ||
  fail "zen preferences default to the zen-browser-bin path"
grep -F '/opt/zen-browser-bin/distribution' "$ROOT/install/helpers/browser-policy.sh" >/dev/null ||
  fail "shared helper covers the zen-browser-bin path for hardening"
pass "zen preferences default to the path Zen reads"
