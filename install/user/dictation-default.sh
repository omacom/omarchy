# The settings package presets Superwhisper as the dictation backend, and it has
# no aarch64 build. A new user there starts with no backend selected and picks
# one in Setup > Defaults > Dictation. Any other selection is left alone.
dictation_default="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/defaults/dictation"
if ! omarchy-hw-x86 && omarchy-cmd-missing superwhisper &&
  [[ -f $dictation_default && $(<"$dictation_default") == "superwhisper" ]]; then
  rm -f "$dictation_default"
fi
