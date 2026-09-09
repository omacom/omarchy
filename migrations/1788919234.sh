echo "Remove agent usage records whose collector is no longer installed"

# The agents panel lists every record in the usage directory, so a record
# left behind by an agent that went away (like the pre-collector-era copilot)
# would keep showing up forever.
#
# omarchy-agent-usage-update now prunes new orphans on every run, so this only
# needs to clear records left behind before that landed. The same guard is
# used there: drop a record only when no installed collector produces it and
# it is at least seven days old, so a writer that keeps a file fresh but does
# not follow the collector naming scheme is not disturbed.

usage_dir="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/agents/usage"
[[ -d $usage_dir ]] || exit 0

known=()
for collector in "$OMARCHY_PATH"/bin/omarchy-agent-usage-*; do
  [[ -x $collector ]] || continue
  agent="${collector##*/omarchy-agent-usage-}"
  [[ $agent != "update" ]] && known+=("$agent")
done
plugins_dir="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins"
for collector in "$plugins_dir"/*/scripts/omarchy-agent-usage-*; do
  [[ -f $collector ]] || continue
  agent="${collector##*/omarchy-agent-usage-}"
  [[ $agent != "update" ]] && known+=("$agent")
done
for collector in "$plugins_dir"/*/bin/omarchy-agent-usage-*; do
  [[ -f $collector ]] || continue
  agent="${collector##*/omarchy-agent-usage-}"
  [[ $agent != "update" ]] && known+=("$agent")
done

cutoff=$(( $(date +%s) - 604800 ))
for record in "$usage_dir"/*.json; do
  [[ -f $record ]] || continue
  agent="${record##*/}"
  agent="${agent%.json}"
  alive=0
  for name in "${known[@]}"; do
    [[ $name == "$agent" ]] && { alive=1; break; }
  done
  (( alive )) && continue
  mtime=$(stat -c %Y -- "$record" 2>/dev/null) || mtime=0
  (( mtime >= cutoff )) && continue
  rm -f -- "$record"
  echo "Removed stale record for '$agent': no installed collector produces it"
done

exit 0
