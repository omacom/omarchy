# Fingerprint authentication

Omarchy selects the fingerprint backend automatically from the hardware.

## Supported readers

Most readers are handled by stock `libfprint` plus `fprintd`. ThinkPad T470-style
Validity readers (`138a:0097` and close relatives) are instead handled by
`python-validity` + `open-fprintd`.

Supported USB IDs: `138a:0090`, `138a:0097`, `138a:009d`, and `06cb:009a`.

## Validity recovery

Validity sensors can lock after an unexpected access and need firmware to be
re-uploaded. Run:

```bash
omarchy-fingerprint-repair
```

Then wait about 15 seconds before re-enrolling:

```bash
omarchy setup security fingerprint
```

The repair utility intentionally performs a factory reset, so enrolled prints are
cleared. Healthy sensors should use enroll/verify directly rather than running
repair.
