echo "Install Reach, for one keyboard and mouse across your Circle machines"

# Reach runs idle until it's given a row of machines (from its panel, or from
# another machine), and only machines on Circle can reach its port.
if omarchy-pkg-missing reach; then
  # Until the package lands, stay pending without stopping the update.
  if ! pacman -Si reach >/dev/null 2>&1; then
    echo "Waiting for the reach package"
    exit 75
  fi
  omarchy-pkg-add reach
fi

# ufw skips a rule it already has, so this is safe to run for every user.
if omarchy-cmd-present ufw; then
  sudo ufw allow in on circle0 to any port 24850 proto tcp comment 'reach' >/dev/null
fi

systemctl --user enable --now reach.service

# Its bar icon stays hidden until Circle is up and another of your machines is
# close by, so it can sit in every bar: before Network, or at the end of the
# right section. Written into shell.json, which the shell hot-reloads, so it
# needs no running shell. Without a shell.json of its own, or a layout in it,
# the bar follows the default layout, which has Reach already.
config_file="$HOME/.config/omarchy/shell.json"
[[ -s $config_file ]] || exit 0

# Written through, so a shell.json linked from dotfiles stays a link.
tmp=$(mktemp)
if jq '
  def entry_id: if type == "object" then (.id // "") elif type == "string" then . else "" end;
  def ids: [.bar.layout[]? | arrays | .[] | entry_id];

  if (.bar.layout | type) != "object" or (ids | index("omarchy.reach")) != null then
    .
  elif (ids | index("omarchy.network")) != null then
    .bar.layout[] |= (if type == "array" then [.[] | if entry_id == "omarchy.network" then { id: "omarchy.reach" }, . else . end] else . end)
  else
    .bar.layout.right = ((.bar.layout.right // []) + [{ id: "omarchy.reach" }])
  end
' "$config_file" >"$tmp"; then
  cat "$tmp" >"$config_file"
else
  # A shell.json jq can't read stays as it is, and the migration pending.
  status=$?
  rm -f "$tmp"
  exit "$status"
fi
rm -f "$tmp"
