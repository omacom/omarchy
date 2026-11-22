"""Configuration: one TOML file (~/.config/omarchy-fabric/config.toml).

See examples/*.toml. Without a config file the fabric runs the built-in
simulator with a development policy, so `ofab serve` works out of the box.
"""

from __future__ import annotations

import dataclasses
import os
import sys
import tomllib
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from .model import Assurance, Effect, Thing, Tier
from .policy import AgentPolicy, Bound, PolicyConfig, QuietHours, Rule
from .util import match_thing, parse_hhmm

DEFAULT_CONFIG = Path("~/.config/omarchy-fabric/config.toml")
DEFAULT_STATE = Path("~/.local/state/omarchy-fabric")


@dataclass
class ThingConfig:
    name: str | None = None
    area: str | None = None
    kind: str | None = None
    expose: bool | None = None
    tags: tuple[str, ...] = ()
    tiers: dict[str, Tier] = field(default_factory=dict)


@dataclass
class AdapterConfig:
    type: str
    id: str
    options: dict[str, Any] = field(default_factory=dict)


@dataclass
class TokenConfig:
    role: str  # agent | console | admin
    agent: str
    token: str
    max_assurance: Assurance = Assurance.DESKTOP


@dataclass
class RpcConfig:
    socket: Path
    tcp: str | None = None  # "127.0.0.1:7300"; prefer SSH or Tailscale for remote access
    tokens: list[TokenConfig] = field(default_factory=list)
    local_assurance: Assurance = Assurance.DESKTOP  # what an approval over the unix socket counts as


@dataclass
class ConsoleConfig:
    status_file: Path = Path("omarchy-fabric/status.json")  # under $XDG_RUNTIME_DIR
    connect: str | None = None  # where clients find the fabric: unix path, ssh://fabric@pi5, tcp://host:port
    notify: bool = True
    notify_executed_from: Tier = Tier.T2  # tell the human about executed actions at or above this tier


@dataclass
class FabricConfig:
    name: str = "home"
    state_dir: Path = DEFAULT_STATE
    adapters: list[AdapterConfig] = field(default_factory=list)
    things: dict[str, ThingConfig] = field(default_factory=dict)
    policy: PolicyConfig = field(default_factory=PolicyConfig)
    rpc: RpcConfig | None = None
    console: ConsoleConfig = field(default_factory=ConsoleConfig)
    audit_path: Path | None = None
    audit_key: bytes | None = None
    audit_fsync: bool = True
    event_history: int = 500
    stale_after_s: float = 900.0
    execute_timeout_s: float = 10.0
    confirm_timeout_s: float = 2.0
    fabric_window_s: float = 15.0
    source: Path | None = None

    def apply_thing_overrides(self, thing: Thing) -> Thing:
        """Glob keys apply first, exact ids last (most specific wins)."""
        matches = [(k, v) for k, v in self.things.items() if k != thing.id and _is_glob(k) and match_thing(k, thing)]
        if thing.id in self.things:
            matches.append((thing.id, self.things[thing.id]))
        for _, tc in matches:
            changes: dict[str, Any] = {}
            if tc.name:
                changes["name"] = tc.name
            if tc.area:
                changes["area"] = tc.area
            if tc.kind:
                changes["kind"] = tc.kind
            if tc.expose is not None:
                changes["expose"] = tc.expose
            if tc.tags:
                changes["tags"] = frozenset(thing.tags | set(tc.tags))
            if tc.tiers:
                changes["tier_overrides"] = {**thing.tier_overrides, **tc.tiers}
            thing = dataclasses.replace(thing, **changes)
        return thing


def _is_glob(key: str) -> bool:
    return any(ch in key for ch in "*?[") or key.split(":", 1)[0] in ("area", "kind", "tag")


def expand(path: str | Path, base: Path | None = None) -> Path:
    text = str(path)
    runtime = os.environ.get("XDG_RUNTIME_DIR")
    if "$XDG_RUNTIME_DIR" in text and not runtime:
        text = text.replace("$XDG_RUNTIME_DIR", str(DEFAULT_STATE.expanduser() / "run"))
    p = Path(os.path.expanduser(os.path.expandvars(text)))
    if base is not None and not p.is_absolute():
        p = base / p
    return p


def runtime_dir() -> Path:
    runtime = os.environ.get("XDG_RUNTIME_DIR")
    return Path(runtime) if runtime else DEFAULT_STATE.expanduser() / "run"


def default_socket() -> Path:
    return runtime_dir() / "omarchy-fabric" / "fabric.sock"


def _read_secret(entry: dict[str, Any], key: str = "token", base: Path | None = None) -> str | None:
    if entry.get(key):
        return str(entry[key])
    file_key = f"{key}_file"
    if entry.get(file_key):
        path = expand(entry[file_key], base)
        return path.read_text().strip()
    return None


def _tiers(table: dict[str, Any]) -> dict[str, Tier]:
    return {str(k): Tier.parse(v) for k, v in table.items()}


def parse(data: dict[str, Any], source: Path | None = None) -> FabricConfig:
    base = source.parent if source else None
    fab = data.get("fabric", {})
    state_dir = expand(fab.get("state_dir", DEFAULT_STATE), base)
    cfg = FabricConfig(
        name=fab.get("name", "home"),
        state_dir=state_dir,
        stale_after_s=float(fab.get("stale_after_s", 900)),
        execute_timeout_s=float(fab.get("execute_timeout_s", 10)),
        confirm_timeout_s=float(fab.get("confirm_timeout_s", 2)),
        fabric_window_s=float(fab.get("fabric_window_s", 15)),
        event_history=int(fab.get("event_history", 500)),
        source=source,
    )

    audit = data.get("audit", {})
    if audit.get("enabled", True):
        cfg.audit_path = expand(audit.get("path", "audit.jsonl"), state_dir)
    if audit.get("hmac_key_file"):
        key_path = expand(audit["hmac_key_file"], base)
        if not key_path.exists():  # fail closed: never silently drop to an unkeyed audit log
            raise ValueError(f"audit.hmac_key_file {key_path} does not exist "
                             "(create it with: openssl rand -hex 32, readable only by the fabric user)")
        cfg.audit_key = key_path.read_bytes().strip()
    cfg.audit_fsync = bool(audit.get("fsync", True))

    for i, entry in enumerate(data.get("adapters", [])):
        entry = dict(entry)
        kind = entry.pop("type")
        adapter_id = entry.pop("id", kind if i == 0 else f"{kind}{i}")
        cfg.adapters.append(AdapterConfig(kind, adapter_id, entry))

    for thing_id, entry in data.get("things", {}).items():
        cfg.things[thing_id] = ThingConfig(
            name=entry.get("name"), area=entry.get("area"), kind=entry.get("kind"),
            expose=entry.get("expose"), tags=tuple(entry.get("tags", ())), tiers=_tiers(entry.get("tiers", {})),
        )

    cfg.policy = parse_policy(data.get("policy", {}), data.get("agents", {}))

    rpc = data.get("rpc", {})
    tokens = []
    for entry in rpc.get("tokens", []):
        secret = _read_secret(entry, base=base)
        if not secret:
            raise ValueError("every [[rpc.tokens]] entry needs token or token_file")
        tokens.append(TokenConfig(role=entry.get("role", "agent"), agent=entry.get("agent", "remote"),
                                  token=secret, max_assurance=Assurance.parse(entry.get("max_assurance", "desktop"))))
    cfg.rpc = RpcConfig(
        socket=expand(rpc["socket"], base) if rpc.get("socket") else default_socket(),
        tcp=rpc.get("tcp"),
        tokens=tokens,
        local_assurance=Assurance.parse(rpc.get("local_assurance", "desktop")),
    )

    console = data.get("console", {})
    cfg.console = ConsoleConfig(
        status_file=expand(console.get("status_file", "omarchy-fabric/status.json"), runtime_dir()),
        connect=console.get("connect"),
        notify=bool(console.get("notify", True)),
        notify_executed_from=Tier.parse(console.get("notify_executed_from", "T2")),
    )
    return cfg


def parse_policy(p: dict[str, Any], agents: dict[str, Any]) -> PolicyConfig:
    policy = PolicyConfig()
    if "tiers" in p:
        policy.tier_effects.update({Tier.parse(k): Effect(v) for k, v in p["tiers"].items()})
    if "assurance" in p:
        policy.tier_assurance.update({Tier.parse(k): Assurance.parse(v) for k, v in p["assurance"].items()})
    for key in ("approval_timeout_s", "human_hold_s", "suspend_s", "lease_max_s"):
        if key in p:
            setattr(policy, key, float(p[key]))
    for key in ("allow_safer_when_frozen", "allow_safer_during_hold"):
        if key in p:
            setattr(policy, key, bool(p[key]))
    if "human_hold_origins" in p:
        policy.human_hold_origins = tuple(p["human_hold_origins"])
    rate = p.get("rate", {})
    policy.rate_per_agent_per_minute = int(rate.get("per_agent_per_minute", policy.rate_per_agent_per_minute))
    policy.rate_per_thing_per_minute = int(rate.get("per_thing_per_minute", policy.rate_per_thing_per_minute))
    policy.suspend_after_denials_per_minute = int(
        rate.get("suspend_after_denials_per_minute", policy.suspend_after_denials_per_minute))
    if qh := p.get("quiet_hours"):
        policy.quiet_hours = QuietHours(parse_hhmm(qh["start"]), parse_hhmm(qh["end"]),
                                        Tier.parse(qh.get("escalate_from", "T1")))
    for b in p.get("bounds", []):
        policy.bounds.append(Bound(param=b["param"], min=b.get("min"), max=b.get("max"),
                                   thing=b.get("thing", "*"), capability=b.get("capability", "*"),
                                   note=b.get("note", "")))
    for r in p.get("rules", []):
        policy.rules.append(Rule(
            effect=Effect(r["effect"]), agent=r.get("agent", "*"), thing=r.get("thing", "*"),
            capability=r.get("capability", "*"), command=r.get("command", "*"),
            min_tier=Tier.parse(r["min_tier"]) if "min_tier" in r else None,
            assurance=Assurance.parse(r["assurance"]) if "assurance" in r else None, note=r.get("note", ""),
        ))
    for name, a in agents.items():
        policy.agents[name] = AgentPolicy(name=name, max_tier=Tier.parse(a.get("max_tier", "T1")),
                                          things=tuple(a.get("things", ("*",))), deny=tuple(a.get("deny", ())))
    if not policy.agents:
        policy.agents["*"] = AgentPolicy("*", max_tier=Tier.T1)
    return policy


def dev_config(state_dir: Path | None = None) -> FabricConfig:
    """Built-in config: the simulated home, every agent up to T3, approvals from the
    local console. Good for trying things out; `ofab status` warns about the T3 setting."""
    data = {
        "fabric": {"name": "dev-sim", "state_dir": str(state_dir or DEFAULT_STATE)},
        "adapters": [{"type": "simulator", "id": "sim"}],
        "policy": {"assurance": {"T2": "desktop", "T3": "desktop"},
                   "bounds": [{"capability": "thermostat", "param": "temperature", "min": 16, "max": 25,
                               "note": "comfort band"}]},
        "agents": {"*": {"max_tier": "T3"}},
    }
    return parse(data)


def load(path: str | Path | None = None) -> FabricConfig:
    candidate = path or os.environ.get("OFAB_CONFIG")
    if candidate:
        p = expand(candidate).resolve()  # relative paths inside resolve against the file, not the cwd
        if not p.exists():
            raise FileNotFoundError(f"config not found: {p}")
    else:
        p = DEFAULT_CONFIG.expanduser()
        if not p.exists():
            return dev_config()
    with open(p, "rb") as fh:
        try:
            data = tomllib.load(fh)
        except tomllib.TOMLDecodeError as exc:
            print(f"ofab: {p}: {exc}", file=sys.stderr)
            raise
    return parse(data, p)
