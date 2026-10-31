#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

python3 - "$ROOT" <<'PY'
import json
import os
import random
import stat
import subprocess
import sys
import tempfile
from pathlib import Path

root = Path(sys.argv[1])
command = root / "bin/omarchy-theme-set-zed"

with tempfile.TemporaryDirectory(prefix="omarchy-zed-settings-") as scratch:
    home = Path(scratch) / "home with spaces"
    config = home / ".config/zed"
    config.mkdir(parents=True)
    settings = config / "settings.json"
    theme = home / ".local/state/omarchy/current/theme/zed.json"
    theme.parent.mkdir(parents=True)
    theme.write_text(json.dumps({"themes": [{"name": "Omarchy", "appearance": "dark", "style": {}}]}))
    env = dict(os.environ, HOME=str(home), OMARCHY_PATH=str(root), PATH=f"{root / 'bin'}:{os.environ['PATH']}")

    def invoke(*args):
        return subprocess.run([str(command), *args], env=env, capture_output=True, text=True)

    def assert_update(source, expected, *args):
        settings.write_text(source, encoding="utf-8", newline="")
        os.chmod(settings, 0o640)
        result = invoke(*args)
        if result.returncode != 0:
            raise AssertionError(f"{args}: unexpected failure: {result.stderr}")
        actual = settings.read_bytes().decode("utf-8")
        if actual != expected:
            raise AssertionError(f"{args}: settings other than the selected value changed")
        if stat.S_IMODE(settings.stat().st_mode) != 0o640:
            raise AssertionError(f"{args}: permissions changed")

    fonts = [
        "JetBrains Mono", 'Quoted "Font"', r"Backslash\Font", "Écriture 字体",
        "/* not a comment */ // } ,", "Tabs\tand\nlines", "Emoji 🐈",
    ]
    values = [
        '"Previous"', '"escaped \\\" // /* } ,"', "null", "false", "42",
        '[1, 2, false, null, "//",]',
        '{/* inner }, */ "mode": "system", "light": "One Light", "dark": "Omazed",}',
    ]
    randomizer = random.Random(8182)
    for index in range(120):
        action = "font" if index % 2 else "theme"
        key = "buffer_font_family" if action == "font" else "theme"
        font = randomizer.choice(fonts)
        old_value = randomizer.choice(values)
        newline = "\r\n" if index % 3 == 0 else "\n"
        bom = "\ufeff" if index % 5 == 0 else ""
        nested = json.dumps({"theme": "Nested", "buffer_font_family": "Nested", "numbers": [1, 2, 3], "flags": [True, False, None]})
        before = (bom + "/* leading } , */" + newline + "{" + newline +
                  '  "nested": ' + nested + "," + newline +
                  f'  "{key}" /* before colon, }} */ : /* before value */ ')
        after = (" /* after value, } */," + newline +
                 '  "unrelated": [1, 2, 3,], // trailing comment with } , ' + newline +
                 "}" + newline)
        replacement = json.dumps(font if action == "font" else "Omarchy", ensure_ascii=False)
        args = ("--font", font) if action == "font" else ("--select",)
        assert_update(before + old_value + after, before + replacement + after, *args)
    print("ok - 120 JSONC updates preserve comments, nested values, escapes, CRLF, BOM, and permissions")

    for source in ("{}", "{ /* comment, } */ }", "\ufeff{\n// comment\n}", "{\r\n// comment\r\n}"):
        root_start = source.index("{")
        newline = "\r\n" if "\r\n" in source else "\n"
        expected = source[:root_start + 1] + newline + '  "buffer_font_family": "New Font"' + source[root_start + 1:]
        assert_update(source, expected, "--font", "New Font")
    print("ok - missing settings are inserted into empty and comment-only JSONC objects")

    invalid = [
        "{", '{"theme": "Old"', '{"theme": "Old", "broken": [1, 2}',
        '{"theme": "Old"} trailing', '{"theme": "Old", "broken": NaN}',
        '{"theme": "Old", "theme": "Other"}',
        '{"buffer_font_family": "Old", "buffer_font_family": "Other"}',
        '{"theme": /* unterminated',
    ]
    for source in invalid:
        settings.write_text(source, encoding="utf-8")
        action = ("--font", "New Font") if "buffer_font_family" in source else ("--select",)
        result = invoke(*action)
        if result.returncode == 0 or settings.read_text(encoding="utf-8") != source:
            raise AssertionError(f"invalid or ambiguous settings were not preserved: {source!r}")
    print("ok - malformed and duplicate target settings fail without changing the file")

    invalid_utf8 = b'{"theme":"\xff"}'
    settings.write_bytes(invalid_utf8)
    result = invoke("--font", "New Font")
    if result.returncode == 0 or settings.read_bytes() != invalid_utf8 or "Traceback" in result.stderr:
        raise AssertionError("invalid UTF-8 was not reported without changing settings")
    print("ok - invalid UTF-8 is reported without changing settings")

    original = '{"theme":"Old", "buffer_font_family":"Before"}\n'
    settings.unlink()
    target = home / "settings target.json"
    target.write_text(original, encoding="utf-8")
    os.chmod(target, 0o640)
    settings.symlink_to(target)
    result = invoke("--font", "After")
    if result.returncode or not settings.is_symlink() or stat.S_IMODE(target.stat().st_mode) != 0o640:
        raise AssertionError("a symlinked settings file or its permissions were not preserved")
    if json.loads(target.read_text()) != {"theme": "Old", "buffer_font_family": "After"}:
        raise AssertionError("the symlink target was not correctly updated")
    settings.unlink()
    print("ok - symlinked settings targets and their permissions are preserved")

    for existing in (True, False):
        for _ in range(10):
            if existing:
                settings.write_text(json.dumps({"theme": "Old", "buffer_font_family": "Old", "padding": "x" * 100000}))
            else:
                settings.unlink(missing_ok=True)
            commands = [[str(command), "--select"] for _ in range(3)]
            commands += [[str(command), "--font", "New Font"] for _ in range(3)]
            children = [subprocess.Popen(args, env=env, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE) for args in commands]
            for child in children:
                _, error = child.communicate()
                if child.returncode:
                    raise AssertionError(f"concurrent settings update failed: {error.decode()}")
            result = json.loads(settings.read_text())
            if result["theme"] != "Omarchy" or result["buffer_font_family"] != "New Font":
                raise AssertionError("concurrent theme and font updates lost a setting")
    print("ok - concurrent native theme and font updates do not overwrite one another")

    # Replacing an existing settings file must fail without truncating it when
    # the directory is not writable. Restore permissions for temporary cleanup.
    settings.write_text(original, encoding="utf-8")
    os.chmod(config, 0o500)
    try:
        result = invoke("--font", "After")
        if os.geteuid() != 0 and (result.returncode == 0 or settings.read_text() != original):
            raise AssertionError("an unwritable settings directory was not handled safely")
        if os.geteuid() != 0 and ("Could not update Zed settings" not in result.stderr or "Traceback" in result.stderr):
            raise AssertionError("an unwritable settings directory was not reported clearly")
    finally:
        os.chmod(config, 0o700)
    print("ok - an unwritable settings directory does not truncate the user's settings")
PY
