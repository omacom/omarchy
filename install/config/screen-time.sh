# Screen time ships on every install and runs on a child install (kids mode):
# the daemon is switched on, the kid account is put under the kids profile,
# and the bar shows the countdown. A default install gets the files and
# nothing running; `sudo omarchy-parent screen-time on` starts it there too.
if [[ ${OMARCHY_INSTALL_PROFILE:-default} == "child" && -n ${OMARCHY_INSTALL_USER:-} ]]; then
  omarchy-parent-screen-time on
  omarchy-parent-screen-time add "$OMARCHY_INSTALL_USER"
fi
