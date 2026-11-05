echo "Configure gnome-libsecret password store for VS Code"

# Return a comment-free copy for key detection while preserving quoted strings and line numbers.
# The original JSONC file is never modified by this function.
strip_jsonc_comments_for_detection() {
  local file="$1"

  awk '
    BEGIN { in_block_comment = 0 }
    {
      output = ""
      in_string = 0
      escaped = 0

      for (i = 1; i <= length($0); i++) {
        char = substr($0, i, 1)
        next_char = substr($0, i + 1, 1)

        if (in_block_comment) {
          if (char == "*" && next_char == "/") {
            in_block_comment = 0
            i++
          }
          continue
        }

        if (in_string) {
          output = output char
          if (escaped) {
            escaped = 0
          } else if (char == "\\") {
            escaped = 1
          } else if (char == "\"") {
            in_string = 0
          }
          continue
        }

        if (char == "\"") {
          in_string = 1
          output = output char
        } else if (char == "/" && next_char == "/") {
          break
        } else if (char == "/" && next_char == "*") {
          in_block_comment = 1
          i++
        } else {
          output = output char
        }
      }

      print output
    }
  ' "$file"
}

# argv.json is treated as VS Code's flat argument map; this is not a general JSONC parser.
# Comments are ignored for key detection, but preserved in the original file.
# It ensures that installations via pacman/yay receive the keyring fix.

for config_dir in "$HOME/.vscode" "$HOME/.vscode-oss"; do
  argv_file="$config_dir/argv.json"

  if ! mkdir -p "$config_dir"; then
    echo "Error [E001]: Cannot create VS Code configuration directory $config_dir." >&2
    exit 1
  fi

  # Case 1: Create argv.json only when it is missing or empty.
  if [[ ! -s $argv_file ]]; then
    if [[ -e $argv_file && ! -w $argv_file ]]; then
      echo "Error [E002]: Existing empty configuration file is not writable: $argv_file." >&2
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
      echo "Error [E003]: Cannot create the default VS Code configuration file $argv_file." >&2
      exit 1
    fi
    continue
  fi

  # Build a comment-free copy for key detection; the original file stays unchanged.
  if ! active_content=$(strip_jsonc_comments_for_detection "$argv_file"); then
    echo "Error [E004]: Cannot read and inspect JSONC comments in $argv_file." >&2
    exit 1
  fi

  # Case 2: Replace an active basic or empty-string value with gnome-libsecret.
  # Commented settings are absent from active_content and cannot trigger this branch.
  if grep -qE '(^|[[:space:],{])"password-store"[[:space:]]*:[[:space:]]*("basic"|"[[:space:]]*")' <<< "$active_content"; then
    if [[ -f $argv_file && ! -w $argv_file ]]; then
      echo "Error [E005]: Cannot replace the password-store value because $argv_file is not writable." >&2
      exit 1
    fi

    # Use line numbers from comment-free content so commented values are never edited.
    value_line_numbers=$(grep -nE '(^|[[:space:],{])"password-store"[[:space:]]*:[[:space:]]*("basic"|"[[:space:]]*")' <<< "$active_content" | cut -d: -f1)
    while IFS= read -r line_number; do
      [[ -z $line_number ]] && continue
      if ! sed -E -i --follow-symlinks "${line_number}s/\"password-store\"[[:space:]]*:[[:space:]]*(\"basic\"|\"[[:space:]]*\")/\"password-store\": \"gnome-libsecret\"/" "$argv_file"; then
        echo "Error [E006]: Failed to replace the basic or empty password-store value on line $line_number in $argv_file." >&2
        exit 1
      fi
    done <<< "$value_line_numbers"
    continue
  fi

  # Case 3: Preserve an existing active non-basic setting.
  # Empty and whitespace-only values are already handled by Case 2.
  # If the key exists but has no quoted value, warn and leave the file untouched.
  if grep -qE '(^|[[:space:],{])"password-store"[[:space:]]*:' <<< "$active_content"; then
    if ! grep -qE '(^|[[:space:],{])"password-store"[[:space:]]*:[[:space:]]*"[^"]*"' <<< "$active_content"; then
      echo "Warning [W001]: password-store has a missing or malformed value in $argv_file; leaving it unchanged." >&2
    fi
    continue
  fi

  if [[ -f $argv_file && ! -w $argv_file ]]; then
    echo "Error [E007]: Cannot add password-store because $argv_file is not writable." >&2
    exit 1
  fi

  # Locate the root opening-brace line in comment-free content. Its line number is retained
  # because the comment-stripping pass preserves one output line for every input line.
  root_open_line=$(grep -n -m1 '^[[:space:]]*{' <<< "$active_content" | cut -d: -f1 || true)

  # Case 4a: No active opening brace; append a new object after any existing comments.
  if [[ -z $root_open_line ]]; then
    if ! printf '\n{\n  "password-store": "gnome-libsecret"\n}\n' >> "$argv_file"; then
      echo "Error [E008]: Case 4a could not append a new configuration object to $argv_file." >&2
      exit 1
    fi

  # Case 4b: Existing properties are present; preserve compact or multiline layout.
  elif grep -qE '(^|[[:space:],{])"[^\"]+"[[:space:]]*:' <<< "$active_content"; then
    if grep -qE '^[[:space:]]*\{[[:space:]]*"' <<< "$active_content"; then
      # Compact object: insert the setting immediately after the opening brace.
      if ! sed -i --follow-symlinks '0,/^[[:space:]]*{/s/^\([[:space:]]*{[[:space:]]*\)/\1"password-store": "gnome-libsecret", /' "$argv_file"; then
        echo "Error [E009]: Case 4b could not insert password-store into compact JSON in $argv_file." >&2
        exit 1
      fi
    else
      # Multiline object: append after the root opening line. If a block comment starts on
      # that line and closes later, append after its closing line instead of inside the comment.
      insert_after_line=$root_open_line
      root_open_text=$(sed -n "${root_open_line}p" "$argv_file")
      if [[ $root_open_text == *'/*'* && $root_open_text != *'*/'* ]]; then
        block_close_offset=$(tail -n +"$((root_open_line + 1))" "$argv_file" | grep -n -m1 '\*/' | cut -d: -f1 || true)
        if [[ -z $block_close_offset ]]; then
          echo "Error [E010]: Case 4b found an unclosed block comment after the opening brace in $argv_file." >&2
          exit 1
        fi
        insert_after_line=$((root_open_line + block_close_offset))
      fi

      sed_script=$(printf '%sa\\\n  "password-store": "gnome-libsecret",' "$insert_after_line")
      if ! sed -i --follow-symlinks "$sed_script" "$argv_file"; then
        echo "Error [E011]: Case 4b could not insert password-store into multiline JSON in $argv_file." >&2
        exit 1
      fi
    fi

  # Case 4c: Empty compact object. Preserve an optional trailing // or same-line block comment.
  elif grep -qE '^[[:space:]]*\{[[:space:]]*\}[[:space:]]*$' <<< "$active_content"; then
    if ! sed -E -i --follow-symlinks '0,/^[[:space:]]*\{/s/^([[:space:]]*\{)([[:space:]]*(\/\*.*\*\/[[:space:]]*)?)[[:space:]]*\}([[:space:]]*(\/\/.*|\/\*.*\*\/[[:space:]]*))?$/\1\2"password-store": "gnome-libsecret"}\4/' "$argv_file"; then
      echo "Error [E012]: Case 4c could not insert password-store into compact empty JSON in $argv_file." >&2
      exit 1
    fi

  # Case 4c: Empty multiline object, including an opening brace followed by comments.
  else
    insert_after_line=$root_open_line
    root_open_text=$(sed -n "${root_open_line}p" "$argv_file")
    if [[ $root_open_text == *'/*'* && $root_open_text != *'*/'* ]]; then
      block_close_offset=$(tail -n +"$((root_open_line + 1))" "$argv_file" | grep -n -m1 '\*/' | cut -d: -f1 || true)
      if [[ -z $block_close_offset ]]; then
        echo "Error [E013]: Case 4c found an unclosed block comment after the opening brace in $argv_file." >&2
        exit 1
      fi
      insert_after_line=$((root_open_line + block_close_offset))
    fi

    sed_script=$(printf '%sa\\\n  "password-store": "gnome-libsecret"' "$insert_after_line")
    if ! sed -i --follow-symlinks "$sed_script" "$argv_file"; then
      echo "Error [E014]: Case 4c could not insert password-store into multiline empty JSON in $argv_file." >&2
      exit 1
    fi
  fi
done
