"""The SSH forced-command bridge: `ofab rpc-stdio` pins the identity, whatever the client claims."""

from __future__ import annotations

import asyncio
import json
import sys
from pathlib import Path

from omarchy_fabric.config import RpcConfig
from omarchy_fabric.model import Assurance, Tier
from omarchy_fabric.policy import AgentPolicy
from omarchy_fabric.rpc import RpcServer


async def test_T03_rpc_stdio_pins_role_and_agent(home, short_tmp):
    sock = short_tmp / "fabric.sock"
    server = RpcServer(home.fabric, RpcConfig(socket=sock, local_assurance=Assurance.DESKTOP))
    await server.start()
    config = short_tmp / "node.toml"
    config.write_text(f'[rpc]\nsocket = "{sock}"\n')
    ofab = Path(sys.executable).with_name("ofab")
    proc = await asyncio.create_subprocess_exec(
        str(ofab), "-c", str(config), "rpc-stdio", "--role", "agent", "--agent", "desk-claude",
        stdin=asyncio.subprocess.PIPE, stdout=asyncio.subprocess.PIPE)

    async def call(mid: int, method: str, **params) -> dict:
        proc.stdin.write((json.dumps({"id": mid, "method": method, "params": params}) + "\n").encode())
        await proc.stdin.drain()
        return json.loads(await asyncio.wait_for(proc.stdout.readline(), 10))

    try:
        hello = await call(1, "hello", role="admin", agent="root")  # a key holder trying to escalate
        assert hello["result"]["role"] == "agent" and hello["result"]["agent"] == "desk-claude"
        # Policy applies to the pinned identity: unknown to policy, it gets the T1 default.
        capped = await call(10, "invoke", thing="sim:kitchen.kettle", command="turn_on", reason="tea")
        assert capped["result"]["code"] == "tier_exceeds_agent"
        home.fabric.config.policy.agents["desk-claude"] = AgentPolicy("desk-claude", Tier.T3)
        pending = await call(2, "invoke", thing="sim:kitchen.kettle", command="turn_on", reason="tea")
        assert pending["result"]["status"] == "pending_approval"
        refused = await call(3, "approve", id=pending["result"]["approval_id"])
        assert refused["error"]["code"] == "forbidden"
        assert home.fabric.approvals.pending()[0].agent == "desk-claude"
    finally:
        proc.stdin.close()
        await asyncio.wait_for(proc.wait(), 10)
        await server.stop()
