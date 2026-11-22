"""Raspberry Pi GPIO: the node's own physical controls, plus simple devices.

Physical controls are what make the Pi the fabric's trust anchor:

  approve button  a short press approves the one pending request (PRESENCE assurance);
                  with several pending it does nothing (the LED blinks fast instead),
                  so one press can never approve the wrong thing. Hold = deny all.
  kill switch     press = freeze every agent action. Thawing needs a console.
  status LED      off = idle, slow blink = an approval is waiting, fast blink =
                  more than one waiting (use a console), solid = frozen.

Devices: led / pwm_led / relay (low voltage only) / button / motion (PIR).
Pins are BCM numbers (GPIO17 = header pin 11). On a Pi 5 gpiozero uses lgpio.
"""

from __future__ import annotations

import asyncio
from typing import Any

from ..model import ORIGIN_DEVICE, ORIGIN_FABRIC, ORIGIN_HUMAN, Thing
from .base import Adapter, AdapterError


class GpioAdapter(Adapter):
    type = "gpio"

    def __init__(self, adapter_id: str, options: dict[str, Any] | None = None):
        super().__init__(adapter_id, options)
        self.specs: list[dict[str, Any]] = list(self.options.get("devices", []))
        self.devices: dict[str, Any] = {}
        self._held: dict[str, bool] = {}
        self._status_leds: list[Any] = []
        self._loop: asyncio.AbstractEventLoop | None = None

    async def start(self, fabric) -> None:
        await super().start(fabric)
        try:
            import gpiozero
        except ImportError:
            fabric.adapter_status(self.id, False, "gpiozero is not installed (pip install 'omarchy-fabric[pi]')")
            return
        if self.options.get("pin_factory") == "mock":
            from gpiozero.pins.mock import MockFactory, MockPWMPin

            gpiozero.Device.pin_factory = MockFactory(pin_class=MockPWMPin)
        self._loop = asyncio.get_running_loop()
        for spec in self.specs:
            self._setup(gpiozero, spec)
        if self._status_leds:
            fabric.registry.listeners.append(self._on_fabric_event)
            self._refresh_led()
        fabric.adapter_status(self.id, True, f"{len(self.devices)} GPIO device(s)")

    async def stop(self) -> None:
        for device in self.devices.values():
            try:
                device.close()
            except Exception:
                pass

    def _later(self, fn, *args) -> None:
        """gpiozero calls back from its own thread; hop onto the fabric's loop."""
        if self._loop is not None:
            self._loop.call_soon_threadsafe(fn, *args)

    def _setup(self, gpiozero, spec: dict[str, Any]) -> None:
        dev_id, kind, pin = spec["id"], spec["kind"], spec["pin"]
        role = spec.get("role", "none")
        name = spec.get("name", dev_id.replace("_", " ").capitalize())
        area = spec.get("area", "node")
        mock = self.options.get("pin_factory") == "mock"
        if kind in ("led", "pwm_led"):
            device = gpiozero.PWMLED(pin) if kind == "pwm_led" else gpiozero.LED(pin)
            caps = ("on_off", "level") if kind == "pwm_led" else ("on_off",)
            state: dict[str, Any] = {"on": False, **({"level": 0} if kind == "pwm_led" else {})}
            thing_kind, expose = "indicator", role != "status"
            if role == "status":
                self._status_leds.append(device)
        elif kind == "relay":
            device = gpiozero.OutputDevice(pin, active_high=spec.get("active_high", True), initial_value=False)
            caps, state, thing_kind, expose = ("on_off",), {"on": False}, spec.get("load", "relay"), True
        elif kind == "button":
            device = gpiozero.Button(pin, pull_up=spec.get("pull_up", True), bounce_time=None if mock else 0.05,
                                     hold_time=float(spec.get("hold_s", 2.0)))
            caps, state, thing_kind = ("button",), {"pressed": False}, "sensor"
            expose = role == "none"
            device.when_pressed = lambda d=dev_id: self._later(self._pressed, d, role)
            device.when_held = lambda d=dev_id: self._later(self._held_cb, d, role)
            device.when_released = lambda d=dev_id: self._later(self._released, d, role)
        elif kind == "motion":
            device = gpiozero.MotionSensor(pin, pull_up=spec.get("pull_up", False))
            caps, state, thing_kind, expose = ("occupancy",), {"occupied": False}, "sensor", True
            device.when_motion = lambda d=dev_id: self._later(self._push, d, {"occupied": True}, ORIGIN_DEVICE)
            device.when_no_motion = lambda d=dev_id: self._later(self._push, d, {"occupied": False}, ORIGIN_DEVICE)
        else:
            raise ValueError(f"gpio device {dev_id}: unknown kind {kind!r}")
        self.devices[dev_id] = device
        self.fabric.add_thing(
            Thing(id=self.thing_id(dev_id), name=name, adapter=self.id, native_id=dev_id, capabilities=caps,
                  area=area, kind=spec.get("thing_kind", thing_kind), expose=expose,
                  meta={"pin": f"GPIO{pin}", "role": role}),
            state=state,
        )

    def _push(self, dev_id: str, attrs: dict[str, Any], origin: str) -> None:
        self.fabric.update_state(self.thing_id(dev_id), attrs, origin)

    # ------------------------------------------------------------ buttons
    def _pressed(self, dev_id: str, role: str) -> None:
        self._held[dev_id] = False
        self._push(dev_id, {"pressed": True}, ORIGIN_HUMAN)
        if role == "kill_switch":
            self.fabric.freeze(f"gpio:{dev_id}", "physical kill switch")

    def _held_cb(self, dev_id: str, role: str) -> None:
        self._held[dev_id] = True
        if role == "approve":
            self.fabric.presence_deny_all(f"gpio:{dev_id}")

    def _released(self, dev_id: str, role: str) -> None:
        self._push(dev_id, {"pressed": False}, ORIGIN_HUMAN)
        if role == "approve" and not self._held.get(dev_id):
            self.fabric.presence_press(f"gpio:{dev_id}")

    # ------------------------------------------------------------ status LED
    def _on_fabric_event(self, event: dict[str, Any]) -> None:
        if event.get("type") in ("approval_requested", "approval_resolved", "freeze", "thaw"):
            self._refresh_led()

    def _refresh_led(self) -> None:
        pending = len(self.fabric.approvals.pending())
        for led in self._status_leds:
            if self.fabric.frozen:
                led.on()
            elif pending == 1:
                led.blink(on_time=0.4, off_time=0.4)
            elif pending > 1:
                led.blink(on_time=0.1, off_time=0.1)
            else:
                led.off()

    # ------------------------------------------------------------ execution
    async def execute(self, thing: Thing, capability: str, command: str, args: dict[str, Any]) -> dict[str, Any]:
        device = self.devices.get(thing.native_id)
        if device is None:
            raise AdapterError(f"unknown GPIO device {thing.native_id}")
        if capability == "on_off":
            {"turn_on": device.on, "turn_off": device.off, "toggle": device.toggle}[command]()
            attrs: dict[str, Any] = {"on": bool(device.value)}
            if hasattr(device, "value") and "level" in thing.capabilities:
                attrs["level"] = round(float(device.value) * 100)
        elif capability == "level":
            device.value = args["level"] / 100
            attrs = {"level": round(args["level"]), "on": args["level"] > 0}
        else:
            raise AdapterError(f"GPIO cannot run {capability}.{command}")
        self._push(thing.native_id, attrs, ORIGIN_FABRIC)
        return {"pin": thing.meta.get("pin")}
