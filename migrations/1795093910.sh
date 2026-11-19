echo "Relink agent skills for the omarchy-make-* renames"

# web-game and omarchy-app became omarchy-make-game and omarchy-make-app, and
# omarchy-make-theme and omarchy-make-plugin are new. Relinking drops the links
# to the old names and adds the new ones.
"$OMARCHY_PATH/bin/omarchy-agent-skills-link"
