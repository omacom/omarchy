#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

python3 - "$ROOT/default/netclaw/workspace-compat.py" <<'PYTHON'
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("workspace_compat", sys.argv[1])
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
with tempfile.TemporaryDirectory() as directory:
    workspace = Path(directory)
    bodies = {
        "legacy-purpose": '# Memory\n\n**Purpose**: Remember "quoted" facts: safely.\n',
        "legacy-overview": '# Visualization\n\n**Version**: 1\n\n## Overview\n\nDraw actual\nnetwork records.\n\n## Usage\n',
        "legacy-paragraph": '# Device query\n\nQuery several\nplatforms.\n',
        "valid": '---\nname: custom-name\ndescription: Keep this unchanged\n---\n# Custom skill\n',
        "markmap-viz": '---\nname: markmap-viz\ndescription: Draw maps\n---\n{"markdown_content":"# Map","theme":"dark","color_scheme":"rainbow"}\n',
    }
    for name, body in bodies.items():
        path = workspace / "skills" / name / "SKILL.md"
        path.parent.mkdir(parents=True)
        path.write_text(body)
    module.prepare(workspace)
    for name in ("legacy-purpose", "legacy-overview", "legacy-paragraph"):
        text = (workspace / "skills" / name / "SKILL.md").read_text()
        assert text.endswith(bodies[name]), "Original instructions must survive"
        assert json.loads(text.splitlines()[1].split(": ", 1)[1]) == name
        assert json.loads(text.splitlines()[2].split(": ", 1)[1])
    assert (workspace / "skills/valid/SKILL.md").read_text() == bodies["valid"]
    markmap = (workspace / "skills/markmap-viz/SKILL.md").read_text()
    assert '"rainbow"' not in markmap and '"theme":"dark"' in markmap
    snapshot = {path: path.read_bytes() for path in workspace.rglob("SKILL.md")}
    module.prepare(workspace)
    assert all(path.read_bytes() == body for path, body in snapshot.items()), "Repeated setup must be stable"
    (workspace / "SOUL.md").write_text("x" * 45116)
    (workspace / "AGENTS.md").write_text("x" * 30000)
    writes = []

    def config_call(args, **kwargs):
        if args[2] == "get":
            # A larger existing limit must survive; absent values need raising.
            if args[3] == "skills.limits.maxCandidatesPerRoot":
                return subprocess.CompletedProcess(args, 0, stdout="2000")
            return subprocess.CompletedProcess(args, 1, stdout="")
        writes.extend(json.loads(args[-1]))
        return subprocess.CompletedProcess(args, 0)

    with patch.object(module.subprocess, "run", side_effect=config_call):
        module.configure_limits(workspace, 227)
    values = {entry["path"]: entry["value"] for entry in writes}
    assert "skills.limits.maxCandidatesPerRoot" not in values
    assert values["skills.limits.maxSkillsLoadedPerSource"] >= 227
    assert values["skills.limits.maxSkillsInPrompt"] >= 227
    assert values["agents.defaults.bootstrapMaxChars"] > 45116
    assert values["agents.defaults.bootstrapTotalMaxChars"] > 75116
PYTHON
pass 'NetClaw preserves skill instructions and makes room for the complete catalog and persona'

node --input-type=module - "$ROOT/default/netclaw/markmap-document.mjs" <<'JAVASCRIPT'
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const {markmapDocument} = await import(pathToFileURL(process.argv[2]));
const html = markmapDocument({content: '</script><script>bad()</script>', children: []}, {duration: 0}, '/*d3*/', '/*markmap*/');
assert(!html.includes('</script><script>bad()'));
assert(html.includes('\\u003c/script>'));
assert(html.includes('document.fonts.ready'));
assert(html.includes('/*d3*/') && html.includes('/*markmap*/'));
assert(!html.includes('src="https://'));
JAVASCRIPT
pass 'Markmap artifacts embed their assets and escape script payloads'

python3 - "$ROOT/default/netclaw/mcp-call.py" <<'PYTHON'
import importlib.util
import os
import sys
import types
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("mcp_adapter", sys.argv[1])
adapter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(adapter)
calls = []
sent = []
client = types.SimpleNamespace(recv=lambda proc, **kwargs: calls.append(kwargs) or {"id": kwargs["expected_id"]}, send=lambda proc, message: sent.append(message))
adapter.configure(client)
with patch.dict(os.environ, {}, clear=True):
    assert client.recv(None, timeout=10, expected_id=0) == {"id": 0}
    assert calls[-1]["timeout"] == 180
    client.recv(None, timeout=90, expected_id=1)
    assert calls[-1]["timeout"] == 90
    os.environ["MCP_INITIALIZE_TIMEOUT"] = "120"
    client.recv(None, expected_id=0)
    assert calls[-1]["timeout"] == 120
    message = {"method": "tools/call", "params": {"name": "pyats_run_show_command", "arguments": {"device_name": "R1", "command": "show version"}}}
    client.send(None, message)
    assert sent[-1]["params"]["arguments"]["timeout"] == 900
    message["params"]["arguments"]["timeout"] = 1500
    client.send(None, message)
    assert sent[-1]["params"]["arguments"]["timeout"] == 1500
PYTHON
pass 'MCP cold startup has a configurable budget without changing tool response deadlines'
