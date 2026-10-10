import fcntl
import json
import os
from pathlib import Path
import pty
import re
import select
import shutil
import struct
import subprocess
import tempfile
import sys
import termios

root = Path(sys.argv[1]).resolve()
binary = shutil.which('fastfetch')
if not binary:
    sys.exit('fastfetch is required for the native logo rendering check')
config = json.loads((root / 'etc/fastfetch/config.jsonc').read_text())
# Isolate logo rendering from unrelated host-information modules and their ANSI.
production_modules = config['modules']
config['modules'] = [{'type': 'custom', 'format': 'TEST MODULE'}]
results = []
with tempfile.TemporaryDirectory(prefix='fastfetch paths ') as directory:
    packaged = Path(directory)
    config_path = packaged / 'native-config.json'
    config_path.write_text(json.dumps(config))
    for name in ['logo.txt', 'default/fastfetch/logo.txt', 'default/fastfetch/logo-small.txt', 'default/fastfetch/logo-none.txt']:
        destination = packaged / name
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy(root / name, destination)
    for columns, filename in [(80, 'default/fastfetch/logo-small.txt'), (120, 'default/fastfetch/logo.txt'), (160, 'logo.txt')]:
        env = os.environ.copy()
        env.update(OMARCHY_PATH=str(packaged), PATH=str(root / 'bin') + ':' + env['PATH'], COLUMNS=str(columns), LINES='40', LC_ALL='C')
        env.pop('NO_COLOR', None)
        expected = (packaged / filename).read_text().splitlines()
        for terminal, no_color in [(False, False), (True, False), (True, True)]:
            if no_color:
                env['NO_COLOR'] = '1'
            argv = [str(binary), '--config', str(config_path)]
            if terminal:
                master, slave = pty.openpty()
                fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack('HHHH', 40, columns, 0, 0))
                process = subprocess.Popen(argv, env=env, stdin=subprocess.DEVNULL, stdout=slave, stderr=slave)
                os.close(slave)
                chunks = []
                while True:
                    ready, _, _ = select.select([master], [], [], 5)
                    if not ready:
                        process.kill()
                        process.wait()
                        os.close(master)
                        raise AssertionError("fastfetch terminal output timed out")
                    try:
                        part = os.read(master, 65536)
                    except OSError:
                        break
                    if not part:
                        break
                    chunks.append(part)
                os.close(master)
                assert process.wait(timeout=5) == 0
                output = b''.join(chunks).decode()
            else:
                result = subprocess.run(argv, env=env, capture_output=True, text=True, timeout=5, check=True)
                assert not result.stderr, result.stderr
                output = result.stdout
            plain = re.sub(r'\x1b\[[0-9;?]*[A-Za-z]', '', output)
            assert all(line in plain for line in expected if line.strip()), (columns, terminal, no_color)
            has_color = '\x1b[32m' in output or '\x1b[1;32m' in output
            assert has_color == (terminal and not no_color), ('color', columns, terminal, no_color, has_color)
            if not terminal or no_color:
                assert '\x1b' not in output, 'Plain output contains escapes'
            results.append(dict(columns=columns, terminal=terminal, no_color=no_color, selected=filename, passed=True))
print('Native fastfetch:', len(results), 'size/color/redirect cases passed in C locale with spaced package path')

# Keep a native production-layout render at both normal and narrow widths.
# The 54-column custom boxes must start at column zero when the logo is hidden.
for columns in (64, 80):
    with tempfile.TemporaryDirectory() as directory:
        production = dict(config, modules=production_modules)
        production_path = Path(directory) / "production.json"
        production_path.write_text(json.dumps(production))
        env = dict(os.environ, OMARCHY_PATH=str(root), PATH=str(root / "bin") + ":" + os.environ["PATH"], COLUMNS=str(columns), LINES="40", NO_COLOR="1")
        result = subprocess.run([binary, "--config", str(production_path)], env=env, capture_output=True, text=True, timeout=10, check=True)
        plain = re.sub(r"\x1b\[[0-9;?]*[A-Za-z]", "", result.stdout)
        boxes = [line for line in plain.splitlines() if "Hardware" in line or "Software" in line]
        assert len(boxes) == 2, result.stdout
        if columns == 64:
            assert all(line.lstrip().startswith("┌") and len(line) <= columns for line in boxes), boxes
            assert "██████████████" not in plain, plain
print("Native fastfetch: production module layout checked at 64 and 80 columns")
