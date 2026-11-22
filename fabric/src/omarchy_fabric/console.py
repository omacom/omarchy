"""Desktop console: the human side of the fabric on an Omarchy machine.

`ofab console` runs as a user service. It subscribes to the fabric's event
stream (local daemon or a Pi node over SSH) and

  - pops an Omarchy notification for every approval, with Approve / Deny actions
    (PRESENCE-level requests get Deny only: approve them at the node's button),
  - tells you about executed actions at or above console.notify_executed_from,
  - keeps $XDG_RUNTIME_DIR/omarchy-fabric/status.json current for the bar widget,
    which watches the file instead of polling (Omarchy's no-polling rule).
"""

from __future__ import annotations

import asyncio
import json
import os
import shutil
import sys
import time
from pathlib import Path
from typing import Any

from .model import Tier
from .rpc import RpcClient, RpcError
from .util import clean_text

GLYPH = "󰒍"  # md-lan-connect
BACKOFF_S = (1, 2, 5, 10, 30)


def write_status(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    tmp = path.with_suffix(".tmp")
    tmp.write_text(json.dumps(payload, default=str))
    os.replace(tmp, path)


def notify_command(headline: str, body: str, actions: list[tuple[str, list[str]]], urgency: str = "normal") -> list[str] | None:
    """Build the notification command for this desktop. Omarchy's helper first
    (its --action runs a program when clicked), plain notify-send otherwise."""
    if shutil.which("omarchy-notification-send"):
        cmd = ["omarchy-notification-send", "--app-name", "omarchy-fabric", "-u", urgency, "-g", GLYPH, headline, body]
        for label, program in actions:
            cmd += ["--action", label, *program]
        return cmd
    if shutil.which("notify-send"):
        return ["notify-send", "-a", "omarchy-fabric", "-u", urgency, headline, body]
    return None


async def _run(cmd: list[str] | None, fallback: str = "") -> None:
    if cmd is None:  # no notification daemon (e.g. developing on macOS): log instead
        print(f"ofab console: {fallback}", file=sys.stderr)
        return
    proc = await asyncio.create_subprocess_exec(*cmd, stdout=asyncio.subprocess.DEVNULL,
                                                stderr=asyncio.subprocess.DEVNULL)
    asyncio.ensure_future(proc.wait())


class Console:
    def __init__(self, target: str | None, status_file: Path, notify: bool = True,
                 notify_executed_from: Tier = Tier.T2, ofab: str = "ofab"):
        self.target = target
        self.status_file = status_file
        self.notify = notify
        self.notify_executed_from = notify_executed_from
        self.ofab = ofab
        self.client: RpcClient | None = None

    async def refresh(self) -> None:
        assert self.client is not None
        status = await self.client.call("status")
        approvals = (await self.client.call("approvals"))["approvals"]
        write_status(self.status_file, {
            "connected": True,
            "updated": time.time(),
            "fabric": status.get("name"),
            "frozen": status.get("frozen"),
            "pending": [{k: a.get(k) for k in ("id", "summary", "tier", "requires", "reason", "expires_in_s")}
                        for a in approvals],
            "adapters": {k: v.get("connected") for k, v in (status.get("adapters") or {}).items()},
            "things": status.get("things"),
            "online": status.get("online"),
            "warning": status.get("warning"),
        })

    def _approval_notification(self, a: dict[str, Any]) -> list[str] | None:
        headline = f"Approve? {clean_text(a['summary'], 90)}"
        lines = [f"{a['tier']} · requested by {clean_text(a['agent'])}"]
        if a.get("reason"):
            lines.append(f"Reason: {clean_text(a['reason'], 160)}")
        actions: list[tuple[str, list[str]]] = []
        if a.get("requires") == "presence":
            lines.append("Press the approve button on the fabric node to allow it.")
        else:
            actions.append(("Approve", [self.ofab, "approve", a["id"]]))
        actions.append(("Deny", [self.ofab, "deny", a["id"]]))
        return notify_command(headline, "\n".join(lines), actions, urgency="critical")

    async def handle(self, event: dict[str, Any]) -> None:
        kind = event.get("type")
        if kind in ("approval_requested", "approval_resolved", "freeze", "thaw", "adapter", "agent_suspended",
                    "availability", "thing_added", "thing_removed"):
            await self.refresh()
        if not self.notify:
            return
        if kind == "approval_requested":
            a = event["approval"]
            await _run(self._approval_notification(a),
                       f"approval {a['id']} needed ({a['requires']}): {clean_text(a['summary'], 120)}")
        elif kind == "approval_resolved" and event["approval"]["status"] in ("denied", "expired", "cancelled"):
            if shutil.which("omarchy-notification-dismiss"):
                await _run(["omarchy-notification-dismiss", f"Approve? {clean_text(event['approval']['summary'], 40)}"])
        elif kind == "action" and event.get("status") == "executed":
            if Tier.parse(event.get("tier", "T0")) >= self.notify_executed_from:
                await _run(notify_command(
                    f"{clean_text(event.get('agent'))} ran {event.get('command')}",
                    f"{event.get('thing')} ({event.get('tier')})", [], urgency="low"))
        elif kind == "agent_suspended":
            await _run(notify_command(
                f"Agent {clean_text(event.get('agent'))} suspended",
                f"Too many refused actions; it is paused for {round(event.get('seconds', 0))}s.",
                [], urgency="critical"))
        elif kind == "freeze":
            await _run(notify_command("Fabric frozen", clean_text(event.get("reason", "")), [], urgency="critical"))

    async def run(self) -> None:
        attempt = 0
        while True:
            try:
                self.client = await RpcClient.connect(self.target, role="console", agent="desktop")
                attempt = 0
                await self.refresh()
                async for event in self.client.events():
                    await self.handle(event)
            except (RpcError, OSError) as exc:
                write_status(self.status_file, {"connected": False, "updated": time.time(), "error": str(exc)})
            finally:
                if self.client is not None:
                    await self.client.close()
                    self.client = None
            await asyncio.sleep(BACKOFF_S[min(attempt, len(BACKOFF_S) - 1)])
            attempt += 1
