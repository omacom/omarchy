echo "Switch machines on linux-omarchy from v4l2loopback-dkms to prebuilt linux-omarchy-v4l2loopback"

# linux-omarchy-v4l2loopback ships the v4l2loopback module built and signed
# with each linux-omarchy kernel, so it loads under Secure Boot without MOK
# enrollment and kernel updates no longer compile it via DKMS. It only covers
# linux-omarchy, so machines with another kernel installed (including Apple
# Silicon Macs on linux-aurora) stay on DKMS.
omarchy-pkg-present v4l2loopback-dkms linux-omarchy || exit 0

pkgbases=$(cat /usr/lib/modules/*/pkgbase 2>/dev/null | sort -u || true)
[[ $pkgbases == "linux-omarchy" ]] || exit 0

# Check whether any installed package still depends on v4l2loopback-dkms by
# name instead of the virtual V4L2LOOPBACK-MODULE. Check permanent no-ops
# (third-party packages) before any exit-75 deferral so we never block the
# migration queue on a machine we intend to leave on DKMS.
pkg_hard_depends_on_v4l2loopback_dkms() {
  LC_ALL=C pacman -Qi "$1" 2>/dev/null | awk '
    /^Depends On[[:space:]]*:/ { sub(/^[^:]*:[[:space:]]*/, ""); in_deps = 1 }
    /^Optional Deps[[:space:]]*:/ { in_deps = 0 }
    in_deps {
      for (i = 1; i <= NF; i++) {
        dep = $i
        sub(/[<>=].*/, "", dep)
        if (dep == "v4l2loopback-dkms") found = 1
      }
    }
    END { exit(found ? 0 : 1) }
  '
}

required_by=$(
  LC_ALL=C pacman -Qi v4l2loopback-dkms 2>/dev/null | awk '
    /^Required By[[:space:]]*:/ { sub(/^[^:]*:[[:space:]]*/, ""); in_req = 1 }
    /^Optional For[[:space:]]*:/ { in_req = 0 }
    in_req {
      for (i = 1; i <= NF; i++) {
        if ($i != "None") print $i
      }
    }
  ' || true
)

waiting_support_pkg=""
if [[ -n $required_by ]]; then
  while IFS= read -r pkg; do
    [[ -n $pkg ]] || continue
    if pkg_hard_depends_on_v4l2loopback_dkms "$pkg"; then
      case $pkg in
        asus-zenbook-a16-support|anduril-bluechip-support|microsoft-surface-laptop-7-support)
          if pacman -Si "$pkg" &>/dev/null; then
            waiting_support_pkg=$pkg
          else
            exit 0
          fi
          ;;
        *)
          exit 0
          ;;
      esac
    fi
  done <<< "$required_by"
fi

if [[ -n $waiting_support_pkg ]]; then
  echo "Waiting for $waiting_support_pkg to update past its hard dependency on v4l2loopback-dkms"
  exit 75
fi

# Verify configured repos offer a linux-omarchy-v4l2loopback matching the
# installed linux-omarchy kernel before touching anything; defer (75) if the
# package has not landed in this channel yet.
installed_kernel=$(pacman -Q linux-omarchy 2>/dev/null | awk '{print $2}' || true)
repo_info=$(LC_ALL=C pacman -Si linux-omarchy-v4l2loopback 2>/dev/null || true)
repo_kernel_dep=$(
  awk '
    /^Depends On[[:space:]]*:/ { sub(/^[^:]*:[[:space:]]*/, ""); in_deps = 1 }
    /^Optional Deps[[:space:]]*:/ { in_deps = 0 }
    in_deps && !found {
      for (i = 1; i <= NF; i++) {
        if ($i ~ /^linux-omarchy=/) {
          sub(/^linux-omarchy=/, "", $i)
          print $i
          found = 1
          break
        }
      }
    }
  ' <<< "$repo_info" || true
)
if [[ -z $installed_kernel || -z $repo_info || ( -n $repo_kernel_dep && $repo_kernel_dep != "$installed_kernel" ) ]]; then
  echo "Waiting for linux-omarchy-v4l2loopback matching linux-omarchy ${installed_kernel:-unknown}"
  exit 75
fi

if pacman -Qeq v4l2loopback-dkms &>/dev/null; then
  reason_flag="--asexplicit"
else
  reason_flag="--asdeps"
fi

# linux-omarchy-v4l2loopback does not declare conflicts=(v4l2loopback-dkms),
# so install the prebuilt module first (keeping V4L2LOOPBACK-MODULE satisfied),
# then drop the DKMS package so updates/dkms cannot shadow the signed module.
sudo pacman -S --noconfirm --needed "$reason_flag" linux-omarchy-v4l2loopback
omarchy-pkg-drop v4l2loopback-dkms

# Confirm depmod resolves v4l2loopback to extramodules rather than a stale DKMS copy.
for pkgbase in /usr/lib/modules/*/pkgbase; do
  [[ -f $pkgbase ]] || continue
  kver=$(basename "$(dirname "$pkgbase")")
  mod_path=$(modinfo -k "$kver" -n v4l2loopback 2>/dev/null || true)
  if [[ $mod_path == */updates/* ]]; then
    sudo depmod "$kver"
  fi
done
