#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
export OMARCHY_PATH="$ROOT"
export TARGET_ROOT="$scratch/target root"
mkdir -p "$TARGET_ROOT/etc/omarchy"

apply() { "$ROOT/bin/omarchy-apply-pacman" "$1" "$TARGET_ROOT"; }

for channel in stable rc edge; do
  apply "$channel"
  cmp "$ROOT/default/pacman/pacman-$channel.conf" "$TARGET_ROOT/etc/pacman.conf"
  cmp "$ROOT/default/pacman/mirrorlist-$channel" "$TARGET_ROOT/etc/pacman.d/mirrorlist"
done
pass "missing region preserves all global channel templates byte for byte"

chmod 600 "$TARGET_ROOT/etc/pacman.conf"
apply stable
[[ $(stat -c %a "$TARGET_ROOT/etc/pacman.conf") == 600 ]] || fail "refresh keeps a customized pacman.conf mode"
chmod 644 "$TARGET_ROOT/etc/pacman.conf"
pass "refresh keeps existing config file modes"

printf 'cn\n' > "$TARGET_ROOT/etc/omarchy/region"
for channel in stable rc edge; do
  case "$channel" in
    stable) host=stable-mirror.omarchy ;;
    rc) host=rc-mirror.omarchy ;;
    edge) host=mirror.omarchy ;;
  esac
  apply "$channel"
  expected=$(printf 'Server = https://%s.cn/$repo/os/$arch\nServer = https://%s.org/$repo/os/$arch' "$host" "$host")
  [[ $(<"$TARGET_ROOT/etc/pacman.d/mirrorlist") == "$expected" ]] || fail "$channel mirror order and variables"
  {
    cat "$ROOT/default/pacman/pacman-$channel.conf"
    printf '\n[archlinuxcn]\nServer = https://mirrors.ustc.edu.cn/archlinuxcn/$arch\n'
  } > "$scratch/expected.conf"
  cmp "$scratch/expected.conf" "$TARGET_ROOT/etc/pacman.conf"
  apply "$channel"
  cmp "$TARGET_ROOT/etc/pacman.conf.bak" "$TARGET_ROOT/etc/pacman.conf"
  cmp "$TARGET_ROOT/etc/pacman.d/mirrorlist.bak" "$TARGET_ROOT/etc/pacman.d/mirrorlist"
done
pass "China puts its channel mirror first, keeps the global one as fallback, and is idempotent"

cp "$TARGET_ROOT/etc/pacman.conf" "$scratch/before.conf"
cp "$TARGET_ROOT/etc/pacman.d/mirrorlist" "$scratch/before.mirrors"
for region in '' CN chn zz '../cn' '$(touch NEVER_EXECUTE)'; do
  printf '%s\n' "$region" > "$TARGET_ROOT/etc/omarchy/region"
  if apply stable > "$scratch/error" 2>&1; then
    fail "invalid region accepted: $region"
  fi
  cmp "$scratch/before.conf" "$TARGET_ROOT/etc/pacman.conf"
  cmp "$scratch/before.mirrors" "$TARGET_ROOT/etc/pacman.d/mirrorlist"
done
pass "unsupported and malformed regions fail before replacing either config"

printf 'cn\n' > "$TARGET_ROOT/etc/omarchy/region"
mkdir -p "$scratch/incomplete/default/regions/cn/pacman"
cp -a "$ROOT/default/pacman" "$scratch/incomplete/default/"
cp "$ROOT/default/regions/cn/pacman/pacman.conf.append" "$scratch/incomplete/default/regions/cn/pacman/"
if OMARCHY_PATH="$scratch/incomplete" apply stable > "$scratch/error" 2>&1; then
  fail "incomplete region profile accepted"
fi
cmp "$scratch/before.conf" "$TARGET_ROOT/etc/pacman.conf"
cmp "$scratch/before.mirrors" "$TARGET_ROOT/etc/pacman.d/mirrorlist"
pass "missing fragment cannot leave a half-generated config"

# Refresh renders these files unprivileged and hands root plain copies; its
# privileged path is covered in the sudo-boundary sandbox, never on the host.
cp "$TARGET_ROOT/etc/pacman.conf" "$scratch/before.conf"
mkdir -p "$scratch/rendered"
"$ROOT/bin/omarchy-apply-pacman" --render rc "$scratch/rendered" "$TARGET_ROOT"
rg -qxF 'Server = https://pkgs.omarchy.org/rc/$arch' "$scratch/rendered/pacman.conf"
rg -qxF '[archlinuxcn]' "$scratch/rendered/pacman.conf"
[[ $(<"$scratch/rendered/mirrorlist") == $'Server = https://rc-mirror.omarchy.cn/$repo/os/$arch\nServer = https://rc-mirror.omarchy.org/$repo/os/$arch' ]] ||
  fail "render puts the regional channel mirror first"
cmp "$scratch/before.conf" "$TARGET_ROOT/etc/pacman.conf"
pass "render builds the regional channel files without touching the target"

if "$ROOT/bin/omarchy-apply-pacman" --render dev "$scratch/rendered" "$TARGET_ROOT" > "$scratch/error" 2>&1; then
  fail "render accepts a nonexistent dev pacman template"
fi
pass "render rejects channels without pacman templates"

printf 'global\n' > "$TARGET_ROOT/etc/omarchy/region"
apply stable
cmp "$ROOT/default/pacman/pacman-stable.conf" "$TARGET_ROOT/etc/pacman.conf"
cmp "$ROOT/default/pacman/mirrorlist-stable" "$TARGET_ROOT/etc/pacman.d/mirrorlist"
pass "users can opt out of regional repository defaults"

# The shipped China profile is repository defaults only. Language, locale, and
# input methods follow the installer's language choice, not the region.
python3 - <<'PY'
import os
from pathlib import Path

region = Path(os.environ["ROOT"]) / "default/regions/cn"
packages = {line.strip() for line in (region / "packages").read_text().splitlines() if line.strip() and not line.startswith("#")}
assert packages == {"archlinuxcn-keyring"}, packages
assert not (region / "skel").exists()
PY
pass "China profile adds only its repository keyring"

# The installer derives the region from the chosen timezone, so every profile
# needs a mapping, and no timezone may select two regions.
python3 - <<'PY'
import os
from pathlib import Path

zoneinfo = Path("/usr/share/zoneinfo")
owners = {}
for profile in sorted((Path(os.environ["ROOT"]) / "default/regions").iterdir()):
    lines = (profile / "timezones").read_text().splitlines()
    zones = [line.strip() for line in lines if line.strip() and not line.startswith("#")]
    assert zones, f"{profile.name} maps no timezones"
    for zone in zones:
        assert zone not in owners, f"{zone} maps to {owners[zone]} and {profile.name}"
        owners[zone] = profile.name
        if zoneinfo.is_dir():
            assert (zoneinfo / zone).is_file(), f"{profile.name} lists unknown timezone {zone}"

# The installer offers tzdata's backward-compatible names too, so China
# covers every name that links to its two zones and nothing else.
# Without tzdata.zi (minimal containers) only the canonical zones can be
# checked, so completeness is enforced where the host has the link table.
china = {zone for zone, region in owners.items() if region == "cn"}
expected = {"Asia/Shanghai", "Asia/Urumqi"}
tzdata = zoneinfo / "tzdata.zi"
if tzdata.is_file():
    for line in tzdata.read_text().splitlines():
        fields = line.split()
        if len(fields) == 3 and fields[0] == "L" and fields[1] in {"Asia/Shanghai", "Asia/Urumqi"}:
            expected.add(fields[2])
    assert china == expected, (china, expected)
else:
    assert expected <= china, (china, expected)
PY
pass "region profiles map each timezone to at most one region"
