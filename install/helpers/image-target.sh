# Image builds and the hardware setup they defer to the machine's first boot.
# Sourced by omarchy-apply-hardware and omarchy-provision-hardware; no shebang.
#
# An image is built away from the machine it will run on, so hardware setup
# during the build would describe the builder, not the target. The builder
# declares the build in a root-owned manifest before it runs
# omarchy-apply-system in the image root:
#
#   /var/lib/omarchy/image/target
#     format=1
#     platform=x86|aarch64|aarch64-apple
#
# While it exists, omarchy-apply-hardware queues each hardware leaf in
# /var/lib/omarchy/image/deferred-steps instead of running it, and arms
# omarchy-provision-hardware.service. On the machine's first boot that service,
# or the platform's own first boot, retires the manifest (to target.booted) and
# runs the queue on the real hardware. Unknown manifest keys are ignored so the
# format can grow.
#
# An image carries no pacman master key of its own, or every machine flashed
# from it would share one: where install finalization would make the keyring
# (install/post-install/pacman.sh), a build requests it in
# /var/lib/omarchy/image/pacman-keyring instead, and the first boot makes it
# before any deferred step runs.
#
# The manifest is also the only source of the image's platform: until that boot,
# omarchy-hw-platform reports its platform instead of the build host's, so the
# initramfs, services and packages the build sets up are the target's. It reads
# the manifest by the same rules as omarchy_image_read_manifest below.
#
# Root always uses the fixed paths. Only a non-root test may move them under
# OMARCHY_IMAGE_ROOT, so no environment variable can make a live system defer,
# skip or replay its hardware setup.

omarchy_image_init() {
  if (( EUID == 0 )); then
    omarchy_image_root=""
  elif [[ -n ${OMARCHY_IMAGE_ROOT:-} ]]; then
    omarchy_image_root=$OMARCHY_IMAGE_ROOT
  else
    echo "Error: image setup state is root-owned; run as root" >&2
    return 1
  fi

  omarchy_image_dir=$omarchy_image_root/var/lib/omarchy/image
  omarchy_image_manifest=$omarchy_image_dir/target
  omarchy_image_queue=$omarchy_image_dir/deferred-steps
  omarchy_image_initramfs_baseline=$omarchy_image_dir/initramfs-inputs
  omarchy_image_boot_rebuild=$omarchy_image_dir/boot-rebuild
  omarchy_image_rebuild_unconfirmed=$omarchy_image_dir/boot-rebuild-unconfirmed
  omarchy_image_keyring_request=$omarchy_image_dir/pacman-keyring
  omarchy_image_unit=omarchy-provision-hardware.service
  omarchy_image_systemd_dir=$omarchy_image_root/etc/systemd/system
}

# Owned by whoever runs this (root on a live system), not a symlink, and not
# writable by anyone else.
omarchy_image_trusted() {
  local path=$1 owner mode

  [[ -e $path && ! -L $path ]] || return 1
  read -r owner mode < <(stat -c '%u %a' -- "$path") || return 1
  (( owner == EUID && (8#$mode & 8#022) == 0 ))
}

omarchy_image_manifest_present() {
  [[ -e $omarchy_image_manifest || -L $omarchy_image_manifest ]]
}

# Sets omarchy_image_platform, or fails without guessing whether this is a build.
omarchy_image_read_manifest() {
  local line key value format="" platform=""

  if [[ ! -d $omarchy_image_dir || ! -f $omarchy_image_manifest ]] || ! omarchy_image_trusted "$omarchy_image_dir" ||
    ! omarchy_image_trusted "$omarchy_image_manifest"; then
    echo "Error: $omarchy_image_manifest is not a root-owned regular file" >&2
    return 1
  fi

  while IFS= read -r line || [[ -n $line ]]; do
    [[ -n $line && $line != \#* ]] || continue
    if [[ $line != *=* ]]; then
      echo "Error: $omarchy_image_manifest is malformed: $line" >&2
      return 1
    fi
    key=${line%%=*}
    value=${line#*=}
    case $key in
      format) format=$value ;;
      platform) platform=$value ;;
    esac
  done <"$omarchy_image_manifest"

  if [[ $format != "1" ]]; then
    echo "Error: $omarchy_image_manifest is not format=1" >&2
    return 1
  fi
  # Builders written before the platform names settled say apple-silicon,
  # generic-aarch64 or generic (as omarchy-hw-platform reads them too).
  case $platform in
    apple-silicon) platform=aarch64-apple ;;
    generic-aarch64) platform=aarch64 ;;
    generic) platform=x86 ;;
  esac
  case $platform in
    x86 | aarch64 | aarch64-apple) ;;
    *)
      echo "Error: $omarchy_image_manifest names no known platform: ${platform:-none}" >&2
      return 1
      ;;
  esac

  omarchy_image_platform=$platform
}

# Holds the image state still for the rest of the caller, so hardware setup and
# a first-boot run never overlap or decide from a manifest the other retires.
# A machine that was never an image has no state and nothing to lock.
omarchy_image_lock() {
  [[ -e $omarchy_image_dir || -L $omarchy_image_dir ]] || return 0
  if [[ ! -d $omarchy_image_dir ]] || ! omarchy_image_trusted "$omarchy_image_dir"; then
    echo "Error: $omarchy_image_dir is not a root-owned directory" >&2
    return 1
  fi
  exec {omarchy_image_lock_fd}>>"$omarchy_image_dir/lock" || return 1
  flock "$omarchy_image_lock_fd"
}

omarchy_image_write_queue() {
  local tmp

  tmp=$(mktemp "$omarchy_image_dir/.deferred-steps.XXXXXX") || return 1
  if (( $# )); then
    printf '%s\n' "$@" >"$tmp" || { rm -f "$tmp"; return 1; }
  fi
  chmod 0644 "$tmp" && mv -f "$tmp" "$omarchy_image_queue"
}

# Queue every leaf install/hardware/all.sh would run, in its order, running
# none of them, then arm the first-boot service. Rerunning rewrites the same queue.
omarchy_image_defer_hardware() {
  local listing
  local -a steps=()

  listing=$(
    run_logged() {
      [[ $1 == "$OMARCHY_INSTALL"/hardware/*.sh && $1 != *..* ]] || {
        echo "Error: cannot defer a step outside the hardware setup: $1" >&2
        exit 1
      }
      printf 'install/%s\n' "${1#"$OMARCHY_INSTALL"/}"
    }
    source "$OMARCHY_INSTALL/hardware/all.sh"
  ) || return 1

  [[ -z $listing ]] || mapfile -t steps <<<"$listing"
  omarchy_image_write_queue "${steps[@]}" || return 1

  install -d -m 0755 "$omarchy_image_systemd_dir/multi-user.target.wants" &&
    install -m 0644 "$OMARCHY_INSTALL/provisioning/$omarchy_image_unit" "$omarchy_image_systemd_dir/$omarchy_image_unit" &&
    ln -sfn "/etc/systemd/system/$omarchy_image_unit" "$omarchy_image_systemd_dir/multi-user.target.wants/$omarchy_image_unit" ||
    return 1

  echo "Image build for $omarchy_image_platform: deferred ${#steps[@]} hardware steps to first boot"
}

# limine-mkinitcpio skips a kernel it could not build or install (a full boot
# partition, say) and still exits 0, so its output ($1) decides: at least one
# image started, every image it started reports success in mkinitcpio's own
# line, and nothing it ran reported an error. A UKI build reports both an
# initcpio and a unified image. mkinitcpio and the hook script prefix errors
# with ERROR; limine-entry-tool, which copies the images to the boot partition,
# prints most of its own as "Failed to ...", "Command failed: ...", "The file:
# ... not found", "Invalid 'initrd=...", "Repeated hash mismatches...",
# "Kernel name: ... is invalid" or "FAT32 boot partition not found...".
omarchy_image_limine_rebuild_confirmed() {
  local output uki initcpio built_uki built_initcpio

  output=$(sed 's/\x1b\[[0-9;]*m//g' <<<"$1")
  ! grep -Eq '^((==> )?(ERROR|Error|error)\b|Failed to |Command failed:|The file: |Invalid '"'"'initrd=|Repeated hash mismatches|Kernel name: |FAT32 boot partition not found)' <<<"$output" ||
    return 1
  uki=$(grep -Ec '^Building UKI (fallback )?for ' <<<"$output") || true
  initcpio=$(grep -Ec '^Building (fallback )?initramfs for ' <<<"$output") || true
  built_uki=$(grep -Ec '^==> Unified kernel image generation successful' <<<"$output") || true
  built_initcpio=$(grep -Ec '^==> Initcpio image generation successful' <<<"$output") || true
  (( uki + initcpio > 0 && built_uki >= uki && built_initcpio >= initcpio + uki ))
}

# Rebuild the boot images through Limine, appending its output to the log ($1).
# Returns 0 when the rebuild is confirmed, 1 when it ran but can't be
# confirmed, and 2 when limine-mkinitcpio itself failed or its images couldn't
# be flushed. A confirmed rebuild clears the marker an unconfirmed one left for
# owner setup, only once the images are on disk: the boot partition is another
# filesystem, so a power cut must not keep the marker's removal and lose them.
omarchy_image_limine_rebuild() {
  local log=$1 output
  local -
  set -o pipefail

  output=$(limine-mkinitcpio </dev/null 2>&1 | tee -a "$log") || return 2
  omarchy_image_limine_rebuild_confirmed "$output" || return 1
  sync || return 2
  rm -f "$omarchy_image_rebuild_unconfirmed"
}
