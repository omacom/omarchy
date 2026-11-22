"""Thing registry: current state, availability, origin attribution, event fan-out."""

from __future__ import annotations

import asyncio
from collections import deque
from typing import Any, Callable

from . import catalog
from .model import (
    ORIGIN_DEVICE,
    ORIGIN_EXTERNAL,
    ORIGIN_FABRIC,
    ORIGIN_INITIAL,
    AttrValue,
    Thing,
)
from .util import Clock

Listener = Callable[[dict], None]


def _same(a: Any, b: Any) -> bool:
    if isinstance(a, float) or isinstance(b, float):
        try:
            return abs(float(a) - float(b)) < 1e-6
        except (TypeError, ValueError):
            return False
    return a == b


class Registry:
    def __init__(self, clock: Clock, history: int = 500):
        self.clock = clock
        self.things: dict[str, Thing] = {}
        self.state: dict[str, dict[str, AttrValue]] = {}
        self.online: dict[str, bool] = {}
        self.events: deque[dict] = deque(maxlen=history)
        self.listeners: list[Listener] = []
        # (thing, attr) -> (deadline, predicted value, value before the command)
        self._fabric_window: dict[tuple[str, str], tuple[float, Any, Any]] = {}
        self.last_human_change: dict[str, tuple[float, str, str]] = {}  # thing -> (ts, attr, origin)
        self._changed = asyncio.Event() if _has_loop() else None
        self._seq = 0

    # ------------------------------------------------------------ events
    def emit(self, event: dict) -> None:
        self._seq += 1
        event = {"seq": self._seq, "ts": self.clock.now(), **event}
        self.events.append(event)
        for listener in list(self.listeners):
            try:
                listener(event)
            except Exception:  # a broken listener must never break the fabric
                pass
        self._notify()

    def _notify(self) -> None:
        if self._changed is None and _has_loop():
            self._changed = asyncio.Event()
        if self._changed is not None:
            self._changed.set()
            self._changed = asyncio.Event()

    async def wait_for(self, predicate: Callable[[], bool], timeout: float) -> bool:
        """Wait until predicate() is true or timeout passes (real time)."""
        loop = asyncio.get_running_loop()
        deadline = loop.time() + timeout
        while not predicate():
            remaining = deadline - loop.time()
            if remaining <= 0:
                return False
            if self._changed is None:
                self._changed = asyncio.Event()
            try:
                await asyncio.wait_for(self._changed.wait(), remaining)
            except asyncio.TimeoutError:
                return predicate()
        return True

    # ------------------------------------------------------------ things
    def upsert(self, thing: Thing, state: dict[str, Any] | None = None, online: bool = True) -> None:
        new = thing.id not in self.things
        self.things[thing.id] = thing
        self.state.setdefault(thing.id, {})
        now = self.clock.now()
        for attr, value in (state or {}).items():
            current = self.state[thing.id].get(attr)
            if current is None or not _same(current.value, value):
                self.state[thing.id][attr] = AttrValue(value, now, ORIGIN_INITIAL)
        self.online[thing.id] = online
        if new:
            self.emit({"type": "thing_added", "thing": thing.id})

    def remove(self, thing_id: str) -> None:
        if self.things.pop(thing_id, None) is not None:
            self.state.pop(thing_id, None)
            self.online.pop(thing_id, None)
            self.emit({"type": "thing_removed", "thing": thing_id})

    def get(self, thing_id: str) -> Thing | None:
        return self.things.get(thing_id)

    def set_online(self, thing_id: str, online: bool) -> None:
        if thing_id in self.things and self.online.get(thing_id) != online:
            self.online[thing_id] = online
            self.emit({"type": "availability", "thing": thing_id, "online": online})

    # ------------------------------------------------------------ state
    def values(self, thing_id: str) -> dict[str, Any]:
        return {k: v.value for k, v in self.state.get(thing_id, {}).items()}

    def expect(self, thing_id: str, attrs: set[str], window_s: float,
               predicted: dict[str, Any] | None = None) -> None:
        """Record what a fabric command is expected to change. During the window, a
        change counts as the fabric's only if it reaches the predicted value or moves
        toward it; anything else (the person who flips the light straight back off)
        is external, so human hold still protects them."""
        deadline = self.clock.now() + window_s
        values = self.values(thing_id)
        predicted = predicted or {}
        for attr in attrs:
            self._fabric_window[(thing_id, attr)] = (deadline, predicted.get(attr), values.get(attr))

    def _attribute(self, thing_id: str, attr: str, value: Any, now: float) -> bool:
        entry = self._fabric_window.get((thing_id, attr))
        if not entry:
            return False
        deadline, target, start = entry
        if now > deadline:
            del self._fabric_window[(thing_id, attr)]
            return False
        if target is None:  # affected but not predicted (cover_state, power...): accept
            return True
        if _same(value, target) or (isinstance(target, (int, float)) and isinstance(value, (int, float))
                                    and not isinstance(target, bool) and abs(float(value) - float(target)) <= 1.0):
            del self._fabric_window[(thing_id, attr)]  # reached: later changes are someone else's
            return True
        numeric = all(isinstance(x, (int, float)) and not isinstance(x, bool) for x in (value, target, start))
        if numeric and min(start, target) <= value <= max(start, target):
            return True  # in transit toward the target (a door opening, a fade)
        return False

    def update(self, thing_id: str, attrs: dict[str, Any], origin: str | None = None) -> list[dict]:
        """Apply attribute updates. `origin` comes from the adapter when it knows
        (HA context, simulator); otherwise changes inside a fabric command window
        count as fabric, and anything else on an actuated attribute is external."""
        thing = self.things.get(thing_id)
        if thing is None:
            return []
        now = self.clock.now()
        actuated = catalog.actuated_attributes(thing)
        changes = []
        current = self.state.setdefault(thing_id, {})
        for attr, value in attrs.items():
            prev = current.get(attr)
            if prev is not None and _same(prev.value, value):
                prev.updated_at = now  # still reporting: refresh freshness, no event
                continue
            who = origin
            if who is None:
                if self._attribute(thing_id, attr, value, now):
                    who = ORIGIN_FABRIC
                elif attr in actuated:
                    who = ORIGIN_EXTERNAL
                else:
                    who = ORIGIN_DEVICE
            current[attr] = AttrValue(value, now, who)
            change = {
                "type": "state",
                "thing": thing_id,
                "attr": attr,
                "old": None if prev is None else prev.value,
                "new": value,
                "origin": who,
            }
            if attr in actuated and who not in (ORIGIN_FABRIC, ORIGIN_DEVICE, ORIGIN_INITIAL):
                self.last_human_change[thing_id] = (now, attr, who)
            changes.append(change)
            self.emit(change)
        return changes


def _has_loop() -> bool:
    try:
        asyncio.get_running_loop()
        return True
    except RuntimeError:
        return False
