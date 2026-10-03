echo "Seed Codex auto-review in config.toml so launches keep the shared server"

# --approve-for-me injects CLI config overrides that force embedded mode on
# Codex 0.157+. Persist the same settings and drop the flag from launchers.
source "$OMARCHY_PATH/install/helpers/codex-config.sh"
omarchy_ensure_codex_auto_review_config
