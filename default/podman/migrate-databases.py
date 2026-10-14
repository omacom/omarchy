"""Move compatible local containers into the desktop user's rootless Podman store."""

import json
import os
import re
import subprocess
import sys
from decimal import Decimal
from pathlib import Path


LABEL = "io.omarchy.docker-id"
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


def daemon_security():
    return json.loads(run("sudo", "docker", "info", "--format", "{{json .SecurityOptions}}", capture=True))


def validate_daemon(options):
    # Daemon defaults (including no-new-privileges and seccomp profiles) need
    # not appear in individual HostConfig records. Userns remapping also changes
    # the meaning of numeric volume ownership. Do not guess these policies.
    defaults = {"name=seccomp,profile=builtin", "name=seccomp,profile=default", "name=cgroupns"}
    if not isinstance(options, list) or not options or set(options) - defaults:
        raise ValueError("Docker daemon confinement or user mapping needs an explicit migration")


def validate_volumes(container):
    name = container["Name"].lstrip("/")
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
    for binding in container["HostConfig"].get("Binds") or []:
        fields = binding.split(":")
        if (len(fields) not in (2, 3) or (len(fields) == 3 and fields[2] not in ("rw", "ro")) or
                not any(fields[:2] == [mount["Name"], mount["Destination"]] and
                        (len(fields) == 2 or (fields[2] == "rw") == mount.get("RW"))
                        for mount in mounts)):
            raise ValueError(f"{name}: custom Binds need an explicit volume transfer")


def validate_security(container):
    name = container["Name"].lstrip("/")
    host = container["HostConfig"]
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
        "SecurityOpt", "CapDrop", "LogConfig", "NanoCpus", *RESOURCE_FLAGS,
    }
    for key, value in host.items():
        if key in handled or value in (None, False, "", [], {}):
            continue
        if key == "ConsoleSize" and value == [0, 0]:
            continue
        # Unknown nondefault settings fail closed, including future Docker
        # device, namespace, runtime, mount and resource options.
        raise ValueError(f"{name}: custom {key} needs an explicit Podman configuration")
    log = host.get("LogConfig") or {}
    if (log.get("Type") not in (None, "", "json-file") or
            (log.get("Config") or {}) not in ({}, {"max-size": "10m", "max-file": "5"})):
        raise ValueError(f"{name}: custom logging needs an explicit migration")


def runtime_arguments(container):
    host = container["HostConfig"]
    arguments = [f'--pids-limit={host.get("PidsLimit") or -1}', "--shm-size", str(host["ShmSize"])]
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
    # Docker masks some paths that Podman only mounts read-only. Retain that
    # restriction in addition to Podman's defaults; never unmask a host path.
    if host.get("MaskedPaths"):
        arguments += ["--security-opt", "mask=" + ":".join(sorted(MASKED_PATHS))]
    return arguments


def allowed_capabilities(container):
    # Explicit --cap-add gives even non-root Podman processes effective and
    # ambient capabilities. Docker's default non-root process has neither.
    user = (container["Config"].get("User") or "").split(":")[0]
    if user not in ("", "0", "root"):
        return set()
    # Docker API clients can retain mixed-case names in inspected CapDrop.
    dropped = {capability.upper().removeprefix("CAP_") for capability in container["HostConfig"].get("CapDrop") or []}
    return set() if "ALL" in dropped else DOCKER_CAPABILITIES - dropped


def verify_environment(container, values):
    # Docker and Podman synthesize these process defaults when absent from the
    # image. All source values must survive, and no other variables may appear.
    defaults = {"HOME", "HOSTNAME", "PATH", "TERM", "container"}
    def mapping(entries):
        if not isinstance(entries, list) or any(not isinstance(entry, str) or "=" not in entry for entry in entries):
            raise RuntimeError("Cannot verify container environment")
        result = dict(entry.split("=", 1) for entry in entries)
        if len(result) != len(entries):
            raise RuntimeError("Cannot verify duplicate container environment variables")
        return result
    source = mapping(container["Config"].get("Env") or [])
    target = mapping(values)
    if any(target.get(key) != value for key, value in source.items()) or set(target) - set(source) - defaults:
        # Environment names and values may contain secrets. Never print them.
        raise RuntimeError("Podman did not preserve the source environment; application was not started")


def verify_runtime(container):
    name = container["Name"].lstrip("/")
    target = inspect("podman", "container", name)
    verify_environment(container, target["Config"].get("Env"))
    source_host, target_host = container["HostConfig"], target["HostConfig"]
    if target_host.get("Privileged") is not False:
        raise RuntimeError(f"{name}: refusing privileged destination")
    if target_host.get("Devices") or target_host.get("DeviceRequests") or target_host.get("DeviceCgroupRules"):
        raise RuntimeError(f"{name}: refusing destination device access")
    expected_mounts = sorted((mount["Destination"], destination_volume(container, mount), bool(mount.get("RW")))
                             for mount in container.get("Mounts", []))
    actual_mounts = target.get("Mounts") or []
    if (any(mount.get("Type") != "volume" for mount in actual_mounts) or
            sorted((mount["Destination"], mount["Name"], bool(mount.get("RW"))) for mount in actual_mounts) != expected_mounts):
        raise RuntimeError(f"{name}: destination mounts differ from the validated private volumes")
    expected = {"ShmSize": source_host["ShmSize"], "PidsLimit": source_host.get("PidsLimit") or -1}
    expected.update({key: source_host[key] for key in RESOURCE_FLAGS if source_host.get(key)})
    for key, value in expected.items():
        if target_host.get(key) != value:
            raise RuntimeError(f"{name}: Podman did not preserve {key}; application was not started")
    if source_host.get("NanoCpus"):
        quota, period = target_host.get("CpuQuota"), target_host.get("CpuPeriod")
        if not period or quota * 1_000_000_000 != source_host["NanoCpus"] * period:
            raise RuntimeError(f"{name}: Podman did not preserve the CPU limit; application was not started")
    if source_host.get("SecurityOpt") and not any(
            option in ("no-new-privileges", "no-new-privileges=true")
            for option in target_host.get("SecurityOpt") or []):
        raise RuntimeError(f"{name}: Podman did not preserve no-new-privileges")
    for field in ("EffectiveCaps", "BoundingCaps"):
        # Podman serializes an empty capability set as JSON null. A missing
        # field still means this engine cannot provide the required evidence.
        if field not in target or (target[field] is not None and not isinstance(target[field], list)):
            raise RuntimeError(f"{name}: cannot verify destination {field}")
        if set(target[field] or []) - {f"CAP_{capability}" for capability in allowed_capabilities(container)}:
            raise RuntimeError(f"{name}: Podman added capabilities beyond the source configuration")
    # Docker-compatible inspect omits OCI masking on Podman. Read the runtime's
    # generated specification after init, before its application can execute.
    specification = oci_spec(target)
    process = specification["process"]
    verify_environment(container, process.get("env"))
    # Named image users can resolve differently from their spelling. Never
    # grant capabilities to a nonzero UID through the root-name branch above.
    if process["user"]["uid"] != 0 and any((process.get("capabilities") or {}).values()):
        raise RuntimeError(f"{name}: refusing capabilities on a non-root application")
    linux = specification["linux"]
    if not linux.get("seccomp"):
        raise RuntimeError(f"{name}: destination seccomp confinement is missing")
    if source_host.get("SecurityOpt") and specification["process"].get("noNewPrivileges") is not True:
        raise RuntimeError(f"{name}: runtime did not retain no-new-privileges")
    if not set(source_host.get("MaskedPaths") or []).issubset(linux.get("maskedPaths") or []):
        raise RuntimeError(f"{name}: Podman did not preserve masked paths")
    if not set(source_host.get("ReadonlyPaths") or []).issubset(linux.get("readonlyPaths") or []):
        raise RuntimeError(f"{name}: Podman did not preserve read-only paths")


def oci_spec(target):
    return json.loads(run("podman", "unshare", "cat", "--", target["OCIConfigPath"], capture=True))


def local_command(args):
    if args[0] == "podman":
        return ["/usr/bin/podman", "--remote=false", *args[1:]]
    if list(args[:2]) == ["sudo", "docker"]:
        return ["sudo", "/usr/bin/docker", "--host", "unix:///var/run/docker.sock", *args[2:]]
    return args


def run(*args, capture=False):
    result = subprocess.run(local_command(args), check=True, text=True, capture_output=capture)
    return result.stdout.strip() if capture else None


def inspect(engine, kind, name):
    command = ["sudo", "docker"] if engine == "docker" else ["podman"]
    return json.loads(run(*command, kind, "inspect", name, capture=True))[0]


def exists(kind, name):
    result = subprocess.run(local_command(["podman", kind, "exists", name]))
    if result.returncode not in (0, 1):
        raise RuntimeError(f"Cannot inspect local Podman {kind} {name}")
    return result.returncode == 0


def destination_volume(container, mount):
    explicit = any(binding.split(":")[0] == mount["Name"]
                   for binding in container["HostConfig"].get("Binds") or [])
    return mount["Name"] if explicit else f'omarchy-migrated-{mount["Name"]}'


def completion_path(identity):
    if not re.fullmatch(r"[a-f0-9]{64}", identity):
        raise ValueError("Unsupported Docker container identity")
    return Path(os.environ.get("XDG_STATE_HOME") or Path.home() / ".local/state") / "omarchy/podman-migration" / identity


def completed(container, target):
    if (target["Config"].get("Labels") or {}).get(LABEL) != container["Id"]:
        return False
    receipt = completion_path(container["Id"])
    if not receipt.is_file():
        return False
    try:
        saved = json.loads(receipt.read_text())
        return (saved["target"] == target.get("Id") and
                saved["source"] == stopped_identity(container["State"]))
    except (ValueError, KeyError, TypeError):
        # Older identity-only receipts cannot prove the source stayed stopped.
        return False


def stopped_identity(state):
    if state["Running"] or not state.get("StartedAt") or not state.get("FinishedAt"):
        raise ValueError("Docker source was restarted or its stopped state cannot be verified")
    return {key: state[key] for key in ("StartedAt", "FinishedAt")}


def record_completion(container, source_state):
    target = inspect("podman", "container", container["Name"].lstrip("/"))
    receipt = completion_path(container["Id"])
    receipt.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    temporary = receipt.with_suffix(f".tmp-{os.getpid()}")
    try:
        with temporary.open("x") as output:
            json.dump({"target": target["Id"], "source": stopped_identity(source_state)}, output)
            output.write("\n")
            output.flush()
            os.fsync(output.fileno())
        temporary.replace(receipt)
    finally:
        temporary.unlink(missing_ok=True)


def validate(container):
    name = container["Name"].lstrip("/")
    if not re.fullmatch(r"[a-zA-Z0-9][a-zA-Z0-9_.-]*", name):
        raise ValueError("Unsupported container name")
    if not re.fullmatch(r"[a-f0-9]{64}", container["Id"]):
        raise ValueError("Unsupported Docker container identity")
    validate_security(container)
    if container["Config"].get("Domainname"):
        raise ValueError(f"{name}: custom domain names require an explicit Podman configuration")
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
    if host.get("PidMode") or host.get("UTSMode") or host.get("UsernsMode"):
        raise ValueError(f"{name}: custom namespaces need an explicit Podman configuration")
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


def health_arguments(config):
    health = config.get("Healthcheck") or {}
    test = health.get("Test") or []
    if not test:
        return []
    if test == ["NONE"]:
        return ["--no-healthcheck"]
    arguments = ["--health-cmd", json.dumps(test)]
    for field, flag in (("Interval", "--health-interval"), ("Timeout", "--health-timeout"),
                        ("StartPeriod", "--health-start-period")):
        if health.get(field):
            arguments += [flag, f"{health[field]}ns"]
    if health.get("Retries"):
        arguments += ["--health-retries", str(health["Retries"])]
    return arguments


def transfer_volume(volume, target):
    destination = inspect("podman", "volume", target)["Mountpoint"]
    # Native tar in the destination user namespace preserves the volume root's
    # mode too; volume import can reset it. PAX retains subsecond timestamps.
    pipe(["sudo", "tar", "--format=pax", "--numeric-owner", "--sparse", "--acls", "--xattrs",
          "--xattrs-include=*", "-C", volume["Mountpoint"], "-cpf", "-", "."],
         ["podman", "unshare", "tar", "--numeric-owner", "--same-owner", "--same-permissions",
          "--sparse", "--acls", "--xattrs", "--xattrs-include=*", "-C", destination, "-xpf", "-"])
    manifest = str(Path(__file__).with_name("volume-manifest.py"))
    source_digest = run("sudo", "python3", manifest, volume["Mountpoint"], capture=True)
    verify_volume(target, source_digest)
    return source_digest


def verify_volume(target, expected):
    destination = inspect("podman", "volume", target)["Mountpoint"]
    manifest = str(Path(__file__).with_name("volume-manifest.py"))
    target_digest = run("podman", "unshare", "python3", manifest, destination, capture=True)
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


def refresh_source(container):
    latest = inspect("docker", "container", container["Id"])
    if source_snapshot(latest) != source_snapshot(container):
        raise ValueError(f'{container["Name"].lstrip("/")}: Docker source changed after preflight; rerun migration after workloads are stable')
    validate(latest)
    return latest


def migrate(container):
    container = refresh_source(container)
    name = container["Name"].lstrip("/")
    identity = container["Id"]
    if exists("container", name):
        target = inspect("podman", "container", name)
        container = refresh_source(container)
        if completed(container, target):
            print(f"{name}: already migrated")
            return
        raise ValueError(f"{name}: an existing Podman container needs review; no completed transfer matches it")
    if completion_path(identity).exists():
        raise ValueError(f"{name}: a previously migrated destination is missing; inspect retained data before retrying")

    container = refresh_source(container)
    running = container["State"]["Running"]
    created = False
    start_attempted = False
    restart_changed = False
    new_volumes = []
    verified_volumes = {}
    try:
        run("sudo", "docker", "stop", "-t", "120", identity)
        state = inspect("docker", "container", identity)["State"]
        if state["Running"] or (running and state["ExitCode"] in (137, 139)):
            raise RuntimeError(f"{name}: container did not stop cleanly; transfer aborted")
        stopped_identity(state)
        # Container names allow uppercase, repeated dots and lengths that image
        # repositories reject. The full engine ID is a valid, unique image tag.
        image = f"localhost/omarchy-migrated:{identity}"
        # Commit includes writable-layer changes and the exact image config.
        # Volume data is copied separately while the source container is stopped.
        run("sudo", "docker", "commit", identity, image)
        pipe(["sudo", "docker", "image", "save", image], ["podman", "image", "load", "--quiet"])
        arguments = ["podman", "create", "--pull=never", "--systemd=false", "--http-proxy=false", "--env-host=false", "--name", name, "--label", f"{LABEL}={identity}"]
        # In rootless Podman, "host" selects the user's existing Podman user
        # namespace, also used by unshare/tar; it does not grant host root.
        arguments += ["--privileged=false", "--userns=host", "--pid=private", "--ipc=private",
                      "--uts=private", "--cgroupns=private", "--network=bridge",
                      "--security-opt", "seccomp=/usr/share/containers/seccomp.json"]
        arguments += runtime_arguments(container)
        arguments += ["--log-driver", "k8s-file", "--log-opt", "max-size=10mb"]
        config = container["Config"]
        if config.get("Hostname"):
            arguments += ["--hostname", config["Hostname"]]
        if config.get("StopTimeout") is not None:
            arguments += ["--stop-timeout", str(config["StopTimeout"])]
        if config.get("Tty"):
            arguments += ["--tty"]
        if config.get("OpenStdin"):
            arguments += ["--interactive"]
        # commit/load does not reliably retain runtime health-check overrides.
        arguments += health_arguments(config)
        restart = container["HostConfig"].get("RestartPolicy") or {}
        policy = restart.get("Name") or "no"
        if policy == "on-failure" and restart.get("MaximumRetryCount"):
            policy += f':{restart["MaximumRetryCount"]}'
        arguments += ["--restart", policy]
        for port, bindings in (container["HostConfig"].get("PortBindings") or {}).items():
            for binding in bindings or []:
                arguments += ["--publish", f'127.0.0.1:{binding["HostPort"]}:{port}']
        for mount in container.get("Mounts", []):
            volume = inspect("docker", "volume", mount["Name"])
            if volume.get("Options"):
                raise ValueError(f"{name}: volume driver options require an explicit transfer")
            target = destination_volume(container, mount)
            if exists("volume", target):
                raise ValueError(f"{name}: destination volume already exists; retained it for inspection")
            uid, gid = json.loads(run("sudo", "stat", "--printf", "[%u,%g]", "--", volume["Mountpoint"], capture=True))
            volume_arguments = ["podman", "volume", "create", "--uid", str(uid), "--gid", str(gid)]
            for key, value in (volume.get("Labels") or {}).items():
                volume_arguments += ["--label", f"{key}={value}"]
            run(*volume_arguments, target)
            new_volumes.append(target)
            verified_volumes[target] = transfer_volume(volume, target)
            access = "rw" if mount.get("RW") else "ro"
            arguments += ["--volume", f'{target}:{mount["Destination"]}:{access},nocopy']
        arguments.append(image)
        run(*arguments)
        created = True
        # Volume mounting can otherwise chown restored data. Initialize the
        # container without starting its application and verify again first.
        run("podman", "init", name)
        verify_runtime(container)
        for target, expected in verified_volumes.items():
            verify_volume(target, expected)
        # A later workload may fail, leaving Docker installed. Prevent a daemon
        # restart from reviving this stale source alongside its migrated copy.
        restart_changed = True
        run("sudo", "docker", "update", "--restart=no", identity)
        latest_state = inspect("docker", "container", identity)["State"]
        if stopped_identity(latest_state) != stopped_identity(state):
            raise RuntimeError(f"{name}: Docker source restarted during transfer; inspect both engines")
        if running:
            # Even a failed start command may have launched an application that
            # accepted writes. From this point the destination is recovery data.
            start_attempted = True
            run("podman", "start", name)
        # A crash before this receipt leaves the destination for review. Its
        # label alone must never turn a partial transfer into a successful retry.
        record_completion(container, state)
        print(f"{name}: migrated to rootless Podman; Docker copy retained for recovery")
    except BaseException:
        if start_attempted:
            print(f"{name}: destination start was attempted; both copies were retained for recovery. "
                  "Inspect Podman before resuming Docker or retrying migration.", file=sys.stderr)
            raise
        recovery = []
        if created:
            recovery.append(("podman", "rm", "--force", name))
        for volume in new_volumes:
            recovery.append(("podman", "volume", "rm", volume))
        if restart_changed:
            recovery.append(("sudo", "docker", "update", f"--restart={policy}", identity))
        if running:
            recovery.append(("sudo", "docker", "start", identity))
        for command in recovery:
            try:
                run(*command)
            except Exception:
                # A failed cleanup must not prevent trying to restart Docker.
                print(f"{name}: a recovery step failed; inspect both engines before retrying", file=sys.stderr)
        raise


def main():
    if os.geteuid() == 0:
        raise ValueError("Run the migration as the desktop user; automatic transfer never creates rootful containers")
    check_completed = sys.argv[1:2] == ["--check-completed"]
    check_only = check_completed or sys.argv[1:2] == ["--check"]
    names = sys.argv[2:] if check_only else sys.argv[1:]
    if names:
        validate_daemon(daemon_security())
    containers = [inspect("docker", "container", name) for name in names]
    volumes = set()
    blockers = []
    for container in containers:
        try:
            validate(container)
        except ValueError as error:
            blockers.append(str(error))
            continue
        for mount in container.get("Mounts", []):
            volume = inspect("docker", "volume", mount["Name"])
            if volume.get("Options") or mount["Name"] in volumes:
                blockers.append(f'{container["Name"].lstrip("/")}: custom or shared volumes require an explicit transfer')
            volumes.add(mount["Name"])
    if blockers:
        raise ValueError("\n".join(blockers))
    if check_completed:
        for container in containers:
            name = container["Name"].lstrip("/")
            if (not exists("container", name) or
                    not completed(container, inspect("podman", "container", name)) or
                    (container["HostConfig"].get("RestartPolicy") or {}).get("Name") != "no"):
                raise ValueError(f"{name}: completed transfer changed; Docker must remain available for recovery")
        return
    if not check_only:
        # Check all destination names before stopping the first source.
        for container in containers:
            name = container["Name"].lstrip("/")
            if exists("container", name):
                target = inspect("podman", "container", name)
                if not completed(container, target):
                    raise ValueError(f"{name}: an existing Podman container needs review; no completed transfer matches it")
                continue
            if completion_path(container["Id"]).exists():
                raise ValueError(f"{name}: a previously migrated destination is missing; inspect retained data before retrying")
            for mount in container.get("Mounts", []):
                if exists("volume", destination_volume(container, mount)):
                    raise ValueError(f"{name}: destination volume already exists; retained it for inspection")
    if check_only:
        for container in containers:
            print(f'{container["Name"].lstrip("/")}: ready for local rootless migration')
    if not check_only:
        for container in containers:
            migrate(container)


if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as error:
        # Do not print argv: health commands and volume labels can hold secrets.
        print(f"Podman container migration command failed (exit {error.returncode}); Docker data was retained", file=sys.stderr)
        sys.exit(1)
    except (ValueError, RuntimeError) as error:
        print(f"Podman container migration stopped: {error}", file=sys.stderr)
        sys.exit(1)
