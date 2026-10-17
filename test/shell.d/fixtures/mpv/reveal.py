"""Check independent toolbar input and visibility in headless mpv."""
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[4]
result = subprocess.run([
    'mpv', '--no-config', '--vo=null', '--ao=null', '--osc=no', '--pause=yes',
    f'--script={ROOT}/test/shell.d/fixtures/mpv/reveal.lua',
    '--script-opts=omarchy-controls-debug=yes',
    'av://lavfi:testsrc2=size=640x360:rate=24',
], env={**os.environ, 'MPV_REVEAL_CONTROLLER':
        str(ROOT / 'config/mpv/scripts/omarchy-controls.lua')},
    capture_output=True, text=True, timeout=15)
output = result.stdout + result.stderr
assert result.returncode == 0 and 'PASS: separate reveals' in output, output
assert 'stack traceback' not in output, output
print('PASS: independent toolbar visibility, input capture, icons, subtitles, dragging, and keyboard focus.')
