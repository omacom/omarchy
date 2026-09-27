# Bluetooth Keyboard Pairing

Read this when helping pair a keyboard or diagnosing a device shown as paired but disconnected.

## Check the actual state

Read `bluetoothctl info <address>` and distinguish `Paired`, `Bonded`, `Trusted`, and `Connected`. Trust permits a device to connect without further authorization; it does not prove that pairing completed. A trusted device with `Paired: no` and `Bonded: no` still needs pairing, even if the panel lists it under paired devices. See [#7879](https://github.com/omacom/omarchy/issues/7879) and [#7880](https://github.com/omacom/omarchy/pull/7880) for the reported panel behavior and proposed fix; check their current status before proposing another code change.

Preserve the user's choice of Bluetooth slot and existing pairings with other computers. Use the address discovered for the selected slot rather than assuming a previous address still applies. Follow the keyboard manufacturer's instructions for entering pairing mode; selecting a slot and putting it into pairing mode can require different key presses.

## Prepare before switching away from wired input

The keyboard being paired may be the user's only way to type. Arrange how terminal prompts will be answered before asking them to switch modes: a second input device, an authorized assistant handling the intended keyboard's prompts, or a temporary return to wired mode.

For a terminal attempt, close the Bluetooth panel to avoid competing discovery activity. Start an interactive agent while wired:

```bash
bluetoothctl --agent KeyboardDisplay
```

Then enter these commands individually, waiting for each response:

```text
default-agent
power on
scan on
```

If replacing an agent in an existing `bluetoothctl` session, wait for `agent off` to finish before registering its replacement. Keep the interactive session open to receive authorization and passkey prompts.

## Handle incoming requests before issuing commands

After the user switches to Bluetooth and enters pairing mode, inspect the terminal before sending `pair`. A pairing request may already be pending, with a prompt such as `[agent] Accept pairing (yes/no)`. Answer that prompt for the intended keyboard; do not paste another command into it.

A Keychron B1 Pro user observed this prompt after scanning and switching to Bluetooth. They temporarily returned to wired mode, entered `yes`, then switched back to Bluetooth. This is an observed way to answer the prompt, not confirmation of successful bonding or a guaranteed workaround for every keyboard. Switching modes may expire the request; if that happens, retry and preserve the actual error.

Follow the displayed authentication request:

- Answer an acceptance or confirmation prompt in the terminal.
- If instructed to enter a displayed passkey on the Bluetooth keyboard, type it there and press Enter.
- If no request is pending and the device is unpaired, issue `pair <address>` using its discovered address, then handle any prompts.

After pairing completes, issue `trust <address>` and, if needed, `connect <address>`. Recheck `bluetoothctl info <address>` before reporting success. Accepting `yes` alone does not establish that bonding or connection completed. Keep command errors visible rather than inferring success from the panel's label.

## Stop monitoring and clean up

When monitoring is requested, watch Bluetooth events and agent prompts. USB presence alone is not a reliable mode indicator: a keyboard may remain enumerated while switched to Bluetooth. Stop when the user asks, including when they report returning to wired mode.

Stop discovery started by the troubleshooting session with `scan off`, close its interactive agent with `quit`, and stop any background polling.
