"""Import the ordinary open/PSK profiles left behind by the Quattro upgrade."""

import os
from pathlib import Path
import re
import stat
import subprocess
import sys
import tempfile
import uuid

import gi

gi.require_version("NM", "1.0")
from gi.repository import GLib, NM


class UnsupportedProfile(Exception):
  pass


def read_keyfile(path):
  # Never follow a profile symlink or block on a FIFO in the old store.
  fd = os.open(path, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK)
  with os.fdopen(fd, "rb") as source:
    if not stat.S_ISREG(os.fstat(source.fileno()).st_mode):
      raise ValueError("not a regular profile")
    data = source.read().decode("utf-8")
  keyfile = GLib.KeyFile()
  keyfile.load_from_data(data, len(data.encode("utf-8")), GLib.KeyFileFlags.NONE)
  return keyfile


def string(keyfile, group, key, default=""):
  if not keyfile.has_group(group) or key not in keyfile.get_keys(group)[0]:
    return default
  return keyfile.get_string(group, key)


def boolean(keyfile, key, default):
  # iwd also accepts 0/1, unlike GKeyFile's boolean accessor.
  value = string(keyfile, "Settings", key, "true" if default else "false")
  if value not in ("true", "false", "0", "1"):
    raise ValueError("invalid boolean")
  return value in ("true", "1")


def profile_ssid(path):
  name = path.stem
  if name.startswith("="):
    if not re.fullmatch(r"(?:[0-9a-fA-F]{2}){1,32}", name[1:]):
      raise ValueError("invalid encoded SSID")
    return bytes.fromhex(name[1:])
  ssid = name.encode("utf-8")
  if not 1 <= len(ssid) <= 32:
    raise ValueError("invalid SSID length")
  return ssid


def convert_profile(path, ssid):
  source = read_keyfile(path)
  # Enterprise certificates, static addressing, MAC policies, and transition
  # restrictions need a full translation. Do not silently replace them with
  # DHCP or weaker Wi-Fi security. SAE-PT-* entries are regenerable key caches.
  for group in source.get_groups()[0]:
    keys = source.get_keys(group)[0]
    if group == "Settings":
      supported = all(key in ("AutoConnect", "Hidden") for key in keys)
    elif group == "Security" and path.suffix == ".psk":
      supported = all(key in ("Passphrase", "PreSharedKey") or
                      re.fullmatch(r"SAE-PT-[0-9]+", key) for key in keys)
    else:
      supported = False
    if not supported:
      raise UnsupportedProfile()

  connection = NM.SimpleConnection.new()
  identity = NM.SettingConnection.new()
  identity.props.id = ssid.decode("utf-8", errors="replace").replace("\0", "�")
  identity.props.uuid = str(uuid.uuid5(uuid.NAMESPACE_URL,
    "https://omarchy.org/iwd/" + path.suffix + "/" + ssid.hex()))
  identity.props.type = "802-11-wireless"
  identity.props.autoconnect = boolean(source, "AutoConnect", True)
  connection.add_setting(identity)

  wireless = NM.SettingWireless.new()
  wireless.props.ssid = GLib.Bytes.new(ssid)
  wireless.props.mode = "infrastructure"
  wireless.props.hidden = boolean(source, "Hidden", False)
  connection.add_setting(wireless)

  if path.suffix == ".psk":
    passphrase = string(source, "Security", "Passphrase")
    psk = string(source, "Security", "PreSharedKey")
    if passphrase:
      if not 8 <= len(passphrase.encode("utf-8")) <= 63:
        raise ValueError("invalid passphrase")
      secret = passphrase
    elif re.fullmatch(r"[0-9a-fA-F]{64}", psk):
      secret = psk
    else:
      raise ValueError("missing or invalid PSK")
    security = NM.SettingWirelessSecurity.new()
    security.props.key_mgmt = "wpa-psk"
    security.props.psk = secret
    connection.add_setting(security)

  ipv4 = NM.SettingIP4Config.new()
  ipv4.props.method = "auto"
  connection.add_setting(ipv4)
  ipv6 = NM.SettingIP6Config.new()
  ipv6.props.method = "auto"
  connection.add_setting(ipv6)
  connection.normalize()
  connection.verify()
  connection.verify_secrets()
  return connection


def existing_ssids(directories):
  ssids = set()
  for directory in directories:
    if not directory.exists():
      continue
    for path in directory.iterdir():
      # These are ignored by NetworkManager's keyfile plugin too.
      if path.name.startswith(".") or path.name.endswith(("~", ".pem", ".der")):
        continue
      connection = NM.keyfile_read(read_keyfile(path), str(directory),
                                   NM.KeyfileHandlerFlags.NONE, None, None)
      wireless = connection.get_setting_wireless()
      if wireless is not None and wireless.props.ssid is not None:
        ssids.add(bytes(wireless.props.ssid.get_data()))
  return ssids


def write_profile(connection, directory):
  keyfile = NM.keyfile_write(connection, NM.KeyfileHandlerFlags.NONE, None, None)
  data = keyfile.to_data()[0].encode("utf-8")
  destination = directory / ("omarchy-iwd-" + connection.get_uuid() + ".nmconnection")
  fd, temporary = tempfile.mkstemp(prefix=".omarchy-iwd-", dir=directory)
  try:
    with os.fdopen(fd, "wb") as output:
      output.write(data)
      output.flush()
      os.fsync(output.fileno())
    # Publish a complete 0600 profile, without overwriting even a dangling
    # symlink. Concurrent imports converge on the same deterministic filename.
    os.link(temporary, destination)
  finally:
    os.unlink(temporary)


def import_networks(iwd_directory, connection_directories, destination):
  if not iwd_directory.exists():
    return 0
  security_order = {".8021x": 0, ".psk": 1, ".open": 2}
  paths = sorted((path for path in iwd_directory.iterdir() if path.suffix in security_order),
                 key=lambda path: (security_order[path.suffix], path.name))
  if not paths:
    return 0

  # Complete this read before publishing anything. Failure to inspect an
  # existing profile must not be mistaken for an empty connection store.
  known = existing_ssids(connection_directories)
  destination.mkdir(mode=0o700, parents=True, exist_ok=True)
  info = destination.lstat()
  if not stat.S_ISDIR(info.st_mode) or info.st_uid != os.geteuid() or info.st_mode & 0o022:
    raise ValueError("unsafe connection directory")

  imported = skipped = unsupported = failed = 0
  considered = set()
  for path in paths:
    try:
      ssid = profile_ssid(path)
      if ssid in known or ssid in considered:
        skipped += 1
        continue
      # An old open profile must not become the fallback for an enterprise or
      # personal profile we cannot translate, even if that import fails.
      considered.add(ssid)
      if path.suffix == ".8021x":
        raise UnsupportedProfile()
      connection = convert_profile(path, ssid)
      try:
        write_profile(connection, destination)
      except FileExistsError:
        # A completed concurrent import is fine; any other collision needs
        # inspection. Never claim success for a partial or unrelated file.
        if ssid not in existing_ssids(connection_directories):
          raise ValueError("profile filename collision")
        skipped += 1
      else:
        imported += 1
      known.add(ssid)
    except UnsupportedProfile:
      unsupported += 1
      print(f"Manual setup required for Wi-Fi profile {path.name!r}.")
    except (OSError, ValueError, GLib.Error):
      # Parser errors can contain the offending line, including a password.
      # Report filenames only; never print exceptions or profile contents.
      failed += 1
      print(f"Could not import Wi-Fi profile {path.name!r}; original retained.")

  print(f"Saved Wi-Fi networks: {imported} imported, {skipped} skipped, "
        f"{unsupported} require manual setup, {failed} failed.")
  if unsupported:
    print("Enterprise and custom network settings need manual setup in the network panel.")
  if unsupported or failed:
    print("Original profiles are unchanged in /var/lib/iwd.")
  if failed:
    raise ValueError("some profiles could not be imported")
  return imported


def main():
  if os.geteuid() != 0:
    print("Importing saved Wi-Fi networks requires root.", file=sys.stderr)
    return 1
  try:
    import_networks(Path("/var/lib/iwd"), [
      Path("/etc/NetworkManager/system-connections"),
      Path("/run/NetworkManager/system-connections"),
      Path("/usr/lib/NetworkManager/system-connections"),
    ], Path("/etc/NetworkManager/system-connections"))
  except (OSError, ValueError, GLib.Error):
    print("Could not import all saved Wi-Fi networks. Original profiles remain in "
          "/var/lib/iwd; fix the profile or storage problem and retry "
          "'omarchy network import iwd'.", file=sys.stderr)
    return 1

  # During the upgrade iwd still owns the live connection. Do not start or
  # restart NetworkManager; it reads these files at boot. For later recovery,
  # reload profiles without activating one or disconnecting the current link.
  if subprocess.run(["systemctl", "is-active", "--quiet", "NetworkManager.service"]).returncode == 0:
    if subprocess.run(["nmcli", "connection", "reload"],
                      stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode != 0:
      print("Saved Wi-Fi profiles were written, but NetworkManager could not reload them. "
            "Retry 'omarchy network import iwd'.", file=sys.stderr)
      return 1
  return 0


if __name__ == "__main__":
  sys.exit(main())
