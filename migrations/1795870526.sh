echo "Switch Chromium browsers that never chose a frame to the system title bar"

# On the system title bar a Chromium browser drops its own frame and gets
# Omarchy's titlebar when it floats, in place of only the empty end of its tab
# strip to drag it by. New profiles start that way; this brings along the ones
# that already exist and never chose.
#
# A running browser writes its own Preferences back when it exits, so one that
# is open can only be switched once it is closed. This is a default, not a
# repair, so declining is fine: those browsers keep their own frame, the
# migration is done, and the setting is the browser's own to change later.
until running=$(omarchy-install-chromium-system-title-bar); do
  # It names the running browsers when they are why it failed. Failing with
  # none named is a write that did not go through, which stays pending.
  [[ -n $running ]] || exit 1

  echo "Still running:"
  echo "$running"
  # An unattended update asks nothing, so it skips. gum draws the prompt on
  # stderr, so it stays attached. Without a terminal to ask in, gum fails,
  # which reads as a decline.
  if [[ ${OMARCHY_UPDATE_UNATTENDED:-0} == "1" ]] || ! gum confirm --affirmative "Continue" --negative "Skip" "Close your browser windows to give them Omarchy's titlebar, then continue"; then
    echo "Left the running browsers on their own frame."
    echo "To switch one later: Settings > Appearance > Use system title bar and borders."
    break
  fi
done
