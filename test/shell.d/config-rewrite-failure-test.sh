#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"
require_command jq

case_root=$(mktemp -d)
trap 'chmod -R u+w "$case_root"; rm -rf "$case_root"' EXIT
mkdir -p "$case_root/bin" "$case_root/staging"
export TMPDIR="$case_root/staging"
cat >"$case_root/bin/omarchy-shell" <<'STUB'
#!/bin/bash
exit 0
STUB
cat >"$case_root/bin/omarchy-agent-usage-update" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$case_root/bin/"*
export PATH="$case_root/bin:$ROOT/bin:$PATH"

assert_no_staging() {
  [[ -z $(find "$TMPDIR" -mindepth 1 -print -quit) ]] || fail "failed rewrite cleans its staging file"
}

for variant in kitty-replace kitty-insert foot-replace foot-insert; do
  home="$case_root/$variant"
  mkdir -p "$home/.config/kitty" "$home/.config/foot"
  case "$variant" in
    kitty-replace) config="$home/.config/kitty/kitty.conf"; printf 'map shift+enter send_text all \\e[13;2u\n' >"$config" ;;
    kitty-insert) config="$home/.config/kitty/kitty.conf"; printf 'map shift+insert paste_from_clipboard\n' >"$config" ;;
    foot-replace) config="$home/.config/foot/foot.ini"; printf '[text-bindings]\n\\x1b[13;2u=Shift+Return\n' >"$config" ;;
    foot-insert) config="$home/.config/foot/foot.ini"; printf '[text-bindings]\n' >"$config" ;;
  esac
  cp "$config" "$case_root/before"
  printf '#!/bin/bash\nexit 17\n' >"$case_root/bin/awk"
  chmod +x "$case_root/bin/awk"
  status=0
  HOME="$home" bash -euo pipefail "$ROOT/migrations/1780057136.sh" >"$case_root/output" 2>&1 || status=$?
  (( status != 0 )) || fail "$variant transformation failure remains pending"
  cmp -s "$config" "$case_root/before" || fail "$variant transform failure preserves original"
  assert_no_staging
  rm "$case_root/bin/awk"
  pass "$variant transformation failure is propagated and cleaned up"
done

for migration in 1780294774 1784989000 1785344985 1786099804; do
  home="$case_root/$migration"
  mkdir -p "$home/.config/omarchy"
  config="$home/.config/omarchy/shell.json"
  printf '{"bar":{"layout":{"center":[]}}}\n' >"$config"
  cp "$config" "$case_root/before"
  printf '#!/bin/bash\nexit 17\n' >"$case_root/bin/jq"
  chmod +x "$case_root/bin/jq"
  status=0
  HOME="$home" bash -euo pipefail "$ROOT/migrations/$migration.sh" >"$case_root/output" 2>&1 || status=$?
  (( status != 0 )) || fail "$migration jq failure remains pending"
  cmp -s "$config" "$case_root/before" || fail "$migration transform failure preserves original"
  assert_no_staging
  rm "$case_root/bin/jq"
  pass "$migration transformation failure is propagated and cleaned up"
done

for variant in hyprland nvim; do
  home="$case_root/$variant-failure"
  if [[ $variant == hyprland ]]; then
    migration=1781063758
    config="$home/.config/hypr/hyprland.lua"
    mkdir -p "$(dirname "$config")"
    printf 'require("autostart")\n' >"$config"
    command=awk
    printf '#!/bin/bash\nexit 17\n' >"$case_root/bin/awk"
  else
    migration=1781587663
    config="$home/.config/nvim/lua/config/options.lua"
    mkdir -p "$(dirname "$config")"
    printf 'vim.opt.number = true\n' >"$config"
    command=cat
    cat >"$case_root/bin/install" <<'STUB'
#!/bin/bash
[[ $1 == -m && $2 == 0644 && $3 == /usr/share/omarchy-nvim/config/lua/config/remote_clipboard.lua ]] || exit 99
[[ $4 == "$HOME/.config/nvim/lua/config/remote_clipboard.lua" ]] || exit 99
printf '%s\n' '-- synthetic provider' >"$4"
STUB
    cat >"$case_root/bin/cat" <<'STUB'
#!/bin/bash
[[ ${1:-} != "$HOME/.config/nvim/lua/config/options.lua" ]] || exit 17
exec /bin/cat "$@"
STUB
    chmod +x "$case_root/bin/install"
  fi
  cp "$config" "$case_root/before"
  chmod +x "$case_root/bin/$command"
  status=0
  HOME="$home" bash -euo pipefail "$ROOT/migrations/$migration.sh" >"$case_root/output" 2>&1 || status=$?
  (( status != 0 )) || fail "$variant failed rewrite remains pending"
  cmp -s "$config" "$case_root/before" || fail "$variant failure preserves original"
  assert_no_staging
  rm "$case_root/bin/$command"
  pass "$variant failed rewrite cleans its staging file"
done
rm "$case_root/bin/install"

# Exercise real write permissions, not a stub that merely returns failure.
if (( EUID == 0 )); then
  echo 'skip - read-only config test requires an unprivileged user'
else
  home="$case_root/readonly"
  mkdir -p "$home/.config/kitty"
  config="$home/.config/kitty/kitty.conf"
  printf 'map shift+insert paste_from_clipboard\n' >"$config"
  cp "$config" "$case_root/before"
  chmod 444 "$config"
  status=0
  HOME="$home" bash -euo pipefail "$ROOT/migrations/1780057136.sh" >"$case_root/output" 2>&1 || status=$?
  (( status != 0 )) || fail "read-only configuration remains pending"
  cmp -s "$config" "$case_root/before" || fail "read-only configuration remains unchanged"
  assert_no_staging
  pass "read-only config remains pending without leaking its staging file"
fi

home="$case_root/terminal-links"
mkdir -p "$home/dotfiles" "$home/.config/alacritty" "$home/.config/ghostty"
printf '{ key = "Return", mods = "Shift", chars = "\\u001B\\r" }\n' >"$home/dotfiles/alacritty"
printf 'keybind = shift+enter=csi:13;4u\n' >"$home/dotfiles/ghostty"
ln -s "$home/dotfiles/alacritty" "$home/.config/alacritty/alacritty.toml"
ln -s "$home/dotfiles/ghostty" "$home/.config/ghostty/config"
HOME="$home" bash -euo pipefail "$ROOT/migrations/1780057136.sh" >/dev/null
[[ -L $home/.config/alacritty/alacritty.toml && -L $home/.config/ghostty/config ]] || fail "terminal migration preserves symlinks"
grep -Fq '\u001B[13;2u' "$home/dotfiles/alacritty" || fail "alacritty target receives new binding"
grep -Fq 'keybind = shift+enter=csi:13;2u' "$home/dotfiles/ghostty" || fail "ghostty target receives new binding"
pass "terminal migration updates symlink targets"

home="$case_root/shell-link"
mkdir -p "$home/dotfiles" "$home/.config/omarchy"
printf '{"bar":{"position":"top"}}\n' >"$home/dotfiles/shell.json"
chmod 640 "$home/dotfiles/shell.json"
ln -s "$home/dotfiles/shell.json" "$home/.config/omarchy/shell.json"
HOME="$home" OMARCHY_PATH="$ROOT" bash "$ROOT/bin/omarchy-bar" position bottom
[[ -L $home/.config/omarchy/shell.json ]] || fail "bar update preserves shell.json symlink"
[[ $(stat -c '%a' "$home/dotfiles/shell.json") == 640 ]] || fail "bar update preserves target mode"
[[ $(jq -r '.bar.position' "$home/dotfiles/shell.json") == bottom ]] || fail "bar update changes target content"
[[ -z $(find "$home/dotfiles" -name '.shell-config.*' -print -quit) ]] || fail "bar update cleans staging file"
pass "bar update atomically replaces the resolved target with its existing mode"

cp "$home/dotfiles/shell.json" "$case_root/before"
printf '#!/bin/bash\nexit 17\n' >"$case_root/bin/jq"
chmod +x "$case_root/bin/jq"
status=0
HOME="$home" OMARCHY_PATH="$ROOT" bash "$ROOT/bin/omarchy-bar" position top >"$case_root/output" 2>&1 || status=$?
rm "$case_root/bin/jq"
(( status != 0 )) || fail "bar transformation failure is reported"
[[ -L $home/.config/omarchy/shell.json ]] || fail "failed bar update preserves symlink"
cmp -s "$home/dotfiles/shell.json" "$case_root/before" || fail "failed bar update preserves content"
[[ -z $(find "$home/dotfiles" -name '.shell-config.*' -print -quit) ]] || fail "failed bar update cleans staging file"
pass "failed bar update keeps the linked config intact and cleans staging"

home="$case_root/new-shell"
HOME="$home" OMARCHY_PATH="$ROOT" bash "$ROOT/bin/omarchy-bar" position bottom
[[ $(stat -c '%a' "$home/.config/omarchy/shell.json") == 600 ]] || fail "new shell config remains private"
[[ $(jq -r '.bar.position' "$home/.config/omarchy/shell.json") == bottom ]] || fail "new shell config receives requested update"
pass "new shell config starts with private permissions"
