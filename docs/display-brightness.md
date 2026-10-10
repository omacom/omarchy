# Display panel brightness

The Display panel resolves a selected compositor output to a hardware brightness endpoint. Its metadata refresh reads sysfs without probing DDC; brightness requests run separately, only while the panel is open. Slider updates are coalesced, failures use bounded retries, and stale process results cannot update a different selection.

## Device selection

- DDC uses an explicit I²C bus and the selected screen's EDID together. This requires ddcutil 2.2.4 or newer. Kernel connector links are preferred; MST discovery is repeated when a direct link is absent. Identical EDIDs without a kernel route are ambiguous. The panel does not use the global brightness helper's cached bus mapping.
- Internal backlights use connector ancestry, or one backlight and one internal panel on the same GPU. Competing drivers and unrelated platform backlights are ambiguous; there is no first-device fallback.
- Apple HID devices require a unique match between the compositor display serial and USB serial. The current adapter supports verified ranges for USB products `05ac:1114` and `05ac:9243`. Other Apple models remain unavailable until their mapping and range are verified. Permission checks are noninteractive.

A sysfs identity token accompanies writes. The endpoint is checked before writing and before accepting readback. These checks reduce hotplug races; they cannot make separate compositor, sysfs, and hardware operations atomic. Readback reports the value returned by the device, which can differ from the requested value.

The response distinguishes `available`, `ambiguous`, `disconnected`, `busy`, `timeout`, `permission_denied`, `unsupported`, `missing_dependency`, `invalid_config`, `invalid_value`, and `io_error`. A generic `VCP 10 ERR` is an I/O error, not proof that brightness is unsupported.

## Scope and verified groups

A DDC channel does not establish physical backlight independence. Its default scope is `unknown`. A matched internal or supported Apple endpoint uses `display`. Shared scope requires an explicit group in `$XDG_CONFIG_HOME/omarchy/display-brightness.json` (normally `~/.config/omarchy/display-brightness.json`). This optional file must only describe behavior verified on the hardware:

```json
{
  "groups": [
    {
      "controller": "<controller display hardwareId>",
      "members": ["<controller display hardwareId>", "<second display hardwareId>"]
    }
  ]
}
```

Replace each placeholder with a `hardwareId` from `omarchy-shell omarchy.monitor state`. IDs are SHA-256 hashes of the full EDID. The controller must be a group member. Groups cannot overlap, duplicate identities are rejected, and a disconnected controller never falls back to another display. A one-member group explicitly records independent behavior. No group is inferred from a brand, model, or matching serial number.

This adapter currently applies to the Display panel. Existing brightness-key commands retain their own implementation and need a separate compatibility review before adopting the same backend.

## Validation limits

Regression tests simulate hotplug, replacement devices, duplicated identities, shared groups, permissions, timeouts, range conversion, and readback. Physical read-only validation so far covers a two-output DDC/MST device: one output responds, the other reports a communication error. Internal backlights, Apple hardware, and confirmed shared groups still need physical validation. This is not a claim of independent brightness support for every monitor.
