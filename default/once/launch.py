"""Pin ONCE to the local rootless engine, independent of Docker environment overrides."""

import http.client
import json
import os
from pathlib import Path
import socket
import stat
import subprocess
import sys

NAMESPACE = "omarchy-once"

class UnixConnection(http.client.HTTPConnection):
    def __init__(self, path):
        super().__init__("localhost", timeout=300)
        self.path = path

    def connect(self):
        self.sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.sock.settimeout(self.timeout)
        self.sock.connect(self.path)



def engine_info(path):
    connection = UnixConnection(path)
    try:
        connection.request("GET", "/v1.44/info")
        response = connection.getresponse()
        if response.status != 200:
            raise RuntimeError(f"Cannot inspect the local engine: HTTP {response.status}")
        return json.load(response)
    finally:
        connection.close()


def main(engine, args):
    uid = os.getuid()
    if uid == 0:
        raise RuntimeError("Run ONCE as your desktop user, without sudo.")
    os.umask(0o077)
    runtime = Path(f"/run/user/{uid}")
    runtime_stat = runtime.stat()
    if runtime_stat.st_uid != uid or stat.S_IMODE(runtime_stat.st_mode) & 0o077:
        raise RuntimeError("A private user runtime directory is required; log in again.")
    env = {key: value for key, value in os.environ.items() if not key.startswith("DOCKER_")}
    env.update(XDG_RUNTIME_DIR=str(runtime), DBUS_SESSION_BUS_ADDRESS=f"unix:path={runtime}/bus", ONCE_NO_SELF_UPDATE="1", ONCE_ROOTLESS="1")
    version = subprocess.check_output(["once", "version"], env=env, text=True).strip()
    if version != "v0.3.2-omarchy1":
        raise RuntimeError(f"This ONCE integration is tested with v0.3.2-omarchy1, found {version}.")
    if engine == "podman":
        unit, endpoint = "podman.socket", runtime / "podman/podman.sock"
    elif engine == "docker":
        unit, endpoint = "docker.service", runtime / "docker.sock"
    else:
        raise RuntimeError("Unknown engine")
    subprocess.run(["systemctl", "--user", "start", unit], env=env, check=True)
    endpoint_stat = endpoint.stat()
    if not stat.S_ISSOCK(endpoint_stat.st_mode) or endpoint_stat.st_uid != uid:
        raise RuntimeError("ONCE requires a socket owned by the current user.")
    info = engine_info(str(endpoint))
    if not any(option.split(",")[0] == "name=rootless" for option in info.get("SecurityOptions", [])):
        raise RuntimeError("ONCE requires a rootless engine; rootful state was left unchanged.")
    env["DOCKER_HOST"] = "unix://" + str(endpoint)
    os.execvpe("once", ["once", "--namespace", NAMESPACE, *args], env)


if __name__ == "__main__":
    try:
        main(sys.argv[1], sys.argv[2:])
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
        sys.exit(f"ONCE: {error}")
