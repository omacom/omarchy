echo "Make Grok Build follow the Omarchy terminal palette"

[[ -d ${GROK_HOME:-$HOME/.grok} ]] || exit 0
omarchy-theme-set-grok --activate
