# IPU7 camera registration regression

Draft investigation for [#10948](https://github.com/omacom/omarchy/issues/10948). Linux 7.2.3 can leave the Dell XPS OV08X40 camera absent from the IPU7 media graph while the relay service and capture devices still exist. A running relay is insufficient evidence of a working camera.

## Evidence

The captured [fixtures](../test/shell.d/fixtures/ipu7-camera-graph/README.md) show IPU7 waiting for `INTC10E1-0/port@1/endpoint@0`, with no sensor entity registered. Earlier boot logs on the capture machine showed OV08X40 binding under Linux 7.1.8; the 7.2.3 boots did not. The capture machine currently uses edge, so these fixtures must not be presented as a live stable-channel test.

On 10 September 2026, the published [stable](https://pkgs.omarchy.org/stable/x86_64/omarchy.db), [RC](https://pkgs.omarchy.org/rc/x86_64/omarchy.db) and [edge](https://pkgs.omarchy.org/edge/x86_64/omarchy.db) package databases all contained `linux-ptl 7.2.3.arch1-1`. Stable and RC published `intel-ipu7-camera 1.0.5-1`; edge published `1.0.5-2`. The latter is the jsoncpp rebuild in [omarchy-pkgs #361](https://github.com/omacom/omarchy-pkgs/pull/361), not a camera graph fix. No fix for #10948 was identified in the reviewed Omarchy or package development branches. The [dev channel](https://github.com/omacom/omarchy/blob/quattro/bin/omarchy-channel-set) uses a linked source checkout over edge packages, not a fourth package repository. These are dated audit observations, not permanent assertions about channel contents.

## Origin and implementation

Linux 7.2 introduced the native CVS V4L2 driver in [8e2b43d2c10b](https://github.com/torvalds/linux/commit/8e2b43d2c10b1b5f42805810c6854470d8774e60), immediately followed by the CVS-aware IPU graph in [c6b1b34b5090](https://github.com/torvalds/linux/commit/c6b1b34b509032c7e7cef9efc63cab55c2ad309e). The intended path is sensor → CVS → IPU. Omarchy adopted the new graph with Linux 7.2.3 while leaving `CONFIG_VIDEO_INTEL_CVS` unset and retaining its legacy `vision-drivers` DKMS module. That older `intel_cvs` does not register the V4L2 endpoint awaited by IPU7.

The coordinated implementation is [omarchy-pkgs #382](https://github.com/omacom/omarchy-pkgs/pull/382), which changes both package definitions:

- Enable the kernel's native CVS driver and prevent the same-named legacy DKMS module from shadowing it. A new camera stack source-directory version lets the normal package removal hook retire the old DKMS registration; legacy kernels retain the legacy driver when native CVS is not configured.
- Integrate Intel's [native CVS HAL support](https://github.com/intel/ipu7-camera-hal/commit/f167239b3ecf242ae081767892cb0a4c54bad496). Extend the existing sensor-format propagation to the native video-interface bridge and propagate configuration errors. This keeps the current IPU75XA sensor configuration and supports direct sensor connections as well as CVS connections.
- Preserve Omarchy's existing firmware-owned sensor-power policy specifically for Synaptics `06cb:0701` with Panther Lake ACPI ID `INTC10E1`. Keep native behaviour on other devices and leave privacy ownership unchanged pending hardware validation.

This implements the candidate native transition using the upstream sensor → CVS → IPU graph. The package candidate has separate build and behavioural tests; the graph check here is its hardware registration acceptance component. No installer migration is needed solely to duplicate the normal package upgrade hooks.

The candidate is not yet hardware-accepted. Native driver compilation and offline HAL/power-policy tests cannot establish video delivery, privacy LED behaviour or suspend recovery. Installation and boot tests require a separately agreed test plan.

## Reproduce the registration failure

The opt-in check reads two saved text files. It does not access device nodes or debugfs itself. Exit status 0 means the limited registration checks passed, 1 means registration failed, and 2 means the input is missing or unsuitable. It does not verify sensor links, frame delivery, suspend recovery or browser capture.

```bash
bash test/hardware/ipu7-camera-graph \
  test/shell.d/fixtures/ipu7-camera-graph/observed-pending.txt \
  test/shell.d/fixtures/ipu7-camera-graph/observed-media.txt
```

Expected result: exit 1 with `IPU7 is waiting for an unregistered Panther Lake CVS endpoint`. The ordinary suite checks that this captured failure remains detectable, alongside explicit synthetic registration expectations and missing-data cases:

```bash
bash test/shell.d/ipu7-camera-graph-test.sh
```

## Acceptance before promotion

- On the affected hardware, capture the pending-subdevice list and complete `media-ctl -p` topology from the same boot for the current stable package set and the proposed package set. Record channel, exact package versions and kernel release with each capture.
- Require the current stable reproduction to fail the registration check and the proposed package set to pass it. Preserve the actual post-change capture separately from the synthetic fixture.
- Verify real frame delivery and browser preview on the proposed packages, then verify the packaged suspend/resume recovery path on a controlled test machine. Passing this text parser alone is not acceptance of a camera repair.
- Use the supported package and boot path for hardware tests. Do not unload or reload the camera modules to exercise this regression.
