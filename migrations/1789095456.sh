echo "Remove automatic project bin directories from PATH"

work_dir="$HOME/Work"
mise_config="$work_dir/.mise.toml"
# install/user/mise-work.sh as shipped in Omarchy 4.0.3.
stock_sha="bd04f191d63bbde86920f44f76f0989fad980afc84e268e8474c201ec7149245"
cwd_bin='\{\{[[:space:]]*cwd[[:space:]]*\}\}/bin'
unsafe_path="^[[:space:]]*_[.]path[[:space:]]*=[[:space:]]*(\"$cwd_bin\"|'$cwd_bin')[[:space:]]*(#.*)?$"
env_section='^[[:space:]]*\[[[:space:]]*env[[:space:]]*\][[:space:]]*(#.*)?$'
any_section='^[[:space:]]*\[\[?.*\]\]?[[:space:]]*(#.*)?$'

remove_empty_work_dir=false
if [[ ! -e $work_dir ]]; then
  mkdir -p "$work_dir"
  remove_empty_work_dir=true
fi

was_ignored=false
if [[ -d $work_dir ]]; then
  mise_state_dir=${MISE_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/mise}
  ignored_configs_dir="$mise_state_dir/ignored-configs"
  work_target=$(readlink -m "$work_dir")
  config_path_target="$work_target/.mise.toml"
  config_target=$(readlink -m "$mise_config")

  if [[ -d $ignored_configs_dir ]]; then
    for ignored_entry in "$ignored_configs_dir"/*; do
      [[ -L $ignored_entry ]] || continue
      ignored_target=$(readlink "$ignored_entry")
      if [[ $ignored_target == $work_target || $ignored_target == $config_path_target || $ignored_target == $config_target ]]; then
        was_ignored=true
        break
      fi
    done
  fi

  if [[ $was_ignored == "false" ]]; then
    # Normal Mise trust is recorded against the config-root directory, while
    # paranoid trust is recorded against the file and its contents. Stage an
    # empty, inert config when the legacy file is gone so either trust mode can
    # resolve and revoke the original grant.
    remove_empty_mise_config=false
    if [[ ! -e $mise_config && ! -L $mise_config ]]; then
      if (set -o noclobber; : >"$mise_config") 2>/dev/null; then
        remove_empty_mise_config=true
      fi
    fi

    untrust_target="$work_dir"
    if [[ -f $mise_config ]]; then
      untrust_target="$mise_config"
    fi

    if mise trust --untrust "$untrust_target"; then
      :
    else
      if [[ $remove_empty_mise_config == "true" ]]; then
        rm -f -- "$mise_config"
      fi
      exit 1
    fi

    if [[ $remove_empty_mise_config == "true" ]]; then
      rm -f -- "$mise_config"
    fi
  fi
fi

if [[ -f $mise_config ]]; then
  if [[ ! -L $mise_config && $(sha256sum "$mise_config" | cut -d ' ' -f 1) == $stock_sha ]]; then
    rm -f -- "$mise_config"
  else
    unsafe_env_paths=$(sed -n -E "\\%$env_section%,\\%$any_section% { \\%$unsafe_path%p; }" "$mise_config")
    if [[ -n $unsafe_env_paths ]]; then
      backup=$(mktemp "$mise_config.bak.XXXXXX")
      cp -p -- "$mise_config" "$backup"
      sed --follow-symlinks -i -E "\\%$env_section%,\\%$any_section% { \\%$unsafe_path%d; }" "$mise_config"

      printf '\n%s\n' \
        "Automatic project bin directories were removed from your Mise PATH." \
        "Your other Mise settings were preserved."
      printf '\nBackup saved to:\n  %s\n' "$backup"
    fi
  fi
fi

if [[ -f $mise_config ]]; then
  if [[ $was_ignored == "true" ]]; then
    printf '\n%s\n' "This custom config remains ignored by Mise."
  else
    printf '\n%s\n  %s\n' \
      "Mise trust for this custom config was revoked. Review it before trusting it again:" \
      "mise trust $mise_config"
  fi
fi

if [[ $remove_empty_work_dir == "true" ]]; then
  rmdir "$work_dir" 2>/dev/null || true
fi
