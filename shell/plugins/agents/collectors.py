"""The plumbing every agent usage collector shares.

Each `bin/omarchy-agent-usage-<id>` keeps what is its own: where its
credentials live, the endpoint it asks and how to read the answer, which
providers' tokens it counts, and the quirks of its record. Everything the
collector contract (docs/agent-usage-collectors.md) asks of all of them lives
here, once: the cache files, how untrusted numbers and times are read, the
record's shape, the limits cache, and the readers for the pi, omp, and
opencode stores several collectors split between them by provider.

It ships with the agents panel the records feed, and a collector loads it
from `$OMARCHY_PATH/shell/plugins/agents`. Nothing here prints a record, reads
a credential, or talks to a service on its own.
"""

from __future__ import annotations

import base64
import contextlib
import fcntl
import hashlib
import http.client
import json
import math
import os
import shutil
import sqlite3
import stat
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.request
from datetime import date, datetime, timedelta, timezone
from pathlib import Path
from typing import Any, Callable, Iterable, Iterator, NamedTuple

# A scan this recent is only reused to dedup concurrent collector runs (the
# update command backgrounds one per agent while the panel refreshes on its
# own); every periodic widget refresh lands a real rescan. --limits-only
# promises only fresh limits, so it may reuse a scan for up to 15 minutes.
# --force reuses nothing.
SCAN_REUSE_SECONDS = 20
LIMITS_ONLY_REUSE_SECONDS = 900

# A panel opened and closed repeatedly must not become one request per flick,
# so a limits answer this recent stands in for a probe; --force skips it.
PROBE_MIN_INTERVAL_SECONDS = 15

# The scan cache's envelope. A file of another version, or another shape, is
# a miss: rescanned and rewritten, never a crash or a garbage record.
SCAN_CACHE_VERSION = 2
STATS_KEYS = ("todayPrompts", "todayTotalTokens", "recentDays", "activeDates", "modelUsage")

# Counts and times read from disk or the network are untrusted: a boolean,
# NaN, negative, or absurdly large value reads as nothing, never as a number
# that would swamp the totals. The ceiling sits well above any epoch
# millisecond time.
NUMBER_CEILING = 10 ** 15

# Bodies larger than this are no answer any collector expects.
HTTP_BODY_LIMIT = 1_048_576


# ------------------------------------------------------------- diagnostics


def program() -> str:
  name = Path(sys.argv[0]).name if sys.argv and sys.argv[0] else ""
  return name if name.startswith("omarchy-agent-usage-") else "omarchy-agent-usage"


def warn(message: str) -> None:
  """A diagnostic on stderr, named for the collector. Never a credential."""
  print(f"{program()}: {message}", file=sys.stderr)


# ----------------------------------------------------------------- runtime


def runtime_env() -> dict[str, str]:
  """The environment with the places agent CLIs and rg install to on PATH."""
  home = str(Path.home())
  path_parts = [
    os.environ.get("PATH", ""),
    f"{home}/.local/bin",
    f"{home}/.npm-global/bin",
    f"{home}/.local/share/mise/shims",
  ]
  env = os.environ.copy()
  env["PATH"] = os.pathsep.join(part for part in path_parts if part)
  return env


def find_command(name: str) -> str | None:
  return shutil.which(name, path=runtime_env().get("PATH"))


# --------------------------------------------------------- untrusted values


def obj(value: Any) -> dict[str, Any]:
  """A nested field of the wrong shape (a list of tokens, a numeric time)
  reads as empty rather than failing the row, or the whole scan with it."""
  return value if isinstance(value, dict) else {}


def number(value: Any) -> int:
  """A count or time from disk or the network, 0 when it can't be trusted."""
  if isinstance(value, bool):
    return 0
  try:
    n = float(value or 0)
  except (TypeError, ValueError, OverflowError):
    return 0
  if not math.isfinite(n) or n < 0 or n >= NUMBER_CEILING:
    return 0
  return round(n)


def token_count(value: Any) -> int:
  """A token count from disk, 0 unless it is a plain JSON number number()
  trusts: a count written as a string is as untrusted as a boolean."""
  if isinstance(value, bool) or not isinstance(value, (int, float)):
    return 0
  return number(value)


def usage_tokens(usage: dict[str, Any], *keys: str) -> int:
  """pi, omp, and the harnesses that copy their format spell usage camelCase
  or snake_case; the first spelling present wins."""
  for key in keys:
    if key in usage:
      return token_count(usage.get(key))
  return 0


def date_string(value: datetime) -> str:
  return value.strftime("%Y-%m-%d")


def today() -> str:
  return date_string(datetime.now())


def recent_dates() -> list[str]:
  """The last seven local days, oldest first, today last."""
  now = datetime.now()
  return [date_string(now - timedelta(days=offset)) for offset in range(6, -1, -1)]


def local_day(value: Any) -> str | None:
  """The local day a row was spent on, or None when its time can't be
  trusted, so the caller skips that row rather than the whole scan.

  A row with no time at all is today's. Epoch seconds and milliseconds, a
  string of digits, and ISO times are read; zero, a huge or negative number,
  NaN, a boolean, a date outside 2000-2100, and anything else are untrusted.
  """
  if value is None:
    return today()
  if isinstance(value, str) and value.strip().isdigit():
    value = int(value.strip())
  if isinstance(value, bool):
    return None
  if isinstance(value, (int, float)):
    seconds = number(value)
    if seconds <= 0:
      return None
    # pi, omp, and opencode write milliseconds.
    if seconds > 10_000_000_000:
      seconds = seconds / 1000
    try:
      parsed = datetime.fromtimestamp(seconds)
    except (OverflowError, OSError, ValueError):
      return None
  else:
    try:
      parsed = datetime.fromisoformat(str(value).strip().replace("Z", "+00:00"))
      if parsed.tzinfo is not None:
        parsed = parsed.astimezone()
    except (OverflowError, OSError, ValueError):
      return None
  # No agent wrote a row before 2000 or after 2100: a time out there is a
  # damaged stamp (a stray 1 reads as 1970), not usage to count.
  if not 2000 <= parsed.year <= 2100:
    return None
  return date_string(parsed)


# -------------------------------------------------------------------- time


def now_ms() -> int:
  """Now as an epoch-ms stamp, floored: a stamp rounded half a millisecond
  ahead reads as a clock that went back, and the next run probes again."""
  return int(time.time() * 1000)


def stamp(value: Any) -> int:
  """An epoch-ms stamp a collector wrote, read back without trusting it."""
  if isinstance(value, bool) or not isinstance(value, (int, float)) or not math.isfinite(value):
    return 0
  return max(0, int(value))


def age_below(stamp_seconds: float, limit_seconds: float) -> bool:
  """Whether a stamp is younger than the limit. A negative age is a stamp
  from the future: the clock moved back since it was written, so it proves
  nothing about freshness."""
  age = time.time() - stamp_seconds
  return 0 <= age < limit_seconds


# ------------------------------------------------------------------- files


def cache_root() -> Path:
  root = Path(os.environ.get("XDG_CACHE_HOME") or (Path.home() / ".cache")) / "omarchy" / "agent-usage"
  root.mkdir(parents=True, exist_ok=True)
  return root


def data_home() -> Path:
  return Path(os.environ.get("XDG_DATA_HOME") or (Path.home() / ".local" / "share"))


def config_home() -> Path:
  return Path(os.environ.get("XDG_CONFIG_HOME") or (Path.home() / ".config"))


def read_json(path: Path) -> dict[str, Any]:
  """A JSON object from disk, {} when missing, unreadable, or not an object.

  Read whatever the file's time: a clock that went back must not lose the
  last good answer. Freshness is judged by the stamps stored inside.
  """
  try:
    parsed = json.loads(path.read_text(encoding="utf-8"))
  except Exception:
    return {}
  return parsed if isinstance(parsed, dict) else {}


def write_json(path: Path, payload: Any, sort_keys: bool = False) -> None:
  """Replace `path` atomically with `payload` as compact JSON."""
  # A temp name unique to this writer, not derived from the target: several
  # collectors can run at once (the update command backgrounds one per agent,
  # the panel refreshes on its own), and a shared temp path means the second
  # replace finds the first one's file already moved away.
  handle_fd, tmp_name = tempfile.mkstemp(dir=path.parent, prefix=path.name + ".", suffix=".tmp")
  tmp = Path(tmp_name)
  try:
    with os.fdopen(handle_fd, "w", encoding="utf-8") as handle:
      handle.write(json.dumps(payload, separators=(",", ":"), sort_keys=sort_keys) + "\n")
    # mkstemp opens at 0600; nothing in the cache is a credential, so open it
    # up to the usual 0644.
    tmp.chmod(0o644)
    tmp.replace(path)
  except BaseException:
    tmp.unlink(missing_ok=True)
    raise


@contextlib.contextmanager
def exclusive_lock(path: Path) -> Iterator[None]:
  """Hold flock on `path` for the block, or run the block unlocked.

  A lock file that isn't a regular file of ours, or one others may write, is
  never trusted with the lock; the block still runs, since the lock only
  dedups concurrent runs.
  """
  fd: int | None = None
  try:
    flags = os.O_WRONLY | os.O_CREAT | os.O_NOFOLLOW | os.O_NONBLOCK | os.O_CLOEXEC
    try:
      fd = os.open(path, flags | os.O_EXCL, 0o600)
    except FileExistsError:
      fd = os.open(path, flags)
    info = os.fstat(fd)
    if (
      not stat.S_ISREG(info.st_mode)
      or info.st_nlink == 0
      or info.st_uid != os.geteuid()
      or info.st_mode & 0o022
    ):
      os.close(fd)
      fd = None
  except OSError:
    if fd is not None:
      os.close(fd)
    fd = None
  if fd is not None:
    try:
      fcntl.flock(fd, fcntl.LOCK_EX)
    except OSError:
      os.close(fd)
      fd = None
  try:
    yield
  finally:
    if fd is not None:
      os.close(fd)


# ------------------------------------------------------------------ record


def empty_bucket() -> dict[str, int]:
  return {
    "inputTokens": 0,
    "outputTokens": 0,
    "cacheReadInputTokens": 0,
    "cacheCreationInputTokens": 0,
  }


def empty_stats() -> dict[str, Any]:
  """The record's stats block with nothing in it: always present, zeroed."""
  return {
    "todayPrompts": 0,
    "todaySessions": 0,
    "todayTotalTokens": 0,
    "todayTokensByModel": {},
    "recentDays": [{"date": day, "messageCount": 0} for day in recent_dates()],
    "totalPrompts": 0,
    "totalSessions": 0,
    "activeDays": 0,
    "activeDates": [],
    "modelUsage": {},
  }


def base_record(agent_id: str, name: str, **overrides: Any) -> dict[str, Any]:
  """A record with every field, empty stats, no limits and no balance.

  As it stands it is what a machine that doesn't use the agent prints: ready
  false, so the panel skips it, and no status, since that is no trouble.
  """
  record: dict[str, Any] = {
    "schemaVersion": 1,
    "id": agent_id,
    "name": name,
    "updatedAt": datetime.now(timezone.utc).isoformat(),
    "ready": False,
    "hasLocalStats": False,
    "hasPromptStats": True,
    "tierLabel": "",
    "usageStatusText": "",
    "authHelpText": "",
    "limits": [],
    "limitsStale": False,
    "limitsFetchedAt": 0,
  }
  record.update(empty_stats())
  record.update(overrides)
  return record


def emit(record: dict[str, Any], sort_keys: bool = False) -> None:
  """Print the record, the one thing on stdout."""
  print(json.dumps(record, separators=(",", ":"), sort_keys=sort_keys))


class Stats:
  """Per-day and per-model totals of every counted reply, turned into the
  record's stats fields by snapshot().

  `today` is the local day "today" means: today itself unless a caller hands
  in another (a date or an ISO day), for rows summarized against a day of
  their own.
  """

  def __init__(self, today: date | str | None = None) -> None:
    if today is None:
      day = datetime.now().date()
    elif isinstance(today, str):
      day = date.fromisoformat(today)
    else:
      day = today
    self.today = date_string(day)
    self.recent_dates = [date_string(day - timedelta(days=offset)) for offset in range(6, -1, -1)]
    self.recent = {day: 0 for day in self.recent_dates}
    self.today_prompts = 0
    self.today_tokens = 0
    self.today_sessions: set[str] = set()
    self.today_by_model: dict[str, int] = {}
    self.total_prompts = 0
    self.sessions: set[str] = set()
    self.active_dates: set[str] = set()
    self.model_usage: dict[str, dict[str, int]] = {}

  def add(
    self,
    day: str | None,
    session: str | None,
    model: str,
    input_tokens: int,
    output_tokens: int,
    cache_read: int,
    cache_write: int,
    prompts: int = 1,
  ) -> None:
    """Tokens `model` spent on `day` in `session`, and the prompts they
    answered: one reply is one prompt, the default.

    A store that books prompts apart from the tokens they spent passes
    prompts=0 here and counts each prompt with add_prompts(); one that keeps
    running totals passes how many prompts they cover. A day of None is a
    row with no date to trust that still counts toward the lifetime totals,
    and a session of None is tokens no session is known for. With no tokens
    there is no model bucket, and with neither tokens nor prompts there is
    nothing to count at all.
    """
    total = input_tokens + output_tokens + cache_read + cache_write
    if total <= 0 and prompts <= 0:
      return
    self.total_prompts += prompts
    if session is not None:
      self.sessions.add(session)
    if day is not None:
      self.active_dates.add(day)
    if total > 0:
      bucket = self.model_usage.setdefault(model, empty_bucket())
      bucket["inputTokens"] += input_tokens
      bucket["outputTokens"] += output_tokens
      bucket["cacheReadInputTokens"] += cache_read
      bucket["cacheCreationInputTokens"] += cache_write
    if day in self.recent:
      # recentDays' messageCount holds tokens, despite the name synced
      # snapshots share.
      self.recent[day] += total
    if day is not None and day == self.today:
      self.today_prompts += prompts
      if session is not None:
        self.today_sessions.add(session)
      self.today_tokens += total
      if total > 0:
        self.today_by_model[model] = self.today_by_model.get(model, 0) + total

  def add_prompts(self, day: str | None, session: str | None, count: int = 1) -> None:
    """`count` prompts typed on `day` in `session`, with no tokens of their
    own: for a store that books what was asked apart from what it spent.

    A count of 0 still says the session was in use that day. A day or a
    session of None reads as it does in add().
    """
    self.total_prompts += count
    if session is not None:
      self.sessions.add(session)
    if day is not None:
      self.active_dates.add(day)
      if day == self.today:
        self.today_prompts += count
        if session is not None:
          self.today_sessions.add(session)

  def add_row(self, row: UsageRow, model: str) -> None:
    """A row from scan_pi_sessions or scan_opencode, under the model name the
    collector shows for it."""
    self.add(row.day, row.session, model, row.input_tokens, row.output_tokens, row.cache_read, row.cache_write)

  def snapshot(self) -> dict[str, Any]:
    return {
      "todayPrompts": self.today_prompts,
      "todaySessions": len(self.today_sessions),
      "todayTotalTokens": self.today_tokens,
      "todayTokensByModel": self.today_by_model,
      "recentDays": [{"date": day, "messageCount": self.recent[day]} for day in self.recent_dates],
      "totalPrompts": self.total_prompts,
      "totalSessions": len(self.sessions),
      # Days with any recorded usage, for the all-time "N days" summary. The
      # dates travel too: merging snapshots from several machines needs
      # their union, which a count alone cannot give.
      "activeDays": len(self.active_dates),
      "activeDates": sorted(self.active_dates),
      "modelUsage": self.model_usage,
    }


# -------------------------------------------------------------- scan cache


def scan_max_age(force: bool, limits_only: bool) -> float:
  """How old a cached scan this run may reuse."""
  if force:
    return 0
  return LIMITS_ONLY_REUSE_SECONDS if limits_only else SCAN_REUSE_SECONDS


def scan_cache_paths(agent_id: str, sources: Iterable[Any]) -> tuple[Path, Path]:
  """The scan cache and its lock, keyed by every data path the scan reads, so
  moving a source is a miss."""
  identity = "\0".join(str(source) for source in sources)
  digest = hashlib.sha1(identity.encode("utf-8", "surrogatepass")).hexdigest()[:16]
  root = cache_root()
  return root / f"{agent_id}-scan-{digest}.json", root / f"{agent_id}-scan-{digest}.lock"


def read_cached_scan(cache_file: Path, max_age: float, match: dict[str, Any] | None = None) -> dict[str, Any] | None:
  """The stats a cached scan holds, or None when it can't stand in for one."""
  cached = read_json(cache_file)
  if cached.get("schemaVersion") != SCAN_CACHE_VERSION:
    return None
  # today* fields only mean "today" on the day they were scanned. A cache
  # from another local date (midnight passed, or the clock moved) is a miss,
  # not merely old.
  if cached.get("scanDate") != today():
    return None
  # A scan only answers for the options it applied (a model filter, say).
  if any(cached.get(key) != value for key, value in (match or {}).items()):
    return None
  if not age_below(stamp(cached.get("scannedAtMs")) / 1000, max_age):
    return None
  stats = cached.get("stats")
  if not isinstance(stats, dict) or not all(key in stats for key in STATS_KEYS):
    return None
  return stats


def cached_scan(
  agent_id: str,
  sources: Iterable[Any],
  max_age: float,
  scan: Callable[[], tuple[dict[str, Any], bool]],
  match: dict[str, Any] | None = None,
  with_complete: bool = False,
) -> Any:
  """Local stats, from a scan cached per day, or from `scan` under flock.

  `scan` returns (stats, complete). A scan that couldn't read all its sources
  still serves this run, but caching it would hide the missing usage from
  every reader until the cache expires, so only a complete one is kept.
  `match` names options the scan applied, stored with it and required to
  match on reuse.

  With `with_complete` the answer is (stats, complete), for a record that
  says whether its stats cover every source; a cached scan was a complete
  one.

  The cache is a pure optimization: any failure in it (an unwritable cache
  root, a lock error, a full disk) degrades to a direct scan and a warning.
  The JSON record is the contract; the cache is not.
  """
  sources = list(sources)
  match = dict(match or {})
  try:
    cache_file, lock_file = scan_cache_paths(agent_id, sources)
    cached = read_cached_scan(cache_file, max_age, match)
    if cached is not None:
      return (cached, True) if with_complete else cached
    lock = exclusive_lock(lock_file)
  except Exception as exc:
    warn(f"cache unavailable ({exc}); scanning directly")
    stats, complete = scan()
    return (stats, complete) if with_complete else stats

  with lock:
    # Another run may have scanned while this one waited for the lock.
    cached = read_cached_scan(cache_file, max_age, match)
    if cached is not None:
      return (cached, True) if with_complete else cached
    stats, complete = scan()
    if complete:
      try:
        write_json(cache_file, {"schemaVersion": SCAN_CACHE_VERSION, "scanDate": today(), "scannedAtMs": now_ms(), **match, "stats": stats})
      except Exception as exc:
        warn(f"could not write usage cache ({exc})")
    return (stats, complete) if with_complete else stats


# ------------------------------------------------------- pi and omp sessions


class UsageRow(NamedTuple):
  """One counted reply from a shared store, normalized.

  `session` is the session it counts toward: the realpath of a pi/omp
  session file, or "opencode:<session id>". `model` is the model id as the
  store wrote it, for the collector to name.
  """

  day: str
  session: str
  provider: str
  model: str
  input_tokens: int
  output_tokens: int
  cache_read: int
  cache_write: int


# accept(provider, model, entry) decides whether a reply bills this collector.
# `entry` is the pi/omp message object, or the opencode row's data, for a
# collector whose filter needs more than the provider and model.
Accept = Callable[[str, str, dict], bool]


def pi_session_roots() -> list[Path]:
  """pi's and omp's session trees, each profile's too.

  `--profile=<name>` moves the whole agent tree under
  <base>/profiles/<name>/. pi moves its agent tree with PI_CODING_AGENT_DIR
  and its sessions alone with PI_CODING_AGENT_SESSION_DIR, both expanding a
  leading ~; either is read as well as the default trees, which keep
  whatever was written before the move.
  """
  roots: list[Path] = []
  for base in (Path.home() / ".pi", Path.home() / ".omp"):
    roots.append(base / "agent" / "sessions")
    try:
      # Sorted so the scan order does not depend on directory order.
      roots.extend(sorted(child / "agent" / "sessions" for child in (base / "profiles").iterdir() if child.is_dir()))
    except OSError:
      # No profiles directory, or it is unreadable: the default root stands.
      pass
  if os.environ.get("PI_CODING_AGENT_DIR", "").strip():
    roots.append(Path(os.environ["PI_CODING_AGENT_DIR"].strip()).expanduser() / "sessions")
  if os.environ.get("PI_CODING_AGENT_SESSION_DIR", "").strip():
    roots.append(Path(os.environ["PI_CODING_AGENT_SESSION_DIR"].strip()).expanduser())
  return canonical_roots(roots)


def canonical_roots(roots: Iterable[Path]) -> list[Path]:
  """Session roots by realpath, so an override that aliases another root
  through a symlink is scanned under one spelling. A root inside another is
  already read with it, so it is dropped rather than counted twice."""
  canonical = list(dict.fromkeys(Path(root).resolve() for root in roots))
  return [root for root in canonical if not any(other != root and root.is_relative_to(other) for other in canonical)]


def pi_parent_session(path: str) -> str | None:
  """The session file a fork was cut from, as its header line names it."""
  try:
    with open(path, encoding="utf-8", errors="replace") as handle:
      header = json.loads(handle.readline())
  except (OSError, ValueError):
    return None
  parent = header.get("parentSession") if isinstance(header, dict) else None
  return os.path.realpath(os.path.expanduser(parent)) if isinstance(parent, str) and parent else None


def _rg_text(field: Any) -> str:
  # rg hands back text that is not valid UTF-8 as base64 bytes.
  field = obj(field)
  if isinstance(field.get("text"), str):
    return field["text"]
  return os.fsdecode(base64.b64decode(field.get("bytes") or ""))


def _pi_row(entry: Any, path: str, accept: Accept) -> tuple[tuple, UsageRow] | None:
  """(dedup key, row) for one session line this collector counts, or None."""
  if not isinstance(entry, dict) or entry.get("type") != "message":
    return None
  message = obj(entry.get("message"))
  if message.get("role") != "assistant":
    return None
  provider = str(message.get("provider") or "")
  model = str(message.get("model") or "")
  if not accept(provider, model, message):
    return None
  usage = obj(message.get("usage"))
  input_tokens = usage_tokens(usage, "input", "inputTokens", "input_tokens")
  # pi folds thinking into its own field; both are generated.
  output_tokens = usage_tokens(usage, "output", "outputTokens", "output_tokens") + usage_tokens(usage, "reasoning", "reasoningTokens", "reasoning_tokens")
  cache_read = usage_tokens(usage, "cacheRead", "cacheReadTokens", "cache_read", "cache_read_input_tokens")
  cache_write = usage_tokens(usage, "cacheWrite", "cacheWriteTokens", "cache_write", "cache_creation_input_tokens")
  if not (input_tokens or output_tokens or cache_read or cache_write):
    # Some writers keep only the total; it was still spent.
    input_tokens = usage_tokens(usage, "totalTokens", "total_tokens")
    if not input_tokens:
      return None
  # The first time present decides: none at all is today's, and an untrusted
  # one, zero included, skips only this line.
  timestamp = entry.get("timestamp")
  if timestamp is None:
    timestamp = message.get("timestamp")
  day = local_day(timestamp)
  if day is None:
    return None
  # A fork copies its parent's entries with their id and timestamp, so the
  # pair names a message across files; an id alone only within its file. A
  # line without an id has nothing tying it to a copy elsewhere, so it is
  # its own and always counts.
  message_id = str(entry.get("id") or "")
  if message_id and timestamp:
    key: tuple = ("entry", message_id, str(timestamp))
  elif message_id:
    key = ("path", path, message_id)
  else:
    key = ("line", path, object())
  return key, UsageRow(day, path, provider, model, input_tokens, output_tokens, cache_read, cache_write)


def scan_pi_sessions(pattern: str, accept: Accept, roots: Iterable[Path] | None = None) -> tuple[list[UsageRow], bool]:
  """Every pi/omp reply `accept` takes, each counted once, and whether every
  root was read in full.

  `pattern` is an rg regex every such line matches (the provider field,
  say); it only keeps other lines out of the parse, and `accept` stays the
  authority for the ones that reach it. A message a fork repeats is one row,
  counted toward the oldest session holding it, so a fork is a session of
  its own only for what it added, whichever file rg read first.

  `roots` are the session trees to read: pi_session_roots() unless the
  collector names others in pi's format (a harness of its own, or pi's and
  omp's with another beside them). They are read as canonical_roots() gives
  them, so a message copied between any of them still counts once. A
  collector that passes roots keys its scan cache by those same roots.
  """
  roots = [root for root in canonical_roots(pi_session_roots() if roots is None else roots) if root.is_dir()]
  if not roots:
    return [], True
  rg = find_command("rg")
  if not rg:
    warn("rg is missing; pi and omp sessions were not scanned")
    return [], False

  # (root, path, line) of every counted line, so the rows come back in one
  # order however rg's threads interleave the files.
  found: list[tuple[int, str, int, tuple, UsageRow]] = []
  complete = True
  for index, root in enumerate(roots):
    try:
      proc = subprocess.Popen(
        # --no-ignore: these are data files, not a source tree. When $HOME is
        # itself a git checkout (a common dotfiles setup), its ignore rules
        # would otherwise hide every session file and count zero usage.
        [rg, "--json", "--no-ignore", "--hidden", "--glob", "*.jsonl", "-e", pattern, str(root)],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        errors="replace",
        env=runtime_env(),
      )
    except OSError:
      return [], False
    assert proc.stdout is not None
    with proc.stdout:
      for raw in proc.stdout:
        try:
          event = json.loads(raw)
          if event.get("type") != "match":
            continue
          data = event["data"]
          path = os.path.realpath(_rg_text(data.get("path")))
          counted = _pi_row(json.loads(_rg_text(data.get("lines"))), path, accept)
          line_number = number(data.get("line_number"))
        except Exception:
          # One odd line costs that line, never the scan.
          continue
        if counted is not None:
          found.append((index, path, line_number, *counted))
    try:
      # rg exits 1 for no match and 2 when it couldn't read something.
      if proc.wait(timeout=5) not in (0, 1):
        complete = False
    except subprocess.TimeoutExpired:
      proc.kill()
      complete = False

  first: dict[tuple, UsageRow] = {}
  holders: dict[tuple, list[str]] = {}
  for _, path, _, key, row in sorted(found, key=lambda item: item[:3]):
    first.setdefault(key, row)
    if path not in holders.setdefault(key, []):
      holders[key].append(path)

  # Resolved after the scan, so rg's file order cannot decide which copy of
  # a forked message counts toward which session.
  parents: dict[str, str | None] = {}

  def ancestors(path: str) -> set[str]:
    found: set[str] = set()
    parent = parents.setdefault(path, pi_parent_session(path))
    while parent and parent not in found and parent != path:
      found.add(parent)
      parent = parents.setdefault(parent, pi_parent_session(parent))
    return found

  rows = []
  for key, row in first.items():
    paths = holders[key]
    if len(paths) > 1:
      roots_of_copy = [path for path in paths if not ancestors(path) & set(paths)]
      row = row._replace(session=min(roots_of_copy or paths))
    rows.append(row)
  return rows, complete


# ---------------------------------------------------------------- opencode


def opencode_db() -> Path:
  """The database opencode itself reads.

  OPENCODE_DB points opencode at another database, as the CLI itself reads
  it; a relative name lives beside the default one. Only a build whose
  channel was literally "v2" wrote opencode-v2.db, so it is a fallback for
  those installs alone.
  """
  root = data_home() / "opencode"
  configured = os.environ.get("OPENCODE_DB", "").strip()
  if configured:
    path = Path(configured).expanduser()
    return path if path.is_absolute() else root / path
  normal = root / "opencode.db"
  legacy = root / "opencode-v2.db"
  return legacy if not normal.is_file() and legacy.is_file() else normal


def _table_columns(conn: sqlite3.Connection, table: str) -> set[str]:
  try:
    return {row[1] for row in conn.execute(f"PRAGMA table_info({table})")}
  except sqlite3.Error:
    return set()


def _opencode_row(session_id: Any, entry: Any, row_type: str, created: Any, accept: Accept) -> UsageRow | None:
  # Shared by both message stores. The original `message` table keeps the
  # provider and model at the top level; the V2 `session_message` table nests
  # them under `model` and keeps the role in its `type` column, with a
  # compaction's tokens spent like any reply's.
  if not isinstance(entry, dict) or (entry.get("role") or row_type) not in ("assistant", "compaction"):
    return None
  nested = obj(entry.get("model"))
  provider = str(entry.get("providerID") or nested.get("providerID") or "")
  model = str(entry.get("modelID") or nested.get("id") or nested.get("modelID") or "")
  if not accept(provider, model, entry):
    return None
  tokens = obj(entry.get("tokens"))
  cache = obj(tokens.get("cache"))
  input_tokens = token_count(tokens.get("input"))
  # opencode keeps thinking tokens out of output; both are generated.
  output_tokens = token_count(tokens.get("output")) + token_count(tokens.get("reasoning"))
  cache_read = token_count(cache.get("read"))
  cache_write = token_count(cache.get("write"))
  if not (input_tokens or output_tokens or cache_read or cache_write):
    return None
  # The message's own time, else the row's: none at all is today's, and an
  # untrusted one, zero included, skips only this row.
  created_at = obj(entry.get("time")).get("created")
  day = local_day(created if created_at is None else created_at)
  if day is None:
    return None
  # One key per session id across both stores: a migrated session is one.
  return UsageRow(day, "opencode:" + str(session_id), provider, model, input_tokens, output_tokens, cache_read, cache_write)


def scan_opencode(providers: Iterable[str], accept: Accept) -> tuple[list[UsageRow], bool]:
  """Every opencode reply `accept` takes, from both message stores, and
  whether the scan ran to completion.

  `providers` are the provider ids the rows may carry, as LIKE prefixes: a
  row whose JSON names none of them is skipped before any parse. End one
  with `"` to match the whole id. They only keep other rows out of the
  parse; `accept` stays the authority for the rows that reach it.

  V2's `session_message` is read first, then the original `message` store,
  deduplicated by message id, leaving out the copies a fork makes. Read-only:
  opencode may be writing right now. A scan cut short by a database error
  still hands back what it read, but says it is incomplete, so it is never
  cached as the whole story.
  """
  db = opencode_db()
  if not db.is_file():
    return [], True
  try:
    conn = sqlite3.connect(db.resolve().as_uri() + "?mode=ro", uri=True, timeout=2)
  except sqlite3.Error:
    return [], False
  patterns = [f'%"providerID"%:%"{provider}%' for provider in providers]
  rows: list[UsageRow] = []
  seen: set[str] = set()

  def take(message_id: Any, session_id: Any, raw: Any, row_type: str, created: Any) -> None:
    # One row that still fails must not take the scan down with it.
    try:
      row = _opencode_row(session_id, json.loads(raw), row_type, created, accept)
    except Exception:
      return
    # A migrated message can sit in both stores under the same id.
    if row is None or str(message_id) in seen:
      return
    seen.add(str(message_id))
    rows.append(row)

  try:
    conn.execute("PRAGMA query_only = ON")
    tables = {name for (name,) in conn.execute("SELECT name FROM sqlite_master WHERE type = 'table'")}
    columns = _table_columns(conn, "session_message") if "session_message" in tables else set()
    if {"id", "session_id", "type", "data"} <= columns and patterns:
      created = "m.time_created" if "time_created" in columns else "NULL"
      source = "session_message m"
      fork_filter = ""
      if "time_created" in columns and "session_v2" in tables and {"id", "fork_session_id", "time_created"} <= _table_columns(conn, "session_v2"):
        # A fork copies its source session's messages under new ids; only
        # what came after the fork was spent in it.
        source += " LEFT JOIN session_v2 s ON s.id = m.session_id"
        fork_filter = " AND (s.fork_session_id IS NULL OR m.time_created >= s.time_created)"
      gate = " OR ".join("m.data LIKE ?" for _ in patterns)
      for message_id, session_id, row_type, time_created, raw in conn.execute(
        f"SELECT m.id, m.session_id, m.type, {created}, m.data FROM {source}"
        f" WHERE m.type IN ('assistant', 'compaction') AND ({gate})" + fork_filter,
        patterns,
      ):
        take(message_id, session_id, raw, str(row_type or ""), time_created)
    columns = _table_columns(conn, "message") if "message" in tables else set()
    if {"session_id", "data"} <= columns and patterns:
      row_id = "id" if "id" in columns else "rowid"
      gate = " OR ".join("data LIKE ?" for _ in patterns)
      for message_id, session_id, raw in conn.execute(
        f"SELECT {row_id}, session_id, data FROM message"
        f" WHERE data LIKE '%\"role\"%:%\"assistant\"%' AND ({gate})",
        patterns,
      ):
        take(message_id, session_id, raw, "", None)
  except sqlite3.Error:
    # Transient lock, schema migration, corruption: the numbers stop here,
    # incomplete.
    return rows, False
  finally:
    conn.close()
  return rows, True


# ------------------------------------------------------------------ limits


def limits_cache_path(agent_id: str, *identity: str, kind: str = "limits") -> Path:
  """`<id>-<kind>-<hash>.json`, keyed by who the credential signs in as (or
  the credential itself), so another sign-in never shows this one's numbers.
  `kind` names an answer kept beside the limits (credits, a balance, usage
  rows) under the same key."""
  # surrogatepass: an identity read from JSON can hold a lone surrogate, and
  # that must not cost the record.
  digest = hashlib.sha256("\0".join(identity).encode("utf-8", "surrogatepass")).hexdigest()[:16]
  return cache_root() / f"{agent_id}-{kind}-{digest}.json"


def limit_window_open(entry: dict[str, Any], now: datetime) -> bool:
  # A window with no reset time, or one that will not parse, is no reason to
  # doubt a real number.
  raw = str(entry.get("resetsAt") or "")
  if raw == "":
    return True
  try:
    resets_at = datetime.fromisoformat(raw.replace("Z", "+00:00"))
  except ValueError:
    return True
  if resets_at.tzinfo is None:
    resets_at = resets_at.replace(tzinfo=timezone.utc)
  return resets_at > now


def open_limits(entries: Any) -> list[dict[str, Any]]:
  """Kept limit windows, as they read now.

  A window whose reset has passed comes back at percent 0 with resetsAt "":
  the allowance it measured has been renewed, so it is untouched rather than
  unknown, and never dropped.
  """
  if not isinstance(entries, list):
    return []
  now = datetime.now(timezone.utc)
  return [
    entry if limit_window_open(entry, now) else dict(entry, percent=0.0, resetsAt="")
    for entry in entries if isinstance(entry, dict)
  ]


class LimitsCache:
  """One credential's last good limits answer.

  Read whatever the file time, so a clock that went back keeps it. `limits`
  are the kept windows as they read now, `fetched_at` when they were
  measured (epoch ms, 0 when never), and `data` the whole file for anything
  else a collector keeps beside them (a plan, a no-plan marker, a balance).

  `kind` keeps another answer of the same credential beside its limits
  (`<id>-<kind>-<hash>.json`): credits, a balance, usage rows. at() opens a
  cache under a name a collector already gave it.
  """

  def __init__(self, agent_id: str, *identity: str, kind: str = "limits") -> None:
    self._open(limits_cache_path(agent_id, *identity, kind=kind))

  @classmethod
  def at(cls, path: Path) -> LimitsCache:
    """The cache kept at `path`, for a name that predates the shared one."""
    cache = cls.__new__(cls)
    cache._open(Path(path))
    return cache

  def _open(self, path: Path) -> None:
    self.path = path
    self.lock_path = path.with_suffix(".lock")
    self.reload()

  def reload(self) -> None:
    self.data = read_json(self.path)
    self.fetched_at = stamp(self.data.get("fetchedAtMs"))
    self.limits = open_limits(self.data.get("limits"))

  def younger_than(self, seconds: float) -> bool:
    return age_below(self.fetched_at / 1000, seconds)

  def fresh(self, force: bool, seconds: float = PROBE_MIN_INTERVAL_SECONDS, allow_empty: bool = False) -> bool:
    """Whether the kept answer stands in for a probe: recent, and no --force.

    Only kept limits count, unless `allow_empty`: then any answer stamped
    inside the age guard does, limits or none, for a service whose answer
    can hold no windows (a plan without quotas, credits, a balance).
    """
    if force or not self.younger_than(seconds):
      return False
    return bool(self.limits) or (allow_empty and self.fetched_at > 0)

  def kept(self) -> tuple[list[dict[str, Any]], int]:
    """The stale fallback: the kept limits and their limitsFetchedAt."""
    return self.limits, self.fetched_at if self.limits else 0

  def save(self, limits: list[dict[str, Any]], only_if_newer: bool = False, **extra: Any) -> int:
    """Keep a good answer, stamped now; returns the stamp. A cache that can't
    be written costs only the reuse, never the answer.

    With `only_if_newer`, a file another run stamped later is left as it is,
    so overlapping runs (the panel's own refresh and a sooner retry) never
    roll a newer answer back. This run still uses its own answer.
    """
    fetched_at = now_ms()
    payload = {"fetchedAtMs": fetched_at, "limits": limits, **extra}
    try:
      if not only_if_newer or stamp(read_json(self.path).get("fetchedAtMs")) <= fetched_at:
        write_json(self.path, payload)
    except Exception as exc:
      warn(f"could not write limits cache ({exc})")
    self.data = payload
    self.fetched_at = fetched_at
    self.limits = open_limits(limits)
    return fetched_at

  def lock(self) -> contextlib.AbstractContextManager[None]:
    """flock for a probe, so concurrent runs ask the service once."""
    return exclusive_lock(self.lock_path)


# -------------------------------------------------------------------- http


class _RefuseRedirects(urllib.request.HTTPRedirectHandler):
  # A redirect would carry the credential to whatever host it names, so it
  # answers as the 3xx status it is.
  def redirect_request(self, req, fp, code, msg, headers, newurl):  # noqa: ANN001
    return None


# Every collector request goes through urllib.request.urlopen, which the
# collectors' tests replace, so the refusal is installed where urlopen looks.
urllib.request.install_opener(urllib.request.build_opener(_RefuseRedirects()))


class HttpError(Exception):
  """A request that brought back no usable answer.

  `status` is the HTTP status of a refusal (a redirect included), 0 when
  there is none, and `headers` the refusal's own (a 429's retry-after).
  `transport` means the connection failed or dropped before any reply (DNS,
  no route, a refused or reset connection, a timeout), which is the only
  failure worth retryAdvised. Otherwise the server answered, with a body
  that isn't JSON or is too large to be an answer (`invalid`), or with a
  reply cut short or garbled on the way (`cut_short`, invalid too): an
  answer all the same, so no reason to ask again sooner.
  """

  def __init__(self, status: int = 0, transport: bool = False, body: bytes = b"", headers: Any = None, cut_short: bool = False) -> None:
    super().__init__(f"HTTP {status}" if status else ("unreachable" if transport else ("reply cut short" if cut_short else "invalid answer")))
    self.status = status
    self.transport = transport
    self.invalid = not status and not transport
    self.cut_short = cut_short
    self.body = body
    self.headers = headers


def open_json(request: urllib.request.Request, timeout: float = 10, limit: int = HTTP_BODY_LIMIT) -> Any:
  """The JSON a request answers with, or HttpError saying why there's none."""
  try:
    with urllib.request.urlopen(request, timeout=timeout) as response:
      body = response.read(limit + 1)
  except urllib.error.HTTPError as error:
    try:
      body = error.read(limit) or b""
    except Exception:
      body = b""
    raise HttpError(status=error.code, body=body, headers=error.headers) from error
  except OSError as error:
    # URLError and every socket failure, a reset and a timeout included: the
    # connection failed or dropped before a reply. RemoteDisconnected is
    # both an OSError and an HTTPException, and lands here: a server that
    # hung up without a word gave no answer.
    raise HttpError(transport=True) from error
  except http.client.HTTPException as error:
    # A reply arrived but was cut short (IncompleteRead) or garbled (a bad
    # status line, bad headers): the server answered.
    raise HttpError(cut_short=True) from error
  if len(body) > limit:
    raise HttpError()
  try:
    return json.loads(body.decode("utf-8", errors="replace"))
  except ValueError as error:
    raise HttpError() from error


# ---------------------------------------------------------------- sign-ins


def finite(value: Any) -> float:
  """A float from an answer or a token, 0.0 when it isn't a finite number."""
  if isinstance(value, bool):
    return 0.0
  try:
    parsed = float(value or 0)
  except (TypeError, ValueError):
    return 0.0
  return parsed if math.isfinite(parsed) else 0.0


def jwt_claims(token: Any) -> dict[str, Any]:
  """The claims a JWT carries, read without checking its signature (only
  ever to tell whose it is, or when it lapses), {} for anything else."""
  if not isinstance(token, str):
    return {}
  parts = token.split(".")
  if len(parts) != 3:
    return {}
  try:
    claims = json.loads(base64.urlsafe_b64decode(parts[1] + "=" * (-len(parts[1]) % 4)))
  except (ValueError, UnicodeDecodeError):
    return {}
  return claims if isinstance(claims, dict) else {}


def token_lapsed(token: str) -> bool:
  """A sign-in token whose expiry has passed. The agent renews its own the
  next time it runs; an opaque API key never lapses here."""
  expires = finite(jwt_claims(token).get("exp"))
  return 0 < expires <= datetime.now(timezone.utc).timestamp()


def account_key(token: str) -> str:
  """Who a token signs in as (the JWT's subject), so a machine signed in to
  someone else never shows the last one's numbers, and a refreshed token
  keeps the same caches. An opaque key stands for itself; the caches hash
  it."""
  return str(jwt_claims(token).get("sub") or "") or token


# The Cursor and Grok Bot collectors ask as the same Cursor account, found
# the same way here, so the two never describe different people.


def cursor_auth_path() -> Path:
  """The Cursor CLI's auth.json: CURSOR_AUTH_PATH when set, else its home
  under the config directory."""
  configured = os.environ.get("CURSOR_AUTH_PATH", "").strip()
  return Path(configured).expanduser() if configured else config_home() / "cursor" / "auth.json"


def cursor_state_db() -> Path:
  return config_home() / "Cursor" / "User" / "globalStorage" / "state.vscdb"


def _cursor_ide_token(state_db: Path) -> str:
  # The sign-in the Cursor editor keeps, for people who never ran the CLI.
  # Read-only: the editor may be writing its database right now. No
  # immutable=1, so a live database with an active WAL still reads.
  if not state_db.is_file():
    return ""
  try:
    conn = sqlite3.connect(state_db.resolve().as_uri() + "?mode=ro", uri=True, timeout=2)
  except sqlite3.Error:
    return ""
  try:
    conn.execute("PRAGMA query_only = ON")
    row = conn.execute("SELECT value FROM ItemTable WHERE key = 'cursorAuth/accessToken' LIMIT 1").fetchone()
  except sqlite3.Error:
    return ""
  finally:
    conn.close()
  value = row[0] if row else None
  if isinstance(value, bytes):
    value = value.decode("utf-8", errors="replace")
  return str(value or "").strip()


def cursor_token(auth_path: Path | None = None, state_db: Path | None = None) -> str:
  """The key the user exported, the credential the Cursor CLI stores, or the
  editor's sign-in, in that order.

  A sign-in that has lapsed gives way to the next one that hasn't: someone
  who ran the CLI once and now lives in the editor would otherwise wait on a
  token nothing renews. With all of them lapsed, the first one decides.
  """
  key = str(os.environ.get("CURSOR_API_KEY") or "").strip()
  if key:
    return key
  cli = str(read_json(auth_path or cursor_auth_path()).get("accessToken") or "").strip()
  if cli and not token_lapsed(cli):
    return cli
  ide = _cursor_ide_token(state_db or cursor_state_db())
  if ide and not token_lapsed(ide):
    return ide
  return cli or ide


# ---------------------------------------------------------------- accounts


def registered_accounts(agent_id: str) -> list[dict[str, Any]]:
  """The accounts `omarchy agent account` registered for the agent, read
  straight from its registry, each marked `active` and carrying the
  registry's `switch` settings. Only a registry holding a second account
  matters: with one, the record is exactly what it always was."""
  state = Path(os.environ.get("XDG_STATE_HOME") or (Path.home() / ".local" / "state"))
  registry = read_json(state / "omarchy" / "agents" / "accounts" / f"{agent_id}.json")
  accounts = [a for a in registry.get("accounts") or [] if isinstance(a, dict) and a.get("id")]
  if len(accounts) < 2:
    return []
  active_id = registry.get("active") or accounts[0]["id"]
  if not any(a["id"] == active_id for a in accounts):
    active_id = accounts[0]["id"]
  for account in accounts:
    account["active"] = account["id"] == active_id
    account["switch"] = {
      "mode": "auto" if registry.get("switch") == "auto" else "manual",
      "threshold": registry.get("threshold") or 95,
    }
  return accounts


def account_entry(account: dict[str, Any], limits: dict[str, Any], plan: str, **extra: Any) -> dict[str, Any]:
  """One registered account in the record's `accounts`.

  `limits` is what the collector's limits check answered for it: `limits`,
  `live`, `fetchedAtMs`, `usageStatusText`, `authHelpText`, and
  `retryAdvised` when set. `plan` is the plan it names now, the registry's
  standing in when it names none, and `extra` the collector's own fields,
  last.
  """
  return {
    "id": account["id"],
    "label": str(account.get("label") or account["id"]),
    "email": str(account.get("email") or ""),
    "plan": plan or str(account.get("plan") or ""),
    "active": account["active"],
    "primary": bool(account.get("primary")),
    "limits": limits["limits"],
    "stale": not limits["live"],
    "fetchedAt": limits["fetchedAtMs"],
    "usageStatusText": limits["usageStatusText"],
    "authHelpText": limits["authHelpText"],
    "retryAdvised": bool(limits.get("retryAdvised")),
    **extra,
  }
