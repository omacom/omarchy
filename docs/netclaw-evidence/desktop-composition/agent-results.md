# Results Ledger — NetClaw `document-mcp` Installation Smoke Test

**Date run:** 2026-09-10 (America/Toronto)
**Host:** netclaw (Omarchy)
**Nature of run:** installation smoke test / replay of previously measured evidence.
No network device or ServiceNow was queried during this session. No GUI application
was launched. No community plugin was installed. No separate virtual desktop was
started.

## Server under test

- Server: `document-mcp` (NetClaw-authored, spec 082 / roadmap R18)
- Invocation: real MCP stdio server, called through the actual client —
  `python3 "$MCP_CALL" "$DOCUMENT_MCP_CMD" <tool> '<json-args>'`
- `DOCUMENT_MCP_CMD` resolved for this run to:
  `/home/netclaw/omarchy/netclaw-python/bin/python3 -u /home/netclaw/omarchy/netclaw/mcp-servers/document-mcp/server.py`
  (this env var was not pre-set on the host; no `document.json`/`document.py` launcher
  file existed yet under `~/.local/share/omarchy/netclaw-launchers/`, unlike pyats/
  netbox/servicenow. The command above was constructed directly from the skill's
  declared `DOCUMENT_MCP_CMD` requirement and confirmed working.)
- Dependencies confirmed present in `/home/netclaw/omarchy/netclaw-python` (shared
  venv): `python-docx 1.2.0`, `openpyxl 3.1.5`, `python-pptx 1.0.2`,
  `pymupdf 1.28.2` (imports as `fitz`), `mcp` — matching the pinned ranges in
  `mcp-servers/document-mcp/requirements.txt`.
- Output directory (server-owned, resolved from server `__file__`):
  `/home/netclaw/omarchy/netclaw/workspace/output/document-mcp/`

## Evidence source (replayed, not re-collected)

- `showcase/cml-pcall-evidence.json` (sanitized)
- `showcase/cml-pcall-validation.md` (sanitized)
- Original collection timestamps preserved exactly:
  - `show ip interface brief` batch — **2026-09-10T11:41:18-04:00**
  - `show version` batch — **2026-09-10T11:41:41-04:00**
- Devices: R1, R2, SW1, SW2 — all 4/4 success in both batches, tool
  `pyats_pcall_show_command`, concurrency `pcall (process per device)`.

## Tool calls made and outcomes

### 1. `list_documents` (pre-check, read-only)

- Arguments: `{}`
- Outcome: `ok`
- Result: `directory: /home/netclaw/omarchy/netclaw/workspace/output/document-mcp`,
  `count: 0` (baseline — confirms the server and output path are live before writing
  anything)

### 2. `xlsx_write` — Device Facts workbook

- Arguments: one sheet `"Device Facts"`, columns `Device`, `IOS XE Version`,
  `Interface Count`; 4 rows (R1, R2, SW1, SW2); `failed_rows: []`
- Every cell sent as a tagged value: `{"v": ..., "src": "pyats_pcall_show_command(...)",
  "device": "...", "as_of": "..."}`
- **No merged interface-status column** — this sheet reports counts only, never an
  admin/operational status merge (the server's `reject_merged_status` guard was not
  triggered because no status column was requested at all).
- **Outcome returned: `ok`** — 0 unavailable, 0 failed, 0 caveats
- **Path returned:**
  `workspace/output/document-mcp/xlsx-20260910T165050Z-desktop-composition-device-facts.xlsx`
  (relative to `/home/netclaw/omarchy/netclaw`)
- Bytes: 6507
- `sources_consulted`: 8 entries — `pyats_pcall_show_command(show ip interface brief)`
  ×4 devices (as_of 2026-09-10T11:41:18-04:00) and
  `pyats_pcall_show_command(show version)` ×4 devices (as_of 2026-09-10T11:41:41-04:00),
  all `status: ok`

### 3. `pptx_write` — Handover deck

- Arguments: title "NetClaw document-generation — Installation Smoke Test Handover";
  4 content slides (Purpose & Scope; Device Software Versions — figure slide;
  Recorded Interface Counts — figure slide; Explicit Limits of This Test)
- Every figure sent as a tagged value with `src`, `device`, `as_of`
- Bullet slides carry `detail_ref: "Sources"` pointing at the server-appended Sources
  slide
- **Outcome returned: `ok`** — 0 unavailable, 0 failed, 0 caveats
- **Path returned:**
  `workspace/output/document-mcp/pptx-20260910T165106Z-desktop-composition-handover.pptx`
  (relative to `/home/netclaw/omarchy/netclaw`)
- Bytes: 42536
- `sources_consulted`: same 8 source entries as above, all `status: ok`
- Deck includes the server's auto-appended title-page stamp, per-slide visible Source
  line (not speaker notes), and a final Sources slide

### 4. `list_documents` (post-check, read-only)

- Outcome: `ok`
- `count: 2`, listing both files above by name/kind/bytes/modified — confirms the
  server's own record matches the filesystem

## Files copied into this validation folder

Both generated documents were copied (not moved) from the server's real output
directory into `showcase/desktop-composition-validation/documents/`, kept separate
from the operator's forthcoming recording:

- `documents/xlsx-20260910T165050Z-desktop-composition-device-facts.xlsx`
- `documents/pptx-20260910T165106Z-desktop-composition-handover.pptx`

## Obsidian-compatible vault

`showcase/desktop-composition-validation/vault/`:

- `Home.md` — entry point; links to all device notes, the collection note, and both
  generated documents (relative path into `../documents/`)
- `R1.md`, `R2.md`, `SW1.md`, `SW2.md` — one note per device, each with its own
  measured version/interface-count/source/as-of table
- `Collection.md` — the two-batch `pyats_pcall_show_command` collection summary

All notes use standard `[[WikiLink]]` syntax; no community plugins were installed or
required.

## Git repository (local only, no push)

- A new Git repository was initialized **only** inside
  `showcase/desktop-composition-validation/` (not at the workspace root, and no
  existing repository elsewhere was touched).
- Global Git configuration was **not** modified.
- Global `user.name`/`user.email` were not configured on this host, so the commit(s)
  in this repo used a **per-commit override** (`git -c user.name=... -c
  user.email=...`, i.e. `GIT_AUTHOR_*`/`GIT_COMMITTER_*` env for this repo only):
  `NetClaw Demo <demo@localhost>`.
- Committed: the vault notes and the two copied generated documents. No secrets were
  read or copied; no credentials exist in this folder.
- No `git push` was run; no remote was added.

## Explicit limitations of this smoke test

- This is a validation of the `document-mcp` writer path only — it is not a network
  health assessment and asserts nothing new about R1/R2/SW1/SW2 beyond what the
  original `cml-pcall-validation.md` already recorded.
- No fresh device or ServiceNow query occurred; all figures are a replay of
  already-measured evidence with original timestamps preserved.
- Chassis serials and licensing identifiers remain withheld, as in the source
  evidence.
- GUI applications were intentionally not launched (being installed independently by
  the operator); no separate virtual desktop was started; no community Obsidian
  plugins were installed.
