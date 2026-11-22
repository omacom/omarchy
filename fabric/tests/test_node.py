"""The Pi node's physical controls (gpiozero mock pins), the RPC roles, and MCP."""

from __future__ import annotations

import asyncio
import json
import socket

import pytest

from omarchy_fabric.config import RpcConfig, TokenConfig
from omarchy_fabric.model import Assurance, InvokeRequest
from omarchy_fabric.rpc import RpcClient, RpcError, RpcServer

GPIO = {"adapters": [
    {"type": "simulator", "id": "sim", "tick_s": 0},
    {"type": "gpio", "id": "gpio", "pin_factory": "mock", "devices": [
        {"id": "approve", "kind": "button", "pin": 17, "role": "approve"},
        {"id": "kill", "kind": "button", "pin": 27, "role": "kill_switch"},
        {"id": "status", "kind": "led", "pin": 22, "role": "status"},
        {"id": "fan_relay", "kind": "relay", "pin": 23, "name": "Desk fan"},
        {"id": "hall_pir", "kind": "motion", "pin": 4},
    ]},
]}


async def _press(adapter, dev_id: str) -> None:
    pin = adapter.devices[dev_id].pin
    pin.drive_low()
    await asyncio.sleep(0.02)
    pin.drive_high()
    await asyncio.sleep(0.05)  # gpiozero calls back on its thread; let the loop run it


async def test_S22_physical_button_approves_exactly_one_request(make_home):
    h = await make_home(GPIO)
    gpio = h.fabric.adapters["gpio"]
    visible = {t["id"] for t in h.fabric.list_things()["things"]}
    assert "gpio:approve" not in visible and "gpio:status" not in visible and "gpio:fan_relay" in visible

    first = await h.do("claude", "entrance.front_door", "unlock", reason="guest")
    assert gpio.devices["status"]._blink_thread is not None  # blinking: approval waiting
    second = await h.do("claude", "garage.door", "open", reason="car")
    await _press(gpio, "approve")
    assert (await h.fabric.approval_status(first["approval_id"]))["status"] == "pending_approval"  # ambiguous

    h.fabric.resolve_approval(second["approval_id"], False, "console:desktop", Assurance.DESKTOP)
    await _press(gpio, "approve")
    final = await h.fabric.approval_status(first["approval_id"], wait_s=1)
    assert final["status"] == "executed" and final["approval"]["resolved_by"] == "presence:gpio:approve"
    assert h.value("entrance.front_door", "lock_state") == "unlocked"


async def test_S23_physical_kill_switch_freezes_the_fabric(make_home):
    h = await make_home(GPIO)
    await _press(h.fabric.adapters["gpio"], "kill")
    assert h.fabric.frozen and h.fabric.frozen["by"] == "gpio:kill"
    assert h.fabric.adapters["gpio"].devices["status"].value == 1  # solid
    assert (await h.do("claude", "living_room.lamp", "turn_on"))["code"] == "frozen"


async def test_gpio_relay_defaults_to_an_unknown_load(make_home):
    h = await make_home(GPIO)
    result = await h.fabric.invoke(InvokeRequest("claude", "gpio:fan_relay", "turn_on", {}, "too warm"))
    assert result["tier"] == "T2" and result["status"] == "pending_approval"


def _free_port() -> int:
    with socket.socket() as s:
        s.bind(("127.0.0.1", 0))
        return s.getsockname()[1]


async def test_T01_rpc_roles_tokens_and_events(home, short_tmp):
    port = _free_port()
    rpc = RpcConfig(socket=short_tmp / "fabric.sock", tcp=f"127.0.0.1:{port}", local_assurance=Assurance.DESKTOP,
                    tokens=[TokenConfig("agent", "remote-claude", "agent-secret"),
                            TokenConfig("console", "phone", "console-secret", Assurance.DESKTOP)])
    server = RpcServer(home.fabric, rpc)
    await server.start()
    try:
        agent = await RpcClient.connect(rpc.socket, role="agent", agent="claude")
        console = await RpcClient.connect(rpc.socket, role="console", agent="desktop")
        await console.subscribe()
        events = console.events()
        pending = await agent.call("invoke", thing="sim:kitchen.kettle", command="turn_on", reason="tea")
        assert pending["status"] == "pending_approval"
        with pytest.raises(RpcError) as err:
            await agent.call("approve", id=pending["approval_id"])
        assert err.value.code == "forbidden"
        first = await asyncio.wait_for(events.__anext__(), 2)
        assert first["type"] in ("action", "approval_requested")
        await console.call("approve", id=pending["approval_id"])
        final = await agent.call("approval_status", id=pending["approval_id"], wait_s=2)
        assert final["status"] == "executed"

        remote = await RpcClient.connect(f"tcp://127.0.0.1:{port}", token="agent-secret")
        assert remote.identity["agent"] == "remote-claude" and remote.identity["role"] == "agent"
        with pytest.raises(RpcError):
            await remote.call("thaw")
        with pytest.raises(RpcError):
            await RpcClient.connect(f"tcp://127.0.0.1:{port}", token="wrong")
        for client in (agent, console, remote):
            await client.close()
    finally:
        await server.stop()


async def test_T02_mcp_tools_are_annotated_and_route_through_policy(home):
    from mcp import Client

    from omarchy_fabric.mcp_server import LocalBackend, build_server

    server = build_server(LocalBackend(home.fabric, "claude"))
    async with Client(server) as client:
        tools = {t.name: t for t in (await client.list_tools()).tools}
        assert {"invoke", "simulate", "emergency_stop", "approval_status"} <= set(tools)
        assert not any("approve" == name or "thaw" == name for name in tools)
        assert tools["invoke"].annotations.destructive_hint is True
        assert tools["list_things"].annotations.read_only_hint is True

        def payload(result):
            if result.structured_content:
                return result.structured_content
            return json.loads(result.content[0].text)

        lamp = payload(await client.call_tool("invoke", {"thing_id": "sim:living_room.lamp", "command": "turn_on",
                                                         "reason": "reading"}))
        assert lamp["status"] == "executed"
        door = payload(await client.call_tool("invoke", {"thing_id": "sim:entrance.front_door",
                                                         "command": "unlock", "reason": "guest"}))
        assert door["status"] == "pending_approval" and door["requires"] == "presence"
        missing = payload(await client.call_tool("get_state", {"thing_id": "sim:nope"}))
        assert missing["error"]["code"] == "not_found"
