# Activity

Shared usage journal for the shell: every consumer records what the user
picked, and ranks with what it reads back. One SQLite database at
`~/.local/share/omarchy/activity.db` (WAL mode), owned by the
`omarchy-activity` command. See `bin/omarchy-activity` for the implementation
and `test/shell.d/activity-test.sh` for the contract.

## Schema

- `items(kind, target, title, bonus, PRIMARY KEY (kind, target))` — one row per rankable thing, strictly namespaced by `kind` so identical target names never collide across categories.
- `visits(kind, target, at, via)` — one row per use, `at` in epoch milliseconds, capped at the 10 newest per item. `via` is `pick` (explicit choice) or `view` (passive sighting, e.g. a window opening).
- Indexed with `idx_visits_lookup(kind, target, at DESC)`, `idx_visits_at(at)`, and `idx_items_kind_target(kind, target)`. Stale pruning uses an $O(1)$ index probe to bypass full-table scans when no stale visits exist.

## Vocabulary

- `kind` namespaces targets: `app` (desktop ids, lowercased), `menu` (menu
  item ids), `dmenu` (dmenu selections), `file` (absolute paths), `project`
  (working directories from agents / zoxide), `agent-session` (coding agent
  session IDs). New consumers add arbitrary kinds; ranking stays per-kind unless
  a consumer blends.
- `via` separates provenance. `top` ranks picks by default; views accumulate
  history for future blending without outvoting picks today.

## Scoring

Firefox-style buckets over the sampled visits, computed in `top`:

| visit age | weight |
|---|---|
| ≤ 4 days | 100 |
| ≤ 14 days | 70 |
| ≤ 31 days | 50 |
| ≤ 90 days | 30 |
| older | 10 |

`score` is the weight sum plus the item `bonus`. `top`, `rank`, and `rank-files`
blend provenance by default: explicit picks count full weight, passive
views a quarter (`VIEW_WEIGHT`), so history accumulates from sightings
while decisions come from picks. `--via pick|view|all` selects raw
provenance instead. `count`/`lastUsed` stay alongside `score` for
consumers not on buckets yet.

## Consumer pattern

Record fire-and-forget at the pick site; hydrate once per session surface,
never per keystroke:

```bash
omarchy-activity record app "$app_id" "$label" >/dev/null 2>&1 || true
```

```bash
omarchy-activity top --kind app  # {target: {count, lastUsed, score}}
```

```bash
printf '%s\n' "$files" | omarchy-activity rank --kind file  # scored first, stable rest
# or legacy alias:
printf '%s\n' "$files" | omarchy-activity rank-files
```

Recording also prunes single-visit targets older than 90 days; anything
revisited stays.

Guard new call sites with `omarchy-cmd-present omarchy-activity` so a pick
never breaks on a system predating the command. `omarchy-menu-input` never
records: free text may be secrets. Display-only lists pass `--no-activity`.

## Third-Party & Custom Integrations

`omarchy-activity` is designed as a generic, UNIX-pipeline friendly frecency engine.
Any external CLI, script, or plugin can record and rank its own data structures:

### 1. Seeding External Tools
- **Zoxide**: `omarchy-activity import-zoxide [file]` imports directory history into `kind='project'`, weighting visits by zoxide score.
- **Coding Agents**: `omarchy-activity import-agents` scans Antigravity and Codex history to seed active workspaces (`kind='project'`) and session titles (`kind='agent-session'`).
- **Gtk Recents**: `omarchy-activity import-xbel [file]` seeds GTK recent files (`kind='file'`).

### 2. Custom Pipelines
Pipe any newline-delimited stream into `omarchy-activity rank --kind <kind>`:
```bash
# Rank git repositories or bookmarks:
find ~/Work -maxdepth 2 -name .git -exec dirname {} \; | omarchy-activity rank --kind project

# Record a pick from any fzf or custom picker:
selected=$(cat choices.txt | omarchy-activity rank --kind custom-choice | fzf)
[[ -n $selected ]] && omarchy-activity record custom-choice "$selected"
```

## Coverage and privacy

`omarchy-activity stats` reports per-kind and per-`via` counts plus the
newest event: an empty kind is a dead source. `omarchy-activity forget
<target> [--kind <kind>]` erases one target; everything is local-only SQLite, no sync.
