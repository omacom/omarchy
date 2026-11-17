# Contribution seams

| Upstream file | Change |
| --- | --- |
| install/hardware/fix-bcm43xx.sh | BCM4360 package selection; preserve installed driver; stock fallback |
| test/shell.d/hardware-quirks-test.sh | Execute selection, availability and failure cases |
| manual/44-mac-support.md | Experimental driver and recovery path |

The existing CI runs the hardware suite through test/all.
The local no-mistakes gate uses the same hardware suite.
