"""Core data model: risk tiers, assurance levels, capability specs, things."""

from __future__ import annotations

import enum
import re
from dataclasses import dataclass, field
from typing import Any


class Tier(enum.IntEnum):
    """Risk tier of a physical action. Higher is riskier."""

    T0 = 0  # observe: read state, list devices
    T1 = 1  # comfort: reversible, low consequence (lights, blinds, setpoint within bounds)
    T2 = 2  # consequential: costly, hard to notice or unknown load (plugs, HVAC mode, appliances)
    T3 = 3  # safety / security critical: locks, garage doors, alarms, heaters, water

    @classmethod
    def parse(cls, value: "str | int | Tier") -> "Tier":
        if isinstance(value, Tier):
            return value
        if isinstance(value, int):
            return cls(value)
        text = str(value).strip().upper()
        if text.startswith("T"):
            text = text[1:]
        return cls(int(text))

    def __str__(self) -> str:  # "T2"
        return self.name


class Effect(str, enum.Enum):
    """What the policy engine decided to do with a request."""

    ALLOW = "allow"
    CONFIRM = "confirm"
    DENY = "deny"

    def __str__(self) -> str:
        return self.value


class Assurance(enum.IntEnum):
    """How strongly an approval proves that a human (not an agent) said yes.

    CLI      a same-user local process approved; cannot tell a human from an agent
    DESKTOP  a person used the desktop console UI (notification / menu)
    PRESENCE physical presence at the node: a hardware button (or OS re-authentication)
    """

    NONE = 0
    CLI = 1
    DESKTOP = 2
    PRESENCE = 3

    @classmethod
    def parse(cls, value: "str | int | Assurance") -> "Assurance":
        if isinstance(value, Assurance):
            return value
        if isinstance(value, int):
            return cls(value)
        return cls[str(value).strip().upper()]

    def __str__(self) -> str:
        return self.name.lower()


# Origins of a state change. HUMAN and EXTERNAL trigger "human hold" by default:
# when a person flips a switch, agents back off instead of fighting them.
ORIGIN_FABRIC = "fabric"  # caused by a command the fabric executed
ORIGIN_HUMAN = "human"  # a known person (HA UI user, physical button we can identify)
ORIGIN_EXTERNAL = "external"  # unexplained change: wall switch, other controller, device itself
ORIGIN_AUTOMATION = "automation"  # an HA automation / script
ORIGIN_DEVICE = "device"  # device-internal (sensor reading, auto-off timer)
ORIGIN_INITIAL = "initial"  # snapshot taken when the thing was discovered


@dataclass(frozen=True)
class ParamSpec:
    name: str
    type: str  # number | integer | boolean | string
    unit: str | None = None
    minimum: float | None = None
    maximum: float | None = None
    enum: tuple[str, ...] | None = None
    pattern: str | None = None
    required: bool = True
    description: str = ""

    def json_schema(self) -> dict[str, Any]:
        schema: dict[str, Any] = {"type": self.type}
        if self.minimum is not None:
            schema["minimum"] = self.minimum
        if self.maximum is not None:
            schema["maximum"] = self.maximum
        if self.enum:
            schema["enum"] = list(self.enum)
        if self.pattern:
            schema["pattern"] = self.pattern
        if self.unit:
            schema["unit"] = self.unit
        if self.description:
            schema["description"] = self.description
        return schema

    def coerce(self, value: Any) -> Any:
        """Validate and coerce one argument. Raises ValueError with a readable message."""
        if self.type in ("number", "integer"):
            if isinstance(value, bool):
                raise ValueError(f"{self.name} must be a {self.type}, got boolean")
            try:
                number = float(value)
            except (TypeError, ValueError):
                raise ValueError(f"{self.name} must be a {self.type}, got {value!r}") from None
            if number != number:  # NaN
                raise ValueError(f"{self.name} must be a real number")
            if self.type == "integer":
                if number != int(number):
                    raise ValueError(f"{self.name} must be an integer, got {value!r}")
                number = int(number)
            if self.minimum is not None and number < self.minimum:
                raise ValueError(f"{self.name}={number} is below the device minimum {self.minimum}")
            if self.maximum is not None and number > self.maximum:
                raise ValueError(f"{self.name}={number} is above the device maximum {self.maximum}")
            return number
        if self.type == "boolean":
            if isinstance(value, bool):
                return value
            if isinstance(value, str) and value.lower() in ("true", "1", "yes", "on"):
                return True
            if isinstance(value, str) and value.lower() in ("false", "0", "no", "off"):
                return False
            raise ValueError(f"{self.name} must be a boolean, got {value!r}")
        text = str(value)
        if self.enum and text not in self.enum:
            raise ValueError(f"{self.name} must be one of {', '.join(self.enum)}; got {text!r}")
        if self.pattern and not re.fullmatch(self.pattern, text):
            raise ValueError(f"{self.name}={text!r} does not match {self.pattern}")
        return text


@dataclass(frozen=True)
class AttributeSpec:
    name: str
    type: str  # number | integer | boolean | string
    unit: str | None = None
    enum: tuple[str, ...] | None = None
    # True when a command changes this attribute (on, level, lock_state...).
    # Only actuated attributes can trigger human hold; sensor readings never do.
    actuated: bool = False
    # True for measurements whose freshness matters (temperature, power...).
    measurement: bool = False
    matter: str | None = None  # "cluster/attribute" reference, e.g. "0x0006/0x0000"
    description: str = ""


@dataclass(frozen=True, eq=False)
class CommandSpec:
    name: str
    tier: Tier
    params: tuple[ParamSpec, ...] = ()
    # True when the command moves the device toward its fail-safe state
    # (lock, turn a heater off, close a water valve). Safer commands stay
    # available while the fabric is frozen or a human hold is active.
    safer: bool = False
    description: str = ""
    # Predicted attribute effects, used for dry-run and fabric-origin tracking.
    # Values may reference params as "$name"; "!attr" means "negate attr".
    effects: dict[str, Any] = field(default_factory=dict)
    matter: str | None = None  # "cluster:Command" reference

    def param(self, name: str) -> ParamSpec | None:
        for p in self.params:
            if p.name == name:
                return p
        return None


@dataclass(frozen=True, eq=False)
class CapabilitySpec:
    id: str
    title: str
    matter_cluster: int | None
    attributes: tuple[AttributeSpec, ...] = ()
    commands: tuple[CommandSpec, ...] = ()
    description: str = ""

    def command(self, name: str) -> CommandSpec | None:
        for c in self.commands:
            if c.name == name:
                return c
        return None

    def attribute(self, name: str) -> AttributeSpec | None:
        for a in self.attributes:
            if a.name == name:
                return a
        return None


@dataclass
class Thing:
    """A controllable or observable physical thing, normalized across backends."""

    id: str  # fabric id: "<adapter>:<native id>", e.g. "ha:light.desk", "matter:5/1"
    name: str  # display name; UNTRUSTED when it comes from a device
    adapter: str  # adapter instance id
    native_id: str  # backend reference (HA entity_id, Matter "node/endpoint", GPIO pin...)
    capabilities: tuple[str, ...]
    area: str | None = None
    kind: str | None = None  # profile that adjusts risk tiers: heater, garage_door, plug...
    tags: frozenset[str] = frozenset()
    tier_overrides: dict[str, Tier] = field(default_factory=dict)  # "cap.cmd" or "cmd" -> Tier
    meta: dict[str, Any] = field(default_factory=dict)
    expose: bool = True  # hidden things (status LED, approval button) are invisible to agents


@dataclass
class AttrValue:
    value: Any
    updated_at: float
    origin: str = ORIGIN_INITIAL


@dataclass
class InvokeRequest:
    agent: str
    thing_id: str
    command: str
    args: dict[str, Any] = field(default_factory=dict)
    reason: str = ""
    dry_run: bool = False
    wait_s: float = 0.0

    def to_dict(self) -> dict[str, Any]:
        return {
            "agent": self.agent,
            "thing": self.thing_id,
            "command": self.command,
            "args": self.args,
            "reason": self.reason,
        }


@dataclass
class Decision:
    effect: Effect
    tier: Tier
    code: str = "ok"  # primary machine-readable reason
    reasons: list[str] = field(default_factory=list)
    assurance: Assurance = Assurance.NONE  # required assurance when effect == CONFIRM
    safer: bool = False

    def to_dict(self) -> dict[str, Any]:
        out: dict[str, Any] = {
            "effect": str(self.effect),
            "tier": str(self.tier),
            "code": self.code,
            "reasons": list(self.reasons),
        }
        if self.effect == Effect.CONFIRM:
            out["requires"] = str(self.assurance)
        if self.safer:
            out["safer"] = True
        return out


class FabricError(Exception):
    """Base error with a machine-readable code, surfaced to agents and RPC clients."""

    code = "error"

    def __init__(self, message: str, code: str | None = None):
        super().__init__(message)
        if code:
            self.code = code


class NotFound(FabricError):
    code = "not_found"


class InvalidRequest(FabricError):
    code = "invalid"


class PermissionDenied(FabricError):
    code = "forbidden"
