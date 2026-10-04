#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

python3 - <<'PY'
import copy
import io
import importlib.util
import json
import os
import re
import subprocess
import sys
import tarfile
import tempfile
from pathlib import Path


sys.dont_write_bytecode = True
path = os.path.join(os.environ["ROOT"], "default/docker/rootless/migrate.py")
spec = importlib.util.spec_from_file_location("rootless_docker_migration", path)
migration = importlib.util.module_from_spec(spec)
spec.loader.exec_module(migration)
os.environ["OMARCHY_ROOTFUL_DOCKER_HOST"] = "unix:///proc/4242/root/run/docker.sock"
manifest_path = os.path.join(os.environ["ROOT"], "default/docker/rootless/volume-manifest.py")
manifest_spec = importlib.util.spec_from_file_location("rootless_docker_volume_manifest", manifest_path)
manifest = importlib.util.module_from_spec(manifest_spec)
manifest_spec.loader.exec_module(manifest)
assert migration.TRUSTED_MANIFEST == "/usr/share/omarchy/default/docker/rootless/volume-manifest.py"
assert migration.local_command([migration.SOURCE, "info"])[:2] == ["/usr/bin/sudo", "/usr/bin/docker"]
print("ok - privileged migration helpers resolve only through packaged absolute paths")

with tempfile.TemporaryDirectory() as directory:
    volume = os.path.join(directory, "volume")
    outside = os.path.join(directory, "outside")
    os.makedirs(os.path.join(volume, "nested"))
    os.makedirs(outside)
    with open(os.path.join(volume, "stale"), "w") as output:
        output.write("old")
    with open(os.path.join(volume, "nested", "old"), "w") as output:
        output.write("old")
    with open(os.path.join(outside, "keep"), "w") as output:
        output.write("safe")
    os.symlink(outside, os.path.join(volume, "outside-link"))
    manifest.clear(volume)
    assert not os.listdir(volume)
    assert open(os.path.join(outside, "keep")).read() == "safe"
    with open(os.path.join(volume, "durable"), "w") as output:
        output.write("new")
    manifest.sync_filesystem(volume)
    archived = subprocess.run(
        [sys.executable, manifest_path, "--archive", volume],
        check=True, stdout=subprocess.PIPE,
    ).stdout
    with tarfile.open(fileobj=io.BytesIO(archived)) as archive:
        assert sorted(archive.getnames()) == [".", "./durable"]
    volume_link = os.path.join(directory, "volume-link")
    os.symlink(volume, volume_link)
    try:
        manifest.fingerprint(volume_link)
    except OSError:
        pass
    else:
        raise AssertionError("a symlinked privileged volume root was accepted")
print("ok - volume helper pins real roots, stays on one filesystem, and archives through its descriptor")

for operation in ("fingerprint", "clear"):
    with tempfile.TemporaryDirectory() as directory:
        volume = Path(directory) / "volume"
        child = volume / "child"
        displaced = volume / "displaced"
        outside = Path(directory) / "outside"
        child.mkdir(parents=True)
        outside.mkdir()
        (child / "inside").write_text("volume")
        (outside / "keep").write_text("outside")
        original_listdir = manifest.os.listdir
        raced = False

        def race_child(descriptor):
            global raced
            resolved = Path(os.readlink(f"/proc/self/fd/{descriptor}")) if isinstance(descriptor, int) else None
            if not raced and resolved == child:
                raced = True
                child.rename(displaced)
                child.symlink_to(outside, target_is_directory=True)
            return original_listdir(descriptor)

        manifest.os.listdir = race_child
        try:
            try:
                getattr(manifest, operation)(volume)
            except RuntimeError:
                pass
            else:
                raise AssertionError(f"a raced child symlink passed privileged volume {operation}")
        finally:
            manifest.os.listdir = original_listdir
        assert raced
        assert (outside / "keep").read_text() == "outside"
print("ok - descriptor-relative volume traversal cannot follow raced child symlinks")

with tempfile.TemporaryDirectory() as directory:
    proc = Path(directory) / "proc"
    config_home = "/home/test/.config"
    config_dir = proc / "4242/root/home/test/.config/docker"
    config_dir.mkdir(parents=True)
    config = config_dir / "daemon.json"
    config.write_text(json.dumps(migration.TARGET_DAEMON_CONFIG))
    config.chmod(0o600)
    assert migration.target_config(proc, 4242, config_home, config.stat().st_ctime + 10) == \
        migration.TARGET_DAEMON_CONFIG
    trusted = config.with_name("daemon.trusted.json")
    config.rename(trusted)
    config.symlink_to(trusted)
    try:
        migration.target_config(proc, 4242, config_home, trusted.stat().st_ctime + 10)
    except ValueError:
        pass
    else:
        raise AssertionError("a symlinked target daemon configuration was accepted")
print("ok - target daemon configuration is read from its mount namespace through a pinned file")

with tempfile.TemporaryDirectory() as directory:
    proc = Path(directory)
    process = proc / "4242"
    process.mkdir()
    (process / "root/run/user/1000").mkdir(parents=True)
    (process / "stat").write_text("4242 (dockerd) S " + " ".join(["0"] * 18) + " 98765\n")
    (process / "exe").symlink_to("/usr/bin/dockerd")
    identity = {"pid": 4242, "start": "98765", "runtime": "/run/user/1000"}
    original_peer_credentials = migration.unix_peer_credentials
    migration.unix_peer_credentials = lambda endpoint: (4242, os.getuid(), os.getgid())
    try:
        pid, endpoint = migration.verified_target_daemon(identity, proc)
        assert pid == 4242
        assert endpoint == str(process / "root/run/user/1000/docker.sock")
        (process / "stat").write_text("4242 (dockerd) S " + " ".join(["0"] * 18) + " 98766\n")
        try:
            migration.verified_target_daemon(identity, proc)
        except RuntimeError:
            pass
        else:
            raise AssertionError("a restarted target daemon retained the previous migration authority")
    finally:
        migration.unix_peer_credentials = original_peer_credentials

original_verified_target_daemon = migration.verified_target_daemon
migration.verified_target_daemon = lambda identity: (4242, "/proc/4242/root/run/user/1000/docker.sock")
try:
    migration.TARGET_DAEMON_IDENTITY = {"verified": True}
    assert migration.local_command([migration.TARGET, "info"])[1:3] == [
        "--host", "unix:///proc/4242/root/run/user/1000/docker.sock",
    ]
    assert migration.local_command(["target-namespace", "/usr/bin/true"])[5:] == [
        "4242", "/usr/bin/true",
    ]
finally:
    migration.verified_target_daemon = original_verified_target_daemon
    migration.TARGET_DAEMON_IDENTITY = None
print("ok - every target command and namespace entry uses the verified dockerd identity")

with tempfile.TemporaryDirectory() as directory:
    state_home = Path(directory) / "new-state-home"
    observed_syncs = []
    original_fsync = migration.os.fsync

    def tracing_fsync(descriptor):
        observed_syncs.append(Path(os.readlink(f"/proc/self/fd/{descriptor}")).resolve())
        original_fsync(descriptor)

    migration.os.fsync = tracing_fsync
    try:
        migration.write_private_json(
            state_home / "omarchy/rootless-docker-migration" / ("a" * 64 + ".in-progress"),
            {"state": "durable"},
        )
    finally:
        migration.os.fsync = original_fsync
    assert Path(directory).resolve() in observed_syncs
print("ok - first journal creation synchronizes the new state hierarchy into its existing parent")

source_security = ["name=seccomp,profile=builtin", "name=cgroupns"]
target_security = ["name=seccomp,profile=builtin", "name=rootless", "name=cgroupns"]
source_nofile = {"soft": 65536, "hard": 524288}
assert migration.parse_nofile_limits(
    "Limit                     Soft Limit           Hard Limit           Units\n"
    "Max open files            65536                524288               files\n"
) == source_nofile
for invalid in ("", "Max open files unknown 524288 files", "Max open files 0 524288 files"):
    try:
        migration.parse_nofile_limits(invalid)
    except ValueError:
        pass
    else:
        raise AssertionError("an invalid source file-limit probe result passed")
probe_token = "a" * 64
with tarfile.open(fileobj=io.BytesIO(migration.nofile_probe_rootfs(probe_token))) as archive:
    names = archive.getnames()
    assert "usr/bin/sleep" in names
    assert f"omarchy-rootless-docker-probe/{probe_token}" in names
original_probe_rootfs = migration.nofile_probe_rootfs
original_subprocess_run = migration.subprocess.run
original_run = migration.run
original_inspect = migration.inspect
original_docker_inspect_optional = migration.docker_inspect_optional
original_token_hex = migration.secrets.token_hex
original_verified_target_daemon = migration.verified_target_daemon
probe_calls = []
probe_objects = {"container": None, "image": None}

class ImportResult:
    stdout = ("sha256:" + "b" * 64).encode()

def probe_run(*args, capture=False):
    probe_calls.append(args)
    if len(args) > 1 and args[0] in (migration.SOURCE, migration.TARGET) and args[1] == "run":
        engine = args[0]
        limits = source_nofile if engine == migration.TARGET else None
        probe_objects["container"] = {
            "Id": "c" * 64,
            "Name": f"/omarchy-rootless-docker-nofile-{engine}-" + "d" * 64,
            "Image": "sha256:" + "b" * 64,
            "Path": "/usr/bin/sleep",
            "Args": [str(migration.NOFILE_PROBE_SECONDS)],
            "Config": {
                "Image": "sha256:" + "b" * 64,
                "Entrypoint": ["/usr/bin/sleep"],
                "Cmd": [str(migration.NOFILE_PROBE_SECONDS)],
                "Labels": {migration.NOFILE_PROBE_LABEL: "d" * 64},
            },
            "HostConfig": {
                "AutoRemove": True, "NetworkMode": "none", "ReadonlyRootfs": True,
                "Privileged": False, "CapDrop": ["ALL"],
                "SecurityOpt": ["no-new-privileges"], "Binds": None, "Mounts": None,
                "Ulimits": ([{"Name": "nofile", "Soft": limits["soft"], "Hard": limits["hard"]}]
                            if limits is not None else None),
                "RestartPolicy": {"Name": "no", "MaximumRetryCount": 0},
            },
            "Mounts": [],
            "State": {"Running": True, "Pid": 4242},
        }
        return "c" * 64
    if args[:2] == ("/usr/bin/sudo", "/usr/bin/cat"):
        return "Max open files            65536                524288               files"
    if len(args) > 3 and args[0] in (migration.SOURCE, migration.TARGET) and args[1:4] == ("container", "rm", "-f"):
        probe_objects["container"] = None
    if len(args) > 2 and args[0] in (migration.SOURCE, migration.TARGET) and args[1:3] == ("image", "rm"):
        probe_objects["image"] = None
    return ""

migration.nofile_probe_rootfs = lambda token: b"trusted-rootfs"
def probe_subprocess_run(*args, **kwargs):
    command = args[0]
    tag = command[-1]
    probe_objects["image"] = {
        "Id": "sha256:" + "b" * 64,
        "RepoTags": [tag],
        "RepoDigests": [],
    }
    return ImportResult()

migration.subprocess.run = probe_subprocess_run
migration.run = probe_run
migration.inspect = lambda *args: probe_objects["container"]
migration.docker_inspect_optional = lambda engine, kind, identity: probe_objects[kind]
migration.secrets.token_hex = lambda length: "d" * (length * 2)
migration.verified_target_daemon = lambda identity: (4242, "/proc/4242/root/run/user/1000/docker.sock")
with tempfile.TemporaryDirectory() as directory:
    previous_state_home = os.environ.get("XDG_STATE_HOME")
    os.environ["XDG_STATE_HOME"] = directory
    try:
        assert migration.source_default_nofile() == source_nofile
        migration.validate_target_nofile(source_nofile)
        assert not migration.nofile_probe_path().exists()
    finally:
        if previous_state_home is None:
            os.environ.pop("XDG_STATE_HOME", None)
        else:
            os.environ["XDG_STATE_HOME"] = previous_state_home
        migration.nofile_probe_rootfs = original_probe_rootfs
        migration.subprocess.run = original_subprocess_run
        migration.run = original_run
        migration.inspect = original_inspect
        migration.docker_inspect_optional = original_docker_inspect_optional
        migration.secrets.token_hex = original_token_hex
        migration.verified_target_daemon = original_verified_target_daemon
probe_command = next(call for call in probe_calls if call[:2] == (migration.SOURCE, "run"))
target_probe_command = next(call for call in probe_calls if call[:2] == (migration.TARGET, "run"))
assert "--rm" in probe_command
assert probe_command[-1] == str(migration.NOFILE_PROBE_SECONDS)
assert target_probe_command[target_probe_command.index("--ulimit") + 1] == "nofile=65536:524288"
assert probe_calls[-2][:4] == (migration.TARGET, "container", "rm", "-f")
assert probe_calls[-1][:3] == (migration.TARGET, "image", "rm")
print("ok - source discovery and target compatibility use bounded, journaled nofile probes")

with tempfile.TemporaryDirectory() as directory:
    previous_state_home = os.environ.get("XDG_STATE_HOME")
    os.environ["XDG_STATE_HOME"] = directory
    token = "e" * 64
    record = {
        "engine": migration.SOURCE,
        "token": token,
        "name": migration.NOFILE_PROBE_PREFIX + migration.SOURCE + "-" + token,
        "tag": "omarchy-rootless-docker-nofile-source:" + token,
        "image": "sha256:" + "f" * 64,
        "limits": None,
    }
    migration.write_private_json(migration.nofile_probe_path(), record)
    cleanup_calls = []
    owned_container = {
        "Id": "1" * 64, "Name": "/" + record["name"], "Image": record["image"],
        "Path": "/usr/bin/sleep", "Args": [str(migration.NOFILE_PROBE_SECONDS)],
        "Config": {
            "Image": record["image"], "Entrypoint": ["/usr/bin/sleep"],
            "Cmd": [str(migration.NOFILE_PROBE_SECONDS)],
            "Labels": {migration.NOFILE_PROBE_LABEL: token},
        },
        "HostConfig": {
            "AutoRemove": True, "NetworkMode": "none", "ReadonlyRootfs": True,
            "Privileged": False, "CapDrop": ["ALL"],
            "SecurityOpt": ["no-new-privileges"], "Binds": None, "Mounts": None,
            "RestartPolicy": {"Name": "no", "MaximumRetryCount": 0},
        },
        "Mounts": [],
    }
    owned_image = {
        "Id": record["image"], "RepoTags": [record["tag"]],
        "RepoDigests": [record["tag"].rsplit(":", 1)[0] + "@" + record["image"]],
    }
    objects = {"container": owned_container, "image": owned_image}
    original_run = migration.run
    original_docker_inspect_optional = migration.docker_inspect_optional
    def interrupted_probe_inspect(engine, kind, identity):
        return objects[kind]
    def interrupted_probe_run(*args, capture=False):
        cleanup_calls.append(args)
        if args[:4] == (migration.SOURCE, "container", "rm", "-f"):
            objects["container"] = None
        elif args[:3] == (migration.SOURCE, "image", "rm"):
            objects["image"] = None
        return ""
    migration.docker_inspect_optional = interrupted_probe_inspect
    migration.run = interrupted_probe_run
    try:
        migration.cleanup_nofile_probe()
        assert not migration.nofile_probe_path().exists()
    finally:
        migration.run = original_run
        migration.docker_inspect_optional = original_docker_inspect_optional
        if previous_state_home is None:
            os.environ.pop("XDG_STATE_HOME", None)
        else:
            os.environ["XDG_STATE_HOME"] = previous_state_home
assert cleanup_calls[0][:4] == (migration.SOURCE, "container", "rm", "-f")
assert cleanup_calls[1][:3] == (migration.SOURCE, "image", "rm")
print("ok - the next migration safely removes a journaled interrupted nofile probe")

with tempfile.TemporaryDirectory() as directory:
    previous_state_home = os.environ.get("XDG_STATE_HOME")
    os.environ["XDG_STATE_HOME"] = directory
    migration.write_private_json(migration.nofile_probe_path(), record)
    failed_cleanup_calls = []
    original_run = migration.run
    original_docker_inspect_optional = migration.docker_inspect_optional
    migration.docker_inspect_optional = lambda engine, kind, identity: (
        owned_container if kind == "container" else owned_image
    )
    def failed_probe_run(*args, capture=False):
        failed_cleanup_calls.append(args)
        raise RuntimeError("injected cleanup failure")
    migration.run = failed_probe_run
    try:
        try:
            migration.cleanup_nofile_probe()
        except RuntimeError:
            pass
        else:
            raise AssertionError("failed probe cleanup was accepted")
        assert migration.nofile_probe_path().exists()
    finally:
        migration.run = original_run
        migration.docker_inspect_optional = original_docker_inspect_optional
        if previous_state_home is None:
            os.environ.pop("XDG_STATE_HOME", None)
        else:
            os.environ["XDG_STATE_HOME"] = previous_state_home
assert failed_cleanup_calls[0][:4] == (migration.SOURCE, "container", "rm", "-f")
assert failed_cleanup_calls[1][:3] == (migration.SOURCE, "image", "rm")
print("ok - a container cleanup failure cannot suppress the probe image cleanup attempt")
migration.validate_source_daemon(source_security)
migration.validate_target_daemon(target_security)
for options in (None, [], ["name=rootless"], ["name=userns"], ["name=no-new-privileges"],
                ["name=cgroupns"], ["name=seccomp,profile=builtin"]):
    try:
        migration.validate_source_daemon(options)
    except ValueError:
        pass
    else:
        raise AssertionError(f"unsafe rootful daemon policy passed: {options}")
for options in (None, [], source_security, target_security + ["name=apparmor"],
                ["name=rootless", "name=cgroupns"],
                ["name=rootless", "name=seccomp,profile=builtin"]):
    try:
        migration.validate_target_daemon(options)
    except ValueError:
        pass
    else:
        raise AssertionError(f"destination was not proven rootless: {options}")
runtime = os.environ.get("XDG_RUNTIME_DIR") or f"/run/user/{os.getuid()}"
config_home = str(Path.home() / ".config")
rootlesskit_arguments = [
    "rootlesskit", f"--state-dir={runtime}/dockerd-rootless", *migration.TARGET_ROOTLESSKIT_ARGUMENTS,
]
for configuration, daemon_arguments, rootless_arguments in (
        ({**migration.TARGET_DAEMON_CONFIG, "init": True}, ["dockerd"], rootlesskit_arguments),
        ({**migration.TARGET_DAEMON_CONFIG, "dns": ["203.0.113.53"]}, ["dockerd"], rootlesskit_arguments),
        ({**migration.TARGET_DAEMON_CONFIG, "default-ulimits": {"nofile": {"Soft": 64, "Hard": 64}}}, ["dockerd"], rootlesskit_arguments),
        ({**migration.TARGET_DAEMON_CONFIG, "default-stop-timeout": 321}, ["dockerd"], rootlesskit_arguments),
        (migration.TARGET_DAEMON_CONFIG, ["dockerd", "--init=true"], rootlesskit_arguments),
        (migration.TARGET_DAEMON_CONFIG, ["dockerd"], [*rootlesskit_arguments[:-1], "--ipv6", rootlesskit_arguments[-1]]),
):
    try:
        migration.validate_target_daemon(
            target_security, configuration, daemon_arguments, rootless_arguments, "/usr/bin",
            config_home,
        )
    except ValueError:
        pass
    else:
        raise AssertionError("a hidden rootless daemon workload default passed preflight")
migration.validate_target_daemon(
    target_security, migration.TARGET_DAEMON_CONFIG, ["dockerd"], rootlesskit_arguments, "/usr/bin",
    config_home,
)
try:
    migration.validate_target_daemon(
        target_security, migration.TARGET_DAEMON_CONFIG, ["dockerd"], rootlesskit_arguments,
        "/home/user/.local/bin:/usr/bin",
        config_home,
    )
except ValueError:
    pass
else:
    raise AssertionError("a rootless daemon with a user-writable service PATH passed preflight")
try:
    migration.validate_target_daemon(
        target_security, migration.TARGET_DAEMON_CONFIG, ["dockerd"], rootlesskit_arguments,
        "/usr/bin", "/tmp/custom-docker-config",
    )
except ValueError:
    pass
else:
    raise AssertionError("a rootless daemon with a custom config directory passed preflight")
print("ok - migration pins known daemon confinement and rejects hidden target workload defaults")
# Direct migration unit fixtures replace Docker with an event recorder. The
# daemon-policy parser is covered above and exercised end-to-end in Lab.
migration.validate_target_policy = lambda: None
migration.source_default_nofile = lambda: source_nofile
migration.validate_target_nofile = lambda limits: None

container = {
    "Name": "/project-worker",
    "Id": "a" * 64,
    "State": {"Running": True, "Pid": 5151, "StartedAt": "start", "FinishedAt": "finish"},
    "Config": {
        "Image": "local/project-worker:v1", "Hostname": "worker", "Domainname": "",
        "User": "1000", "Env": ["PRIVATE=not-logged"], "Labels": {"project": "fixture"},
        "Tty": False, "OpenStdin": False, "StopTimeout": 300,
    },
    "HostConfig": {
        "NetworkMode": "bridge", "IpcMode": "private", "ShmSize": 128 * 1024 * 1024,
        "Binds": ["project-data:/data:rw"], "Memory": 128 * 1024 * 1024,
        "MemorySwap": 256 * 1024 * 1024, "PidsLimit": 64, "NanoCpus": 500000000,
        "CapDrop": ["ALL"], "SecurityOpt": ["no-new-privileges"],
        "MaskedPaths": sorted(migration.MASKED_PATHS),
        "ReadonlyPaths": sorted(migration.READONLY_PATHS),
        "Runtime": "runc", "CgroupnsMode": "private", "ConsoleSize": [0, 0],
        "OomScoreAdj": 0, "BlkioWeight": 0, "CpuRealtimePeriod": 0,
        "CpuRealtimeRuntime": 0, "CpuCount": 0, "CpuPercent": 0,
        "IOMaximumIOps": 0, "IOMaximumBandwidth": 0,
        "PortBindings": {"8080/tcp": [{"HostIp": "127.0.0.1", "HostPort": "18080"}]},
        "RestartPolicy": {"Name": "unless-stopped", "MaximumRetryCount": 0},
        "LogConfig": {"Type": "json-file", "Config": {"max-size": "10m", "max-file": "5"}},
    },
    "NetworkSettings": {"Networks": {"bridge": {}}},
    "Mounts": [{"Type": "volume", "Driver": "local", "Name": "project-data",
                "Destination": "/data", "RW": True}],
}
assert migration.validate(container) == "project-worker"
actual_nofile = {"soft": 32768, "hard": 262144}
original_run = migration.run
original_inspect = migration.inspect
migration.run = lambda *args, **kwargs: (
    "Max open files 32768 262144 files" if args[:2] == ("/usr/bin/sudo", "/usr/bin/cat") else None
)
migration.inspect = lambda engine, kind, name: copy.deepcopy(container)
assert migration.container_nofile(container, source_nofile) == actual_nofile
assert migration.source_namespace_path("/proc/5151/limits") == \
    "/proc/4242/root/proc/5151/limits"
migration.run = original_run
migration.inspect = original_inspect
print("ok - running workloads use their live process file limit instead of a new daemon default")
arguments = migration.runtime_arguments(container, source_nofile)
for flag, value in (("--pids-limit=64", None), ("--shm-size", "134217728"),
                    ("--memory", "134217728"), ("--memory-swap", "268435456"),
                    ("--cpus", "0.5"), ("--cap-drop", "ALL")):
    if value is None:
        assert flag in arguments
    else:
        assert arguments[arguments.index(flag) + 1] == value
assert "--cap-add" not in arguments
assert "--init=false" in arguments
assert arguments[arguments.index("--ulimit") + 1] == "nofile=65536:524288"
assert migration.destination_volume(container, container["Mounts"][0]) == "project-data"
unlimited = copy.deepcopy(container)
unlimited["HostConfig"]["PidsLimit"] = 0
assert not any(argument.startswith("--pids-limit=") for argument in migration.runtime_arguments(unlimited, source_nofile))
modern_mount = copy.deepcopy(container)
modern_mount["HostConfig"]["Binds"] = []
modern_mount["HostConfig"]["Mounts"] = [{
    "Type": "volume", "Source": "project-data", "Target": "/data",
    "ReadOnly": False, "VolumeOptions": {"NoCopy": True},
}]
assert migration.validate(modern_mount) == "project-worker"
assert migration.destination_volume(modern_mount, modern_mount["Mounts"][0]) == "project-data"
print("ok - compatible custom workloads retain resources, private volumes, ports and restrictive capabilities")

numeric_root = copy.deepcopy(container)
numeric_root["Config"]["User"] = "00:1000"
numeric_root["HostConfig"]["CapDrop"] = []
assert migration.allowed_capabilities(numeric_root) == migration.DOCKER_CAPABILITIES
non_root_default_caps = copy.deepcopy(container)
non_root_default_caps["HostConfig"]["CapDrop"] = []
try:
    migration.validate(non_root_default_caps)
except ValueError:
    pass
else:
    raise AssertionError("non-root image user with an unreproducible capability ceiling passed")
for named_user in ("root", "daemon", "root:root", "\u0660"):
    changed = copy.deepcopy(container)
    changed["Config"]["User"] = named_user
    try:
        migration.validate(changed)
    except ValueError:
        pass
    else:
        raise AssertionError(f"ambiguous named user passed preflight: {named_user}")
print("ok - numeric UID zero keeps its capabilities and ambiguous named users fail closed")

paused = copy.deepcopy(container)
paused["State"]["Paused"] = True
try:
    migration.validate(paused)
except ValueError:
    pass
else:
    raise AssertionError("a paused source passed automatic lifecycle migration")
exited = copy.deepcopy(container)
exited["State"] = {
    "Status": "exited", "Running": False, "StartedAt": "start", "FinishedAt": "finish", "ExitCode": 7,
}
with tempfile.TemporaryDirectory() as directory:
    os.environ["XDG_STATE_HOME"] = directory
    try:
        migration.validate(exited)
    except ValueError:
        pass
    else:
        raise AssertionError("an exited source with unreproducible state passed automatic migration")
created = copy.deepcopy(exited)
created["State"] = {
    "Status": "created", "Running": False, "StartedAt": "0001-01-01T00:00:00Z",
    "FinishedAt": "0001-01-01T00:00:00Z", "ExitCode": 0,
}
assert migration.validate(created) == "project-worker"
assert migration.target_never_started(created)
ran_target = copy.deepcopy(created)
ran_target["State"] = {
    "Status": "exited", "Running": False, "StartedAt": "target-start",
    "FinishedAt": "target-stop", "ExitCode": 0,
}
assert not migration.target_never_started(ran_target)
print("ok - paused, exited, and unreproducible non-root capability states fail closed")

for stop_timeout in (None, -1, 0, 300):
    changed = copy.deepcopy(container)
    changed["Config"]["StopTimeout"] = stop_timeout
    assert migration.validate(changed) == "project-worker"
for stop_timeout in (True, -2, "300"):
    changed = copy.deepcopy(container)
    changed["Config"]["StopTimeout"] = stop_timeout
    try:
        migration.validate(changed)
    except ValueError:
        pass
    else:
        raise AssertionError(f"unsupported stop timeout passed preflight: {stop_timeout!r}")
print("ok - stop timeouts are type checked and larger application grace periods are retained")

for field, value in (("Labels", {migration.LABEL: "old"}),
                     ("Env", ["DUPLICATE=one", "DUPLICATE=two"])):
    changed = copy.deepcopy(container)
    changed["Config"][field] = value
    try:
        migration.validate(changed)
    except ValueError:
        pass
    else:
        raise AssertionError(f"ambiguous {field} passed preflight")
print("ok - reserved labels and duplicate environment keys fail before transfer")

windows = copy.deepcopy(container)
windows["Name"] = "/omarchy-windows"
windows["Id"] = "f" * 64
windows["Config"]["Image"] = "dockurr/windows"
windows["Config"]["Env"] = ["VERSION=11", "PROTECT=Y"]
windows["Config"]["Labels"] = {
    "com.docker.compose.project": "windows",
    "com.docker.compose.service": "windows",
}
windows["HostConfig"]["Privileged"] = False
windows["HostConfig"]["CapAdd"] = ["NET_ADMIN"]
windows["HostConfig"]["CapDrop"] = []
windows["HostConfig"]["DeviceRequests"] = []
windows["HostConfig"]["DeviceCgroupRules"] = []
windows["HostConfig"]["SecurityOpt"] = []
windows["HostConfig"]["RestartPolicy"] = {"Name": "no", "MaximumRetryCount": 0}
windows["HostConfig"]["NetworkMode"] = "windows_default"
windows["HostConfig"]["Devices"] = [
    {"PathOnHost": "/dev/kvm", "PathInContainer": "/dev/kvm"},
    {"PathOnHost": "/dev/net/tun", "PathInContainer": "/dev/net/tun"},
]
windows["HostConfig"]["PortBindings"] = {
    "8006/tcp": [{"HostIp": "127.0.0.1", "HostPort": "8006"}],
    "3389/tcp": [{"HostIp": "127.0.0.1", "HostPort": "3389"}],
    "3389/udp": [{"HostIp": "127.0.0.1", "HostPort": "3389"}],
}
uid = os.getuid()
windows["Mounts"] = [
    {"Type": "bind", "Source": f"/var/lib/omarchy/windows/mounts/users/{uid}/storage",
     "Destination": "/storage", "RW": True},
    {"Type": "bind", "Source": f"/var/lib/omarchy/windows/mounts/users/{uid}/shared",
     "Destination": "/shared", "RW": True},
]
windows["NetworkSettings"]["Networks"] = {"windows_default": {}}
assert migration.validate_windows_exception(windows) == "omarchy-windows"
legacy_windows = copy.deepcopy(windows)
legacy_windows["Mounts"][0]["Source"] = f"{Path.home()}/.windows"
legacy_windows["Mounts"][1]["Source"] = f"{Path.home()}/Windows"
for mutation in ("image", "labels", "devices", "extra-device", "device-rules", "security-opt",
                 "mounts", "mount-source", "restart", "network-mode", "extra-network", "autoremove",
                 "missing-protect", "duplicate-protect"):
    changed = copy.deepcopy(windows)
    if mutation == "image":
        changed["Config"]["Image"] = "example/custom"
    elif mutation == "labels":
        changed["Config"]["Labels"] = {}
    elif mutation == "devices":
        changed["HostConfig"]["Devices"] = []
    elif mutation == "extra-device":
        changed["HostConfig"]["Devices"].append({"PathOnHost": "/dev/null", "PathInContainer": "/dev/null"})
    elif mutation == "device-rules":
        changed["HostConfig"]["DeviceCgroupRules"] = ["a *:* rwm"]
    elif mutation == "security-opt":
        changed["HostConfig"]["SecurityOpt"] = ["seccomp=unconfined"]
    elif mutation == "mounts":
        changed["Mounts"] = []
    elif mutation == "mount-source":
        changed["Mounts"][0]["Source"] = "/tmp/unmanaged-windows"
    elif mutation == "restart":
        changed["HostConfig"]["RestartPolicy"] = {"Name": "always", "MaximumRetryCount": 0}
    elif mutation == "network-mode":
        changed["HostConfig"]["NetworkMode"] = "host"
    elif mutation == "extra-network":
        changed["NetworkSettings"]["Networks"]["unexpected"] = {}
    elif mutation == "missing-protect":
        changed["Config"]["Env"] = ["VERSION=11"]
    elif mutation == "duplicate-protect":
        changed["Config"]["Env"] += ["PROTECT=N"]
    else:
        changed["HostConfig"]["AutoRemove"] = True
    try:
        migration.validate_windows_exception(changed)
    except ValueError:
        pass
    else:
        raise AssertionError(f"unmanaged Windows exception passed: {mutation}")
try:
    migration.validate_windows_exception(legacy_windows)
except ValueError:
    pass
else:
    raise AssertionError("legacy home-mounted Windows runtime passed the protected exception")
print("ok - only Omarchy's managed Windows runtime qualifies for the rootful exception")

source_volume = {"Name": "project-data", "Driver": "local", "Options": None,
                 "Labels": {"project": "fixture"}, "Mountpoint": "/source-volume"}
sealed_container = copy.deepcopy(container)
sealed_container["State"] = {
    "Status": "created", "Running": False,
    "StartedAt": "0001-01-01T00:00:00Z",
    "FinishedAt": "0001-01-01T00:00:00Z", "ExitCode": 0,
}
sealed_container["HostConfig"]["RestartPolicy"] = {"Name": "no", "MaximumRetryCount": 0}
sealed_digest = ["1" * 64]
original_inspect = migration.inspect
original_source_volume_digest = migration.source_volume_digest
with tempfile.TemporaryDirectory() as directory:
    os.environ["XDG_STATE_HOME"] = directory
    migration.inspect = lambda engine, kind, name: copy.deepcopy(source_volume)
    migration.source_volume_digest = lambda volume: sealed_digest[0]
    sealed_intent = migration.record_migration_intent(sealed_container, source_nofile=source_nofile)
    sealed_intent = migration.seal_quiesced_source_volumes(sealed_container, sealed_intent)
    assert sealed_intent["source_volumes"] == {"project-data": "1" * 64}
    sealed_digest[0] = "2" * 64
    try:
        migration.seal_quiesced_source_volumes(sealed_container, sealed_intent)
    except RuntimeError:
        pass
    else:
        raise AssertionError("a rootful client changed a volume after quiescing without detection")
    sealed_digest[0] = "1" * 64
    seal_order = []
    original_validate_trusted_manifest = migration.validate_trusted_manifest
    original_daemon_security = migration.daemon_security
    original_exists = migration.exists
    migration.validate_trusted_manifest = lambda: seal_order.append("trusted-helper")
    migration.daemon_security = lambda engine: source_security if engine == migration.SOURCE else target_security
    migration.inspect = lambda engine, kind, name: copy.deepcopy(
        sealed_container if kind == "container" else source_volume
    )
    migration.exists = lambda kind, name: False
    migration.source_volume_digest = lambda volume: (seal_order.append("source-digest") or sealed_digest[0])
    sys.argv = ["migrate.py", "--check", sealed_container["Name"].lstrip("/")]
    migration.main()
    assert seal_order[:2] == ["trusted-helper", "source-digest"]
    migration.validate_trusted_manifest = original_validate_trusted_manifest
    migration.daemon_security = original_daemon_security
    migration.exists = original_exists
migration.inspect = original_inspect
migration.source_volume_digest = original_source_volume_digest
print("ok - trusted helper validation precedes quiesced source-volume seal checks")

ownership = migration.volume_identity(container, container["Mounts"][0])
assert ownership != migration.volume_identity(container, container["Mounts"][0])
raced_volume = copy.deepcopy(source_volume)
raced_volume["Labels"] = {"project": "fixture"}
migration.inspect = lambda engine, kind, name: copy.deepcopy(raced_volume)
try:
    migration.verify_volume_definition(source_volume, "project-data", ownership)
except RuntimeError:
    pass
else:
    raise AssertionError("an independently created destination volume was claimed")
owned_volume = copy.deepcopy(source_volume)
owned_volume["Labels"][migration.VOLUME_LABEL] = ownership
migration.inspect = lambda engine, kind, name: copy.deepcopy(owned_volume)
migration.verify_volume_definition(source_volume, "project-data", ownership)
real_run = migration.run
migration.run = lambda *args, **kwargs: "f" * 64
assert migration.volume_users("project-data") == ["f" * 64]
migration.run = lambda *args, **kwargs: "short-id"
try:
    migration.volume_users("project-data")
except RuntimeError:
    pass
else:
    raise AssertionError("an ambiguous destination-volume attachment passed validation")
real_verify_event_marker = migration.verify_volume_event_marker
migration.verify_volume_event_marker = lambda source, intent: None
migration.run = lambda *args, **kwargs: "\n".join((
    json.dumps({"Type": "volume", "Action": "create", "Actor": {
        "ID": "marker", "Attributes": {"driver": "local"}}}),
    json.dumps({"Type": "volume", "Action": "mount", "Actor": {
        "ID": "project-data", "Attributes": {"container": "e" * 64}}}),
))
try:
    migration.verify_volume_event_window(
        container, {"target_ownership": "d" * 64,
                    "volume_event": {"name": "marker", "since": "time"}},
        {"name": "marker", "since": "time"}, {"project-data"}, "f" * 64,
    )
except RuntimeError:
    pass
else:
    raise AssertionError("a transient destination-volume writer escaped event validation")
migration.run = lambda *args, **kwargs: "\n".join((
    json.dumps({"Type": "volume", "Action": "create", "Actor": {
        "ID": "marker", "Attributes": {"driver": "local"}}}),
    json.dumps({"Type": "volume", "Action": "mount", "Actor": {
        "ID": "project-data", "Attributes": {"container": "f" * 64}}}),
))
migration.verify_volume_event_window(
    container, {"target_ownership": "d" * 64,
                "volume_event": {"name": "marker", "since": "time"}},
    {"name": "marker", "since": "time"}, {"project-data"}, "f" * 64,
)
migration.run = real_run
migration.verify_volume_event_marker = real_verify_event_marker
print("ok - volume event windows reject transient writers and require the intended mount")

journal_event_source = {"Id": "b" * 64, "Name": "/journal-event-window"}
journal_event_intent = {"target_ownership": "a" * 64, "volume_event": None, "volumes": {}}
original_event_exists = migration.exists
original_event_run = migration.run
original_event_verify_marker = migration.verify_volume_event_marker
with tempfile.TemporaryDirectory() as directory:
    os.environ["XDG_STATE_HOME"] = directory
    migration.exists = lambda kind, name: False
    migration.verify_volume_event_marker = lambda source, intent: None

    def create_journaled_marker(*args, **kwargs):
        saved = json.loads(migration.intent_path(journal_event_source["Id"]).read_text())
        assert saved["volume_event"]["name"] == migration.volume_event_marker_name(saved)
        assert saved["volumes"] == {}

    migration.run = create_journaled_marker
    journal_event_intent = migration.ensure_volume_event_window(
        journal_event_source, journal_event_intent, {"journal-event-data"},
    )
    saved_event_intent = json.loads(migration.intent_path(journal_event_source["Id"]).read_text())
    assert saved_event_intent["volume_event"] == journal_event_intent["volume_event"]
    missing_marker_intent = copy.deepcopy(journal_event_intent)
    missing_marker_intent["volumes"]["journal-event-data"] = {
        "source": "source-data", "ownership": "owned",
    }
    try:
        migration.ensure_volume_event_window(
            journal_event_source, missing_marker_intent, {"journal-event-data"},
        )
    except RuntimeError as error:
        assert "marker disappeared" in str(error)
    else:
        raise AssertionError("a missing marker with a retained destination volume was recreated")
migration.exists = original_event_exists
migration.run = original_event_run
migration.verify_volume_event_marker = original_event_verify_marker
print("ok - event windows are durable before volume creation and missing retained markers fail closed")

retry_event_source = copy.deepcopy(container)
retry_event_source["Id"] = "c" * 64
retry_event_source["Name"] = "/retained-event-window"
retry_order = []
original_retry_inspect = migration.inspect
original_retry_exists = migration.exists
original_retry_verify_window = migration.verify_volume_event_window
original_retry_remove_guard = migration.remove_volume_guard
with tempfile.TemporaryDirectory() as directory:
    os.environ["XDG_STATE_HOME"] = directory
    retry_event_intent = migration.record_migration_intent(
        retry_event_source, source_nofile={"soft": 1024, "hard": 4096},
    )
    retry_target = migration.destination_volume(retry_event_source, retry_event_source["Mounts"][0])
    retry_event_intent["volumes"][retry_target] = {
        "source": retry_event_source["Mounts"][0]["Name"],
        "ownership": migration.volume_identity(retry_event_source, retry_event_source["Mounts"][0]),
    }
    retry_event_intent["volume_event"] = {
        "name": migration.volume_event_marker_name(retry_event_intent),
        "since": "2026-09-12T00:00:00Z",
    }
    migration.persist_migration_intent(retry_event_source, retry_event_intent)
    migration.inspect = lambda engine, kind, name: copy.deepcopy(retry_event_source)
    migration.exists = lambda kind, name: False

    def reject_retry_event(source, intent, window, targets, allowed=None):
        retry_order.append("verify-history")
        raise RuntimeError("another container accessed a retained destination volume")

    migration.verify_volume_event_window = reject_retry_event
    migration.remove_volume_guard = lambda source, intent: retry_order.append("remove-guard")
    try:
        migration.migrate(retry_event_source, {"soft": 1024, "hard": 4096})
    except RuntimeError as error:
        assert "another container accessed" in str(error)
    else:
        raise AssertionError("a retained destination volume mount between retries was missed")
    assert retry_order == ["verify-history"]
migration.inspect = original_retry_inspect
migration.exists = original_retry_exists
migration.verify_volume_event_window = original_retry_verify_window
migration.remove_volume_guard = original_retry_remove_guard
print("ok - retained volume event history is checked before retry cleanup")

retire_source = copy.deepcopy(container)
retire_source["Id"] = "1" * 64
retire_source["Name"] = "/retire-event-window"
original_retire_marker = migration.remove_volume_event_marker
with tempfile.TemporaryDirectory() as directory:
    os.environ["XDG_STATE_HOME"] = directory
    retire_intent = migration.record_migration_intent(
        retire_source, source_nofile={"soft": 1024, "hard": 4096},
    )
    retire_intent["volume_event"] = {
        "name": migration.volume_event_marker_name(retire_intent),
        "since": "2026-09-12T00:00:00Z",
    }
    retire_intent["volumes"]["retired-data"] = {
        "source": "source-data", "ownership": "owned",
    }
    migration.persist_migration_intent(retire_source, retire_intent)

    def interrupt_after_marker_removal(source, intent):
        raise KeyboardInterrupt

    migration.remove_volume_event_marker = interrupt_after_marker_removal
    try:
        migration.retire_volume_event_window(retire_source, retire_intent, volumes_absent=True)
    except KeyboardInterrupt:
        pass
    else:
        raise AssertionError("event retirement interruption was not injected")
    retired = migration.migration_intent(retire_source)
    assert retired["volume_event"] is None and retired["volumes"] == {}
    migration.remove_volume_event_marker = lambda source, intent: None
    retired = migration.retire_volume_event_window(retire_source, retired, volumes_absent=True)
    migration.clear_migration_intent(retire_source["Id"])
    assert not migration.intent_path(retire_source["Id"]).exists()
migration.remove_volume_event_marker = original_retire_marker
print("ok - absent retained volumes are durably retired before event-marker removal")

restore_retire_source = copy.deepcopy(container)
restore_retire_source["Id"] = "2" * 64
restore_retire_source["Name"] = "/restore-retire-event-window"
original_restore_inspect = migration.inspect
original_restore_remove_marker = migration.remove_volume_event_marker
original_restore_clear_intent = migration.clear_migration_intent
with tempfile.TemporaryDirectory() as directory:
    os.environ["XDG_STATE_HOME"] = directory
    restore_retire_intent = migration.record_migration_intent(
        restore_retire_source, source_nofile={"soft": 1024, "hard": 4096},
    )
    restore_retire_intent["volume_event"] = {
        "name": migration.volume_event_marker_name(restore_retire_intent),
        "since": "2026-09-12T00:00:00Z",
    }
    migration.persist_migration_intent(restore_retire_source, restore_retire_intent)
    migration.inspect = lambda engine, kind, name: copy.deepcopy(restore_retire_source)
    marker_removals = []
    migration.remove_volume_event_marker = lambda source, intent: marker_removals.append(intent["volume_event"])

    def interrupt_intent_clear(identity):
        raise KeyboardInterrupt

    migration.clear_migration_intent = interrupt_intent_clear
    try:
        migration.restore_source(restore_retire_source["Id"])
    except KeyboardInterrupt:
        pass
    else:
        raise AssertionError("restored-source cleanup interruption was not injected")
    restored_retired = migration.migration_intent(restore_retire_source)
    assert restored_retired["volume_event"] is None and restored_retired["volumes"] == {}
    migration.clear_migration_intent = original_restore_clear_intent
    migration.restore_source(restore_retire_source["Id"])
    assert not migration.intent_path(restore_retire_source["Id"]).exists()
    assert marker_removals == [None, None]
migration.inspect = original_restore_inspect
migration.remove_volume_event_marker = original_restore_remove_marker
migration.clear_migration_intent = original_restore_clear_intent
print("ok - restored-source event cleanup resumes after marker removal interruption")
reserved_source = copy.deepcopy(source_volume)
reserved_source["Labels"][migration.VOLUME_LABEL] = "foreign"
try:
    migration.validate_source_volume(container, reserved_source)
except ValueError:
    pass
else:
    raise AssertionError("a source volume with the migration ownership label was accepted")
print("ok - destination volumes require unpredictable ownership and no attachments before cleanup")

blocked = (
    ("Privileged", True), ("CapAdd", ["SYS_ADMIN"]),
    ("Devices", [{"PathOnHost": "/dev/kvm"}]),
    ("DeviceRequests", [{"Driver": "nvidia"}]),
    ("DeviceCgroupRules", ["a *:* rwm"]), ("NetworkMode", "host"),
    ("Runtime", "nvidia"), ("CgroupnsMode", "host"),
    ("SecurityOpt", ["seccomp=unconfined"]),
    ("Binds", ["/home/example/project:/data:rw"]),
    ("Mounts", [{"Type": "bind", "Source": "/home/example", "Target": "/data"}]),
    ("MemorySwappiness", 0),
    ("FutureNumericOption", 0),
    ("FuturePrivilegeOption", {"enabled": True}),
)
for field, value in blocked:
    changed = copy.deepcopy(container)
    changed["HostConfig"][field] = value
    try:
        migration.validate(changed)
    except ValueError:
        pass
    else:
        raise AssertionError(f"unsupported {field} passed preflight")
for networks in ({"bridge": {}, "project": {}}, {"project": {}}, {}):
    changed = copy.deepcopy(container)
    changed["NetworkSettings"]["Networks"] = networks
    try:
        migration.validate(changed)
    except ValueError:
        pass
    else:
        raise AssertionError(f"unsupported networks passed: {networks}")
print("ok - privileged, device, host-path, custom-network and unknown settings fail closed")

records = {}
for index, field in enumerate(("Privileged", "Runtime"), 1):
    changed = copy.deepcopy(container)
    changed["Name"] = f"/blocked-{index}"
    changed["Id"] = str(index) * 64
    changed["HostConfig"][field] = True if field == "Privileged" else "nvidia"
    records[changed["Name"].lstrip("/")] = changed
migration.daemon_security = lambda engine: source_security if engine == migration.SOURCE else target_security
migration.inspect = lambda engine, kind, name: records[name]
migration.run = lambda *args, **kwargs: (_ for _ in ()).throw(AssertionError("preflight changed a workload"))
sys.argv = ["migrate.py", "--check", *records]
try:
    migration.main()
except ValueError as error:
    message = str(error)
    assert all(name in message for name in records)
    assert "PRIVATE" not in message and "not-logged" not in message
else:
    raise AssertionError("blocked batch passed preflight")
print("ok - complete-batch preflight reports every blocker without exposing container secrets")

stopped = copy.deepcopy(container)
stopped["State"] = {"Running": False, "StartedAt": "start", "FinishedAt": "finish", "ExitCode": 0}
stopped["HostConfig"]["RestartPolicy"] = {"Name": "no", "MaximumRetryCount": 0}
target = copy.deepcopy(stopped)
target["Id"] = "b" * 64
target["Config"]["Labels"][migration.LABEL] = stopped["Id"]
target["State"] = {
    "Status": "created", "Running": False, "StartedAt": "0001-01-01T00:00:00Z",
    "FinishedAt": "0001-01-01T00:00:00Z", "ExitCode": 0,
}
with tempfile.TemporaryDirectory() as directory:
    os.environ["XDG_STATE_HOME"] = directory
    migration.inspect = lambda engine, kind, name: copy.deepcopy(stopped if engine == migration.SOURCE else target)
    migration.record_completion(stopped, stopped["State"], False, target)
    assert migration.validate(stopped) == "project-worker"
    assert migration.completed(stopped, target)
    stopped["RestartCount"] = 4
    stopped["NetworkSettings"]["SandboxID"] = "changed-by-daemon-restart"
    target["RestartCount"] = 2
    target["State"]["StartedAt"] = "later-start"
    target["NetworkSettings"]["Networks"]["bridge"]["EndpointID"] = "later-endpoint"
    assert migration.completed(stopped, target)
    changed = copy.deepcopy(stopped)
    changed["Config"]["Hostname"] = "changed-after-transfer"
    assert not migration.completed(changed, target)
    target["State"]["Running"] = True
    assert not migration.completed(stopped, target)
print("ok - completion receipts bind both immutable workload snapshots and lifecycle state")

receipt_source = copy.deepcopy(stopped)
receipt_target = copy.deepcopy(target)
receipt_target["State"] = {
    "Status": "created", "Running": False, "StartedAt": "0001-01-01T00:00:00Z",
    "FinishedAt": "0001-01-01T00:00:00Z", "ExitCode": 0,
}
verified_receipt_target = copy.deepcopy(receipt_target)
receipt_target["HostConfig"]["RestartPolicy"] = {"Name": "always", "MaximumRetryCount": 0}
with tempfile.TemporaryDirectory() as directory:
    os.environ["XDG_STATE_HOME"] = directory
    migration.inspect = lambda engine, kind, name: copy.deepcopy(
        receipt_source if engine == migration.SOURCE else receipt_target
    )
    try:
        migration.record_completion(
            receipt_source, receipt_source["State"], False, verified_receipt_target,
        )
    except RuntimeError as error:
        assert "destination changed before completion" in str(error)
    else:
        raise AssertionError("a destination changed after runtime verification received a completion receipt")
    assert not migration.completion_path(receipt_source["Id"]).exists()
print("ok - completion re-inspects the exact verified destination before publishing its receipt")

with tempfile.TemporaryDirectory() as directory:
    os.environ["XDG_STATE_HOME"] = directory
    overlap_original = copy.deepcopy(container)
    overlap_original["Mounts"] = []
    overlap_original["HostConfig"]["Binds"] = []
    overlap_source = copy.deepcopy(overlap_original)
    overlap_source["State"] = {
        "Status": "exited", "Running": False, "StartedAt": "start",
        "FinishedAt": "completed-stop", "ExitCode": 0,
    }
    overlap_source["HostConfig"]["RestartPolicy"] = {"Name": "no", "MaximumRetryCount": 0}
    overlap_target = copy.deepcopy(overlap_original)
    overlap_target["Id"] = "b" * 64
    overlap_target["Config"]["Labels"][migration.LABEL] = overlap_source["Id"]
    overlap_target["State"] = {
        "Status": "running", "Running": True, "StartedAt": "target-start",
        "FinishedAt": "0001-01-01T00:00:00Z", "ExitCode": 0,
    }
    overlap_intent = migration.record_migration_intent(overlap_original, source_nofile=source_nofile)
    overlap_intent = migration.record_migration_intent(
        overlap_source, overlap_source["State"], overlap_intent, restart_disabled=True,
    )
    overlap_intent["start_attempted"] = True
    migration.persist_migration_intent(overlap_source, overlap_intent)
    migration.inspect = lambda engine, kind, name: copy.deepcopy(
        overlap_source if engine == migration.SOURCE else overlap_target
    )
    migration.record_completion(overlap_source, overlap_source["State"], True, overlap_target)
    migration.exists = lambda kind, name: kind == "container" and name == "project-worker"
    migration.migrate(overlap_source, source_nofile)
    assert not migration.intent_path(overlap_source["Id"]).exists()

    migration.persist_migration_intent(overlap_source, overlap_intent)
    migration.daemon_security = lambda engine: source_security if engine == migration.SOURCE else target_security
    sys.argv = ["migrate.py", "--check", overlap_source["Name"].lstrip("/")]
    migration.main()
    assert migration.intent_path(overlap_source["Id"]).exists()
    sys.argv = ["migrate.py", "--quiesce-all", "-", overlap_source["Name"].lstrip("/")]
    migration.main()
    assert not migration.intent_path(overlap_source["Id"]).exists()
print("ok - a valid completion receipt clears its stale journal in check, transfer, and quiesce phases")

restarted = copy.deepcopy(stopped)
restarted["State"]["Running"] = True
migration.inspect = lambda engine, kind, name: copy.deepcopy(restarted if engine == migration.SOURCE else target)
try:
    migration.record_completion(stopped, stopped["State"], False, target)
except ValueError:
    pass
else:
    raise AssertionError("a restarted source received a completion receipt")
print("ok - completion re-inspects the source and refuses a stale stopped state")

intent_source = copy.deepcopy(container)
intent_source["Mounts"] = []
intent_source["HostConfig"]["Binds"] = []
with tempfile.TemporaryDirectory() as directory:
    os.environ["XDG_STATE_HOME"] = directory
    intent = migration.record_migration_intent(intent_source, source_nofile=source_nofile)
    assert migration.migration_intent(intent_source) == intent
    stopped_intent_source = copy.deepcopy(intent_source)
    stopped_intent_source["State"] = {
        "Running": False, "StartedAt": "start", "FinishedAt": "stopped", "ExitCode": 0,
    }
    intent = migration.record_migration_intent(stopped_intent_source, stopped_intent_source["State"], intent)
    intent = migration.record_migration_intent(stopped_intent_source, stopped_intent_source["State"], intent,
                                               restart_disabled=True)
    disabled_source = copy.deepcopy(stopped_intent_source)
    disabled_source["HostConfig"]["RestartPolicy"] = {"Name": "no", "MaximumRetryCount": 0}
    loaded = migration.migration_intent(disabled_source)
    restored_plan = migration.planned_source(disabled_source, loaded)
    assert restored_plan["HostConfig"]["RestartPolicy"] == intent_source["HostConfig"]["RestartPolicy"]
    assert migration.snapshot_digest(restored_plan) == migration.snapshot_digest(stopped_intent_source)
    changed = copy.deepcopy(disabled_source)
    changed["Config"]["Hostname"] = "changed-during-interruption"
    try:
        migration.migration_intent(changed)
    except ValueError:
        pass
    else:
        raise AssertionError("interrupted source configuration drift was accepted")
    assert migration.intent_path(intent_source["Id"]).stat().st_mode & 0o777 == 0o600
print("ok - durable migration intent restores lifecycle and restart policy after interruption")

quiesce_source = copy.deepcopy(intent_source)
quiesce_calls = []
restore_markers = []

def quiesce_inspect(engine, kind, name):
    return copy.deepcopy(quiesce_source)

def quiesce_run(*args, **kwargs):
    quiesce_calls.append(args)
    if args[:2] == (migration.SOURCE, "stop"):
        quiesce_source["State"] = {
            "Running": False, "StartedAt": "start", "FinishedAt": "quiesced", "ExitCode": 0,
        }
    elif args[:2] == (migration.SOURCE, "update"):
        value = args[2].split("=", 1)[1]
        if value != "no":
            restore_markers.append(migration.migration_intent(quiesce_source)["restore_started"])
        quiesce_source["HostConfig"]["RestartPolicy"] = {
            "Name": value, "MaximumRetryCount": 0,
        }
    elif args[:2] == (migration.SOURCE, "start"):
        quiesce_source["State"]["Running"] = True
        quiesce_source["State"]["StartedAt"] = "restored"

with tempfile.TemporaryDirectory() as directory:
    os.environ["XDG_STATE_HOME"] = directory
    migration.inspect = quiesce_inspect
    migration.run = quiesce_run
    migration.quiesce(quiesce_source, source_nofile)
    quiesced_intent = migration.migration_intent(quiesce_source)
    assert quiesced_intent["target_running"] is True
    assert quiesced_intent["restart_disabled"] is True
    assert (migration.SOURCE, "stop", "-t", "300", quiesce_source["Id"]) in quiesce_calls
    assert (migration.SOURCE, "update", "--restart=no", quiesce_source["Id"]) in quiesce_calls
    assert quiesce_calls.index((migration.SOURCE, "update", "--restart=no", quiesce_source["Id"])) < \
        quiesce_calls.index((migration.SOURCE, "stop", "-t", "300", quiesce_source["Id"]))
    migration.restore_source(quiesce_source["Id"])
    assert quiesce_source["State"]["Running"] is True
    assert quiesce_source["HostConfig"]["RestartPolicy"]["Name"] == "unless-stopped"
    assert restore_markers == [True]
    assert not migration.intent_path(quiesce_source["Id"]).exists()
print("ok - batch quiesce durably disables restart and restores the exact source lifecycle")

with tempfile.TemporaryDirectory() as directory:
    os.environ["XDG_STATE_HOME"] = directory
    power_intent = migration.record_migration_intent(intent_source, source_nofile=source_nofile)
    power_intent = migration.record_migration_intent(intent_source, saved=power_intent,
                                                     restart_disabled=True)
    power_intent["quiesce_started"] = True
    migration.persist_migration_intent(intent_source, power_intent)
    restarted_before_update = copy.deepcopy(intent_source)
    restarted_before_update["State"]["StartedAt"] = "restarted-after-power-loss"
    assert migration.migration_intent(restarted_before_update) == power_intent
print("ok - restart-disable intent recovers a daemon restart before Docker applies the update")

with tempfile.TemporaryDirectory() as directory:
    os.environ["XDG_STATE_HOME"] = directory
    always_source = copy.deepcopy(intent_source)
    always_source["HostConfig"]["RestartPolicy"] = {"Name": "always", "MaximumRetryCount": 0}
    always_intent = migration.record_migration_intent(always_source, source_nofile=source_nofile)
    always_stopped = copy.deepcopy(always_source)
    always_stopped["State"] = {
        "Running": False, "StartedAt": "start", "FinishedAt": "restore-window", "ExitCode": 0,
    }
    always_stopped["HostConfig"]["RestartPolicy"] = {"Name": "no", "MaximumRetryCount": 0}
    always_intent = migration.record_migration_intent(always_stopped, always_stopped["State"],
                                                      always_intent, restart_disabled=True)
    always_intent["restore_started"] = True
    migration.persist_migration_intent(always_stopped, always_intent)
    restarted_during_restore = copy.deepcopy(always_source)
    restarted_during_restore["State"]["StartedAt"] = "daemon-restart-during-restore"
    assert migration.migration_intent(restarted_during_restore) == always_intent
print("ok - durable restore intent recognizes an always source restarted after policy restoration")

quiesce_source = copy.deepcopy(intent_source)
quiesce_calls = []
with tempfile.TemporaryDirectory() as directory:
    os.environ["XDG_STATE_HOME"] = directory
    migration.quiesce(quiesce_source, source_nofile)
    artifact_intent = migration.migration_intent(quiesce_source)
    artifact_intent["volumes"]["retained-data"] = {
        "source": "source-data", "ownership": f'{quiesce_source["Id"]}:source-data:{"e" * 64}',
    }
    migration.persist_migration_intent(quiesce_source, artifact_intent)
    migration.restore_source(quiesce_source["Id"])
    assert quiesce_source["State"]["Running"] is True
    assert migration.intent_path(quiesce_source["Id"]).exists()
    assert migration.migration_intent(quiesce_source)["volumes"] == artifact_intent["volumes"]
print("ok - batch recovery retains ownership journals for interrupted destination artifacts")

transfer_source = copy.deepcopy(container)
transfer_source["Id"] = "2" * 64
transfer_source["Name"] = "/interrupted-image-transfer"
transfer_source["Mounts"] = []
transfer_source["HostConfig"]["Binds"] = []
transfer_image_id = "sha256:" + "3" * 64
transfer_cleanup_calls = []
original_run = migration.run
original_docker_inspect_optional = migration.docker_inspect_optional
with tempfile.TemporaryDirectory() as directory:
    os.environ["XDG_STATE_HOME"] = directory
    transfer_intent = migration.record_migration_intent(
        transfer_source, source_nofile=source_nofile,
    )
    transfer_tag = f'omarchy-rootless-docker-transfer:{transfer_intent["target_ownership"]}'
    transfer_intent["image"] = {
        "tag": transfer_tag, "source": transfer_image_id, "target": transfer_image_id,
        "target_preexisting": False,
    }
    migration.persist_migration_intent(transfer_source, transfer_intent)
    transfer_images = {
        migration.SOURCE: {
            "Id": transfer_image_id, "RepoTags": [transfer_tag], "RepoDigests": [],
        },
        migration.TARGET: {
            "Id": transfer_image_id, "RepoTags": [transfer_tag], "RepoDigests": [],
        },
    }

    def transfer_inspect_optional(engine, kind, identity):
        image = transfer_images[engine]
        if image is None or identity not in (image["Id"], *(image.get("RepoTags") or [])):
            return None
        return copy.deepcopy(image)

    def transfer_cleanup_run(*args, capture=False):
        transfer_cleanup_calls.append(args)
        if args[1:3] == ("image", "rm"):
            transfer_images[args[0]] = None
        return ""

    migration.docker_inspect_optional = transfer_inspect_optional
    migration.run = transfer_cleanup_run
    recovered_intent = migration.migration_intent(transfer_source)
    migration.cleanup_transfer_images(transfer_source, recovered_intent)
    assert transfer_cleanup_calls == [
        (migration.TARGET, "image", "rm", transfer_tag),
        (migration.SOURCE, "image", "rm", transfer_tag),
    ]
    assert migration.migration_intent(transfer_source)["image"] is None
migration.run = original_run
migration.docker_inspect_optional = original_docker_inspect_optional
print("ok - a fresh process removes both journal-owned image copies after interrupted load")


def exercise_failed_transfer(after_start, mutate_source=False, preexisting_image=False,
                             replace_target=False, completed_cleanup_failure=False,
                             wrong_loaded_image=False, completion_signal_window=False):
    original_release_transfer_image = migration.release_transfer_image
    source = copy.deepcopy(container)
    source["Id"] = ("d" if after_start else "c") * 64
    source["Name"] = "/post-start" if after_start else "/pre-start"
    source["Mounts"] = []
    source["HostConfig"]["Binds"] = []
    if completed_cleanup_failure or completion_signal_window:
        source["State"] = {
            "Status": "created", "Running": False, "Pid": 0,
            "StartedAt": "0001-01-01T00:00:00Z",
            "FinishedAt": "0001-01-01T00:00:00Z", "ExitCode": 0,
        }
    current_source = copy.deepcopy(source)
    current_target = None
    image_id = "sha256:" + ("f" if after_start else "e") * 64
    transfer_tag = None
    source_image = None
    target_image = ({"Id": image_id, "RepoTags": ["existing/project:v1"], "RepoDigests": []}
                    if preexisting_image else None)
    calls = []
    pipes = []

    def fake_inspect(engine, kind, name):
        if kind == "image":
            image = source_image if engine == migration.SOURCE else target_image
            if image is None or name not in (image["Id"], *(image.get("RepoTags") or [])):
                raise migration.subprocess.CalledProcessError(1, ["docker", "inspect"])
            return copy.deepcopy(image)
        if engine == migration.SOURCE:
            return copy.deepcopy(current_source)
        if current_target is None:
            raise migration.subprocess.CalledProcessError(1, ["docker", "inspect"])
        return copy.deepcopy(current_target)

    def fake_run(*args, **kwargs):
        nonlocal current_target, source_image, target_image, transfer_tag
        calls.append(args)
        if args[:2] == (migration.SOURCE, "stop"):
            if current_source["State"]["Running"]:
                current_source["State"] = {
                    "Running": False, "StartedAt": "start", "FinishedAt": "finish", "ExitCode": 0,
                }
            if mutate_source:
                current_source["HostConfig"]["Memory"] += 4096
        elif args[:2] == (migration.SOURCE, "update"):
            value = args[2].split("=", 1)[1]
            policy, _, retry_count = value.partition(":")
            current_source["HostConfig"]["RestartPolicy"] = {
                "Name": policy, "MaximumRetryCount": int(retry_count or 0),
            }
        elif args[:2] == (migration.SOURCE, "start"):
            current_source["State"]["Running"] = True
        elif args[:2] == (migration.SOURCE, "commit"):
            pending = migration.migration_intent(current_source)["image"]
            transfer_tag = args[3]
            assert pending == {
                "tag": transfer_tag, "source": None, "target": None,
                "target_preexisting": None,
            }
            source_image = {"Id": image_id, "RepoTags": [transfer_tag], "RepoDigests": []}
            return image_id
        elif args[:3] == (migration.SOURCE, "image", "rm"):
            source_image = None
        elif args[:3] == (migration.TARGET, "image", "rm"):
            if current_target is not None and target_image is not None and args[3] == transfer_tag:
                target_image["RepoTags"] = []
            else:
                target_image = None
        elif args[:2] == (migration.TARGET, "create"):
            labels = {}
            for index, argument in enumerate(args):
                if argument == "--label":
                    key, value = args[index + 1].split("=", 1)
                    labels[key] = value
            current_target = {"Id": "b" * 64, "Image": image_id,
                              "Config": {"Labels": labels, "Image": (
                                  image_id if preexisting_image else transfer_tag)},
                              "State": {"Status": "created", "Running": False,
                                        "StartedAt": "0001-01-01T00:00:00Z",
                                        "FinishedAt": "0001-01-01T00:00:00Z"}}
        elif args[:3] == (migration.TARGET, "rm", "--force"):
            current_target = None
        elif args[:2] == (migration.TARGET, "start"):
            current_target["State"]["Running"] = True

    migration.inspect = fake_inspect
    migration.run = fake_run
    migration.exists = lambda kind, name: (
        (kind == "container" and current_target is not None and
         name in (current_target.get("Id"), current_target.get("Name", "").lstrip("/"))) or
        (kind == "image" and target_image is not None and
         name in (target_image["Id"], *(target_image.get("RepoTags") or [])))
    )
    def fake_pipe(producer, consumer):
        nonlocal target_image
        pipes.append((producer, consumer))
        loaded_id = "sha256:" + "7" * 64 if wrong_loaded_image else image_id
        target_image = {"Id": loaded_id, "RepoTags": [transfer_tag], "RepoDigests": []}
    migration.pipe = fake_pipe
    def fake_inspect_optional(engine, kind, name):
        try:
            return fake_inspect(engine, kind, name)
        except migration.subprocess.CalledProcessError:
            return None
    migration.docker_inspect_optional = fake_inspect_optional
    if after_start or completed_cleanup_failure or completion_signal_window:
        migration.verify_runtime = lambda value, ownership=None, source_nofile=None: copy.deepcopy(current_target)
    else:
        def fail_verification(value, ownership=None, source_nofile=None):
            nonlocal current_target
            if replace_target:
                current_target = {"Id": "6" * 64, "Config": {"Labels": {}},
                                  "State": {"Running": False}}
            raise RuntimeError("verification failed")
        migration.verify_runtime = fail_verification
    if completed_cleanup_failure:
        migration.record_completion = lambda source, state, running, verified: None
        migration.release_transfer_image = lambda source, intent: (_ for _ in ()).throw(
            RuntimeError("journal cleanup failed")
        )
    elif completion_signal_window:
        def publish_then_interrupt(source, state, running, verified):
            migration.write_private_json(migration.completion_path(source["Id"]), {"durable": True})
            raise KeyboardInterrupt
        migration.record_completion = publish_then_interrupt
    else:
        migration.record_completion = lambda source, state, running, verified: (_ for _ in ()).throw(RuntimeError("receipt failed"))

    with tempfile.TemporaryDirectory() as directory:
        os.environ["XDG_STATE_HOME"] = directory
        try:
            migration.migrate(source, source_nofile)
        except (RuntimeError, KeyboardInterrupt):
            pass
        else:
            raise AssertionError("failed transfer was reported as complete")
        intent_retained = migration.intent_path(source["Id"]).exists()
    migration.release_transfer_image = original_release_transfer_image
    return calls, current_source, pipes, intent_retained


calls, source, pipes, intent_retained = exercise_failed_transfer(False)
create_call = next(call for call in calls if call[:2] == (migration.TARGET, "create"))
assert create_call[create_call.index("--runtime") + 1] == "runc"
assert len(pipes) == 1 and pipes[0][0][-1].startswith("omarchy-rootless-docker-transfer:")
assert (migration.TARGET, "rm", "--force", "b" * 64) in calls
assert any(call[:3] == (migration.TARGET, "image", "rm") and
           call[3].startswith("omarchy-rootless-docker-transfer:") for call in calls)
assert (migration.SOURCE, "stop", "-t", "300", "c" * 64) in calls
assert (migration.SOURCE, "start", "c" * 64) in calls
assert source["State"]["Running"]
assert not intent_retained
print("ok - verification failure before first start removes the destination and restores the source")

calls, source, pipes, intent_retained = exercise_failed_transfer(False, mutate_source=True)
assert not any(call[:2] == (migration.SOURCE, "commit") for call in calls)
assert (migration.SOURCE, "start", "c" * 64) in calls
assert source["State"]["Running"]
assert intent_retained
print("ok - source configuration changes during stop abort before image transfer")

calls, source, pipes, intent_retained = exercise_failed_transfer(True)
assert (migration.TARGET, "start", "post-start") in calls
assert not any(call[:2] == (migration.TARGET, "rm") for call in calls)
assert not any(call[:3] == (migration.TARGET, "image", "rm") for call in calls)
assert not any(call[:2] == (migration.SOURCE, "start") for call in calls)
assert source["HostConfig"]["RestartPolicy"]["Name"] == "no"
assert not source["State"]["Running"]
assert intent_retained
print("ok - any destination start attempt retains both copies and keeps the source stopped")

calls, source, pipes, intent_retained = exercise_failed_transfer(False, preexisting_image=True)
assert not pipes
assert not any(call[:3] == (migration.TARGET, "image", "rm") for call in calls)
assert any(call[:3] == (migration.SOURCE, "image", "rm") and
           call[3].startswith("omarchy-rootless-docker-transfer:") for call in calls)
print("ok - a preexisting target image digest is reused without claiming or deleting it")

calls, source, pipes, intent_retained = exercise_failed_transfer(False, replace_target=True)
assert not any(call[:3] == (migration.TARGET, "rm", "--force") for call in calls)
assert not source["State"]["Running"]
assert intent_retained
print("ok - a concurrently replaced destination is retained without restarting its rootful source")

calls, source, pipes, intent_retained = exercise_failed_transfer(False, wrong_loaded_image=True)
assert len(pipes) == 1
assert not any(call[:2] == (migration.TARGET, "create") for call in calls)
assert (migration.SOURCE, "start", "c" * 64) in calls
print("ok - a loaded transfer tag must resolve to the committed source image ID")

calls, source, pipes, intent_retained = exercise_failed_transfer(
    False, completed_cleanup_failure=True,
)
assert not any(call[:3] == (migration.TARGET, "rm", "--force") for call in calls)
assert not any(call[:2] == (migration.SOURCE, "start") for call in calls)
assert intent_retained
print("ok - durable completion makes later journal cleanup non-destructive")

calls, source, pipes, intent_retained = exercise_failed_transfer(
    False, completion_signal_window=True,
)
assert not any(call[:3] == (migration.TARGET, "rm", "--force") for call in calls)
assert not any(call[:2] == (migration.SOURCE, "start") for call in calls)
assert intent_retained
print("ok - a signal after durable receipt publication cannot cross back into rollback")

retry_original = copy.deepcopy(container)
retry_original["Id"] = "9" * 64
retry_original["Name"] = "/interrupted-retry"
retry_original["Mounts"] = []
retry_original["HostConfig"]["Binds"] = []
retry_source = copy.deepcopy(retry_original)
retry_source["State"] = {
    "Running": False, "StartedAt": "start", "FinishedAt": "power-loss-stop", "ExitCode": 0,
}
retry_source["HostConfig"]["RestartPolicy"] = {"Name": "no", "MaximumRetryCount": 0}
retry_state = {"target": None, "source_image": None, "target_image": None, "tag": None}
retry_calls = []
with tempfile.TemporaryDirectory() as directory:
    os.environ["XDG_STATE_HOME"] = directory
    retry_intent = migration.record_migration_intent(retry_original, source_nofile=source_nofile)
    retry_intent = migration.record_migration_intent(retry_original, retry_source["State"], retry_intent,
                                                     restart_disabled=True)

    def retry_inspect(engine, kind, name):
        if kind == "image":
            key = "source_image" if engine == migration.SOURCE else "target_image"
            image = retry_state[key]
            if image is None or name not in (image["Id"], *(image.get("RepoTags") or [])):
                raise migration.subprocess.CalledProcessError(1, ["docker", "inspect"])
            return copy.deepcopy(image)
        return copy.deepcopy(retry_source if engine == migration.SOURCE else retry_state["target"])

    def retry_run(*args, **kwargs):
        retry_calls.append(args)
        if args[:2] == (migration.SOURCE, "commit"):
            image_id = "sha256:" + "8" * 64
            retry_state["tag"] = args[3]
            retry_state["source_image"] = {
                "Id": image_id, "RepoTags": [retry_state["tag"]], "RepoDigests": [],
            }
            return image_id
        if args[:3] == (migration.SOURCE, "image", "rm"):
            retry_state["source_image"] = None
        if args[:3] == (migration.TARGET, "image", "rm"):
            if retry_state["target_image"] is not None and args[3] == retry_state["tag"]:
                retry_state["target_image"]["RepoTags"] = []
            else:
                retry_state["target_image"] = None
        if args[:2] == (migration.TARGET, "create"):
            labels = {}
            for index, argument in enumerate(args):
                if argument == "--label":
                    key, value = args[index + 1].split("=", 1)
                    labels[key] = value
            retry_state["target"] = {
                "Id": "7" * 64, "Image": "sha256:" + "8" * 64,
                "Config": {"Labels": labels, "Image": retry_state["tag"]},
                "State": {"Status": "created", "Running": False,
                          "StartedAt": "0001-01-01T00:00:00Z",
                          "FinishedAt": "0001-01-01T00:00:00Z"},
            }
        if args[:2] == (migration.TARGET, "start"):
            retry_state["target"]["State"]["Running"] = True

    migration.inspect = retry_inspect
    migration.run = retry_run
    migration.exists = lambda kind, name: (
        kind == "image" and retry_state["target_image"] is not None and
        name in (retry_state["target_image"]["Id"],
                 *(retry_state["target_image"].get("RepoTags") or []))
    )
    def retry_pipe(producer, consumer):
        retry_state["target_image"] = {
            "Id": "sha256:" + "8" * 64,
            "RepoTags": [retry_state["tag"]], "RepoDigests": [],
        }
    def retry_inspect_optional(engine, kind, name):
        try:
            return retry_inspect(engine, kind, name)
        except migration.subprocess.CalledProcessError:
            return None
    migration.pipe = retry_pipe
    migration.docker_inspect_optional = retry_inspect_optional
    migration.verify_runtime = lambda value, ownership=None, source_nofile=None: copy.deepcopy(retry_state["target"])
    migration.record_completion = lambda source, state, running, verified: None
    migration.migrate(retry_source, source_nofile)
    create_call = next(call for call in retry_calls if call[:2] == (migration.TARGET, "create"))
    assert create_call[create_call.index("--restart") + 1] == "unless-stopped"
    assert (migration.TARGET, "start", "interrupted-retry") in retry_calls
    assert not migration.intent_path(retry_source["Id"]).exists()
print("ok - a fresh process resumes a stopped migration with the original running and restart intent")

resume_original = copy.deepcopy(retry_original)
resume_source = copy.deepcopy(retry_source)
resume_target = copy.deepcopy(retry_state["target"])
resume_target["State"]["Running"] = False
resume_calls = []
with tempfile.TemporaryDirectory() as directory:
    os.environ["XDG_STATE_HOME"] = directory
    resume_intent = migration.record_migration_intent(resume_original, source_nofile=source_nofile)
    resume_intent = migration.record_migration_intent(resume_source, resume_source["State"], resume_intent,
                                                      restart_disabled=True)
    resume_target["Config"]["Labels"][migration.OWNERSHIP_LABEL] = resume_intent["target_ownership"]
    resume_intent["destination"] = {
        "id": resume_target["Id"], "snapshot": migration.snapshot_digest(resume_target),
    }
    migration.persist_migration_intent(resume_source, resume_intent)

    def resume_inspect(engine, kind, name):
        return copy.deepcopy(resume_source if engine == migration.SOURCE else resume_target)

    def resume_run(*args, **kwargs):
        resume_calls.append(args)
        if args[:2] == (migration.TARGET, "start"):
            resume_target["State"]["Running"] = True

    migration.inspect = resume_inspect
    migration.run = resume_run
    migration.verify_runtime = lambda value, ownership=None, source_nofile=None: copy.deepcopy(resume_target)
    migration.record_completion = lambda source, state, running, verified: None
    unexpected_running = copy.deepcopy(resume_target)
    unexpected_running["State"]["Running"] = True
    try:
        migration.verify_resumable_migration(resume_source, unexpected_running, resume_intent)
    except ValueError:
        pass
    else:
        raise AssertionError("an unexpectedly running interrupted destination passed preflight")
    ran_and_stopped = copy.deepcopy(resume_target)
    ran_and_stopped["State"] = {
        "Status": "exited", "Running": False, "StartedAt": "outside-start",
        "FinishedAt": "outside-stop", "ExitCode": 0,
    }
    try:
        migration.verify_resumable_migration(resume_source, ran_and_stopped, resume_intent)
    except ValueError:
        pass
    else:
        raise AssertionError("an externally started and stopped destination passed automatic retry")
    post_start_intent = copy.deepcopy(resume_intent)
    post_start_intent["start_attempted"] = True
    try:
        migration.verify_resumable_migration(resume_source, resume_target, post_start_intent)
    except ValueError:
        pass
    else:
        raise AssertionError("a stopped destination that already ran passed automatic retry")
    restored_source_intent = copy.deepcopy(resume_intent)
    restored_source_intent["restore_started"] = True
    try:
        migration.verify_resumable_migration(resume_source, resume_target, restored_source_intent)
    except ValueError:
        pass
    else:
        raise AssertionError("a destination older than a restored source passed automatic retry")
    migration.persist_migration_intent(resume_source, post_start_intent)
    try:
        migration.restore_source(resume_source["Id"])
    except RuntimeError:
        pass
    else:
        raise AssertionError("post-start recovery restarted the rootful source")
    assert not resume_source["State"]["Running"]
    try:
        migration.migrate(resume_source, source_nofile)
    except ValueError:
        pass
    else:
        raise AssertionError("a missing post-start destination allowed automatic recreation")
    migration.persist_migration_intent(resume_source, resume_intent)
    migration.resume_verified_migration(resume_source, resume_target, resume_intent)
    assert (migration.TARGET, "start", "interrupted-retry") in resume_calls
    assert not migration.intent_path(resume_source["Id"]).exists()
print("ok - a verified destination resumes safely across interruption before its first start")

receipt_source = copy.deepcopy(resume_source)
receipt_source["Id"] = "4" * 64
receipt_source["Name"] = "/receipt-window"
receipt_source["Mounts"] = [copy.deepcopy(container["Mounts"][0])]
receipt_target = copy.deepcopy(resume_target)
receipt_target["Id"] = "3" * 64
receipt_target["State"]["Running"] = False
receipt_events = []
original_verify_resumable = migration.verify_resumable_migration
original_verify_event_window = migration.verify_volume_event_window
original_record_completion = migration.record_completion
original_remove_event_marker = migration.remove_volume_event_marker
with tempfile.TemporaryDirectory() as directory:
    os.environ["XDG_STATE_HOME"] = directory
    receipt_intent = migration.record_migration_intent(receipt_source, source_nofile=source_nofile)
    receipt_intent["volume_event"] = {
        "name": migration.volume_event_marker_name(receipt_intent),
        "since": "2026-09-12T00:00:00Z",
    }
    migration.persist_migration_intent(receipt_source, receipt_intent)
    migration.verify_resumable_migration = lambda source, target, intent: (
        copy.deepcopy(receipt_source), copy.deepcopy(receipt_source["State"]),
    )
    migration.inspect = lambda engine, kind, name: copy.deepcopy(
        receipt_source if engine == migration.SOURCE else receipt_target
    )
    migration.verify_volume_event_window = lambda source, intent, window, targets, allowed=None: (
        receipt_events.append((copy.deepcopy(window), set(targets), allowed))
    )
    migration.remove_volume_event_marker = lambda source, intent: receipt_events.append("marker-removed")

    def interrupt_receipt(source, state, running, verified):
        assert migration.migration_intent(source)["volume_event"] == receipt_intent["volume_event"]
        raise RuntimeError("power loss before receipt")

    migration.record_completion = interrupt_receipt
    try:
        migration.resume_verified_migration(receipt_source, receipt_target, receipt_intent)
    except RuntimeError as error:
        assert str(error) == "power loss before receipt"
    else:
        raise AssertionError("an interrupted completion unexpectedly removed its event window")
    assert migration.migration_intent(receipt_source)["volume_event"] == receipt_intent["volume_event"]
    receipt_target["Config"]["Labels"][migration.LABEL] = receipt_source["Id"]

    def publish_receipt(source, state, running, verified):
        migration.write_private_json(migration.completion_path(source["Id"]), {
            "target": receipt_target["Id"],
            "source": migration.stopped_identity(state),
            "target_running": running,
            "source_snapshot": migration.snapshot_digest(source),
            "target_snapshot": migration.snapshot_digest(receipt_target),
        })

    original_release_transfer_image = migration.release_transfer_image
    migration.record_completion = publish_receipt
    migration.release_transfer_image = lambda source, intent: (_ for _ in ()).throw(
        RuntimeError("cleanup after resumed receipt")
    )
    before_recovery_calls = len(resume_calls)
    try:
        migration.resume_verified_migration(receipt_source, receipt_target, receipt_intent)
    except RuntimeError as error:
        assert str(error) == "cleanup after resumed receipt"
    else:
        raise AssertionError("resumed completion cleanup failure was accepted")
    assert migration.completion_path(receipt_source["Id"]).exists()
    migration.restore_source(receipt_source["Id"])
    assert len(resume_calls) == before_recovery_calls
    migration.completion_path(receipt_source["Id"]).unlink()
    migration.release_transfer_image = original_release_transfer_image
    migration.record_completion = lambda source, state, running, verified: None
    migration.resume_verified_migration(receipt_source, receipt_target, receipt_intent)
    assert receipt_events.count("marker-removed") == 2
    assert len([event for event in receipt_events if event != "marker-removed"]) == 3
    assert not migration.intent_path(receipt_source["Id"]).exists()
migration.verify_resumable_migration = original_verify_resumable
migration.verify_volume_event_window = original_verify_event_window
migration.record_completion = original_record_completion
migration.remove_volume_event_marker = original_remove_event_marker
print("ok - interrupted and published resumed receipts retain their safe recovery state")

for unsafe_kind in ("destination", "guard"):
    unsafe_original = copy.deepcopy(retry_original)
    unsafe_original["Id"] = ("a" if unsafe_kind == "destination" else "b") * 64
    unsafe_original["Name"] = f"/{unsafe_kind}-race"
    unsafe_source = copy.deepcopy(unsafe_original)
    unsafe_source["State"] = {
        "Status": "exited", "Running": False, "StartedAt": unsafe_original["State"]["StartedAt"],
        "FinishedAt": "source-stop", "ExitCode": 0,
    }
    unsafe_source["HostConfig"]["RestartPolicy"] = {"Name": "no", "MaximumRetryCount": 0}
    with tempfile.TemporaryDirectory() as directory:
        os.environ["XDG_STATE_HOME"] = directory
        unsafe_intent = migration.record_migration_intent(unsafe_original, source_nofile=source_nofile)
        unsafe_intent = migration.record_migration_intent(
            unsafe_source, unsafe_source["State"], unsafe_intent, restart_disabled=True,
        )
        unsafe_name = (unsafe_source["Name"].lstrip("/") if unsafe_kind == "destination"
                       else migration.volume_guard_name(unsafe_intent))
        unsafe_target = {
            "Id": "c" * 64, "Name": f"/{unsafe_name}",
            "Config": {"Labels": {
                migration.LABEL: unsafe_source["Id"],
                migration.OWNERSHIP_LABEL: unsafe_intent["target_ownership"],
            }},
            "State": {"Status": "exited", "Running": False, "StartedAt": "outside-start",
                      "FinishedAt": "outside-stop", "ExitCode": 0},
        }

        def unsafe_inspect(engine, kind, name):
            if engine == migration.SOURCE:
                return copy.deepcopy(unsafe_source)
            if name in (unsafe_target["Id"], unsafe_name):
                return copy.deepcopy(unsafe_target)
            raise migration.subprocess.CalledProcessError(1, ["docker", "inspect"])

        migration.inspect = unsafe_inspect
        migration.exists = lambda kind, name: kind == "container" and name == unsafe_name
        try:
            migration.migrate(unsafe_source, source_nofile)
        except ValueError:
            pass
        else:
            raise AssertionError(f"a raced {unsafe_kind} allowed automatic migration")
        assert migration.migration_intent(unsafe_source)["start_attempted"] is True
        try:
            migration.restore_source(unsafe_source["Id"])
        except RuntimeError:
            pass
        else:
            raise AssertionError(f"a raced {unsafe_kind} allowed rootful source restart")
print("ok - a destination or guard run after preflight durably blocks rootful source restart")

pinned_source = copy.deepcopy(container)
pinned_source["Name"] = "/pinned-volume"
pinned_source["Id"] = "5" * 64
current_pinned_source = copy.deepcopy(pinned_source)
source_volume = {
    "Name": "project-data", "Driver": "local", "Options": None,
    "Labels": {"project": "fixture"}, "Mountpoint": "/source-volume",
}
target_volume = None
pinned_target = None
pinned_guard = None
pin_source_image = None
pin_target_image = None
pin_transfer_tag = None
pin_events = []


def pin_inspect(engine, kind, name):
    if kind == "image":
        image = pin_source_image if engine == migration.SOURCE else pin_target_image
        if image is None or name not in (image["Id"], *(image.get("RepoTags") or [])):
            raise migration.subprocess.CalledProcessError(1, ["docker", "inspect"])
        return copy.deepcopy(image)
    if engine == migration.SOURCE and kind == "container":
        return copy.deepcopy(current_pinned_source)
    if engine == migration.SOURCE and kind == "volume":
        return copy.deepcopy(source_volume)
    if engine == migration.TARGET and kind == "volume":
        if target_volume is None:
            raise migration.subprocess.CalledProcessError(1, ["docker", "inspect"])
        return copy.deepcopy(target_volume)
    for candidate in (pinned_target, pinned_guard):
        if candidate is not None and name in (candidate["Id"], candidate["Name"].lstrip("/")):
            return copy.deepcopy(candidate)
    raise migration.subprocess.CalledProcessError(1, ["docker", "inspect"])


def pin_run(*args, **kwargs):
    global target_volume, pinned_target, pinned_guard
    global pin_source_image, pin_target_image, pin_transfer_tag
    pin_events.append(args)
    if args[:2] == (migration.SOURCE, "update"):
        current_pinned_source["HostConfig"]["RestartPolicy"] = {"Name": "no", "MaximumRetryCount": 0}
    elif args[:2] == (migration.SOURCE, "stop"):
        current_pinned_source["State"] = {
            "Status": "exited", "Running": False, "StartedAt": "start",
            "FinishedAt": "pinned-stop", "ExitCode": 0,
        }
    elif args[:2] == (migration.SOURCE, "commit"):
        pin_transfer_tag = args[3]
        pin_source_image = {
            "Id": "sha256:" + "4" * 64,
            "RepoTags": [pin_transfer_tag], "RepoDigests": [],
        }
        return pin_source_image["Id"]
    elif args[:3] == (migration.SOURCE, "image", "rm"):
        pin_source_image = None
    elif args[:3] == (migration.TARGET, "image", "rm"):
        if pin_target_image is not None and args[3] == pin_transfer_tag:
            pin_target_image["RepoTags"] = []
        else:
            pin_target_image = None
    elif args[:3] == (migration.TARGET, "volume", "create"):
        labels = {}
        for index, argument in enumerate(args):
            if argument == "--label":
                key, value = args[index + 1].split("=", 1)
                labels[key] = value
        target_volume = {
            "Name": args[-1], "Driver": "local", "Options": None,
            "Labels": labels, "Mountpoint": "/target-volume",
        }
    elif args[:2] == (migration.TARGET, "create"):
        labels = {}
        for index, argument in enumerate(args):
            if argument == "--label":
                key, value = args[index + 1].split("=", 1)
                labels[key] = value
        created_name = args[args.index("--name") + 1]
        created = {
            "Id": ("8" if created_name.startswith("omarchy-volume-guard-") else "6") * 64,
            "Name": f"/{created_name}", "Image": "sha256:" + "4" * 64,
            "Config": {"Labels": labels, "Image": pin_transfer_tag},
            "State": {"Status": "created", "Running": False,
                      "StartedAt": "0001-01-01T00:00:00Z",
                      "FinishedAt": "0001-01-01T00:00:00Z"},
        }
        if created_name.startswith("omarchy-volume-guard-"):
            pinned_guard = created
        else:
            pinned_target = created
    elif args[:3] == (migration.TARGET, "container", "ls"):
        return "\n".join(candidate["Id"] for candidate in (pinned_guard, pinned_target)
                         if candidate is not None)
    elif args[:3] == (migration.TARGET, "rm", "--force"):
        if pinned_guard is not None and args[3] == pinned_guard["Id"]:
            pinned_guard = None
        elif pinned_target is not None and args[3] == pinned_target["Id"]:
            pinned_target = None
    elif args[:2] == (migration.TARGET, "start"):
        pinned_target["State"]["Status"] = "running"
        pinned_target["State"]["Running"] = True


def pin_exists(kind, name):
    if kind == "volume":
        return target_volume is not None
    if kind == "image":
        return (pin_target_image is not None and
                name in (pin_target_image["Id"], *(pin_target_image.get("RepoTags") or [])))
    return any(candidate is not None and name in (candidate["Id"], candidate["Name"].lstrip("/"))
               for candidate in (pinned_guard, pinned_target))


original_pin_remove_event_marker = migration.remove_volume_event_marker
with tempfile.TemporaryDirectory() as directory:
    os.environ["XDG_STATE_HOME"] = directory
    migration.inspect = pin_inspect
    migration.run = pin_run
    migration.exists = pin_exists
    def pin_pipe(producer, consumer):
        global pin_target_image
        pin_events.append(("pipe",))
        pin_target_image = {
            "Id": "sha256:" + "4" * 64,
            "RepoTags": [pin_transfer_tag], "RepoDigests": [],
        }
    def pin_inspect_optional(engine, kind, name):
        try:
            return pin_inspect(engine, kind, name)
        except migration.subprocess.CalledProcessError:
            return None
    migration.pipe = pin_pipe
    migration.docker_inspect_optional = pin_inspect_optional
    migration.verify_runtime = lambda value, ownership=None, source_nofile=None: copy.deepcopy(pinned_target)
    migration.verify_volume = lambda target, digest: None
    migration.source_volume_digest = lambda volume: "7" * 64
    migration.clear_volume = lambda target: pin_events.append(("clear", target))
    migration.transfer_volume = lambda volume, target: (pin_events.append(("transfer", target)) or "7" * 64)
    def pin_event_window(source, intent, targets):
        pin_events.append(("event-window-begin",))
        intent = copy.deepcopy(intent)
        intent["volume_event"] = {"name": "marker", "since": "time"}
        return intent
    migration.ensure_volume_event_window = pin_event_window
    migration.verify_volume_event_window = lambda source, intent, window, targets, allowed=None: (
        pin_events.append(("event-window-verify", tuple(sorted(targets)), allowed))
    )
    migration.remove_volume_event_marker = lambda source, intent: pin_events.append(("event-window-remove",))
    migration.record_completion = lambda source, state, running, verified: None
    migration.migrate(pinned_source, source_nofile)
migration.remove_volume_event_marker = original_pin_remove_event_marker

create_indexes = [index for index, event in enumerate(pin_events)
                  if event[:2] == (migration.TARGET, "create")]
assert len(create_indexes) == 2
guard_index, create_index = create_indexes
clear_index = pin_events.index(("clear", "project-data"))
transfer_index = pin_events.index(("transfer", "project-data"))
event_begin_index = pin_events.index(("event-window-begin",))
assert event_begin_index < guard_index < clear_index < transfer_index < create_index
guard_call = pin_events[guard_index]
create_call = pin_events[create_index]
assert "--network=none" in guard_call
assert "--read-only" in guard_call and "--cap-drop" in guard_call
guard_entrypoint = guard_call[guard_call.index("--entrypoint") + 1]
assert re.fullmatch(r"/\.omarchy-volume-guard-[a-f0-9]{64}", guard_entrypoint)
assert create_call[create_call.index("--runtime") + 1] == "runc"
assert any(event[:3] == (migration.TARGET, "container", "ls")
           for event in pin_events[guard_index + 1:clear_index])
guard_remove_index = next(index for index, event in enumerate(pin_events)
                          if event[:3] == (migration.TARGET, "rm", "--force") and event[3] == "8" * 64)
start_index = pin_events.index((migration.TARGET, "start", "pinned-volume"))
event_verify = [event for event in pin_events if event[:1] == ("event-window-verify",)][-1]
event_verify_index = pin_events.index(event_verify)
assert create_index < guard_remove_index < start_index < event_verify_index
assert event_verify[1:] == (("project-data",), "6" * 64)
assert ("event-window-verify", ("project-data",), None) in pin_events[guard_index:create_index]
assert event_verify_index < pin_events.index(("event-window-remove",))
sync_index = next(index for index, event in enumerate(pin_events)
                  if event[:4] == ("target-namespace", "/usr/bin/python3", migration.TRUSTED_MANIFEST, "--sync"))
assert transfer_index < sync_index < create_index
print("ok - an inert random guard pins and durably verifies volumes before application start")

batch = []
for index in (1, 2):
    member = copy.deepcopy(container)
    member["Name"] = f"/batch-{index}"
    member["Id"] = str(index) * 64
    member["Mounts"] = []
    member["HostConfig"]["Binds"] = []
    batch.append(member)
batch_by_name = {member["Name"].lstrip("/"): member for member in batch}
restored_batch = []
with tempfile.TemporaryDirectory() as directory:
    os.environ["XDG_STATE_HOME"] = directory
    migration.daemon_security = lambda engine: source_security if engine == migration.SOURCE else target_security
    migration.inspect = lambda engine, kind, name: copy.deepcopy(batch_by_name[name])
    migration.exists = lambda kind, name: False
    migration.container_nofile = lambda member, default, intent=None: copy.deepcopy(source_nofile)
    migration.migrate = lambda member, nofile: (_ for _ in ()).throw(RuntimeError("first transfer failed"))
    migration.restore_source = lambda identity, validator=migration.validate: restored_batch.append(identity)
    sys.argv = ["migrate.py", *batch_by_name]
    try:
        migration.main()
    except RuntimeError:
        pass
    else:
        raise AssertionError("a failed batch transfer was reported as complete")
assert restored_batch == [batch[1]["Id"], batch[0]["Id"]]
print("ok - transfer failure restores every remaining quiesced workload in reverse order")
PY
