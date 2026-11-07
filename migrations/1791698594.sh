echo "Save workspace layouts as modes, so a default layout keeps them"

# Workspace layouts were saved as plain Hyprland rules. Floating and the default
# layout read the mode a workspace was given, and a rule names none, so a
# workspace set to scrolling would follow a floating default instead. The old
# toggle wrote to ~/.local/state whatever XDG_STATE_HOME said, so both are read.
for state_home in "$HOME/.local/state" "${XDG_STATE_HOME:-}"; do
  [[ -n $state_home ]] || continue

  for saved in "$state_home"/omarchy/workspace-layouts/*.lua; do
    [[ -f $saved ]] || continue
    # C locale: under tr_TR.UTF-8 [a-z] skips i, which would leave dwindle and
    # scrolling unconverted.
    LC_ALL=C sed -i --follow-symlinks 's/^hl\.workspace_rule({ workspace = "\([0-9]*\)", layout = "\([a-z]*\)" })$/o.workspace_mode({ workspace = "\1", mode = "\2" })/' "$saved"
  done
done
