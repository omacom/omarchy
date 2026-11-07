# Omarchy triage — 2026-10-01

Covered **170** open items (#13949–#13740), finishing the unfinished 2026-09-30 backlog. **6 workers** (1 recheck + 5 ranges). Nothing posted.

## Recheck (prior jandrusk comments)
- **#13063** — new commit after LGTM; draft re-LGTM
- **#13734** — author asked next steps / conflicts; still dirty; draft reply
- No action: #13018, #13041, #13064–#13071, #13112, #13151, #13176, #13724, #13725 (blocking still unanswered)

## Blocking / high-priority

- **#13922** (issue): Enterprise PEAP without CA — rogue-AP credential capture (pair with #13947)
- **#13947** (pr): Require CA/server validation for enterprise Wi-Fi (fix for #13922)
- **#13885** (pr): README rewrite into personal-fork notes — do not merge as-is
- **#13879** (pr): `browser_command` always returns after first .desktop
- **#13889** (pr): Conflicts with #13867 — both add migrations/1790703856.sh
- **#13867** (pr): Migration stamp clash with #13889
- **#13818** (pr): Lock wake int vs real coords (CHANGES_REQUESTED)
- **#13856** (pr): Claude bypassPermissions default — product hold / security-sensitive
- **#13816** (pr): Prefer #13703 Codex RPC; CONFLICTING
- **#13804** (pr): 2s clock poll concern
- **#13778** (pr): Lid-inhibit unit packaging/PATH
- **#13936** (pr): /tmp lock hardening — merge before sibling lock PRs
- **#13937** (pr): Update log atomic claim
- **#13906** (issue): Fingerprint 250ms retry loop (cluster with #13944/#13748/#9905)

## Duplicate / cluster highlights
- Fingerprint retry: #13944 → #13906 / #13748 / #10393 / #11918 / #12461
- Enterprise Wi-Fi CA: #13922 + #13947
- Sunshine Alias unit: #13877 + #13925
- Idle Qt timer overflow: #13920 + #13921
- OverlayWindow / unplug monitors: #13882 → #13903
- Menu submenu Backspace: #13896 (8 open PRs)
- Bar toggle: #13846 → #7023…
- Codex RPC race: #13773 / #13816 → prefer #13703
- Setgid Windows VM: #13750 cluster
- Update inhibitor locale: #13892 → #13352
- /tmp locks: #13933/#13934/#13936/#13937 (land #13936 first)

## Needs more info
- **#13943**: Dual Monitor Support is Buggy — Need Omarchy version, hyprctl monitors/workspaces output, exact bind/config used for pairing, steps to reproduce vanishi
- **#13927**: Shell exits with a fatal Wayland error when the monitor wakes while lo — Ask for WAYLAND_DEBUG of the fatal request and a repro with third-party plugins disabled (author notes plugins were load
- **#13904**: External monitors stay at 0x0 after resume from a USB-C dock — omarchy/Hyprland versions of a minimal reproduce without scale 1.5 if possible; whether a hotplug `hyprctl reload` or `d
- **#13900**: omarchy screen recording keybinding (alt + printscreen) doesn’t — hyprctl layers / overlay state when the flash happens; whether external monitor / overlay-park bug (#13882) is in play; 
- **#13890**: Dual-GPU Macs: after resume, the lock screen's blank resets the gmux b — Whether omarchy-brightness path or hyprland DPMS is what blanks; does disabling lock blank avoid it; linux-t2 issue link
- **#13873**: Codex Desktop stays on 'Starting your task' and never dispatches threa — Exact fixed upstream version / desired package version in omarchy-pkgs; confirm still broken on latest desktop build.
- **#13849**: linux-omarchy 7.2.5: mt7925e cannot associate with any BSS — Retest on stock Arch linux 7.2.3 to separate omarchy patches vs upstream 7.2 regression (reporter notes this gap).
- **#13822**: ollama 0.33.3: tool-call requests that don't match the PEG grammar are — Confirm whether Omarchy's ollama package is a fork with peg-native patches vs upstream; link upstream issue if any.

## Product calls (sample)
- **#13941**: Add OneCloud to Install > Service
- **#13918**: Show fingerprint reader state on the lock screen, and fade the lock over the desktop
- **#13912**: Nightlight: mouse cursor outline turns fluorescent blue on NVIDIA (hardware cursor not tin
- **#13883**: Add an opt-in bar ticker for incoming agent messages
- **#13874**: Diagnose captured logs with the selected coding agent
- **#13872**: Review local Git changes with the selected coding agent
- **#13871**: Diagnose services with the selected coding agent
- **#13868**: Run saved tasks with the selected coding agent
- **#13856**: Launch Claude with a real permission bypass
- **#13851**: Fix clock widget rendering weekday/month names in English regardless of locale
- **#13797**: Smooth out battery time
- **#13789**: feat(bar): choose visible widgets per display

## Ready for review: 82 items
(See per-range report.md for the full list.)

## Drafted comments (NOT posted) — 72 total

### Priority shortlist (recommend reviewing these first)
- #13063: `/workspace/omarchy-triage-2026-10-01/recheck/drafts/13063.md`
- #13734: `/workspace/omarchy-triage-2026-10-01/recheck/drafts/13734.md`
- #13778: `/workspace/omarchy-triage-2026-10-01/ranges/range-4-13816-13776/drafts/13778.md`
- #13804: `/workspace/omarchy-triage-2026-10-01/ranges/range-4-13816-13776/drafts/13804.md`
- #13816: `/workspace/omarchy-triage-2026-10-01/ranges/range-4-13816-13776/drafts/13816.md`
- #13818: `/workspace/omarchy-triage-2026-10-01/ranges/range-3-13866-13817/drafts/13818.md`
- #13856: `/workspace/omarchy-triage-2026-10-01/ranges/range-3-13866-13817/drafts/13856.md`
- #13867: `/workspace/omarchy-triage-2026-10-01/ranges/range-2-13908-13867/drafts/13867.md`
- #13875: `/workspace/omarchy-triage-2026-10-01/ranges/range-2-13908-13867/drafts/13875.md`
- #13879: `/workspace/omarchy-triage-2026-10-01/ranges/range-2-13908-13867/drafts/13879.md`
- #13885: `/workspace/omarchy-triage-2026-10-01/ranges/range-2-13908-13867/drafts/13885.md`
- #13889: `/workspace/omarchy-triage-2026-10-01/ranges/range-2-13908-13867/drafts/13889.md`
- #13903: `/workspace/omarchy-triage-2026-10-01/ranges/range-2-13908-13867/drafts/13903.md`
- #13906: `/workspace/omarchy-triage-2026-10-01/ranges/range-2-13908-13867/drafts/13906.md`
- #13921: `/workspace/omarchy-triage-2026-10-01/ranges/range-1-13949-13909/drafts/13921.md`
- #13922: `/workspace/omarchy-triage-2026-10-01/ranges/range-1-13949-13909/drafts/13922.md`
- #13927: `/workspace/omarchy-triage-2026-10-01/ranges/range-1-13949-13909/drafts/13927.md`
- #13933: `/workspace/omarchy-triage-2026-10-01/ranges/range-1-13949-13909/drafts/13933.md`
- #13934: `/workspace/omarchy-triage-2026-10-01/ranges/range-1-13949-13909/drafts/13934.md`
- #13935: `/workspace/omarchy-triage-2026-10-01/ranges/range-1-13949-13909/drafts/13935.md`
- #13936: `/workspace/omarchy-triage-2026-10-01/ranges/range-1-13949-13909/drafts/13936.md`
- #13937: `/workspace/omarchy-triage-2026-10-01/ranges/range-1-13949-13909/drafts/13937.md`
- #13943: `/workspace/omarchy-triage-2026-10-01/ranges/range-1-13949-13909/drafts/13943.md`
- #13944: `/workspace/omarchy-triage-2026-10-01/ranges/range-1-13949-13909/drafts/13944.md`
- #13945: `/workspace/omarchy-triage-2026-10-01/ranges/range-1-13949-13909/drafts/13945.md`
- #13946: `/workspace/omarchy-triage-2026-10-01/ranges/range-1-13949-13909/drafts/13946.md`
- #13947: `/workspace/omarchy-triage-2026-10-01/ranges/range-1-13949-13909/drafts/13947.md`

### All draft numbers
#13063, #13734, #13740, #13741, #13744, #13746, #13747, #13748, #13750, #13752, #13754, #13756, #13758, #13760, #13767, #13772, #13773, #13778, #13792, #13800, #13804, #13806, #13808, #13810, #13813, #13816, #13817, #13818, #13819, #13830, #13833, #13845, #13850, #13851, #13856, #13857, #13859, #13861, #13867, #13868, #13875, #13877, #13879, #13880, #13882, #13885, #13889, #13892, #13893, #13896, #13903, #13906, #13908, #13911, #13912, #13918, #13921, #13922, #13925, #13927, #13928, #13933, #13934, #13935, #13936, #13937, #13941, #13943, #13944, #13945, #13946, #13947

Details: `/workspace/omarchy-triage-2026-10-01/` (ranges/*/report.md, drafts/, merged/).
