"""A simulated home, so agents, policy and the Omarchy UI can be exercised
without hardware (and deterministically in tests).

It has a little physics: the thermostat heats the room, the kettle switches
itself off once it boils, the garage door takes 12 s to travel, plugs report
power and energy. Scenario scripts can play the human (`human`) or an
unexplained physical change (`external`), knock things offline, or inject faults.
"""

from __future__ import annotations

import asyncio
import copy
from typing import Any

from ..model import ORIGIN_DEVICE, ORIGIN_FABRIC, ORIGIN_HUMAN, Thing
from .base import Adapter, AdapterError

# native id, name, area, kind, capabilities, initial state
HOME: list[tuple[str, str, str, str | None, tuple[str, ...], dict[str, Any]]] = [
    ("living_room.lamp", "Living room lamp", "living_room", "light", ("on_off", "level", "color", "power"),
     {"on": False, "level": 0, "color_temp_kelvin": 2700, "rgb": "#ffb46b", "power_w": 0.0, "energy_kwh": 0.0}),
    ("office.desk_light", "Desk light", "office", "light", ("on_off", "level", "color"),
     {"on": True, "level": 80, "color_temp_kelvin": 4000, "rgb": "#ffffff"}),
    ("living_room.thermostat", "Living room thermostat", "living_room", "thermostat", ("thermostat",),
     {"current_temperature": 19.5, "target_temperature": 20.0, "mode": "heat"}),
    ("living_room.climate", "Living room climate sensor", "living_room", "sensor", ("temperature", "humidity"),
     {"temperature": 19.5, "humidity": 45.0}),
    ("hallway.motion", "Hallway motion", "hallway", "sensor", ("occupancy",), {"occupied": False}),
    ("entrance.front_door", "Front door lock", "entrance", "lock", ("door_lock",), {"lock_state": "locked"}),
    ("entrance.front_door_contact", "Front door contact", "entrance", "sensor", ("contact",), {"open": False}),
    ("entrance.alarm", "House alarm", "entrance", None, ("alarm_panel",), {"alarm_state": "disarmed"}),
    ("kitchen.kettle", "Kettle", "kitchen", "appliance", ("on_off", "power"),
     {"on": False, "power_w": 0.0, "energy_kwh": 0.0}),
    ("bedroom.heater", "Bedroom space heater", "bedroom", "heater", ("on_off", "power"),
     {"on": False, "power_w": 0.0, "energy_kwh": 0.0}),
    ("office.plug", "Office plug", "office", "plug", ("on_off", "power"),
     {"on": True, "power_w": 35.0, "energy_kwh": 0.0}),
    ("garage.door", "Garage door", "garage", "garage_door", ("cover",), {"position": 0, "cover_state": "closed"}),
    ("office.blinds", "Office blinds", "office", "blind", ("cover",), {"position": 100, "cover_state": "open"}),
    ("utility.leak", "Utility room leak sensor", "utility", "sensor", ("leak",), {"leak": False}),
    ("utility.water_main", "Water main valve", "utility", "water_main", ("valve",), {"open": True}),
]

LOAD_W = {"kitchen.kettle": 2000.0, "bedroom.heater": 1500.0, "office.plug": 35.0}
TRAVEL_S = {"garage_door": 12.0, "gate": 20.0}
DEFAULT_TRAVEL_S = 6.0
KETTLE_BOIL_S = 150.0
AMBIENT_C = 12.0


class SimulatorAdapter(Adapter):
    type = "simulator"

    def __init__(self, adapter_id: str, options: dict[str, Any] | None = None):
        super().__init__(adapter_id, options)
        self.tick_s = float(self.options.get("tick_s", 1.0))
        self.latency_s = float(self.options.get("latency_s", 0.0))
        layout = self.options.get("layout", "home")
        self.defs: dict[str, dict[str, Any]] = {}
        if layout == "home":
            for native, name, area, kind, caps, state in HOME:
                self.defs[native] = {"name": name, "area": area, "kind": kind, "capabilities": caps,
                                     "state": copy.deepcopy(state)}
        for extra in self.options.get("things", []):
            self.defs[extra["id"]] = {
                "name": extra.get("name", extra["id"]), "area": extra.get("area"), "kind": extra.get("kind"),
                "capabilities": tuple(extra.get("capabilities", ())), "state": dict(extra.get("state", {})),
            }
        self.state: dict[str, dict[str, Any]] = {k: v["state"] for k, v in self.defs.items()}
        self.faults: dict[str, str] = {}
        self.offline: set[str] = set()
        self.t = 0.0
        self._cover_target: dict[str, float | None] = {}
        self._kettle_on_at: float | None = None
        self._last_temp_report = None
        self._room_temp: float | None = None
        self._task: asyncio.Task | None = None
        self.commands: list[tuple[str, str, str, dict]] = []  # executed command log, for tests

    async def start(self, fabric) -> None:
        await super().start(fabric)
        fabric.adapter_status(self.id, True, "simulated home")
        for native, d in self.defs.items():
            fabric.add_thing(
                Thing(id=self.thing_id(native), name=d["name"], adapter=self.id, native_id=native,
                      capabilities=tuple(d["capabilities"]), area=d["area"], kind=d["kind"],
                      meta={"vendor": "omarchy-fabric", "model": "simulator"}),
                state=dict(self.state[native]),
            )
        if self.tick_s > 0:
            self._task = asyncio.ensure_future(self._run())

    async def stop(self) -> None:
        if self._task:
            self._task.cancel()

    async def _run(self) -> None:
        while True:
            await asyncio.sleep(self.tick_s)
            self.step(self.tick_s)

    # ------------------------------------------------------------ scenario hooks
    def _push(self, native: str, attrs: dict[str, Any], origin: str | None) -> None:
        self.state[native].update(attrs)
        if self.fabric:
            self.fabric.update_state(self.thing_id(native), attrs, origin)

    def human(self, native: str, **attrs: Any) -> None:
        """A known person did this (e.g. from the HA app)."""
        self._push(native, attrs, ORIGIN_HUMAN)

    def external(self, native: str, **attrs: Any) -> None:
        """Something changed with no known cause (a wall switch, another controller)."""
        self._push(native, attrs, None)

    def sensor(self, native: str, **attrs: Any) -> None:
        self._push(native, attrs, ORIGIN_DEVICE)

    def set_offline(self, native: str, offline: bool = True) -> None:
        (self.offline.add if offline else self.offline.discard)(native)
        if self.fabric:
            self.fabric.set_online(self.thing_id(native), not offline)

    def inject_fault(self, native: str, fault: str = "error") -> None:
        self.faults[native] = fault

    # ------------------------------------------------------------ execution
    async def execute(self, thing: Thing, capability: str, command: str, args: dict[str, Any]) -> dict[str, Any]:
        native = thing.native_id
        if native in self.offline:
            raise AdapterError(f"{native} did not respond")
        fault = self.faults.pop(native, None)
        if fault == "timeout":
            await asyncio.sleep(3600)
        if fault:
            raise AdapterError(f"{native}: simulated {fault}")
        if self.latency_s:
            await asyncio.sleep(self.latency_s)
        self.commands.append((native, capability, command, dict(args)))
        s = self.state[native]
        out: dict[str, Any] = {}
        if capability == "on_off":
            on = {"turn_on": True, "turn_off": False}.get(command, not s.get("on", False))
            out["on"] = on
            if on and "level" in s and not s.get("level"):
                out["level"] = 100
            if native == "kitchen.kettle":
                self._kettle_on_at = self.t if on else None
        elif capability == "level":
            out = {"level": args["level"], "on": args["level"] > 0}
        elif capability == "color":
            out = {"color_temp_kelvin": args["kelvin"]} if command == "set_color_temp" else {"rgb": args["rgb"].lower()}
        elif capability == "door_lock":
            out = {"lock_state": "locked" if command == "lock" else "unlocked"}
        elif capability == "cover":
            target = {"open": 100.0, "close": 0.0}.get(command, args.get("position"))
            if command == "stop":
                self._cover_target[native] = None
                out = {"cover_state": "stopped"}
            else:
                self._cover_target[native] = float(target)
                if abs(float(target) - s.get("position", 0)) > 0.01:
                    out = {"cover_state": "opening" if target > s.get("position", 0) else "closing"}
        elif capability == "thermostat":
            out = ({"target_temperature": args["temperature"]} if command == "set_target_temperature"
                   else {"mode": args["mode"]})
        elif capability == "valve":
            out = {"open": command == "open"}
        elif capability == "alarm_panel":
            out = {"alarm_state": {"arm_away": "armed_away", "arm_home": "armed_home", "disarm": "disarmed"}[command]}
        elif capability == "scene":
            out = {}
        else:
            raise AdapterError(f"simulator cannot run {capability}.{command}")
        if out:
            self._push(native, out, ORIGIN_FABRIC)
        self._update_power(native)
        return {"simulated": True}

    # ------------------------------------------------------------ physics
    def _update_power(self, native: str) -> None:
        s = self.state.get(native, {})
        if "power_w" not in s:
            return
        if native == "living_room.lamp":
            watts = round(9.0 * s.get("level", 0) / 100.0, 1) if s.get("on") else 0.0
        else:
            watts = LOAD_W.get(native, 10.0) if s.get("on") else 0.0
        if watts != s.get("power_w"):
            self._push(native, {"power_w": watts}, ORIGIN_DEVICE)

    def step(self, dt: float) -> None:
        self.t += dt
        # energy
        for native, s in self.state.items():
            if "energy_kwh" in s and s.get("power_w"):
                s["energy_kwh"] = round(s["energy_kwh"] + s["power_w"] * dt / 3_600_000.0, 6)
        # kettle boils and switches itself off
        if self._kettle_on_at is not None and self.t - self._kettle_on_at >= KETTLE_BOIL_S:
            self._kettle_on_at = None
            self._push("kitchen.kettle", {"on": False}, ORIGIN_DEVICE)
            self._update_power("kitchen.kettle")
        # covers travel
        for native, target in list(self._cover_target.items()):
            if target is None:
                continue
            s = self.state[native]
            kind = self.defs[native]["kind"]
            speed = 100.0 / TRAVEL_S.get(kind or "", DEFAULT_TRAVEL_S)
            pos = float(s.get("position", 0))
            step = speed * dt
            if abs(target - pos) <= step:
                self._cover_target[native] = None
                state = "open" if target >= 99.5 else "closed" if target <= 0.5 else "stopped"
                self._push(native, {"position": round(target), "cover_state": state}, ORIGIN_DEVICE)
            else:
                pos += step if target > pos else -step
                self._push(native, {"position": round(pos)}, ORIGIN_DEVICE)
        # thermostat heats / cools the living room
        th = self.state.get("living_room.thermostat")
        if th:
            # Integrate at full precision; only the reported value is rounded.
            if self._room_temp is None:
                self._room_temp = float(th["current_temperature"])
            current = self._room_temp
            mode, target = th["mode"], float(th["target_temperature"])
            if mode in ("heat", "auto", "heat_cool") and current < target:
                current = min(target + 0.2, current + 0.02 * dt)
            elif mode in ("cool", "auto", "heat_cool") and current > target:
                current = max(target - 0.2, current - 0.02 * dt)
            else:
                current += (AMBIENT_C - current) * min(1.0, 0.0005 * dt)
            self._room_temp = current
            rounded = round(current, 1)
            if rounded != self._last_temp_report:
                self._last_temp_report = rounded
                self._push("living_room.thermostat", {"current_temperature": rounded}, ORIGIN_DEVICE)
                if "living_room.climate" in self.state:
                    self._push("living_room.climate", {"temperature": rounded}, ORIGIN_DEVICE)
