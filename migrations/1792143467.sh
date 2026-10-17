echo "Finish Superwhisper's per-user setup for installs that preset it"

# Fresh installs preset Superwhisper as the dictation backend but never ran
# its per-user setup, so Settings could not save and the bar had no panel.
# The first-run step skips every install that does not need it; this reaches
# installs whose first run already completed.
bash "$OMARCHY_PATH/install/user/first-run/setup-superwhisper.sh"
