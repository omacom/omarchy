"""Human-in-the-loop approvals.

An approval binds a human's "yes" to one exact request (agent, thing, command,
args). Agents can see the status of their own approvals but can never resolve
them: approve/deny is only reachable from console roles, and each channel
carries an assurance level (cli < desktop < presence). A T3 action that needs
PRESENCE cannot be approved from a shell, only by a physical button on the node.

When approved, the fabric re-checks every guard (frozen? offline? human hold?)
before executing, so a stale approval cannot do something unsafe later.
"""

from __future__ import annotations

import asyncio
from dataclasses import dataclass, field
from typing import Any, Callable

from .model import Assurance, InvalidRequest, NotFound, PermissionDenied, Tier
from .util import Clock, clean_text, iso, short_id

PENDING = "pending"
APPROVED = "approved"  # transient: execution is in progress
FINAL = ("denied", "expired", "executed", "failed", "cancelled")


@dataclass
class Approval:
    id: str
    agent: str
    thing_id: str
    thing_name: str
    capability: str
    command: str
    args: dict[str, Any]
    reason: str
    tier: Tier
    requires: Assurance
    created_at: float
    expires_at: float
    status: str = PENDING
    resolved_by: str | None = None
    resolved_assurance: Assurance | None = None
    resolved_at: float | None = None
    note: str = ""
    result: dict[str, Any] | None = None
    _done: asyncio.Event | None = field(default=None, repr=False, compare=False)

    @property
    def summary(self) -> str:
        args = ", ".join(f"{k}={v}" for k, v in self.args.items())
        verb = self.command.upper().replace("_", " ")
        return f"{self.agent} wants to {verb} {self.thing_name!r}" + (f" ({args})" if args else "")

    def to_dict(self, now: float) -> dict[str, Any]:
        out: dict[str, Any] = {
            "id": self.id,
            "status": self.status,
            "summary": self.summary,
            "agent": self.agent,
            "thing": self.thing_id,
            "command": f"{self.capability}.{self.command}",
            "args": self.args,
            "reason": self.reason,
            "tier": str(self.tier),
            "requires": str(self.requires),
            "created": iso(self.created_at),
        }
        if self.status == PENDING:
            out["expires_in_s"] = round(max(0.0, self.expires_at - now))
        if self.resolved_by:
            out["resolved_by"] = self.resolved_by
            out["resolved_assurance"] = str(self.resolved_assurance)
        if self.note:
            out["note"] = self.note
        if self.result is not None:
            out["result"] = self.result
        return out


class ApprovalBroker:
    def __init__(self, clock: Clock, on_change: Callable[[str, Approval], None] | None = None):
        self.clock = clock
        self.on_change = on_change or (lambda kind, a: None)
        self._items: dict[str, Approval] = {}

    def create(self, *, agent: str, thing_id: str, thing_name: str, capability: str, command: str,
               args: dict[str, Any], reason: str, tier: Tier, requires: Assurance,
               timeout_s: float) -> Approval:
        now = self.clock.now()
        approval_id = short_id()
        while approval_id in self._items:
            approval_id = short_id()
        approval = Approval(
            id=approval_id, agent=agent, thing_id=thing_id, thing_name=clean_text(thing_name),
            capability=capability, command=command, args=dict(args), reason=clean_text(reason, 240),
            tier=tier, requires=requires, created_at=now, expires_at=now + timeout_s,
        )
        self._items[approval.id] = approval
        self.on_change("approval_requested", approval)
        return approval

    def get(self, approval_id: str) -> Approval:
        self.expire_due()
        approval = self._items.get(approval_id.strip().upper())
        if approval is None:
            raise NotFound(f"no approval {approval_id!r}")
        return approval

    def pending(self) -> list[Approval]:
        self.expire_due()
        return sorted((a for a in self._items.values() if a.status == PENDING), key=lambda a: a.created_at)

    def recent(self, limit: int = 20) -> list[Approval]:
        self.expire_due()
        return sorted(self._items.values(), key=lambda a: a.created_at, reverse=True)[:limit]

    def expire_due(self) -> list[Approval]:
        now = self.clock.now()
        expired = []
        for approval in self._items.values():
            if approval.status == PENDING and approval.expires_at <= now:
                approval.status = "expired"
                approval.resolved_at = now
                expired.append(approval)
                self._finish_event(approval)
                self.on_change("approval_resolved", approval)
        return expired

    def resolve(self, approval_id: str, *, approve: bool, by: str, assurance: Assurance,
                note: str = "") -> Approval:
        approval = self.get(approval_id)
        if approval.status != PENDING:
            raise InvalidRequest(f"approval {approval.id} is already {approval.status}")
        if approve and assurance < approval.requires:
            raise PermissionDenied(
                f"approval {approval.id} requires {approval.requires} assurance; "
                f"this channel only provides {assurance}"
                + (" - press the approve button on the fabric node" if approval.requires == Assurance.PRESENCE else "")
            )
        approval.status = APPROVED if approve else "denied"
        approval.resolved_by = by
        approval.resolved_assurance = assurance
        approval.resolved_at = self.clock.now()
        approval.note = clean_text(note, 240)
        if not approve:
            self._finish_event(approval)
        self.on_change("approval_resolved", approval)
        return approval

    def finish(self, approval: Approval, status: str, result: dict[str, Any] | None) -> None:
        approval.status = status
        approval.result = result
        self._finish_event(approval)
        self.on_change("approval_resolved", approval)

    def _finish_event(self, approval: Approval) -> None:
        if approval._done is not None:
            approval._done.set()

    async def wait(self, approval_id: str, timeout_s: float) -> Approval:
        approval = self.get(approval_id)
        if approval.status in FINAL or timeout_s <= 0:
            return approval
        if approval._done is None:
            approval._done = asyncio.Event()
        try:
            await asyncio.wait_for(approval._done.wait(), timeout_s)
        except asyncio.TimeoutError:
            pass
        self.expire_due()
        return approval
