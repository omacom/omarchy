"""Dependency-free local UI and deliberately small desktop action boundary."""

import argparse
import json
import os
from pathlib import Path
import secrets
import shutil
import subprocess
import tempfile
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlsplit

WEB = Path(__file__).parent / "web"
STEPS = ("welcome", "icloud", "email", "files", "desktop", "apps", "ready")
TASKS = ("drive", "photos", "email", "local-files", "bookmarks", "passwords", "desktop", "backup")
SERVICES = {
  "drive": ("iCloud Drive", "https://www.icloud.com/iclouddrive/", "folder-cloud"),
  "photos": ("iCloud Photos", "https://www.icloud.com/photos/", "image-x-generic"),
  "mail": ("iCloud Mail", "https://www.icloud.com/mail/", "internet-mail"),
  "calendar": ("iCloud Calendar", "https://www.icloud.com/calendar/", "x-office-calendar"),
  "notes": ("iCloud Notes", "https://www.icloud.com/notes/", "accessories-text-editor"),
}


def xdg_path(variable, default):
  value = os.environ.get(variable, "")
  return Path(value) if value and Path(value).is_absolute() else Path.home() / default


def atomic_json(path, data):
  path.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
  fd, temporary = tempfile.mkstemp(dir=path.parent, prefix=".state-")
  try:
    with os.fdopen(fd, "w") as stream:
      json.dump(data, stream, indent=2)
      stream.write("\n")
    os.replace(temporary, path)
  finally:
    Path(temporary).unlink(missing_ok=True)


class Wizard:
  def __init__(self, state_dir=None):
    self.state_dir = Path(state_dir) if state_dir else xdg_path("XDG_STATE_HOME", ".local/state") / "omarchy-wizard"
    self.applications = xdg_path("XDG_DATA_HOME", ".local/share") / "applications"
    self.lock = threading.Lock()
    self.state = {"step": "welcome", "completed": [], "tasks": [], "finished": False}
    self.warning = None
    try:
      loaded = json.loads((self.state_dir / "state.json").read_text())
      self.validate_state(loaded)
      self.state = loaded
    except FileNotFoundError:
      pass
    except (ValueError, TypeError, OSError):
      self.warning = "Saved progress could not be read. You can start again; your files and shortcuts are unchanged."

  @staticmethod
  def validate_state(data):
    if not isinstance(data, dict) or set(data) != {"step", "completed", "tasks", "finished"}:
      raise ValueError("Invalid progress data")
    if data["step"] not in STEPS or type(data["finished"]) is not bool:
      raise ValueError("Invalid step")
    for key, allowed in (("completed", STEPS), ("tasks", TASKS)):
      values = data[key]
      if not isinstance(values, list) or len(values) > len(allowed) or any(not isinstance(v, str) or v not in allowed for v in values) or len(set(values)) != len(values):
        raise ValueError("Invalid checklist")

  def save(self, data):
    self.validate_state(data)
    with self.lock:
      atomic_json(self.state_dir / "state.json", data)
      self.state = data
    return {"ok": True}

  def shortcut_path(self, service):
    return self.applications / f"omarchy-wizard-{service}.desktop"

  def shortcut_text(self, service):
    name, url, icon = SERVICES[service]
    launcher = "omarchy-launch-webapp"
    return f"[Desktop Entry]\nVersion=1.0\nType=Application\nName={name}\nComment=Open {name} on the web\nExec={launcher} {url}\nIcon={icon}\nTerminal=false\nCategories=Network;\nX-Omarchy-Wizard=true\n"

  def install_shortcut(self, service):
    self.applications.mkdir(parents=True, exist_ok=True)
    path = self.shortcut_path(service)
    content = self.shortcut_text(service)
    with self.lock:
      try:
        with path.open("x") as stream:
          stream.write(content)
      except FileExistsError:
        if path.is_symlink() or path.read_text() != content:
          raise ValueError("A different launcher already uses this filename. It was left unchanged.")
    return {"ok": True, "message": f"{SERVICES[service][0]} added to your app launcher. Sign in in the Apple window."}

  def remove_shortcut(self, service):
    path = self.shortcut_path(service)
    with self.lock:
      if path.is_symlink():
        raise ValueError("This launcher was changed outside the wizard. It was left unchanged.")
      if path.exists():
        if path.read_text() != self.shortcut_text(service):
          raise ValueError("This launcher was changed outside the wizard. It was left unchanged.")
        path.unlink()
    return {"ok": True, "message": "Shortcut removed. Your iCloud data is unchanged."}

  @staticmethod
  def run(command):
    if command[0] == "thunderbird" and not shutil.which("thunderbird"):
      raise ValueError("This action is not available on this desktop.")
    try:
      process = subprocess.Popen(command, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True)
      result = process.wait(timeout=0.35)
    except subprocess.TimeoutExpired:
      threading.Thread(target=process.wait, daemon=True).start()
      return {"ok": True, "message": "Opening on your desktop. Finish this step in the app, then return here."}
    if result:
      raise ValueError("The desktop could not open this action. Try it from the Omarchy menu.")
    return {"ok": True, "message": "Opened on your desktop."}

  @staticmethod
  def capabilities():
    return {
      "settings": True,
      "email-client": bool(shutil.which("thunderbird")),
      "shortcuts": True,
      "files": True,
      "webapps": True,
    }

  def action(self, action, service=None):
    if action in ("install", "remove", "open"):
      if service not in SERVICES:
        raise ValueError("Unknown service")
      if action == "install":
        return self.install_shortcut(service)
      if action == "remove":
        return self.remove_shortcut(service)
      launcher = "omarchy-launch-webapp"
      return self.run([launcher, SERVICES[service][1]])
    commands = {
      "email-client": ["thunderbird"],
      "settings": ["omarchy-menu", "summon", "setup"],
      "shortcuts": ["omarchy-menu-keybindings"],
      "files": ["omarchy-launch-nautilus"],
    }
    if action not in commands:
      raise ValueError("Unknown action")
    return self.run(commands[action])

  def snapshot(self):
    version_path = Path(os.environ["OMARCHY_PATH"]) / "version"
    try:
      version = version_path.read_text().strip()[:64]
    except OSError:
      version = None
    return {
      "state": self.state,
      "warning": self.warning,
      "version": version,
      "capabilities": self.capabilities(),
      "installed": [s for s in SERVICES if self.shortcut_path(s).is_file()],
      "free_gb": round(shutil.disk_usage(Path.home()).free / 1024**3),
    }


class Server(ThreadingHTTPServer):
  daemon_threads = True

  def __init__(self, address, wizard):
    super().__init__(address, Handler)
    self.wizard = wizard
    self.token = secrets.token_urlsafe(32)
    self.origin = f"http://127.0.0.1:{self.server_port}"
    self.last_seen = time.monotonic()


class Handler(BaseHTTPRequestHandler):
  def log_message(self, *args):
    # Avoid logging the session token or browsing activity.
    pass

  def send(self, status, content, mime="application/json"):
    if isinstance(content, dict):
      content = json.dumps(content).encode()
    elif isinstance(content, str):
      content = content.encode()
    self.send_response(status)
    self.send_header("Content-Type", mime)
    self.send_header("Content-Length", str(len(content)))
    self.send_header("Cache-Control", "no-store")
    self.send_header("X-Content-Type-Options", "nosniff")
    self.send_header("Referrer-Policy", "no-referrer")
    self.send_header("Content-Security-Policy", "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; connect-src 'self'; frame-ancestors 'none'; base-uri 'none'; form-action 'none'")
    self.end_headers()
    self.wfile.write(content)

  def valid_host(self):
    if self.headers.get("Host") != f"127.0.0.1:{self.server.server_port}":
      self.send(403, {"error": "Invalid host"})
      return False
    return True

  def authenticated(self):
    supplied = self.headers.get("X-Wizard-Token", "")
    if not secrets.compare_digest(supplied, self.server.token):
      self.send(403, {"error": "Session expired. Reopen the wizard from your desktop."})
      return False
    return True

  def do_GET(self):
    if not self.valid_host():
      return
    route = urlsplit(self.path).path
    if route == "/api/state":
      if self.authenticated():
        self.server.last_seen = time.monotonic()
        self.send(200, self.server.wizard.snapshot())
      return
    files = {"/": ("index.html", "text/html; charset=utf-8"), "/app.js": ("app.js", "text/javascript; charset=utf-8"), "/style.css": ("style.css", "text/css; charset=utf-8"), "/icon.svg": ("icon.svg", "image/svg+xml")}
    if route not in files:
      self.send(404, {"error": "Not found"})
      return
    name, mime = files[route]
    self.send(200, (WEB / name).read_bytes(), mime)

  def do_POST(self):
    if not self.valid_host() or not self.authenticated():
      return
    if self.headers.get("Origin") != self.server.origin:
      self.send(403, {"error": "Invalid origin"})
      return
    try:
      length = int(self.headers.get("Content-Length", "0"))
      if not 0 < length <= 8192:
        raise ValueError("Invalid request size")
      if self.headers.get_content_type() != "application/json":
        raise ValueError("Expected JSON")
      self.connection.settimeout(5)
      data = json.loads(self.rfile.read(length))
      if not isinstance(data, dict):
        raise ValueError("Expected an object")
      route = urlsplit(self.path).path
      if route == "/api/state":
        result = self.server.wizard.save(data)
      elif route == "/api/action":
        if not isinstance(data.get("action"), str) or ("service" in data and not isinstance(data["service"], str)):
          raise ValueError("Invalid action")
        result = self.server.wizard.action(data["action"], data.get("service"))
      else:
        self.send(404, {"error": "Not found"})
        return
      self.server.last_seen = time.monotonic()
      self.send(200, result)
    except json.JSONDecodeError:
      self.send(400, {"error": "Invalid JSON"})
    except (ValueError, TypeError) as error:
      self.send(400, {"error": str(error)})
    except OSError:
      self.send(500, {"error": "Could not access the desktop or save progress. Check available disk space and permissions."})


def main():
  parser = argparse.ArgumentParser(description="Welcome to Omarchy — a local guide for moving from macOS")
  parser.add_argument("--no-browser", action="store_true", help="Print the local URL without opening a window")
  parser.add_argument("--port", type=int, default=0, help="Loopback port (default: select a free port)")
  parser.add_argument("--state-dir", type=Path, help="Use a separate progress directory for testing")
  args = parser.parse_args()
  server = Server(("127.0.0.1", args.port), Wizard(args.state_dir))
  url = f"{server.origin}/#{server.token}"
  print(f"Welcome wizard: {url}", flush=True)
  if not args.no_browser:
    command = ["omarchy-launch-webapp", url]
    try:
      subprocess.Popen(command, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except OSError:
      print("Open the URL above in your browser.", flush=True)

  def expire():
    while True:
      time.sleep(30)
      if time.monotonic() - server.last_seen > 300:
        server.shutdown()
        return

  threading.Thread(target=expire, daemon=True).start()
  try:
    server.serve_forever()
  except KeyboardInterrupt:
    pass
  finally:
    server.server_close()


if __name__ == "__main__":
  main()
