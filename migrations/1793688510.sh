#!/bin/bash
# omarchy:summary=Configure gnome-libsecret password store for VS Code/Code-OSS to fix keyring loop

echo "Configure gnome-libsecret password store for VS Code"

# Apply to both Microsoft VS Code (AUR) and Arch Code-OSS (pacman)
for config_dir in "$HOME/.vscode" "$HOME/.vscode-oss"; do
  argv_file="$config_dir/argv.json"

  # 1. If argv.json doesn't exist OR is exactly 0 bytes, create it
  if [[ ! -s "$argv_file" ]]; then
    mkdir -p "$config_dir"
    cat > "$argv_file" << 'EOF'
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
EOF
    continue
  fi

  # Skip if the user messed up their permissions (prevents the update from crashing)
  if [[ ! -w "$argv_file" ]]; then
    continue
  fi

  # 2. If password-store is explicitly set to "basic", heal/override it
  # (Anchored to ensure we don't match commented-out settings)
  if grep -q '^[[:space:]]*"password-store"[[:space:]]*:[[:space:]]*"basic"' "$argv_file"; then
    sed --follow-symlinks -i 's/"password-store"[[:space:]]*:[[:space:]]*"basic"/"password-store": "gnome-libsecret"/g' "$argv_file"
    continue
  fi

  # 3. If password-store already exists with some other value, leave it completely alone
  # (Anchored to ensure we don't get fooled by // "password-store": "gnome-libsecret")
  if grep -q '^[[:space:]]*"password-store"' "$argv_file"; then
    continue
  fi

  # 4. If password-store key is missing entirely, safely inject it while preserving JSONC comments
  # (Anchored to ignore commented-out brackets like `// {`)
  if ! grep -q '^[[:space:]]*{' "$argv_file"; then
    # No active opening brace found (file is just comments). Append a new JSON object.
    printf '\n{\n\t"password-store": "gnome-libsecret"\n}\n' >> "$argv_file"
  elif grep -qE '^[[:space:]]*"[^"]+"[[:space:]]*:' "$argv_file"; then
    # Existing active keys found. Inject WITH a trailing comma.
    sed --follow-symlinks -i '0,/^[[:space:]]*{/s//{\n\t"password-store": "gnome-libsecret",/' "$argv_file"
  else
    # No existing active keys found. Inject WITHOUT a trailing comma.
    sed --follow-symlinks -i '0,/^[[:space:]]*{/s//{\n\t"password-store": "gnome-libsecret"/' "$argv_file"
  fi

done
