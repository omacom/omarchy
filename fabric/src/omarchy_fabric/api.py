"""One method table for every transport (unix socket, TCP, SSH stdio, embedded MCP).

Roles: agent < console < admin.
  agent    observe, invoke (through policy), simulate, leases, its own approvals, emergency stop
  console  + list / approve / deny approvals, thaw, audit, simulator controls
  admin    + Matter commissioning
An agent can always make things safer (freeze) but never approve its own requests.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Awaitable, Callable

from .model import Assurance, InvalidRequest, InvokeRequest, NotFound, PermissionDenied
from .util import clean_text

ROLES = {"agent": 0, "console": 1, "admin": 2}


@dataclass
class Session:
    role: str
    agent: str
    max_assurance: Assurance = Assurance.NONE  # strongest approval this session can give
    transport: str = "local"

    def at_least(self, role: str) -> bool:
        return ROLES[self.role] >= ROLES[role]

    @property
    def who(self) -> str:
        return f"{self.role}:{self.agent}"


Handler = Callable[[Any, Session, dict[str, Any]], Awaitable[Any]]
METHODS: dict[str, tuple[str, Handler]] = {}


def method(name: str, role: str = "agent"):
    def register(fn: Handler) -> Handler:
        METHODS[name] = (role, fn)
        return fn
    return register


async def dispatch(fabric, session: Session, name: str, params: dict[str, Any] | None) -> Any:
    entry = METHODS.get(name)
    if entry is None:
        raise InvalidRequest(f"unknown method {name!r}")
    role, handler = entry
    if not session.at_least(role):
        raise PermissionDenied(f"{name} needs the {role} role; this session is {session.role}")
    try:
        return await handler(fabric, session, dict(params or {}))
    except KeyError as exc:
        raise InvalidRequest(f"missing parameter {exc.args[0]!r}") from None


def _hidden_ok(s: Session) -> bool:
    return s.at_least("console")


@method("status")
async def _status(f, s, p):
    return f.status()


@method("things")
async def _things(f, s, p):
    return f.list_things(p.get("area"), p.get("capability"), p.get("query"), include_hidden=_hidden_ok(s))


@method("state")
async def _state(f, s, p):
    return f.get_state(p["thing"], include_hidden=_hidden_ok(s))


@method("describe")
async def _describe(f, s, p):
    return f.describe(s.agent, p["thing"], include_hidden=_hidden_ok(s))


def _request(s: Session, p: dict[str, Any], dry_run: bool = False) -> InvokeRequest:
    args = p.get("args") or {}
    if not isinstance(args, dict):
        raise InvalidRequest("args must be an object, e.g. {\"level\": 40}")
    return InvokeRequest(agent=s.agent, thing_id=p["thing"], command=p["command"], args=args,
                         reason=str(p.get("reason", "")), dry_run=dry_run, wait_s=float(p.get("wait_s") or 0))


@method("invoke")
async def _invoke(f, s, p):
    return await f.invoke(_request(s, p))


@method("simulate")
async def _simulate(f, s, p):
    return await f.invoke(_request(s, p, dry_run=True))


@method("approval_status")
async def _approval_status(f, s, p):
    return await f.approval_status(p["id"], agent=None if s.at_least("console") else s.agent,
                                   wait_s=float(p.get("wait_s") or 0))


@method("events")
async def _events(f, s, p):
    return {"events": f.recent_events(int(p.get("limit", 50)), p.get("thing"), int(p.get("since_seq", 0)),
                                      include_hidden=_hidden_ok(s))}


@method("lease")
async def _lease(f, s, p):
    return f.acquire_lease(s.agent, p["thing"], float(p.get("ttl_s", 300)), str(p.get("purpose", "")))


@method("release")
async def _release(f, s, p):
    return f.release_lease(s.agent, p["thing"])


@method("freeze")
async def _freeze(f, s, p):
    return f.freeze(s.who, str(p.get("reason", "")))


@method("approvals", "console")
async def _approvals(f, s, p):
    return {"approvals": f.list_approvals(bool(p.get("recent", False)))}


@method("approve", "console")
async def _approve(f, s, p):
    return f.resolve_approval(p["id"], True, s.who, s.max_assurance, str(p.get("note", "")))


@method("deny", "console")
async def _deny(f, s, p):
    return f.resolve_approval(p["id"], False, s.who, s.max_assurance, str(p.get("note", "")))


@method("thaw", "console")
async def _thaw(f, s, p):
    return f.thaw(s.who)


@method("lift_suspension", "console")
async def _lift(f, s, p):
    f.rates.lift(p["agent"])
    f.audit.append("suspension_lifted", agent=clean_text(p["agent"]), by=s.who)
    return {"lifted": p["agent"]}


@method("audit_tail", "console")
async def _audit_tail(f, s, p):
    return {"records": f.audit.tail(int(p.get("n", 20)))}


@method("audit_verify", "console")
async def _audit_verify(f, s, p):
    return f.audit.verify().to_dict()


@method("sim", "console")
async def _sim(f, s, p):
    """Scenario controls for simulator adapters: play the human, break things, advance time."""
    adapter = f.adapters.get(p.get("adapter", "sim"))
    if adapter is None or adapter.type != "simulator":
        raise NotFound("no simulator adapter (sim controls only work on simulated things)")
    action = p["action"]
    native = p.get("thing", "")
    if native.startswith(f"{adapter.id}:"):
        native = native.split(":", 1)[1]
    attrs = p.get("attrs") or {}
    if action in ("human", "external", "sensor"):
        if native not in adapter.state:
            raise NotFound(f"simulator has no {native!r}")
        getattr(adapter, action)(native, **attrs)
    elif action in ("offline", "online"):
        adapter.set_offline(native, action == "offline")
    elif action == "fault":
        adapter.inject_fault(native, str(p.get("fault", "error")))
    elif action == "step":
        adapter.step(float(p.get("seconds", 1)))
    else:
        raise InvalidRequest(f"unknown sim action {action!r}")
    return {"ok": True, "action": action, "thing": native}


@method("matter_commission", "admin")
async def _commission(f, s, p):
    adapter = f.adapters.get(p.get("adapter", "matter"))
    if adapter is None or adapter.type != "matter":
        raise NotFound("no matter adapter configured")
    result = await adapter.commission(str(p["code"]), bool(p.get("network_only", False)))
    f.audit.append("matter_commission", by=s.who, result=result)
    return result
