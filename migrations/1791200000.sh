echo "Rename the bar-off toggle flag to bar-hidden"

# The bar toggle used to pass its `on`/`off` arguments straight through to a
# flag named `bar-off`, which produced inverted behaviour: `omarchy toggle bar
# on` hid the bar. The flag has been renamed to `bar-hidden` so the flag name
# matches the state the user is asking about, and the helper now maps its
# arguments so `on`/`off` line up with bar visibility. Move any existing flag
# the user had set under the old name across, and leave a fresh absent flag
# behind when none existed (the absence of the file is what now means "bar
# visible"), so the bar lands the same place it was before the upgrade.

flag_dir="$HOME/.local/state/omarchy/toggles"
old_flag="$flag_dir/bar-off"
new_flag="$flag_dir/bar-hidden"

if [[ -f $old_flag ]]; then
  mv "$old_flag" "$new_flag"
elif [[ ! -f $new_flag ]]; then
  # Ensure the directory exists so the bar's FileView watches it and so the
  # user can `touch` the flag without mkdir path races.
  mkdir -p "$flag_dir"
fi
