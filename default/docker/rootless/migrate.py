"""Move compatible rootful containers into the desktop user's rootless Docker store."""

import hashlib
import io
import json
import os
import re
import secrets
import socket
import stat
import struct
import subprocess
import sys
import tarfile
from copy import deepcopy
from datetime import datetime, timezone
from decimal import Decimal
from pathlib import Path, PurePosixPath


LABEL = "io.omarchy.rootless-docker.source-id"
OWNERSHIP_LABEL = "io.omarchy.rootless-docker.ownership"
VOLUME_LABEL = "io.omarchy.rootless-docker.source-volume"
VOLUME_EVENT_LABEL = "io.omarchy.rootless-docker.event-marker"
NOFILE_PROBE_LABEL = "io.omarchy.rootless-docker.nofile-probe"
NOFILE_PROBE_PREFIX = "omarchy-rootless-docker-nofile-"
NOFILE_PROBE_SECONDS = 30
SOURCE = "source"
TARGET = "target"
TRUSTED_MANIFEST = "/usr/share/omarchy/default/docker/rootless/volume-manifest.py"
SECCOMP_OPTIONS = {"name=seccomp,profile=builtin", "name=seccomp,profile=default"}
MASKED_PATHS = {
    "/proc/acpi", "/proc/asound", "/proc/interrupts", "/proc/kcore", "/proc/keys",
    "/proc/latency_stats", "/proc/sched_debug", "/proc/scsi", "/proc/timer_list",
    "/proc/timer_stats", "/sys/devices/virtual/powercap", "/sys/firmware",
}
READONLY_PATHS = {"/proc/bus", "/proc/fs", "/proc/irq", "/proc/sys", "/proc/sysrq-trigger"}
DOCKER_CAPABILITIES = {
    "AUDIT_WRITE", "CHOWN", "DAC_OVERRIDE", "FOWNER", "FSETID", "KILL", "MKNOD",
    "NET_BIND_SERVICE", "NET_RAW", "SETFCAP", "SETGID", "SETPCAP", "SETUID", "SYS_CHROOT",
}
RESOURCE_FLAGS = {
    "Memory": "--memory", "MemoryReservation": "--memory-reservation",
    "MemorySwap": "--memory-swap", "CpuShares": "--cpu-shares",
    "CpuQuota": "--cpu-quota", "CpuPeriod": "--cpu-period",
    "CpusetCpus": "--cpuset-cpus", "CpusetMems": "--cpuset-mems",
}
DEFAULT_ZERO_HOST_CONFIG = {
    "BlkioWeight", "CpuCount", "CpuPercent", "CpuRealtimePeriod", "CpuRealtimeRuntime",
    "IOMaximumBandwidth", "IOMaximumIOps", "OomScoreAdj",
}
TARGET_DAEMON_CONFIG = {
    "log-driver": "json-file",
    "log-opts": {"max-size": "10m", "max-file": "5"},
}
TARGET_ROOTLESSKIT_ARGUMENTS = [
    "--net=slirp4netns",
    "--mtu=65520",
    "--slirp4netns-sandbox=auto",
    "--slirp4netns-seccomp=auto",
    "--disable-host-loopback",
    "--port-driver=builtin",
    "--copy-up=/etc",
    "--copy-up=/run",
    "--propagation=rslave",
    "--detach-netns",
    "/usr/bin/dockerd-rootless.sh",
]
TARGET_DAEMON_IDENTITY = None


def daemon_security(engine):
    return json.loads(run(engine, "info", "--format", "{{json .SecurityOptions}}", capture=True))


def unix_peer_credentials(path):
    connection = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    try:
        connection.connect(path)
        payload = connection.getsockopt(socket.SOL_SOCKET, socket.SO_PEERCRED,
                                        struct.calcsize("3i"))
    except OSError as error:
        raise ValueError("the rootless Docker API socket cannot be identified") from error
    finally:
        connection.close()
    return struct.unpack("3i", payload)


def process_start_token(proc, pid):
    try:
        fields = (proc / str(pid) / "stat").read_text().rsplit(")", 1)[1].split()
        token = fields[19]
    except (FileNotFoundError, PermissionError, IndexError) as error:
        raise ValueError("the rootless Docker daemon process identity cannot be verified") from error
    if not token.isdigit():
        raise ValueError("the rootless Docker daemon process identity cannot be verified")
    return token


def target_config(proc, dockerd_pid, config_home, dockerd_start):
    path = proc / str(dockerd_pid) / "root" / config_home.lstrip("/") / "docker/daemon.json"
    descriptor = None
    try:
        descriptor = os.open(path, os.O_RDONLY | os.O_CLOEXEC | os.O_NOFOLLOW | os.O_NONBLOCK)
        before = os.fstat(descriptor)
        if (not stat.S_ISREG(before.st_mode) or before.st_uid != os.getuid() or
                before.st_mode & 0o022 or before.st_nlink != 1):
            raise ValueError("the rootless Docker daemon configuration is not a trusted regular file")
        with os.fdopen(os.dup(descriptor), "rb") as source:
            payload = source.read(1024 * 1024 + 1)
        after = os.fstat(descriptor)
        identity = lambda value: (
            value.st_dev, value.st_ino, value.st_mode, value.st_uid, value.st_gid,
            value.st_nlink, value.st_size, value.st_mtime_ns, value.st_ctime_ns,
        )
        if len(payload) > 1024 * 1024 or identity(before) != identity(after):
            raise ValueError("the rootless Docker daemon configuration changed while it was read")
        if before.st_ctime > dockerd_start:
            raise ValueError("the rootless Docker configuration changed after the daemon started; restart it")
        return json.loads(payload)
    except (OSError, UnicodeDecodeError, json.JSONDecodeError) as error:
        raise ValueError("the rootless Docker daemon configuration cannot be verified") from error
    finally:
        if descriptor is not None:
            os.close(descriptor)


def verified_target_daemon(identity, proc=Path("/proc")):
    if (not isinstance(identity, dict) or set(identity) != {"pid", "start", "runtime"} or
            type(identity["pid"]) is not int or identity["pid"] <= 1 or
            not isinstance(identity["start"], str) or not identity["start"].isdigit() or
            not isinstance(identity["runtime"], str) or not identity["runtime"].startswith("/")):
        raise RuntimeError("the verified rootless Docker daemon identity is unavailable")
    pid = identity["pid"]
    try:
        executable = os.readlink(proc / str(pid) / "exe")
        current_start = process_start_token(proc, pid)
    except (FileNotFoundError, PermissionError, ValueError) as error:
        raise RuntimeError("the verified rootless Docker daemon is no longer running") from error
    if executable != "/usr/bin/dockerd" or current_start != identity["start"]:
        raise RuntimeError("the verified rootless Docker daemon changed during migration")
    endpoint = proc / str(pid) / "root" / identity["runtime"].lstrip("/") / "docker.sock"
    try:
        peer_pid, peer_uid, _peer_gid = unix_peer_credentials(str(endpoint))
    except ValueError as error:
        raise RuntimeError("the verified rootless Docker API socket is unavailable") from error
    if peer_pid != pid or peer_uid != os.getuid():
        raise RuntimeError("the verified rootless Docker API socket changed during migration")
    return pid, str(endpoint)


def target_daemon_policy(proc=Path("/proc")):
    try:
        main_pid = int(run("/usr/bin/systemctl", "--user", "show", "docker.service",
                           "--property=MainPID", "--value", capture=True))
    except (OSError, ValueError) as error:
        raise ValueError("the rootless Docker daemon configuration cannot be verified") from error
    if main_pid <= 1:
        raise ValueError("the rootless Docker daemon has no valid service process")
    try:
        rootlesskit_arguments = [value.decode() for value in (proc / str(main_pid) / "cmdline").read_bytes().split(b"\0") if value]
        rootlesskit_environment = [value.decode() for value in (proc / str(main_pid) / "environ").read_bytes().split(b"\0") if value]
        rootlesskit_executable = os.readlink(proc / str(main_pid) / "exe")
    except (FileNotFoundError, PermissionError, UnicodeDecodeError) as error:
        raise ValueError("the rootless Docker service process cannot be inspected") from error

    descendants = {main_pid}
    changed = True
    while changed:
        changed = False
        for entry in proc.iterdir():
            if not entry.name.isdigit() or int(entry.name) in descendants:
                continue
            try:
                parent = next(line.split()[1] for line in (entry / "status").read_text().splitlines()
                              if line.startswith("PPid:"))
            except (FileNotFoundError, PermissionError, StopIteration):
                continue
            if int(parent) in descendants:
                descendants.add(int(entry.name))
                changed = True
    candidates = []
    slirp_candidates = []
    for pid in descendants - {main_pid}:
        try:
            arguments = [value.decode() for value in (proc / str(pid) / "cmdline").read_bytes().split(b"\0") if value]
        except (FileNotFoundError, PermissionError, UnicodeDecodeError):
            continue
        if arguments and Path(arguments[0]).name == "dockerd":
            try:
                executable = os.readlink(proc / str(pid) / "exe")
            except (FileNotFoundError, PermissionError):
                continue
            candidates.append((pid, arguments, executable))
        if arguments and Path(arguments[0]).name == "slirp4netns":
            try:
                executable = os.readlink(proc / str(pid) / "exe")
            except (FileNotFoundError, PermissionError):
                continue
            slirp_candidates.append(executable)
    if len(candidates) != 1 or rootlesskit_executable != "/usr/bin/rootlesskit":
        raise ValueError("the rootless Docker daemon process cannot be identified uniquely")
    dockerd_pid, arguments, executable = candidates[0]
    if executable != "/usr/bin/dockerd":
        raise ValueError("the rootless Docker daemon does not use the packaged executable")
    if slirp_candidates != ["/usr/bin/slirp4netns"]:
        raise ValueError("the rootless Docker network helper cannot be identified uniquely")
    service_paths = [value.removeprefix("PATH=") for value in rootlesskit_environment
                     if value.startswith("PATH=")]
    config_homes = [value.removeprefix("XDG_CONFIG_HOME=") for value in rootlesskit_environment
                    if value.startswith("XDG_CONFIG_HOME=")]
    expected_config_home = str(Path.home() / ".config")
    if service_paths != ["/usr/bin"]:
        raise ValueError("the rootless Docker daemon does not use the packaged service PATH")
    if config_homes != [expected_config_home]:
        raise ValueError("the rootless Docker daemon does not use the packaged config directory")
    try:
        dockerd_start = (proc / str(dockerd_pid)).stat().st_ctime
        dockerd_start_token = process_start_token(proc, dockerd_pid)
    except (OSError, ValueError) as error:
        raise ValueError("the rootless Docker daemon configuration cannot be verified") from error
    runtime = os.environ.get("XDG_RUNTIME_DIR") or f"/run/user/{os.getuid()}"
    configuration = target_config(proc, dockerd_pid, config_homes[0], dockerd_start)
    identity = {"pid": dockerd_pid, "start": dockerd_start_token, "runtime": runtime}
    try:
        verified_target_daemon(identity, proc)
    except RuntimeError as error:
        raise ValueError("the rootless Docker API socket belongs to a different daemon") from error
    return configuration, arguments, rootlesskit_arguments, service_paths[0], config_homes[0], identity


def validate_source_daemon(options):
    # Daemon defaults (including no-new-privileges and seccomp profiles) need
    # not appear in individual HostConfig records. Userns remapping also changes
    # the meaning of numeric volume ownership. Do not guess these policies.
    defaults = {*SECCOMP_OPTIONS, "name=cgroupns"}
    configured = set(options) if isinstance(options, list) else set()
    if (not configured or configured - defaults or "name=cgroupns" not in configured or
            len(configured & SECCOMP_OPTIONS) != 1):
        raise ValueError("rootful Docker daemon confinement or user mapping needs an explicit migration")


def validate_target_daemon(options, configuration=None, arguments=None, rootlesskit_arguments=None,
                           service_path=None, config_home=None):
    allowed = {
        "name=rootless", "name=cgroupns", "name=seccomp,profile=builtin",
        "name=seccomp,profile=default",
    }
    configured = set(options) if isinstance(options, list) else set()
    if "name=rootless" not in configured:
        raise ValueError("the destination Docker daemon is not running rootlessly")
    if (configured - allowed or "name=cgroupns" not in configured or
            len(configured & SECCOMP_OPTIONS) != 1):
        raise ValueError("rootless Docker daemon confinement needs an explicit migration")
    if configuration is not None and configuration != TARGET_DAEMON_CONFIG:
        raise ValueError("rootless Docker has custom daemon defaults; restore Omarchy's daemon.json or migrate containers explicitly")
    if arguments is not None and arguments not in (["dockerd"], ["/usr/bin/dockerd"]):
        raise ValueError("rootless Docker uses custom daemon options; migrate containers explicitly")
    runtime = os.environ.get("XDG_RUNTIME_DIR") or f"/run/user/{os.getuid()}"
    expected_rootlesskit = [f"--state-dir={runtime}/dockerd-rootless", *TARGET_ROOTLESSKIT_ARGUMENTS]
    if (rootlesskit_arguments is not None and
            (not rootlesskit_arguments or Path(rootlesskit_arguments[0]).name != "rootlesskit" or
             rootlesskit_arguments[1:] != expected_rootlesskit)):
        raise ValueError("rootless Docker uses custom RootlessKit isolation; migrate containers explicitly")
    if service_path is not None and service_path != "/usr/bin":
        raise ValueError("rootless Docker uses an unsafe service PATH; restart it from the packaged unit")
    if config_home is not None and config_home != str(Path.home() / ".config"):
        raise ValueError("rootless Docker uses a custom config directory; restart it from the packaged unit")


def trusted_probe_file(path):
    path = Path(path)
    if not path.is_absolute():
        raise ValueError("the source file-limit probe has an invalid executable path")
    try:
        canonical = path.resolve(strict=True)
        metadata = canonical.stat()
    except OSError as error:
        raise ValueError("the source file-limit probe executable is unavailable") from error
    if not stat.S_ISREG(metadata.st_mode) or metadata.st_uid != 0 or metadata.st_mode & 0o022:
        raise ValueError("the source file-limit probe executable is not trusted")
    parent = canonical.parent
    while True:
        metadata = parent.stat()
        if not stat.S_ISDIR(metadata.st_mode) or metadata.st_uid != 0 or metadata.st_mode & 0o022:
            raise ValueError("the source file-limit probe executable has an unsafe parent")
        if parent == Path("/"):
            break
        parent = parent.parent
    return canonical


def nofile_probe_rootfs(token):
    if not re.fullmatch(r"[a-f0-9]{64}", token):
        raise ValueError("the source file-limit probe has an invalid identity")
    ldd = trusted_probe_file("/usr/bin/ldd")
    sleep = trusted_probe_file("/usr/bin/sleep")
    result = subprocess.run(
        [ldd, sleep], check=True, text=True, capture_output=True,
        env={"PATH": "/usr/bin", "LC_ALL": "C"},
    )
    files = {"/usr/bin/sleep": sleep}
    for line in result.stdout.splitlines():
        definition = line.split("(", 1)[0].strip()
        left, separator, right = definition.partition("=>")
        for candidate in ((left.strip(), right.strip()) if separator else (left.strip(),)):
            if candidate.startswith("/"):
                files[candidate] = trusted_probe_file(candidate)
    if len(files) < 3:
        raise ValueError("the source file-limit probe dependencies cannot be identified")

    archive = io.BytesIO()
    with tarfile.open(fileobj=archive, mode="w") as output:
        for destination, source in sorted(files.items()):
            payload = source.read_bytes()
            entry = tarfile.TarInfo(destination.lstrip("/"))
            entry.size = len(payload)
            entry.mode = 0o755
            output.addfile(entry, io.BytesIO(payload))
        marker = token.encode()
        entry = tarfile.TarInfo(f"omarchy-rootless-docker-probe/{token}")
        entry.size = len(marker)
        entry.mode = 0o400
        output.addfile(entry, io.BytesIO(marker))
    return archive.getvalue()


def parse_nofile_limits(output):
    line = next((line for line in output.splitlines() if line.startswith("Max open files ")), None)
    if line is None:
        raise ValueError("the source container file limit cannot be read")
    fields = line.split()
    if len(fields) != 6 or fields[:3] != ["Max", "open", "files"] or fields[5] != "files":
        raise ValueError("the source container file limit has an unexpected format")
    try:
        soft = -1 if fields[3] == "unlimited" else int(fields[3])
        hard = -1 if fields[4] == "unlimited" else int(fields[4])
    except ValueError as error:
        raise ValueError("the source container file limit is invalid") from error
    limits = {"soft": soft, "hard": hard}
    validate_nofile(limits)
    return limits


def nofile_probe_path():
    state = Path(os.environ.get("XDG_STATE_HOME") or Path.home() / ".local/state")
    return state / "omarchy/rootless-docker-migration/.nofile-probe.in-progress"


def nofile_probe_record():
    path = nofile_probe_path()
    try:
        metadata = path.lstat()
    except FileNotFoundError:
        return None
    if path.is_symlink() or not stat.S_ISREG(metadata.st_mode):
        raise RuntimeError("the source file-limit probe journal changed unexpectedly")
    try:
        record = json.loads(path.read_text())
    except (OSError, json.JSONDecodeError) as error:
        raise RuntimeError("the source file-limit probe journal cannot be read safely") from error
    token = record.get("token") if isinstance(record, dict) else None
    engine = record.get("engine") if isinstance(record, dict) else None
    expected_name = f"{NOFILE_PROBE_PREFIX}{engine}-{token}"
    expected_tag = f"omarchy-rootless-docker-nofile-{engine}:{token}"
    image = record.get("image") if isinstance(record, dict) else None
    limits = record.get("limits") if isinstance(record, dict) else None
    try:
        if limits is not None:
            validate_nofile(limits)
    except ValueError as error:
        raise RuntimeError("the source file-limit probe journal changed unexpectedly") from error
    if (not isinstance(record, dict) or metadata.st_uid != os.getuid() or
            metadata.st_mode & 0o077 or
            set(record) != {"engine", "token", "name", "tag", "image", "limits"} or
            engine not in (SOURCE, TARGET) or
            not re.fullmatch(r"[a-f0-9]{64}", token or "") or
            record.get("name") != expected_name or record.get("tag") != expected_tag or
            (image is not None and not re.fullmatch(r"sha256:[a-f0-9]{64}", image))):
        raise RuntimeError("the source file-limit probe journal changed unexpectedly")
    return record


def docker_inspect_optional(engine, kind, identity):
    result = subprocess.run(
        local_command([engine, kind, "inspect", identity]), text=True, capture_output=True,
    )
    if result.returncode != 0:
        run(engine, "info", capture=True)
        return None
    try:
        inspected = json.loads(result.stdout)
    except json.JSONDecodeError as error:
        raise RuntimeError(f"the source file-limit probe {kind} cannot be inspected") from error
    if not isinstance(inspected, list) or len(inspected) != 1 or not isinstance(inspected[0], dict):
        raise RuntimeError(f"the source file-limit probe {kind} has an invalid identity")
    return inspected[0]


def nofile_probe_container_owned(container, record):
    config = container.get("Config") or {}
    host = container.get("HostConfig") or {}
    restart = host.get("RestartPolicy") or {}
    expected_ulimits = None
    if record["limits"] is not None:
        expected_ulimits = [{
            "Name": "nofile", "Soft": record["limits"]["soft"],
            "Hard": record["limits"]["hard"],
        }]
    return (
        record["image"] is not None and
        re.fullmatch(r"[a-f0-9]{64}", container.get("Id") or "") is not None and
        container.get("Name") == f'/{record["name"]}' and
        container.get("Image") == record["image"] and
        container.get("Path") == "/usr/bin/sleep" and
        container.get("Args") == [str(NOFILE_PROBE_SECONDS)] and
        config.get("Image") == record["image"] and
        config.get("Entrypoint") == ["/usr/bin/sleep"] and
        config.get("Cmd") == [str(NOFILE_PROBE_SECONDS)] and
        config.get("Labels") == {NOFILE_PROBE_LABEL: record["token"]} and
        host.get("AutoRemove") is True and host.get("NetworkMode") == "none" and
        host.get("ReadonlyRootfs") is True and host.get("Privileged") is False and
        host.get("CapDrop") == ["ALL"] and
        host.get("SecurityOpt") == ["no-new-privileges"] and
        (host.get("Ulimits") == expected_ulimits or
         (expected_ulimits is None and host.get("Ulimits") in (None, []))) and
        restart.get("Name") == "no" and restart.get("MaximumRetryCount") == 0 and
        not (host.get("Binds") or host.get("Mounts")) and not container.get("Mounts")
    )


def nofile_probe_image_owned(image, record):
    identity = image.get("Id")
    repository = record["tag"].rsplit(":", 1)[0]
    return (
        re.fullmatch(r"sha256:[a-f0-9]{64}", identity or "") is not None and
        (record["image"] is None or identity == record["image"]) and
        image.get("RepoTags") == [record["tag"]] and
        image.get("RepoDigests") in (None, [], [f"{repository}@{identity}"])
    )


def clear_nofile_probe_record():
    path = nofile_probe_path()
    try:
        path.unlink()
    except FileNotFoundError:
        return
    directory = os.open(path.parent, os.O_RDONLY | os.O_DIRECTORY)
    try:
        os.fsync(directory)
    finally:
        os.close(directory)


def cleanup_nofile_probe():
    record = nofile_probe_record()
    if record is None:
        return
    failures = []
    engine = record["engine"]
    try:
        container = docker_inspect_optional(engine, "container", record["name"])
        if container is not None:
            if not nofile_probe_container_owned(container, record):
                raise RuntimeError("the source file-limit probe container changed unexpectedly")
            run(engine, "container", "rm", "-f", container["Id"], capture=True)
            if docker_inspect_optional(engine, "container", container["Id"]) is not None:
                raise RuntimeError("the source file-limit probe container was replaced during cleanup")
    except Exception as error:
        failures.append(error)
    try:
        image = docker_inspect_optional(engine, "image", record["tag"])
        if image is not None:
            if not nofile_probe_image_owned(image, record):
                raise RuntimeError("the source file-limit probe image changed unexpectedly")
            run(engine, "image", "rm", record["tag"], capture=True)
            if (docker_inspect_optional(engine, "image", image["Id"]) is not None or
                    docker_inspect_optional(engine, "image", record["tag"]) is not None):
                raise RuntimeError("the source file-limit probe image was replaced during cleanup")
    except Exception as error:
        failures.append(error)
    if failures:
        raise RuntimeError(
            "the source file-limit probe could not be cleaned safely; inspect rootful Docker"
        ) from failures[0]
    clear_nofile_probe_record()


def probe_nofile(engine, expected=None):
    if engine not in (SOURCE, TARGET):
        raise ValueError("the file-limit probe has an invalid Docker engine")
    if expected is not None:
        validate_nofile(expected)
    cleanup_nofile_probe()
    token = secrets.token_hex(32)
    record = {
        "engine": engine,
        "token": token,
        "name": f"{NOFILE_PROBE_PREFIX}{engine}-{token}",
        "tag": f"omarchy-rootless-docker-nofile-{engine}:{token}",
        "image": None,
        "limits": deepcopy(expected),
    }
    write_private_json(nofile_probe_path(), record)
    try:
        imported = subprocess.run(
            local_command([engine, "image", "import", "-", record["tag"]]),
            input=nofile_probe_rootfs(token),
            check=True, capture_output=True,
        ).stdout.decode().strip()
        if not re.fullmatch(r"sha256:[a-f0-9]{64}", imported):
            raise RuntimeError("the source file-limit probe image has an invalid identity")
        record["image"] = imported
        write_private_json(nofile_probe_path(), record)
        arguments = [
            engine, "run", "-d", "--rm", "--name", record["name"],
            "--label", f"{NOFILE_PROBE_LABEL}={token}", "--network=none", "--read-only",
            "--cap-drop=ALL", "--security-opt=no-new-privileges", "--entrypoint=/usr/bin/sleep",
        ]
        if expected is not None:
            arguments += ["--ulimit", f'nofile={expected["soft"]}:{expected["hard"]}']
        arguments += [imported, str(NOFILE_PROBE_SECONDS)]
        container_id = run(*arguments, capture=True)
        if not re.fullmatch(r"[a-f0-9]{64}", container_id):
            raise RuntimeError("the source file-limit probe container has an invalid identity")
        container = inspect(engine, "container", container_id)
        if not nofile_probe_container_owned(container, record):
            raise RuntimeError("the source file-limit probe container changed unexpectedly")
        state = container["State"]
        pid = state.get("Pid")
        if not state.get("Running") or type(pid) is not int or pid <= 1:
            raise RuntimeError("the source file-limit probe did not start safely")
        if engine == SOURCE:
            limits_path = source_namespace_path(f"/proc/{pid}/limits")
        else:
            limits_path = f"/proc/{pid}/limits"
        output = run("/usr/bin/sudo", "/usr/bin/cat", limits_path, capture=True)
        actual = parse_nofile_limits(output)
        if expected is not None and actual != expected:
            raise RuntimeError("rootless Docker cannot reproduce the source container file limit")
        return actual
    finally:
        cleanup_nofile_probe()


def source_default_nofile():
    return probe_nofile(SOURCE)


def validate_target_nofile(limits):
    probe_nofile(TARGET, limits)


def container_nofile(container, default, intent=None):
    if intent is not None:
        expected = intent["source_nofile"]
    else:
        expected = default
    if not container["State"]["Running"]:
        return deepcopy(expected)
    pid = container["State"].get("Pid")
    if type(pid) is not int or pid <= 1:
        raise ValueError(f'{container["Name"].lstrip("/")}: source process cannot be identified')
    limits = parse_nofile_limits(run(
        "/usr/bin/sudo", "/usr/bin/cat",
        source_namespace_path(f"/proc/{pid}/limits"), capture=True,
    ))
    latest = inspect(SOURCE, "container", container["Id"])
    if (not latest["State"]["Running"] or latest["State"].get("Pid") != pid or
            latest["State"].get("StartedAt") != container["State"].get("StartedAt") or
            snapshot_digest(latest) != snapshot_digest(container)):
        raise RuntimeError(f'{container["Name"].lstrip("/")}: source changed while its file limit was read')
    if intent is not None and limits != expected:
        raise ValueError(f'{container["Name"].lstrip("/")}: source file limit changed during migration')
    return limits


def validate_nofile(limits):
    if (not isinstance(limits, dict) or set(limits) != {"soft", "hard"} or
            any(type(limits[key]) is not int for key in ("soft", "hard"))):
        raise ValueError("the source container file limit is invalid")
    soft, hard = limits["soft"], limits["hard"]
    if soft == 0 or hard == 0 or soft < -1 or hard < -1 or (hard != -1 and (soft == -1 or soft > hard)):
        raise ValueError("the source container file limit is invalid")


def validate_target_policy():
    global TARGET_DAEMON_IDENTITY
    policy = target_daemon_policy()
    identity = policy[-1]
    TARGET_DAEMON_IDENTITY = identity
    try:
        validate_target_daemon(daemon_security(TARGET), *policy[:-1])
    except BaseException:
        TARGET_DAEMON_IDENTITY = None
        raise


def validate_volumes(container):
    name = container["Name"].lstrip("/")
    host = container["HostConfig"]
    mounts = container.get("Mounts", [])
    for mount in mounts:
        if mount.get("Type") != "volume" or mount.get("Driver") != "local":
            raise ValueError(f"{name}: host mounts or custom storage need an explicit transfer")
        if not re.fullmatch(r"[a-zA-Z0-9][a-zA-Z0-9_.-]*", mount["Name"]):
            raise ValueError(f"{name}: unsupported volume name")
        if not mount["Destination"].startswith("/") or ":" in mount["Destination"]:
            raise ValueError(f"{name}: unsupported volume destination")
    # -v also records named volumes in Binds. Accept only an exact match to a
    # local volume; never treat a host directory or socket as a named volume.
    for binding in host.get("Binds") or []:
        fields = binding.split(":")
        if (len(fields) not in (2, 3) or (len(fields) == 3 and fields[2] not in ("rw", "ro")) or
                not any(fields[:2] == [mount["Name"], mount["Destination"]] and
                        (len(fields) == 2 or (fields[2] == "rw") == mount.get("RW"))
                        for mount in mounts)):
            raise ValueError(f"{name}: custom Binds need an explicit volume transfer")
    for requested in host.get("Mounts") or []:
        allowed = {"Type", "Source", "Target", "ReadOnly", "Consistency", "VolumeOptions"}
        options = requested.get("VolumeOptions") or {}
        if (set(requested) - allowed or requested.get("Type") != "volume" or
                requested.get("Consistency") not in (None, "") or
                set(options) - {"NoCopy"} or
                options.get("NoCopy") not in (None, False, True)):
            raise ValueError(f"{name}: custom mount options need an explicit volume transfer")
        matching = [mount for mount in mounts
                    if mount["Destination"] == requested.get("Target") and
                    (not requested.get("Source") or mount["Name"] == requested["Source"])]
        if (len(matching) != 1 or matching[0].get("Type") != "volume" or
                bool(matching[0].get("RW")) == bool(requested.get("ReadOnly"))):
            raise ValueError(f"{name}: Docker mount configuration does not match its private volume")


def validate_security(container):
    name = container["Name"].lstrip("/")
    host = container["HostConfig"]
    if host.get("Privileged"):
        raise ValueError(f"{name}: privileged containers require a manual migration")
    if host.get("CapAdd"):
        raise ValueError(f"{name}: added Linux capabilities require a manual migration")
    if host.get("Devices") or host.get("DeviceRequests") or host.get("DeviceCgroupRules"):
        raise ValueError(f"{name}: host device access requires a manual migration")
    if container.get("AppArmorProfile") or container.get("ProcessLabel"):
        raise ValueError(f"{name}: mandatory access-control profiles need an explicit migration")
    if host.get("Runtime") not in (None, "", "runc"):
        raise ValueError(f"{name}: custom Runtime needs an explicit migration")
    if host.get("CgroupnsMode") not in (None, "", "private"):
        raise ValueError(f"{name}: host cgroup access needs an explicit migration")
    for key, expected in (("MaskedPaths", MASKED_PATHS), ("ReadonlyPaths", READONLY_PATHS)):
        if key in host and set(host[key] or []) != expected:
            raise ValueError(f"{name}: custom {key} must not be silently changed")
    if any(option not in ("no-new-privileges", "no-new-privileges=true", "no-new-privileges:true")
           for option in host.get("SecurityOpt") or []):
        raise ValueError(f"{name}: custom SecurityOpt needs an explicit migration")
    handled = {
        "NetworkMode", "IpcMode", "ShmSize", "PortBindings", "RestartPolicy", "Binds",
        "PidsLimit", "Runtime", "CgroupnsMode", "MaskedPaths", "ReadonlyPaths",
        "SecurityOpt", "CapDrop", "LogConfig", "NanoCpus", "Mounts", *RESOURCE_FLAGS,
    }
    for key, value in host.items():
        # bool is an int subclass, so membership in a tuple containing False
        # also accepts integer zero. Allow only the stock zero-valued fields
        # Docker currently emits; an unknown zero can be meaningful (for
        # example MemorySwappiness=0) and must fail closed.
        if (key in handled or value is None or value is False or
                value == "" or value == [] or value == {} or
                (key in DEFAULT_ZERO_HOST_CONFIG and type(value) is int and value == 0)):
            continue
        if key == "ConsoleSize" and value == [0, 0]:
            continue
        # Unknown nondefault settings fail closed, including future Docker
        # device, namespace, runtime, mount and resource options.
        raise ValueError(f"{name}: custom {key} needs an explicit rootless Docker configuration")
    log = host.get("LogConfig") or {}
    if (log.get("Type") not in (None, "", "json-file") or
            (log.get("Config") or {}) not in ({}, {"max-size": "10m", "max-file": "5"})):
        raise ValueError(f"{name}: custom logging needs an explicit migration")


def runtime_arguments(container, source_nofile):
    host = container["HostConfig"]
    arguments = ["--shm-size", str(host["ShmSize"]), "--init=false", "--ulimit",
                 f'nofile={source_nofile["soft"]}:{source_nofile["hard"]}']
    if host.get("PidsLimit") not in (None, 0, -1):
        arguments.append(f'--pids-limit={host["PidsLimit"]}')
    for key, flag in RESOURCE_FLAGS.items():
        if host.get(key):
            arguments += [flag, str(host[key])]
    if host.get("NanoCpus"):
        arguments += ["--cpus", format(Decimal(host["NanoCpus"]) / 1_000_000_000, "f")]
    arguments += ["--cap-drop", "ALL"]
    for capability in sorted(allowed_capabilities(container)):
        arguments += ["--cap-add", capability]
    if host.get("SecurityOpt"):
        arguments += ["--security-opt", "no-new-privileges"]
    return arguments


def allowed_capabilities(container):
    # Explicit --cap-add gives even non-root processes capabilities. Docker's
    # default non-root process has none, so keep that source boundary.
    user = (container["Config"].get("User") or "").split(":", 1)[0]
    if user and not re.fullmatch(r"[0-9]+", user):
        raise ValueError(f'{container["Name"].lstrip("/")}: named image users need an explicit migration')
    if user and int(user) != 0:
        dropped = {capability.upper().removeprefix("CAP_")
                   for capability in container["HostConfig"].get("CapDrop") or []}
        if "ALL" not in dropped:
            raise ValueError(f'{container["Name"].lstrip("/")}: non-root image users need cap-drop ALL for an exact migration')
        return set()
    # Docker API clients can retain mixed-case names in inspected CapDrop.
    dropped = {capability.upper().removeprefix("CAP_") for capability in container["HostConfig"].get("CapDrop") or []}
    return set() if "ALL" in dropped else DOCKER_CAPABILITIES - dropped


def verify_environment(container, values):
    # The committed image contains the source environment exactly. A temporary
    # empty DOCKER_CONFIG prevents the destination CLI from injecting proxy
    # variables from the user's client configuration.
    def mapping(entries):
        if not isinstance(entries, list) or any(not isinstance(entry, str) or "=" not in entry for entry in entries):
            raise RuntimeError("Cannot verify container environment")
        result = dict(entry.split("=", 1) for entry in entries)
        if len(result) != len(entries):
            raise RuntimeError("Cannot verify duplicate container environment variables")
        return result
    source = mapping(container["Config"].get("Env") or [])
    target = mapping(values)
    if target != source:
        # Environment names and values may contain secrets. Never print them.
        raise RuntimeError("rootless Docker did not preserve the source environment; application was not started")


def verify_runtime(container, ownership=None, source_nofile=None):
    name = container["Name"].lstrip("/")
    target = inspect(TARGET, "container", name)
    verify_environment(container, target["Config"].get("Env"))
    source_host, target_host = container["HostConfig"], target["HostConfig"]
    if target_host.get("Privileged") is not False:
        raise RuntimeError(f"{name}: refusing privileged destination")
    if target_host.get("Devices") or target_host.get("DeviceRequests") or target_host.get("DeviceCgroupRules"):
        raise RuntimeError(f"{name}: refusing destination device access")
    private_modes = {
        "NetworkMode": "bridge", "IpcMode": "private", "PidMode": "",
        "UTSMode": "", "CgroupnsMode": "private",
    }
    if any(target_host.get(key, "") != value for key, value in private_modes.items()):
        raise RuntimeError(f"{name}: rootless Docker changed a private namespace boundary")
    if target_host.get("Runtime") != "runc":
        raise RuntimeError(f"{name}: rootless Docker changed the OCI runtime")
    if target_host.get("Init") is not False:
        raise RuntimeError(f"{name}: rootless Docker changed the init process policy")
    if source_nofile is not None:
        expected_ulimits = [{"Name": "nofile", "Soft": source_nofile["soft"], "Hard": source_nofile["hard"]}]
        actual_ulimits = target_host.get("Ulimits") or []
        if actual_ulimits != expected_ulimits:
            raise RuntimeError(f"{name}: rootless Docker did not preserve the source file limit")
    expected_mounts = sorted((mount["Destination"], destination_volume(container, mount), bool(mount.get("RW")))
                             for mount in container.get("Mounts", []))
    actual_mounts = target.get("Mounts") or []
    if (any(mount.get("Type") != "volume" for mount in actual_mounts) or
            sorted((mount["Destination"], mount["Name"], bool(mount.get("RW"))) for mount in actual_mounts) != expected_mounts):
        raise RuntimeError(f"{name}: destination mounts differ from the validated private volumes")
    expected = {"ShmSize": source_host["ShmSize"]}
    expected.update({key: source_host[key] for key in RESOURCE_FLAGS if source_host.get(key)})
    for key, value in expected.items():
        if target_host.get(key) != value:
            raise RuntimeError(f"{name}: rootless Docker did not preserve {key}; application was not started")
    source_pids = source_host.get("PidsLimit")
    target_pids = target_host.get("PidsLimit")
    if (-1 if source_pids in (None, 0, -1) else source_pids) != (-1 if target_pids in (None, 0, -1) else target_pids):
        raise RuntimeError(f"{name}: rootless Docker did not preserve PidsLimit; application was not started")
    if target_host.get("NanoCpus") != source_host.get("NanoCpus"):
        raise RuntimeError(f"{name}: rootless Docker did not preserve the CPU limit; application was not started")
    if source_host.get("SecurityOpt") and not any(
            option in ("no-new-privileges", "no-new-privileges=true")
            for option in target_host.get("SecurityOpt") or []):
        raise RuntimeError(f"{name}: rootless Docker did not preserve no-new-privileges")
    expected_add = sorted(allowed_capabilities(container))
    actual_add = sorted(capability.upper().removeprefix("CAP_")
                        for capability in target_host.get("CapAdd") or [])
    actual_drop = {capability.upper().removeprefix("CAP_")
                   for capability in target_host.get("CapDrop") or []}
    if actual_add != expected_add or "ALL" not in actual_drop:
        raise RuntimeError(f"{name}: rootless Docker changed the capability ceiling")
    expected_labels = dict(container["Config"].get("Labels") or {})
    expected_labels[LABEL] = container["Id"]
    if ownership is not None:
        expected_labels[OWNERSHIP_LABEL] = ownership
    if target["Config"].get("Labels") != expected_labels:
        raise RuntimeError(f"{name}: rootless Docker changed the container labels")
    source_config = dict(container["Config"])
    target_config = dict(target["Config"])
    for config in (source_config, target_config):
        config.pop("Image", None)
        config.pop("Labels", None)
        # A committed Docker image causes a later `docker create` to report
        # stdout/stderr attachment even when its detached source did not. These
        # flags describe the original create client's stream attachment; they
        # do not change the stored logs or a later `docker attach` operation.
        config.pop("AttachStdout", None)
        config.pop("AttachStderr", None)
    if target_config != source_config:
        changed = sorted(key for key in source_config.keys() | target_config.keys()
                         if source_config.get(key) != target_config.get(key))
        raise RuntimeError(f'{name}: rootless Docker changed application fields: {", ".join(changed)}')
    if target_host.get("PortBindings") != source_host.get("PortBindings"):
        raise RuntimeError(f"{name}: rootless Docker changed the published ports")
    if target_host.get("RestartPolicy") != source_host.get("RestartPolicy"):
        raise RuntimeError(f"{name}: rootless Docker changed the restart policy")
    if target_host.get("LogConfig") != source_host.get("LogConfig"):
        raise RuntimeError(f"{name}: rootless Docker changed the logging policy")
    return target


def local_command(args):
    if args[0] == SOURCE:
        host = os.environ.get("OMARCHY_ROOTFUL_DOCKER_HOST", "")
        if not re.fullmatch(r"unix:///proc/[1-9][0-9]*/root/run/docker\.sock", host):
            raise RuntimeError("the verified rootful Docker endpoint is unavailable")
        return ["/usr/bin/sudo", "/usr/bin/docker", "--host", host, *args[1:]]
    if args[0] == TARGET:
        _pid, endpoint = verified_target_daemon(TARGET_DAEMON_IDENTITY)
        return ["/usr/bin/docker", "--host", f"unix://{endpoint}", *args[1:]]
    if args[0] == "target-namespace":
        pid, _endpoint = verified_target_daemon(TARGET_DAEMON_IDENTITY)
        return ["/usr/bin/nsenter", "-U", "--preserve-credentials", "-m", "-t", str(pid), *args[1:]]
    return args


def source_dockerd_pid():
    host = os.environ.get("OMARCHY_ROOTFUL_DOCKER_HOST", "")
    match = re.fullmatch(r"unix:///proc/([1-9][0-9]*)/root/run/docker\.sock", host)
    if match is None:
        raise RuntimeError("the verified rootful Docker endpoint is unavailable")
    return int(match.group(1))


def source_namespace_path(path):
    if not isinstance(path, str) or not path.startswith("/"):
        raise ValueError("rootful Docker returned an invalid host path")
    normalized = PurePosixPath(path)
    if ".." in normalized.parts or str(normalized) != path:
        raise ValueError("rootful Docker returned an invalid host path")
    return f"/proc/{source_dockerd_pid()}/root{path}"


def run(*args, capture=False):
    environment = os.environ.copy()
    if args[0] == TARGET:
        runtime = environment.get("XDG_RUNTIME_DIR") or f"/run/user/{os.getuid()}"
        config = Path(runtime) / "omarchy-rootless-docker-migration-client"
        config.mkdir(mode=0o700, exist_ok=True)
        environment["DOCKER_CONFIG"] = str(config)
        environment.pop("DOCKER_CONTEXT", None)
    result = subprocess.run(local_command(args), check=True, text=True, capture_output=capture, env=environment)
    return result.stdout.strip() if capture else None


def inspect(engine, kind, name):
    return json.loads(run(engine, kind, "inspect", name, capture=True))[0]


def exists(kind, name):
    result = subprocess.run(local_command([TARGET, kind, "inspect", name]),
                            text=True, capture_output=True)
    if result.returncode == 0:
        return True
    subprocess.run(local_command([TARGET, "info"]), check=True,
                   text=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return False


def destination_volume(container, mount):
    explicit = any(binding.split(":")[0] == mount["Name"]
                   for binding in container["HostConfig"].get("Binds") or [])
    explicit = explicit or any(requested.get("Source") == mount["Name"]
                               for requested in container["HostConfig"].get("Mounts") or [])
    return mount["Name"] if explicit else f'omarchy-migrated-{mount["Name"]}'


def volume_identity(container, mount):
    # Docker volume create is idempotent rather than exclusive. An unpredictable
    # token lets us prove that the volume returned by that call is the one this
    # migration just requested, even if another client races the predictable
    # destination name between the existence check and creation.
    return f'{container["Id"]}:{mount["Name"]}:{secrets.token_hex(32)}'


def completion_path(identity):
    if not re.fullmatch(r"[a-f0-9]{64}", identity):
        raise ValueError("Unsupported Docker container identity")
    return Path(os.environ.get("XDG_STATE_HOME") or Path.home() / ".local/state") / "omarchy/rootless-docker-migration" / identity


def intent_path(identity):
    receipt = completion_path(identity)
    return receipt.with_name(f"{receipt.name}.in-progress")


def ensure_state_directory(path):
    missing = []
    current = path
    while not current.exists():
        missing.append(current)
        current = current.parent
    path.mkdir(parents=True, exist_ok=True, mode=0o700)
    # fsync every directory that received a new child entry. This includes the
    # first pre-existing ancestor, making a newly created state hierarchy
    # durable before its journal can authorize source mutation.
    for created in missing:
        directory = os.open(created.parent, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
        try:
            os.fsync(directory)
        finally:
            os.close(directory)


def write_private_json(path, payload):
    ensure_state_directory(path.parent)
    temporary = path.with_suffix(f"{path.suffix}.tmp-{os.getpid()}")
    try:
        descriptor = os.open(temporary, os.O_CREAT | os.O_EXCL | os.O_WRONLY | os.O_NOFOLLOW, 0o600)
        with os.fdopen(descriptor, "w") as output:
            json.dump(payload, output)
            output.write("\n")
            output.flush()
            os.fsync(output.fileno())
        temporary.replace(path)
        directory = os.open(path.parent, os.O_RDONLY | os.O_DIRECTORY)
        try:
            os.fsync(directory)
        finally:
            os.close(directory)
    finally:
        temporary.unlink(missing_ok=True)


def record_migration_intent(container, stopped_state=None, saved=None, restart_disabled=False,
                            source_nofile=None):
    state = container["State"]
    if saved is None:
        validate_nofile(source_nofile)
        payload = {
            "source": container["Id"],
            "source_snapshot": snapshot_digest(container),
            "source_snapshot_ignore_restart": snapshot_digest(container, ignore_restart=True),
            "source_restart_policy": deepcopy(container["HostConfig"].get("RestartPolicy") or {}),
            "started_at": state["StartedAt"],
            "target_running": bool(state["Running"]),
            "restart_disabled": False,
            "quiesce_started": False,
            "restore_started": False,
            "start_attempted": False,
            "target_ownership": secrets.token_hex(32),
            "source_volumes": None,
            "source_nofile": deepcopy(source_nofile),
            "image": None,
            "volume_event": None,
            "volumes": {},
        }
        if not state["Running"]:
            payload["stopped"] = stopped_identity(state)
    else:
        payload = deepcopy(saved)
    if stopped_state is not None:
        payload["stopped"] = stopped_identity(stopped_state)
        payload["quiesce_started"] = False
        payload["restore_started"] = False
    if restart_disabled:
        payload["restart_disabled"] = True
    write_private_json(intent_path(container["Id"]), payload)
    return payload


def migration_intent(container):
    path = intent_path(container["Id"])
    if not path.exists():
        return None
    try:
        saved = json.loads(path.read_text())
        restart_policy = saved["source_restart_policy"]
        source_volumes = saved.get("source_volumes")
        source_nofile = saved["source_nofile"]
        image_record = saved.get("image")
        volume_event = saved.get("volume_event")
        validate_nofile(source_nofile)
        if (saved["source"] != container["Id"] or
                not isinstance(saved["target_running"], bool) or
                not isinstance(saved["restart_disabled"], bool) or
                not isinstance(saved["quiesce_started"], bool) or
                not isinstance(saved["restore_started"], bool) or
                not isinstance(saved["start_attempted"], bool) or
                not re.fullmatch(r"[a-f0-9]{64}", saved["target_ownership"]) or
                (image_record is not None and
                 (not isinstance(image_record, dict) or
                  set(image_record) != {"tag", "source", "target", "target_preexisting"} or
                  image_record.get("tag") != f'omarchy-rootless-docker-transfer:{saved["target_ownership"]}' or
                  (image_record.get("target_preexisting") is not None and
                   type(image_record.get("target_preexisting")) is not bool) or
                  ((image_record.get("target") is None) !=
                   (image_record.get("target_preexisting") is None)) or
                  any(value is not None and not re.fullmatch(r"sha256:[a-f0-9]{64}", value)
                      for value in (image_record.get("source"), image_record.get("target"))))) or
                (source_volumes is not None and
                 (not isinstance(source_volumes, dict) or
                 any(not re.fullmatch(r"[a-zA-Z0-9][a-zA-Z0-9_.-]*", name) or
                      not re.fullmatch(r"[a-f0-9]{64}", digest)
                      for name, digest in source_volumes.items()))) or
                (volume_event is not None and
                 (not isinstance(volume_event, dict) or
                  set(volume_event) != {"name", "since"} or
                  volume_event.get("name") != f'omarchy-volume-event-marker-{saved["target_ownership"]}' or
                  not isinstance(volume_event.get("since"), str) or not volume_event["since"])) or
                not isinstance(saved["volumes"], dict) or
                not isinstance(restart_policy, dict) or
                not isinstance(saved["started_at"], str)):
            raise ValueError
        saved.setdefault("source_volumes", None)
        saved.setdefault("image", None)
        saved.setdefault("volume_event", None)
        exact_snapshot = saved["source_snapshot"] == snapshot_digest(container)
        disabled_snapshot = (
            saved["restart_disabled"] is True and
            (container["HostConfig"].get("RestartPolicy") or {}).get("Name") == "no" and
            saved["source_snapshot_ignore_restart"] == snapshot_digest(container, ignore_restart=True)
        )
        if not exact_snapshot and not disabled_snapshot:
            raise ValueError
        if container["State"]["Running"]:
            quiescing = (saved["quiesce_started"] is True and
                         saved.get("destination") is None and
                         saved["start_attempted"] is False)
            resumed_restore = (saved["restore_started"] is True and
                               saved["target_running"] is True and exact_snapshot)
            if (saved["target_running"] is not True and not quiescing) or (
                    "stopped" in saved and not resumed_restore and not quiescing) or (
                    saved["started_at"] != container["State"]["StartedAt"] and
                    not resumed_restore and not quiescing):
                raise ValueError
        else:
            if saved["started_at"] != container["State"]["StartedAt"]:
                raise ValueError
            current_stopped = stopped_identity(container["State"])
            if "stopped" in saved and saved["stopped"] != current_stopped:
                raise ValueError
        return saved
    except (OSError, json.JSONDecodeError, KeyError, TypeError, ValueError) as error:
        raise ValueError(f'{container["Name"].lstrip("/")}: interrupted migration state changed; inspect both engines') from error


def planned_source(container, intent):
    if intent is None:
        return container
    planned = deepcopy(container)
    planned["HostConfig"]["RestartPolicy"] = deepcopy(intent["source_restart_policy"])
    if snapshot_digest(planned) != intent["source_snapshot"]:
        raise ValueError(f'{container["Name"].lstrip("/")}: interrupted migration cannot reconstruct the source configuration')
    return planned


def clear_migration_intent(identity):
    path = intent_path(identity)
    try:
        path.unlink()
    except FileNotFoundError:
        return
    directory = os.open(path.parent, os.O_RDONLY | os.O_DIRECTORY)
    try:
        os.fsync(directory)
    finally:
        os.close(directory)


def persist_migration_intent(container, intent):
    write_private_json(intent_path(container["Id"]), intent)
    return intent


def transfer_image_record(intent):
    record = intent.get("image")
    expected_tag = f'omarchy-rootless-docker-transfer:{intent["target_ownership"]}'
    if (not isinstance(record, dict) or
            set(record) != {"tag", "source", "target", "target_preexisting"} or
            record.get("tag") != expected_tag or
            (record.get("target_preexisting") is not None and
             type(record.get("target_preexisting")) is not bool) or
            ((record.get("target") is None) !=
             (record.get("target_preexisting") is None)) or
            any(value is not None and not re.fullmatch(r"sha256:[a-f0-9]{64}", value)
                for value in (record.get("source"), record.get("target")))):
        raise ValueError("interrupted transfer image ownership is invalid")
    return record


def transfer_image_owned(image, record, engine):
    identity = image.get("Id")
    repository = record["tag"].rsplit(":", 1)[0]
    expected_identity = record[engine]
    return (
        re.fullmatch(r"sha256:[a-f0-9]{64}", identity or "") is not None and
        (expected_identity is None or identity == expected_identity) and
        image.get("RepoTags") == [record["tag"]] and
        image.get("RepoDigests") in (None, [], [f"{repository}@{identity}"])
    )


def update_transfer_image(container, intent, engine, identity):
    if engine not in (SOURCE, TARGET):
        raise ValueError("invalid transfer image engine")
    if identity is not None and not re.fullmatch(r"sha256:[a-f0-9]{64}", identity):
        raise ValueError("invalid transfer image identity")
    saved = deepcopy(intent)
    record = transfer_image_record(saved)
    record[engine] = identity
    return persist_migration_intent(container, saved)


def update_target_transfer_image(container, intent, identity, preexisting):
    if not isinstance(preexisting, bool) or not re.fullmatch(r"sha256:[a-f0-9]{64}", identity):
        raise ValueError("invalid destination transfer image identity")
    saved = deepcopy(intent)
    record = transfer_image_record(saved)
    record["target"] = identity
    record["target_preexisting"] = preexisting
    return persist_migration_intent(container, saved)


def remove_transfer_image(engine, record, untag_only=False):
    image = docker_inspect_optional(engine, "image", record["tag"])
    if image is None:
        expected_identity = record[engine]
        if expected_identity is not None:
            retained = docker_inspect_optional(engine, "image", expected_identity)
            if retained is not None and not untag_only:
                raise RuntimeError("a migration transfer image lost its ownership tag")
        return
    if not transfer_image_owned(image, record, engine):
        raise RuntimeError("a migration transfer image changed; retained it for inspection")
    if untag_only:
        run(engine, "image", "rm", record["tag"], capture=True)
        if docker_inspect_optional(engine, "image", record["tag"]) is not None:
            raise RuntimeError("a migration transfer image tag was replaced during cleanup")
    else:
        # Docker rejects removing a tagged image by digest without --force.
        # Ownership proves this is its only tag, so removing the tag deletes
        # the unused transfer image without broadening the removal operation.
        run(engine, "image", "rm", record["tag"], capture=True)
        if (docker_inspect_optional(engine, "image", image["Id"]) is not None or
                docker_inspect_optional(engine, "image", record["tag"]) is not None):
            raise RuntimeError("a migration transfer image was replaced during cleanup")


def cleanup_transfer_images(container, intent):
    if intent.get("image") is None:
        return intent
    record = transfer_image_record(intent)
    failures = []
    engines = [SOURCE] if record["target_preexisting"] is True else [TARGET, SOURCE]
    for engine in engines:
        try:
            remove_transfer_image(engine, record)
        except Exception as error:
            failures.append(error)
    if failures:
        raise RuntimeError("migration transfer images could not be cleaned safely") from failures[0]
    saved = deepcopy(intent)
    saved["image"] = None
    return persist_migration_intent(container, saved)


def release_transfer_image(container, intent):
    if intent.get("image") is None:
        return intent
    record = transfer_image_record(intent)
    failures = []
    try:
        remove_transfer_image(SOURCE, record)
    except Exception as error:
        failures.append(error)
    if record["target_preexisting"] is not True:
        try:
            image = docker_inspect_optional(TARGET, "image", record["tag"])
            destination = intent.get("destination") or {}
            target = inspect(TARGET, "container", destination.get("id", ""))
            if (image is None or not transfer_image_owned(image, record, TARGET) or
                    target.get("Id") != destination.get("id") or
                    target.get("Image") != record["target"] or
                    (target.get("Config") or {}).get("Image") != record["tag"] or
                    not target_owned(container, target, intent)):
                raise RuntimeError("the migrated container no longer owns its transferred image")
        except Exception as error:
            failures.append(error)
    if failures:
        raise RuntimeError("migration transfer image tags could not be released safely") from failures[0]
    saved = deepcopy(intent)
    saved["image"] = None
    return persist_migration_intent(container, saved)


def record_destination_may_have_run(container, intent):
    saved = deepcopy(intent)
    saved["start_attempted"] = True
    return persist_migration_intent(container, saved)


def target_owned(container, target, intent):
    labels = target["Config"].get("Labels") or {}
    return (labels.get(LABEL) == container["Id"] and
            labels.get(OWNERSHIP_LABEL) == intent["target_ownership"])


def volume_guard_name(intent):
    ownership = intent.get("target_ownership")
    if not re.fullmatch(r"[a-f0-9]{64}", ownership or ""):
        raise ValueError("Interrupted rootless Docker ownership is invalid")
    return f"omarchy-volume-guard-{ownership}"


def volume_guard_owned(container, guard, intent):
    name = volume_guard_name(intent)
    return (guard.get("Name") == f"/{name}" and
            target_owned(container, guard, intent) and
            target_never_started(guard))


def remove_volume_guard(container, intent):
    name = volume_guard_name(intent)
    if not exists("container", name):
        return
    guard = inspect(TARGET, "container", name)
    if (not re.fullmatch(r"[a-f0-9]{64}", guard.get("Id") or "") or
            not volume_guard_owned(container, guard, intent)):
        raise ValueError(f'{container["Name"].lstrip("/")}: rootless volume guard changed or ran; inspect both engines')
    run(TARGET, "rm", "--force", guard["Id"])
    if exists("container", name):
        raise RuntimeError(f'{container["Name"].lstrip("/")}: rootless volume guard name was replaced during cleanup')


def completed(container, target):
    if (target["Config"].get("Labels") or {}).get(LABEL) != container["Id"]:
        return False
    receipt = completion_path(container["Id"])
    if not receipt.is_file():
        return False
    try:
        saved = json.loads(receipt.read_text())
        return (saved["target"] == target.get("Id") and
                saved["source"] == stopped_identity(container["State"]) and
                isinstance(saved["target_running"], bool) and
                saved["target_running"] == bool(target["State"]["Running"]) and
                saved["source_snapshot"] == snapshot_digest(container) and
                saved["target_snapshot"] == snapshot_digest(target))
    except (ValueError, KeyError, TypeError):
        # Older identity-only receipts cannot prove the source stayed stopped.
        return False


def stopped_identity(state):
    if state["Running"] or not state.get("StartedAt") or not state.get("FinishedAt"):
        raise ValueError("Docker source was restarted or its stopped state cannot be verified")
    return {key: state[key] for key in ("StartedAt", "FinishedAt")}


def target_never_started(container):
    state = container.get("State") or {}
    never = "0001-01-01T00:00:00Z"
    return (state.get("Status") == "created" and state.get("Running") is False and
            state.get("Paused") is not True and state.get("Restarting") is not True and
            state.get("Dead") is not True and state.get("StartedAt") == never and
            state.get("FinishedAt") == never)


def record_completion(container, source_state, target_running, verified_target):
    latest_source = inspect(SOURCE, "container", container["Id"])
    if (stopped_identity(latest_source["State"]) != stopped_identity(source_state) or
            snapshot_digest(latest_source) != snapshot_digest(container)):
        raise RuntimeError(f'{container["Name"].lstrip("/")}: Docker source changed before completion; inspect both engines')
    container = latest_source
    target = inspect(TARGET, "container", container["Name"].lstrip("/"))
    verified_snapshot = snapshot_digest(verified_target)
    if (target.get("Id") != verified_target.get("Id") or
            snapshot_digest(target) != verified_snapshot):
        raise RuntimeError(f'{container["Name"].lstrip("/")}: destination changed before completion; inspect both engines')
    if target_running:
        if target["State"].get("Running") is not True:
            raise RuntimeError(f'{container["Name"].lstrip("/")}: destination stopped before completion')
    elif not target_never_started(target):
        raise RuntimeError(f'{container["Name"].lstrip("/")}: stopped destination ran before completion')
    write_private_json(completion_path(container["Id"]), {
        "target": target["Id"], "source": stopped_identity(source_state),
        "target_running": target_running,
        "source_snapshot": snapshot_digest(container),
        "target_snapshot": verified_snapshot,
    })


def validate(container):
    name = container["Name"].lstrip("/")
    if not re.fullmatch(r"[a-zA-Z0-9][a-zA-Z0-9_.-]*", name):
        raise ValueError("Unsupported container name")
    if not re.fullmatch(r"[a-f0-9]{64}", container["Id"]):
        raise ValueError("Unsupported Docker container identity")
    labels = container["Config"].get("Labels") or {}
    if labels.keys() & {LABEL, OWNERSHIP_LABEL, NOFILE_PROBE_LABEL}:
        raise ValueError(f"{name}: reserved Omarchy migration labels need an explicit migration")
    state = container["State"]
    if (state.get("Paused") or state.get("Restarting") or state.get("Dead") or
            state.get("RemovalInProgress")):
        raise ValueError(f"{name}: paused or transitional lifecycle state requires an explicit migration")
    if not state["Running"] and state.get("Status") != "created":
        intent = migration_intent(container)
        if ((intent is None or intent["target_running"] is not True) and
                not completion_path(container["Id"]).is_file()):
            raise ValueError(f"{name}: an exited container needs an explicit migration to preserve its exit state")
    allowed_capabilities(container)
    stop_timeout = container["Config"].get("StopTimeout")
    if (stop_timeout is not None and
            (isinstance(stop_timeout, bool) or not isinstance(stop_timeout, int) or stop_timeout < -1)):
        raise ValueError(f"{name}: unsupported stop timeout")
    environment = container["Config"].get("Env") or []
    if (not isinstance(environment, list) or
            any(not isinstance(entry, str) or "=" not in entry for entry in environment) or
            len({entry.split("=", 1)[0] for entry in environment}) != len(environment)):
        raise ValueError(f"{name}: ambiguous container environment needs an explicit migration")
    validate_security(container)
    if container["Config"].get("Domainname"):
        raise ValueError(f"{name}: custom domain names require an explicit rootless Docker configuration")
    health = container["Config"].get("Healthcheck") or {}
    if health.get("StartInterval"):
        raise ValueError(f"{name}: custom health start intervals require an explicit configuration")
    host = container["HostConfig"]
    if host.get("NetworkMode") not in ("default", "bridge"):
        raise ValueError(f"{name}: custom networking requires its original Compose definition")
    # Connecting another network does not update HostConfig.NetworkMode.
    # Only the stock bridge attachment can be recreated without losing intent.
    networks = container.get("NetworkSettings", {}).get("Networks") or {}
    if set(networks) != {"bridge"}:
        raise ValueError(f"{name}: custom network attachments require its original Compose definition")
    if any(networks["bridge"].get(key) for key in ("IPAMConfig", "Links", "DriverOpts", "Aliases")):
        raise ValueError(f"{name}: custom network addressing or aliases need an explicit migration")
    if not isinstance(host.get("ShmSize"), int) or host["ShmSize"] <= 0:
        raise ValueError(f"{name}: unsupported ShmSize")
    if (host.get("PidsLimit") not in (None, 0, -1) and
            (not isinstance(host["PidsLimit"], int) or host["PidsLimit"] <= 0)):
        raise ValueError(f"{name}: unsupported PidsLimit")
    if host.get("PidMode") or host.get("UTSMode") or host.get("UsernsMode"):
        raise ValueError(f"{name}: custom namespaces need an explicit rootless Docker configuration")
    if host.get("IpcMode") not in (None, "", "private"):
        raise ValueError(f"{name}: custom IPC requires its original Compose definition")
    for port, bindings in (host.get("PortBindings") or {}).items():
        if not re.fullmatch(r"\d+/(tcp|udp)", port):
            raise ValueError(f"{name}: unsupported port {port}")
        for binding in bindings or []:
            if binding.get("HostIp") != "127.0.0.1" or not binding.get("HostPort", "").isdigit():
                raise ValueError(f"{name}: only the stock localhost port bindings can migrate automatically")
            minimum = int(Path("/proc/sys/net/ipv4/ip_unprivileged_port_start").read_text())
            if not max(1, minimum) <= int(binding["HostPort"]) <= 65535:
                raise ValueError(f"{name}: published port needs explicit handling; host policy will not be weakened")
    validate_volumes(container)
    return name


def validate_windows_exception(container):
    name = container["Name"].lstrip("/")
    config = container["Config"]
    host = container["HostConfig"]
    labels = config.get("Labels") or {}
    devices = {(device.get("PathOnHost"), device.get("PathInContainer"))
               for device in host.get("Devices") or []}
    ports = host.get("PortBindings") or {}
    expected_ports = {
        "8006/tcp": [{"HostIp": "127.0.0.1", "HostPort": "8006"}],
        "3389/tcp": [{"HostIp": "127.0.0.1", "HostPort": "3389"}],
        "3389/udp": [{"HostIp": "127.0.0.1", "HostPort": "3389"}],
    }
    mounts = container.get("Mounts") or []
    mounts_by_destination = {mount.get("Destination"): mount for mount in mounts}
    storage = mounts_by_destination.get("/storage") or {}
    shared = mounts_by_destination.get("/shared") or {}
    protected = f"/var/lib/omarchy/windows/mounts/users/{os.getuid()}"
    environment = config.get("Env") or []
    valid_environment = (isinstance(environment, list) and
                         all(isinstance(entry, str) and "=" in entry for entry in environment) and
                         len({entry.split("=", 1)[0] for entry in environment}) == len(environment))
    environment_map = dict(entry.split("=", 1) for entry in environment) if valid_environment else {}
    networks = container.get("NetworkSettings", {}).get("Networks") or {}
    if (name != "omarchy-windows" or
            not re.fullmatch(r"[a-f0-9]{64}", container["Id"]) or
            config.get("Image") not in ("dockurr/windows", "dockurr/windows:latest") or
            labels.get("com.docker.compose.project") != "windows" or
            labels.get("com.docker.compose.service") != "windows" or
            host.get("Privileged") is not False or
            host.get("AutoRemove") not in (None, False) or host.get("ReadonlyRootfs") not in (None, False) or
            {capability.upper().removeprefix("CAP_") for capability in host.get("CapAdd") or []} != {"NET_ADMIN"} or
            host.get("CapDrop") or host.get("DeviceRequests") or host.get("DeviceCgroupRules") or
            host.get("SecurityOpt") or host.get("PidMode") or host.get("UTSMode") or host.get("UsernsMode") or
            host.get("NetworkMode") != "windows_default" or
            host.get("IpcMode") not in (None, "", "private") or
            host.get("CgroupnsMode") not in (None, "", "private") or
            host.get("Runtime") not in (None, "", "runc") or
            devices != {("/dev/kvm", "/dev/kvm"), ("/dev/net/tun", "/dev/net/tun")} or
            len(host.get("Devices") or []) != 2 or
            ports != expected_ports or
            (host.get("RestartPolicy") or {}).get("Name") != "no" or
            len(mounts) != 2 or any(mount.get("Type") != "bind" for mount in mounts) or
            any(mount.get("RW") is not True for mount in mounts) or
            (storage.get("Source"), shared.get("Source")) !=
            (f"{protected}/storage", f"{protected}/shared") or
            environment_map.get("PROTECT") != "Y" or
            set(networks) != {"windows_default"}):
        raise ValueError("omarchy-windows: the rootful exception does not match Omarchy's managed Windows VM")
    return name


def pipe(producer, consumer):
    with subprocess.Popen(local_command(producer), stdout=subprocess.PIPE) as source:
        try:
            destination = subprocess.run(local_command(consumer), stdin=source.stdout, check=False)
            source.stdout.close()
            source_code = source.wait()
        except BaseException:
            source.kill()
            source.wait()
            raise
        if source_code or destination.returncode:
            raise RuntimeError("Container image or volume transfer failed; Docker data was retained")


def transfer_volume(volume, target):
    destination = inspect(TARGET, "volume", target)["Mountpoint"]
    # Native tar inside RootlessKit's user/mount namespace preserves numeric
    # container ownership, root mode, PAX timestamps, ACLs and xattrs.
    pipe(["/usr/bin/sudo", "/usr/bin/python3", TRUSTED_MANIFEST, "--archive",
          source_namespace_path(volume["Mountpoint"])],
         ["target-namespace", "/usr/bin/tar", "--numeric-owner", "--same-owner", "--same-permissions",
          "--sparse", "--acls", "--xattrs", "--xattrs-include=*", "-C", destination, "-xpf", "-"])
    source_digest = source_volume_digest(volume)
    verify_volume(target, source_digest)
    return source_digest


def clear_volume(target):
    destination = inspect(TARGET, "volume", target)["Mountpoint"]
    run("target-namespace", "/usr/bin/python3", TRUSTED_MANIFEST, "--clear", destination)


def sync_volume(target):
    destination = inspect(TARGET, "volume", target)["Mountpoint"]
    run("target-namespace", "/usr/bin/python3", TRUSTED_MANIFEST, "--sync", destination)


def volume_users(target):
    output = run(TARGET, "container", "ls", "--all", "--no-trunc", "--filter",
                 f"volume={target}", "--format", "{{.ID}}", capture=True)
    users = output.splitlines() if output else []
    if any(not re.fullmatch(r"[a-f0-9]{64}", identity) for identity in users):
        raise RuntimeError("Cannot verify destination volume users")
    return users


def volume_event_marker_name(intent):
    ownership = intent.get("target_ownership")
    if not re.fullmatch(r"[a-f0-9]{64}", ownership or ""):
        raise ValueError("Interrupted rootless Docker ownership is invalid")
    return f"omarchy-volume-event-marker-{ownership}"


def volume_event_marker_owned(container, marker, intent):
    expected_labels = {
        LABEL: container["Id"],
        OWNERSHIP_LABEL: intent["target_ownership"],
        VOLUME_EVENT_LABEL: "1",
    }
    return (marker.get("Name") == volume_event_marker_name(intent) and
            marker.get("Driver") == "local" and marker.get("Options") in (None, {}) and
            marker.get("Labels") == expected_labels)


def remove_volume_event_marker(container, intent):
    name = volume_event_marker_name(intent)
    if not exists("volume", name):
        return
    marker = inspect(TARGET, "volume", name)
    if not volume_event_marker_owned(container, marker, intent) or volume_users(name):
        raise RuntimeError(f'{container["Name"].lstrip("/")}: volume event marker changed; retained it for inspection')
    run(TARGET, "volume", "rm", name)
    if exists("volume", name):
        raise RuntimeError(f'{container["Name"].lstrip("/")}: volume event marker name was replaced during cleanup')


def retire_volume_event_window(container, intent, volumes_absent=False):
    retired = deepcopy(intent)
    retired["volume_event"] = None
    if volumes_absent:
        retired["volumes"] = {}
    if retired != intent:
        retired = persist_migration_intent(container, retired)
    remove_volume_event_marker(container, retired)
    return retired


def verify_volume_event_marker(container, intent):
    name = volume_event_marker_name(intent)
    if not exists("volume", name):
        raise RuntimeError(f'{container["Name"].lstrip("/")}: destination volume event history is missing')
    marker = inspect(TARGET, "volume", name)
    if not volume_event_marker_owned(container, marker, intent) or volume_users(name):
        raise RuntimeError(f'{container["Name"].lstrip("/")}: volume event marker changed; retained destination data for inspection')


def ensure_volume_event_window(container, intent, targets):
    window = intent.get("volume_event")
    if window is None:
        if intent["volumes"]:
            raise RuntimeError(f'{container["Name"].lstrip("/")}: interrupted destination volume event history is missing')
        window = {
            "name": volume_event_marker_name(intent),
            "since": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        }
        intent["volume_event"] = window
        intent = persist_migration_intent(container, intent)
    name = window["name"]
    if exists("volume", name):
        verify_volume_event_marker(container, intent)
        return intent
    if intent["volumes"]:
        raise RuntimeError(f'{container["Name"].lstrip("/")}: destination volume event marker disappeared; retained destination data for inspection')
    for target in targets:
        if exists("volume", target):
            raise RuntimeError(f'{container["Name"].lstrip("/")}: destination volume already exists without complete event history')
    run(TARGET, "volume", "create",
        "--label", f"{LABEL}={container['Id']}",
        "--label", f"{OWNERSHIP_LABEL}={intent['target_ownership']}",
        "--label", f"{VOLUME_EVENT_LABEL}=1", name)
    verify_volume_event_marker(container, intent)
    return intent


def verify_volume_event_window(container, intent, window, targets, allowed_container=None):
    if window != intent.get("volume_event"):
        raise RuntimeError(f'{container["Name"].lstrip("/")}: destination volume event journal changed')
    verify_volume_event_marker(container, intent)
    until = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    output = run(TARGET, "events", "--since", window["since"], "--until", until,
                 "--filter", "type=volume", "--format", "{{json .}}", capture=True)
    try:
        events = [json.loads(line) for line in output.splitlines() if line]
    except json.JSONDecodeError as error:
        raise RuntimeError("Cannot verify destination volume access events") from error
    if any(not isinstance(event, dict) for event in events):
        raise RuntimeError("Cannot verify destination volume access events")
    marker_events = [event for event in events
                     if event.get("Type") == "volume" and event.get("Action") == "create" and
                     (event.get("Actor") or {}).get("ID") == window["name"]]
    if len(marker_events) != 1:
        raise RuntimeError(f'{container["Name"].lstrip("/")}: destination volume event history is incomplete')
    expected_mounts = set()
    for event in events:
        actor = event.get("Actor") or {}
        if (event.get("Type") != "volume" or event.get("Action") != "mount" or
                actor.get("ID") not in targets):
            continue
        mounted_by = (actor.get("Attributes") or {}).get("container")
        if allowed_container is None or mounted_by != allowed_container:
            raise RuntimeError(f'{container["Name"].lstrip("/")}: another container accessed a destination volume during transfer')
        expected_mounts.add(actor["ID"])
    if allowed_container is not None and expected_mounts != set(targets):
        raise RuntimeError(f'{container["Name"].lstrip("/")}: destination volume mount history is incomplete')
    verify_volume_event_marker(container, intent)


def source_volume_digest(volume):
    return run("/usr/bin/sudo", "/usr/bin/python3", TRUSTED_MANIFEST,
               source_namespace_path(volume["Mountpoint"]), capture=True)


def current_source_volume_digests(container):
    digests = {}
    for mount in container.get("Mounts", []):
        volume = inspect(SOURCE, "volume", mount["Name"])
        validate_source_volume(container, volume)
        digests[mount["Name"]] = source_volume_digest(volume)
    return digests


def seal_quiesced_source_volumes(container, intent):
    actual = current_source_volume_digests(container)
    expected = intent.get("source_volumes")
    if expected is None:
        saved = deepcopy(intent)
        saved["source_volumes"] = actual
        return persist_migration_intent(container, saved)
    if expected != actual:
        raise RuntimeError(f'{container["Name"].lstrip("/")}: source volume changed after quiescing; inspect rootful Docker')
    return intent


def validate_source_volume(container, volume):
    name = container["Name"].lstrip("/")
    mountpoint = volume.get("Mountpoint")
    if (volume.get("Driver") != "local" or volume.get("Options") or
            VOLUME_LABEL in (volume.get("Labels") or {}) or
            not isinstance(mountpoint, str) or not mountpoint.startswith("/") or
            ".." in PurePosixPath(mountpoint).parts or str(PurePosixPath(mountpoint)) != mountpoint):
        raise ValueError(f"{name}: custom volume configuration requires an explicit transfer")


def verify_volume_definition(volume, target, ownership):
    expected_labels = dict(volume.get("Labels") or {})
    expected_labels[VOLUME_LABEL] = ownership
    actual = inspect(TARGET, "volume", target)
    if (actual.get("Name") != target or actual.get("Driver") != "local" or
            actual.get("Options") not in (None, {}) or actual.get("Labels") != expected_labels):
        raise RuntimeError("Destination volume ownership or configuration changed; retained it for inspection")


def validate_volume_record(container, mount, record):
    expected = rf'{container["Id"]}:{re.escape(mount["Name"])}:[a-f0-9]{{64}}'
    if (not isinstance(record, dict) or record.get("source") != mount["Name"] or
            not re.fullmatch(expected, record.get("ownership") or "")):
        raise ValueError(f'{container["Name"].lstrip("/")}: interrupted destination volume record changed')
    return record["ownership"]


def validate_trusted_manifest():
    path = Path(TRUSTED_MANIFEST)
    try:
        metadata = path.lstat()
    except FileNotFoundError as error:
        raise ValueError("the packaged rootless Docker volume verifier is missing") from error
    if (path.is_symlink() or not stat.S_ISREG(metadata.st_mode) or metadata.st_uid != 0 or
            metadata.st_mode & 0o022):
        raise ValueError("the packaged rootless Docker volume verifier is not trusted")
    for parent in path.parents:
        metadata = parent.stat()
        if metadata.st_uid != 0 or metadata.st_mode & 0o022:
            raise ValueError("the packaged rootless Docker volume verifier path is not trusted")


def verify_volume(target, expected):
    destination = inspect(TARGET, "volume", target)["Mountpoint"]
    target_digest = run("target-namespace", "/usr/bin/python3", TRUSTED_MANIFEST,
                        destination, capture=True)
    if expected != target_digest:
        raise RuntimeError("Volume content or metadata verification failed; Docker data was retained")


def source_snapshot(container):
    # Health probes and process IDs are observations, not workload settings.
    # Keep lifecycle timestamps/flags, complete creation/runtime configuration,
    # attachments and security labels so a batch cannot use an obsolete plan.
    fields = ("Id", "Name", "Image", "Config", "HostConfig", "Mounts", "NetworkSettings",
              "AppArmorProfile", "ProcessLabel", "MountLabel", "RestartCount")
    snapshot = {field: container.get(field) for field in fields}
    snapshot["State"] = {key: value for key, value in container["State"].items() if key not in ("Health", "Pid")}
    return snapshot


def snapshot_digest(container, ignore_restart=False):
    fields = ("Id", "Name", "Image", "Config", "HostConfig", "Mounts",
              "AppArmorProfile", "ProcessLabel", "MountLabel")
    snapshot = {field: container.get(field) for field in fields}
    # Docker can rewrite top-level API defaults across a daemon restart (for
    # example HostConfig.Dns changes from null to []). These representations
    # have the same runtime meaning and must not invalidate a durable journal.
    snapshot["HostConfig"] = {
        key: value for key, value in (snapshot["HostConfig"] or {}).items()
        if not (value is None or value is False or value == "" or value == [] or value == {})
    }
    snapshot["Mounts"] = sorted(snapshot["Mounts"] or [],
                                key=lambda mount: json.dumps(mount, sort_keys=True, separators=(",", ":")))
    if ignore_restart:
        snapshot["HostConfig"].pop("RestartPolicy", None)
    networks = container.get("NetworkSettings", {}).get("Networks") or {}
    snapshot["Networks"] = {
        name: {key: network.get(key) for key in ("IPAMConfig", "Links", "Aliases", "DriverOpts")}
        for name, network in networks.items()
    }
    encoded = json.dumps(snapshot, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(encoded.encode()).hexdigest()


def refresh_source(container, validator=validate):
    latest = inspect(SOURCE, "container", container["Id"])
    if source_snapshot(latest) != source_snapshot(container):
        raise ValueError(f'{container["Name"].lstrip("/")}: Docker source changed after preflight; rerun migration after workloads are stable')
    validator(latest)
    return latest


def configured_stop_timeout(container):
    configured = container["Config"].get("StopTimeout")
    return -1 if configured == -1 else max(120, configured or 0)


def restart_policy_argument(container):
    restart = container["HostConfig"].get("RestartPolicy") or {}
    policy = restart.get("Name") or "no"
    if policy == "on-failure" and restart.get("MaximumRetryCount"):
        policy += f':{restart["MaximumRetryCount"]}'
    return policy


def disable_source_restart(container, intent, planned, validator=validate):
    restart = container["HostConfig"].get("RestartPolicy") or {}
    if restart.get("Name") == "no":
        return container, intent
    intent = record_migration_intent(container, saved=intent, restart_disabled=True)
    running = bool(container["State"]["Running"])
    started_at = container["State"]["StartedAt"]
    stopped = None if running else stopped_identity(container["State"])
    run(SOURCE, "update", "--restart=no", container["Id"])
    disabled = inspect(SOURCE, "container", container["Id"])
    validator(disabled)
    lifecycle_changed = (bool(disabled["State"]["Running"]) != running or
                         (running and disabled["State"]["StartedAt"] != started_at) or
                         (not running and stopped_identity(disabled["State"]) != stopped))
    if (lifecycle_changed or
            snapshot_digest(disabled, ignore_restart=True) != snapshot_digest(planned, ignore_restart=True) or
            (disabled["HostConfig"].get("RestartPolicy") or {}).get("Name") != "no"):
        raise RuntimeError(f'{container["Name"].lstrip("/")}: source changed while restart was being disabled')
    return disabled, intent


def begin_quiesce(container, intent):
    intent = deepcopy(intent)
    intent["quiesce_started"] = True
    if container["State"]["Running"]:
        intent["started_at"] = container["State"]["StartedAt"]
        intent.pop("stopped", None)
        # A source restored after an earlier pre-transfer failure may have
        # changed its volume normally while it ran. Establish the next cutover
        # snapshot only after this quiesce stops it again.
        intent["source_volumes"] = None
    return persist_migration_intent(container, intent)


def restore_source(identity, validator=validate):
    current = inspect(SOURCE, "container", identity)
    validator(current)
    if completion_path(identity).exists():
        try:
            target = inspect(TARGET, "container", current["Name"].lstrip("/"))
        except BaseException as error:
            raise RuntimeError(
                f'{current["Name"].lstrip("/")}: completion is durable; source recovery is disabled while the destination cannot be verified'
            ) from error
        if completed(current, target):
            return
        raise RuntimeError(
            f'{current["Name"].lstrip("/")}: completion is durable but changed; inspect both engines'
        )
    intent = migration_intent(current)
    if intent is None:
        return
    if intent["start_attempted"]:
        raise RuntimeError(f'{current["Name"].lstrip("/")}: destination start was attempted; source recovery needs review')
    planned = planned_source(current, intent)
    desired_restart = planned["HostConfig"].get("RestartPolicy") or {}
    if intent["target_running"] and not intent["restore_started"]:
        # Re-enabling `always` can make Docker start the container after a daemon
        # restart. Record that lifecycle restoration has begun before changing
        # the policy so a fresh process can recognize that exact transition.
        intent["restore_started"] = True
        intent["quiesce_started"] = False
        persist_migration_intent(current, intent)
    if (current["HostConfig"].get("RestartPolicy") or {}) != desired_restart:
        run(SOURCE, "update", f"--restart={restart_policy_argument(planned)}", identity)
        current = inspect(SOURCE, "container", identity)
    if intent["target_running"]:
        if not current["State"]["Running"]:
            run(SOURCE, "start", identity)
    elif current["State"]["Running"]:
        raise RuntimeError(f'{current["Name"].lstrip("/")}: stopped source restarted during recovery')
    restored = inspect(SOURCE, "container", identity)
    validator(restored)
    if (bool(restored["State"]["Running"]) != intent["target_running"] or
            snapshot_digest(restored) != snapshot_digest(planned)):
        raise RuntimeError(f'{restored["Name"].lstrip("/")}: source lifecycle could not be restored')
    # A retry can enter batch quiescing with destination artifacts from an
    # earlier interrupted transfer. If a later workload then fails to quiesce,
    # restore this source without discarding the ownership needed to resume or
    # inspect those artifacts safely.
    if not intent["volumes"] and intent.get("destination") is None and not intent["start_attempted"]:
        intent = retire_volume_event_window(planned, intent)
        intent = cleanup_transfer_images(current, intent)
        clear_migration_intent(identity)


def quiesce(container, source_nofile, validator=validate):
    container = refresh_source(container, validator)
    name = container["Name"].lstrip("/")
    if exists("container", name) and completed(container, inspect(TARGET, "container", name)):
        intent = migration_intent(container)
        if intent is not None:
            if intent.get("volume_event") is not None:
                remove_volume_event_marker(container, intent)
            intent = release_transfer_image(container, intent)
        clear_migration_intent(container["Id"])
        print(f"{name}: already migrated")
        return
    intent = migration_intent(container)
    planned = planned_source(container, intent)
    if intent is not None and intent.get("volume_event") is None and not intent["volumes"]:
        remove_volume_event_marker(planned, intent)
    if intent is None:
        intent = record_migration_intent(container, source_nofile=source_nofile)
    elif intent["source_nofile"] != source_nofile:
        raise ValueError(f"{name}: source container file-limit defaults changed during migration")
    if intent["start_attempted"]:
        raise ValueError(f'{container["Name"].lstrip("/")}: destination start was attempted; inspect both engines')
    if intent.get("destination") is not None and intent["restore_started"]:
        raise ValueError(f'{container["Name"].lstrip("/")}: source ran after destination creation; inspect both engines')
    intent = begin_quiesce(container, intent)
    container, intent = disable_source_restart(container, intent, planned, validator)
    if container["State"]["Running"]:
        run(SOURCE, "stop", "-t", str(configured_stop_timeout(planned)), container["Id"])
        stopped = inspect(SOURCE, "container", container["Id"])
        state = stopped["State"]
        if state["Running"] or state.get("ExitCode") in (137, 139):
            raise RuntimeError(f'{container["Name"].lstrip("/")}: container did not stop cleanly; migration aborted')
        if snapshot_digest(stopped) != snapshot_digest(container):
            raise RuntimeError(f'{container["Name"].lstrip("/")}: Docker source changed while stopping; migration aborted')
        container = stopped
    state = container["State"]
    stopped_identity(state)
    intent = record_migration_intent(container, state, intent)
    disabled = inspect(SOURCE, "container", container["Id"])
    validator(disabled)
    if (stopped_identity(disabled["State"]) != stopped_identity(state) or
            snapshot_digest(disabled, ignore_restart=True) != snapshot_digest(planned, ignore_restart=True) or
            (disabled["HostConfig"].get("RestartPolicy") or {}).get("Name") != "no"):
        raise RuntimeError(f'{container["Name"].lstrip("/")}: source changed while being quiesced')
    seal_quiesced_source_volumes(disabled, intent)
    print(f'{container["Name"].lstrip("/")}: quiesced before rootful Docker access revocation')


def verify_resumable_migration(container, target, intent):
    name = container["Name"].lstrip("/")
    if intent["start_attempted"]:
        raise ValueError(f"{name}: destination start was attempted; inspect both engines")
    if intent["restore_started"]:
        raise ValueError(f"{name}: source ran after destination creation; inspect both engines")
    planned = planned_source(container, intent)
    seal_quiesced_source_volumes(container, intent)
    destination = intent.get("destination")
    if (not isinstance(destination, dict) or destination.get("id") != target.get("Id") or
            destination.get("snapshot") != snapshot_digest(target) or
            not target_owned(container, target, intent)):
        raise ValueError(f"{name}: interrupted rootless destination changed; inspect both engines")
    if not target_never_started(target):
        raise ValueError(f"{name}: interrupted rootless destination may have run; inspect both engines")
    verify_runtime(planned, intent["target_ownership"], intent["source_nofile"])

    expected_volumes = {destination_volume(planned, mount): mount
                        for mount in planned.get("Mounts", [])}
    if set(intent["volumes"]) != set(expected_volumes):
        raise ValueError(f"{name}: interrupted destination volume inventory changed")
    for target_name, mount in expected_volumes.items():
        record = intent["volumes"][target_name]
        ownership = validate_volume_record(planned, mount, record)
        if not re.fullmatch(r"[a-f0-9]{64}", record.get("digest") or ""):
            raise ValueError(f"{name}: interrupted destination volume record is incomplete")
        source_volume = inspect(SOURCE, "volume", mount["Name"])
        validate_source_volume(planned, source_volume)
        verify_volume_definition(source_volume, target_name, ownership)
        verify_volume(target_name, record["digest"])
        if source_volume_digest(source_volume) != record["digest"]:
            raise RuntimeError(f"{name}: source volume changed after interruption; inspect both engines")

    state = container["State"]
    if (stopped_identity(state) != intent.get("stopped") or
            snapshot_digest(container, ignore_restart=True) != snapshot_digest(planned, ignore_restart=True)):
        raise RuntimeError(f"{name}: rootful source changed after interruption; inspect both engines")
    return planned, state


def resume_verified_migration(container, target, intent):
    name = container["Name"].lstrip("/")
    planned, state = verify_resumable_migration(container, target, intent)
    if (container["HostConfig"].get("RestartPolicy") or {}).get("Name") != "no":
        intent = record_migration_intent(container, state, intent, restart_disabled=True)
        run(SOURCE, "update", "--restart=no", container["Id"])
    source_after = inspect(SOURCE, "container", container["Id"])
    if (stopped_identity(source_after["State"]) != stopped_identity(state) or
            snapshot_digest(source_after, ignore_restart=True) != snapshot_digest(planned, ignore_restart=True) or
            (source_after["HostConfig"].get("RestartPolicy") or {}).get("Name") != "no"):
        raise RuntimeError(f"{name}: rootful source changed during resumed finalization")

    if intent["target_running"] and not target["State"]["Running"]:
        intent["start_attempted"] = True
        persist_migration_intent(source_after, intent)
        run(TARGET, "start", name)
    target = inspect(TARGET, "container", name)
    if bool(target["State"]["Running"]) != intent["target_running"]:
        raise RuntimeError(f"{name}: resumed destination lifecycle differs from the source")
    expected_volumes = {destination_volume(planned, mount) for mount in planned.get("Mounts", [])}
    event_window = intent.get("volume_event")
    if expected_volumes and event_window is None:
        raise RuntimeError(f"{name}: interrupted destination volume event history is missing")
    if event_window is not None:
        verify_volume_event_window(planned, intent, event_window, expected_volumes,
                                   target["Id"] if intent["target_running"] else None)
    verified_target = verify_runtime(planned, intent["target_ownership"], intent["source_nofile"])
    completion_published = False
    try:
        record_completion(source_after, state, intent["target_running"], verified_target)
        completion_published = True
        if event_window is not None:
            remove_volume_event_marker(planned, intent)
        intent = release_transfer_image(source_after, intent)
        clear_migration_intent(container["Id"])
    except BaseException:
        if completion_published:
            print(f"{name}: migration completed; transfer-image journal cleanup remains pending", file=sys.stderr)
        raise
    print(f"{name}: completed the interrupted rootless Docker migration")


def migrate(container, source_nofile):
    container = refresh_source(container)
    name = container["Name"].lstrip("/")
    identity = container["Id"]
    intent = migration_intent(container)
    if intent is not None and intent["source_nofile"] != source_nofile:
        raise ValueError(f"{name}: source container file-limit defaults changed during migration")
    planned_retry = planned_source(container, intent) if intent is not None else container
    expected_retry_volumes = {
        destination_volume(planned_retry, mount) for mount in planned_retry.get("Mounts", [])
    }
    if exists("container", name):
        target = inspect(TARGET, "container", name)
        container = refresh_source(container)
        if completed(container, target):
            if intent is not None:
                if intent.get("volume_event") is not None:
                    remove_volume_event_marker(container, intent)
                remove_volume_guard(container, intent)
                intent = release_transfer_image(container, intent)
            clear_migration_intent(identity)
            print(f"{name}: already migrated")
            return
        if intent is not None and intent.get("volume_event") is not None:
            verify_volume_event_window(planned_retry, intent, intent["volume_event"],
                                       expected_retry_volumes)
        elif intent is not None and intent["volumes"]:
            raise RuntimeError(f"{name}: interrupted destination volume event history is missing")
        if intent is not None and intent["start_attempted"]:
            raise ValueError(f"{name}: destination start was attempted; inspect both engines")
        if intent is None:
            raise ValueError(f"{name}: an existing rootless Docker container needs review; no owned transfer matches it")
        if not target_owned(container, target, intent):
            intent = record_destination_may_have_run(container, intent)
            raise ValueError(f"{name}: an existing rootless Docker container needs review; no owned transfer matches it")
        if intent.get("destination") is not None:
            if exists("container", volume_guard_name(intent)):
                raise ValueError(f"{name}: completed volume transfer still has a guard; inspect both engines")
            resume_verified_migration(container, target, intent)
            return
        if not target_never_started(target):
            intent = record_destination_may_have_run(container, intent)
            raise ValueError(f"{name}: an incomplete rootless destination may have run; inspect both engines")
        owned_id = target["Id"]
        run(TARGET, "rm", "--force", owned_id)
        if exists("container", name):
            intent = record_destination_may_have_run(container, intent)
            raise ValueError(f"{name}: rootless destination name was replaced during recovery")
    if intent is not None:
        if intent.get("volume_event") is None and not intent["volumes"]:
            remove_volume_event_marker(planned_retry, intent)
        if (intent.get("volume_event") is not None and
                (exists("volume", intent["volume_event"]["name"]) or intent["volumes"])):
            verify_volume_event_window(planned_retry, intent, intent["volume_event"],
                                       expected_retry_volumes)
        elif intent["volumes"]:
            raise RuntimeError(f"{name}: interrupted destination volume event history is missing")
        try:
            remove_volume_guard(container, intent)
        except BaseException:
            intent = record_destination_may_have_run(container, intent)
            raise
        intent = cleanup_transfer_images(container, intent)
    if intent is not None and intent["start_attempted"]:
        raise ValueError(f"{name}: destination start was attempted; inspect both engines")
    if completion_path(identity).exists():
        raise ValueError(f"{name}: a previously migrated destination is missing; inspect retained data before retrying")

    container = refresh_source(container)
    intent = migration_intent(container)
    planned = planned_source(container, intent)
    running = intent["target_running"] if intent is not None else bool(container["State"]["Running"])
    created_id = None
    guard_id = None
    event_window = intent.get("volume_event") if intent is not None else None
    image = None
    start_attempted = False
    completion_published = False
    verified_volumes = {}
    restart = planned["HostConfig"].get("RestartPolicy") or {}
    policy = restart_policy_argument(planned)
    try:
        if intent is None:
            intent = record_migration_intent(container, source_nofile=source_nofile)
        expected_volume_names = {destination_volume(planned, mount) for mount in planned.get("Mounts", [])}
        if set(intent["volumes"]) - expected_volume_names:
            raise ValueError(f"{name}: interrupted destination volume inventory changed")
        if intent.get("destination") is not None:
            intent = deepcopy(intent)
            intent.pop("destination")
            persist_migration_intent(container, intent)
        intent = begin_quiesce(container, intent)
        container, intent = disable_source_restart(container, intent, planned)
        run(SOURCE, "stop", "-t", str(configured_stop_timeout(planned)), identity)
        stopped_source = inspect(SOURCE, "container", identity)
        state = stopped_source["State"]
        if state["Running"] or (running and state["ExitCode"] in (137, 139)):
            raise RuntimeError(f"{name}: container did not stop cleanly; transfer aborted")
        stopped_identity(state)
        if snapshot_digest(stopped_source) != snapshot_digest(container):
            raise RuntimeError(f"{name}: Docker source configuration changed while stopping; rerun after workloads are stable")
        container = stopped_source
        intent = record_migration_intent(container, state, intent)
        intent = seal_quiesced_source_volumes(container, intent)
        intent = deepcopy(intent)
        intent["image"] = {
            "tag": f'omarchy-rootless-docker-transfer:{intent["target_ownership"]}',
            "source": None,
            "target": None,
            "target_preexisting": None,
        }
        intent = persist_migration_intent(container, intent)
        image_record = transfer_image_record(intent)
        # Commit includes writable-layer changes and the exact image config.
        # Volume data is copied separately while the source container is stopped.
        image = run(SOURCE, "commit", identity, image_record["tag"], capture=True)
        if not re.fullmatch(r"sha256:[a-f0-9]{64}", image or ""):
            raise RuntimeError(f"{name}: Docker did not return a transferable committed image")
        source_image = inspect(SOURCE, "image", image_record["tag"])
        if source_image.get("Id") != image or not transfer_image_owned(source_image, image_record, SOURCE):
            raise RuntimeError(f"{name}: source transfer image ownership could not be proven")
        intent = update_transfer_image(container, intent, SOURCE, image)
        image_record = transfer_image_record(intent)
        target_preexisting = exists("image", image)
        if not target_preexisting:
            if exists("image", image_record["tag"]):
                raise RuntimeError(f"{name}: destination transfer image tag already exists")
            # Saving by tag keeps the unpredictable journal-owned identity in
            # the archive. Saving by digest produces an untagged load that a
            # fresh process cannot distinguish safely from an unrelated image.
            pipe([SOURCE, "image", "save", image_record["tag"]],
                 [TARGET, "image", "load", "--quiet"])
            target_image = inspect(TARGET, "image", image_record["tag"])
            if (target_image.get("Id") != image_record["source"] or
                    not transfer_image_owned(target_image, image_record, TARGET)):
                raise RuntimeError(f"{name}: destination transfer image ownership could not be proven")
            image = target_image["Id"]
        intent = update_target_transfer_image(container, intent, image, target_preexisting)
        image_record = transfer_image_record(intent)
        target_reference = image if target_preexisting else image_record["tag"]
        remove_transfer_image(SOURCE, image_record)
        intent = update_transfer_image(container, intent, SOURCE, None)
        arguments = [TARGET, "create", "--pull=never", "--name", name,
                     "--label", f"{LABEL}={identity}",
                     "--label", f'{OWNERSHIP_LABEL}={intent["target_ownership"]}', "--privileged=false",
                     "--ipc=private", "--cgroupns=private", "--network=bridge", "--runtime", "runc"]
        arguments += runtime_arguments(planned, intent["source_nofile"])
        config = planned["Config"]
        if config.get("Hostname"):
            arguments += ["--hostname", config["Hostname"]]
        if config.get("StopTimeout") is not None:
            arguments += ["--stop-timeout", str(config["StopTimeout"])]
        for field, stream in (("AttachStdin", "stdin"), ("AttachStdout", "stdout"), ("AttachStderr", "stderr")):
            if config.get(field):
                arguments += ["--attach", stream]
        if config.get("Tty"):
            arguments += ["--tty"]
        if config.get("OpenStdin"):
            arguments += ["--interactive"]
        arguments += ["--restart", policy]
        for port, bindings in (planned["HostConfig"].get("PortBindings") or {}).items():
            for binding in bindings or []:
                arguments += ["--publish", f'127.0.0.1:{binding["HostPort"]}:{port}']
        pending_volumes = {}
        if expected_volume_names:
            intent = ensure_volume_event_window(planned, intent, expected_volume_names)
            event_window = intent["volume_event"]
        for mount in planned.get("Mounts", []):
            volume = inspect(SOURCE, "volume", mount["Name"])
            validate_source_volume(container, volume)
            target = destination_volume(planned, mount)
            record = intent["volumes"].get(target)
            if record is None:
                if exists("volume", target):
                    raise ValueError(f"{name}: destination volume already exists; retained it for inspection")
                ownership = volume_identity(planned, mount)
                record = {"source": mount["Name"], "ownership": ownership}
                intent["volumes"][target] = record
                persist_migration_intent(container, intent)
            else:
                ownership = validate_volume_record(planned, mount, record)
            volume_arguments = [TARGET, "volume", "create"]
            for key, value in (volume.get("Labels") or {}).items():
                volume_arguments += ["--label", f"{key}={value}"]
            volume_arguments += ["--label", f"{VOLUME_LABEL}={ownership}"]
            retained = exists("volume", target)
            if not retained:
                run(*volume_arguments, target)
            verify_volume_definition(volume, target, ownership)
            if volume_users(target):
                raise RuntimeError(f"{name}: destination volume is attached; retained it for inspection")
            pending_volumes[target] = (volume, ownership, record)
            mount_arg = f'type=volume,src={target},dst={mount["Destination"]},volume-nocopy'
            if not mount.get("RW"):
                mount_arg += ",readonly"
            arguments += ["--mount", mount_arg]
        arguments.append(target_reference)
        if pending_volumes:
            guard_name = volume_guard_name(intent)
            guard_arguments = [
                TARGET, "create", "--pull=never", "--name", guard_name,
                "--label", f"{LABEL}={identity}",
                "--label", f'{OWNERSHIP_LABEL}={intent["target_ownership"]}',
                "--privileged=false", "--read-only", "--cap-drop", "ALL",
                "--security-opt", "no-new-privileges", "--ipc=private",
                "--cgroupns=private", "--network=none", "--runtime", "runc",
                "--restart", "no", "--entrypoint", f"/.{guard_name}",
            ]
            for mount in planned.get("Mounts", []):
                target = destination_volume(planned, mount)
                mount_arg = f'type=volume,src={target},dst={mount["Destination"]},volume-nocopy'
                if not mount.get("RW"):
                    mount_arg += ",readonly"
                guard_arguments += ["--mount", mount_arg]
            guard_arguments.append(target_reference)
            run(*guard_arguments)
            guard = inspect(TARGET, "container", guard_name)
            if (not re.fullmatch(r"[a-f0-9]{64}", guard.get("Id") or "") or
                    not volume_guard_owned(planned, guard, intent)):
                raise RuntimeError(f"{name}: rootless volume guard ownership could not be proven")
            guard_id = guard["Id"]
            for target, pending in pending_volumes.items():
                volume, ownership, _record = pending
                verify_volume_definition(volume, target, ownership)
                if set(volume_users(target)) != {guard_id}:
                    raise RuntimeError(f"{name}: destination volume guard changed; retained it for inspection")
            verify_volume_event_window(planned, intent, event_window, set(pending_volumes))
        for target, pending in pending_volumes.items():
            volume, ownership, record = pending
            verify_volume_definition(volume, target, ownership)
            if set(volume_users(target)) != {guard_id}:
                raise RuntimeError(f"{name}: destination volume guard changed; retained it for inspection")
            clear_volume(target)
            verify_volume_definition(volume, target, ownership)
            if set(volume_users(target)) != {guard_id}:
                raise RuntimeError(f"{name}: destination volume guard changed; retained it for inspection")
            digest = transfer_volume(volume, target)
            record["digest"] = digest
            persist_migration_intent(container, intent)
            verified_volumes[target] = (volume, ownership, digest)
        for target, expected in verified_volumes.items():
            volume, ownership, digest = expected
            verify_volume_definition(volume, target, ownership)
            # A digest proves what the page cache currently returns. Flush the
            # destination filesystem before any completion metadata can outlive
            # the copied volume data across sudden power loss.
            sync_volume(target)
            verify_volume(target, digest)
            if source_volume_digest(volume) != digest:
                raise RuntimeError(f"{name}: source volume changed during transfer; inspect both engines")
        latest_source = inspect(SOURCE, "container", identity)
        if (stopped_identity(latest_source["State"]) != stopped_identity(state) or
                snapshot_digest(latest_source) != snapshot_digest(container)):
            raise RuntimeError(f"{name}: Docker source changed during transfer; inspect both engines")
        if guard_id is not None:
            guard = inspect(TARGET, "container", guard_id)
            if not volume_guard_owned(planned, guard, intent):
                raise RuntimeError(f"{name}: rootless volume guard changed or ran during transfer")
        validate_target_policy()
        run(*arguments)
        target = inspect(TARGET, "container", name)
        if (not re.fullmatch(r"[a-f0-9]{64}", target.get("Id") or "") or
                not target_never_started(target) or not target_owned(planned, target, intent)):
            raise RuntimeError(f"{name}: rootless destination ownership could not be proven")
        created_id = target["Id"]
        verify_runtime(planned, intent["target_ownership"], intent["source_nofile"])
        for target_name, pending in pending_volumes.items():
            volume, ownership, _record = pending
            verify_volume_definition(volume, target_name, ownership)
            if set(volume_users(target_name)) != {guard_id, created_id}:
                raise RuntimeError(f"{name}: destination volume references changed; retained it for inspection")
        if guard_id is not None:
            guard = inspect(TARGET, "container", guard_id)
            if not volume_guard_owned(planned, guard, intent):
                raise RuntimeError(f"{name}: rootless volume guard changed or ran during finalization")
            run(TARGET, "rm", "--force", guard_id)
            guard_id = None
            if exists("container", volume_guard_name(intent)):
                raise RuntimeError(f"{name}: rootless volume guard name was replaced during finalization")
        for target_name in pending_volumes:
            if set(volume_users(target_name)) != {created_id}:
                raise RuntimeError(f"{name}: final destination volume references changed; retained it for inspection")
        target = inspect(TARGET, "container", created_id)
        if not target_never_started(target) or not target_owned(planned, target, intent):
            raise RuntimeError(f"{name}: rootless destination changed or ran during finalization")
        intent["destination"] = {"id": created_id, "snapshot": snapshot_digest(target)}
        persist_migration_intent(container, intent)
        source_after = inspect(SOURCE, "container", identity)
        if (stopped_identity(source_after["State"]) != stopped_identity(state) or
                snapshot_digest(source_after, ignore_restart=True) != snapshot_digest(planned, ignore_restart=True) or
                (source_after["HostConfig"].get("RestartPolicy") or {}).get("Name") != "no"):
            raise RuntimeError(f"{name}: Docker source changed during finalization; inspect both engines")
        if running:
            # Even a failed start command may have launched an application that
            # accepted writes. From this point the destination is recovery data.
            start_attempted = True
            intent["start_attempted"] = True
            persist_migration_intent(source_after, intent)
            run(TARGET, "start", name)
        # A crash before this receipt leaves the destination for review. Its
        # label alone must never turn a partial transfer into a successful retry.
        target_state = inspect(TARGET, "container", name)["State"]
        if bool(target_state["Running"]) != bool(running):
            raise RuntimeError(f"{name}: destination lifecycle differs from the source")
        if event_window is not None:
            verify_volume_event_window(planned, intent, event_window, set(pending_volumes),
                                       created_id if running else None)
        verified_target = verify_runtime(planned, intent["target_ownership"], intent["source_nofile"])
        record_completion(source_after, state, bool(running), verified_target)
        completion_published = True
        if event_window is not None:
            remove_volume_event_marker(planned, intent)
        intent = release_transfer_image(source_after, intent)
        clear_migration_intent(identity)
        print(f"{name}: migrated to rootless Docker; rootful copy retained for recovery")
    except BaseException:
        if intent is None:
            raise
        # The receipt rename and directory fsync happen inside record_completion.
        # A signal can arrive after that durable boundary but before the next
        # Python assignment, so the file itself is the final authority.
        if completion_published or completion_path(identity).exists():
            print(f"{name}: migration completed; transfer-image journal cleanup remains pending", file=sys.stderr)
            raise
        if start_attempted:
            print(f"{name}: destination start was attempted; both copies were retained for recovery. "
                  "Inspect rootless Docker before resuming the rootful copy or retrying migration.", file=sys.stderr)
            raise
        recovery_failed = False
        destination_may_have_run = False
        try:
            owned_target = inspect(TARGET, "container", created_id or name)
            if not target_owned(planned, owned_target, intent):
                destination_may_have_run = True
                raise RuntimeError("rootless destination ownership changed")
            if not target_never_started(owned_target):
                destination_may_have_run = True
                raise RuntimeError("rootless destination may have run")
            run(TARGET, "rm", "--force", owned_target["Id"])
            if exists("container", name):
                destination_may_have_run = True
                raise RuntimeError("rootless destination name was replaced")
        except subprocess.CalledProcessError:
            if exists("container", name):
                destination_may_have_run = True
                recovery_failed = True
                print(f"{name}: destination identity was replaced; retained both stores for review", file=sys.stderr)
        except Exception:
            recovery_failed = True
            print(f"{name}: destination cleanup was not ownership-safe; retained it for inspection", file=sys.stderr)
        try:
            guard_name = volume_guard_name(intent)
            if exists("container", guard_name):
                guard = inspect(TARGET, "container", guard_name)
                if ((guard_id is not None and guard.get("Id") != guard_id) or
                        not volume_guard_owned(planned, guard, intent)):
                    destination_may_have_run = True
                    raise RuntimeError("rootless volume guard changed or ran")
                run(TARGET, "rm", "--force", guard["Id"])
                if exists("container", guard_name):
                    destination_may_have_run = True
                    raise RuntimeError("rootless volume guard name was replaced")
        except subprocess.CalledProcessError:
            pass
        except Exception:
            recovery_failed = True
            print(f"{name}: volume guard cleanup was not ownership-safe; retained it for inspection", file=sys.stderr)
        if destination_may_have_run:
            try:
                intent["start_attempted"] = True
                persist_migration_intent(container, intent)
            except Exception:
                pass
            print(f"{name}: a rootless migration container may have run; both stores were retained for review", file=sys.stderr)
            raise
        recovery = []
        try:
            intent = cleanup_transfer_images(container, intent)
        except Exception:
            recovery_failed = True
            print(f"{name}: transfer image cleanup was not ownership-safe; retained it for inspection", file=sys.stderr)
        if intent["restart_disabled"] and restart.get("Name") != "no":
            recovery.append((SOURCE, "update", f"--restart={policy}", identity))
        if running:
            try:
                intent["restore_started"] = True
                persist_migration_intent(container, intent)
            except Exception:
                recovery_failed = True
                print(f"{name}: source recovery intent could not be saved", file=sys.stderr)
            recovery.append((SOURCE, "start", identity))
        for command in recovery:
            try:
                run(*command)
            except Exception:
                # A failed cleanup must not prevent trying to restart Docker.
                recovery_failed = True
                print(f"{name}: a recovery step failed; inspect both engines before retrying", file=sys.stderr)
        retained_volume = False
        for target in intent["volumes"]:
            try:
                retained_volume = retained_volume or exists("volume", target)
            except Exception:
                recovery_failed = True
                retained_volume = True
        if not recovery_failed and not retained_volume:
            try:
                restored = inspect(SOURCE, "container", identity)
                if (bool(restored["State"]["Running"]) == bool(running) and
                        snapshot_digest(restored) == snapshot_digest(planned)):
                    intent = retire_volume_event_window(planned, intent, volumes_absent=True)
                    clear_migration_intent(identity)
            except Exception:
                pass
        raise


def main():
    if os.geteuid() == 0:
        raise ValueError("Run the migration as the desktop user; the destination is always rootless")
    os.environ.setdefault("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
    if sys.argv[1:] == ["--check-target-policy"]:
        validate_target_policy()
        print("rootless Docker target policy verified")
        return
    if sys.argv[1:] == ["--cleanup-probes"]:
        validate_source_daemon(daemon_security(SOURCE))
        validate_target_policy()
        cleanup_nofile_probe()
        return
    quiesce_all_mode = sys.argv[1:2] == ["--quiesce-all"]
    if quiesce_all_mode:
        if len(sys.argv) < 3:
            raise ValueError("Expected a Windows identity placeholder before container names")
        windows_identity = sys.argv[2]
        names = sys.argv[3:]
        validate_source_daemon(daemon_security(SOURCE))
        validate_target_policy()
        source_nofile = source_default_nofile()
        containers = [inspect(SOURCE, "container", name) for name in names]
        volumes = set()
        blockers = []
        intents = {}
        for container in containers:
            try:
                validate(container)
                intent = migration_intent(container)
                intents[container["Id"]] = intent
            except (ValueError, RuntimeError) as error:
                blockers.append(str(error))
                continue
            for mount in container.get("Mounts", []):
                volume = inspect(SOURCE, "volume", mount["Name"])
                try:
                    validate_source_volume(container, volume)
                except ValueError as error:
                    blockers.append(str(error))
                if mount["Name"] in volumes:
                    blockers.append(f'{container["Name"].lstrip("/")}: custom or shared volumes require an explicit transfer')
                volumes.add(mount["Name"])
        windows = None
        if windows_identity != "-":
            windows = inspect(SOURCE, "container", windows_identity)
            try:
                validate_windows_exception(windows)
            except ValueError as error:
                blockers.append(str(error))
        if blockers:
            raise ValueError("\n".join(blockers))
        source_nofiles = {}
        for container in containers:
            try:
                source_nofiles[container["Id"]] = container_nofile(
                    container, source_nofile, intents[container["Id"]],
                )
            except (ValueError, RuntimeError) as error:
                blockers.append(str(error))
        target_limits = {(limits["soft"], limits["hard"])
                         for limits in source_nofiles.values()}
        for soft, hard in sorted(target_limits):
            try:
                validate_target_nofile({"soft": soft, "hard": hard})
            except (ValueError, RuntimeError, subprocess.CalledProcessError) as error:
                blockers.append(str(error))
        windows_nofile = source_nofile
        if windows is not None:
            try:
                windows_intent = migration_intent(windows)
                windows_nofile = container_nofile(windows, source_nofile, windows_intent)
            except (ValueError, RuntimeError) as error:
                blockers.append(str(error))
        if blockers:
            raise ValueError("\n".join(blockers))
        if volumes:
            validate_trusted_manifest()
        for container in containers:
            intent = intents[container["Id"]]
            if (intent is not None and not container["State"]["Running"] and
                    intent.get("source_volumes") is not None):
                try:
                    seal_quiesced_source_volumes(container, intent)
                except (ValueError, RuntimeError) as error:
                    blockers.append(str(error))
        if blockers:
            raise ValueError("\n".join(blockers))
        quiesced = []
        try:
            for container in containers:
                quiesced.append((container["Id"], validate))
                quiesce(container, source_nofiles[container["Id"]])
            if windows is not None:
                quiesced.append((windows["Id"], validate_windows_exception))
                quiesce(windows, windows_nofile, validate_windows_exception)
        except BaseException:
            for identity, validator in reversed(quiesced):
                try:
                    restore_source(identity, validator)
                except Exception:
                    print("A quiesced rootful workload could not be restored; inspect Docker before retrying", file=sys.stderr)
            raise
        return
    restore_windows = sys.argv[1:2] == ["--restore-windows"]
    if restore_windows:
        if len(sys.argv) != 3:
            raise ValueError("Expected one Windows container identity")
        validate_source_daemon(daemon_security(SOURCE))
        restore_source(sys.argv[2], validate_windows_exception)
        print("omarchy-windows: restored after rootful Docker access revocation")
        return
    check_windows = sys.argv[1:2] == ["--check-windows"]
    if check_windows:
        if len(sys.argv) != 3:
            raise ValueError("Expected one Windows container identity")
        validate_source_daemon(daemon_security(SOURCE))
        validate_windows_exception(inspect(SOURCE, "container", sys.argv[2]))
        print("omarchy-windows: verified managed rootful exception")
        return
    check_completed = sys.argv[1:2] == ["--check-completed"]
    check_only = check_completed or sys.argv[1:2] == ["--check"]
    names = sys.argv[2:] if check_only else sys.argv[1:]
    source_nofile = None
    if names:
        validate_source_daemon(daemon_security(SOURCE))
        validate_target_policy()
        if not check_completed:
            source_nofile = source_default_nofile()
    containers = [inspect(SOURCE, "container", name) for name in names]
    volumes = set()
    blockers = []
    intents = {}
    for container in containers:
        try:
            validate(container)
            intent = migration_intent(container)
            intents[container["Id"]] = intent
        except (ValueError, RuntimeError) as error:
            blockers.append(str(error))
            continue
        for mount in container.get("Mounts", []):
            volume = inspect(SOURCE, "volume", mount["Name"])
            try:
                validate_source_volume(container, volume)
            except ValueError as error:
                blockers.append(str(error))
            if mount["Name"] in volumes:
                blockers.append(f'{container["Name"].lstrip("/")}: custom or shared volumes require an explicit transfer')
            volumes.add(mount["Name"])
    if blockers:
        raise ValueError("\n".join(blockers))
    source_nofiles = {}
    if not check_completed:
        for container in containers:
            try:
                source_nofiles[container["Id"]] = container_nofile(
                    container, source_nofile, intents[container["Id"]],
                )
            except (ValueError, RuntimeError) as error:
                blockers.append(str(error))
        for soft, hard in sorted({(limits["soft"], limits["hard"])
                                  for limits in source_nofiles.values()}):
            try:
                validate_target_nofile({"soft": soft, "hard": hard})
            except (ValueError, RuntimeError, subprocess.CalledProcessError) as error:
                blockers.append(str(error))
    if blockers:
        raise ValueError("\n".join(blockers))
    if volumes:
        validate_trusted_manifest()
    for container in containers:
        intent = intents[container["Id"]]
        if (intent is not None and not container["State"]["Running"] and
                intent.get("source_volumes") is not None):
            try:
                seal_quiesced_source_volumes(container, intent)
            except (ValueError, RuntimeError) as error:
                blockers.append(str(error))
    if blockers:
        raise ValueError("\n".join(blockers))
    if check_completed:
        for container in containers:
            name = container["Name"].lstrip("/")
            if (not exists("container", name) or
                    not completed(container, inspect(TARGET, "container", name)) or
                    (container["HostConfig"].get("RestartPolicy") or {}).get("Name") != "no"):
                raise ValueError(f"{name}: completed transfer changed; Docker must remain available for recovery")
        return
    if not check_completed:
        # Check all destination names before stopping the first source.
        for container in containers:
            name = container["Name"].lstrip("/")
            intent = migration_intent(container)
            if exists("container", name):
                target = inspect(TARGET, "container", name)
                if completed(container, target):
                    continue
                if intent is not None and intent["start_attempted"]:
                    raise ValueError(f"{name}: destination start was attempted; inspect both engines")
                if intent is None or not target_owned(container, target, intent):
                    raise ValueError(f"{name}: an existing rootless Docker container needs review; no owned transfer matches it")
                if intent.get("destination") is not None:
                    verify_resumable_migration(container, target, intent)
                elif not target_never_started(target):
                    raise ValueError(f"{name}: an incomplete rootless destination may have run; inspect both engines")
                continue
            if intent is not None and intent["start_attempted"]:
                raise ValueError(f"{name}: destination start was attempted; inspect both engines")
            if completion_path(container["Id"]).exists():
                raise ValueError(f"{name}: a previously migrated destination is missing; inspect retained data before retrying")
            for mount in container.get("Mounts", []):
                target = destination_volume(container, mount)
                if exists("volume", target):
                    record = intent["volumes"].get(target) if intent is not None else None
                    source_volume = inspect(SOURCE, "volume", mount["Name"])
                    if record is None:
                        raise ValueError(f"{name}: destination volume already exists; retained it for inspection")
                    ownership = validate_volume_record(container, mount, record)
                    verify_volume_definition(source_volume, target, ownership)
    if check_only:
        for container in containers:
            print(f'{container["Name"].lstrip("/")}: ready for rootless Docker migration')
    if not check_only:
        try:
            for container in containers:
                migrate(container, source_nofiles[container["Id"]])
        except BaseException:
            for container in reversed(containers):
                try:
                    restore_source(container["Id"])
                except Exception:
                    print(f'{container["Name"].lstrip("/")}: a quiesced source could not be restored; inspect both engines',
                          file=sys.stderr)
            raise


if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as error:
        # Do not print argv: health commands and volume labels can hold secrets.
        print(f"Rootless Docker migration command failed (exit {error.returncode}); rootful Docker data was retained", file=sys.stderr)
        sys.exit(1)
    except (ValueError, RuntimeError) as error:
        print(f"Rootless Docker migration stopped: {error}", file=sys.stderr)
        sys.exit(1)
