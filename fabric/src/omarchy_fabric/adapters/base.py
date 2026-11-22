"""Adapter contract: southbound backends (Home Assistant, Matter, GPIO, simulator)."""

from __future__ import annotations

import abc
from typing import TYPE_CHECKING, Any, ClassVar

from ..model import FabricError, Thing

if TYPE_CHECKING:
    from ..fabric import Fabric


class AdapterError(FabricError):
    code = "backend_error"


class Adapter(abc.ABC):
    """An adapter discovers things, keeps their state current through
    fabric.update_state(), and executes normalized commands.

    Adapters never decide policy. By the time execute() is called the request
    has been validated, authorized, possibly approved, and is being audited.
    """

    type: ClassVar[str] = "base"

    def __init__(self, adapter_id: str, options: dict[str, Any] | None = None):
        self.id = adapter_id
        self.options = dict(options or {})
        self.fabric: Fabric | None = None

    def thing_id(self, native_id: str) -> str:
        return f"{self.id}:{native_id}"

    async def start(self, fabric: "Fabric") -> None:
        self.fabric = fabric

    async def stop(self) -> None:
        return None

    @abc.abstractmethod
    async def execute(self, thing: Thing, capability: str, command: str, args: dict[str, Any]) -> dict[str, Any] | None:
        """Carry out one command. Return backend details for the audit log
        (e.g. an HA context id), or None. Raise AdapterError on failure."""
