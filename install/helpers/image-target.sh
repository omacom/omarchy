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
#     platform=apple-silicon|qualcomm|generic-aarch64|generic
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
  case $platform in
    apple-silicon | qualcomm | generic-aarch64 | generic) ;;
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
