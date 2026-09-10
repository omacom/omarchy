# IPU7 camera registration regression

Draft investigation for [#10948](https://github.com/omacom/omarchy/issues/10948). Linux 7.2.3 can leave the Dell XPS OV08X40 camera absent from the IPU7 media graph while the relay service and capture devices still exist. A running relay is insufficient evidence of a working camera.

## Evidence

The captured [fixtures](../test/shell.d/fixtures/ipu7-camera-graph/README.md) show IPU7 waiting for `INTC10E1-0/port@1/endpoint@0`, with no sensor entity registered. Earlier boot logs on the capture machine showed OV08X40 binding under Linux 7.1.8; the 7.2.3 boots did not. The capture machine currently uses edge, so these fixtures must not be presented as a live stable-channel test.

On 10 September 2026, the published [stable](https://pkgs.omarchy.org/stable/x86_64/omarchy.db), [RC](https://pkgs.omarchy.org/rc/x86_64/omarchy.db) and [edge](https://pkgs.omarchy.org/edge/x86_64/omarchy.db) package databases all contained `linux-ptl 7.2.3.arch1-1`. Stable and RC published `intel-ipu7-camera 1.0.5-1`; edge published `1.0.5-2`. The latter is the jsoncpp rebuild in [omarchy-pkgs #361](https://github.com/omacom/omarchy-pkgs/pull/361), not a camera graph fix. No fix for #10948 was identified in the reviewed Omarchy or package development branches. The [dev channel](https://github.com/omacom/omarchy/blob/quattro/bin/omarchy-channel-set) uses a linked source checkout over edge packages, not a fourth package repository. These are dated audit observations, not permanent assertions about channel contents.

## Proposed package correction

Resolve the contract between the kernel's `ipu-bridge` CVS endpoint discovery and the separately packaged `intel_cvs` driver in `omacom/omarchy-pkgs`. IPU7 must not await a V4L2 endpoint which that driver does not register. A maintainer-reviewed compatibility change could preserve the previous sensor graph for the affected Panther Lake IDs until the packaged CVS driver implements the required subdevice. An alternative is to supply that matching driver support. The scope and choice belong with the package maintainers, including checking other CVS hardware before changing discovery.

This draft supplies diagnostic coverage and acceptance criteria only. It changes no installed configuration, package, module, service, sleep hook or kernel, and does not claim a working kernel fix.

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
