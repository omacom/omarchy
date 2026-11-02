echo "Link agent skills where each installed coding agent reads them"

# One helper now writes Omarchy's skill links from default/agents/registry,
# replacing the folder lists that provisioning, the quattro upgrade and
# earlier migrations each carried. Besides linking, it removes the links
# those wrote into the folders of agents that read ~/.agents/skills anyway
# (Codex, Pi), so a skill is no longer listed twice; a user's own skills stay.
omarchy-agent-skills-link
