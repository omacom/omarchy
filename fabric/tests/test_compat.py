"""Backward compatibility: Home Assistant and Matter, over their real WebSocket protocols."""

from __future__ import annotations

import asyncio

from omarchy_fabric.config import parse
from omarchy_fabric.fabric import Fabric
from omarchy_fabric.model import InvokeRequest

from .fakes import HA_TOKEN, FakeHomeAssistant, FakeMatterServer

POLICY = {"assurance": {"T2": "desktop", "T3": "presence"}, "human_hold_s": 600}
AGENTS = {"claude": {"max_tier": "T3"}}


async def _connected(fabric: Fabric, adapter: str) -> None:
    ok = await fabric.registry.wait_for(lambda: fabric.adapter_health.get(adapter, {}).get("connected"), 5)
    assert ok, fabric.adapter_health


async def _ha_fabric(ha: FakeHomeAssistant, things: dict | None = None, **options) -> Fabric:
    cfg = parse({"fabric": {"confirm_timeout_s": 1}, "audit": {"enabled": False},
                 "adapters": [{"type": "homeassistant", "id": "ha", "url": ha.url, "token": HA_TOKEN, **options}],
                 "things": things or {}, "policy": POLICY, "agents": AGENTS})
    fabric = Fabric(cfg)
    await fabric.start()
    await _connected(fabric, "ha")
    return fabric


async def test_C01_ha_discovery_maps_entities_areas_and_kinds():
    async with FakeHomeAssistant() as ha:
        fabric = await _ha_fabric(ha)
        try:
            things = {t["id"]: t for t in fabric.list_things()["things"]}
            assert "ha:sensor.aqi" not in things and "ha:light.disabled_one" not in things
            lamp = things["ha:light.living_lamp"]
            assert lamp["area"] == "Living Room" and lamp["capabilities"] == ["on_off", "level", "color"]
            assert things["ha:cover.garage"]["kind"] == "garage_door"
            assert things["ha:switch.space_heater"]["kind"] == "plug"  # unknown load until configured
            assert fabric.registry.values("ha:sensor.outdoor")["temperature"] == 10.0  # 50 °F
        finally:
            await fabric.stop()


async def test_C02_ha_command_round_trip_is_attributed_to_the_fabric():
    async with FakeHomeAssistant() as ha:
        fabric = await _ha_fabric(ha)
        try:
            result = await fabric.invoke(InvokeRequest("claude", "ha:light.living_lamp", "set_level", {"level": 50}, "test"))
            assert result["status"] == "executed" and result["confirmed"]
            call = ha.calls[-1]
            assert (call["domain"], call["service"], call["service_data"]) == ("light", "turn_on", {"brightness_pct": 50})
            assert call["target"] == {"entity_id": "light.living_lamp"}
            assert fabric.registry.state["ha:light.living_lamp"]["level"].origin == "fabric"
            assert "human_hold" not in fabric.get_state("ha:light.living_lamp")
        finally:
            await fabric.stop()


async def test_C03_ha_wall_switch_and_ui_changes_trigger_human_hold():
    async with FakeHomeAssistant() as ha:
        fabric = await _ha_fabric(ha)
        try:
            await ha.broadcast_change("light.living_lamp", "on", {"brightness": 255})  # no user, no parent
            await fabric.registry.wait_for(lambda: fabric.registry.values("ha:light.living_lamp").get("on"), 2)
            assert fabric.registry.state["ha:light.living_lamp"]["on"].origin == "external"
            denied = await fabric.invoke(InvokeRequest("claude", "ha:light.living_lamp", "set_level", {"level": 10}, "dim"))
            assert denied["code"] == "human_hold"
            await ha.broadcast_change("lock.front_door", "unlocked", user_id="someone-in-the-app")
            await fabric.registry.wait_for(
                lambda: fabric.registry.values("ha:lock.front_door").get("lock_state") == "unlocked", 2)
            assert fabric.registry.state["ha:lock.front_door"]["lock_state"].origin == "human"
            await ha.broadcast_change("switch.space_heater", "on", parent_id="automation-run")
            await fabric.registry.wait_for(lambda: fabric.registry.values("ha:switch.space_heater").get("on"), 2)
            assert fabric.registry.state["ha:switch.space_heater"]["on"].origin == "automation"
            assert "human_hold" not in fabric.get_state("ha:switch.space_heater")
        finally:
            await fabric.stop()


async def test_C04_ha_config_reclassifies_a_plug_as_a_heater_and_converts_units():
    async with FakeHomeAssistant(temp_unit="°F") as ha:
        fabric = await _ha_fabric(ha, things={"ha:switch.space_heater": {"kind": "heater", "area": "Bedroom"}})
        try:
            heater = await fabric.invoke(InvokeRequest("claude", "ha:switch.space_heater", "turn_on", {}, "cold"))
            assert heater["tier"] == "T3" and heater["requires"] == "presence"
            assert fabric.registry.values("ha:climate.hallway")["current_temperature"] == 20.0  # 68 °F
            await fabric.invoke(InvokeRequest("claude", "ha:climate.hallway", "set_target_temperature",
                                              {"temperature": 21}, "warmer"))
            assert ha.calls[-1]["service_data"] == {"temperature": 69.8}
        finally:
            await fabric.stop()


async def test_C05_ha_can_leave_matter_devices_to_the_matter_adapter():
    async with FakeHomeAssistant() as ha:
        for entity in ("lock.front_door", "light.living_lamp"):
            ha.platforms[entity] = "matter"
        fabric = await _ha_fabric(ha, exclude_integrations=["matter"])
        try:
            ids = {t["id"] for t in fabric.list_things()["things"]}
            assert "ha:lock.front_door" not in ids and "ha:light.living_lamp" not in ids
            assert "ha:switch.space_heater" in ids
        finally:
            await fabric.stop()


async def test_C06_ha_disconnect_takes_things_offline():
    async with FakeHomeAssistant() as ha:
        fabric = await _ha_fabric(ha)
    try:
        await fabric.registry.wait_for(lambda: not fabric.adapter_health["ha"]["connected"], 5)
        result = await fabric.invoke(InvokeRequest("claude", "ha:light.living_lamp", "turn_on", {}, "test"))
        assert result["code"] == "offline"
    finally:
        await fabric.stop()


async def _matter_fabric(server: FakeMatterServer) -> Fabric:
    cfg = parse({"fabric": {"confirm_timeout_s": 1}, "audit": {"enabled": False},
                 "adapters": [{"type": "matter", "id": "matter", "url": server.url}],
                 "policy": POLICY, "agents": AGENTS})
    fabric = Fabric(cfg)
    await fabric.start()
    await _connected(fabric, "matter")
    return fabric


async def test_C07_matter_discovery_maps_clusters_to_capabilities():
    async with FakeMatterServer() as server:
        fabric = await _matter_fabric(server)
        try:
            things = {t["id"]: t for t in fabric.list_things()["things"]}
            assert things["matter:1/1"]["name"] == "Desk bulb"
            assert things["matter:1/1"]["capabilities"] == ["on_off", "level", "color"]
            assert things["matter:2/1"]["kind"] == "lock"
            assert fabric.registry.values("matter:1/1")["color_temp_kelvin"] == 2703
            assert fabric.registry.values("matter:3/1")["temperature"] == 21.5
            assert fabric.registry.values("matter:3/2")["open"] is False  # StateValue true = closed
            assert fabric.registry.values("matter:4/1") == {"mode": "heat", "current_temperature": 19.5,
                                                            "target_temperature": 20.0}
        finally:
            await fabric.stop()


async def test_C08_matter_commands_use_spec_units_and_timed_lock_invokes():
    async with FakeMatterServer() as server:
        fabric = await _matter_fabric(server)
        try:
            result = await fabric.invoke(InvokeRequest("claude", "matter:1/1", "set_level", {"level": 50}, "test"))
            assert result["status"] == "executed" and result["confirmed"]
            assert server.commands[-1]["command_name"] == "MoveToLevelWithOnOff"
            assert server.commands[-1]["payload"]["level"] == 127
            assert fabric.registry.state["matter:1/1"]["level"].origin == "fabric"

            pending = await fabric.invoke(InvokeRequest("claude", "matter:2/1", "unlock", {}, "guest"))
            assert pending["requires"] == "presence"
            fabric.presence_press("gpio:test")
            final = await fabric.approval_status(pending["approval_id"], wait_s=2)
            assert final["status"] == "executed"
            assert server.commands[-1]["timed_request_timeout_ms"] == 1000
            assert fabric.registry.values("matter:2/1")["lock_state"] == "unlocked"

            await fabric.invoke(InvokeRequest("claude", "matter:4/1", "set_target_temperature", {"temperature": 21.5}, "t"))
            assert server.commands[-1] == {"write": {"node_id": 4, "attribute_path": "1/513/18", "value": 2150}}
        finally:
            await fabric.stop()


async def test_C09_matter_device_side_change_counts_as_external():
    async with FakeMatterServer() as server:
        fabric = await _matter_fabric(server)
        try:
            await server.set_attribute(1, "1/6/0", True)  # someone pressed the bulb's own switch
            await fabric.registry.wait_for(lambda: fabric.registry.values("matter:1/1").get("on"), 2)
            assert fabric.registry.state["matter:1/1"]["on"].origin == "external"
            assert "human_hold" in fabric.get_state("matter:1/1")
            await asyncio.sleep(0)
        finally:
            await fabric.stop()

