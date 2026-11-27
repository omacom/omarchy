echo "Relink agent skills for the omarchy-diagnose-crash rename"

# diagnose-crash became omarchy-diagnose-crash. Relinking drops the links to
# the old name and adds the new one.
"$OMARCHY_PATH/bin/omarchy-agent-skills-link"
