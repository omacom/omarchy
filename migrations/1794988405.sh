echo "Link every agent skill from the Omarchy tree in use"

# Skills were linked once, at first login, so skills shipped since (web-game)
# never reached existing installs, and a dev-linked checkout's agents kept
# reading the package's copies.
"$OMARCHY_PATH/bin/omarchy-agent-skills-link"
