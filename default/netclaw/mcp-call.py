"""Use NetClaw's MCP client with time for cold component imports on a desktop VM."""

import importlib.util
import json
import os
from pathlib import Path


def configure(client):
    receive = client.recv
    send_message = client.send
    os.environ.setdefault("MCP_CALL_TIMEOUT", "1800")

    def recv(proc, timeout=30, expected_id=None):
        if expected_id == 0:
            timeout = float(os.environ.get("MCP_INITIALIZE_TIMEOUT", "180"))
        return receive(proc, timeout=timeout, expected_id=expected_id)

    client.recv = recv

    def send(proc, message):
        if message.get("method") == "tools/call":
            params = message.get("params", {})
            if params.get("name") == "pyats_run_show_command":
                params.setdefault("arguments", {}).setdefault("timeout", int(os.environ.get("PYATS_SHOW_TIMEOUT", "900")))
        return send_message(proc, message)

    client.send = send


if __name__ == "__main__":
    config = json.loads(Path(__file__).with_suffix(".json").read_text())
    spec = importlib.util.spec_from_file_location("netclaw_mcp_client", config["backend"])
    client = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(client)
    configure(client)
    client.main()
