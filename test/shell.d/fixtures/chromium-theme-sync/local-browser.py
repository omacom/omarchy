"""Manual Theme Sync check without touching the developer's browser profile."""

import argparse
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import os
from pathlib import Path
import selectors
import signal
import subprocess
import sys
import tempfile
import threading


parser = argparse.ArgumentParser(prog="test/browser-theme-sync", usage="%(prog)s [--desktop]", description=__doc__)
parser.add_argument("root", type=Path, help=argparse.SUPPRESS)
parser.add_argument("--desktop", action="store_true", help="observe the real desktop theme read-only instead of a synthetic palette")
args = parser.parse_args()
root = args.root
browser_binary = Path("/usr/lib/chromium/chromium")
if not browser_binary.is_file():
  parser.error("Chromium must be installed to run this manual check")
desktop = Path.home() / ".local/state/omarchy/current"
if args.desktop and not desktop.is_dir():
  parser.error("there is no current Omarchy desktop theme to observe")

palettes = {
  "dark": 'mode="dark"\nbackground="#17212b"\nforeground="#e4ecf2"\naccent="#79c0ff"\n',
  "light": 'mode="light"\nbackground="#f2f6fa"\nforeground="#17212b"\naccent="#005b9e"\n',
}
page = Path(__file__).with_name("demo.html").read_bytes()


class Handler(BaseHTTPRequestHandler):
  def do_GET(self):
    if self.path != "/":
      self.send_error(404)
      return
    self.send_response(200)
    self.send_header("Content-Type", "text/html; charset=utf-8")
    self.send_header("Cache-Control", "no-store")
    self.send_header("Content-Length", str(len(page)))
    self.end_headers()
    self.wfile.write(page)

  def log_message(self, *_):
    pass


def interrupted(*_):
  raise KeyboardInterrupt


with tempfile.TemporaryDirectory(prefix="omarchy-browser-theme-sync-") as directory:
  scratch = Path(directory)
  home = scratch / "home"
  config = home / ".config"
  profile = config / "chromium"
  runtime = scratch / "run"
  runtime.mkdir(mode=0o700)
  current = home / ".local/state/omarchy/current"
  current.parent.mkdir(parents=True)
  if args.desktop:
    current.symlink_to(desktop, target_is_directory=True)
  else:
    (current / "theme").mkdir(parents=True)
    (current / "theme/colors.toml").write_text(palettes["dark"])
  host_dir = profile / "NativeMessagingHosts"
  host_dir.mkdir(parents=True)
  manifest = json.loads((root / "default/chromium/native-messaging-hosts/com.omarchy.theme.json").read_text())
  manifest["path"] = str(root / "bin/omarchy-browser-theme-host")
  (host_dir / "com.omarchy.theme.json").write_text(json.dumps(manifest))
  server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
  server.daemon_threads = True
  thread = threading.Thread(target=server.serve_forever, daemon=True)
  thread.start()
  url = f"http://127.0.0.1:{server.server_port}/"
  environment = dict(os.environ, HOME=str(home), OMARCHY_PATH=str(root), XDG_CONFIG_HOME=str(config),
    XDG_STATE_HOME=str(home / ".local/state"), XDG_DATA_HOME=str(home / ".local/share"),
    XDG_CACHE_HOME=str(home / ".cache"), XDG_RUNTIME_DIR=str(runtime))
  # Keep access to the existing display without using its runtime directory for
  # browser state. No real profile, flags file, or native registration is edited.
  display = environment.get("WAYLAND_DISPLAY", "")
  if display and not display.startswith("/"):
    environment["WAYLAND_DISPLAY"] = str(Path(os.environ["XDG_RUNTIME_DIR"]) / display)
  environment.pop("BASH_ENV", None)
  extension = root / "default/chromium/extensions/theme-sync"
  log = (scratch / "chromium.log").open("w")
  browser = None
  try:
    print(f"Temporary browser: {profile}\nTest page: {url}", flush=True)
    print("Click Theme Sync in Chromium's extensions menu, then approve the browser prompt.", flush=True)
    print("Click it again to revoke this site; right-click it to stop sharing on all sites.", flush=True)
    if args.desktop:
      print("The native host observes your desktop read-only. Change themes normally to test updates.", flush=True)
    else:
      print("Type light or dark + Enter here to change only the synthetic palette.", flush=True)
    print("Close this temporary browser or press Ctrl+C to clean up. Do not sign into this test profile.", flush=True)
    browser = subprocess.Popen([str(browser_binary), "--no-first-run", "--no-default-browser-check", "--disable-sync",
      "--disable-background-networking", "--disable-component-update", "--password-store=basic",
      f"--user-data-dir={profile}", f"--load-extension={extension}", f"--disable-extensions-except={extension}", url],
      env=environment, stdout=log, stderr=log, start_new_session=True)
    signal.signal(signal.SIGTERM, interrupted)
    with selectors.DefaultSelector() as selector:
      pidfd = os.pidfd_open(browser.pid)
      try:
        selector.register(pidfd, selectors.EVENT_READ, "browser")
        if not args.desktop:
          try:
            selector.register(sys.stdin, selectors.EVENT_READ, "input")
          except (PermissionError, ValueError):
            pass
        while True:
          finished = False
          for key, _ in selector.select():
            if key.data == "browser":
              finished = True
              break
            line = sys.stdin.readline()
            if not line:
              selector.unregister(sys.stdin)
            elif line.strip() in palettes:
              (current / "theme/colors.toml").write_text(palettes[line.strip()])
              print(f"Synthetic palette: {line.strip()}", flush=True)
            else:
              print("Use light or dark, then Enter.", flush=True)
          if finished:
            break
      finally:
        os.close(pidfd)
    status = browser.wait()
    if status != 0:
      log.flush()
      print((scratch / "chromium.log").read_text(), file=sys.stderr)
      raise SystemExit(status if status > 0 else 1)
  except KeyboardInterrupt:
    pass
  finally:
    if browser is not None and browser.poll() is None:
      browser.terminate()
      try:
        browser.wait(timeout=5)
      except subprocess.TimeoutExpired:
        os.killpg(browser.pid, signal.SIGKILL)
        browser.wait()
    server.shutdown()
    server.server_close()
    thread.join()
    log.close()
