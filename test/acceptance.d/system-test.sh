#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

status=0

verify_core_packages() {
  local package
  local manifest="$OMARCHY_PATH/install/omarchy-base.packages"
  local -a missing=()

  # Without this, a missing manifest reads as an empty package list and the
  # audit passes having checked nothing.
  [[ -f $manifest ]] || fail "all Omarchy core packages are installed" "package manifest not found: $manifest"

  while IFS= read -r package; do
    [[ -z $package || $package == \#* ]] && continue
    pacman -Q "$package" >/dev/null 2>&1 || missing+=("$package")
  done <"$manifest"

  (( ${#missing[@]} == 0 )) || fail "all Omarchy core packages are installed" "missing packages: ${missing[*]}"
  pass "all Omarchy core packages are installed (${#missing[@]} missing)"
}

verify_defaults() {
  [[ $(omarchy-default-browser) == "chromium" ]] || fail "Chromium is the default browser"
  pass "Chromium is the default browser"

  [[ $(omarchy-default-terminal) == "foot" ]] || fail "Foot is the default terminal"
  pass "Foot is the default terminal"

  [[ $(omarchy-default-editor) == "nvim" ]] || fail "Neovim is the default editor"
  pass "Neovim is the default editor"

  [[ $(omarchy-theme-current) != "Unknown" ]] || fail "a current theme is configured"
  pass "a current theme is configured"

  [[ $(omarchy-theme-bg-current) != "Unknown" ]] || fail "a current background is configured"
  pass "a current background is configured"

  [[ -n $(omarchy-font-current) ]] || fail "a monospace font is configured"
  pass "a monospace font is configured"

  [[ $(xdg-mime query default x-scheme-handler/http) == "chromium.desktop" ]] || fail "HTTP MIME handling uses Chromium"
  [[ $(xdg-mime query default inode/directory) == "org.gnome.Nautilus.desktop" ]] || fail "directory MIME handling uses Nautilus"
  pass "desktop MIME handlers are configured"
}

verify_services() {
  local unit

  for unit in \
    avahi-daemon.service \
    NetworkManager.service power-profiles-daemon.service sddm.service \
    systemd-resolved.service ufw.service; do
    systemctl is-enabled --quiet "$unit" || fail "core system services are enabled" "$unit is not enabled"
  done
  pass "core system services are enabled"

  for unit in NetworkManager.service systemd-resolved.service ufw.service; do
    systemctl is-active --quiet "$unit" || fail "critical system services are running" "$unit is not active"
  done
  pass "critical system services are running"

  systemctl --user is-active --quiet pipewire.service pipewire-pulse.service wireplumber.service ||
    fail "user audio services are running"
  pass "user audio services are running"
}

verify_runtime_tools() {
  [[ $(timeout 10 podman info --format '{{.Host.Security.Rootless}}') == true ]] ||
    fail "Podman runs rootless for the desktop user"
  podman-compose --version >/dev/null || fail "Podman Compose is installed"
  podman-tui version >/dev/null || fail "Podman TUI is installed"
  systemctl --user is-enabled --quiet podman.socket podman-restart.service ||
    fail "Podman user services are enabled"
  if pacman -Q podman-docker >/dev/null 2>&1; then
    [[ $(pacman -Qqo /usr/bin/docker) == "podman-docker" ]] || fail "Docker command must be provided by Podman"
    [[ $(timeout 10 docker info --format '{{.Host.Security.Rootless}}') == true ]] ||
      fail "Docker compatibility command runs rootless Podman"
    timeout 10 docker compose version >/dev/null || fail "Docker Compose compatibility command is runnable"
  fi
  [[ $(pacman -Qq docker 2>/dev/null) != "docker" ]] || fail "Docker Engine package must be absent"
  ! systemctl is-active --quiet docker.socket docker.service || fail "Docker must not be running"
  ! id -nG | grep -qw docker || fail "desktop user must not be in the docker group"
  pass "Podman is rootless, installed compatibility works and Docker Engine is absent"

  nvim --headless '+qa' >/dev/null 2>&1 || fail "Neovim starts headlessly"
  pass "Neovim starts headlessly"

  timeout 10 fastfetch --pipe false >/dev/null 2>&1 || fail "Fastfetch can read system information"
  pass "Fastfetch can read system information"

  git --version >/dev/null || fail "Git is installed and runnable"
  tmux -V >/dev/null || fail "Tmux is installed and runnable"
  mise --version >/dev/null || fail "Mise is installed and runnable"
  pass "core terminal tools are runnable"
}

verify_user_setup() {
  local directory

  for directory in DESKTOP DOCUMENTS DOWNLOAD PICTURES; do
    [[ -d $(xdg-user-dir "$directory") ]] || fail "XDG user directories exist" "$directory is missing"
  done
  pass "XDG user directories exist"

  [[ -e $HOME/.local/state/omarchy/current/theme ]] || fail "current theme state exists"
  [[ -e $HOME/.local/state/omarchy/current/background ]] || fail "current background state exists"
  [[ -s $HOME/.config/omarchy/shell.json ]] || fail "shell configuration exists"
  jq empty "$HOME/.config/omarchy/shell.json" || fail "shell configuration is valid JSON"
  pass "Omarchy user state and shell configuration exist"
}

for check in verify_core_packages verify_defaults verify_services verify_runtime_tools verify_user_setup; do
  if ! ("$check"); then
    status=1
  fi
done

exit $status
