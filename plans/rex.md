# Plan: Rex — an offline regular expression workbench

Revision 2.

## Problem

Writing, testing, and learning regular expressions on Omarchy today means a browser tab on regex101.com or regexr.com. That is online-only, sends every pattern and test string (often log lines, config files, customer data) to a third party, and only covers the handful of flavors those sites implement — usually by emulating them in JavaScript or WebAssembly rather than running the real engine. There is no native tool that runs a pattern through the actual Perl, Python, Ruby, .NET, Go, Rust, Java, POSIX, grep/sed/awk, Vim, Lua, or Resid engine and shows where they disagree.

## Shape

Rex is a first-party Quickshell plugin (`omarchy.rex`) that opens a normal, tiled application window, listed under Apps through `applications/Rex.desktop` and launched by `omarchy-launch-rex`. It follows the touchpad settings window's structure: a plugin directory under `shell/plugins/rex/` with a `manifest.json`, a pure `Model.js` (and siblings) that hold all logic and are unit-tested from `test/shell.d/rex-test.sh`, QML views that only bind to the model, hidden `bin/` helpers, a manual page, and visual verification in the running UI.

Everything works offline. Every flavor runs on the real engine for that language; nothing is emulated.

## Features

- **Match**: live highlighting of matches and groups in the test text; a match table with every group's span, named groups, and offsets in codepoints, UTF-16 units, and UTF-8 bytes; flags per flavor; global/first match; multiline test text and file-backed test text.
- **Substitute**: replacement preview using the flavor's own replacement syntax (`$1`, `\1`, `\g<name>`, `${name}`, `\0`, `&`, case-conversion escapes where the engine supports them).
- **Split and list**: the flavor's own split semantics (captured delimiters, empty fields) and a list/format view (`$1,$2\n` per match).
- **Explain**: a token tree with a plain-language description of every node, colour-linked to the pattern and to the matched text, flagging tokens the selected flavor does not support.
- **Debug**: step-by-step match trace with backtracking, a step counter, and a timeline scrubber, from PCRE2's own callouts. PCRE2 only for now; other flavors offer "debug as PCRE2" when the pattern parses there.
- **Compare**: one pattern, every installed flavor side by side, with differences highlighted (match spans, groups, errors, unsupported syntax).
- **Optimize**: static analysis plus measurement — ReDoS and catastrophic backtracking detection with a witness input, suggestions (anchoring, atomic groups/possessive quantifiers, merging alternations into classes, hoisting common prefixes, negated classes in place of lazy dots, removing redundant groups and escapes, Unicode-correctness warnings, portability notes). Each suggestion shows the rewritten pattern and can be applied in one click after Rex confirms the rewrite matches identically on the current test text and unit tests. Benchmark mode times the pattern on every engine.
- **Unit tests**: per pattern, a list of inputs that must match / must not match / must produce specific groups; runs live, per flavor.
- **Code generator**: idiomatic snippet for each language (match, find all, replace, split), with correct escaping for that language's string literals.
- **Reference**: searchable quick reference filtered to the selected flavor, every entry with a runnable example.
- **Lessons**: an interactive course from first literal to recursion, Unicode properties, and engine internals; each lesson has exercises checked against hidden tests; progress saved.
- **Library**: named, tagged patterns with their test text, flags, flavor, and unit tests; history of recent sessions; the last session restored on open. Stored under `~/.local/share/omarchy/rex/`.

## Flavors

Grouped by how Rex reaches the engine. "Base" means it is always available on an Omarchy install; "detected" means Rex offers it only when the toolchain is found, and the flavor picker explains how to get it.

| Flavor | Engine | Availability | Adapter |
|---|---|---|---|
| ECMAScript (Qt V4/YARR) | in-process | base | `WorkerScript` (off the UI thread) |
| JavaScript (V8) | Node | detected | `node` worker |
| PCRE2 (and PHP) | libpcre2-8 | base | Python `ctypes` worker, JIT on, callouts for the debugger |
| Perl | perl | base | Perl worker |
| Python `re` | python | base | Python worker |
| Python `regex` | python-regex | detected | same Python worker |
| Ruby (Onigmo) | ruby | base | Ruby worker |
| .NET | dotnet | detected (needs SDK to build once) | C# worker, built to cache |
| Java | JDK | detected | single-file `java` worker |
| Go `regexp` (RE2) | go | detected | Go worker, built to cache |
| Rust `regex` | cargo | detected | Rust worker, built to cache (crate vendored with the source) |
| C++ `std::regex` (all six grammars) | gcc | base (base-devel) | C++ worker, built to cache |
| POSIX ERE/BRE (glibc) | libc | base | Python `ctypes` worker over `regcomp`/`regexec` |
| grep / egrep / grep -P, sed, gawk | the tools | base | run the real tool per request |
| Vim / Neovim | nvim | base | headless `nvim` worker using `matchstrpos` |
| Lua patterns | lua5.1 | base | Lua worker |
| Resid | residc | detected (`~/.resid`) | Resid worker over `lib/regex.resid`, built to cache |

Compiled workers are built on first use into `~/.cache/omarchy/rex/workers/<flavor>-<source hash>/` and rebuilt when the source changes, so nothing compiled is checked in and an update invalidates stale builds automatically.

## Architecture

### Process model

Rex runs inside the long-lived shell process, so nothing it does may block the shell's UI thread or risk the desktop:

- Every engine except ECMAScript runs in a **persistent worker process** spoken to over newline-delimited JSON on stdin/stdout (`{"id", "op", "flavor", "pattern", "flags", "text" | "textPath", ...}`). Workers start lazily on first use and stay warm, so interpreter and JIT start-up (Python ~30 ms, .NET/Java hundreds of ms) is paid once per session, not per keystroke.
- ECMAScript matching runs in a `WorkerScript`, never on the UI thread.
- Every request carries a deadline and a step budget. A request that overruns is cancelled by killing and respawning that one worker; the UI shows "timed out after N ms / N steps", which is itself the ReDoS signal for the optimizer.
- Requests are coalesced: typing schedules one request per flavor after a short debounce, and a newer request supersedes any in-flight one for the same view.

### Large inputs

- Test text below a threshold (about 64 KB) is an editable `TextEdit` with highlight overlays.
- Above it, or when opened from a file, the text is shown in a virtualized, read-only line view (`ListView` over line offsets) that renders and highlights only the visible lines. Editing stays available by switching back to the editor for files under the threshold.
- Large text is never sent over the pipe: Rex writes it once to a file in `$XDG_RUNTIME_DIR` (or uses the opened file directly) and workers `mmap`/read it themselves.
- Workers stream matches back in pages (span arrays, not objects) with a running count; the view requests the pages it needs for the visible region. A status line shows matches found, time per engine, and a cancel button.

### Modules

All logic lives in plain JavaScript modules under `shell/plugins/rex/lib/`, importable from QML and runnable under Node for tests:

- `Flavors.js` — the flavor table: capabilities (lookbehind kinds, atomic groups, possessive, recursion, conditionals, Unicode properties, named-group syntax, flags, replacement syntax, offsets unit).
- `Parser.js` — one parser producing a shared AST, parameterised by the flavor table, with precise source spans and flavor-specific errors.
- `Explain.js` — AST to explanation tree.
- `Analyze.js` — ReDoS detection (nested and overlapping quantifiers via NFA ambiguity analysis, with a witness string), lint rules, and rewrite suggestions.
- `Codegen.js` — snippet templates and per-language string escaping.
- `Engines.js` — the worker protocol, request coalescing, and result normalisation.
- `Store.js` — library, history, and lesson progress serialisation.
- `Lessons.js` + `lessons/*.json` — course content.

Workers live in `shell/plugins/rex/workers/<flavor>/`.

### Storage

`~/.local/share/omarchy/rex/`:

- `library.json` — saved patterns.
- `history.json` — recent sessions (capped).
- `session.json` — the last session, restored on open.
- `lessons.json` — lesson progress.

Every file is written atomically (write to a temp file, then rename) and carries a `version` for future migrations.

## Desktop integration

- `applications/Rex.desktop` and `applications/icons/Rex.png` — listed under Apps.
- `bin/omarchy-launch-rex` — summons the plugin (`omarchy-shell shell summon omarchy.rex`), optionally with a pattern or file payload.
- Hidden helpers: `bin/omarchy-rex-worker` (starts a flavor's worker, building it into the cache first when needed) and `bin/omarchy-rex-flavors` (prints detected flavors as JSON).
- `default/hypr/apps/omarchy-shell.lua` — Rex's window tiles like a normal app (no float rule).
- `manual/` — a Rex page.
- `shell/plugins/README.md` — plugin table entry.

## Commits

Each commit leaves Rex working and its tests passing:

1. Rex plugin skeleton, launcher, desktop entry, and window rule
2. Flavor table and shared regex parser
3. ECMAScript matching in a WorkerScript with live highlighting
4. Worker protocol and the interpreted flavors (PCRE2, Perl, Python, Ruby, POSIX, Lua)
5. Tool flavors (grep, sed, gawk, Neovim)
6. Compiled flavors built into the cache (Go, Rust, Java, .NET, C++, Node)
7. Resid flavor
8. Substitute, split, and list views
9. Virtualized view and streamed matching for large inputs
10. Explanation tree
11. Flavor comparison view
12. PCRE2 debugger
13. Optimizer analysis and suggestions
14. Benchmarks
15. Unit tests per pattern
16. Code generator
17. Quick reference
18. Pattern library, history, and session restore
19. Lessons
20. Manual page

## Testing

- `test/shell.d/rex-test.sh` runs the JS modules under Node: parser and explainer golden tests per flavor, analyzer cases (known ReDoS patterns and their witnesses, safe patterns), codegen escaping, store round-trips, and lesson validation (every exercise's reference answer passes its own tests).
- Worker parity tests send the same corpus to every installed worker and compare against expected results per flavor; flavors whose toolchain is missing are skipped with a notice.
- Performance checks: a multi-MB fixture must stream its first page of matches within a fixed budget, and a catastrophic pattern must time out cleanly without wedging the worker pool.
- Visual verification in the running shell per `agents/skills/visual-verification.md` for every view, in both a light and a dark theme.

## Decisions

- **Name**: Rex (`omarchy.rex`, `omarchy-launch-rex`).
- **Zyl**: not supported; Zyl has no regex engine to run against.
- **Upstreaming**: each flavor is a self-contained worker plus one flavor table entry, so Resid can be dropped cleanly if this goes upstream.
- **Debugger**: PCRE2 only for now.
- **Large files**: shown read-only in the virtualized view.
- **Optimizer**: one-click apply, gated on an equivalence check against the test text and unit tests.
- **Lessons**: about 30 lessons, beginner to engine internals, progress saved.
- **Window**: a tiled application window.
- **Session restore**: on.
- **Flavors**: a flavor works only when its engine is installed; tests skip missing ones with a notice.
