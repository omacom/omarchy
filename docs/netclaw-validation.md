# NetClaw validation record

The current validation record is [NetClaw test results](netclaw-test-results.md). It contains the automated suite results, native VM checks, sanitized real NetClaw MCP outputs, screenshots, reproduced defects and remaining work.

As of 2026-09-10, 358 checks pass across eleven suites, with 17 focused checks rerun after extending network timeouts. The native VM registers all 227 NetClaw skills. Actual NetClaw collection passed 14 device commands and two four-device pyATS pcall batches (8/8 results), and generated a live Markmap that was opened and screenshotted. The four-device CML network has OSPF, iBGP, router-on-a-stick, four host VLANs, DHCP and switch edge protections configured; direct router-to-host checks returned 40/40 replies. NetBox created and read back 62 scoped demo records. ServiceNow created and independently verified 13 objects, and a fresh post-restart MCP read confirmed the current credentials. All 75 NetBox/ServiceNow validation records were removed after screenshots, with deletion and absence verified. Draw.io was opened in its editor; Three.js rendered and its zoom/R2 inspector were captured; whole-scene labels benefit from zoom. The operator confirmed native Dashboard operation and reboot/login testing on 2026-09-10. NetClaw also generated a workbook and handover deck through its document MCP; Obsidian, Calc and Impress were visually checked in the native VM.

Both the native Try Omarchy ARM64 desktop VM and the separate OrbStack x86-64 Linux lab remain in place. The native VM is a development overlay on the existing desktop, not a newly published distro image. Its temporary VNC viewer is stopped.

[Watch the recorded Omarchy + NetClaw demonstration on YouTube](https://youtu.be/nEp0g5rC6Hk).

After the full submenu and dedicated Chat session were restored, 179 focused checks passed across four suites. A VPN interruption was reproduced from both Mac and VM, then resolved by the operator. Fresh actual NetClaw four-device pcall collection subsequently passed all 8/8 results at 14:04 EDT. The detailed report preserves both the failure and recovery.
