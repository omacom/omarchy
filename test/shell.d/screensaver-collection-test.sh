#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command magick

python3 - "$ROOT" <<'PY'
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

root = Path(sys.argv[1])
prepare = root / "bin/omarchy-screensaver-prepare"


def check(value, label):
  if not value:
    raise AssertionError(label)
  print("ok - " + label, flush=True)


with tempfile.TemporaryDirectory() as temporary:
  temp = Path(temporary)
  source = temp / "art collection"
  source.mkdir()
  (source / "01.txt").write_text("FIRST\n")
  (source / "02.txt").write_text("⣿⣿⣿\nSECOND\n")

  def run(path=source, success=True):
    output = Path(tempfile.mkdtemp(dir=temp))
    result = subprocess.run([prepare, str(path), str(output)], cwd=temp, capture_output=True, timeout=5)
    check((result.returncode == 0) == success, "source preparation " + ("succeeds" if success else "refuses unusable input"))
    return [p.read_text() for p in sorted(output.glob("*.txt"))]

  check(run() == ["FIRST\n", "⣿⣿⣿\nSECOND\n"], "collection preserves text in filename order")
  check(run(source / "02.txt") == ["⣿⣿⣿\nSECOND\n"], "single-file source preserves braille")
  selected_link = temp / "selected-link"
  selected_link.symlink_to(source, target_is_directory=True)
  check(run(selected_link) == run(), "an explicitly selected directory symlink works")

  (source / "escape.txt").symlink_to(source / "01.txt")
  (source / "loop.txt").symlink_to(source / "loop.txt")
  (source / "folder.txt").mkdir()
  (source / "folder.txt" / "nested.txt").write_text("NESTED")
  os.mkfifo(source / "pipe.txt")
  (source / ".hidden.txt").write_text("HIDDEN")
  (source / "image.png").write_text("IMAGE")
  (source / "binary.txt").write_bytes(b"\xff\x00")
  (source / "empty.txt").write_text(" \n\t")
  (source / "escape-sequence.txt").write_text("\x1b]52;c;SEVMTE8=\x07")
  (source / "c1.txt").write_text("\u009b31m")
  (source / "oversize.txt").write_text("X" * 1048577)
  (source / "wide.txt").write_text("X" * 513)
  (source / "tall.txt").write_text("X\n" * 129)
  (source / "long-sgr.txt").write_text("\x1b[" + "1;" * 30 + "m" + "X")
  (source / "sgr-then-osc.txt").write_text("\x1b[31mX\x1b]0;title\x07")
  (source / "sgr-cursor.txt").write_text("\x1b[31mX\x1b[2J")
  (source / "sgr-overflow.txt").write_text("\x1b[99999999999999999999mX")
  (source / "sgr-big-value.txt").write_text("\x1b[38;5;300mX")
  (source / "sgr-bad-arity.txt").write_text("\x1b[38;7;1mX")
  (source / "sgr-dangling.txt").write_text("\x1b[38mX")
  check(run() == ["FIRST\n", "⣿⣿⣿\nSECOND\n"], "links, special files, non-text files, controls and excessive artwork are skipped")
  run(source / "pipe.txt", success=False)
  colour = "\x1b[38;2;255;0;0;48;2;0;0;255m▀▄\x1b[0m\n"
  (source / "00-colour.txt").write_text(colour)
  check(run()[0] == colour, "SGR colour sequences pass through unchanged")
  (source / "00-colour.txt").write_text(("\x1b[38;2;1;2;3;48;2;4;5;6m" + "█" * 500 + "\x1b[0m\n") * 120)
  check(len(run()[0].encode()) > 65536, "a colour picture larger than the old 64 KiB limit is accepted")
  (source / "00-colour.txt").write_text("\x1b[38;2;1;2;3m" + "X" * 513 + "\x1b[0m\n")
  check(run()[0] == "FIRST\n", "the line limit applies to visible text, not to colour sequences")
  (source / "00-colour.txt").write_text("\x1b[38;2;1;2;3m \x1b[0m\n")
  check(run()[0] == "FIRST\n", "colour around blank text is still empty artwork")
  (source / "00-colour.txt").write_text("\x1b[0;1;38;5;196;48;2;0;0;0mX\x1b[m\n")
  check(run()[0].startswith("\x1b[0;1;38;5;196"), "attribute, 256-colour and empty SGR parameters are accepted")
  (source / "00-colour.txt").write_text("X" * 513 + "\n" + "\x1b[m" * 300000 + "\n")
  import time
  started = time.monotonic()
  check(run()[0] == "FIRST\n" and time.monotonic() - started < 2, "a large over-wide file is rejected quickly")
  for name in ("00-colour.txt", "long-sgr.txt", "sgr-then-osc.txt", "sgr-cursor.txt", "sgr-overflow.txt",
               "sgr-big-value.txt", "sgr-bad-arity.txt", "sgr-dangling.txt"):
    (source / name).unlink()

  import re
  image = temp / "photo.png"
  subprocess.run(["magick", "-size", "120x80", "gradient:red-blue", str(image)], check=True, timeout=30)
  converted = temp / "photo.txt"
  subprocess.run([root / "bin/omarchy-transcode-ascii", str(image), str(converted), "--mode", "color",
                  "--width", "40", "--height", "20"], check=True, capture_output=True, timeout=60)
  visible = re.sub(r"\x1b\[[0-9;]*m", "", converted.read_text())
  check(0 < len(visible.splitlines()) <= 20 and all(0 < len(line) <= 40 for line in visible.splitlines())
        and set(visible.replace("\n", "")) <= set("▘▝▀▖▌▞▛▗▚▐▜▄▙▟█"),
        "colour conversion fits the cell box using block glyphs only")
  check("\x1b[38;2;" in converted.read_text() and run(converted) == [converted.read_text()],
        "colour conversion carries truecolour and passes playback validation")

  marker = temp / "EXECUTED"
  hostile = source / "03-$(touch EXECUTED) `touch EXECUTED`\n--help.txt"
  hostile.write_text("LITERAL NAME\n")
  check(run()[-1] == "LITERAL NAME\n" and not marker.exists(), "shell syntax, newlines and options in filenames remain data")
  with tempfile.TemporaryDirectory(dir=temp) as snapshot:
    subprocess.run([prepare, str(source), snapshot], check=True)
    (source / "01.txt").write_text("CHANGED\n")
    check((Path(snapshot) / "000.txt").read_text() == "FIRST\n", "playback copy is unaffected by source replacement")
    check((Path(snapshot) / "000.txt").stat().st_mode & 0o777 == 0o600, "playback files are private")

  empty = temp / "empty"
  empty.mkdir()
  run(empty, success=False)
  run(temp / "missing", success=False)
  run("relative/path", success=False)

  many = temp / "many"
  many.mkdir()
  for index in range(129):
    (many / f"{index:03d}.txt").write_text(str(index))
  check(len(run(many)) == 128, "artwork count is bounded")
  for index in range(4096 - 129 + 1):
    (many / f"extra-{index}").touch()
  run(many, success=False)

  # Exercise the real runtime with a fake desktop and renderer. Nothing reaches
  # the running compositor, the user's branding, or their processes.
  home = temp / "home"
  branding = home / ".config/omarchy/branding"
  branding.mkdir(parents=True)
  (branding / "screensaver.txt").write_text("DEFAULT\n")
  config = branding.parent / "shell.json"
  stubs = temp / "bin"
  stubs.mkdir()
  log = temp / "frames"
  calls = temp / "calls"
  scratch = temp / "scratch"
  scratch.mkdir()

  def stub(name, content):
    file = stubs / name
    file.write_text("#!/bin/bash\n" + content)
    file.chmod(0o755)

  stub("hyprctl", '''if [[ $1 == activewindow ]]; then
  if (( $(wc -l < "$FRAME_LOG") >= 4 )); then
    printf '%s\\n' '{"class":"other"}'
  else
    printf '%s\\n' '{"class":"org.omarchy.screensaver"}'
  fi
fi
''')
  stub("ttfx", 'printf "%s\\n" "$2" >> "$CALL_LOG"\nhead -n 1 -- "$2" >> "$FRAME_LOG"\n')
  stub("pgrep", 'sleep 0.1\n(( $(wc -l < "$FRAME_LOG") >= 4 ))\n')
  stub("pkill", 'exit 0\n')
  stub("stty", 'echo "60 160"\n')
  stub("tty", 'echo /dev/pts/99\n')
  environment = dict(os.environ, HOME=str(home), OMARCHY_PATH=str(root), TMPDIR=str(scratch),
                     PATH=str(stubs) + ":" + str(root / "bin") + ":" + os.environ["PATH"],
                     FRAME_LOG=str(log), CALL_LOG=str(calls))

  def play(settings):
    config.write_text(json.dumps(settings))
    log.write_text("")
    calls.write_text("")
    result = subprocess.run([root / "bin/omarchy-screensaver"], env=environment,
                            stdin=subprocess.DEVNULL, capture_output=True, timeout=10)
    check(result.returncode == 0, "screensaver exits on dismissal")
    check(not list(scratch.iterdir()), "dismissal removes playback copies")
    return log.read_text().splitlines()

  check(play({}) == ["DEFAULT"] * 4, "absent setting preserves default single-file playback")
  check(play({"screensaver": {"source": str(source / '01.txt')}}) == ["CHANGED"] * 4, "configured file plays through the runtime")
  check(play({"screensaver": {"source": str(source)}}) == ["CHANGED", "⣿⣿⣿", "LITERAL NAME", "CHANGED"], "runtime advances and wraps a collection")
  check(play({"screensaver": {"source": str(empty)}}) == ["DEFAULT"] * 4, "empty collection keeps the screensaver alive with its fallback")
  check(play({"screensaver": {"source": str(temp / 'missing')}}) == ["DEFAULT"] * 4, "missing source falls back instead of exiting")
  check(play({"screensaver": {"source": 42}}) == ["DEFAULT"] * 4, "invalid config type retains the default")
  stub("ttfx", 'printf "%s\\n" "$*" >> "$CALL_LOG"\nhead -n 1 -- "$2" >> "$FRAME_LOG"\n')
  play({"screensaver": {"source": str(source), "effects": ["wipe", "beams"]}})
  check(calls.read_text().splitlines() and all("--include-effects wipe beams --no-eol" in line
        and "--existing-color-handling ignore" in line for line in calls.read_text().splitlines()),
        "configured effects reach the renderer and plain text keeps the effect gradient")
  (source / "00-colour.txt").write_text("\x1b[38;2;255;0;0m▀\x1b[0m\n")
  play({"screensaver": {"source": str(source)}})
  handling = [line.split("--existing-color-handling ")[1].split()[0] for line in calls.read_text().splitlines()]
  check(handling[:2] == ["dynamic", "ignore"], "colour artwork settles on its own colours, plain artwork does not")
  (source / "00-colour.txt").unlink()
  play({"screensaver": {"source": str(source), "effects": ["wipe", "../x"]}})
  check(all("--include-effects" not in line for line in calls.read_text().splitlines()), "an invalid effect name disables the whole list")
  play({"screensaver": {"source": str(source), "effects": ["wipe", 5]}})
  check(all("--include-effects" not in line for line in calls.read_text().splitlines()), "a non-string entry disables the whole list")
  play({"screensaver": {"source": str(source), "effects": "wipe"}})
  check(all("--include-effects" not in line for line in calls.read_text().splitlines()), "a non-array effects setting is ignored")
  stub("ttfx", 'if [[ " $* " == *" --include-effects "* ]]; then exit 1; fi\nprintf "%s\\n" "$*" >> "$CALL_LOG"\nhead -n 1 -- "$2" >> "$FRAME_LOG"\n')
  play({"screensaver": {"source": str(source), "effects": ["nosuch"]}})
  check(calls.read_text().splitlines() and all("--include-effects" not in line for line in calls.read_text().splitlines()),
        "an effect list ttfx rejects is dropped and playback continues unfiltered")
  stub("ttfx", 'printf "%s\\n" "$2" >> "$CALL_LOG"\nhead -n 1 -- "$2" >> "$FRAME_LOG"\n')
  stub("mktemp", 'exit 1\n')
  check(play({"screensaver": {"source": str(source)}}) == ["DEFAULT"] * 4, "temporary-directory failure retains playback")
  (stubs / "mktemp").unlink()
  stub("timeout", 'exit 124\n')
  check(play({"screensaver": {"source": str(source)}}) == ["DEFAULT"] * 4, "preparation timeout retains playback and cleans its directory")
  (stubs / "timeout").unlink()
  (branding / "screensaver.txt").unlink()
  play({"screensaver": {"source": str(empty)}})
  check(set(calls.read_text().splitlines()) == {str(root / 'logo.txt')}, "missing user fallback uses the bundled logo")
  # Cleanup must not match unrelated process command lines or ttfx instances.
  import shutil
  import time
  sleeper = temp / 'org.omarchy.screensaver-unrelated' / 'ttfx'
  sleeper.parent.mkdir()
  shutil.copy2('/usr/bin/sleep', sleeper)
  unrelated = subprocess.Popen([str(sleeper), '30'])
  owned_pid = temp / 'owned-pid'
  dispatches = temp / 'dispatches'
  broad_kills = temp / 'broad-kills'
  environment.update(OWNED_PID=str(owned_pid), DISPATCHES=str(dispatches), BROAD_KILLS=str(broad_kills))
  stub('ttfx', 'echo $$ > "$OWNED_PID"\nexec sleep 30\n')
  stub('pkill', 'echo unsafe >> "$BROAD_KILLS"\n')
  stub('hyprctl', '''case "$1" in
activewindow) echo '{"class":"org.omarchy.screensaver"}';;
clients) echo '[{"class":"org.omarchy.screensaver","address":"0x123"},{"class":"other","address":"0x456"},{"class":"org.omarchy.screensaver","address":"bad;command"}]';;
dispatch) printf "%s\\n" "$2" >> "$DISPATCHES";;
esac
''')
  process = subprocess.Popen([root / 'bin/omarchy-screensaver'], env=environment,
                             stdin=subprocess.PIPE, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
  try:
    deadline = time.monotonic() + 5
    while not owned_pid.exists() and time.monotonic() < deadline:
      time.sleep(.02)
    check(owned_pid.exists(), 'runtime starts an owned animation child')
    child_pid = int(owned_pid.read_text())
    process.communicate(b'x', timeout=5)
    check(process.returncode == 0 and unrelated.poll() is None and not broad_kills.exists(),
          'dismissal leaves unrelated ttfx and matching command lines alone')
    check(not Path(f'/proc/{child_pid}').exists(), 'dismissal reaps its owned animation child')
    check('address:0x123' in dispatches.read_text() and '0x456' not in dispatches.read_text()
          and 'bad;command' not in dispatches.read_text(), 'cleanup closes only validated screensaver window addresses')
  finally:
    if process.poll() is None:
      process.kill()
    process.wait()
    unrelated.terminate()
    unrelated.wait()
  stub('ttfx', 'exit 1\n')
  stub('hyprctl', 'exit 1\n')
  process = subprocess.Popen([root / 'bin/omarchy-screensaver'], env=environment,
                             stdin=subprocess.PIPE, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
  try:
    time.sleep(1.2)
    check(process.poll() is None, 'renderer failure and unavailable compositor do not dismiss the idle window')
  finally:
    process.terminate()
    process.communicate(timeout=5)

PY
