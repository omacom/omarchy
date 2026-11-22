"""Matter backend via the Matter Server WebSocket API (ws://host:5580/ws).

That server is the controller Home Assistant itself uses (python-matter-server,
and its matter.js-based successor, which keeps the same WebSocket protocol).
Talking to it directly lets the fabric run Matter without HA in the middle, and
share the same Matter fabric HA uses when it is there.

Each Matter endpoint with a supported server cluster becomes a fabric thing:
"matter:<node>/<endpoint>". Cluster ids are the Matter spec's; values are
converted to the fabric's units (°C, %, W, kWh).
"""

from __future__ import annotations

import asyncio
import colorsys
import json
from typing import Any

from ..model import Thing
from .base import Adapter, AdapterError

ON_OFF, LEVEL, COLOR = 0x0006, 0x0008, 0x0300
DESCRIPTOR, BASIC, BRIDGED = 0x001D, 0x0028, 0x0039
DOOR_LOCK, WINDOW_COVERING, THERMOSTAT = 0x0101, 0x0102, 0x0201
TEMPERATURE, HUMIDITY, OCCUPANCY, BOOLEAN_STATE = 0x0402, 0x0405, 0x0406, 0x0045
POWER, ENERGY, VALVE = 0x0090, 0x0091, 0x0081

# Matter device type id -> (kind, label)
DEVICE_TYPES = {
    0x0100: ("light", "On/off light"), 0x0101: ("light", "Dimmable light"),
    0x010C: ("light", "Color temperature light"), 0x010D: ("light", "Extended color light"),
    0x010A: ("plug", "On/off plug-in unit"), 0x010B: ("plug", "Dimmable plug-in unit"),
    0x000A: ("lock", "Door lock"), 0x0202: ("blind", "Window covering"), 0x0301: ("thermostat", "Thermostat"),
    0x0302: ("sensor", "Temperature sensor"), 0x0307: ("sensor", "Humidity sensor"),
    0x0107: ("sensor", "Occupancy sensor"), 0x0015: ("sensor", "Contact sensor"),
    0x0043: ("sensor", "Water leak detector"), 0x0042: ("water_main", "Water valve"),
    0x002B: ("fan", "Fan"), 0x0510: ("sensor", "Electrical sensor"),
}
WATER_LEAK_DETECTOR = 0x0043
LOCK_STATES = {0: "not_fully_locked", 1: "locked", 2: "unlocked", 3: "open"}
SYSTEM_MODES = {0: "off", 1: "auto", 3: "cool", 4: "heat", 5: "heat", 6: "cool", 7: "fan_only", 8: "dry"}
MODE_TO_SYSTEM = {"off": 0, "auto": 1, "heat_cool": 1, "cool": 3, "heat": 4, "fan_only": 7, "dry": 8}
BACKOFF_S = (1, 2, 5, 10, 30, 60)


def _field(value: Any, tag: str, name: str) -> Any:
    """Struct values arrive keyed by TLV tag ("0") or by field name; accept both."""
    if isinstance(value, dict):
        return value.get(tag, value.get(name))
    return None


def parse_attributes(attributes: dict[str, Any]) -> dict[int, dict[int, dict[int, Any]]]:
    endpoints: dict[int, dict[int, dict[int, Any]]] = {}
    for path, value in attributes.items():
        try:
            ep, cluster, attr = (int(x) for x in path.split("/"))
        except ValueError:
            continue
        endpoints.setdefault(ep, {}).setdefault(cluster, {})[attr] = value
    return endpoints


def endpoint_profile(clusters: dict[int, dict[int, Any]]) -> tuple[list[str], str | None, str | None, list[int]]:
    """-> capabilities, kind, device-type label, device type ids"""
    device_types = []
    for entry in clusters.get(DESCRIPTOR, {}).get(0) or []:
        dt = _field(entry, "0", "deviceType")
        if isinstance(dt, int):
            device_types.append(dt)
    caps: list[str] = []
    if ON_OFF in clusters:
        caps.append("on_off")
    if LEVEL in clusters and ON_OFF in clusters:
        caps.append("level")
    if COLOR in clusters:
        caps.append("color")
    if DOOR_LOCK in clusters:
        caps.append("door_lock")
    if WINDOW_COVERING in clusters:
        caps.append("cover")
    if THERMOSTAT in clusters:
        caps.append("thermostat")
    if TEMPERATURE in clusters:
        caps.append("temperature")
    if HUMIDITY in clusters:
        caps.append("humidity")
    if OCCUPANCY in clusters:
        caps.append("occupancy")
    if BOOLEAN_STATE in clusters:
        caps.append("leak" if WATER_LEAK_DETECTOR in device_types else "contact")
    if POWER in clusters or ENERGY in clusters:
        caps.append("power")
    if VALVE in clusters:
        caps.append("valve")
    kind = label = None
    for dt in device_types:
        if dt in DEVICE_TYPES:
            kind, label = DEVICE_TYPES[dt]
            break
    if kind is None and caps:
        if "door_lock" in caps:
            kind = "lock"
        elif "thermostat" in caps:
            kind = "thermostat"
        elif "cover" in caps:
            kind = "blind"
        elif "on_off" in caps:
            kind = "light" if ("level" in caps or "color" in caps) else "plug"  # unknown on/off load: T2
        else:
            kind = "sensor"
    return caps, kind, label, device_types


def endpoint_state(clusters: dict[int, dict[int, Any]], caps: list[str]) -> dict[str, Any]:
    s: dict[str, Any] = {}
    if "on_off" in caps:
        s["on"] = bool(clusters[ON_OFF].get(0))
    if "level" in caps and clusters[LEVEL].get(0) is not None:
        s["level"] = round(clusters[LEVEL][0] / 254 * 100)
    if "color" in caps:
        color = clusters[COLOR]
        if color.get(7):
            s["color_temp_kelvin"] = round(1_000_000 / color[7])
        if color.get(0) is not None and color.get(1) is not None:
            r, g, b = colorsys.hsv_to_rgb(color[0] / 254, color[1] / 254, 1.0)
            s["rgb"] = "#%02x%02x%02x" % (round(r * 255), round(g * 255), round(b * 255))
    if "door_lock" in caps:
        s["lock_state"] = LOCK_STATES.get(clusters[DOOR_LOCK].get(0), "unknown")
    if "cover" in caps:
        wc = clusters[WINDOW_COVERING]
        lift = wc.get(14)  # CurrentPositionLiftPercent100ths: 0 = open, 10000 = closed
        if lift is not None:
            s["position"] = round(100 - lift / 100)
        moving = (wc.get(10) or 0) & 0b11  # OperationalStatus, global bits
        if moving == 1:
            s["cover_state"] = "opening"
        elif moving == 2:
            s["cover_state"] = "closing"
        elif lift is not None:
            s["cover_state"] = "open" if lift < 50 else "closed" if lift > 9950 else "stopped"
    if "thermostat" in caps:
        th = clusters[THERMOSTAT]
        mode = SYSTEM_MODES.get(th.get(28), "off")
        s["mode"] = mode
        if th.get(0) is not None:
            s["current_temperature"] = th[0] / 100
        setpoint = th.get(17) if mode == "cool" else th.get(18)
        if setpoint is not None:
            s["target_temperature"] = setpoint / 100
    if "temperature" in caps and clusters[TEMPERATURE].get(0) is not None:
        s["temperature"] = clusters[TEMPERATURE][0] / 100
    if "humidity" in caps and clusters[HUMIDITY].get(0) is not None:
        s["humidity"] = clusters[HUMIDITY][0] / 100
    if "occupancy" in caps:
        s["occupied"] = bool((clusters[OCCUPANCY].get(0) or 0) & 1)
    if "contact" in caps:
        s["open"] = not bool(clusters[BOOLEAN_STATE].get(0))  # StateValue true = contact (closed)
    if "leak" in caps:
        s["leak"] = bool(clusters[BOOLEAN_STATE].get(0))
    if "power" in caps:
        if clusters.get(POWER, {}).get(8) is not None:
            s["power_w"] = clusters[POWER][8] / 1000  # ActivePower, mW
        energy = _field(clusters.get(ENERGY, {}).get(1), "0", "energy")  # CumulativeEnergyImported, mWh
        if isinstance(energy, (int, float)):
            s["energy_kwh"] = energy / 1_000_000
    if "valve" in caps and clusters[VALVE].get(4) is not None:
        s["open"] = clusters[VALVE][4] == 1  # CurrentState: 0 closed, 1 open, 2 transitioning
    return s


class MatterAdapter(Adapter):
    type = "matter"

    def __init__(self, adapter_id: str, options: dict[str, Any] | None = None):
        super().__init__(adapter_id, options)
        self.url = self.options.get("url", "ws://localhost:5580/ws")
        self.nodes: dict[int, dict[str, Any]] = {}
        self.server_info: dict[str, Any] = {}
        self._ws = None
        self._next_id = 1
        self._pending: dict[str, asyncio.Future] = {}
        self._task: asyncio.Task | None = None

    async def start(self, fabric) -> None:
        await super().start(fabric)
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

        async with connect(self.url, max_size=64 * 1024 * 1024, open_timeout=10) as ws:
            self.server_info = json.loads(await ws.recv())
            self._ws = ws
            reader = asyncio.ensure_future(self._reader(ws))
            try:
                nodes = await self._call("start_listening", timeout=60)
                version = self.server_info.get("sdk_version") or self.server_info.get("schema_version", "")
                self.fabric.adapter_status(self.id, True, f"Matter server {version}".strip())
                seen = set()
                for node in nodes or []:
                    seen |= self._apply_node(node)
                for thing_id, thing in list(self.fabric.registry.things.items()):
                    if thing.adapter == self.id and thing_id not in seen:
                        self.fabric.remove_thing(thing_id)
                await reader
            finally:
                reader.cancel()
                self._ws = None
                for future in self._pending.values():
                    if not future.done():
                        future.set_exception(AdapterError("connection to the Matter server lost"))
                self._pending.clear()

    async def _reader(self, ws) -> None:
        async for raw in ws:
            msg = json.loads(raw)
            if "message_id" in msg:
                future = self._pending.pop(str(msg["message_id"]), None)
                if future and not future.done():
                    if "error_code" in msg:
                        future.set_exception(AdapterError(f"matter error {msg['error_code']}: {msg.get('details', '')}"))
                    else:
                        future.set_result(msg.get("result"))
            elif "event" in msg:
                self._on_event(msg["event"], msg.get("data"))

    async def _call(self, command: str, args: dict[str, Any] | None = None, timeout: float = 30.0) -> Any:
        if self._ws is None:
            raise AdapterError("not connected to the Matter server")
        message_id = str(self._next_id)
        self._next_id += 1
        future = asyncio.get_running_loop().create_future()
        self._pending[message_id] = future
        payload: dict[str, Any] = {"message_id": message_id, "command": command}
        if args is not None:
            payload["args"] = args
        await self._ws.send(json.dumps(payload))
        return await asyncio.wait_for(future, timeout)

    # ------------------------------------------------------------ nodes
    def _apply_node(self, node: dict[str, Any]) -> set[str]:
        node_id = int(node["node_id"])
        self.nodes[node_id] = node
        endpoints = parse_attributes(node.get("attributes") or {})
        basic = endpoints.get(0, {}).get(BASIC, {})
        node_name = basic.get(5) or basic.get(3) or f"Matter node {node_id}"
        candidates = []
        for ep, clusters in sorted(endpoints.items()):
            if ep == 0:
                continue
            caps, kind, label, device_types = endpoint_profile(clusters)
            if caps:
                candidates.append((ep, clusters, caps, kind, label, device_types))
        seen = set()
        for ep, clusters, caps, kind, label, device_types in candidates:
            bridged = clusters.get(BRIDGED, {})
            name = bridged.get(5) or bridged.get(3)
            if not name:
                name = node_name if len(candidates) == 1 else f"{node_name} {label or ep}"
            thing = Thing(
                id=self.thing_id(f"{node_id}/{ep}"), name=str(name), adapter=self.id,
                native_id=f"{node_id}/{ep}", capabilities=tuple(caps), kind=kind,
                meta={k: v for k, v in {"vendor": basic.get(1), "product": basic.get(3), "node_id": node_id,
                                         "endpoint": ep, "bridged": bool(bridged)}.items() if v is not None},
            )
            self.fabric.add_thing(thing, state=endpoint_state(clusters, caps), online=bool(node.get("available", True)))
            self.fabric.set_online(thing.id, bool(node.get("available", True)))
            seen.add(thing.id)
        return seen

    def _on_event(self, event: str, data: Any) -> None:
        if self.fabric is None:
            return
        if event in ("node_added", "node_updated") and isinstance(data, dict):
            before = {t for t, th in self.fabric.registry.things.items()
                      if th.adapter == self.id and th.native_id.startswith(f"{data['node_id']}/")}
            for gone in before - self._apply_node(data):
                self.fabric.remove_thing(gone)
        elif event == "node_removed":
            node_id = int(data)
            self.nodes.pop(node_id, None)
            for thing_id, thing in list(self.fabric.registry.things.items()):
                if thing.adapter == self.id and thing.native_id.startswith(f"{node_id}/"):
                    self.fabric.remove_thing(thing_id)
        elif event == "attribute_updated" and isinstance(data, list) and len(data) == 3:
            node_id, path, value = int(data[0]), str(data[1]), data[2]
            node = self.nodes.get(node_id)
            if node is None:
                return
            node.setdefault("attributes", {})[path] = value
            ep = int(path.split("/")[0])
            clusters = parse_attributes(node["attributes"]).get(ep, {})
            thing_id = self.thing_id(f"{node_id}/{ep}")
            thing = self.fabric.registry.get(thing_id)
            if thing is not None:
                self.fabric.update_state(thing_id, endpoint_state(clusters, list(thing.capabilities)))
        elif event == "server_shutdown":
            self.fabric.adapter_status(self.id, False, "Matter server shut down")

    # ------------------------------------------------------------ execution
    async def _command(self, node: int, ep: int, cluster: int, name: str, payload: dict[str, Any],
                       timed_ms: int | None = None) -> Any:
        args: dict[str, Any] = {"node_id": node, "endpoint_id": ep, "cluster_id": cluster,
                                "command_name": name, "payload": payload}
        if timed_ms:
            args["timed_request_timeout_ms"] = timed_ms
        return await self._call("device_command", args)

    async def execute(self, thing: Thing, capability: str, command: str, args: dict[str, Any]) -> dict[str, Any]:
        node, ep = (int(x) for x in thing.native_id.split("/"))
        transition = int(round(float(args.get("transition_s") or 0) * 10))  # tenths of a second
        if capability == "on_off":
            name = {"turn_on": "On", "turn_off": "Off", "toggle": "Toggle"}[command]
            await self._command(node, ep, ON_OFF, name, {})
        elif capability == "level":
            await self._command(node, ep, LEVEL, "MoveToLevelWithOnOff", {
                "level": round(args["level"] * 254 / 100), "transitionTime": transition,
                "optionsMask": 0, "optionsOverride": 0})
        elif capability == "color" and command == "set_color_temp":
            await self._command(node, ep, COLOR, "MoveToColorTemperature", {
                "colorTemperatureMireds": round(1_000_000 / args["kelvin"]), "transitionTime": transition,
                "optionsMask": 0, "optionsOverride": 0})
        elif capability == "color":
            rgb = args["rgb"].lstrip("#")
            h, s, _ = colorsys.rgb_to_hsv(*(int(rgb[i:i + 2], 16) / 255 for i in (0, 2, 4)))
            await self._command(node, ep, COLOR, "MoveToHueAndSaturation", {
                "hue": round(h * 254), "saturation": round(s * 254), "transitionTime": transition,
                "optionsMask": 0, "optionsOverride": 0})
        elif capability == "door_lock":
            # Door Lock commands are timed interactions in the Matter spec.
            await self._command(node, ep, DOOR_LOCK, "LockDoor" if command == "lock" else "UnlockDoor", {},
                                timed_ms=1000)
        elif capability == "cover":
            if command == "set_position":
                await self._command(node, ep, WINDOW_COVERING, "GoToLiftPercentage",
                                    {"liftPercent100thsValue": round((100 - args["position"]) * 100)})
            else:
                name = {"open": "UpOrOpen", "close": "DownOrClose", "stop": "StopMotion"}[command]
                await self._command(node, ep, WINDOW_COVERING, name, {})
        elif capability == "thermostat":
            if command == "set_mode":
                await self._call("write_attribute", {"node_id": node, "attribute_path": f"{ep}/{THERMOSTAT}/28",
                                                     "value": MODE_TO_SYSTEM[args["mode"]]})
            else:
                mode = self.fabric.registry.values(thing.id).get("mode") if self.fabric else None
                attr = 17 if mode == "cool" else 18  # Occupied{Cooling,Heating}Setpoint, 0.01 °C
                await self._call("write_attribute", {"node_id": node, "attribute_path": f"{ep}/{THERMOSTAT}/{attr}",
                                                     "value": round(args["temperature"] * 100)})
        elif capability == "valve":
            await self._command(node, ep, VALVE, "Open" if command == "open" else "Close", {})
        else:
            raise AdapterError(f"no Matter mapping for {capability}.{command}")
        return {"matter_node": node, "endpoint": ep}

    # ------------------------------------------------------------ admin
    async def commission(self, code: str, network_only: bool = False) -> dict[str, Any]:
        node = await self._call("commission_with_code", {"code": code, "network_only": network_only}, timeout=300)
        if isinstance(node, dict):
            self._apply_node(node)
            return {"node_id": node.get("node_id")}
        return {"result": node}
