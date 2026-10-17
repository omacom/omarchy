echo "Activate the Omarchy theme for existing T3 Code installs"

omarchy-pkg-present t3code-bin || exit 0

# The theme steps of omarchy-install-ai-t3-code, without the install around them
# or the launch after them, so an update does not open T3 Code.
T3CODE_HOME="${T3CODE_HOME:-$HOME/.t3}"
mkdir -p "$T3CODE_HOME/userdata"

if [[ ! -f $HOME/.local/state/omarchy/current/theme/t3code.json ]]; then
  omarchy-theme-refresh
fi

omarchy-theme-set-t3code
t3 theme set omarchy --base-dir "$T3CODE_HOME"
