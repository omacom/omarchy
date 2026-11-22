"""Capability catalog, aligned with Matter clusters, plus risk profiles.

A capability is a small, typed contract (attributes + commands) that every
adapter maps onto. The ids are ours; the Matter cluster numbers are recorded so
Matter devices map 1:1 and so the catalog can be exported as W3C WoT Thing
Descriptions.

Tiers here are defaults. A thing's *kind* (profile) adjusts them, and config can
override per thing: a smart plug that powers a space heater is not a lamp.
"""

from __future__ import annotations

from .model import AttributeSpec as A
from .model import CapabilitySpec as C
from .model import CommandSpec as Cmd
from .model import ParamSpec as P
from .model import Thing, Tier

T0, T1, T2, T3 = Tier.T0, Tier.T1, Tier.T2, Tier.T3

_TRANSITION = P("transition_s", "number", unit="s", minimum=0, maximum=60, required=False,
                description="fade time in seconds")

CAPABILITIES: dict[str, C] = {
    c.id: c
    for c in (
        C(
            "on_off", "On/Off", 0x0006,
            attributes=(A("on", "boolean", actuated=True, matter="0x0006/0x0000"),),
            commands=(
                Cmd("turn_on", T1, effects={"on": True}, matter="0x0006:On"),
                Cmd("turn_off", T1, safer=True, effects={"on": False}, matter="0x0006:Off"),
                Cmd("toggle", T1, effects={"on": "!on"}, matter="0x0006:Toggle"),
            ),
        ),
        C(
            "level", "Level", 0x0008,
            attributes=(A("level", "number", unit="%", actuated=True, matter="0x0008/0x0000"),),
            commands=(
                Cmd("set_level", T1,
                    params=(P("level", "number", unit="%", minimum=0, maximum=100), _TRANSITION),
                    effects={"level": "$level"}, matter="0x0008:MoveToLevelWithOnOff"),
            ),
        ),
        C(
            "color", "Color", 0x0300,
            attributes=(
                A("color_temp_kelvin", "integer", unit="K", actuated=True, matter="0x0300/0x0007"),
                A("rgb", "string", actuated=True, description="#rrggbb"),
            ),
            commands=(
                Cmd("set_color_temp", T1,
                    params=(P("kelvin", "integer", unit="K", minimum=1500, maximum=9000), _TRANSITION),
                    effects={"color_temp_kelvin": "$kelvin"}, matter="0x0300:MoveToColorTemperature"),
                Cmd("set_color", T1,
                    params=(P("rgb", "string", pattern=r"#[0-9a-fA-F]{6}", description="#rrggbb"),
                            _TRANSITION),
                    effects={"rgb": "$rgb"}, matter="0x0300:MoveToHueAndSaturation"),
            ),
        ),
        C(
            "door_lock", "Door lock", 0x0101,
            attributes=(
                A("lock_state", "string", actuated=True, matter="0x0101/0x0000",
                  enum=("locked", "unlocked", "not_fully_locked", "jammed", "locking",
                        "unlocking", "open", "unknown")),
            ),
            commands=(
                Cmd("lock", T1, safer=True, effects={"lock_state": "locked"}, matter="0x0101:LockDoor"),
                Cmd("unlock", T3, effects={"lock_state": "unlocked"}, matter="0x0101:UnlockDoor"),
            ),
        ),
        C(
            "cover", "Window covering / door opener", 0x0102,
            attributes=(
                A("position", "number", unit="%", actuated=True, matter="0x0102/0x000E",
                  description="100 = fully open"),
                A("cover_state", "string", actuated=True,
                  enum=("open", "closed", "opening", "closing", "stopped", "unknown")),
            ),
            commands=(
                Cmd("open", T1, effects={"position": 100}, matter="0x0102:UpOrOpen"),
                Cmd("close", T1, effects={"position": 0}, matter="0x0102:DownOrClose"),
                Cmd("stop", T1, safer=True, matter="0x0102:StopMotion"),
                Cmd("set_position", T1,
                    params=(P("position", "number", unit="%", minimum=0, maximum=100),),
                    effects={"position": "$position"}, matter="0x0102:GoToLiftPercentage"),
            ),
        ),
        C(
            "thermostat", "Thermostat", 0x0201,
            attributes=(
                A("current_temperature", "number", unit="°C", measurement=True, matter="0x0201/0x0000"),
                A("target_temperature", "number", unit="°C", actuated=True, matter="0x0201/0x0012"),
                A("mode", "string", actuated=True, matter="0x0201/0x001C",
                  enum=("off", "heat", "cool", "auto", "heat_cool", "fan_only", "dry")),
            ),
            commands=(
                Cmd("set_target_temperature", T1,
                    params=(P("temperature", "number", unit="°C", minimum=5, maximum=35),),
                    effects={"target_temperature": "$temperature"}),
                Cmd("set_mode", T2,
                    params=(P("mode", "string",
                              enum=("off", "heat", "cool", "auto", "heat_cool", "fan_only", "dry")),),
                    effects={"mode": "$mode"}),
            ),
        ),
        C(
            "valve", "Valve", 0x0081,
            attributes=(A("open", "boolean", actuated=True, matter="0x0081/0x0004"),),
            commands=(
                Cmd("open", T2, effects={"open": True}, matter="0x0081:Open"),
                Cmd("close", T1, safer=True, effects={"open": False}, matter="0x0081:Close"),
            ),
        ),
        C(
            "alarm_panel", "Alarm panel", None,
            attributes=(
                A("alarm_state", "string", actuated=True,
                  enum=("disarmed", "armed_home", "armed_away", "armed_night", "arming",
                        "pending", "triggered", "unknown")),
            ),
            commands=(
                Cmd("arm_away", T1, safer=True, effects={"alarm_state": "armed_away"}),
                Cmd("arm_home", T1, safer=True, effects={"alarm_state": "armed_home"}),
                Cmd("disarm", T3, effects={"alarm_state": "disarmed"}),
            ),
        ),
        C(
            "scene", "Scene / script", None,
            description="Runs a backend scene or script. Its contents are opaque, so it is T2.",
            commands=(Cmd("activate", T2),),
        ),
        C("temperature", "Temperature", 0x0402,
          attributes=(A("temperature", "number", unit="°C", measurement=True, matter="0x0402/0x0000"),)),
        C("humidity", "Relative humidity", 0x0405,
          attributes=(A("humidity", "number", unit="%", measurement=True, matter="0x0405/0x0000"),)),
        C("occupancy", "Occupancy", 0x0406,
          attributes=(A("occupied", "boolean", measurement=True, matter="0x0406/0x0000"),)),
        C("contact", "Contact sensor", 0x0045,
          attributes=(A("open", "boolean", measurement=True, matter="0x0045/0x0000"),)),
        C("leak", "Water leak", 0x0045,
          attributes=(A("leak", "boolean", measurement=True, matter="0x0045/0x0000"),)),
        C("power", "Electrical power", 0x0090,
          attributes=(
              A("power_w", "number", unit="W", measurement=True, matter="0x0090/0x0008"),
              A("energy_kwh", "number", unit="kWh", measurement=True, matter="0x0091/0x0001"),
          )),
        C("button", "Button", 0x003B,
          attributes=(A("pressed", "boolean", measurement=True, matter="0x003B/0x0001"),)),
    )
}


# Profiles: a thing's *kind* adjusts tiers (and whether a command counts as safer).
# value = (tier, safer) where safer=None keeps the catalog default.
PROFILES: dict[str, dict[str, tuple[Tier, bool | None]]] = {
    # Space heater, oven, iron: turning ON is a fire risk; turning OFF is always safe.
    "heater": {"on_off.turn_on": (T3, None), "on_off.toggle": (T3, None)},
    # Appliances with a known, attended load (kettle, coffee machine, washer).
    "appliance": {"on_off.turn_on": (T2, None), "on_off.toggle": (T2, None)},
    # Unknown load behind a plug or relay: off is NOT automatically safe (fridge, NAS, aquarium).
    "plug": {"on_off.turn_on": (T2, None), "on_off.turn_off": (T2, False), "on_off.toggle": (T2, None)},
    "relay": {"on_off.turn_on": (T2, None), "on_off.turn_off": (T2, False), "on_off.toggle": (T2, None)},
    # Loads that must stay powered (freezer, medical device, network gear).
    "critical_load": {"on_off.turn_off": (T3, False), "on_off.toggle": (T3, None)},
    # Moving machinery big enough to hurt someone and to open the house.
    "garage_door": {"cover.open": (T3, None), "cover.set_position": (T3, None), "cover.close": (T2, None)},
    "gate": {"cover.open": (T3, None), "cover.set_position": (T3, None), "cover.close": (T2, None)},
    "water_main": {"valve.open": (T3, None)},
    "irrigation": {"valve.open": (T2, None)},
    # Plain lights, indicators, blinds: catalog defaults.
    "light": {},
    "indicator": {},
    "blind": {},
    "fan": {},
    "lock": {},
    "thermostat": {},
    "sensor": {},
}


def capability(cap_id: str) -> C:
    try:
        return CAPABILITIES[cap_id]
    except KeyError:
        raise KeyError(f"unknown capability {cap_id!r}") from None


def resolve_command(thing: Thing, command: str) -> tuple[str, Cmd]:
    """Accept "cap.cmd" or a bare "cmd" and find it among the thing's capabilities."""
    from .model import InvalidRequest

    if "." in command:
        cap_id, _, name = command.partition(".")
        if cap_id not in thing.capabilities:
            raise InvalidRequest(f"{thing.id} has no capability {cap_id!r}")
        spec = capability(cap_id).command(name)
        if spec is None:
            raise InvalidRequest(f"capability {cap_id!r} has no command {name!r}")
        return cap_id, spec
    matches = [(c, capability(c).command(command)) for c in thing.capabilities if c in CAPABILITIES]
    matches = [(c, s) for c, s in matches if s is not None]
    if not matches:
        available = ", ".join(commands_for(thing)) or "none"
        raise InvalidRequest(f"{thing.id} has no command {command!r} (available: {available})")
    if len(matches) > 1:
        options = ", ".join(f"{c}.{command}" for c, _ in matches)
        raise InvalidRequest(f"{command!r} is ambiguous on {thing.id}; use one of {options}")
    return matches[0]


def commands_for(thing: Thing) -> list[str]:
    out = []
    for cap_id in thing.capabilities:
        spec = CAPABILITIES.get(cap_id)
        if spec:
            out.extend(f"{cap_id}.{c.name}" for c in spec.commands)
    return out


def effective_profile(thing: Thing, cap_id: str, cmd: Cmd) -> tuple[Tier, bool]:
    """Catalog default -> kind profile -> per-thing override."""
    tier, safer = cmd.tier, cmd.safer
    key = f"{cap_id}.{cmd.name}"
    override = PROFILES.get(thing.kind or "", {}).get(key)
    if override:
        tier = override[0]
        if override[1] is not None:
            safer = override[1]
    if key in thing.tier_overrides:
        tier = thing.tier_overrides[key]
    elif cmd.name in thing.tier_overrides:
        tier = thing.tier_overrides[cmd.name]
    return tier, safer


def actuated_attributes(thing: Thing) -> set[str]:
    out: set[str] = set()
    for cap_id in thing.capabilities:
        spec = CAPABILITIES.get(cap_id)
        if spec:
            out.update(a.name for a in spec.attributes if a.actuated)
    return out


def measurement_attributes(thing: Thing) -> set[str]:
    out: set[str] = set()
    for cap_id in thing.capabilities:
        spec = CAPABILITIES.get(cap_id)
        if spec:
            out.update(a.name for a in spec.attributes if a.measurement)
    return out


def attribute_spec(thing: Thing, name: str) -> A | None:
    for cap_id in thing.capabilities:
        spec = CAPABILITIES.get(cap_id)
        if spec and (a := spec.attribute(name)):
            return a
    return None


def predict(cmd: Cmd, args: dict, state: dict) -> dict:
    """Predicted attribute changes for a command (used for dry-run + origin tracking)."""
    out = {}
    for attr, expr in cmd.effects.items():
        if isinstance(expr, str) and expr.startswith("$"):
            name = expr[1:]
            if name in args:
                out[attr] = args[name]
        elif isinstance(expr, str) and expr.startswith("!"):
            current = state.get(expr[1:])
            if isinstance(current, bool):
                out[attr] = not current
        else:
            out[attr] = expr
    if cmd.name == "set_level" and "level" in args:
        out["on"] = args["level"] > 0
    return out


def affected_attributes(cmd: Cmd) -> set[str]:
    """Attributes a command may change, predicted or as a side effect. Side effects
    (a light restoring its last brightness and color when switched on) must count
    as the fabric's, or our own action would look like a person's."""
    attrs = set(cmd.effects)
    if cmd.name in ("open", "close", "stop", "set_position"):
        attrs |= {"position", "cover_state"}
    if cmd.name in ("turn_on", "turn_off", "toggle", "set_level", "set_color", "set_color_temp"):
        attrs |= {"on", "level", "color_temp_kelvin", "rgb", "power_w"}
    if cmd.name in ("lock", "unlock"):
        attrs.add("lock_state")
    return attrs
