echo "Render the OpenClaw palette for the current theme and hand it to OpenClaw"

# The palette is generated with the rest of the theme, so a theme applied
# before the template existed has none yet, and an OpenClaw installed after
# this update would find nothing to follow until the next theme switch. Render
# it for everyone by re-staging the current theme. An install without a
# current theme has nothing to render; one whose theme has since been removed
# has nothing to render it from, and gets the palette with its next theme.
# Anything else that stops the refresh keeps this pending, as a migration
# that could not finish must.
if [[ ! -f $HOME/.local/state/omarchy/current/theme/openclaw.json ]]; then
  theme_name_path="$HOME/.local/state/omarchy/current/theme.name"
  [[ -s $theme_name_path ]] || exit 0
  theme_name=$(<"$theme_name_path")

  if [[ ! -d $OMARCHY_PATH/themes/$theme_name && ! -d $HOME/.config/omarchy/themes/$theme_name ]]; then
    echo "Theme '$theme_name' no longer exists; the palette renders with the next theme"
    exit 0
  fi

  omarchy-theme-refresh

  # A refresh that ran through without rendering the palette is not done.
  if [[ ! -f $HOME/.local/state/omarchy/current/theme/openclaw.json ]]; then
    echo "The theme was refreshed but no OpenClaw palette was rendered; leaving this to try again" >&2
    exit 1
  fi
fi

# Only an OpenClaw already installed gets the hand-over now; one installed
# later gets it from its own onboarding.
omarchy-pkg-present openclaw || exit 0

# Through OpenClaw's own config command, the same as a fresh install, and only
# where no theme was chosen in OpenClaw. An OpenClaw that is not set up is
# told and skipped; one that refuses the write is cosmetic and must not hold
# up later migrations.
omarchy-theme-set-openclaw --activate || true
