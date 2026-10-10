echo "Point XCompose at a home-local table so sandboxed apps keep compose"

# ~/.XCompose with an absolute include into /usr/share/omarchy parses on the
# host, but Steam's pressure-vessel (and other sandboxes that bind $HOME without
# the host /usr) cannot open that path. xkbcommon then rejects the whole file,
# so every compose sequence dies inside the container. Omarchy 3 used a
# %H-relative include; restore that shape with a real home-local copy of the
# packaged table rather than a checkout symlink under ~/.local/share/omarchy.

xcompose="$HOME/.XCompose"

omarchy-refresh-xcompose

[[ -f $xcompose ]] || exit 0

# Absolute packaged path (fresh Omarchy 4 / upgrade-to-quattro seed) and the
# Omarchy 3 %H/.local/share/... form both become the home-local include.
# Do not restart fcitx5 from an unattended migration: X11 clients (Steam) can
# retain XIM objects owned by the old process and SIGSEGV later (#9541). The
# repaired file is picked up at the next graphical login; fcitx5's ExecStartPre
# also refreshes ~/.XCompose.omarchy then.
if grep -Eq '^[[:space:]]*include[[:space:]]+"(/usr/share/omarchy/default/xcompose|%H/\.local/share/omarchy/default/xcompose|[^"]*/\.local/share/omarchy/default/xcompose)"[[:space:]]*$' "$xcompose"; then
  # Three separate replacements keep the sed program free of nested | groups
  # that trip portable ERE parsing.
  sed -i -E \
    -e 's|^([[:space:]]*include[[:space:]]+")/usr/share/omarchy/default/xcompose("[[:space:]]*)$|\1%H/.XCompose.omarchy\2|' \
    -e 's|^([[:space:]]*include[[:space:]]+")%H/\.local/share/omarchy/default/xcompose("[[:space:]]*)$|\1%H/.XCompose.omarchy\2|' \
    -e 's|^([[:space:]]*include[[:space:]]+")[^"]*/\.local/share/omarchy/default/xcompose("[[:space:]]*)$|\1%H/.XCompose.omarchy\2|' \
    "$xcompose"
fi
