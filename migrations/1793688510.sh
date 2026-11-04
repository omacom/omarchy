echo "Configure gnome-libsecret password store for VS Code"

# argv.json is treated as VS Code's flat argument map; this is not a general JSONC parser.
# Supports full-line // comments and a trailing // comment on the root opening-brace line.
# This remains a targeted flat-object migration, not a general JSONC parser.
# It ensures that installations via pacman/yay receive the keyring fix.

for config_dir in "$HOME/.vscode" "$HOME/.vscode-oss"; do
  argv_file="$config_dir/argv.json"

  if ! mkdir -p "$config_dir"; then
    echo "Error: Cannot create configuration directory $config_dir." >&2
    exit 1
  fi

  # Create argv.json only when it is missing or empty.
  if [[ ! -s $argv_file ]]; then
    if [[ -e $argv_file && ! -w $argv_file ]]; then
      echo "Error: $argv_file is not writable. Aborting migration so it can retry later." >&2
      exit 1
    fi

    if ! cat > "$argv_file" <<'JSONC'
// This configuration file allows you to pass permanent command line arguments to VS Code.
// Only a subset of arguments is currently supported to reduce the likelihood of breaking
// the installation.
//
// PLEASE DO NOT CHANGE WITHOUT UNDERSTANDING THE IMPACT
//
// NOTE: Changing this file requires a restart of VS Code.
{
	"password-store": "gnome-libsecret"
}
JSONC
    then
      echo "Error: Failed to create $argv_file." >&2
      exit 1
    fi
    continue
  fi

  # Ignore full-line // comments. Inline and block comments are outside this migration's
  # supported input format; argv.json is expected to use VS Code's usual flat argument map.
  if ! active_content=$(sed -E '/^[[:space:]]*\/\//d' "$argv_file"); then
    echo "Error: Cannot read $argv_file." >&2
    exit 1
  fi

  # Case 2: Replace an existing basic setting. Do not rewrite full-line comments.
  if grep -qE '(^|[[:space:],{])"password-store"[[:space:]]*:[[:space:]]*"basic"' <<< "$active_content"; then
    if [[ -f $argv_file && ! -w $argv_file ]]; then
      echo "Error: $argv_file is not writable. Aborting migration so it can retry later." >&2
      exit 1
    fi

    if ! sed -i --follow-symlinks '/^[[:space:]]*\/\//! s/"password-store"[[:space:]]*:[[:space:]]*"basic"/"password-store": "gnome-libsecret"/' "$argv_file"; then
      echo "Error: Failed to update the password-store setting in $argv_file." >&2
      exit 1
    fi
    continue
  fi

  # Case 3: Preserve an existing non-basic setting.
  if grep -qE '(^|[[:space:],{])"password-store"[[:space:]]*:' <<< "$active_content"; then
    continue
  fi

  if [[ -f $argv_file && ! -w $argv_file ]]; then
    echo "Error: $argv_file is not writable. Aborting migration so it can retry later." >&2
    exit 1
  fi

  # Case 4a: The file contains comments but no JSON object; append a new object.
  if ! grep -q '^[[:space:]]*{' <<< "$active_content"; then
    if ! printf '\n{\n\t"password-store": "gnome-libsecret"\n}\n' >> "$argv_file"; then
      echo "Error: Failed to append the configuration to $argv_file." >&2
      exit 1
    fi

  # Case 4b: Existing properties are present; preserve compact or multiline layout.
  elif grep -qE '(^|[[:space:],{])"[^\"]+"[[:space:]]*:' <<< "$active_content"; then
    if grep -qE '^[[:space:]]*\{[[:space:]]*"' <<< "$active_content"; then
      # Compact object: insert after the opening brace.
      if ! sed -i --follow-symlinks '0,/^[[:space:]]*{/s/^\([[:space:]]*{[[:space:]]*\)/\1"password-store": "gnome-libsecret", /' "$argv_file"; then
        echo "Error: Failed to update $argv_file." >&2
        exit 1
      fi
    elif grep -qE '^[[:space:]]*\{[[:space:]]*(//.*)?$' <<< "$active_content"; then
      # Multiline object: the opening brace may have a trailing // comment.
      # Insert the new property on the following line, preserving that comment.
      if ! sed -i --follow-symlinks '0,/^[[:space:]]*{/ { /^[[:space:]]*{/a\
	"password-store": "gnome-libsecret",
}' "$argv_file"; then
        echo "Error: Failed to update $argv_file." >&2
        exit 1
      fi
    else
      echo "Error: Cannot safely locate the root opening brace in $argv_file." >&2
      exit 1
    fi

  # Case 4c: Empty object; no trailing comma is required.
  elif grep -qE '^[[:space:]]*\{[[:space:]]*\}[[:space:]]*$' <<< "$active_content"; then
    if ! sed -i --follow-symlinks '0,/^[[:space:]]*{/s/^\([[:space:]]*{\)[[:space:]]*}[[:space:]]*$/\1"password-store": "gnome-libsecret"}/' "$argv_file"; then
      echo "Error: Failed to update $argv_file." >&2
      exit 1
    fi
  elif grep -qE '^[[:space:]]*\{[[:space:]]*(//.*)?$' <<< "$active_content"; then
    # Empty multiline object; allow a trailing // comment after the opening brace.
    # Keep the comment on the opening-brace line and add the property below it.
    if ! sed -i --follow-symlinks '0,/^[[:space:]]*{/ { /^[[:space:]]*{/a\
	"password-store": "gnome-libsecret"
}' "$argv_file"; then
      echo "Error: Failed to update $argv_file." >&2
      exit 1
    fi
  else
    echo "Error: Cannot safely update $argv_file." >&2
    exit 1
  fi
done
