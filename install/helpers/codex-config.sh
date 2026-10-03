# Seed Codex "Approve for me" defaults into config.toml without CLI overrides.
# Codex 0.157+ treats --approve-for-me (and -c/--enable/--disable/--search) as
# configuration overrides that force embedded mode and skip the shared
# background server. Persisting the same keys keeps auto-review and the shared
# server. Existing root keys are left alone.

omarchy_ensure_codex_auto_review_config() {
  local codex_home=${CODEX_HOME:-$HOME/.codex}
  local config=$codex_home/config.toml
  local defaults="" root_config temp_config
  local key value

  mkdir -p "$codex_home"
  [[ -f $config ]] || : >"$config"
  # Parse root keys so table-like text and keys inside multiline strings are ignored.
  root_config=$(/usr/bin/python3 - "$config" <<'PY'
import sys
import tomllib

with open(sys.argv[1], "rb") as config:
  print("\n".join(tomllib.load(config)))
PY
  ) || return 1

  for key in approvals_reviewer approval_policy sandbox_mode; do
    case $key in
    approvals_reviewer) value='"auto_review"' ;;
    approval_policy) value='"on-request"' ;;
    sandbox_mode) value='"workspace-write"' ;;
    esac

    if grep -qxF "$key" <<<"$root_config"; then
      continue
    fi

    defaults+="$key = $value"$'\n'
  done

  if [[ -n $defaults ]]; then
    temp_config=$(mktemp "$codex_home/config.toml.XXXXXX")
    {
      printf '# Omarchy: Approve for me without CLI overrides (keeps the shared background server).\n'
      printf '%s\n' "$defaults"
      cat "$config"
    } >"$temp_config"
    cat "$temp_config" >"$config"
    rm -f "$temp_config"
  fi
}
