echo "Switch default mise tools to native lazy shims"

legacy_wrapper_template() {
  local form=$1 package=$2 bin=$3

  case $form in
  quiet)
    printf '#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g --quiet "%s" || exit 1\nexec mise x "%s" -- "%s" "$@"\n' "$package" "$package" "$bin" ;;
  cooldown-export)
    printf '#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g "%s" || exit 1\nexec mise x "%s" -- "%s" "$@"\n' "$package" "$package" "$bin" ;;
  bail-on-failure)
    printf '#!/bin/bash\nmise use -g "%s" || exit 1\nexec mise x "%s" -- "%s" "$@"\n' "$package" "$package" "$bin" ;;
  mise-exec)
    printf '#!/bin/bash\nmise use -g "%s"\nexec mise exec "%s" -- "%s" "$@"\n' "$package" "$package" "$bin" ;;
  bare-exec)
    printf '#!/bin/bash\nmise use -g "%s"\nexec "%s" "$@"\n' "$package" "$bin" ;;
  esac
}

legacy_wrapper() {
  local command=$1 package=$2 wrapper="$HOME/.local/bin/$1" form

  [[ -f $wrapper && ! -L $wrapper && -r $wrapper ]] || return 1
  (($(stat -c%s "$wrapper") <= 1024)) || return 1

  # Match complete shipped templates, including the binary name and final
  # newline. Matching only the mise lines would discard user customizations.
  for form in quiet cooldown-export bail-on-failure mise-exec bare-exec; do
    if cmp -s "$wrapper" <(legacy_wrapper_template "$form" "$package" "$command"); then
      return 0
    fi
  done
  return 1
}

remove_legacy_wrapper() {
  local command=$1
  shift

  for package in "$@"; do
    if legacy_wrapper "$command" "$package"; then
      rm -f "$HOME/.local/bin/$command"
      return
    fi
  done
}

remove_legacy_wrapper codex codex aqua:openai/codex npm:@openai/codex
remove_legacy_wrapper claude claude aqua:anthropics/claude-code
remove_legacy_wrapper crush crush aqua:charmbracelet/crush
remove_legacy_wrapper agy antigravity-cli aqua:google-antigravity/antigravity-cli gemini npm:@google/gemini-cli
remove_legacy_wrapper gh gh github-cli aqua:cli/cli
remove_legacy_wrapper copilot copilot aqua:github/copilot-cli github:github/copilot-cli npm:@github/copilot
remove_legacy_wrapper opencode opencode aqua:anomalyco/opencode
remove_legacy_wrapper playwright playwright npm:playwright
remove_legacy_wrapper playwright-cli playwright npm:playwright
remove_legacy_wrapper pi pi aqua:earendil-works/pi github:earendil-works/pi npm:@earendil-works/pi-coding-agent
remove_legacy_wrapper omp oh-my-pi github:can1357/oh-my-pi
remove_legacy_wrapper grok grok npm:@xai-official/grok
remove_legacy_wrapper ghui ghui npm:@kitlangton/ghui
remove_legacy_wrapper hunk hunk aqua:modem-dev/hunk
remove_legacy_wrapper hey hey-cli github:basecamp/hey-cli
remove_legacy_wrapper ori ori github:OpenRouterLabs/ori-releases
remove_legacy_wrapper cf npm:cf
remove_legacy_wrapper cursor-agent cursor-agent
remove_legacy_wrapper basecamp basecamp github:basecamp/basecamp-cli
remove_legacy_wrapper muse muse 'http:muse[url=https://api.meta.ai/muse-launcher.sh,bin=muse,version_list_url=https://api.meta.ai/muse-code/channels/muse-stable,version_json_path=.version]'

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  MISE_CONFIG_PATH="${OMARCHY_MISE_CONFIG_PATH:-/etc/mise/config.toml}"
  sudo install -Dm644 "$OMARCHY_PATH/default/mise/config.toml" "$MISE_CONFIG_PATH"
fi

mise reshim --system
