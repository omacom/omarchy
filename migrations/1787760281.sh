echo "Install the Hermes CLI wrapper for existing installs"

# Users who removed the preinstalls opted out of the mise wrappers, and Hermes
# is one of them.
[[ -f $HOME/.local/state/omarchy/preinstalls-removed ]] && exit 0

# Strict mode skips the mise category, but the Hermes installer runs mise
# (mise where/rm/uninstall/use) and opaque external probes (timeout hermes
# --version, hermes chat --help). Honoring the category policy beats a silent
# partial install, so defer when the installer would run without an explicit
# --mise=run opt-in. The guard sits before either installer invocation so the
# desktop branch's `|| true` cannot swallow the deferral; the marker stays
# absent and the queue stops.
if [[ ${OMARCHY_UPDATE_STRICT:-} == "1" && ${OMARCHY_UPDATE_MISE:-} != "run" ]]; then
  will_install=0
  if omarchy-pkg-present hermes-desktop; then
    will_install=1
  else
    strict_hermes_wrapper="$HOME/.local/bin/hermes"
    if [[ -e $strict_hermes_wrapper || -L $strict_hermes_wrapper ]] && ! omarchy-install-hermes-cli --owns; then
      will_install=0
    else
      will_install=1
    fi
  fi
  if (( will_install )); then
    echo "Deferring Hermes CLI install in strict mode: installer runs mise, which is skipped." >&2
    echo "Finish with interactive omarchy-migrate or rerun with --mise=run." >&2
    exit 1
  fi
fi

# Hermes Desktop provides its own Hermes. The installer stands aside for it,
# removing the mise copy and the Omarchy wrapper an earlier install may have
# left beside the app. It also reports when the app has not finished setting
# Hermes up, which is the app's to finish, not this migration's to fail on.
if omarchy-pkg-present hermes-desktop; then
  omarchy-install-hermes-cli || true
  exit 0
fi

# Anything already answering to hermes that this installer did not write --
# an official install, a hand-rolled wrapper, even a dangling link -- belongs to
# the user and stays exactly as it is. The installer is asked rather than
# matched against here, so there is one answer to who owns that wrapper.
wrapper="$HOME/.local/bin/hermes"
if [[ -e $wrapper || -L $wrapper ]] && ! omarchy-install-hermes-cli --owns; then
  exit 0
fi

omarchy-install-hermes-cli
