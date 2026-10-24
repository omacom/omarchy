echo "Install RTKit so PipeWire clients do not inherit a zero realtime budget"

# Without rtkit, xdg-desktop-portal reports a realtime budget of 0, which
# PipeWire's client module-rt applies as a hard RLIMIT_RTTIME of 0 in
# omarchy-shell and every application it launches.
if omarchy-pkg-missing rtkit; then
  omarchy-pkg-add rtkit
  # xdg-desktop-portal caches the realtime budget when it starts; restart it so
  # the shell reload that follows migrations picks up the RTKit budget.
  systemctl --user try-restart xdg-desktop-portal.service >/dev/null 2>&1 || true
fi
