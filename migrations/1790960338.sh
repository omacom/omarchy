echo "Replace the keyboard-backlight and force-igpu sleep hooks earlier releases installed"

# omarchy-hibernation-setup and omarchy-toggle-hybrid-gpu used to copy these
# hooks with cp -p from a 644 file, so the installed copies were never
# executable and systemd-sleep silently skipped them: the keyboard LEDs stayed on
# into S4 (which the hook exists to prevent on ASUS keyboards) and force-igpu
# never detached the dGPU before hibernate. Both scripts now install them 0755.
# Migration 1788662350 replaces copies a user could write, but leaves
# root-owned ones alone, and cp -p from the root-owned packaged source produced
# exactly that: a root-owned 644 hook.
#
# Making those copies executable as they are would switch on old code: every
# earlier keyboard-backlight zeroed any vendor's keyboard LED and never
# restored it, and earlier force-igpu copies call supergfxctl with no timeout
# and miss the hibernate phase of suspend-then-hibernate. So replace any copy
# of an earlier shipped version with the current hook. A copy of the current
# hook, or anything an administrator wrote, keeps its content and mode.
hook_dir=/usr/lib/systemd/system-sleep
source_dir="$OMARCHY_PATH/default/systemd/system-sleep"

declare -A shipped_sha256s=(
  [keyboard-backlight]="f313a81e47401f0d38b8602e5997f52c5286d5e97f74027564ddd515b3d16511 79215eed4da8036e25cd70ad09276823aad92d386a68c69d589d587c93b79c60 21bceaa64e355808ca6c21011564c08a20e305bb7e30939d113fa43347de2b3b"
  [force-igpu]="de620729f0c824225487ab988a53158de7336e4151d594c49641a99ed5740e6b d604e7c4903829563e45fc52188fc5602c3f1bc66e247f0a2cc0a974ed6e57db cbcd9972eb194369947bfcf630909a7c2f24170fb5526355c7d32122d3b1f3be cb619d71989c044e75c0c446af29fc6fb7853e47a29c41800e083c0218a71f3d"
)

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

# Hash as the user when the hook is readable, so an up-to-date machine needs
# no password, and as root otherwise.
file_sha256() {
  local digest

  if [[ -r $1 ]]; then
    digest=$(/usr/bin/sha256sum -- "$1") || return 1
  else
    digest=$(as_root /usr/bin/sha256sum -- "$1") || return 1
  fi
  printf '%s\n' "${digest%% *}"
}

# Only ever remove a path mktemp could have made for this hook.
safe_stage_path() {
  local stage="$1"
  local destination="$2"
  local prefix suffix

  prefix="${destination%/*}/.${destination##*/}.omarchy."
  [[ $stage == "$prefix"* ]] || return 1
  suffix=${stage#"$prefix"}
  [[ $suffix =~ ^[[:alnum:]]{6}$ ]]
}

for hook in keyboard-backlight force-igpu; do
  installed="$hook_dir/$hook"
  [[ -f $installed && ! -L $installed ]] || continue

  if ! digest=$(file_sha256 "$installed"); then
    echo "Could not read $installed; rerun omarchy-migrate to retry" >&2
    exit 1
  fi
  [[ " ${shipped_sha256s[$hook]} " == *" $digest "* ]] || continue
  if ! source_digest=$(/usr/bin/sha256sum -- "$source_dir/$hook"); then
    echo "Could not read $source_dir/$hook; rerun omarchy-migrate to retry" >&2
    exit 1
  fi
  [[ $digest != "${source_digest%% *}" ]] || continue

  # Stage the current hook beside the old one and rename it into place, so a
  # failed copy leaves the shipped version for a retry to recognize.
  # systemd-sleep skips hidden files, so the stage never runs.
  if ! stage=$(as_root /usr/bin/mktemp -- "$hook_dir/.$hook.omarchy.XXXXXX") || ! safe_stage_path "$stage" "$installed"; then
    echo "Could not stage a replacement for $installed; rerun omarchy-migrate to retry" >&2
    exit 1
  fi
  if ! { as_root /usr/bin/install -m 0755 -T -- "$source_dir/$hook" "$stage" && as_root /usr/bin/mv -Tf -- "$stage" "$installed"; }; then
    as_root /usr/bin/rm -f -- "$stage"
    echo "Could not replace $installed; rerun omarchy-migrate to retry" >&2
    exit 1
  fi
done
