"""Run NetClaw's pyATS backend with the transport its skills expect."""

import importlib.util
import os
import pathlib
import sys

path = pathlib.Path(sys.argv[1]).resolve()
# The adjacent generated pyats.py launcher must not shadow the pyats package.
launcher_dir = pathlib.Path(__file__).resolve().parent
sys.path = [entry for entry in sys.path if pathlib.Path(entry).resolve() != launcher_dir]
sys.path.insert(0, str(path.parent))
spec = importlib.util.spec_from_file_location("omarchy_pyats_backend", path)
backend = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = backend
spec.loader.exec_module(backend)
if hasattr(backend, "_get_testbed_connection_args"):
    connection_args = backend._get_testbed_connection_args

    def slow_network_args(device):
        args = dict(connection_args(device))
        args.setdefault("connection_timeout", int(os.environ.get("PYATS_MCP_CONNECTION_TIMEOUT", "300")))
        settings = dict(args.get("settings", {}))
        for key in ("EXEC_TIMEOUT", "CONFIG_TIMEOUT"):
            settings.setdefault(key, int(os.environ.get("PYATS_COMMAND_TIMEOUT", "300")))
        args["settings"] = settings
        return args

    backend._get_testbed_connection_args = slow_network_args
backend.mcp.run(transport="stdio")
