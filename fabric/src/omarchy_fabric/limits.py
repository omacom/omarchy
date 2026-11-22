"""Rate limits, denial circuit breaker, and per-thing leases for multi-agent arbitration."""

from __future__ import annotations

from collections import defaultdict, deque
from dataclasses import dataclass

from .model import FabricError


class SlidingWindow:
    def __init__(self, limit: int, window_s: float = 60.0):
        self.limit = limit
        self.window_s = window_s
        self._hits: dict[str, deque[float]] = defaultdict(deque)

    def _trim(self, key: str, now: float) -> deque[float]:
        hits = self._hits[key]
        while hits and hits[0] <= now - self.window_s:
            hits.popleft()
        return hits

    def count(self, key: str, now: float) -> int:
        return len(self._trim(key, now))

    def allowed(self, key: str, now: float) -> bool:
        return self.limit <= 0 or self.count(key, now) < self.limit

    def retry_after(self, key: str, now: float) -> float:
        hits = self._trim(key, now)
        if self.limit <= 0 or len(hits) < self.limit:
            return 0.0
        return max(0.0, hits[0] + self.window_s - now)

    def hit(self, key: str, now: float) -> None:
        self._trim(key, now).append(now)


class RateLimits:
    """Per-agent and per-(agent, thing) action budgets, plus a circuit breaker:
    an agent that keeps getting denied (a prompt-injected loop, a confused
    planner) is suspended for a while and the human is told."""

    def __init__(self, per_agent: int = 30, per_thing: int = 6,
                 suspend_after_denials: int = 10, suspend_s: float = 300.0):
        self.per_agent = SlidingWindow(per_agent)
        self.per_thing = SlidingWindow(per_thing)
        self.denials = SlidingWindow(suspend_after_denials)
        self.suspend_s = suspend_s
        self.suspended_until: dict[str, float] = {}

    def check(self, agent: str, thing_id: str, now: float) -> tuple[bool, str, float]:
        until = self.suspended_until.get(agent, 0.0)
        if now < until:
            return False, "agent_suspended", until - now
        if not self.per_agent.allowed(agent, now):
            return False, "rate_limited", self.per_agent.retry_after(agent, now)
        key = f"{agent}|{thing_id}"
        if not self.per_thing.allowed(key, now):
            return False, "rate_limited", self.per_thing.retry_after(key, now)
        return True, "ok", 0.0

    def record_action(self, agent: str, thing_id: str, now: float) -> None:
        self.per_agent.hit(agent, now)
        self.per_thing.hit(f"{agent}|{thing_id}", now)

    def record_denial(self, agent: str, now: float) -> bool:
        """Returns True when this denial trips the breaker."""
        if self.denials.limit <= 0:
            return False
        self.denials.hit(agent, now)
        if self.denials.count(agent, now) >= self.denials.limit and now >= self.suspended_until.get(agent, 0):
            self.suspended_until[agent] = now + self.suspend_s
            return True
        return False

    def lift(self, agent: str) -> None:
        self.suspended_until.pop(agent, None)


@dataclass
class Lease:
    thing_id: str
    agent: str
    expires_at: float
    purpose: str = ""

    def to_dict(self, now: float) -> dict:
        return {"thing": self.thing_id, "agent": self.agent, "purpose": self.purpose,
                "expires_in_s": round(max(0.0, self.expires_at - now))}


class LeaseConflict(FabricError):
    code = "leased"


class LeaseTable:
    """Advisory-for-the-holder, enforced-for-everyone-else exclusive control.
    Two agents should not fight over the thermostat; the first to lease it wins
    until the lease expires or is released. Humans are never subject to leases."""

    def __init__(self, max_ttl_s: float = 3600.0):
        self.max_ttl_s = max_ttl_s
        self._leases: dict[str, Lease] = {}

    def holder(self, thing_id: str, now: float) -> Lease | None:
        lease = self._leases.get(thing_id)
        if lease and lease.expires_at <= now:
            del self._leases[thing_id]
            return None
        return lease

    def acquire(self, agent: str, thing_id: str, ttl_s: float, now: float, purpose: str = "") -> Lease:
        ttl_s = max(1.0, min(float(ttl_s), self.max_ttl_s))
        current = self.holder(thing_id, now)
        if current and current.agent != agent:
            raise LeaseConflict(
                f"{thing_id} is leased by {current.agent} for another "
                f"{round(current.expires_at - now)}s ({current.purpose or 'no purpose given'})"
            )
        lease = Lease(thing_id, agent, now + ttl_s, purpose)
        self._leases[thing_id] = lease
        return lease

    def release(self, agent: str, thing_id: str, now: float) -> bool:
        current = self.holder(thing_id, now)
        if current and current.agent == agent:
            del self._leases[thing_id]
            return True
        return False

    def all(self, now: float) -> list[Lease]:
        return [lease for t in list(self._leases) if (lease := self.holder(t, now))]
