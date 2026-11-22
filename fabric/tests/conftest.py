from __future__ import annotations

import copy
import shutil
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import pytest

from omarchy_fabric.config import parse
from omarchy_fabric.fabric import Fabric
from omarchy_fabric.model import InvokeRequest
from omarchy_fabric.util import FakeClock

# A node-grade policy: T2 needs the desktop console, T3 needs physical presence.
BASE: dict[str, Any] = {
    "fabric": {"name": "test-home", "confirm_timeout_s": 0.05},
    "audit": {"enabled": False},
    "adapters": [{"type": "simulator", "id": "sim", "tick_s": 0}],
    "policy": {
        "assurance": {"T2": "desktop", "T3": "presence"},
        "approval_timeout_s": 120,
        "human_hold_s": 600,
        "quiet_hours": {"start": "23:00", "end": "07:00", "escalate_from": "T1"},
        "bounds": [{"capability": "thermostat", "param": "temperature", "min": 16, "max": 24, "note": "comfort band"}],
    },
    "agents": {
        "claude": {"max_tier": "T3"},
        "codex": {"max_tier": "T3"},
        "intern": {"max_tier": "T1", "deny": ["area:entrance"]},
        "*": {"max_tier": "T1"},
    },
}


def merge(base: dict, extra: dict) -> dict:
    out = copy.deepcopy(base)
    for key, value in extra.items():
        if isinstance(value, dict) and isinstance(out.get(key), dict):
            out[key] = merge(out[key], value)
        else:
            out[key] = copy.deepcopy(value)
    return out


@dataclass
class Home:
    fabric: Fabric
    sim: Any
    clock: FakeClock

    async def do(self, agent: str, thing: str, command: str, reason: str = "test", wait_s: float = 0,
                 **args: Any) -> dict:
        return await self.fabric.invoke(InvokeRequest(agent, f"sim:{thing}", command, args, reason, wait_s=wait_s))

    def value(self, thing: str, attr: str) -> Any:
        return self.fabric.registry.values(f"sim:{thing}").get(attr)


@pytest.fixture
def clock() -> FakeClock:
    return FakeClock()


@pytest.fixture
async def make_home(clock):
    started: list[Fabric] = []

    async def factory(extra: dict | None = None) -> Home:
        cfg = parse(merge(BASE, extra or {}))
        fabric = Fabric(cfg, clock=clock)
        await fabric.start()
        started.append(fabric)
        return Home(fabric, fabric.adapters["sim"], clock)

    yield factory
    for fabric in started:
        await fabric.stop()


@pytest.fixture
async def home(make_home) -> Home:
    return await make_home()


@pytest.fixture
def short_tmp():
    """Unix socket paths must stay under ~100 bytes; pytest's tmp_path on macOS does not."""
    path = Path(tempfile.mkdtemp(prefix="ofab-"))  # $TMPDIR: short enough on macOS and Linux
    yield path
    shutil.rmtree(path, ignore_errors=True)
