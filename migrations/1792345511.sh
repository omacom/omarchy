echo "Replace the T3 Code package with the T3 Code app, which updates itself"

if omarchy-pkg-present t3code-nightly-bin; then
  channel="nightly"
elif omarchy-pkg-present t3code-bin; then
  channel="stable"
else
  exit 0
fi

# The package is installed for the whole machine, but only a user who has run
# T3 Code has anything to carry over. Leave it in place for whoever does.
if [[ ! -d ${T3CODE_HOME:-$HOME/.t3} && ! -d $HOME/.config/t3code && ! -d $HOME/.config/t3code-v2 ]]; then
  exit 0
fi

# Threads, settings, and the theme stay in ~/.t3, which the app keeps using.
# The package's channel carries over, and the running app stays open. The
# package goes last, so an install that fails partway is retried in full.
omarchy-install-ai-t3-code "$channel" --no-launch

echo "T3 Code now updates itself. If it is open, quit and reopen it to run the new app."
