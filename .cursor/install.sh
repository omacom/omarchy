#!/bin/bash

# Idempotent Cloud Agent bootstrap.
#
# Spike (2026-09-08): Hyprland 0.56.2 + Aquamarine 0.15 cannot start without
# /dev/dri. On this Omarchy host, hiding DRM with bwrap --tmpfs /dev/dri and
# AQ_NO_KMS_REQUIREMENT=1 aborted with CBackend::create() failed!. In a
# throwaway archlinux:base-devel container (no --device, no seatd/logind)
# Aquamarine logged "Cannot open backend: no allocator available" and
# "could not find a GPU". A custom Arch image therefore cannot host a live
# Omarchy (Hyprland + Quickshell) session on Cloud Agents, which also have
# no /dev/dri. Cursor computer-use is documented as Debian/Ubuntu-only, so
# this script stays on the default Ubuntu image and only installs the tools
# ./test/cli and ./test/shell need. Graphical acceptance stays on omarchy-iso
# VMs. Do not replay install/ or start Hyprland here.

set -euo pipefail

WORK_DIR="$HOME/Work/omacom"
PKGS_DIR="$WORK_DIR/omarchy-pkgs"
ISO_DIR="$WORK_DIR/omarchy-iso"

install_ubuntu_tools() {
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ffmpeg \
    gawk \
    imagemagick \
    jq \
    libxkbcommon-tools \
    lua5.4 \
    plocate \
    python-is-python3 \
    qrencode \
    ripgrep

  sudo update-alternatives --install /usr/bin/awk awk /usr/bin/gawk 100
  sudo update-alternatives --set awk /usr/bin/gawk
  sudo update-alternatives --install /usr/bin/lua lua /usr/bin/lua5.4 100

  if ! command -v magick >/dev/null; then
    if command -v convert >/dev/null; then
      sudo ln -sfn "$(command -v convert)" /usr/local/bin/magick
    fi
  fi
}

ensure_checkout() {
  local dest="$1"
  local url="$2"
  local marker="${3:-.git}"

  if [[ -e $dest/$marker ]]; then
    git -C "$dest" pull --ff-only || true
    return 0
  fi

  mkdir -p "$(dirname "$dest")"
  git clone --depth 1 "$url" "$dest"
}

if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  if [[ ${ID:-} == "ubuntu" || ${ID:-} == "debian" || ${ID_LIKE:-} == *debian* ]]; then
    install_ubuntu_tools
  fi
fi

ensure_checkout "$PKGS_DIR" https://github.com/omacom-io/omarchy-pkgs.git pkgbuilds
ensure_checkout "$ISO_DIR" https://github.com/omacom/omarchy-iso.git .git
