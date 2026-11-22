# Hardware list

What to get, in the order it becomes useful. Every automated scenario runs on the simulator with no hardware at all; each phase below unlocks the manual scenarios in [04-scenarios.md](04-scenarios.md) listed next to it.

Product names are examples. For Matter devices, look for the Matter logo and check whether a device uses **Matter over Wi-Fi** (works with just the Pi) or **Matter over Thread** (needs a Thread border router, phase 4).

## Phase 0: what you have

| Item | Notes |
|---|---|
| Raspberry Pi 5, 8 GB | The fabric node. 8 GB comfortably runs Home Assistant, the Matter Server and the fabric together. |
| An Omarchy machine | The console and where your agents run. A Mac or any Linux box works for development with the simulator. |

## Phase 1: a reliable node

| Item | Why | Unlocks |
|---|---|---|
| Official Raspberry Pi 27 W USB-C power supply (5.1 V, 5 A) | A weaker supply makes the Pi 5 limit USB power, which starves radios and SSDs | everything on the Pi |
| Official Active Cooler | Sustained load from HA, the Matter Server and Docker | |
| NVMe SSD (128 GB or more) on an M.2 HAT+, or a high-endurance A2 microSD (32 GB or more) to start | HA's database writes wear out ordinary SD cards | H14 (power loss) |
| A case with room for the cooler and the HAT, or an open bumper while prototyping | | |
| Ethernet cable | Matter and mDNS are more predictable wired; Wi-Fi works too | H05 |
| USB 2.0 extension cable, 0.5–1 m | Keeps 2.4 GHz radio dongles away from USB 3 ports and the Pi's metal, which interfere | phase 4 |

## Phase 2: the node's physical controls (the trust anchor)

These few parts are what make T3 safe: only a person standing at the node can approve an unlock.

| Item | Qty | Unlocks |
|---|---|---|
| Momentary push button (approve) | 1 | S22, H02, H03, H10 |
| Big red momentary button, panel-mount or arcade style (kill switch) | 1 | S23, H04 |
| LED (any colour) and a 330 Ω resistor (status) | 1 | H02–H04 |
| Dupont jumper wires and a small breadboard, or a GPIO screw-terminal HAT for wiring that stays put | 1 set | |
| Optional: piezo buzzer | 1 | an audible "approval waiting" cue (roadmap) |

Wiring (BCM numbers, internal pull-ups, nothing else needed):

| Part | GPIO | Header pin | Other leg |
|---|---|---|---|
| Approve button | GPIO17 | 11 | GND, pin 9 |
| Kill switch | GPIO27 | 13 | GND, pin 14 |
| Status LED | GPIO22 | 15 | 330 Ω, then LED anode; LED cathode to GND, pin 20 |

## Phase 3: Matter devices over Wi-Fi (backward compatibility)

| Item | Qty | Role in the tests | Unlocks |
|---|---|---|---|
| Matter smart plug with energy monitoring (e.g. a Tapo or Meross Matter plug) | 2 | One as an `appliance`; one classified `kind = "heater"` **with a desk lamp plugged in, never a real heater** | H05, H06, H10 |
| Matter colour bulb over Wi-Fi (e.g. a WiZ or LIFX Matter bulb) | 1 | Levels, colours, Omarchy theme sync, a physical override you can feel | H06, H08 |

## Phase 4: Thread

| Item | Qty | Notes | Unlocks |
|---|---|---|---|
| Thread radio for the Pi: Home Assistant Connect ZBT-2 (or the older ZBT-1), or another EFR32 / nRF52840 stick with OpenThread RCP firmware | 1 | One radio does Thread **or** Zigbee, not both. Alternatively use an existing Thread border router (Apple TV / HomePod mini, Nest Hub, Eero) and share its credentials with HA. | H19 |
| Matter-over-Thread contact sensor (e.g. Eve Door & Window, Aqara P2) | 1 | Arrival and "door left open" scenarios | H19 |
| Matter-over-Thread temperature / humidity sensor | 1 | Thermostat and comfort-band scenarios against real readings | H09 |

## Phase 5: build your own Matter devices (the physical-layer kit)

The safest way to test T3 hardware is to build the actuator yourself, so nothing real is at stake.

| Item | Qty | Use |
|---|---|---|
| ESP32-C6 dev board (Wi-Fi 6, Thread / Zigbee radio, BLE) | 2 | Flash Espressif's esp-matter examples: a "door lock" that drives a servo, a "valve" that drives an LED |
| SG90 micro servo | 1 | A visible stand-in for a lock bolt or a valve |
| BME280 or BME680 sensor (I2C) | 1 | Temperature, humidity and pressure (BME680 adds gas) for a DIY Matter sensor |
| PIR motion sensor, 3.3 V friendly (e.g. AM312) | 1 | Occupancy on the Pi's GPIO (`kind = "motion"`) or on an ESP32 |
| Opto-isolated relay module | 1 | **Low-voltage loads only** (a 5 V fan, an LED strip); a GPIO `relay` defaults to T2 |

## Optional extras

| Item | Use |
|---|---|
| A Zigbee radio and a couple of cheap Zigbee devices (IKEA, Aqara) | Zigbee2MQTT -> HA -> fabric (`docker compose --profile zigbee up -d`), H07 |
| Raspberry Pi AI HAT+ and Camera Module 3 | On-device vision for camera-based occupancy: the "AI" in AIoT at the edge (later phase) |
| A spare microSD or NVMe for Omarchy itself | H20: trying Omarchy's ARM build on the Pi 5 and reporting back upstream |
| A USB-C power bank with pass-through, or just the plug | H14: power-loss recovery |

## Safety rules for the testbed

- Never wire mains voltage to the Pi, a relay module or a breadboard. Mains loads go through certified smart plugs.
- Never test "heater" scenarios with a real heater. Plug in a lamp and set `kind = "heater"`.
- Don't connect a real door lock or garage opener until the T3 scenarios pass against the simulator and with the approve button. When you do, start with a hard rule such as `deny` on `kind:garage_door` `open`, and lift it only once you trust the setup.
