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

# omarchy-drive-unlock finds a keyfile by the LUKS UUID alone, so only a drive
# named by exactly one UUID translates. Anything less certain is named, not guessed.
/usr/bin/python3 -I - "$config" "$HOME/.config/omarchy/drive-keys" <<'PY'
import fnmatch
import json
import os
import re
import sys

config, keys = sys.argv[1:]
values = {"keyfile", "options", "ignore", "automount", "skip"}
unknown = object()

try:
    with open(config) as f:
        if config.endswith(".json"):
            data = json.load(f)
        else:
            import yaml
            data = yaml.safe_load(f)
    rules = []
    for section in ("device_config", "mount_options", "ignore_device"):
        for rule in data.get(section) or []:
            if isinstance(rule, dict):
                rule = dict(rule)
                if section == "ignore_device":
                    rule.setdefault("ignore", True)
                rules.append(rule)
except Exception as error:
    print(f"Could not read {config} ({error}). Link each keyfile to {keys}/<LUKS UUID> by hand.")
    sys.exit(0)


def match_of(rule):
    return {k: v for k, v in rule.items() if k not in values}


def matches(rule, uuid):
    """True or False when the rule's match can be decided from the UUID alone, else unknown."""
    match = match_of(rule)
    patterns = match.get("id_uuid", "*")
    patterns = patterns if isinstance(patterns, list) else [patterns]
    # Every condition must hold, so a UUID that rules the drive out settles it.
    if not any(fnmatch.fnmatch(uuid, str(p).lower()) for p in patterns):
        return False
    if set(match) - {"id_uuid"}:
        return unknown
    return True


# udiskie resolves each setting on its own, from the first matching rule that sets
# it. A matching skip hands the question to the parent device, which is not known here.
def resolve(uuid, kind, default):
    for rule in rules:
        sets = kind in rule
        skips = rule.get("skip") in (True, "all", kind)
        if sets or skips:
            matched = matches(rule, uuid)
            if matched is unknown or (matched and not sets):
                return unknown
            if matched:
                return rule[kind]
    return default


def keyfile_path(value):
    # udiskie opened a relative keyfile from the directory it was started in, which was home.
    return os.path.join(os.path.expanduser("~"), os.path.expanduser(os.path.expandvars(value)))


uuids = []
for rule in rules:
    if not isinstance(rule.get("keyfile"), str):
        continue
    uuid = match_of(rule).get("id_uuid")
    if list(match_of(rule)) == ["id_uuid"] and isinstance(uuid, str) and re.fullmatch(r"[0-9a-fA-F-]+", uuid):
        if uuid.lower() not in uuids:
            uuids.append(uuid.lower())
    else:
        print(f"Not carried over, link it to {keys}/<LUKS UUID> by hand: {keyfile_path(rule['keyfile'])}")

for uuid in uuids:
    link = os.path.join(keys, uuid)
    if os.path.lexists(link):
        continue

    keyfile = resolve(uuid, "keyfile", None)
    # Omarchy started udiskie with --automount, so automounting was on unless a rule turned it off.
    ignore = resolve(uuid, "ignore", False)
    automount = resolve(uuid, "automount", True)

    if unknown in (keyfile, ignore, automount) or not isinstance(keyfile, str):
        print(f"Not carried over, a broader udiskie rule may apply to {uuid}. Link its keyfile to {link} by hand.")
        continue

    keyfile = keyfile_path(keyfile)

    # The automounter knows nothing of udiskie's flags, so a link would unlock a drive the user had excluded.
    if ignore or not automount:
        print(f"Not carried over, udiskie was told to leave {uuid} alone. Link {keyfile} to {link} by hand to unlock it on its own.")
        continue

    if not os.path.isfile(keyfile):
        print(f"Not carried over, {keyfile} does not exist. Link the right keyfile to {link} by hand.")
        continue

    os.makedirs(keys, mode=0o700, exist_ok=True)
    os.symlink(keyfile, link)
    print(f"Linked {link} to {keyfile}")
PY
