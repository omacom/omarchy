# Bluetooth Keyboard Pairing

Read this when helping pair a keyboard or diagnosing a device shown as paired but disconnected.

## Identify the keyboard and check its state

Run `bluetoothctl devices` to list known devices as `Device ADDRESS NAME`. Match the intended keyboard by name and use that row's address wherever `<address>` appears below; do not enter the placeholder literally. If the keyboard is missing, follow the scanning procedure below with the keyboard in pairing mode. If multiple entries have the same name, resolve which address belongs to the intended keyboard and slot before pairing or trusting it; use the user's confirmation and discovery events rather than picking the first match.

Read `bluetoothctl info <address>` and distinguish `Paired`, `Bonded`, `Trusted`, and `Connected`. Trust does not prove that pairing completed. A trusted device with `Paired: no` and `Bonded: no` still needs pairing, even if the panel lists it under paired devices. See [#7879](https://github.com/omacom/omarchy/issues/7879) and [#7880](https://github.com/omacom/omarchy/pull/7880) for the reported panel behavior and proposed fix; check their current status before proposing another code change.

Preserve the user's choice of Bluetooth slot and existing pairings with other computers. Use the address discovered for the selected slot rather than assuming a previous address still applies. Follow the keyboard manufacturer's instructions for entering pairing mode; selecting a slot and putting it into pairing mode can require different key presses.

## Prepare before switching away from wired input

The keyboard being paired may be the user's only way to type. Arrange how terminal prompts will be answered before asking them to switch modes: a second input device, an authorized assistant handling the intended keyboard's prompts, or a temporary return to wired mode. Returning to wired mode may allow the user to answer a terminal prompt, but switching modes can cancel or expire pairing; inspect the result and retry if necessary.

For a terminal attempt, close the Bluetooth panel to avoid competing discovery activity. Start an interactive agent while wired or while another input method is available:

```bash
bluetoothctl --agent KeyboardDisplay
```

Then enter these commands individually, waiting for each response:

```text
default-agent
power on
scan on
```

If `power on` fails because the adapter is rfkill-blocked, run `omarchy bluetooth power on` from a separate shell, then retry. Omarchy's off switch can block the radio, which `bluetoothctl power on` alone does not undo. For other errors, inspect the output before continuing.

If replacing an agent in an existing `bluetoothctl` session, wait for `agent off` to finish before registering its replacement. Keep the interactive session open to receive authorization and passkey prompts.

Watch discovery events for the keyboard's name and address. At the normal command prompt, `devices` lists the devices found so far. Commands below such as `pair`, `trust`, and `connect` are entered inside this interactive session; `bluetoothctl info <address>` is a shell command, or use `info <address>` inside the session.

## Handle incoming requests before issuing commands

After the user switches to Bluetooth and enters pairing mode, inspect the terminal before sending `pair`. A pairing request may already be pending, with a prompt such as `[agent] Accept pairing (yes/no)`. Answer that prompt for the intended keyboard; do not paste another command into it.

Follow the displayed authentication request:

- Answer an acceptance or confirmation prompt in the terminal.
- If instructed to enter a displayed passkey on the Bluetooth keyboard, type it there and press Enter.
- If no request is pending and the device is unpaired, issue `pair <address>` using its discovered address, then handle any prompts.

After pairing completes, issue `trust <address>` and, if needed, `connect <address>`. If the device is already paired or bonded, skip re-pairing and connect as needed. Recheck `info <address>` before reporting success: report pairing/bonding and connection separately, and ask the user to confirm typing works before claiming the keyboard is usable. Accepting `yes` alone does not establish that bonding or connection completed. Keep command errors visible rather than inferring success from the panel's label; stop on failure to inspect the error rather than blindly continuing with the remaining commands.

## Stop monitoring and clean up

When monitoring is requested, watch Bluetooth events and agent prompts and follow the user's agreed stopping condition. USB presence alone is not a reliable mode indicator: a keyboard may remain enumerated while switched to Bluetooth. Do not mistake a temporary return to wired mode to answer a prompt for a request to stop. Stop when the user asks.

Stop discovery started by the troubleshooting session with `scan off`, close its interactive agent with `quit`, and stop any background polling.
