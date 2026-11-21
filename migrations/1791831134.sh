echo "Fix Framework Laptop 13 AMD Ryzen AI 300 microphone input"

# The install-time fix only reaches machines set up after it shipped, so existing
# installs add the WirePlumber rule here. The rule applies when WirePlumber next
# starts, so restart the session manager to apply it now, with no reboot.
#
# The live card state, not this run's write, decides what to do: a machine whose
# card already has UCM off (restarted, or logged in since) is left alone so its
# audio is not interrupted twice, while a card that is present with UCM still on
# gets a best-effort restart. If the card is not in the graph there is no session
# to restart and the rule applies at the next login.
# See install/user/hardware/framework/fix-framework13-ai300-mic.sh.
source "$OMARCHY_PATH/install/user/hardware/framework/fix-framework13-ai300-mic.sh"

if [[ $omarchy_framework13_ai300_mic_matched == 1 ]] &&
  omarchy_framework13_ai300_mic_card_present &&
  ! omarchy_framework13_ai300_mic_ucm_off; then
  # The rule is already written, so nothing is lost by finishing here even if
  # this restart cannot make it take now. Never fail: omarchy-migrate runs under
  # `set -e`, so a non-zero exit would abort the whole run and leave every later
  # migration pending for good -- for example when a later drop-in sets
  # api.alsa.use-ucm = true, or on a custom WirePlumber setup.
  if systemctl --user try-restart wireplumber; then
    # The card reflects the rule within a fraction of a second when the restart
    # works; the generous default timeout avoids mistaking a slow session manager
    # for a failure. The overrides exist so the tests do not have to wait it out.
    restart_tries="${OMARCHY_FRAMEWORK13_AI300_MIC_RESTART_TRIES:-40}"
    restart_interval="${OMARCHY_FRAMEWORK13_AI300_MIC_RESTART_INTERVAL:-0.25}"
    for ((try = 0; try < restart_tries; try++)); do
      omarchy_framework13_ai300_mic_ucm_off && break
      sleep "$restart_interval"
    done
  fi

  if ! omarchy_framework13_ai300_mic_ucm_off; then
    echo "The Framework 13 microphone rule was written, but WirePlumber has not applied it; a conflicting setting may be overriding it." >&2
  fi
fi
