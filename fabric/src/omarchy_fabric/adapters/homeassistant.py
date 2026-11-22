"""Home Assistant backend over HA's WebSocket API (ws://host:8123/api/websocket).

Backward compatibility, not a replacement: HA keeps doing what it is great at
(Zigbee, Z-Wave, Matter, 3000+ integrations, automations) and the fabric adds
the agent layer on top. Entities map to fabric things; HA service calls carry
the fabric's commands. HA's event context tells us *who* changed something:
our own call (fabric), a logged-in user (human), an automation, or nobody we
know of (a wall switch: external).

Use a dedicated HA user and long-lived token for the fabric, and expose only
the entities you want agents to see (include_domains / include_entities).
"""

from __future__ import annotations

import asyncio
import json
import time
from typing import Any

from ..model import ORIGIN_AUTOMATION, ORIGIN_FABRIC, ORIGIN_HUMAN, Thing
from ..util import glob
from .base import Adapter, AdapterError

DEFAULT_DOMAINS = ("light", "switch", "fan", "lock", "cover", "climate", "sensor", "binary_sensor",
                   "valve", "alarm_control_panel", "input_boolean")
LOCK_STATES = {"locked": "locked", "unlocked": "unlocked", "jammed": "jammed", "locking": "locking",
               "unlocking": "unlocking", "open": "open", "opening": "unlocking"}
COVER_STATES = ("open", "closed", "opening", "closing")
HVAC_MODES = ("off", "heat", "cool", "auto", "heat_cool", "fan_only", "dry")
ALARM_STATES = ("disarmed", "armed_home", "armed_away", "armed_night", "arming", "pending", "triggered")
BACKOFF_S = (1, 2, 5, 10, 30, 60)


def _num(value: Any) -> float | None:
    try:
        number = float(value)
    except (TypeError, ValueError):
        return None
    return number if number == number else None


def map_entity(state: dict[str, Any], temp_unit: str = "°C") -> tuple[list[str], str | None, dict[str, Any]] | None:
    """HA state object -> (capabilities, kind, attributes). None = not supported."""
    entity_id = state["entity_id"]
    domain = entity_id.split(".", 1)[0]
    s = state.get("state")
    a = state.get("attributes") or {}

    def to_c(value: Any, unit: str | None = None) -> float | None:
        v = _num(value)
        if v is None:
            return None
        if (unit or temp_unit) in ("°F", "F"):
            v = (v - 32.0) * 5.0 / 9.0
        return round(v, 2)

    if domain == "light":
        caps, attrs = ["on_off"], {"on": s == "on"}
        modes = set(a.get("supported_color_modes") or [])
        if modes - {"onoff"}:
            caps.append("level")
            brightness = _num(a.get("brightness"))
            attrs["level"] = round(brightness / 255 * 100) if brightness is not None else (0 if s == "off" else None)
        if modes & {"color_temp", "hs", "rgb", "rgbw", "rgbww", "xy"}:
            caps.append("color")
            if a.get("color_temp_kelvin") is not None:
                attrs["color_temp_kelvin"] = int(a["color_temp_kelvin"])
            if isinstance(a.get("rgb_color"), (list, tuple)) and len(a["rgb_color"]) == 3:
                attrs["rgb"] = "#%02x%02x%02x" % tuple(int(c) for c in a["rgb_color"])
        return caps, "light", attrs
    if domain in ("switch", "input_boolean"):
        # A switch is an unknown load until the user says what it powers.
        return ["on_off"], ("plug" if domain == "switch" else "indicator"), {"on": s == "on"}
    if domain == "fan":
        caps, attrs = ["on_off"], {"on": s == "on"}
        if a.get("percentage") is not None:
            caps.append("level")
            attrs["level"] = _num(a.get("percentage"))
        return caps, "fan", attrs
    if domain == "lock":
        return ["door_lock"], "lock", {"lock_state": LOCK_STATES.get(s, "unknown")}
    if domain == "cover":
        position = _num(a.get("current_position"))
        if position is None:
            position = 100.0 if s == "open" else 0.0 if s == "closed" else None
        dc = a.get("device_class")
        if dc in ("blind", "curtain", "shade", "shutter", "awning", "window", "damper"):
            kind = "blind"
        elif dc == "gate":
            kind = "gate"
        else:  # garage, door, or no class at all: assume it can open the house
            kind = "garage_door"
        return ["cover"], kind, {"position": position, "cover_state": s if s in COVER_STATES else "unknown"}
    if domain == "climate":
        return ["thermostat"], "thermostat", {
            "current_temperature": to_c(a.get("current_temperature")),
            "target_temperature": to_c(a.get("temperature")),
            "mode": s if s in HVAC_MODES else "off",
        }
    if domain == "sensor":
        dc, unit, value = a.get("device_class"), a.get("unit_of_measurement"), _num(s)
        if dc == "temperature":
            return ["temperature"], "sensor", {"temperature": to_c(value, unit)}
        if dc == "humidity":
            return ["humidity"], "sensor", {"humidity": value}
        if dc == "power":
            return ["power"], "sensor", {"power_w": None if value is None else value * (1000 if unit == "kW" else 1)}
        if dc == "energy":
            return ["power"], "sensor", {"energy_kwh": None if value is None else value / (1000 if unit == "Wh" else 1)}
        return None
    if domain == "binary_sensor":
        dc, on = a.get("device_class"), s == "on"
        if dc in ("door", "window", "opening", "garage_door"):
            return ["contact"], "sensor", {"open": on}
        if dc in ("motion", "occupancy", "presence"):
            return ["occupancy"], "sensor", {"occupied": on}
        if dc == "moisture":
            return ["leak"], "sensor", {"leak": on}
        return None
    if domain == "valve":
        kind = "water_main" if a.get("device_class") in ("water", "gas") else None
        return ["valve"], kind, {"open": s in ("open", "opening")}
    if domain == "alarm_control_panel":
        return ["alarm_panel"], None, {"alarm_state": s if s in ALARM_STATES else "unknown"}
    if domain in ("scene", "script"):
        return ["scene"], None, {}
    return None


def service_for(entity_id: str, capability: str, command: str, args: dict[str, Any],
                temp_unit: str = "°C") -> tuple[str, str, dict[str, Any]]:
    """Fabric command -> (HA domain, service, service_data)."""
    domain = entity_id.split(".", 1)[0]
    extra = {"transition": args["transition_s"]} if args.get("transition_s") is not None else {}
    if capability == "on_off":
        return domain, command, {}
    if capability == "level":
        if domain == "fan":
            return "fan", "set_percentage", {"percentage": round(args["level"])}
        if args["level"] <= 0:
            return "light", "turn_off", extra
        return "light", "turn_on", {"brightness_pct": round(args["level"]), **extra}
    if capability == "color":
        if command == "set_color_temp":
            return "light", "turn_on", {"color_temp_kelvin": int(args["kelvin"]), **extra}
        rgb = args["rgb"].lstrip("#")
        return "light", "turn_on", {"rgb_color": [int(rgb[i:i + 2], 16) for i in (0, 2, 4)], **extra}
    if capability == "door_lock":
        return "lock", command, {}
    if capability == "cover":
        if command == "set_position":
            return "cover", "set_cover_position", {"position": round(args["position"])}
        return "cover", {"open": "open_cover", "close": "close_cover", "stop": "stop_cover"}[command], {}
    if capability == "thermostat":
        if command == "set_mode":
            return "climate", "set_hvac_mode", {"hvac_mode": args["mode"]}
        temperature = args["temperature"]
        if temp_unit in ("°F", "F"):
            temperature = round(temperature * 9.0 / 5.0 + 32.0, 1)
        return "climate", "set_temperature", {"temperature": temperature}
    if capability == "valve":
        return "valve", f"{command}_valve", {}
    if capability == "alarm_panel":
        return "alarm_control_panel", {"arm_away": "alarm_arm_away", "arm_home": "alarm_arm_home",
                                       "disarm": "alarm_disarm"}[command], {}
    if capability == "scene":
        return domain, "turn_on", {}
    raise AdapterError(f"no Home Assistant mapping for {capability}.{command}")


class HomeAssistantAdapter(Adapter):
    type = "homeassistant"

    def __init__(self, adapter_id: str, options: dict[str, Any] | None = None):
        super().__init__(adapter_id, options)
        from ..config import expand

        o = self.options
        self.url = o.get("url", "ws://homeassistant.local:8123/api/websocket")
        self.token = o.get("token")
        self.token_file = expand(o["token_file"]) if o.get("token_file") else None
        self.include_domains = set(o.get("include_domains", DEFAULT_DOMAINS))
        self.include_entities = tuple(o.get("include_entities", ()))
        self.exclude_entities = tuple(o.get("exclude_entities", ()))
        # One path per physical device: when the fabric talks to the Matter server
        # directly, skip HA's view of the same devices (exclude_integrations = ["matter"]),
        # or a lease / human hold on one id would not cover its alias.
        self.exclude_integrations = set(o.get("exclude_integrations", ()))
        self.use_registry = bool(o.get("use_registry", True))
        self.alarm_code = o.get("alarm_code")
        self.temp_unit = "°C"
        self._ws = None
        self._next_id = 1
        self._pending: dict[int, asyncio.Future] = {}
        self._contexts: dict[str, float] = {}  # context ids of our own service calls
        self._meta: dict[str, dict[str, Any]] = {}
        self._task: asyncio.Task | None = None
        self.ha_version = ""
        self.own_user_id: str | None = None

    # ------------------------------------------------------------ lifecycle
    async def start(self, fabric) -> None:
        await super().start(fabric)
        if not self.token and self.token_file and self.token_file.exists():
            self.token = self.token_file.read_text().strip()
        if not self.token:
            # A fresh node before HA onboarding: stay up, say what is missing.
            where = self.token_file or "token_file"
            fabric.adapter_status(self.id, False, f"no Home Assistant token: create a long-lived token for "
                                                   f"a dedicated HA user and save it to {where}, then restart")
            return
        fabric.adapter_status(self.id, False, "connecting")
        self._task = asyncio.ensure_future(self._run())

    async def stop(self) -> None:
        if self._task:
            self._task.cancel()
        if self._ws is not None:
            await self._ws.close()

    async def _run(self) -> None:
        attempt = 0
        while True:
            try:
                await self._session()
                attempt = 0
            except asyncio.CancelledError:
                raise
            except Exception as exc:
                self.fabric.adapter_status(self.id, False, f"{type(exc).__name__}: {exc}"[:200])
            await asyncio.sleep(BACKOFF_S[min(attempt, len(BACKOFF_S) - 1)])
            attempt += 1

    async def _session(self) -> None:
        from websockets.asyncio.client import connect

        async with connect(self.url, max_size=32 * 1024 * 1024, open_timeout=10) as ws:
            hello = json.loads(await ws.recv())
            if hello.get("type") != "auth_required":
                raise AdapterError(f"unexpected greeting from Home Assistant: {hello.get('type')}")
            await ws.send(json.dumps({"type": "auth", "access_token": self.token}))
            auth = json.loads(await ws.recv())
            if auth.get("type") != "auth_ok":
                raise AdapterError(f"Home Assistant rejected the token: {auth.get('message', auth.get('type'))}")
            self.ha_version = auth.get("ha_version", "")
            self._ws = ws
            reader = asyncio.ensure_future(self._reader(ws))
            try:
                config = await self._call({"type": "get_config"})
                self.temp_unit = (config.get("unit_system") or {}).get("temperature", "°C")
                # Our own HA user: its state changes are ours even when HA emits the
                # state_changed event before the call_service result arrives.
                me = await self._call({"type": "auth/current_user"})
                self.own_user_id = (me or {}).get("id")
                registry = await self._load_registry() if self.use_registry else {}
                await self._call({"type": "subscribe_events", "event_type": "state_changed"})
                states = await self._call({"type": "get_states"})
                self.fabric.adapter_status(self.id, True, f"Home Assistant {self.ha_version}".strip())
                self._sync(states, registry)
                await reader
            finally:
                reader.cancel()
                self._ws = None
                for future in self._pending.values():
                    if not future.done():
                        future.set_exception(AdapterError("connection to Home Assistant lost"))
                self._pending.clear()

    async def _reader(self, ws) -> None:
        async for raw in ws:
            msg = json.loads(raw)
            kind = msg.get("type")
            if kind == "result":
                future = self._pending.pop(msg.get("id"), None)
                if future and not future.done():
                    if msg.get("success"):
                        future.set_result(msg.get("result"))
                    else:
                        err = msg.get("error") or {}
                        future.set_exception(AdapterError(f"{err.get('code', 'error')}: {err.get('message', '')}"))
            elif kind == "event":
                self._on_event(msg.get("event") or {})

    async def _call(self, msg: dict[str, Any], timeout: float = 15.0) -> Any:
        if self._ws is None:
            raise AdapterError("not connected to Home Assistant")
        msg_id = self._next_id
        self._next_id += 1
        future = asyncio.get_running_loop().create_future()
        self._pending[msg_id] = future
        await self._ws.send(json.dumps({**msg, "id": msg_id}))
        return await asyncio.wait_for(future, timeout)

    async def _load_registry(self) -> dict[str, dict[str, Any]]:
        try:
            entities = await self._call({"type": "config/entity_registry/list"})
            areas = await self._call({"type": "config/area_registry/list"})
            devices = await self._call({"type": "config/device_registry/list"})
        except AdapterError:
            return {}  # non-admin token: fine, we just lose areas and device info
        area_names = {a["area_id"]: a.get("name") for a in areas}
        device_by_id = {d["id"]: d for d in devices}
        out = {}
        for e in entities:
            device = device_by_id.get(e.get("device_id")) or {}
            area_id = e.get("area_id") or device.get("area_id")
            out[e["entity_id"]] = {
                "area": area_names.get(area_id),
                "manufacturer": device.get("manufacturer"),
                "model": device.get("model"),
                "platform": e.get("platform"),
                "skip": bool(e.get("disabled_by") or e.get("hidden_by")
                             or e.get("platform") in self.exclude_integrations),
            }
        return out

    # ------------------------------------------------------------ mapping
    def _included(self, entity_id: str) -> bool:
        if any(glob(p, entity_id) for p in self.exclude_entities):
            return False
        if any(glob(p, entity_id) for p in self.include_entities):
            return True
        return entity_id.split(".", 1)[0] in self.include_domains

    def _sync(self, states: list[dict[str, Any]], registry: dict[str, dict[str, Any]]) -> None:
        self._meta = registry
        seen = set()
        for state in states:
            entity_id = state["entity_id"]
            if registry.get(entity_id, {}).get("skip") or not self._included(entity_id):
                continue
            if self._add(state):
                seen.add(self.thing_id(entity_id))
        for thing_id, thing in list(self.fabric.registry.things.items()):
            if thing.adapter == self.id and thing_id not in seen:
                self.fabric.remove_thing(thing_id)

    def _add(self, state: dict[str, Any]) -> bool:
        mapped = map_entity(state, self.temp_unit)
        if mapped is None:
            return False
        caps, kind, attrs = mapped
        entity_id = state["entity_id"]
        meta = self._meta.get(entity_id, {})
        name = (state.get("attributes") or {}).get("friendly_name") or entity_id
        thing = Thing(
            id=self.thing_id(entity_id), name=str(name), adapter=self.id, native_id=entity_id,
            capabilities=tuple(caps), area=meta.get("area"), kind=kind,
            meta={k: v for k, v in {"manufacturer": meta.get("manufacturer"), "model": meta.get("model"),
                                     "integration": meta.get("platform"), "entity_id": entity_id}.items() if v},
        )
        online = state.get("state") != "unavailable"
        known = thing.id in self.fabric.registry.things
        self.fabric.add_thing(thing, state=attrs, online=online)
        if known:
            self.fabric.set_online(thing.id, online)
        return True

    def _origin(self, context: dict[str, Any] | None) -> str | None:
        if not context:
            return None
        now = time.monotonic()
        for ctx_id, ts in list(self._contexts.items()):
            if now - ts > 120:
                del self._contexts[ctx_id]
        if context.get("id") in self._contexts:
            return ORIGIN_FABRIC
        if self.own_user_id and context.get("user_id") == self.own_user_id:
            return ORIGIN_FABRIC  # the fabric's dedicated HA user
        if context.get("user_id"):
            return ORIGIN_HUMAN
        if context.get("parent_id"):
            return ORIGIN_AUTOMATION
        return None  # no user, no parent: a device or wall switch - the registry decides

    def _on_event(self, event: dict[str, Any]) -> None:
        if event.get("event_type") != "state_changed" or self.fabric is None:
            return
        data = event.get("data") or {}
        entity_id = data.get("entity_id", "")
        new = data.get("new_state")
        thing_id = self.thing_id(entity_id)
        if new is None:
            self.fabric.remove_thing(thing_id)
            return
        if thing_id not in self.fabric.registry.things:
            if self._included(entity_id) and not self._meta.get(entity_id, {}).get("skip"):
                self._add(new)
            return
        mapped = map_entity(new, self.temp_unit)
        if mapped is None:
            return
        _, _, attrs = mapped
        self.fabric.set_online(thing_id, new.get("state") != "unavailable")
        origin = self._origin(new.get("context") or event.get("context"))
        self.fabric.update_state(thing_id, {k: v for k, v in attrs.items() if v is not None}, origin)

    # ------------------------------------------------------------ execution
    async def execute(self, thing: Thing, capability: str, command: str, args: dict[str, Any]) -> dict[str, Any]:
        domain, service, data = service_for(thing.native_id, capability, command, args, self.temp_unit)
        if capability == "alarm_panel" and self.alarm_code:
            data["code"] = self.alarm_code
        result = await self._call({
            "type": "call_service", "domain": domain, "service": service,
            "service_data": data, "target": {"entity_id": thing.native_id},
        })
        context = (result or {}).get("context") or {}
        if context.get("id"):
            self._contexts[context["id"]] = time.monotonic()
        return {"ha_service": f"{domain}.{service}", "ha_context": context.get("id")}
