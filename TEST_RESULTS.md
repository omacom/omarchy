## Test Results: Global Workspaces Fixes (P1 + P2)

### Summary
✓ **All 13 tests passed** (13/13 ✓, 0 ✗, 0 ⊘)

### Fixed Issues

#### P1: Critical State-Path & Persistence Issues

**P1.1: State-Path Consistency** ✓
- Fixed `omarchy-switch-to-aw` to use `${XDG_STATE_HOME:-$HOME/.local/state}` instead of hardcoded `~/.local/state`
- `workspace-global.lua` already uses consistent path derivation from HOME
- **Impact**: Global mode flag is now reliably detected regardless of XDG_STATE_HOME configuration

**P1.2: Atomic Writes to monitor-bases.json** ✓
- Updated `write_bases()` in `omarchy-monitor-base` to use `tempfile.mkstemp()` + `os.rename()`
- Updated `allocate_bases()` in `omarchy-monitor-base` with same atomic write pattern
- Added `os.fsync()` for durability before rename
- **Impact**: If a write is interrupted (kill, OOM), the JSON file remains valid with the previous state intact

**P1.3: Background Sync Race Elimination** ✓
- Removed `os.execute("omarchy-monitor-base sync &>/dev/null &")` from `workspace-global.lua`
- Lua's synchronous `save_bases()` is now the authoritative write
- **Impact**: No race condition where a second monitor hotplug during background sync can overwrite allocations with stale data

#### P2: Stale-Mode Recovery

**P2: Bar Widget Re-probe Timer** ✓
- Added `Timer { interval: 2000; running: true; repeat: true; onTriggered: ... }` to `Workspaces.qml`
- Triggers periodic re-probe of the workspace-global.lua flag file
- Matches the recovery pattern documented in Bar.qml
- **Impact**: Widget detects rapid flag changes that FileView.watchChanges might miss; prevents showing wrong slots until shell restart

### Test Coverage

**P1.1 - State-Path Consistency (3 tests)**
- ✓ XDG_STATE_HOME expansion in omarchy-switch-to-aw
- ✓ Fallback to ~/.local/state when XDG_STATE_HOME unset
- ✓ Lua uses consistent path construction

**P1.2 - Atomic Writes (3 tests)**
- ✓ write_bases() uses tempfile.mkstemp()
- ✓ allocate_bases() uses tempfile.mkstemp()
- ✓ Both include fsync() for durability

**P1.3 - Background Sync Race (2 tests)**
- ✓ Executable code does not call omarchy-monitor-base sync
- ✓ pcall() wrapper is gone (only in comments)

**P2 - Stale-Mode Recovery (3 tests)**
- ✓ Timer element present in Workspaces.qml
- ✓ Timer has interval configured (2000ms)
- ✓ Timer.onTriggered calls globalFlagProbe.running = true

**Integration Tests (2 tests)**
- ✓ Shell scripts have valid bash syntax
- ✓ Python imports (json, sys, os, tempfile) validate

### Verification

All fixes are in place and passing static analysis. The test suite is available at:
```
/mnt/ai/projects/omarchy-global-workspaces/test-fixes.sh
```

Run with:
```bash
bash test-fixes.sh
```

### Next Steps
Ready for:
1. Integration testing with actual Hyprland multi-monitor setup
2. Hotplug testing (connect/disconnect monitors, verify stable workspace ranges)
3. Interrupt testing (kill processes during writes, verify JSON integrity)
4. Rapid flag toggle testing (verify widget state consistency)
