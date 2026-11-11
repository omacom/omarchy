import os, pathlib, subprocess, tempfile
script = pathlib.Path(os.environ['OMARCHY_TEST_ROOT']) / 'bin/omarchy-setup-gaming'
with tempfile.TemporaryDirectory(prefix='haki-gaming-test-') as temp:
    root = pathlib.Path(temp)
    commands = {
        'omarchy-i18n': '#!/bin/bash\nvalue=$("$OMARCHY_TEST_ROOT/bin/omarchy-i18n" "$@") || exit $?\nif [[ ${TEST_TRANSLATED:-0} == 1 ]]; then printf "translated:%s\\n" "$value"; else printf "%s\\n" "$value"; fi\n',
        'omarchy-cmd-present': '#!/bin/bash\n[[ $1 == steam && $STEAM_PRESENT == 1 ]]\n',
        'omarchy-menu-select': '''#!/bin/bash
printf '%s\\n' "$*" >> "$TEST_ROOT/menus"
read -r count < "$TEST_ROOT/count"
printf '%s\\n' "$((count + 1))" > "$TEST_ROOT/count"
line=$(sed -n "$((count + 1))p" "$TEST_ROOT/choices")
case "$line" in CANCEL) exit 1;; ERROR) exit 2;; esac
valid=0
for option in "${@:2}"; do
  [[ $option == "--" ]] && break
  label=${option#*$'\t'}; label=${label%%$'\t'*}
  [[ $line == "$label" ]] && valid=1
done
[[ $valid == 1 ]] || { echo "Selection is not an offered row: $line" >&2; exit 93; }
printf '%s\\tfixture subtext\\n' "$line"
''',
        'omarchy-launch-steam-bigpicture': '#!/bin/bash\necho bigpicture >> "$TEST_ROOT/actions"\n',
        'omarchy-launch-steam-desktop': '#!/bin/bash\necho desktop >> "$TEST_ROOT/actions"\n',
        'omarchy-menu': '#!/bin/bash\necho "$*" >> "$TEST_ROOT/actions"\n',
    }
    for name, source in commands.items():
        path = root / name
        path.write_text(source)
        path.chmod(0o755)
    cases = [
        ('installed-launch', 1, ['Open Big Picture'], 0, 'bigpicture\n'),
        ('translated-launch', 1, ['Open Big Picture'], 0, 'bigpicture\n'),
        ('missing-steam', 0, ['Install Steam…'], 0, 'summon install.gaming\n'),
        ('cancel', 1, ['CANCEL'], 0, ''),
        ('desktop-return', 1, ['Desktop Mode'], 0, 'desktop\n'),
        ('shell-failure', 1, ['ERROR'], 2, ''),
        ('guidance-return', 1, ['Help and first sign-in', 'First sign-in', 'Back', 'Help and first sign-in', 'Controller and typing', 'Back', 'Help and first sign-in', 'Return to desktop', 'Back', 'Close'], 0, ''),
        ('guidance-cancel', 1, ['Help and first sign-in', 'First sign-in', 'CANCEL'], 0, ''),
    ]
    for name, present, choices, status, actions in cases:
        translated = name.startswith('translated-')
        if translated:
            choices = ['translated:' + choice for choice in choices]
        (root / 'choices').write_text('\n'.join(choices) + '\n')
        (root / 'count').write_text('0\n')
        (root / 'actions').write_text('')
        (root / 'menus').write_text('')
        env = dict(os.environ, PATH=f'{root}:' + str(script.parent) + ':' + os.environ['PATH'], HOME=temp, OMARCHY_PATH=str(script.parent.parent), TEST_ROOT=temp, STEAM_PRESENT=str(present), TEST_TRANSLATED=str(int(translated)))
        result = subprocess.run([str(script)], env=env, capture_output=True, text=True, timeout=15)
        assert result.returncode == status, (name, result)
        assert (root / 'actions').read_text() == actions, name
        menus = (root / 'menus').read_text()
        assert ('Open Big Picture' in menus) == bool(present), name
        assert ('Install Steam…' in menus) != bool(present), name
        print('PASS', name)
    result = subprocess.run([str(script), '--help'], env={'PATH': '/usr/bin:/bin'}, capture_output=True, text=True)
    assert result.returncode == 0 and 'first sign-in' in result.stdout
    print('PASS standalone-help')
