echo "Retire the Hermes that mise built; Hermes now updates itself"

# Hermes installs the way Hermes Desktop does now: upstream's installer makes a checkout under ~/.hermes that `hermes update` fast-forwards. The wrapper that built Hermes through mise had nothing an update could move, so it goes, with the mise environment it built. The wrapper, the environment and what proves them Omarchy's are known to the installer and nowhere else, so it is asked rather than matched against here; it leaves a hermes the user set up themselves, and a mise environment without the wrapper, as they are, and exits non-zero with the commands to finish by hand when the environment cannot be removed, which keeps this pending rather than done.
omarchy-install-hermes-cli --retire-mise

# Choosing Hermes again is what installs the runtime, and nothing else will.
if [[ $(omarchy-default-agent) == "hermes" ]] && ! omarchy-install-hermes-cli --check; then
  echo "Hermes is the default agent but is no longer installed. Choose it again under Setup > Default Agent, or run: omarchy default agent hermes"
fi
