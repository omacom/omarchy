"""Policy engine: decides allow / confirm / deny for every physical action.

Order of evaluation (first two groups can never be overridden by rules):

  guards      frozen -> agent permissions -> offline -> bounds -> human hold
              -> lease -> rate limit / circuit breaker
  base        tier -> effect (default T0/T1 allow, T2/T3 confirm) + required assurance
  rules       first matching user rule may set the effect (allow / confirm / deny)
  escalation  unknown state on T2+ -> confirm; quiet hours -> confirm

"Safer" commands (lock, heater off, valve close, stop) stay available while
frozen or during a human hold: agents can always make things safer.
"""

from __future__ import annotations

import datetime as dt
from dataclasses import dataclass, field
from typing import Any

from .model import Assurance, Decision, Effect, Thing, Tier
from .util import glob, match_thing


@dataclass
class AgentPolicy:
    name: str
    max_tier: Tier = Tier.T1
    things: tuple[str, ...] = ("*",)
    deny: tuple[str, ...] = ()


@dataclass
class Bound:
    param: str
    min: float | None = None
    max: float | None = None
    thing: str = "*"
    capability: str = "*"
    note: str = ""


@dataclass
class Rule:
    effect: Effect
    agent: str = "*"
    thing: str = "*"
    capability: str = "*"
    command: str = "*"
    min_tier: Tier | None = None
    assurance: Assurance | None = None
    note: str = ""

    def matches(self, agent: str, thing: Thing, cap_id: str, command: str, tier: Tier) -> bool:
        return (
            glob(self.agent, agent)
            and match_thing(self.thing, thing)
            and glob(self.capability, cap_id)
            and glob(self.command, command)
            and (self.min_tier is None or tier >= self.min_tier)
        )


@dataclass
class QuietHours:
    start: dt.time
    end: dt.time
    escalate_from: Tier = Tier.T1

    def active(self, local: dt.datetime) -> bool:
        now = local.time()
        if self.start <= self.end:
            return self.start <= now < self.end
        return now >= self.start or now < self.end  # crosses midnight


def _default_effects() -> dict[Tier, Effect]:
    return {Tier.T0: Effect.ALLOW, Tier.T1: Effect.ALLOW, Tier.T2: Effect.CONFIRM, Tier.T3: Effect.CONFIRM}


def _default_assurance() -> dict[Tier, Assurance]:
    return {Tier.T0: Assurance.CLI, Tier.T1: Assurance.DESKTOP, Tier.T2: Assurance.DESKTOP,
            Tier.T3: Assurance.PRESENCE}


@dataclass
class PolicyConfig:
    tier_effects: dict[Tier, Effect] = field(default_factory=_default_effects)
    tier_assurance: dict[Tier, Assurance] = field(default_factory=_default_assurance)
    approval_timeout_s: float = 120.0
    human_hold_s: float = 600.0
    human_hold_origins: tuple[str, ...] = ("human", "external")
    allow_safer_when_frozen: bool = True
    allow_safer_during_hold: bool = True
    rate_per_agent_per_minute: int = 30
    rate_per_thing_per_minute: int = 6
    suspend_after_denials_per_minute: int = 10
    suspend_s: float = 300.0
    lease_max_s: float = 3600.0
    quiet_hours: QuietHours | None = None
    bounds: list[Bound] = field(default_factory=list)
    rules: list[Rule] = field(default_factory=list)
    agents: dict[str, AgentPolicy] = field(default_factory=dict)

    def agent(self, name: str) -> AgentPolicy | None:
        return self.agents.get(name) or self.agents.get("*")


@dataclass
class Context:
    """Everything the engine needs, gathered by the fabric for one request."""

    agent: str
    thing: Thing
    capability: str
    command: str
    args: dict[str, Any]
    tier: Tier
    safer: bool
    online: bool
    frozen: bool
    local_time: dt.datetime
    human_hold_left_s: float = 0.0
    human_hold_attr: str = ""
    lease_holder: str | None = None
    lease_left_s: float = 0.0
    rate_ok: bool = True
    rate_code: str = "ok"
    rate_retry_s: float = 0.0
    state_known: bool = True
    approved: Assurance = Assurance.NONE  # set when re-evaluating an approved request


class PolicyEngine:
    def __init__(self, config: PolicyConfig):
        self.config = config

    def _deny(self, ctx: Context, code: str, reason: str) -> Decision:
        return Decision(Effect.DENY, ctx.tier, code, [reason], safer=ctx.safer)

    def evaluate(self, ctx: Context) -> Decision:
        c = self.config
        what = f"{ctx.capability}.{ctx.command} on {ctx.thing.id}"

        # ---------------------------------------------------------- guards
        if ctx.frozen and not (ctx.safer and c.allow_safer_when_frozen):
            return self._deny(ctx, "frozen", "the fabric is frozen (emergency stop); only safer actions run")

        agent = c.agent(ctx.agent)
        if agent is None:
            return self._deny(ctx, "unknown_agent", f"agent {ctx.agent!r} has no policy")
        if not any(match_thing(p, ctx.thing) for p in agent.things) or any(
            match_thing(p, ctx.thing) for p in agent.deny
        ):
            return self._deny(ctx, "not_permitted", f"agent {ctx.agent!r} may not control {ctx.thing.id}")
        if ctx.tier > agent.max_tier:
            return self._deny(
                ctx, "tier_exceeds_agent",
                f"{what} is {ctx.tier}; agent {ctx.agent!r} is limited to {agent.max_tier}",
            )

        if not ctx.online:
            return self._deny(ctx, "offline", f"{ctx.thing.id} is offline or its backend is disconnected")

        for bound in c.bounds:
            if bound.param in ctx.args and glob(bound.capability, ctx.capability) and match_thing(bound.thing, ctx.thing):
                value = ctx.args[bound.param]
                if (bound.min is not None and value < bound.min) or (bound.max is not None and value > bound.max):
                    lo = "-inf" if bound.min is None else bound.min
                    hi = "inf" if bound.max is None else bound.max
                    note = f" ({bound.note})" if bound.note else ""
                    return self._deny(
                        ctx, "out_of_bounds",
                        f"{bound.param}={value} is outside the allowed range [{lo}, {hi}]{note}",
                    )

        if ctx.human_hold_left_s > 0 and not (ctx.safer and c.allow_safer_during_hold):
            minutes = max(1, round(ctx.human_hold_left_s / 60))
            return self._deny(
                ctx, "human_hold",
                f"a person changed {ctx.thing.id} ({ctx.human_hold_attr}) recently; agents yield "
                f"for about {minutes} more minute(s)",
            )

        if ctx.lease_holder and ctx.lease_holder != ctx.agent and not ctx.safer:
            return self._deny(
                ctx, "leased",
                f"{ctx.thing.id} is leased by agent {ctx.lease_holder!r} for {round(ctx.lease_left_s)}s more",
            )

        if not ctx.rate_ok:
            msg = ("agent is suspended after repeated denials" if ctx.rate_code == "agent_suspended"
                   else "rate limit reached")
            return self._deny(ctx, ctx.rate_code, f"{msg}; retry in {round(ctx.rate_retry_s)}s")

        # ---------------------------------------------------------- base
        effect = c.tier_effects.get(ctx.tier, Effect.CONFIRM)
        assurance = c.tier_assurance.get(ctx.tier, Assurance.PRESENCE)
        code = "tier"
        reasons = [f"{what} is {ctx.tier}"]

        # ---------------------------------------------------------- rules
        for rule in c.rules:
            if rule.matches(ctx.agent, ctx.thing, ctx.capability, ctx.command, ctx.tier):
                effect = rule.effect
                if rule.assurance is not None:
                    assurance = rule.assurance
                code = "rule"
                reasons.append(f"rule: {rule.note or rule.effect.value}")
                break

        if effect == Effect.DENY:
            return Decision(Effect.DENY, ctx.tier, code, reasons, safer=ctx.safer)

        # ---------------------------------------------------------- escalation
        if effect == Effect.ALLOW and ctx.tier >= Tier.T2 and not ctx.state_known and not ctx.safer:
            effect, code = Effect.CONFIRM, "state_unknown"
            reasons.append("current state is unknown, so a human should confirm")
        if (
            effect == Effect.ALLOW
            and c.quiet_hours is not None
            and ctx.tier >= c.quiet_hours.escalate_from
            and not ctx.safer
            and c.quiet_hours.active(ctx.local_time)
        ):
            effect, code = Effect.CONFIRM, "quiet_hours"
            assurance = max(assurance, Assurance.DESKTOP)
            reasons.append("quiet hours are active")

        if effect == Effect.CONFIRM and ctx.approved >= assurance:
            return Decision(Effect.ALLOW, ctx.tier, "approved", reasons + [f"approved ({ctx.approved})"],
                            safer=ctx.safer)
        return Decision(effect, ctx.tier, code, reasons,
                        assurance if effect == Effect.CONFIRM else Assurance.NONE, safer=ctx.safer)
