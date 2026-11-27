echo "Unlock encrypted drives with the keyfiles udiskie was configured to use"

# udiskie read the first of these that exists.
config=""
for candidate in "${XDG_CONFIG_HOME:-$HOME/.config}"/udiskie/config.{yml,json}; do
  if [[ -f $candidate ]]; then
    config=$candidate
    break
  fi
done

[[ -n $config ]] && grep -qE '^[^#]*keyfile' "$config" || exit 0

# The system Python, since mise may put its own first on PATH without system packages.
if [[ $config == *.yml ]] && ! /usr/bin/python3 -I -c "import yaml" 2>/dev/null; then
  omarchy-pkg-add python-yaml
fi

# omarchy-drive-unlock finds a keyfile by the LUKS UUID alone, so only a rule
# that matches exactly one UUID translates. Any other rule is named, not guessed.
/usr/bin/python3 -I - "$config" "$HOME/.config/omarchy/drive-keys" <<'PY'
import json
import os
import re
import sys

config, keys = sys.argv[1:]
values = {"keyfile", "options", "ignore", "automount", "skip"}

try:
    with open(config) as f:
        if config.endswith(".json"):
            data = json.load(f)
        else:
            import yaml
            data = yaml.safe_load(f)
    rules = [rule for section in ("device_config", "mount_options", "ignore_device") for rule in data.get(section) or []]
except Exception as error:
    print(f"Could not read {config} ({error}). Link each keyfile to {keys}/<LUKS UUID> by hand.")
    sys.exit(0)

for rule in rules:
    if not isinstance(rule, dict) or not isinstance(rule.get("keyfile"), str):
        continue

    # udiskie opened a relative keyfile from the directory it was started in, which was home.
    keyfile = os.path.join(os.path.expanduser("~"), os.path.expanduser(os.path.expandvars(rule["keyfile"])))
    match = {k: v for k, v in rule.items() if k not in values}
    uuid = match.get("id_uuid")

    if list(match) != ["id_uuid"] or not isinstance(uuid, str) or not re.fullmatch(r"[0-9a-fA-F-]+", uuid):
        print(f"Not carried over, link it to {keys}/<LUKS UUID> by hand: {keyfile}")
        continue

    link = os.path.join(keys, uuid.lower())
    if os.path.lexists(link):
        continue

    if not os.path.isfile(keyfile):
        print(f"Not carried over, {keyfile} does not exist. Link the right keyfile to {link} by hand.")
        continue

    os.makedirs(keys, mode=0o700, exist_ok=True)
    os.symlink(keyfile, link)
    print(f"Linked {link} to {keyfile}")
PY
