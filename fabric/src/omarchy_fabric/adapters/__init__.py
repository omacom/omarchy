"""Adapter registry. Imports are lazy so optional dependencies stay optional."""

from __future__ import annotations

import importlib
from typing import TYPE_CHECKING

from .base import Adapter, AdapterError

if TYPE_CHECKING:
    from ..config import AdapterConfig

ADAPTERS = {
    "simulator": ("omarchy_fabric.adapters.simulator", "SimulatorAdapter"),
    "homeassistant": ("omarchy_fabric.adapters.homeassistant", "HomeAssistantAdapter"),
    "matter": ("omarchy_fabric.adapters.matter", "MatterAdapter"),
    "gpio": ("omarchy_fabric.adapters.gpio", "GpioAdapter"),
}


def build_adapters(configs: "list[AdapterConfig]") -> list[Adapter]:
    adapters = []
    for cfg in configs:
        if cfg.type not in ADAPTERS:
            raise ValueError(f"unknown adapter type {cfg.type!r} (known: {', '.join(ADAPTERS)})")
        module_name, cls_name = ADAPTERS[cfg.type]
        cls = getattr(importlib.import_module(module_name), cls_name)
        adapters.append(cls(cfg.id, cfg.options))
    return adapters


__all__ = ["Adapter", "AdapterError", "ADAPTERS", "build_adapters"]
