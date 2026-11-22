"""Protocol-level fakes of Home Assistant's and the Matter Server's WebSocket APIs.

They speak the real message shapes (auth handshake, ids, results, events), so the
adapters are tested against the wire protocol, not against mocks of themselves.
"""

from __future__ import annotations

import copy
import json
import uuid
from typing import Any

from websockets.asyncio.server import serve

HA_TOKEN = "good-token"


class FakeHomeAssistant:
    def __init__(self, temp_unit: str = "°C"):
        self.temp_unit = temp_unit
        self.user_id = "fabric-user"
        self.calls: list[dict[str, Any]] = []
        self.clients: set = set()
        self.server = None
        self.platforms: dict[str, str] = {}  # entity_id -> integration, default "demo"
        self.states: dict[str, dict[str, Any]] = {}
        for entity_id, state, attrs in [
            ("light.living_lamp", "off", {"friendly_name": "Living Lamp", "supported_color_modes": ["color_temp", "hs"]}),
            ("switch.space_heater", "off", {"friendly_name": "Space Heater"}),
            ("lock.front_door", "locked", {"friendly_name": "Front Door"}),
            ("climate.hallway", "heat", {"friendly_name": "Hallway", "current_temperature": 68, "temperature": 70}),
            ("sensor.outdoor", "50", {"friendly_name": "Outdoor", "device_class": "temperature", "unit_of_measurement": "°F"}),
            ("sensor.aqi", "42", {"friendly_name": "Air quality", "device_class": "aqi"}),
            ("cover.garage", "closed", {"friendly_name": "Garage", "device_class": "garage", "current_position": 0}),
            ("binary_sensor.front_door", "off", {"friendly_name": "Front door contact", "device_class": "door"}),
            ("light.disabled_one", "off", {"friendly_name": "Disabled", "supported_color_modes": ["onoff"]}),
        ]:
            self.states[entity_id] = {"entity_id": entity_id, "state": state, "attributes": attrs,
                                      "context": {"id": uuid.uuid4().hex, "user_id": None, "parent_id": None}}

    @property
    def url(self) -> str:
        port = self.server.sockets[0].getsockname()[1]
        return f"ws://127.0.0.1:{port}/api/websocket"

    async def __aenter__(self):
        self.server = await serve(self._handler, "127.0.0.1", 0).__aenter__()
        return self

    async def __aexit__(self, *exc):
        self.server.close()
        await self.server.wait_closed()

    async def _send(self, ws, msg: dict[str, Any]) -> None:
        await ws.send(json.dumps(msg))

    async def broadcast_change(self, entity_id: str, state: str, attributes: dict[str, Any] | None = None, *,
                               user_id: str | None = None, parent_id: str | None = None,
                               context_id: str | None = None) -> None:
        old = copy.deepcopy(self.states[entity_id])
        new = copy.deepcopy(old)
        new["state"] = state
        new["attributes"].update(attributes or {})
        new["context"] = {"id": context_id or uuid.uuid4().hex, "user_id": user_id, "parent_id": parent_id}
        self.states[entity_id] = new
        for ws, sub_id in list(self.clients):
            await self._send(ws, {"id": sub_id, "type": "event", "event": {
                "event_type": "state_changed", "data": {"entity_id": entity_id, "old_state": old, "new_state": new},
                "origin": "LOCAL", "context": new["context"]}})

    async def _apply(self, domain: str, service: str, data: dict[str, Any], entity_id: str, ctx: str) -> None:
        s = self.states[entity_id]
        attrs = dict(s["attributes"])
        state = s["state"]
        if service == "turn_on":
            state = "on"
            if "brightness_pct" in data:
                attrs["brightness"] = round(data["brightness_pct"] * 255 / 100)
            elif domain == "light" and not attrs.get("brightness"):
                attrs["brightness"] = 255
            if "color_temp_kelvin" in data:
                attrs["color_temp_kelvin"] = data["color_temp_kelvin"]
        elif service == "turn_off":
            state, attrs["brightness"] = "off", None
        elif service in ("lock", "unlock"):
            state = "locked" if service == "lock" else "unlocked"
        elif service == "set_temperature":
            attrs["temperature"] = data["temperature"]
        elif service == "open_cover":
            state, attrs["current_position"] = "open", 100
        await self.broadcast_change(entity_id, state, attrs, user_id=self.user_id, context_id=ctx)

    async def _handler(self, ws) -> None:
        await self._send(ws, {"type": "auth_required", "ha_version": "2026.11.1"})
        auth = json.loads(await ws.recv())
        if auth.get("access_token") != HA_TOKEN:
            await self._send(ws, {"type": "auth_invalid", "message": "Invalid access token"})
            return
        await self._send(ws, {"type": "auth_ok", "ha_version": "2026.11.1"})
        try:
            async for raw in ws:
                msg = json.loads(raw)
                kind, mid = msg["type"], msg["id"]
                result: Any = None
                if kind == "get_config":
                    result = {"unit_system": {"temperature": self.temp_unit}, "version": "2026.11.1"}
                elif kind == "auth/current_user":
                    result = {"id": self.user_id, "name": "Omarchy Fabric", "is_admin": True}
                elif kind == "config/entity_registry/list":
                    result = [{"entity_id": e, "device_id": "dev-lamp" if e == "light.living_lamp" else None,
                               "area_id": "garage" if e == "cover.garage" else None,
                               "platform": self.platforms.get(e, "demo"),
                               "disabled_by": "user" if e == "light.disabled_one" else None, "hidden_by": None}
                              for e in self.states]
                elif kind == "config/area_registry/list":
                    result = [{"area_id": "living_room", "name": "Living Room"}, {"area_id": "garage", "name": "Garage"}]
                elif kind == "config/device_registry/list":
                    result = [{"id": "dev-lamp", "area_id": "living_room", "manufacturer": "Signify", "model": "Hue Go"}]
                elif kind == "subscribe_events":
                    self.clients.add((ws, mid))
                elif kind == "get_states":
                    result = list(self.states.values())
                elif kind == "call_service":
                    self.calls.append(msg)
                    ctx = uuid.uuid4().hex
                    entity_id = msg["target"]["entity_id"]
                    # Real HA often emits state_changed before the call's result: test that race.
                    await self._apply(msg["domain"], msg["service"], msg.get("service_data") or {}, entity_id, ctx)
                    result = {"context": {"id": ctx, "parent_id": None, "user_id": self.user_id}, "response": None}
                await self._send(ws, {"id": mid, "type": "result", "success": True, "result": result})
        finally:
            self.clients = {(c, s) for c, s in self.clients if c is not ws}


class FakeMatterServer:
    def __init__(self):
        self.commands: list[dict[str, Any]] = []
        self.clients: set = set()
        self.server = None
        self.nodes: dict[int, dict[str, Any]] = {
            1: {"node_id": 1, "available": True, "is_bridge": False, "attributes": {
                "0/40/1": "Acme", "0/40/3": "Smart Bulb", "0/40/5": "Desk bulb",
                "1/29/0": [{"0": 269, "1": 1}], "1/6/0": False, "1/8/0": 0, "1/768/7": 370,
                "1/768/0": 0, "1/768/1": 0}},
            2: {"node_id": 2, "available": True, "is_bridge": False, "attributes": {
                "0/40/3": "Smart Lock", "1/29/0": [{"0": 10, "1": 1}], "1/257/0": 1}},
            3: {"node_id": 3, "available": True, "is_bridge": False, "attributes": {
                "0/40/3": "Door sensor", "1/29/0": [{"0": 770, "1": 1}], "1/1026/0": 2150,
                "2/29/0": [{"0": 21, "1": 1}], "2/69/0": True}},
            4: {"node_id": 4, "available": True, "is_bridge": False, "attributes": {
                "0/40/3": "Thermostat", "1/29/0": [{"0": 769, "1": 1}], "1/513/0": 1950, "1/513/18": 2000,
                "1/513/28": 4}},
        }

    @property
    def url(self) -> str:
        return f"ws://127.0.0.1:{self.server.sockets[0].getsockname()[1]}/ws"

    async def __aenter__(self):
        self.server = await serve(self._handler, "127.0.0.1", 0).__aenter__()
        return self

    async def __aexit__(self, *exc):
        self.server.close()
        await self.server.wait_closed()

    async def set_attribute(self, node: int, path: str, value: Any) -> None:
        self.nodes[node]["attributes"][path] = value
        for ws in list(self.clients):
            await ws.send(json.dumps({"event": "attribute_updated", "data": [node, path, value]}))

    async def _handler(self, ws) -> None:
        await ws.send(json.dumps({"fabric_id": 1, "compressed_fabric_id": 1234, "schema_version": 11,
                                  "min_supported_schema_version": 9, "sdk_version": "2026.10.0",
                                  "wifi_credentials_set": False, "thread_credentials_set": False,
                                  "bluetooth_enabled": False}))
        try:
            async for raw in ws:
                msg = json.loads(raw)
                mid, command, args = msg["message_id"], msg["command"], msg.get("args") or {}
                reply: dict[str, Any] = {"message_id": mid, "result": None}
                if command == "start_listening":
                    self.clients.add(ws)
                    reply["result"] = list(self.nodes.values())
                elif command == "device_command":
                    self.commands.append(args)
                    node, ep, cluster, name = args["node_id"], args["endpoint_id"], args["cluster_id"], args["command_name"]
                    if cluster == 257 and not args.get("timed_request_timeout_ms"):
                        reply = {"message_id": mid, "error_code": 1, "details": "NEEDS_TIMED_INTERACTION"}
                    elif cluster == 6:
                        await self.set_attribute(node, f"{ep}/6/0", name == "On")
                    elif cluster == 8:
                        await self.set_attribute(node, f"{ep}/8/0", args["payload"]["level"])
                        await self.set_attribute(node, f"{ep}/6/0", args["payload"]["level"] > 0)
                    elif cluster == 257:
                        await self.set_attribute(node, f"{ep}/257/0", 1 if name == "LockDoor" else 2)
                elif command == "write_attribute":
                    self.commands.append({"write": args})
                    await self.set_attribute(args["node_id"], args["attribute_path"], args["value"])
                    reply["result"] = [{"Path": args["attribute_path"], "Status": 0}]
                await ws.send(json.dumps(reply))
        finally:
            self.clients.discard(ws)
