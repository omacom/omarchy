echo "Remove the usage records of the retired LiteLLM, Kiro, and Freebuff collectors"

# Nothing refreshes these records anymore, and the agents panel shows every
# record in the directory, so a left-behind one would show frozen numbers.
usage_dir="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/agents/usage"
for agent in litellm kiro freebuff; do
  rm -f "$usage_dir/$agent.json"
done
