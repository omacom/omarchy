"""Make deployed NetClaw skills discoverable without changing upstream source."""

import argparse
import json
import pathlib
import re
import subprocess


def skill_description(text):
    purpose = re.search(r"^\*\*Purpose\*\*:\s*(.+)$", text, re.MULTILINE)
    if purpose:
        return purpose.group(1).strip()
    overview = re.search(r"^## (?:Overview|Purpose)\s*\n+(.+?)(?:\n\s*\n|\Z)", text, re.MULTILINE | re.DOTALL)
    if overview:
        return " ".join(overview.group(1).split())
    for paragraph in re.split(r"\n\s*\n", text):
        if paragraph.strip() and not paragraph.startswith(("#", "*", ">", "```", "---")):
            return " ".join(paragraph.split())
    raise ValueError("Skill has no purpose or description paragraph")


def prepare(workspace):
    skills = sorted((workspace / "skills").glob("*/SKILL.md"))
    repaired = 0
    for path in skills:
        text = path.read_text()
        if not text.startswith("---\n"):
            header = "---\nname: " + json.dumps(path.parent.name)
            header += "\ndescription: " + json.dumps(skill_description(text))
            path.write_text(header + "\n---\n\n" + text)
            repaired += 1
    netbox = workspace / "skills/netbox-reconcile/SKILL.md"
    if netbox.exists():
        text = netbox.read_text().replace(
            "The MCP has full API access to create and update devices, IPs, interfaces, VLANs, and cables.",
            "NetBox's REST API supports creating and updating inventory, but the installed NetBox MCP exposes read tools. Discover the actual tools before choosing an operation; never invent a mutation tool. When the operator explicitly authorizes writes, use the supported NetBox REST API from the agent with privately configured credentials, or an available write-capable connector. Validate the API schema, preserve unrelated records, record created object IDs, and read back successful writes. Explain which path was used."
        )
        netbox.write_text(text)
    pyats = workspace / "skills/pyats-network/SKILL.md"
    if pyats.exists():
        text = pyats.read_text()
        heading = "## Omarchy collection runtime"
        if heading not in text:
            text += "\n\n" + heading + "\n\nFor multi-device show collection, prefer the upstream `pyats_pcall_show_command` tool with `device_names` and one `command`. It uses pyATS pcall (one process per device). For example, collect `show ip interface brief` from the actual aliases returned by device discovery in a single call. Run successive command batches sequentially; do not launch several competing sessions to the same device. This tool returns raw per-device output. Inspect every result and report partial failures. Inventory discovery alone does not establish connectivity. Never assume the example device address in this skill matches the user's inventory.\n\nAllow slow network operations: MCP initialization defaults to 180 seconds, MCP tool response to 1800 seconds, and single-device show calls to 900 seconds. Use exec timeoutSeconds 2100 for MCP calls and poll the running process instead of launching duplicate calls. The agent turn budget is at least 3600 seconds. Long timeouts are ceilings, not required waits. Use the configured MCP_CALL adapter. Preserve read-only scope and redact credentials, serial numbers and licensing identifiers in reports.\n"
            pyats.write_text(text)
    # The current Markmap backend accepts a list of hex colors, not 'rainbow'.
    markmap = workspace / "skills/markmap-viz/SKILL.md"
    if markmap.exists():
        text = markmap.read_text()
        text = text.replace(',"color_scheme":"rainbow"', '')
        text = text.replace("network-map.svg", "network-map.html")
        text = text.replace("Returns interactive SVG content that can be saved to a file and opened in a browser with zoom, collapse/expand, and pan controls.", "Returns a saved_path to a self-contained interactive HTML file. Open it in the desktop browser for zoom, collapse/expand, and pan controls. The managed MCP renders in the browser and keeps large HTML payloads out of the model context. Use a new .html output_path within the workspace, or omit it for a unique generated filename.")
        markmap.write_text(text)
    print(f"NetClaw workspace: {len(skills)} skill files, {repaired} metadata repairs")
    return len(skills)


def configure_limits(workspace, count):
    # Reserve room for runtime-bundled skills in addition to the NetClaw catalog.
    capacity = max(500, count + 128)
    bootstrap = [workspace / name for name in (
        "AGENTS.md", "SOUL.md", "TOOLS.md", "IDENTITY.md", "USER.md", "HEARTBEAT.md", "BOOTSTRAP.md", "MEMORY.md"
    )]
    sizes = [len(path.read_text()) for path in bootstrap if path.exists()]
    required = {
        "skills.limits.maxCandidatesPerRoot": capacity,
        "skills.limits.maxSkillsLoadedPerSource": capacity,
        "skills.limits.maxSkillsInPrompt": capacity,
        "skills.limits.maxSkillsPromptChars": max(150000, count * 700),
        "agents.defaults.bootstrapMaxChars": max([20000, *sizes]) + 4096,
        "agents.defaults.bootstrapTotalMaxChars": max(60000, sum(sizes) + 8192),
        "agents.defaults.timeoutSeconds": 3600,
        "tools.exec.timeoutSeconds": 2100,
    }
    operations = []
    for key, minimum in required.items():
        result = subprocess.run(["openclaw", "config", "get", key, "--json"], capture_output=True, text=True)
        if result.returncode == 0:
            current = json.loads(result.stdout)
            if isinstance(current, int) and current >= minimum:
                continue
        operations.append({"path": key, "value": minimum})
    if operations:
        subprocess.run(["openclaw", "config", "set", "--batch-json", json.dumps(operations)], check=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("workspace", type=pathlib.Path)
    parser.add_argument("--configure-limits", action="store_true")
    args = parser.parse_args()
    count = prepare(args.workspace)
    if args.configure_limits:
        configure_limits(args.workspace, count)
