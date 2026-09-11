echo "Remove automatic project bin directories from PATH"

work_dir="$HOME/Work"
mise_config="$work_dir/.mise.toml"
# install/user/mise-work.sh as shipped in Omarchy 4.0.3.
stock_sha="bd04f191d63bbde86920f44f76f0989fad980afc84e268e8474c201ec7149245"
cwd_bin='\{\{[[:space:]]*cwd[[:space:]]*\}\}/bin'
unsafe_path="^[[:space:]]*_[.]path[[:space:]]*=[[:space:]]*(\"$cwd_bin\"|'$cwd_bin')[[:space:]]*(#.*)?$"

remove_empty_work_dir=false
if [[ ! -e $work_dir ]]; then
  mkdir -p "$work_dir"
  remove_empty_work_dir=true
fi

if [[ -d $work_dir ]]; then
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

if [[ -f $mise_config ]]; then
  if [[ ! -L $mise_config && $(sha256sum "$mise_config" | cut -d ' ' -f 1) == $stock_sha ]]; then
    rm -f -- "$mise_config"
  elif grep -qE "$unsafe_path" "$mise_config"; then
    backup=$(mktemp "$mise_config.bak.XXXXXX")
    cp -p -- "$mise_config" "$backup"
    sed --follow-symlinks -i -E "\\%$unsafe_path%d" "$mise_config"

    printf '\n%s\n' \
      "Automatic project bin directories were removed from your Mise PATH." \
      "Your other Mise settings were preserved."
    printf '\nBackup saved to:\n  %s\n' "$backup"
  fi
fi

if [[ -f $mise_config ]]; then
  printf '\n%s\n  %s\n' \
    "Mise trust for this custom config was revoked. Review it before trusting it again:" \
    "mise trust $mise_config"
fi

if [[ $remove_empty_work_dir == "true" ]]; then
  rmdir "$work_dir" 2>/dev/null || true
fi
