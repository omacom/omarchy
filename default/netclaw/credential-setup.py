"""Run the pinned credential wizard with literal input and dotenv persistence."""
import os
from pathlib import Path
import re
import shlex
import subprocess
import sys
import tempfile


def write_value(path, key, value):
    if not re.fullmatch(r"[A-Z][A-Z0-9_]*", key):
        raise ValueError("Invalid environment key")
    if "\n" in value or "\r" in value or "\0" in value:
        raise ValueError("Credentials must be a single line")
    if not value:
        return
    lines = path.read_text().splitlines() if path.exists() else []
    lines = [line for line in lines if not re.match(r"^(?:# )?" + key + "=", line)]
    encoded = "'" + value.replace("\\", "\\\\").replace("'", "\\'") + "'"
    lines.append(key + "=" + encoded)
    fd, temporary = tempfile.mkstemp(dir=path.parent, prefix=".netclaw-env-")
    try:
        with os.fdopen(fd, "w") as output:
            output.write("\n".join(lines) + "\n")
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def patch_wizard(source, root, writer):
    replacements = {
        'eval "$var=\\"${input:-$default}\\""': '''printf -v "$var" '%s' "${input:-$default}"''',
        'eval "$var=\\"$input\\""': '''printf -v "$var" '%s' "$input"''',
    }
    for old, new in replacements.items():
        if source.count(old) != 1:
            raise ValueError("Upstream credential prompt contract changed")
        source = source.replace(old, new)
    source, count = re.subn(r'^NETCLAW_DIR=.*$', lambda _: "NETCLAW_DIR=" + shlex.quote(str(root)), source, count=1, flags=re.M)
    if count != 1:
        raise ValueError("Upstream source root contract changed")
    replacement = '''set_env() {
    printf '%s' "$2" | python3 ''' + shlex.quote(str(writer)) + ' --write "$OPENCLAW_ENV" "$1"\n}'
    source, count = re.subn(r'^set_env\(\) \{.*?^\}', lambda _: replacement, source, count=1, flags=re.M | re.S)
    if count != 1:
        raise ValueError("Upstream credential writer contract changed")
    return source


if __name__ == "__main__":
    if sys.argv[1] == "--write":
        write_value(Path(sys.argv[2]), sys.argv[3], sys.stdin.read())
    else:
        root = Path(sys.argv[1])
        source = patch_wizard((root / "scripts/setup.sh").read_text(), root, Path(__file__).resolve())
        sys.exit(subprocess.run(["bash", "-c", source, "netclaw-credentials"], cwd=root).returncode)
