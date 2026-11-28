import ctypes
import errno
import hashlib
import os
from pathlib import Path
import shutil
import stat
import subprocess
import sys
import tempfile


SERVICE = Path("/usr/lib/systemd/system/linux-modules-cleanup.service")
if not SERVICE.is_file():
  SERVICE = Path(__file__).with_suffix(".service")
SERVICE_SHA256 = "5d947290ef8c94b33c79c531e5615f4c9bea38e7649092d34af3bf0af5b1ca24"
PROFILE = Path(sys.argv[1]).resolve()


def require(condition, message):
  if not condition:
    raise RuntimeError(message)


def skip(message):
  if os.environ.get("OMARCHY_REQUIRE_CLEANUP_NAMESPACE_TEST") == "1":
    raise RuntimeError(message)
  print("ok - SKIP cleanup namespace test: " + message, flush=True)
  sys.exit(0)


def run(*args, **kwargs):
  return subprocess.run(args, check=True, text=True, **kwargs)


def snapshot(root):
  result = {}
  for path in [root, *sorted(root.rglob("*"))]:
    info = path.lstat()
    data = None
    if stat.S_ISREG(info.st_mode):
      data = path.read_bytes()
    elif stat.S_ISLNK(info.st_mode):
      data = os.readlink(path)
    attrs = {key: os.getxattr(path, key, follow_symlinks=False)
             for key in os.listxattr(path, follow_symlinks=False)}
    result[str(path.relative_to(root))] = (
      info.st_mode, info.st_uid, info.st_gid, info.st_mtime_ns, data, attrs)
  return result


def restricted(fixture):
  values = dict(line.split(":", 1) for line in Path("/proc/self/status").read_text().splitlines()
                if ":" in line)
  excluded = (1 << 21) | (1 << 16)
  for field in ("CapBnd", "CapEff", "CapPrm", "CapInh"):
    require(int(values[field], 16) & excluded == 0, field + " retains mount/module capability")
  retained = sum(1 << bit for bit in (0, 1, 3, 4, 31))
  require(int(values["CapEff"], 16) & retained == retained,
          "ownership, DAC, mode or file-capability preservation privileges were removed")
  print("ok - namespace process drops SYS_ADMIN/SYS_MODULE while retaining filesystem metadata capabilities", flush=True)

  protected = fixture / "protected" / "must-not-write"
  try:
    protected.write_text("unexpected write")
  except OSError as error:
    require(error.errno == errno.EROFS, "write failed for a reason other than the read-only boundary")
  else:
    raise RuntimeError("write outside the modules allowance succeeded")

  libc = ctypes.CDLL(None, use_errno=True)
  libc.mount.argtypes = [ctypes.c_char_p, ctypes.c_char_p, ctypes.c_char_p, ctypes.c_ulong, ctypes.c_char_p]
  libc.syscall.restype = ctypes.c_long
  result = libc.mount(None, b"/usr/lib/modules", None, 4096 | 32 | 1, None)
  require(result == -1 and ctypes.get_errno() == errno.EPERM, "mount/remount was not denied")
  print("ok - a representative protected-path write and module-tree remount are denied in the isolated namespace", flush=True)

  module_syscall = {"x86_64": 175, "aarch64": 105}.get(os.uname().machine)
  if module_syscall is not None:
    result = libc.syscall(module_syscall, ctypes.c_void_p(), ctypes.c_ulong(0), b"")
    require(result == -1 and ctypes.get_errno() == errno.EPERM, "invalid-image module syscall was not denied")
    print("ok - module syscall denied (user namespaces independently prohibit host module loading)", flush=True)

  modules = Path("/usr/lib/modules")
  current = modules / os.uname().release
  packaged = modules / "999.0-packaged"
  stale = modules / "999.1-stale"
  before_current = snapshot(current)
  before_packaged = snapshot(packaged)
  before_stale = snapshot(stale)
  before_acl = run("getfacl", "-cpn", str(stale / "kernel" / "a.ko"), capture_output=True).stdout
  run("pacman", "-Qo", str(packaged), capture_output=True)
  run("/bin/bash", "-ex", str(fixture / "cleanup.sh"), capture_output=True)
  archive = modules / ".old" / stale.name
  require(not stale.exists(), "stale source tree was not removed")
  require(snapshot(current) == before_current, "running kernel changed")
  require(snapshot(packaged) == before_packaged, "package-owned kernel changed")
  after_stale = snapshot(archive)
  differences = {key: (before_stale.get(key), after_stale.get(key))
                 for key in before_stale.keys() | after_stale.keys()
                 if before_stale.get(key) != after_stale.get(key)}
  require(not differences, "archive changed metadata: " + repr(differences))
  require((archive / "kernel" / "a.ko").stat().st_ino == (archive / "kernel" / "b.ko").stat().st_ino,
          "archive did not preserve hardlinks")
  after_acl = run("getfacl", "-cpn", str(archive / "kernel" / "a.ko"), capture_output=True).stdout
  require(after_acl == before_acl, "archive lost its POSIX ACL")
  print("ok - actual Arch cleanup skips running/package-owned trees and archives stale trees with ACLs, xattrs, hardlinks and ownership", flush=True)

  run("/bin/bash", "-ex", str(fixture / "cleanup.sh"), capture_output=True)
  require(snapshot(archive) == before_stale, "second cleanup changed the archive")
  failed = modules / "999.2-transfer-failure"
  failed.mkdir()
  (failed / "keep.ko").write_text("must survive failed rsync")
  environment = dict(os.environ, PATH=str(fixture / "failbin") + ":" + os.environ["PATH"])
  result = subprocess.run(["/bin/bash", "-ex", str(fixture / "cleanup.sh")], env=environment,
                          text=True, capture_output=True)
  require(result.returncode == 23 and (failed / "keep.ko").exists(),
          "failed archive transfer did not preserve the source")
  print("ok - cleanup is idempotent and failed rsync cannot remove its source", flush=True)
  print("ok - namespace/capability approximation only; the complete systemd profile still needs a disposable Arch VM", flush=True)


def sandbox(fixture, parent_user, parent_mount):
  require(str(os.stat("/proc/self/ns/user").st_ino) != parent_user, "refusing mounts outside a new user namespace")
  require(str(os.stat("/proc/self/ns/mnt").st_ino) != parent_mount, "refusing mounts outside a new mount namespace")
  require(os.geteuid() == 0, "namespace UID mapping failed")
  run("mount", "--bind", str(fixture / "modules"), "/usr/lib/modules")
  run("mount", "--bind", str(fixture / "db"), "/var/lib/pacman")
  protected = str(fixture / "protected")
  run("mount", "--bind", protected, protected)
  run("mount", "-o", "remount,bind,ro", protected)
  run("setpriv", "--no-new-privs", "mount", "-o", "remount,bind,rw", protected)
  require(not os.statvfs(protected).f_flag & os.ST_RDONLY, "unrestricted remount control did not succeed")
  print("ok - control: no-new-privileges alone still permits a remount before dropping SYS_ADMIN", flush=True)
  run("mount", "-o", "remount,bind,ro", protected)
  run("mount", "-o", "remount,bind,ro", "/var/lib/pacman")
  require(not os.statvfs("/usr/lib/modules").f_flag & os.ST_RDONLY, "module archive is not writable")
  capability_lines = [line.split("=", 1)[1] for line in PROFILE.read_text().splitlines()
                      if line.startswith("CapabilityBoundingSet=")]
  require(len(capability_lines) <= 1, "namespace test requires one capability assignment")
  capability_args = []
  if capability_lines:
    require(capability_lines[0].startswith("~"), "namespace test supports capability exclusions only")
    excluded = ",".join("-" + name.removeprefix("CAP_").lower()
                        for name in capability_lines[0][1:].split())
    capability_args = ["--bounding-set=" + excluded, "--inh-caps=" + excluded]
  run("setpriv", *capability_args, "--ambient-caps=-all", "--no-new-privs",
      sys.executable, str(Path(__file__).resolve()), str(PROFILE), "--restricted", str(fixture),
      parent_user, parent_mount)


def main():
  if len(sys.argv) > 2:
    require(len(sys.argv) == 6, "internal test stages require parent namespace identities")
    require(str(os.stat("/proc/self/ns/user").st_ino) != sys.argv[4], "refusing test outside a new user namespace")
    require(str(os.stat("/proc/self/ns/mnt").st_ino) != sys.argv[5], "refusing test outside a new mount namespace")
    fixture = Path(sys.argv[3])
    if sys.argv[2] == "--sandbox":
      sandbox(fixture, sys.argv[4], sys.argv[5])
    elif sys.argv[2] == "--restricted":
      restricted(fixture)
    else:
      raise RuntimeError("unknown test stage")
    return

  if sys.platform != "linux":
    skip("requires Linux, Arch kernel-modules-hook/pacman, rsync, ACL tools and unprivileged user namespaces; no runtime profile validation")
  needed = ("pacman", "rsync", "setfacl", "getfacl", "mount", "setpriv", "unshare", "systemd-analyze")
  missing = [command for command in needed if shutil.which(command) is None]
  if missing or not SERVICE.is_file():
    skip("install Arch kernel-modules-hook, python, acl and util-linux in a disposable environment; missing " + ", ".join(missing or [str(SERVICE)]))
  source = SERVICE.read_bytes()
  require(hashlib.sha256(source).hexdigest() == SERVICE_SHA256,
          "Arch cleanup service changed: review its ExecStart before updating the approved source hash")
  start = next(line for line in source.decode().splitlines() if line.startswith("ExecStart="))
  prefix = "ExecStart=/bin/bash -exc '"
  require(start.startswith(prefix) and start.endswith("'"), "unexpected cleanup command encoding")
  script = start[len(prefix):-1].replace("\\'", "'").replace("$$", "$").replace("%v", os.uname().release)

  with tempfile.TemporaryDirectory(prefix="omarchy-cleanup-test-") as directory:
    fixture = Path(directory)
    units = fixture / "units"
    unit_dropin = units / (SERVICE.name + ".d")
    unit_dropin.mkdir(parents=True)
    (units / SERVICE.name).write_bytes(source)
    shutil.copyfile(PROFILE, unit_dropin / "10-omarchy.conf")
    environment = dict(os.environ, SYSTEMD_UNIT_PATH=str(units) + ":")
    result = run("systemd-analyze", "verify", str(units / SERVICE.name), env=environment, capture_output=True)
    require("Unknown" not in result.stderr, "systemd ignored a profile directive: " + result.stderr)
    print("ok - Arch kernel-modules-hook 0.1.7-3 unit plus drop-in passes offline verify (parsing only; source " + str(SERVICE) + ")", flush=True)
    probe = subprocess.run(["unshare", "--user", "--map-root-user", "--mount", "--propagation", "private", "true"],
                           text=True, capture_output=True, timeout=10)
    if probe.returncode:
      skip("unprivileged user/mount namespaces unavailable: " + probe.stderr.strip())
    if not Path("/usr/lib/modules").is_dir() or not Path("/var/lib/pacman").is_dir():
      skip("namespace bind targets /usr/lib/modules and /var/lib/pacman must already exist")

    modules = fixture / "modules"
    for name in (os.uname().release, "999.0-packaged", "999.1-stale/kernel"):
      path = modules / name
      path.mkdir(parents=True)
      (path / "a.ko").write_text("preserve " + name)
    stale = modules / "999.1-stale"
    data = stale / "kernel" / "a.ko"
    data.chmod(0o640)
    os.link(data, data.with_name("b.ko"))
    os.symlink("/usr/src/omarchy-test-absent", stale / "build")
    os.setxattr(data, "user.omarchy-cleanup", b"preserve module metadata")
    run("setfacl", "-m", "u:" + str(os.getuid()) + ":r--", str(data))
    for path in [stale, *stale.rglob("*")]:
      os.utime(path, ns=(1600000000123456789, 1600000000123456789), follow_symlinks=False)
    db = fixture / "db" / "local"
    package = db / "omarchy-cleanup-fixture-1-1"
    package.mkdir(parents=True)
    (db / "ALPM_DB_VERSION").write_text("9\n")
    (package / "desc").write_text("%NAME%\nomarchy-cleanup-fixture\n\n%VERSION%\n1-1\n\n")
    (package / "files").write_text("%FILES%\nusr/lib/modules/999.0-packaged/\nusr/lib/modules/999.0-packaged/a.ko\n\n")
    (fixture / "cleanup.sh").write_text(script + "\n")
    (fixture / "protected").mkdir()
    failbin = fixture / "failbin"
    failbin.mkdir()
    fail_rsync = failbin / "rsync"
    fail_rsync.write_text("#!/bin/bash\nexit 23\n")
    fail_rsync.chmod(0o755)
    run("unshare", "--user", "--map-root-user", "--mount", "--propagation", "private",
        sys.executable, str(Path(__file__).resolve()), str(PROFILE), "--sandbox", str(fixture),
        str(os.stat("/proc/self/ns/user").st_ino), str(os.stat("/proc/self/ns/mnt").st_ino), timeout=60)


try:
  main()
except (OSError, RuntimeError, subprocess.SubprocessError) as error:
  print("not ok - cleanup behavior: " + str(error), file=sys.stderr)
  if isinstance(error, subprocess.CalledProcessError):
    print(error.stdout or "", error.stderr or "", file=sys.stderr)
  sys.exit(1)
