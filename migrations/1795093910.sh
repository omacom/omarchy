echo "Relink agent skills for the omarchy-make-* and omarchy-contribute skills"

# web-game and omarchy-app became omarchy-make-game and omarchy-make-app, and
# omarchy-make-theme, omarchy-make-plugin and omarchy-contribute are new.
# Relinking drops the links to the old names and adds the new ones.
"$OMARCHY_PATH/bin/omarchy-agent-skills-link"
