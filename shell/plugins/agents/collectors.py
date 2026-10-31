"""The plumbing every agent usage collector shares.

Each `bin/omarchy-agent-usage-<id>` keeps what is its own: where its
credentials live, the endpoint it asks and how to read the answer, which
providers' tokens it counts, and the quirks of its record. Everything the
collector contract (docs/agent-usage-collectors.md) asks of all of them lives
here, once: the cache files, how untrusted numbers and times are read, the
record's shape, the limits cache, and the readers for the stores several
collectors split between them by provider: pi, omp and opencode sessions,
Claude Code transcripts, Codex rollouts, DeepSeek Harness logs and MiniMax
Code sessions, with the one rule each split follows.

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
import ipaddress
import json
import math
import os
import re
import shutil
import sqlite3
import stat
import subprocess
import sys
import tempfile
import time
import tomllib
import urllib.error
import urllib.parse
import urllib.request
from collections import Counter
from datetime import date, datetime, timedelta, timezone
from pathlib import Path
from typing import Any, Callable, Iterable, Iterator, NamedTuple

try:
  from compression import zstd
except ImportError:
  zstd = None

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


def _mise_shims_dir() -> str:
  return os.path.join(os.environ.get("MISE_DATA_DIR") or str(data_home() / "mise"), "shims")


def _is_lazy_launcher(path: str) -> bool:
  # omarchy-mise-install writes a regular file whose first step is `mise use
  # -g`, and mise's shims exec `mise x`; running either installs the tool it
  # wraps. A shim is a symlink to the mise binary itself, as is each account
  # wrapper in mise's command-wrappers/bin, so the symlink check comes after
  # the shim checks: a symlink elsewhere is the user's own binary.
  if os.path.dirname(os.path.abspath(path)) == _mise_shims_dir():
    return True
  if os.path.islink(path):
    mise = find_command("mise")
    return bool(mise) and os.path.realpath(path) == os.path.realpath(mise)
  try:
    with open(path, "rb") as handle:
      head = handle.read(4096)
    return b"mise use" in head or b"mise x " in head
  except OSError:
    return False


def find_installed_command(name: str) -> str | None:
  """An agent CLI already installed, never a launcher that would install or
  update it first: the first on PATH that isn't one, else what mise names."""
  env = runtime_env()
  for directory in env.get("PATH", "").split(os.pathsep):
    candidate = os.path.join(directory, name)
    if os.path.isfile(candidate) and os.access(candidate, os.X_OK) and not _is_lazy_launcher(candidate):
      return candidate
  # `mise which` only prints a binary that is already installed, so it is the
  # safe way to resolve a tool managed by mise without running the launcher.
  # `mise which` can resolve a configured `latest` over the network; a usage
  # probe stays offline.
  mise = find_command("mise")
  if mise:
    try:
      out = subprocess.run([mise, "which", name], capture_output=True, text=True, env=dict(env, MISE_OFFLINE="1"), timeout=10)
      resolved = out.stdout.strip()
      if out.returncode == 0 and os.path.isfile(resolved) and not _is_lazy_launcher(resolved):
        return resolved
    except Exception:
      pass
  return None


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
  # ASCII digits only, and few enough to be a time: isdigit() also passes
  # other scripts' digits and int() refuses strings past 4300 digits.
  if isinstance(value, str) and re.fullmatch(r"[0-9]{1,20}", value.strip()):
    value = int(value.strip())
  if isinstance(value, bool):
    return None
  if isinstance(value, (int, float)):
    # number() turns untrusted values (NaN, negative, huge) into 0; the time
    # itself is floored, as stamps are, so the last half second of a day
    # isn't read as the next one.
    if number(value) <= 0:
      return None
    seconds = math.floor(value)
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


def _finite(value: Any) -> Any:
  if isinstance(value, float) and not math.isfinite(value):
    return 0
  if isinstance(value, dict):
    return {key: _finite(item) for key, item in value.items()}
  if isinstance(value, (list, tuple)):
    return [_finite(item) for item in value]
  return value


def emit(record: dict[str, Any], sort_keys: bool = False) -> None:
  """Print the record, the one thing on stdout.

  A number that overflowed to infinity (a huge balance read with float())
  prints as 0: Infinity and NaN aren't JSON, and the panel would drop the
  whole record over one.
  """
  print(json.dumps(_finite(record), separators=(",", ":"), sort_keys=sort_keys, allow_nan=False))


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
    """A row from one of the shared readers, under the model name the
    collector shows for it. A row with no tokens books its prompts alone,
    and with none of those still says its session was in use that day."""
    if row.input_tokens + row.output_tokens + row.cache_read + row.cache_write <= 0:
      self.add_prompts(row.day, row.session, row.prompts)
      return
    self.add(row.day, row.session, model, row.input_tokens, row.output_tokens, row.cache_read, row.cache_write, row.prompts)

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
  store wrote it, for the collector to name. `prompts` is how many prompts
  it answered: tokens spent on a summary answered none.
  """

  day: str
  session: str
  provider: str
  model: str
  input_tokens: int
  output_tokens: int
  cache_read: int
  cache_write: int
  prompts: int = 1


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
  whatever was written before the move. A `sessionDir` in an agent tree's
  settings.json moves its sessions too and is read the same way; a relative
  one resolves against the cwd pi started in, which can't be known here.
  """
  agent_dirs: list[Path] = []
  for base in (Path.home() / ".pi", Path.home() / ".omp"):
    agent_dirs.append(base / "agent")
    try:
      # Sorted so the scan order does not depend on directory order.
      agent_dirs.extend(sorted(child / "agent" for child in (base / "profiles").iterdir() if child.is_dir()))
    except OSError:
      # No profiles directory, or it is unreadable: the default root stands.
      pass
  if os.environ.get("PI_CODING_AGENT_DIR", "").strip():
    agent_dirs.append(Path(os.environ["PI_CODING_AGENT_DIR"].strip()).expanduser())
  roots = [agent_dir / "sessions" for agent_dir in agent_dirs]
  for agent_dir in agent_dirs:
    configured = read_json(agent_dir / "settings.json").get("sessionDir")
    if isinstance(configured, str) and configured.strip():
      configured_root = Path(configured.strip()).expanduser()
      if configured_root.is_absolute():
        roots.append(configured_root)
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
    # A header can name any path; opening a FIFO or a device there would
    # hang the scan, so only a regular file is read.
    if not stat.S_ISREG(os.stat(path).st_mode):
      return None
    with open(path, encoding="utf-8", errors="replace") as handle:
      header = json.loads(handle.readline())
  except (OSError, ValueError, RecursionError):
    # RecursionError: a damaged header nested deeper than the parser goes.
    return None
  parent = header.get("parentSession") if isinstance(header, dict) else None
  if not isinstance(parent, str) or not parent:
    return None
  # pi deletes a session from /resume, leaving its forks naming it. A parent
  # that is gone still ties its forks together, so a prompt they both copied
  # counts once; only reading it is skipped.
  return os.path.realpath(os.path.expanduser(parent))


def _rg_text(field: Any) -> str:
  # rg hands back text that is not valid UTF-8 as base64 bytes.
  field = obj(field)
  if isinstance(field.get("text"), str):
    return field["text"]
  return os.fsdecode(base64.b64decode(field.get("bytes") or ""))


# Spent tokens with no provider of their own: pi writes a compaction's and a
# branch summary's on the entry, and a tool's nested model work on its
# result, all as the session's model ran them, and counts them in the
# session's totals.
_PI_SUMMARIES = ("compaction", "branch_summary")


def _pi_line(entry: Any) -> tuple | None:
  """What one session line says, for the reader to fold in file order:
  ("model", provider, model, reference) for a model switch, ("reply", ...)
  for an assistant message, which also names the model the session is on,
  ("spent", provider, model, entry, usage) for usage with its own provider,
  ("summary", usage) for usage spent on the session's model, ("prompt",)
  for a typed prompt, or None."""
  if not isinstance(entry, dict):
    return None
  kind = entry.get("type")
  if kind == "message":
    message = obj(entry.get("message"))
    role = message.get("role")
    if role == "assistant":
      provider = str(message.get("provider") or "")
      model = str(message.get("model") or "")
      # Only what a collector's filter reads is kept, not the reply's text.
      reference = {key: value for key, value in message.items() if key != "content"}
      return "reply", provider, model, reference, obj(message.get("usage"))
    if role == "toolResult" and isinstance(message.get("usage"), dict):
      return "summary", message["usage"]
    # omp marks the user messages it writes itself (a handoff, a compaction
    # summary) as the agent's.
    if role == "user" and message.get("attribution") != "agent" and message.get("synthetic") is not True:
      return ("prompt",)
    return None
  if kind == "model_change":
    # pi names the provider and model apart; omp joins them as provider/model.
    provider = str(entry.get("provider") or "")
    model = str(entry.get("modelId") or "")
    if not provider and isinstance(entry.get("model"), str):
      provider, _, model = entry["model"].partition("/")
    return ("model", provider, model, {"provider": provider, "model": model}) if provider else None
  if kind == "usage":
    return "spent", str(entry.get("provider") or ""), str(entry.get("model") or ""), entry, obj(entry.get("usage"))
  if kind in _PI_SUMMARIES and isinstance(entry.get("usage"), dict):
    return "summary", entry["usage"]
  return None


def _pi_unsent(message: dict) -> bool:
  """Whether a failed omp reply never reached its provider.

  omp times every request it makes, a failed one included (`duration`, and
  `errorStatus` for an HTTP answer), so an error it writes with its
  `errorId` and neither, like a refused local credential, was raised before
  sending. pi writes no `errorId`, and an aborted request may have gone out.
  """
  return message.get("stopReason") == "error" and "errorId" in message and not any(key in message for key in ("duration", "errorStatus", "responseId"))


def _pi_key(entry: dict, timestamp: Any, path: str) -> tuple:
  """The dedup key of one session line.

  A reply with a response id is that response, at the time it came. A
  fork copies its parent's entries with their id and timestamp, so the
  pair names a message across files; an id alone only within its file. A
  line without an id has nothing tying it to a copy elsewhere, so it is its
  own and always counts.
  """
  message = obj(entry.get("message"))
  response = message.get("responseId")
  if message.get("role") == "assistant" and isinstance(response, str) and response and message.get("timestamp") is not None:
    # omp writes a reply that overflowed the model's context window twice,
    # as siblings with new ids; the response they repeat, and a fork's copy
    # of it, is the one request the provider served.
    return ("response", str(message.get("provider") or ""), response, str(message["timestamp"]))
  message_id = str(entry.get("id") or "")
  if message_id and timestamp:
    return ("entry", message_id, str(timestamp))
  if message_id:
    return ("path", path, message_id)
  return ("line", path, object())


def _pi_row(entry: dict, timestamp: Any, path: str, provider: str, model: str, usage: dict, prompts: int) -> tuple[tuple, UsageRow] | None:
  """(dedup key, row) for usage one session line spent, or None."""
  input_tokens = usage_tokens(usage, "input", "inputTokens", "input_tokens")
  # pi's `reasoning` and omp's `reasoningTokens` are the part of output that
  # was thinking, already in it, so they are never added again.
  output_tokens = usage_tokens(usage, "output", "outputTokens", "output_tokens")
  cache_read = usage_tokens(usage, "cacheRead", "cacheReadTokens", "cache_read", "cache_read_input_tokens")
  cache_write = usage_tokens(usage, "cacheWrite", "cacheWriteTokens", "cache_write", "cache_creation_input_tokens")
  if not (input_tokens or output_tokens or cache_read or cache_write):
    # Some writers keep only the total; it was still spent.
    input_tokens = usage_tokens(usage, "totalTokens", "total_tokens")
    if not input_tokens:
      return None
  # The first time present decides: none at all is today's, and an untrusted
  # one, zero included, skips only this line.
  day = local_day(timestamp)
  if day is None:
    return None
  return _pi_key(entry, timestamp, path), UsageRow(day, path, provider, model, input_tokens, output_tokens, cache_read, cache_write, prompts)


def _pi_rows(path: str, lines: list[tuple[int, Any]], accept: Accept) -> Iterator[tuple[int, tuple, UsageRow, tuple, bool]]:
  """(line number, dedup key, row, prompt keys, whether `accept` takes it)
  for each (line number, entry) of one session file, in order, whoever's,
  the prompt keys naming the typed prompts the row's `prompts` count.

  `lines` hold every model switch, user and assistant message in the file.
  Usage with no provider of its own bills the model the session was on: the
  last model switch or reply before it. With neither, nothing says who
  billed it, and it is skipped. A typed prompt is booked on the first reply
  that spent tokens answering it, so tool steps and summaries answer none,
  and a prompt another provider answered stays with that one. One that no
  reply answered before the next prompt or the file's end (its request
  failed, or none came) is a row of its own without tokens, on the model
  the session was set to use for it: the failed reply, which pi and omp
  write with its provider and no usage, else the last model switch or reply
  before it; with neither, or when omp refused the request before sending
  it, it counts nowhere. A prompt counts on its own day,
  not the reply's, and one whose time can't be trusted doesn't count. A file
  with no user messages at all, as only a writer copying pi's format leaves,
  keeps a prompt per reply.
  """
  parsed = [(line_number, entry, _pi_line(entry)) for line_number, entry in lines]
  typed = any(line == ("prompt",) for _, _, line in parsed)
  # The model the session is on, from the last switch or reply.
  context: tuple | None = None
  # Each typed prompt no reply has answered yet: (line number, dedup key,
  # day or None for an untrusted time, the model the session was on).
  asked: list[tuple[int, tuple, str | None, tuple | None]] = []
  # The first reply since those prompts that spent nothing: a failed request,
  # or () for one omp refused before sending it.
  failed: tuple | None = None

  def takes(provider: str, model: str, reference: dict) -> bool:
    try:
      return bool(accept(provider, model, reference))
    except Exception:
      return False

  def unanswered() -> Iterator[tuple[int, tuple, UsageRow, tuple, bool]]:
    for line_number, key, day, before in asked:
      target = before if failed is None else failed
      if day is None or not target:
        continue
      provider, model, reference = target
      yield line_number, ("asked", *key), UsageRow(day, path, provider, model, 0, 0, 0, 0, 1), (key,), takes(provider, model, reference)

  for line_number, entry, line in parsed:
    try:
      if line is None:
        continue
      kind = line[0]
      if kind == "model":
        context = tuple(line[1:4])
        continue
      # The entry's own time, else the message's.
      timestamp = entry.get("timestamp")
      if timestamp is None:
        timestamp = obj(entry.get("message")).get("timestamp")
      if kind == "prompt":
        # Only a prompt no reply answered is still asked: it is its own row,
        # so a fork that copies it books it under the same key. One with no
        # model known yet rides on the next reply, as before.
        if asked:
          yield from unanswered()
          asked = [prompt for prompt in asked if failed is None and prompt[3] is None]
          failed = None
        asked.append((line_number, _pi_key(entry, timestamp, path), local_day(timestamp), context))
        continue
      if kind == "summary":
        if context is None:
          continue
        provider, model, reference = context
        usage = line[1]
      else:
        provider, model, reference, usage = line[1:]
        if kind == "reply":
          context = (provider, model, reference)
      counted = _pi_row(entry, timestamp, path, provider, model, obj(usage), int(kind == "reply" and not typed))
      answered: list[tuple] = []
      if kind == "reply":
        if counted is not None:
          answered, asked, failed = asked, [], None
        elif asked and failed is None:
          failed = () if _pi_unsent(reference) else (provider, model, reference)
    except Exception:
      # One odd line costs that line, never the scan.
      continue
    if counted is None:
      continue
    taken = takes(provider, model, reference)
    key, row = counted
    # Prompts typed on the reply's day ride on its row; one typed on another
    # day is a row of its own there, keyed by the reply that answered it.
    days: dict[str, list[tuple]] = {}
    for _, prompt, day, _ in answered:
      if day is not None:
        days.setdefault(day, []).append(prompt)
    asks = days.pop(row.day, [])
    yield line_number, key, row._replace(prompts=row.prompts + len(asks)), tuple(asks), taken
    for day, asks in sorted(days.items()):
      yield line_number, ("prompt", day, *key), UsageRow(day, path, provider, model, 0, 0, 0, 0, len(asks)), tuple(asks), taken
  yield from unanswered()


def scan_pi_sessions(pattern: str, accept: Accept, roots: Iterable[Path] | None = None) -> tuple[list[UsageRow], bool]:
  """Every pi/omp reply `accept` takes, each counted once, and whether every
  root was read in full.

  `pattern` is an rg regex every such line matches (the provider field,
  say); it only keeps other lines and files out of the parse, and `accept`
  stays the authority for the ones that reach it. A message a fork repeats is one row,
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

  # Usage that names no provider of its own, spent on the session's model,
  # the prompts the replies answer, every reply, since one another provider
  # gave still answers the prompt before it, and every model switch, which
  # says whose a summary or a prompt no reply answered is.
  switch = r'"type"\s*:\s*"model_change"'
  context = r'"type"\s*:\s*"(compaction|branch_summary)"|"role"\s*:\s*"toolResult".*"usage"\s*:\s*\{|"role"\s*:\s*"(user|assistant)"|' + switch

  # (root, path, line) of every counted line, so the rows come back in one
  # order however rg's threads interleave the files.
  found: list[tuple[int, str, int, tuple, UsageRow, tuple]] = []
  complete = True
  # Each file's lines, folded in order when rg finishes the file.
  pending: dict[str, list[tuple[int, Any]]] = {}
  # Every booking of each typed prompt, whichever provider took it, so one a
  # fork answered on another provider books under one collector alone.
  bookings: dict[tuple, list[tuple]] = {}
  read: set[str] = set()
  parents: dict[str, str | None] = {}

  def ancestors(path: str) -> set[str]:
    found: set[str] = set()
    parent = parents.setdefault(path, pi_parent_session(path))
    while parent and parent not in found and parent != path:
      found.add(parent)
      parent = parents.setdefault(parent, pi_parent_session(parent))
    return found

  def fold(index: int | None, path: str) -> None:
    # `index` None reads a file for its bookings alone.
    read.add(path)
    depth = len(ancestors(path))
    for line_number, key, row, asks, taken in _pi_rows(path, sorted(pending.pop(path, []), key=lambda line: line[0]), accept):
      for ask in asks:
        # An answer before a prompt no reply answered, the oldest session's
        # first, as a fork copies its parent's.
        bookings.setdefault(ask, []).append((key[0] == "asked", depth, path, line_number, (key, row.provider, row.model)))
      if taken and index is not None:
        found.append((index, path, line_number, key, row, asks))

  def run_rg(args: list[str], targets: list[bytes]) -> Iterator[bytes]:
    """rg's output lines for `args` over `targets`, a batch of them at a time
    so a long list of files stays under the argument limit."""
    nonlocal complete
    batches: list[list[bytes]] = [[]]
    size = 0
    for target in targets:
      if batches[-1] and size + len(target) > 100_000:
        batches.append([])
        size = 0
      batches[-1].append(target)
      size += len(target) + 1
    for batch in batches:
      if not batch:
        continue
      try:
        # --no-ignore: these are data files, not a source tree. When $HOME is
        # itself a git checkout (a common dotfiles setup), its ignore rules
        # would otherwise hide every session file and count zero usage.
        proc = subprocess.Popen([rg, "--no-ignore", "--hidden", *args, "--", *batch], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, env=runtime_env())
      except OSError:
        complete = False
        return
      assert proc.stdout is not None
      with proc.stdout:
        yield from proc.stdout
      try:
        # rg exits 1 for no match and 2 when it couldn't read something.
        if proc.wait(timeout=5) not in (0, 1):
          complete = False
      except subprocess.TimeoutExpired:
        proc.kill()
        complete = False

  def match_events(targets: list[bytes], patterns: list[str]) -> Iterator[tuple[str, str, int, Any]]:
    """(event type, path, line number, entry) for each rg match and file end."""
    args = ["--json"] + [arg for pattern in patterns for arg in ("-e", pattern)]
    for raw in run_rg(args, targets):
      try:
        event = json.loads(raw)
        data = event["data"]
        if event.get("type") == "end":
          yield "end", os.path.realpath(_rg_text(data.get("path"))), 0, None
        elif event.get("type") == "match":
          yield "match", os.path.realpath(_rg_text(data.get("path"))), number(data.get("line_number")), json.loads(_rg_text(data.get("lines")))
      except Exception:
        # One odd line costs that line, never the scan.
        continue

  def matching_files(targets: list[bytes], patterns: list[str]) -> list[bytes]:
    """The *.jsonl files under `targets` with a line matching any of `patterns`,
    by realpath, as the scan names them."""
    args = ["--files-with-matches", "--null", "--glob", "*.jsonl"] + [arg for pattern in patterns for arg in ("-e", pattern)]
    return [os.fsencode(os.path.realpath(os.fsdecode(name))) for name in b"".join(run_rg(args, targets)).split(b"\0") if name]

  for index, root in enumerate(roots):
    # Only a file holding this collector's lines can hold its rows, so the
    # files are picked first: those with a line `pattern` matches, and those
    # with a model switch `accept` takes, which says whose a summary or an
    # unanswered prompt there is (omp names the switch's provider/model,
    # which `pattern` doesn't see). Every other file's prompts and summaries
    # belong to another collector, and are never parsed here.
    owned = matching_files([os.fsencode(root)], [pattern])
    switched = set(matching_files([os.fsencode(root)], [switch])) - set(owned)
    for _, path, _, entry in match_events(sorted(switched), [switch]):
      line = _pi_line(entry)
      try:
        if line is not None and line[0] == "model" and accept(*line[1:4]):
          owned.append(os.fsencode(path))
      except Exception:
        continue
    for kind, path, line_number, entry in match_events(sorted(set(owned)), [pattern, context]):
      if kind == "end":
        fold(index, path)
      else:
        pending.setdefault(path, []).append((line_number, entry))
    for path in list(pending):
      fold(index, path)

  # A prompt's copies live in the forks of the session it was typed in, so
  # the other files of those fork trees holding a prompt this collector
  # booked are read for their bookings alone: each collector then picks the
  # same one among them. Only a prompt with an entry id has copies elsewhere.
  ids = {ask[1] for *_, asks in found for ask in asks if ask[0] == "entry"}
  children: dict[str, list[str]] = {}
  for name in matching_files([os.fsencode(root) for root in roots], [r'"parentSession"']) if ids else ():
    path = os.fsdecode(name)
    parent = parents.setdefault(path, pi_parent_session(path))
    if parent:
      children.setdefault(parent, []).append(path)
  family: set[str] = set()
  queue = list(read) if ids else []
  while queue:
    path = queue.pop()
    if path in family:
      continue
    family.add(path)
    queue.extend(ancestors(path) | set(children.get(path, ())))
  others = sorted(os.fsencode(path) for path in family - read if os.path.isfile(path) and any(Path(path).is_relative_to(root) for root in roots))
  if others and all(re.fullmatch(r"[A-Za-z0-9_.:-]+", key) for key in ids):
    # Such an id is written as itself, quoted, so a file holding none of
    # them quoted holds no copy, and is never parsed.
    try:
      with tempfile.NamedTemporaryFile("w", suffix=".ids") as quoted:
        quoted.write("".join(f'"{key}"\n' for key in sorted(ids)))
        quoted.flush()
        others = sorted({os.fsencode(os.path.realpath(os.fsdecode(name))) for name in b"".join(run_rg(["--files-with-matches", "--null", "--fixed-strings", "-f", quoted.name], others)).split(b"\0") if name})
    except OSError:
      # With nowhere to write the ids, every file of the family is read.
      pass
  for kind, path, line_number, entry in match_events(others, [context]):
    if kind == "end":
      fold(None, path)
    else:
      pending.setdefault(path, []).append((line_number, entry))
  for path in list(pending):
    fold(None, path)
  owner = {ask: min(candidates, key=lambda candidate: candidate[:4])[-1] for ask, candidates in bookings.items()}

  first: dict[tuple, UsageRow] = {}
  holders: dict[tuple, list[str]] = {}
  for _, path, _, key, row, asks in sorted(found, key=lambda item: item[:3]):
    if key not in first:
      # A typed prompt is its own message, so it counts once by its own key
      # however it was booked: a fork can copy one its parent left
      # unanswered and answer it, on a reply the parent never had and on
      # another provider too. The oldest session's answer books it, else
      # its booking unanswered, whichever collector that is.
      repeated = sum(1 for ask in asks if owner.get(ask) != (key, row.provider, row.model))
      row = row._replace(prompts=row.prompts - repeated)
      first[key] = row
    if path not in holders.setdefault(key, []):
      holders[key].append(path)

  # Resolved after the scan, so rg's file order cannot decide which copy of
  # a forked message counts toward which session.
  rows = []
  for key, row in first.items():
    if not (row.prompts or row.input_tokens or row.output_tokens or row.cache_read or row.cache_write):
      continue
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


def _opencode_tokens(value: Any) -> tuple[int, int, int, int]:
  """(input, output, cache read, cache write) of an opencode `tokens`
  object, each count one token_count() trusts."""
  tokens = obj(value)
  cache = obj(tokens.get("cache"))
  # opencode keeps thinking tokens out of output; both are generated.
  return token_count(tokens.get("input")), token_count(tokens.get("output")) + token_count(tokens.get("reasoning")), token_count(cache.get("read")), token_count(cache.get("write"))


def _opencode_row(session_id: Any, entry: Any, row_type: str, created: Any, accept: Accept, empty: bool = False) -> UsageRow | None:
  # Shared by both message stores. The original `message` table keeps the
  # provider and model at the top level; the V2 `session_message` table nests
  # them under `model` and keeps the role in its `type` column, with a
  # compaction's tokens spent like any reply's. `empty` keeps a row that
  # spent nothing, for the prompt it books; a user row is one such.
  if not isinstance(entry, dict) or (entry.get("role") or row_type) not in (("assistant", "compaction", "user") if empty else ("assistant", "compaction")):
    return None
  nested = obj(entry.get("model"))
  provider = str(entry.get("providerID") or nested.get("providerID") or "")
  model = str(entry.get("modelID") or nested.get("id") or nested.get("modelID") or "")
  if not accept(provider, model, entry):
    return None
  # A user row spent nothing, whatever it claims.
  input_tokens, output_tokens, cache_read, cache_write = _opencode_tokens(entry.get("tokens") if entry.get("role") != "user" else {})
  if not (input_tokens or output_tokens or cache_read or cache_write or empty):
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
  # The typed prompt each row answers, and where it falls among the steps
  # answering the same one; the first step books the prompt.
  turns: list[tuple[Any, tuple]] = []
  seen: set[str] = set()
  # A subagent's session: the prompts in it are the model's, not typed.
  children: set[str] = set()
  # The original store's first step answering each user message, whichever
  # provider took it, by (session, parentID).
  firsts: dict[tuple[str, str], str] = {}

  def take(message_id: Any, session_id: Any, raw: Any, row_type: str, created: Any, since: Any = None, turn: Any = "", empty: bool = False, typed: str | None = None) -> None:
    # `turn` is the prompt the row answers, None for none, or "" to read it
    # from the row; `empty` keeps a row that spent nothing, for that prompt,
    # dated `typed`, the day it was typed (None when that can't be trusted).
    # One row that still fails must not take the scan down with it.
    try:
      entry = json.loads(raw)
      # A copy a fork made predates the session holding it.
      spent_at = number(obj(obj(entry).get("time")).get("created"))
      if spent_at and spent_at < number(since):
        return
      row = _opencode_row(session_id, entry, row_type, created, accept, empty)
    except Exception:
      return
    # A migrated message can sit in both stores under the same id.
    if row is None or str(message_id) in seen:
      return
    seen.add(str(message_id))
    if empty and not (row.input_tokens or row.output_tokens or row.cache_read or row.cache_write):
      # A failed reply is only its prompt, which counts on its own day.
      if typed is None:
        return
      row = row._replace(day=typed)
    if turn == "":
      # The original store's steps name the user message they answer; a
      # compaction's summary answers the marker opencode adds, no prompt.
      parent = entry.get("parentID")
      if entry.get("summary") is True or entry.get("mode") == "compaction":
        turn = None
      elif isinstance(parent, str) and parent:
        turn = (str(session_id), parent)
        # A later step, even one another provider's first, answers none.
        if firsts.get(turn, str(message_id)) != str(message_id):
          turn = None
      else:
        turn = ("message", str(message_id))
    if str(session_id) in children:
      turn = None
    rows.append(row)
    turns.append((turn, (spent_at, str(message_id))))

  def answered() -> list[UsageRow]:
    first: dict[Any, int] = {}
    for index, (turn, order) in enumerate(turns):
      if turn is not None and (turn not in first or order < turns[first[turn]][1]):
        first[turn] = index
    return [row._replace(prompts=int(first.get(turn) == index)) for index, (row, (turn, _)) in enumerate(zip(rows, turns))]

  try:
    conn.execute("PRAGMA query_only = ON")
    tables = {name for (name,) in conn.execute("SELECT name FROM sqlite_master WHERE type = 'table'")}
    if "session" in tables and {"id", "parent_id"} <= _table_columns(conn, "session"):
      children = {str(session_id) for (session_id,) in conn.execute("SELECT id FROM session WHERE parent_id IS NOT NULL")}
    columns = _table_columns(conn, "session_message") if "session_message" in tables else set()
    if {"id", "session_id", "type", "data"} <= columns and patterns:
      # V2 keeps typed prompts as `user` rows without a model, so each books
      # the first reply after it in its session, one whose request failed
      # and spent nothing too; `synthetic` rows are the ones opencode adds
      # itself. A session without any keeps a prompt per reply.
      asked: set[str] = set()
      # Each reply booking a prompt, and the day its first user row was typed.
      replies: dict[str, str | None] = {}
      order = "seq" if "seq" in columns else "time_created" if "time_created" in columns else ""
      if order:
        for session_id, reply_id, created_at, typed_at in conn.execute(
          "SELECT u.session_id, (SELECT a.id FROM session_message a WHERE a.session_id = u.session_id AND a.type = 'assistant'"
          f" AND (a.{order} > u.{order} OR (a.{order} = u.{order} AND a.id > u.id)) ORDER BY a.{order}, a.id LIMIT 1),"
          " CASE WHEN json_valid(u.data) THEN json_extract(u.data, '$.time.created') END,"
          f" {'u.time_created' if 'time_created' in columns else 'NULL'}"
          f" FROM session_message u WHERE u.type = 'user' ORDER BY u.{order}, u.id"
        ):
          asked.add(str(session_id))
          if reply_id is not None and str(reply_id) not in replies:
            # The user row's own time, else the row's, as _opencode_row reads it.
            replies[str(reply_id)] = local_day(typed_at if created_at is None else created_at)
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
        if row_type == "compaction" or (str(session_id) in asked and str(message_id) not in replies):
          turn = None
        else:
          turn = ("message", str(message_id))
        take(message_id, session_id, raw, str(row_type or ""), time_created, turn=turn, empty=turn is not None and str(session_id) in asked, typed=replies.get(str(message_id)))
    columns = _table_columns(conn, "message") if "message" in tables else set()
    if {"session_id", "data"} <= columns and patterns:
      row_id = "m.id" if "id" in columns else "m.rowid"
      source = "message m"
      session_created = "NULL"
      if "session" in tables and {"id", "time_created"} <= _table_columns(conn, "session"):
        # A fork here is a plain new session holding copies of its source's
        # messages under new ids, each keeping its original time.created, so
        # a message older than its session was spent in the source.
        source += " LEFT JOIN session s ON s.id = m.session_id"
        session_created = "s.time_created"
      gate = " OR ".join("m.data LIKE ?" for _ in patterns)
      # This collector's own steps and prompts, read before the first steps
      # they need, which are looked up for their sessions alone.
      own_steps = list(conn.execute(
        f"SELECT {row_id}, m.session_id, m.data, {session_created} FROM {source}"
        f" WHERE m.data LIKE '%\"role\"%:%\"assistant\"%' AND ({gate})",
        patterns,
      ))
      own_prompts = list(conn.execute(
        f"SELECT {row_id}, m.session_id, m.data, {session_created} FROM {source}"
        f" WHERE m.data LIKE '%\"role\"%:%\"user\"%' AND ({gate})",
        patterns,
      ))
      # The first step that spent tokens on each user message across every
      # provider, so a tool loop that switches providers books its prompt
      # once, on whichever collector took that step. Only valid JSON is read,
      # so one odd row can't fail the query, and a step counts as first only
      # if take() would keep it: its tokens and time pass the same checks,
      # so a damaged step never takes the prompt from a valid one after it.
      # A session's first steps are its own, so only the sessions above are
      # read, through opencode's index on session_id, each id as stored.
      sessions = list(dict.fromkeys(session_id for _, session_id, _, _ in own_steps + own_prompts))
      for session_id, parent, first_id, created, tokens, since in conn.execute(
        "SELECT session_id, parent, id, created, tokens, since"
        " FROM (SELECT id, session_id, j, since, json_extract(j, '$.parentID') AS parent, json_extract(j, '$.time.created') AS created,"
        " json_extract(j, '$.tokens') AS tokens"
        f" FROM (SELECT {row_id} AS id, m.session_id, CASE WHEN json_valid(m.data) THEN m.data END AS j, {session_created} AS since"
        f" FROM {source} WHERE m.session_id IN (SELECT value FROM json_each(?))"
        " AND m.data LIKE '%\"parentID\"%' AND m.data LIKE '%\"role\"%:%\"assistant\"%'))"
        " WHERE typeof(parent) = 'text' AND parent != '' AND typeof(tokens) = 'text'"
        " AND json_extract(j, '$.summary') IS NOT 1 AND json_extract(j, '$.mode') IS NOT 'compaction'"
        " ORDER BY session_id, parent, created, CAST(id AS TEXT)",
        (json.dumps(sessions, default=str),),
      ) if sessions else ():
        turn = (str(session_id), str(parent))
        if turn in firsts:
          continue
        try:
          spent_at = number(created)
          if not any(_opencode_tokens(json.loads(tokens))) or local_day(created) is None or (spent_at and spent_at < number(since)):
            continue
        except Exception:
          continue
        firsts[turn] = str(first_id)
      for message_id, session_id, raw, since in own_steps:
        take(message_id, session_id, raw, "", None, since)
      # A typed prompt no step answered (its request failed or was cut off)
      # books itself, without tokens, on the model the user row names, the
      # one opencode sent it to. A compaction's marker is answered by its
      # summary, and one in a subagent's session isn't typed.
      waiting: list[tuple[Any, str, dict]] = []
      for message_id, session_id, raw, since in own_prompts:
        try:
          entry = json.loads(raw)
          if not isinstance(entry, dict) or entry.get("role") != "user" or str(session_id) in children or (str(session_id), str(message_id)) in firsts:
            continue
          typed_at = number(obj(entry.get("time")).get("created"))
          if typed_at and typed_at < number(since):
            continue
        except Exception:
          continue
        waiting.append((message_id, str(session_id), entry))
      if waiting:
        # The steps that did answer them: a compaction's summary, or a failed
        # request, whose id V2 may have booked the prompt under already.
        sessions = sorted({session_id for _, session_id, _ in waiting})
        steps: dict[tuple[str, str], str] = {}
        compacted: set[tuple[str, str]] = set()
        for start in range(0, len(sessions), 500):
          batch = sessions[start:start + 500]
          for step_id, session_id, raw in conn.execute(
            f"SELECT {row_id}, m.session_id, m.data FROM message m WHERE m.session_id IN ({', '.join('?' for _ in batch)})"
            " AND m.data LIKE '%\"parentID\"%' AND m.data LIKE '%\"role\"%:%\"assistant\"%'"
            f" ORDER BY {'m.time_created, ' if 'time_created' in columns else ''}CAST({row_id} AS TEXT)",
            batch,
          ):
            try:
              step = json.loads(raw)
              key = (str(session_id), str(step.get("parentID")))
              if step.get("summary") is True or step.get("mode") == "compaction":
                compacted.add(key)
              steps.setdefault(key, str(step_id))
            except Exception:
              continue
        for message_id, session_id, entry in waiting:
          key = (session_id, str(message_id))
          # opencode writes the step before it sends the request, so a user
          # row no step names was refused before sending (an unknown model or
          # provider) and counts nowhere.
          step_id = steps.get(key)
          if step_id is None or key in compacted or step_id in seen:
            continue
          try:
            row = _opencode_row(session_id, entry, "user", None, accept, empty=True)
          except Exception:
            continue
          if row is None:
            continue
          seen.add(step_id)
          rows.append(row)
          turns.append((("asked", session_id, str(message_id)), (0, str(message_id))))
  except sqlite3.Error:
    # Transient lock, schema migration, corruption: the numbers stop here,
    # incomplete.
    return answered(), False
  finally:
    conn.close()
  return answered(), True


# --------------------------------------------------- who bills an endpoint
#
# Some harnesses send to whatever base URL they are given and record only the
# model that answered, or a route's name: Claude Code fronts any endpoint
# ANTHROPIC_BASE_URL names, and a MiniMax Code custom provider any baseURL.
# Z.ai, Ollama, MiniMax, DeepSeek, Kimi, Alibaba's Model Studio, OpenRouter,
# Synthetic and Kimchi each document pointing them at their own APIs, so the
# host says whose tokens those turns are.

# The hosts a harness is pointed at in place of its own service, by the
# collector that bills them. A subdomain of one is the same service.
PROVIDER_HOSTS = {
  "api.z.ai": "zai",
  "open.bigmodel.cn": "zai",
  "ollama.com": "ollama",
  "api.minimax.io": "minimax",
  "api.minimaxi.com": "minimax",
  "api.deepseek.com": "deepseek",
  "api.moonshot.ai": "kimi",
  "api.moonshot.cn": "kimi",
  "api.kimi.com": "kimi",
  "api.kimi.ai": "kimi",
  # Model Studio (DashScope, the Coding and Token Plans) and Qwen's own
  # sign-in.
  "aliyuncs.com": "qwen",
  "alibabacloud.com": "qwen",
  "qwen.ai": "qwen",
  "openrouter.ai": "openrouter",
  # Synthetic's Anthropic- and OpenAI-compatible APIs (/anthropic, /openai/v1).
  "api.synthetic.new": "synthetic",
  # Kimchi's gateway in each region (llm.kimchi.dev, llm.eu.kimchi.dev), at
  # the /anthropic and /openai/v1 routes `kimchi claudecode`, `kimchi codex`
  # and its opencode setup write. It bills every model it serves, Claude,
  # Kimi, GLM and MiniMax ones too.
  "kimchi.dev": "kimchi",
}


def url_host(url: Any) -> str:
  """The lowercase host a URL names, or "" for none or a URL that isn't one."""
  try:
    return (urllib.parse.urlsplit(str(url or "").strip()).hostname or "").lower().rstrip(".")
  except ValueError:
    return ""


def self_hosted(url: Any) -> bool:
  """Whether a base URL points at hardware the user controls: this machine,
  a private or link-local address, or a LAN name."""
  host = url_host(url)
  if not host:
    return False
  if host == "localhost":
    return True
  try:
    address = ipaddress.ip_address(host)
    return address.is_loopback or address.is_private or address.is_link_local
  except ValueError:
    pass
  # A bare hostname is a LAN name by construction; the rest are the suffixes
  # home routers and mDNS hand out.
  if "." not in host:
    return True
  return host.endswith((".home", ".lan", ".local", ".internal", ".localdomain", ".home.arpa"))


def endpoint_owner(url: Any) -> str:
  """The collector that bills what a base URL serves: a provider host's, or
  `local` for one the user runs, or "" when nothing here can place it (a
  gateway or proxy that may forward anywhere)."""
  host = url_host(url)
  if not host:
    return ""
  owner = next((provider for name, provider in PROVIDER_HOSTS.items() if host == name or host.endswith("." + name)), "")
  return owner or ("local" if self_hosted(url) else "")


def cloud_model(model: Any) -> bool:
  """Whether a model is one of Ollama's hosted ones, which carry a cloud tag
  ("glm-4.6:cloud", "gpt-oss:120b-cloud"): a local daemon only forwards
  them, so Ollama's servers did the work."""
  text = str(model or "").lower()
  tag = text.rpartition(":")[2] if ":" in text else ""
  return tag == "cloud" or tag.endswith("-cloud")


# --------------------------------------------------------- Claude Code
#
# Claude Code writes one JSONL transcript per session under
# ~/.claude/projects (CLAUDE_CONFIG_DIR moves it). Each reply carries the
# model that answered and its usage, but not where it was sent: the claude
# collector counts the replies Anthropic served, and the collector of
# whichever provider ANTHROPIC_BASE_URL names, or whose model answered,
# counts the rest. claude_code_owner() is the one rule all of them apply, so
# every reply lands in exactly one record.

# What a model's name says about who served it, when Claude Code is pointed
# at no other host: these are those providers' own models.
CLAUDE_CODE_MODEL_OWNERS = (
  ("glm-", "zai"),
  ("minimax-", "minimax"),
  ("deepseek-", "deepseek"),
  ("kimi-", "kimi"),
  ("moonshot", "kimi"),
  # Synthetic's own naming: Hugging Face ids (hf:org/model) and its aliases
  # (syn:large:text).
  ("hf:", "synthetic"),
  ("syn:", "synthetic"),
)


def claude_code_dir() -> Path:
  return Path(os.path.expandvars(os.path.expanduser(os.environ.get("CLAUDE_CONFIG_DIR") or "~/.claude"))).resolve()


def claude_code_base_url(claude_dir: Path | None = None) -> str:
  """Where ANTHROPIC_BASE_URL sends Claude Code now: its settings' env wins
  over the environment, as it does in Claude Code."""
  env = read_json((claude_dir or claude_code_dir()) / "settings.json").get("env")
  configured = env.get("ANTHROPIC_BASE_URL") if isinstance(env, dict) else None
  return str(configured or os.environ.get("ANTHROPIC_BASE_URL") or "").strip()


def claude_code_endpoint(base_url: str) -> str:
  """The kind of endpoint Claude Code is sent to, which is all that decides
  who owns its replies: "" for Anthropic's own (no override), a provider
  collector's id, `local`, or `other` for a host nothing here can place."""
  host = url_host(base_url)
  if not host or host == "anthropic.com" or host.endswith(".anthropic.com"):
    return ""
  return endpoint_owner(base_url) or "other"


def claude_code_owner(model: Any, base_url: str = "") -> str | None:
  """The collector that counts a Claude Code reply by `model` (None for a
  prompt no reply has answered yet) while Claude Code is sent to `base_url`,
  or None when nothing here can say who billed it.

  A transcript doesn't say where it was sent, so while ANTHROPIC_BASE_URL
  names a provider's host every reply is read as that provider's, whatever
  its model: a Claude or kimi-* reply through Kimchi's gateway is Kimchi's,
  never Anthropic's or Kimi's. Otherwise an Ollama cloud tag is Ollama's,
  wherever it was sent, and a Claude model
  is Anthropic's, through a proxy that may forward to it too. Behind a
  self-hosted base URL anything else ran on the user's own hardware. With no
  override the model's name says whose it was (glm-* is Z.ai's, MiniMax-*
  MiniMax's, deepseek-* DeepSeek's, kimi-* and moonshot* Kimi's, hf:* and
  syn:* Synthetic's); behind a
  gateway nothing here can place, it could be anyone's, and counts nowhere.
  """
  endpoint = claude_code_endpoint(base_url)
  if endpoint not in ("", "local", "other"):
    return endpoint
  name = str(model).lower() if model is not None else ""
  if cloud_model(name):
    return "ollama"
  if model is None or "claude" in name:
    return "claude"
  if endpoint == "local":
    return "local"
  if endpoint == "other":
    return None
  return next((owner for prefix, owner in CLAUDE_CODE_MODEL_OWNERS if name.startswith(prefix)), None)


# Transcripts are append-only, and most of the corpus never changes between
# ticks, so the scan keeps a per-file index: the unique usage records already
# parsed out of each file plus the byte offset they end at. A file whose size
# and mtime match the index is not opened; a file that grew is read from the
# stored offset; anything else (truncated, rewritten, replaced, unknown) is
# read from the start. Every collector reading Claude Code shares the index,
# which holds every reply whoever owns it.
#
# Version 5 reads token counts and times the way every collector reads them
# (a count written as a string is no count, an untrusted time skips its line),
# so an index parsed the older way is read again. Version 6 stops reading a
# falsy time (0, false, "") as no time at all, which counted it as today.
# Version 7 keeps the typed prompts too, which are the record's prompts; a
# reply was counted as one before. Version 8 keys a reply by its request too,
# and keeps its bare message id and whether a sidechain wrote it. Version 9
# reads the advisor iterations a reply carries. Version 10 keeps the model
# that answered each prompt. Version 11 stops counting a built-in local
# command (/model, /clear, /compact) as a prompt. Version 12 keeps each
# reply's time and the cost-state totals, which count the requests no reply
# records.
CLAUDE_CODE_INDEX_VERSION = 12

# How much of each end of what was read the index remembers a hash of, so a
# file replaced or rewritten with more than it had is not mistaken for an
# append.
CLAUDE_CODE_INDEX_HEAD_BYTES = 4096

# What Claude Code puts in a user line that nobody typed: a background task
# reporting back, a local command's output and its caveat, and the marker an
# interruption leaves.
CLAUDE_CODE_MACHINE_PROMPTS = ("<task-notification>", "<local-command-stdout>", "<local-command-stderr>", "<local-command-caveat>", "[Request interrupted")
# What a local command's output starts with, which says the command it
# answers was no prompt.
CLAUDE_CODE_LOCAL_OUTPUT = ("<local-command-stdout>", "<local-command-stderr>")
# Who sent a prompt, where Claude Code records it (a user line's
# promptSource, a queued one's origin.kind): the system (a task notification)
# and another agent are not a person asking.
CLAUDE_CODE_MACHINE_SOURCES = ("system", "task-notification", "peer")

# A line's own time, the last `timestamp` it holds (Claude Code writes it
# after the message), read without parsing the line.
CLAUDE_CODE_STAMP = re.compile(rb'"timestamp":\s*"([^"\\]{1,64})"')

# Claude Code 2.1.308 and later write a `cost-state` line when a process
# saves its running cost: `startTime` names the process's cost lineage,
# which a resume or `--fork-session` carries on, and `modelUsage` holds what
# each model has used in it so far, the requests no reply line records
# (a compaction, the session title, a side query) included. Its model names
# carry the context window as a suffix the replies don't.
CLAUDE_CODE_COST_MODEL_SUFFIX = re.compile(r"\[1m\]$", re.IGNORECASE)


def claude_code_index_path(projects: Path) -> Path:
  digest = hashlib.sha1(str(projects).encode("utf-8", "surrogatepass")).hexdigest()[:16]
  return cache_root() / f"claude-index-{digest}.json"


# Records hold local days, so an index is only true in the timezone that
# wrote it; after a change every transcript is read again.
def _claude_code_index_zone() -> list[Any]:
  return [os.environ.get("TZ"), list(time.tzname), time.timezone, time.altzone]


def _claude_code_load_index(index_file: Path) -> dict[str, Any]:
  data = read_json(index_file)
  if data.get("version") == CLAUDE_CODE_INDEX_VERSION and data.get("zone") == _claude_code_index_zone() and isinstance(data.get("files"), dict):
    return data["files"]
  return {}


# What was already read, by its first and last few kilobytes: a transcript
# rewritten in place rather than appended to changes one or the other.
def _claude_code_digest(path: Path, length: int) -> str:
  digest = hashlib.sha1()
  with path.open("rb") as handle:
    digest.update(handle.read(min(length, CLAUDE_CODE_INDEX_HEAD_BYTES)))
    handle.seek(max(0, length - CLAUDE_CODE_INDEX_HEAD_BYTES))
    digest.update(handle.read(min(length, CLAUDE_CODE_INDEX_HEAD_BYTES)))
  return digest.hexdigest()


def claude_code_typed_prompt(line: dict[str, Any]) -> bool:
  """Whether a transcript line is a prompt a person sent: a main-thread user
  message that isn't a tool's result, Claude Code's own (isMeta), a
  compaction summary, or a subagent's (isSidechain); or a prompt typed while
  a turn was running, which Claude Code queues into the turn as a
  queued_command attachment rather than a user line."""
  if line.get("isMeta") or line.get("isSidechain") or line.get("isCompactSummary"):
    return False
  if line.get("type") == "attachment":
    queued = line.get("attachment")
    if not isinstance(queued, dict) or queued.get("type") != "queued_command" or queued.get("commandMode") != "prompt" or queued.get("isMeta"):
      return False
    origin = queued.get("origin")
    return not (isinstance(origin, dict) and origin.get("kind") in CLAUDE_CODE_MACHINE_SOURCES)
  if line.get("type") != "user" or line.get("promptSource") in CLAUDE_CODE_MACHINE_SOURCES:
    return False
  text = _claude_code_user_text(line)
  return text is not None and not text.lstrip().startswith(CLAUDE_CODE_MACHINE_PROMPTS)


def _claude_code_user_text(line: dict[str, Any]) -> str | None:
  """The text of a user line, None for a tool's result or no content."""
  message = line.get("message")
  content = message.get("content") if isinstance(message, dict) else None
  if isinstance(content, str):
    return content
  if isinstance(content, list):
    blocks = [block for block in content if isinstance(block, dict)]
    if not blocks or any(block.get("type") == "tool_result" for block in blocks):
      return None
    return next((str(block.get("text") or "") for block in blocks if block.get("type") == "text"), "")
  return None


def claude_code_local_command(line: dict[str, Any]) -> str | None:
  """The uuid of the command a transcript line is the local output of. A
  built-in that runs on its own (/model, /clear, /compact, /exit) answers its
  `<command-name>` line with a `<local-command-stdout>` or `-stderr` child,
  a user line or a `local_command` system line, and asks the model nothing;
  a custom command or skill expands into a prompt instead, and has none."""
  if line.get("type") == "system":
    text = line.get("content") if isinstance(line.get("content"), str) else None
  elif line.get("type") == "user":
    text = _claude_code_user_text(line)
  else:
    return None
  parent = line.get("parentUuid")
  if text is not None and isinstance(parent, str) and text.lstrip().startswith(CLAUDE_CODE_LOCAL_OUTPUT):
    return parent
  return None


def _claude_code_line_day(parsed: dict[str, Any], message: dict[str, Any]) -> tuple[bool, str | None]:
  """(trusted, day) of a transcript line. A line with no time is today's,
  kept as None so the index stays true past midnight; one whose time can't
  be trusted counts nowhere. A time of 0, false or "" is present and
  untrusted, not missing."""
  timestamp = parsed.get("timestamp")
  if timestamp is None:
    timestamp = message.get("timestamp")
  if timestamp is None:
    return True, None
  day = local_day(timestamp)
  return day is not None, day


def _claude_code_moment(value: Any) -> float | None:
  """When a trusted transcript time was, as epoch seconds, to put a reply
  before or after a cost-state line (None for no time)."""
  if value is None or isinstance(value, bool):
    return None
  if isinstance(value, str) and re.fullmatch(r"[0-9]{1,20}", value.strip()):
    value = int(value.strip())
  if isinstance(value, (int, float)):
    seconds = math.floor(number(value))
    return seconds / 1000 if seconds > 10_000_000_000 else float(seconds)
  try:
    return datetime.fromisoformat(str(value).strip().replace("Z", "+00:00")).timestamp()
  except (OverflowError, OSError, ValueError):
    return None


def _claude_code_cost_state(parsed: dict[str, Any]) -> tuple[str, dict[str, list[int]]] | None:
  """The cost lineage and per-model [input, output, cacheRead, cacheWrite]
  totals of a cost-state line, None for one of another shape."""
  usage = parsed.get("modelUsage")
  start = parsed.get("startTime")
  if not isinstance(usage, dict) or start is None or isinstance(start, (bool, dict, list)) or str(start) == "":
    return None
  models: dict[str, list[int]] = {}
  for name, counts in usage.items():
    if not isinstance(counts, dict):
      continue
    tokens = [
      usage_tokens(counts, "inputTokens", "input_tokens"),
      usage_tokens(counts, "outputTokens", "output_tokens"),
      usage_tokens(counts, "cacheReadInputTokens", "cache_read_input_tokens"),
      usage_tokens(counts, "cacheCreationInputTokens", "cache_creation_input_tokens"),
    ]
    # One model under both names is two counters of the same model.
    held = models.setdefault(CLAUDE_CODE_COST_MODEL_SUFFIX.sub("", str(name)), [0, 0, 0, 0])
    for kind, count in enumerate(tokens):
      held[kind] += count
  return str(start), models


def read_claude_code_transcript(path: Path, entry: dict[str, Any] | None) -> dict[str, Any]:
  """Return the index entry for one transcript, reusing `entry` where the file
  only grew. Records are [key, model, day, input, output, cacheRead,
  cacheWrite, session, messageId, sidechain, moment]; prompts are [key, day,
  session, model], the model of the first reply after it (None until one
  is read); costs are [lineage, session, day, moment, {model: [input,
  output, cacheRead, cacheWrite]}], each cost-state line's totals at the
  time of the last line before it. A `day` is None, and a `moment` (epoch
  seconds) too, when the line carries no timestamp."""
  info = path.stat()
  size = info.st_size
  mtime = info.st_mtime_ns

  if entry and entry.get("size") == size and entry.get("mtime") == mtime:
    return entry

  # Only the same file, grown past what was read with what was read still in
  # place, is an append. A transcript replaced by a larger one is a new file,
  # and one rewritten in place has a different start or end.
  if (
    entry
    and size > number(entry.get("size"))
    and entry.get("file") == [info.st_dev, info.st_ino]
    and entry.get("head") == _claude_code_digest(path, number(entry.get("offset")))
  ):
    records = list(entry.get("records") or [])
    prompts = [list(prompt) for prompt in entry.get("prompts") or []]
    costs = list(entry.get("costs") or [])
    stamp = entry.get("stamp")
    offset = number(entry.get("offset"))
    line_number = number(entry.get("lines"))
  else:
    records = []
    prompts = []
    costs = []
    stamp = None
    offset = 0
    line_number = 0

  # A streamed response is several lines sharing one message id, and the
  # first line's output_tokens is a placeholder while the last carries the
  # real count. Keep each message's line with the highest output count (the
  # last one read wins a tie), whole: a response that fell back to another
  # model mid-stream has lines that are separate snapshots, and mixing fields
  # across them over-counts cache tokens and credits the wrong model.
  positions = {record[0]: index for index, record in enumerate(records)}
  prompted = {prompt[0] for prompt in prompts}
  # Prompts still waiting for their reply, which says who answered them.
  unanswered = [prompt for prompt in prompts if prompt[3] is None]
  stamped: tuple[bytes, int] | None = None

  def last_stamp() -> Any:
    found = CLAUDE_CODE_STAMP.match(stamped[0], stamped[1]) if stamped else None
    return found.group(1).decode("utf-8", errors="replace") if found else stamp

  with path.open("rb") as handle:
    handle.seek(offset)
    for raw in handle:
      if not raw.endswith(b"\n"):
        # A line still being written; pick it up whole next time.
        break
      offset += len(raw)
      line_number += 1

      # A cost-state line carries no time of its own: it was written when
      # the line before it was, read only when one turns up.
      at = raw.rfind(b'"timestamp":')
      if at >= 0:
        stamped = (raw, at)

      # Cheap pre-filter before JSON parsing keeps files with unrelated
      # lines inexpensive.
      if b'"usage":' not in raw and b'"user"' not in raw and b'"queued_command"' not in raw and b"<local-command-std" not in raw and b'"cost-state"' not in raw:
        continue

      try:
        parsed = json.loads(raw.decode("utf-8", errors="replace"))
      except Exception:
        continue
      # A line of JSON that isn't an object is a bad row, not a bad file.
      if not isinstance(parsed, dict):
        continue

      message = parsed.get("message") if isinstance(parsed.get("message"), dict) else {}

      if parsed.get("type") == "cost-state":
        stamp = last_stamp()
        stamped = None
        cost = _claude_code_cost_state(parsed)
        day = local_day(stamp) if stamp is not None else None
        if cost is not None and (stamp is None or day is not None):
          costs.append([cost[0], str(parsed.get("sessionId") or path), day, _claude_code_moment(stamp), cost[1]])
        continue

      # A prompt copied into a resumed or forked transcript keeps its uuid,
      # so the uuid counts it once.
      # A local command's output takes back the prompt its command line
      # looked like.
      command = claude_code_local_command(parsed)
      if command is not None:
        held = next((prompt for prompt in prompts if prompt[0] == command), None)
        if held is not None:
          prompts.remove(held)
          if held in unanswered:
            unanswered.remove(held)
        continue

      if parsed.get("type") in ("user", "attachment"):
        if claude_code_typed_prompt(parsed):
          trusted, day = _claude_code_line_day(parsed, message)
          prompt_key = str(parsed.get("uuid") or f"{path}:{line_number}")
          if trusted and prompt_key not in prompted:
            prompted.add(prompt_key)
            prompts.append([prompt_key, day, str(parsed.get("sessionId") or path), None])
            unanswered.append(prompts[-1])
        continue

      if parsed.get("type") != "assistant" and message.get("role") != "assistant":
        continue

      usage = message.get("usage") or parsed.get("usage")
      if not isinstance(usage, dict):
        continue

      # One response is one message id and one request id, across every
      # transcript a copy of it lands in: a gateway can reuse a message id for
      # every response it serves, and only the request tells those apart.
      message_id = str(message.get("id") or parsed.get("messageId") or "")
      request_id = str(parsed.get("requestId") or "")
      if message_id:
        key = f"{message_id}:{request_id}" if request_id else message_id
      else:
        key = f"{path}:{parsed.get('uuid') or request_id or line_number}"

      trusted, day = _claude_code_line_day(parsed, message)
      if not trusted:
        continue
      moment = _claude_code_moment(parsed["timestamp"] if parsed.get("timestamp") is not None else message.get("timestamp")) if day is not None else None

      # An advisor the model consulted is billed apart, under its own model:
      # Claude Code prices each `advisor_message` iteration on its own, and the
      # reply's top-level usage is the main model's alone.
      session_key = str(parsed.get("sessionId") or path)
      sidechain = parsed.get("isSidechain") is True
      served = [(key, message_id, str(message.get("model") or parsed.get("model") or "claude"), usage)]
      iterations = usage.get("iterations")
      for index, iteration in enumerate(iterations if isinstance(iterations, list) else []):
        if isinstance(iteration, dict) and iteration.get("type") == "advisor_message" and iteration.get("model"):
          served.append((f"{key}:advisor:{index}", f"{message_id}:advisor:{index}" if message_id else "", str(iteration["model"]), iteration))

      for record_key, record_id, model, counts in served:
        input_tokens = usage_tokens(counts, "input_tokens", "inputTokens")
        output_tokens = usage_tokens(counts, "output_tokens", "outputTokens")
        cache_read = usage_tokens(counts, "cache_read_input_tokens", "cacheReadInputTokens")
        cache_write = usage_tokens(counts, "cache_creation_input_tokens", "cacheCreationInputTokens")
        if input_tokens + output_tokens + cache_read + cache_write <= 0:
          continue

        # The first reply a model spent tokens on says who answered the
        # prompts before it: not a subagent's, which answers the subagent,
        # and not one Claude Code made up itself (`<synthetic>`, no tokens).
        if record_key == key and not sidechain:
          for prompt in unanswered:
            prompt[3] = model
          unanswered.clear()

        held = positions.get(record_key)
        if held is not None and output_tokens < records[held][4]:
          continue

        record = [record_key, model, day, input_tokens, output_tokens, cache_read, cache_write, session_key, record_id, sidechain, moment]
        if held is None:
          positions[record_key] = len(records)
          records.append(record)
        else:
          records[held] = record

  return {
    "size": size,
    "file": [info.st_dev, info.st_ino],
    "mtime": mtime,
    "head": _claude_code_digest(path, offset),
    "offset": offset,
    "lines": line_number,
    "records": records,
    "prompts": prompts,
    "costs": costs,
    "stamp": last_stamp(),
  }


def _claude_code_index_stamp(index_file: Path) -> tuple[int, int, int] | None:
  """Which index file is there now: a write replaces it whole."""
  try:
    info = index_file.stat()
  except OSError:
    return None
  return (info.st_ino, info.st_mtime_ns, info.st_size)


def _claude_code_index_fresh(index: dict[str, Any], files: list[Path]) -> bool:
  """Whether `index` holds every transcript in `files` as it is now, and no
  other, so nothing needs reading."""
  if len(index) != len(files):
    return False
  for path in files:
    entry = index.get(str(path))
    try:
      info = path.stat()
    except OSError:
      return False
    if not entry or entry.get("size") != info.st_size or entry.get("mtime") != info.st_mtime_ns:
      return False
  return True


def _claude_code_read_transcripts(files: list[Path], previous: dict[str, Any]) -> tuple[dict[str, Any], list[str], bool]:
  """Each transcript's index entry, reusing `previous`, the order they were
  read in, and whether every one could be read."""
  current: dict[str, Any] = {}
  order: list[str] = []
  unreadable_count = 0
  unreadable_examples: list[str] = []
  for path in files:
    key = str(path)
    try:
      current[key] = read_claude_code_transcript(path, previous.get(key))
    except Exception as exc:
      unreadable_count += 1
      if len(unreadable_examples) < 3:
        unreadable_examples.append(f"{path}: {exc}")
      # What was read before is still true of the file.
      if key in previous:
        current[key] = previous[key]
    if key in current:
      order.append(key)

  if unreadable_count:
    examples = "; ".join(unreadable_examples)
    print(f"Ignoring {unreadable_count} unreadable Claude project files (examples: {examples})", file=sys.stderr)
  return current, order, not unreadable_count


_DEFAULT_INDEX = object()


def scan_claude_code(
  owner: str,
  projects: Path | None = None,
  index_file: Any = _DEFAULT_INDEX,
  base_url: str | None = None,
  reread: bool = False,
) -> list[UsageRow]:
  """claude_code_usage()'s rows alone."""
  return claude_code_usage(owner, projects, index_file, base_url, reread)[0]


def claude_code_usage(
  owner: str,
  projects: Path | None = None,
  index_file: Any = _DEFAULT_INDEX,
  base_url: str | None = None,
  reread: bool = False,
) -> tuple[list[UsageRow], bool]:
  """The Claude Code usage `owner` counts, and whether every transcript was
  read: one that can't be read keeps what was read of it before, and a scan
  missing the rest is not one to cache. The rows are each reply once (with
  no prompts of its own), each typed prompt once (no tokens), and a tokenless
  row for every session in use on a day, for Stats.add_row(). A prompt's row
  names the model that answered it ("" for none yet), so a collector that
  keeps some models alone can keep their prompts alone too.

  `projects` defaults to the Claude Code home's projects/, `index_file` to
  the index every collector shares there (None reads without one), and
  `base_url` to where Claude Code is sent now. `reread` reads every
  transcript from the start and replaces the index, which other collectors
  keep reading meanwhile. Every reply is deduplicated across transcripts
  before claude_code_owner() splits them, so a reply a fork copied lands
  once, under one owner.
  """
  if projects is None:
    projects = claude_code_dir() / "projects"
  if base_url is None:
    base_url = claude_code_base_url(projects.parent)
  if index_file is _DEFAULT_INDEX:
    try:
      index_file = claude_code_index_path(projects)
    except OSError as exc:
      warn(f"scan index unavailable ({exc})")
      index_file = None
  # Every collector reading Claude Code runs at once (the update command
  # backgrounds one per agent), so one of them brings the index up to date
  # while the others wait on its lock and then find nothing left to read. An
  # index that already answers for every transcript is read without waiting.
  # Directory order, as before: when one API message shows up in several
  # transcripts with the same output count, the last file visited wins, and
  # the numbers must not move because the scan got faster.
  files = list(projects.rglob("*.jsonl")) if projects.is_dir() else []
  if not index_file:
    current, order, complete = _claude_code_read_transcripts(files, {})
  else:
    lock_file = index_file.with_name(index_file.name + ".lock")

    def build(previous: dict[str, Any]) -> tuple[dict[str, Any], list[str], bool]:
      current, order, complete = _claude_code_read_transcripts(files, previous)
      if current != previous:
        try:
          write_json(index_file, {"version": CLAUDE_CODE_INDEX_VERSION, "zone": _claude_code_index_zone(), "files": current}, sort_keys=True)
        except Exception as exc:
          warn(f"could not write the Claude scan index {index_file} ({exc})")
      return current, order, complete

    loaded = _claude_code_index_stamp(index_file)
    previous = {} if reread else _claude_code_load_index(index_file)
    built = None
    if reread or not _claude_code_index_fresh(previous, files):
      with exclusive_lock(lock_file):
        if reread or _claude_code_index_stamp(index_file) == loaded:
          built = build(previous)
      # Whoever held the lock wrote the index meanwhile, most likely all
      # this reader needs.
      if built is None:
        previous = _claude_code_load_index(index_file)
        if not _claude_code_index_fresh(previous, files):
          with exclusive_lock(lock_file):
            built = build(_claude_code_load_index(index_file))
    # An index fresh for every transcript read them all.
    current, order, complete = built or (previous, [str(path) for path in files], True)

  owners: dict[Any, str | None] = {}

  def ours(model: Any) -> bool:
    if model not in owners:
      owners[model] = claude_code_owner(model, base_url)
    return owners[model] == owner

  # One API message can show up in several transcripts (a resumed session
  # carries the earlier ones). As within a file, the record with the highest
  # output count wins, the last one visited breaking a tie. Only the tokens
  # are deduplicated: every transcript holding a reply on a day was a session
  # in use that day, so a fork that copied a session's replies never takes
  # that session out of the count.
  seen: dict[str, list[Any]] = {}
  # When a reply was first written, whichever copy of it counts.
  earliest: dict[str, float] = {}
  active: set[tuple[Any, str, str]] = set()
  for key in order:
    for record in current[key].get("records") or []:
      if ours(record[1]):
        active.add((record[2], record[7], record[1]))
      if record[10] is not None and record[10] < earliest.get(record[0], math.inf):
        earliest[record[0]] = record[10]
      held = seen.get(record[0])
      if held is not None and record[4] < held[4]:
        continue
      seen[record[0]] = record

  # A sidechain (a /btw side question) replays its parent's messages whole
  # under new request ids; the parent's own copy is the one that counts. A
  # subagent's own reply is a request of its own, which a gateway reusing one
  # message id can still give its parent's id, so only a whole copy is one.
  parents = {(record[8], record[7], *record[3:7]) for record in seen.values() if record[8] and not record[9]}
  scan_day = today()
  rows: list[UsageRow] = []
  replies: list[list[Any]] = []
  for record in seen.values():
    _, model, day, input_tokens, output_tokens, cache_read, cache_write, session_key, message_id, sidechain, _ = record
    if sidechain and (message_id, session_key, input_tokens, output_tokens, cache_read, cache_write) in parents:
      continue
    replies.append(record)
    if ours(model):
      rows.append(UsageRow(day or scan_day, session_key, owner, model, input_tokens, output_tokens, cache_read, cache_write, prompts=0))
  for day, session_key, model, counts in _claude_code_unrecorded(current, order, replies, earliest):
    if ours(model):
      rows.append(UsageRow(day or scan_day, session_key, owner, model, *counts, prompts=0))

  # A prompt is what a person typed, not each API request a tool loop makes,
  # so replies carry no prompts and the typed ones are counted on their own,
  # once each across transcripts, under whoever answered them.
  typed: dict[str, list[Any]] = {}
  for key in order:
    for prompt in current[key].get("prompts") or []:
      if ours(prompt[3]):
        active.add((prompt[1], prompt[2], prompt[3] or ""))
      typed.setdefault(prompt[0], prompt)
  for _, day, session_key, model in typed.values():
    if ours(model):
      rows.append(UsageRow(day or scan_day, session_key, owner, model or "", 0, 0, 0, 0, prompts=1))
  for day, session_key, model in sorted(active, key=lambda item: (str(item[0]), item[1], item[2])):
    rows.append(UsageRow(day or scan_day, session_key, owner, model, 0, 0, 0, 0, prompts=0))
  return rows, complete


def _claude_code_unrecorded(
  current: dict[str, Any], order: list[str], replies: list[list[Any]], earliest: dict[str, float]
) -> list[tuple[str | None, str, str, list[int]]]:
  """What the cost-state lines say was used beyond the replies, as (day,
  session, model, [input, output, cacheRead, cacheWrite]): the requests no
  reply line records, a compaction's, the session title's, a side query's.

  A cost lineage (one `startTime`) holds every session that carried it on,
  forks included, so each is counted once: its cost-states are taken in
  time order, each against every reply of its sessions written by then
  (subagents' included, which run under their parent's session), and only
  what one says beyond the most already counted is new, on that cost-state's
  day. A fork's total includes its parent's, and the parent's own replies
  are among those it is held against, so the parent is never counted twice;
  two branches that both went on are held against each other's replies too,
  which can only count too little. Nor can a model name the replies don't
  use add anything: no more counts, kind by kind, than the whole cost-state
  says beyond all the replies.
  """
  lineages: dict[str, list[list[Any]]] = {}
  for key in order:
    for cost in current[key].get("costs") or []:
      lineages.setdefault(cost[0], []).append(cost)
  if not lineages:
    return []

  by_session: dict[str, list[tuple[float, str, list[int]]]] = {}
  for record in replies:
    # A reply with no time is held against every cost-state.
    moment = earliest.get(record[0], -math.inf)
    by_session.setdefault(record[7], []).append((moment, record[1], record[3:7]))

  unrecorded: dict[tuple[str | None, str, str], list[int]] = {}
  for events in lineages.values():
    sessions = {event[1] for event in events}
    lineage_replies = sorted((reply for session in sessions for reply in by_session.get(session, ())), key=lambda reply: reply[0])
    # A cost-state with no time is the last, held against every reply.
    events.sort(key=lambda event: math.inf if event[3] is None else event[3])
    replied: dict[str, list[int]] = {}
    replied_total = [0, 0, 0, 0]
    counted: dict[str, list[int]] = {}
    position = 0
    for _, session, day, moment, models in events:
      until = math.inf if moment is None else moment
      while position < len(lineage_replies) and lineage_replies[position][0] <= until:
        _, model, counts = lineage_replies[position]
        held = replied.setdefault(model, [0, 0, 0, 0])
        for kind in range(4):
          held[kind] += counts[kind]
          replied_total[kind] += counts[kind]
        position += 1
      beyond = {model: [max(0, totals[kind] - replied.get(model, (0, 0, 0, 0))[kind]) for kind in range(4)] for model, totals in models.items()}
      for kind in range(4):
        room = max(0, sum(totals[kind] for totals in models.values()) - replied_total[kind])
        claimed = sum(extra[kind] for extra in beyond.values())
        if claimed > room:
          for extra in beyond.values():
            extra[kind] = extra[kind] * room // claimed
      for model, extra in beyond.items():
        done = counted.setdefault(model, [0, 0, 0, 0])
        new = [max(0, extra[kind] - done[kind]) for kind in range(4)]
        if any(new):
          counted[model] = [max(done[kind], extra[kind]) for kind in range(4)]
          held = unrecorded.setdefault((day, session, model), [0, 0, 0, 0])
          for kind in range(4):
            held[kind] += new[kind]
  return [(day, session, model, counts) for (day, session, model), counts in unrecorded.items()]


def claude_code_scan_match(claude_dir: Path | None = None) -> dict[str, str]:
  """What a scan of Claude Code's transcripts was made under, for a
  collector's cached_scan(match=...): where Claude Code is sent decides
  whose its replies are, so a scan only answers for the endpoint it saw."""
  return {"claudeCodeEndpoint": claude_code_endpoint(claude_code_base_url(claude_dir))}


# ------------------------------------------------------- Codex rollouts
#
# Codex writes one JSONL rollout per session under $CODEX_HOME/sessions (and
# archived_sessions), naming the model provider it ran on. Every rollout is
# read here, once for every collector that bills one: the Codex collector its
# own `openai` rollouts, and the rest (`--oss` on a local daemon, a custom
# model_providers entry) the local collector for a self-hosted provider,
# Ollama Cloud for a cloud-tagged model the local daemon forwarded, and a
# provider's collector for a model_providers entry whose base_url is that
# provider's host (codex_route_owner). While openai_base_url sends the
# built-in provider elsewhere, its models are split the same way.

# The Codex collector counts rollouts on the built-in provider, and ones too
# old to name a provider at all.
CODEX_NATIVE_PROVIDER = "openai"

# Codex rollouts are read back this far, matching the Codex collector.
CODEX_WINDOW_DAYS = 30

# Per-file totals of Codex rollouts survive between runs, so a rescan only
# reads the files that changed. Bumping it retires every older record; version
# 2 drops totals cached while an untrusted time still counted on the file's day,
# version 3 those that counted every request as a prompt, version 4 those
# that missed the responses only Codex 0.163's token_usage_record lines name,
# version 5 those with no session, version 6 those that left a built-in
# rollout unread without saying so, version 7 those that booked a
# switched-to model's first requests to the model before it, and version 8
# those that read no turns from a rollout naming no session_meta.
CODEX_ROLLOUT_SCHEMA = 8

_CODEX_MARKERS = (
  '"token_count"', '"token_usage_record"', '"turn_context"', '"thread_settings_applied"', '"session_meta"', '"user_message"', '"UserMessage"',
)

# What a token_usage_record's running total is compared by.
_CODEX_USAGE_FIELDS = ("input_tokens", "cached_input_tokens", "cache_write_input_tokens", "output_tokens", "reasoning_output_tokens", "total_tokens")


def codex_home() -> Path:
  return Path(os.environ.get("CODEX_HOME") or (Path.home() / ".codex"))


# Records hold local days, so they are only true in the timezone that wrote
# them.
def _codex_cache_zone() -> list[Any]:
  return [os.environ.get("TZ"), list(time.tzname), time.timezone, time.altzone]


def _codex_record_valid(value: Any) -> bool:
  try:
    counts = [totals for models in value["days"].values() for totals in models.values()]
    return (
      type(value["mtime"]) in (int, float) and type(value["size"]) is int and isinstance(value["provider"], str)
      and (value["session"] is None or type(value["session"]) is str)
      and all(len(totals) == 5 and all(type(n) is int for n in totals) for totals in counts)
    )
  except Exception:
    return False


def _codex_typed_prompt(entry: dict[str, Any]) -> bool:
  """Whether a rollout line is a prompt the user typed, as the Codex collector
  reads it: an item_completed UserMessage in paginated rollouts, a plain
  user_message event in legacy ones."""
  if entry.get("type") != "event_msg":
    return False
  payload = obj(entry.get("payload"))
  if payload.get("type") == "user_message":
    return payload.get("kind") in (None, "plain")
  return payload.get("type") == "item_completed" and obj(payload.get("item")).get("type") == "UserMessage"


def _codex_settings_model(entry: dict[str, Any]) -> str:
  """The model a thread_settings_applied event switches the thread to, or "".
  Codex 0.163 writes one when `-m` on a resume or /model picks another model,
  ahead of any request on it: a compaction the switch sends goes out on the
  new model before that turn's turn_context names it."""
  payload = obj(entry.get("payload"))
  if entry.get("type") != "event_msg" or payload.get("type") != "thread_settings_applied":
    return ""
  settings = obj(payload.get("thread_settings"))
  return str(settings.get("model") or obj(obj(settings.get("collaboration_mode")).get("settings")).get("model") or "")


def _codex_typed_session(meta: dict[str, Any]) -> bool:
  # A subagent's thread, or one of Codex's own (a guardian review, memory
  # consolidation), is prompted by Codex, not by anyone typing: its requests
  # still spend tokens, but its messages are no prompts.
  source = meta.get("source")
  return not (isinstance(source, dict) and ("subagent" in source or "internal" in source))


def codex_rollout_session(meta: dict[str, Any], typed: bool, path: Any) -> str | None:
  """The session a rollout's tokens count under. A thread someone started is
  its own, by its thread id. Codex's own threads (a review, a guardian check,
  a spawned agent) name the root thread that started them in session_id, or
  their parent in parent_thread_id, and count under it, as a Claude Code
  sidechain counts under its parent's sessionId: they spend tokens but start
  no session. One that names no thread but its own, such as a memory
  consolidation, counts under none."""
  thread = meta.get("id")
  if typed:
    return str(thread or path)
  for starter in (meta.get("session_id"), meta.get("parent_thread_id")):
    if starter and starter != thread:
      return str(starter)
  return None


# A rollout that only grew is read on from where the last read stopped,
# with the reader's state as it was there, when the first and last few
# kilobytes of what was read are still in place.
CODEX_ROLLOUT_HEAD_BYTES = 4096

_CODEX_MARKER_BYTES = tuple(marker.encode() for marker in _CODEX_MARKERS)

# The line ends a text-mode read splits a rollout on.
_CODEX_LINE_ENDS = re.compile(r"\r\n|\r|\n")


def _codex_digest(handle: Any, length: int) -> str:
  digest = hashlib.sha1()
  handle.seek(0)
  digest.update(handle.read(min(length, CODEX_ROLLOUT_HEAD_BYTES)))
  handle.seek(max(0, length - CODEX_ROLLOUT_HEAD_BYTES))
  digest.update(handle.read(min(length, CODEX_ROLLOUT_HEAD_BYTES)))
  return digest.hexdigest()


def _codex_response_key(response: tuple[Any, ...]) -> str:
  return hashlib.blake2b(json.dumps(response).encode(), digest_size=8).hexdigest()


def _codex_resume(handle: Any, previous: dict[str, Any]) -> dict[str, Any] | None:
  """The reader state a cached record stopped in, when the open rollout is
  that same file, grown past it with what was read still in place, else
  None. The record's days have the prompts no request had answered yet
  taken back out, since the read goes on to find who answers them."""
  try:
    state = dict(previous["resume"])
    info = os.fstat(handle.fileno())
    offset = state["offset"]
    if not (
      type(offset) is int and info.st_size > previous["size"] and info.st_size >= offset
      and state["file"] == [info.st_dev, info.st_ino]
      and isinstance(state["model"], str) and all(type(state[flag]) is bool for flag in ("meta", "typed", "records", "done"))
      and all(isinstance(day, str) for day in state["pending"]) and all(isinstance(key, str) for key in state["responses"])
      and state["head"] == _codex_digest(handle, offset)
    ):
      return None
    days = {day: {model: list(totals) for model, totals in models.items()} for day, models in previous["days"].items()}
    for day in state["pending"]:
      totals = days[day][state["model"]]
      totals[4] -= 1
      if totals[4] < 0:
        return None
      # A prompt's bucket holds nothing else until a request lands in it.
      if not any(totals):
        del days[day][state["model"]]
        if not days[day]:
          del days[day]
    state["days"] = days
    return state
  except Exception:
    return None


def read_codex_rollout(path: Path, stat_result: os.stat_result, previous: dict[str, Any] | None = None, native: bool = False) -> dict[str, Any]:
  """One rollout's provider, session (codex_rollout_session) and day ->
  model -> [input, output, cacheRead, cacheWrite, prompts]. A rollout on the
  built-in provider, or naming none, is left unread and marked `skipped`,
  unless `native` asks for it, as the Codex collector does and
  openai_base_url can.

  A prompt counts on its own day, under the model that answered it: the one
  in effect at the next request, since a legacy rollout can write the prompt
  before the turn_context naming its model. A partial read has an mtime of
  None, so it is never cached as the file's whole story.

  `previous`, the file's last record, is read on from where it stopped when
  the file only grew; the record's `resume` holds what that takes. A
  rollout dated by its mtime, or ending in a line still being written, is
  read whole next time.
  """
  record: dict[str, Any] = {"mtime": stat_result.st_mtime, "size": stat_result.st_size, "provider": "", "session": str(path), "days": {}}
  current_model = "local"
  seen_meta = False
  typed = True
  pending_prompts: list[str] = []
  previous_total_usage = None
  # Codex 0.163 writes a token_usage_record for every response it is billed
  # for, a compaction's included, where token_count only follows a sampling
  # request. Once one appears, the records are the usage and the token_count
  # lines after it repeat them; those before it still count.
  seen_records = False
  seen_responses: set[str] = set()
  offset = 0
  done = False
  resumable = True
  resume: dict[str, Any] = {}

  def bucket(day: str, model: str) -> list[int]:
    return record["days"].setdefault(day, {}).setdefault(model, [0, 0, 0, 0, 0])

  try:
    with path.open("rb") as handle:
      state = _codex_resume(handle, previous) if previous else None
      if previous and state is not None:
        record["provider"] = previous["provider"]
        record["session"] = previous["session"]
        record["days"] = state["days"]
        current_model = state["model"]
        seen_meta = state["meta"]
        typed = state["typed"]
        pending_prompts = list(state["pending"])
        previous_total_usage = state["total"]
        seen_records = state["records"]
        seen_responses = set(state["responses"])
        offset = state["offset"]
        done = state["done"]
      handle.seek(offset)
      for raw in [] if done else handle:
        # A line still being written is read again once it is whole.
        whole = raw.endswith(b"\n")
        if whole:
          offset += len(raw)
        if not any(marker in raw for marker in _CODEX_MARKER_BYTES):
          continue
        text = raw.decode("utf-8", errors="replace")
        for line in _CODEX_LINE_ENDS.split(text) if "\r" in text else (text,):
          if not any(marker in line for marker in _CODEX_MARKERS):
            continue
          try:
            entry = json.loads(line)
          except Exception:
            # A line nested too deep to parse is a RecursionError, not a
            # ValueError; either way only that line is lost.
            continue
          if not isinstance(entry, dict):
            continue
          if not whole:
            resumable = False
          if entry.get("type") == "session_meta":
            # A forked rollout copies its parent's session_meta after its own,
            # so only the first one, as Codex reads it, says who served this.
            if seen_meta:
              continue
            seen_meta = True
            meta = obj(entry.get("payload"))
            record["provider"] = str(meta.get("model_provider") or "").strip().lower()
            # The built-in provider, or none recorded, is the Codex
            # collector's unless openai_base_url sends it elsewhere.
            if record["provider"] in ("", CODEX_NATIVE_PROVIDER):
              if not native:
                record["skipped"] = True
                done = True
                break
              # A turn naming no model is Codex's own, as the Codex
              # collector reads it.
              current_model = "codex"
            typed = _codex_typed_session(meta)
            record["session"] = codex_rollout_session(meta, typed, path)
            continue
          if not seen_meta:
            # A rollout from before Codex wrote session_meta names no
            # provider, so its turns are the built-in provider's.
            if not native:
              record["skipped"] = True
              done = True
              break
            seen_meta = True
            current_model = "codex"
          if _codex_typed_prompt(entry):
            # A prompt with no time is the file's; one whose time can't be
            # trusted counts nowhere.
            timestamp = entry.get("timestamp")
            if timestamp is None:
              resumable = False
            day = local_day(stat_result.st_mtime if timestamp is None else timestamp)
            if typed and day is not None:
              pending_prompts.append(day)
            continue
          if entry.get("type") == "turn_context":
            payload = obj(entry.get("payload"))
            current_model = str(payload.get("model") or payload.get("model_slug") or current_model)
            continue
          switched = _codex_settings_model(entry)
          if switched:
            current_model = switched
            continue
          if entry.get("type") == "token_usage_record":
            seen_records = True
            payload = obj(entry.get("payload"))
            # One response, with the thread's running total after it. Only the
            # same response id under an unchanged total is a repeat: a backend
            # may reuse an id from turn to turn.
            thread_usage = obj(payload.get("thread_token_usage"))
            response = _codex_response_key((str(payload.get("response_id") or ""), *(token_count(thread_usage.get(field)) for field in _CODEX_USAGE_FIELDS)))
            if response in seen_responses:
              continue
            seen_responses.add(response)
            usage = obj(payload.get("usage"))
            total_usage = None
          else:
            payload = entry.get("payload") or entry
            if entry.get("type") == "response_item" and isinstance(payload, dict):
              payload = payload.get("payload") or payload
            if not isinstance(payload, dict) or payload.get("type") != "token_count" or seen_records:
              continue
            info = obj(payload.get("info"))
            # total_token_usage is cumulative for the session; the last turn is
            # what this one spent.
            usage = obj(info.get("last_token_usage"))
            total_usage = info.get("total_token_usage")
          cache_read = token_count(usage.get("cached_input_tokens"))
          cache_write = token_count(usage.get("cache_write_input_tokens"))
          # Cached tokens are inside input_tokens, and reasoning inside
          # output_tokens.
          input_tokens = max(0, token_count(usage.get("input_tokens")) - cache_read - cache_write)
          output_tokens = token_count(usage.get("output_tokens"))
          if not (input_tokens or output_tokens or cache_read or cache_write):
            continue
          # Quota updates can repeat the previous request's last_token_usage.
          # Only an unchanged cumulative snapshot proves this is a repeat:
          # separate requests may spend identical counts.
          if isinstance(total_usage, dict) and total_usage:
            if total_usage == previous_total_usage:
              continue
            previous_total_usage = total_usage
          # A turn with no time is dated by the file; one whose time can't be
          # trusted counts nowhere, as in the Codex collector.
          timestamp = entry.get("timestamp")
          if timestamp is None:
            resumable = False
          day = local_day(stat_result.st_mtime if timestamp is None else timestamp)
          if day is None:
            continue
          totals = bucket(day, current_model)
          totals[0] += input_tokens
          totals[1] += output_tokens
          totals[2] += cache_read
          totals[3] += cache_write
          # One prompt can take many requests, one per tool call it makes; the
          # requests count no prompts of their own.
          for prompt_day in pending_prompts:
            bucket(prompt_day, current_model)[4] += 1
          pending_prompts = []
        if done:
          break
      if resumable:
        opened = os.fstat(handle.fileno())
        resume = {
          "file": [opened.st_dev, opened.st_ino], "offset": offset, "head": _codex_digest(handle, offset),
          "model": current_model, "meta": seen_meta, "typed": typed, "pending": list(pending_prompts),
          "total": previous_total_usage, "records": seen_records, "responses": sorted(seen_responses), "done": done,
        }
  except OSError:
    record["mtime"] = None
    resumable = False
  # A prompt no request answered yet, or ever, was put to the last model.
  for prompt_day in pending_prompts:
    bucket(prompt_day, current_model)[4] += 1
  if resumable:
    record["resume"] = resume
  return record


# How long a refresh's start, as omarchy-agent-usage-update hands it to the
# collectors it runs, speaks for a forced read: longer than any refresh takes,
# so a stamp inherited from elsewhere soon stops standing in for --force.
CODEX_REFRESH_SECONDS = 300


def _codex_refresh_started(now: float) -> float:
  """When the refresh this collector runs in began, or `now` outside one."""
  try:
    started = float(os.environ.get("OMARCHY_AGENT_USAGE_REFRESH_AT", ""))
  except ValueError:
    return now
  return started if now - CODEX_REFRESH_SECONDS <= started <= now else now


def codex_rollout_cache(agent_id: str | None = None) -> Path | None:
  """Where the Codex rollout records of this Codex home are kept, or None
  when the cache root is unusable: that costs the reuse, never the scan.
  A record keeps every turn whatever its provider, so every collector shares
  the one file; `agent_id` names nothing, for callers from before that."""
  digest = hashlib.sha1(str(codex_home()).encode("utf-8", "surrogatepass")).hexdigest()[:16]
  try:
    return cache_root() / f"codex-rollouts-{digest}.json"
  except OSError:
    return None


def codex_rollouts(cache_file: Path | None, reuse: bool = True, native: bool = False) -> tuple[dict[str, dict[str, Any]], bool]:
  """Every Codex rollout of the last CODEX_WINDOW_DAYS, as
  read_codex_rollout() reads it, keyed by path, and whether every one was
  read in full. Those on the built-in provider are read only with `native`,
  while openai_base_url sends it elsewhere (codex_native_endpoint), and a
  record that skipped one is read again once they are.

  Rollouts are append-only, so a file whose mtime and size both match its
  cached record cannot have grown a turn since, and one that grew is read on
  from where its record stopped; `reuse=False` reads them all again, but
  takes what another forced read wrote since this one or its refresh
  (OMARCHY_AGENT_USAGE_REFRESH_AT) began, so the collectors one refresh
  forces read every rollout once between them, whenever each starts. A
  record keeps every turn whatever its provider, so the caller decides which
  providers and models are its own, and every caller shares the cache
  codex_rollout_cache() names: any `cache_file` stands for it, and None
  reads with no cache at all. Every collector reading Codex runs at once,
  so one of them brings the cache up to date under its `.lock` while the
  others wait and then find nothing left to read; a cache that already
  answers for every rollout is read without waiting. Only the files a scan
  saw are written back, so deleted rollouts and ones past the window leave
  the cache.
  """
  shared = None if cache_file is None else codex_rollout_cache()

  def rollouts() -> list[tuple[str, Path, os.stat_result]]:
    found = []
    cutoff = time.time() - CODEX_WINDOW_DAYS * 24 * 60 * 60
    for root in (codex_home() / "sessions", codex_home() / "archived_sessions"):
      if not root.is_dir():
        continue
      for path in root.rglob("*.jsonl"):
        try:
          stat_result = path.stat()
        except OSError:
          continue
        if stat_result.st_mtime >= cutoff:
          found.append((str(path), path, stat_result))
    return found

  started = _codex_refresh_started(time.time())
  # When a forced read last wrote the cache: every record in it was read
  # afresh since, replayed from that read or read since.
  forced_at: list[float | None] = [None]

  def load() -> dict[str, Any]:
    forced_at[0] = None
    if shared is None:
      return {}
    try:
      payload = read_json(shared)
    except OSError:
      payload = {}
    if payload.get("schemaVersion") != CODEX_ROLLOUT_SCHEMA or payload.get("zone") != _codex_cache_zone():
      return {}
    stamp = payload.get("forcedAt")
    stamp = stamp if type(stamp) in (int, float) else None
    # A forced read reuses only what another forced read of the same refresh
    # wrote, so a refresh rereads every rollout once, whichever collector gets
    # to the lock first, and never replays an older cache.
    if not reuse and (stamp is None or stamp < started):
      return {}
    forced_at[0] = stamp
    return {path: record for path, record in obj(payload.get("files")).items() if _codex_record_valid(record)}

  def current(record: dict[str, Any] | None, stat_result: os.stat_result) -> bool:
    return (
      record is not None and record["mtime"] == stat_result.st_mtime and record["size"] == stat_result.st_size
      and not (native and record.get("skipped"))
    )

  def scan(files: list[tuple[str, Path, os.stat_result]], cached: dict[str, Any]) -> tuple[dict[str, dict[str, Any]], bool]:
    records: dict[str, dict[str, Any]] = {}
    kept: dict[str, dict[str, Any]] = {}
    complete = True
    for key, path, stat_result in files:
      record = cached.get(key)
      if not current(record, stat_result):
        # A built-in rollout once skipped is read from the start.
        record = read_codex_rollout(path, stat_result, None if record and record.get("skipped") else record, native)
      if record["mtime"] is None:
        complete = False
      else:
        kept[key] = record
      records[key] = record
    if shared is not None and kept != cached:
      try:
        stamp = forced_at[0] if reuse else time.time()
        write_json(shared, {"schemaVersion": CODEX_ROLLOUT_SCHEMA, "zone": _codex_cache_zone(), "forcedAt": stamp, "files": kept})
      except OSError as exc:
        warn(f"could not write file cache ({exc})")
    return records, complete

  if shared is None:
    return scan(rollouts(), {})
  files = rollouts()
  cached = load()
  if reuse and len(cached) == len(files) and all(current(cached.get(key), stat_result) for key, _, stat_result in files):
    return {key: cached[key] for key, _, _ in files}, True
  with exclusive_lock(shared.with_name(shared.name + ".lock")):
    # Whoever held the lock meanwhile most likely read what this scan is after.
    return scan(rollouts(), load())


def _codex_config(path: Path) -> dict[str, Any]:
  try:
    with path.open("rb") as handle:
      return tomllib.load(handle)
  except (OSError, UnicodeError, tomllib.TOMLDecodeError):
    return {}


def codex_native_key(pid: Any) -> bool:
  """Whether a codex_config_urls() key is the built-in provider's
  openai_base_url, plain or a profile's (`openai@<model>`)."""
  return pid == CODEX_NATIVE_PROVIDER or str(pid).startswith(CODEX_NATIVE_PROVIDER + "@")


def codex_config_urls() -> dict[str, str]:
  """provider id -> base_url, from the Codex CLI's own config: the system
  layer, the user's config.toml over it, and the profiles
  (<name>.config.toml) Codex layers over that when one is selected. The
  built-in `openai` provider's is its openai_base_url.

  Codex 0.163 applies a profile only to a run given --profile, and its
  rollouts still name only `openai`, so only the system layer and
  config.toml say where the built-in provider goes. A profile's
  openai_base_url is kept as `openai@<model>` for the model it sets, the one
  thing its rollouts can be told apart by: never an OpenAI model, which
  plain `codex` runs too, nor the one the plain config sets, and none when
  two profiles send that model to different places."""
  home = codex_home()
  urls: dict[str, str] = {}
  profiles: dict[str, str | None] = {}
  plain_model = ""
  for path in (Path("/etc/codex/config.toml"), home / "config.toml", *sorted(home.glob("*.config.toml"))):
    config = _codex_config(path)
    providers = config.get("model_providers")
    if isinstance(providers, dict):
      urls.update((str(name).lower(), str(entry.get("base_url") or "")) for name, entry in providers.items() if isinstance(entry, dict))
    model = config.get("model").strip().lower() if isinstance(config.get("model"), str) else ""
    base = config.get("openai_base_url")
    if path.name != "config.toml":
      if model and isinstance(base, str) and not codex_openai_model(model):
        profiles[model] = base if profiles.get(model, base) == base else None
      continue
    # Where the built-in provider goes in place of OpenAI's API. Codex 0.163
    # reads it from the config only, never from OPENAI_BASE_URL.
    if isinstance(base, str):
      urls[CODEX_NATIVE_PROVIDER] = base
    plain_model = model or plain_model
  for model, base in profiles.items():
    if base is not None and model != plain_model:
      urls[f"{CODEX_NATIVE_PROVIDER}@{model}"] = base
  return urls


def codex_providers_path() -> Path:
  return Path(os.environ.get("XDG_STATE_HOME") or (Path.home() / ".local" / "state")) / "omarchy" / "agents" / "local-codex-providers.json"


def codex_provider_urls() -> dict[str, str]:
  """provider id -> base_url, for every Codex provider config.toml has named.

  A rollout records only its provider's id, never the URL it reached, so a
  custom provider that leaves config.toml would take its history with it.
  Each run remembers the endpoints the config names, per Codex home, and a
  provider the config no longer has keeps the last one it had. The current
  config always wins. A provider only ever given on the command line (`-c
  model_providers...`) or in a project's .codex/config.toml is never seen
  here: local.json names those for the local collector. The built-in
  provider's openai_base_url is never remembered: once the config drops it,
  Codex is back on OpenAI's API, as Claude Code is once ANTHROPIC_BASE_URL
  goes.
  """
  path = codex_providers_path()
  homes = read_json(path).get("homes")
  homes = homes if isinstance(homes, dict) else {}
  key = str(codex_home())
  known = homes.get(key)
  known = {str(pid): url for pid, url in known.items() if isinstance(url, str) and url and not codex_native_key(pid)} if isinstance(known, dict) else {}
  urls = {**known, **codex_config_urls()}
  remembered = {pid: url for pid, url in urls.items() if url and not codex_native_key(pid)}
  if remembered != known:
    try:
      path.parent.mkdir(parents=True, exist_ok=True)
      write_json(path, {"homes": {**homes, key: remembered}}, sort_keys=True)
    except OSError as exc:
      # Remembering costs nothing when it fails: the current config still
      # classifies.
      warn(f"could not remember Codex providers ({exc})")
  return urls


def codex_openai_model(model: Any) -> bool:
  """Whether a model is one OpenAI serves Codex (gpt-5.1-codex,
  codex-auto-review, o3), or none is named; gpt-oss is open weights anyone
  runs."""
  name = str(model or "").strip().lower().rpartition("/")[2]
  if name.startswith("gpt-oss"):
    return False
  return not name or name.startswith(("gpt-", "chatgpt-")) or "codex" in name or re.fullmatch(r"o[1-9](-.*)?", name) is not None


def codex_native_class(base: Any) -> str:
  """Where an openai_base_url sends the built-in provider: "" for OpenAI's
  own API (no override), a provider collector's id, `local`, or `other` for
  a host nothing here can place."""
  host = url_host(base)
  if not host or host in ("openai.com", "chatgpt.com") or host.endswith((".openai.com", ".chatgpt.com")):
    return ""
  return endpoint_owner(base) or "other"


def codex_native_endpoint(urls: dict[str, str], model: Any = None) -> str:
  """codex_native_class() of the openai_base_url a built-in turn on `model`
  went to: the profile's that sets that model, else the plain config's."""
  profile = f"{CODEX_NATIVE_PROVIDER}@{str(model or '').strip().lower()}"
  return codex_native_class(urls[profile] if profile in urls else urls.get(CODEX_NATIVE_PROVIDER, ""))


def codex_native_routed(urls: dict[str, str]) -> bool:
  """Whether any built-in rollout may be another collector's, so
  codex_rollouts() has to read them (its `native`)."""
  return any(codex_native_class(url) for pid, url in urls.items() if codex_native_key(pid))


def codex_route_owner(provider: Any, model: Any, urls: dict[str, str]) -> str | None:
  """The collector that bills a Codex rollout on `provider`, with the model
  that answered, or None for one no provider's collector counts (the local
  collector decides which of those `--oss` and local.json ran itself).

  The built-in provider is `codex`'s until openai_base_url (the profile's
  for the model a profile sets, else the plain config's) sends it
  elsewhere. A provider's host there bills all of it. Otherwise an Ollama
  cloud tag is Ollama's, and OpenAI's own models stay `codex`'s through a
  proxy that may forward to it; a self-hosted URL makes any other model
  `local`'s, and a host nothing here can place counts it nowhere, as
  claude_code_owner() reads ANTHROPIC_BASE_URL.

  A model_providers entry whose base_url is a provider's host is that
  provider's, whatever its id; one at a host nothing here can place is no
  provider's. Past that, `ollama-cloud`, and a cloud-tagged model through
  the local daemon's `ollama`, are Ollama Cloud's, and any other model on
  the user's own hardware is `local`'s, whatever the entry's id: the base
  URL decides, not an id another collector claims elsewhere."""
  name = str(provider or "").strip().lower()
  if name in ("", CODEX_NATIVE_PROVIDER):
    endpoint = codex_native_endpoint(urls, model)
    if endpoint not in ("", "local", "other"):
      return endpoint
    if endpoint and cloud_model(model):
      return "ollama"
    if not endpoint or codex_openai_model(model):
      return "codex"
    return "local" if endpoint == "local" else None
  owner = endpoint_owner(urls.get(name))
  if owner and owner != "local":
    return owner
  if name == "ollama-cloud" or (name == "ollama" and cloud_model(model)):
    return "ollama"
  return "local" if owner == "local" and not cloud_model(model) else None


def codex_scan_match() -> dict[str, Any]:
  """For a collector's cached_scan(match=...): which collector each Codex
  provider's base_url bills, which the config can change without a rollout
  changing. The built-in provider's is read as codex_route_owner() reads
  it, which tells OpenAI's own API from a host nothing can place."""
  return {"codexRoutes": [
    [pid, codex_native_class(url) if codex_native_key(pid) else endpoint_owner(url)] for pid, url in sorted(codex_provider_urls().items())
  ]}


def scan_codex_routed(owner: str, reuse: bool = True) -> tuple[list[UsageRow], bool]:
  """The Codex rollout totals codex_route_owner() says `owner` bills, as rows
  (one per rollout, day and model, prompts counted), and whether every
  rollout was read. Only Ollama Cloud bills a provider no base_url names, so
  a collector no configured provider points at reads nothing."""
  urls = codex_provider_urls()
  if owner != "ollama" and not any(endpoint_owner(url) == owner for url in urls.values()):
    return [], True
  records, complete = codex_rollouts(codex_rollout_cache(), reuse=reuse, native=codex_native_routed(urls))
  rows = [
    UsageRow(day, record["session"], owner, model, *totals[:4], prompts=totals[4])
    for record in records.values()
    for day, models in record["days"].items()
    for model, totals in models.items()
    if codex_route_owner(record["provider"], model, urls) == owner
  ]
  return rows, complete


# ------------------------------------------------------------ Kimchi


def kimchi_sessions_root() -> Path:
  """Where Kimchi's harness keeps its pi-format sessions: under
  KIMCHI_CODING_AGENT_DIR when set, as the CLI itself reads it, else
  ~/.config/kimchi/harness. Kimchi has no profiles that move it. Its own
  gateway routes (kimchi, kimchi-dev, kimchi-dev/<upstream>,
  kimchi-experimental) are the kimchi collector's here and in pi's and omp's
  trees alike; a session `--provider` sent elsewhere (OpenRouter) is that
  provider's."""
  return Path(os.environ.get("KIMCHI_CODING_AGENT_DIR") or (Path.home() / ".config" / "kimchi" / "harness")) / "sessions"


# ---------------------------------------------------- DeepSeek Harness
#
# dsh keeps one append-only event log per session under
# $DSH_HOME/sessions/<project>/<session>/, Zstandard-compressed by default.
# Each billed model attempt settles as an assistant/message (or a log-only
# assistant/attempt) carrying the provider's usage; the request/header before
# it names the provider route and model. Its DeepSeek routes are the deepseek
# collector's, and a pi-ai route on another provider (OpenRouter, say) that
# provider's, so the reader hands each collector the routes it takes.

# One canonical session log generation: session.jsonl, session.v4.jsonl, and
# their Zstandard twins.
DSH_LOG_NAME = re.compile(r"session(?:\.v([1-9][0-9]*))?\.jsonl(\.zstd)?")

# The most one compressed session log may inflate to. A real log, even a
# long-running agent session's, is a few MiB of JSON lines, so 64 MiB is far
# past any of them; a log that inflates further is a corrupt or hostile
# frame, and the scan stops there rather than filling memory.
DSH_MAX_LOG_BYTES = 64 * 1024 * 1024


def dsh_home() -> Path:
  # An empty or blank DSH_HOME reads as unset, as dsh itself treats it.
  configured = os.environ.get("DSH_HOME", "").strip()
  return Path(configured).expanduser() if configured else Path.home() / ".dsh"


def dsh_session_logs(root: Path) -> tuple[list[Path], bool]:
  """The current log of each session, and whether every directory could be
  listed: a walk that couldn't read one has missed its logs."""
  # The newest generation in each session directory is the current log;
  # older ones are kept only as migration history.
  newest: dict[Path, tuple[int, Path]] = {}
  unlisted: list[OSError] = []
  for directory, _, names in root.walk(on_error=unlisted.append):
    for name in names:
      match = DSH_LOG_NAME.fullmatch(name)
      path = directory / name
      if not match or not path.is_file():
        continue
      version = int(match.group(1) or 0)
      current = newest.get(directory)
      if current is None or version > current[0]:
        newest[directory] = (version, path)
  return [path for _, path in sorted(newest.values(), key=lambda item: str(item[1]))], not unlisted


def dsh_decompress(data: bytes) -> bytes | None:
  """Every complete Zstandard frame of a log, or None past DSH_MAX_LOG_BYTES.

  Decompressed a bounded piece at a time, so a corrupt or hostile frame that
  inflates without end stops at the cap instead of filling memory.
  """
  chunks: list[bytes] = []
  total = 0
  while data:
    decompressor = zstd.ZstdDecompressor()
    pending = data
    try:
      while True:
        chunk = decompressor.decompress(pending, max_length=DSH_MAX_LOG_BYTES - total + 1)
        pending = b""
        total += len(chunk)
        if total > DSH_MAX_LOG_BYTES:
          return None
        chunks.append(chunk)
        if decompressor.eof or decompressor.needs_input:
          break
    except zstd.ZstdError:
      break
    if not decompressor.eof:
      break
    data = decompressor.unused_data
  return b"".join(chunks)


def dsh_log_lines(path: Path) -> tuple[list[bytes], bool]:
  """The complete records of one log, and whether all of it could be read.

  A torn final line or frame from a crash mid-write is dropped, as dsh's own
  reader does, without making the scan incomplete.
  """
  data = path.read_bytes()
  if path.name.endswith(".zstd"):
    if zstd is None:
      warn("this Python has no Zstandard support; DeepSeek Harness sessions were not scanned")
      return [], False
    data = dsh_decompress(data)
    if data is None:
      warn(f"a DeepSeek Harness session log inflates past {DSH_MAX_LOG_BYTES >> 20} MiB and was not scanned")
      return [], False
  lines = data.split(b"\n")
  # Whatever follows the last newline is an unfinished record.
  return lines[:-1], True


def dsh_usage_sample(event: dict[str, Any]) -> dict[str, Any] | None:
  data = obj(event.get("data"))
  if event.get("type") == "assistant/message" and isinstance(data.get("usage"), dict):
    return data["usage"]
  stream = data.get("stream")
  if not isinstance(stream, list):
    return None
  for record in reversed(stream):
    chunk = obj(obj(record).get("chunk"))
    if obj(record).get("type") == "chunk" and chunk.get("type") == "usage":
      return obj(chunk.get("usage"))
  return None


def _dsh_rows(path: Path, accept: Accept) -> tuple[list[UsageRow], bool]:
  lines, complete = dsh_log_lines(path)
  if not lines:
    return [], complete
  try:
    header = obj(json.loads(lines[0]))
  except Exception:
    # A line nested too deep to parse is a RecursionError, not a
    # ValueError; either way only that line (here, its log) is lost.
    return [], complete
  if header.get("type") != "session":
    return [], complete
  events = []
  for line in lines[1:]:
    try:
      event = json.loads(line)
    except Exception:
      continue
    if isinstance(event, dict):
      events.append(event)

  # A fork's log opens with a copy of its parent's history; the last
  # `session/end-seed` marked inherited is where its own spending begins.
  start = 0
  if header.get("isSeeded") is True:
    for index, event in enumerate(events):
      if event.get("type") == "session/end-seed" and obj(event.get("data")).get("inherited") is True:
        start = index + 1

  session = "dsh:" + str(header.get("id") or path.parent.name)
  provider, model, request = "", "", {}
  # One slot per billed attempt. A settlement replaces the streaming sample
  # of the same turn and step, until a retry starts a new attempt, the same
  # fold dsh's own token meter runs.
  slots: list[list[Any]] = []
  last: tuple[Any, Any] | None = None
  # The messages someone typed (a user message whose source is `user`, as
  # dsh's own session title reads them) since the last attempt: the next
  # attempt answers them. A tool step, a retry, and a turn dsh starts on its
  # own (a schedule, a goal round) answer none.
  typed = 0
  for index, event in enumerate(events):
    kind = event.get("type")
    data = obj(event.get("data"))
    if kind == "user/message":
      if index >= start and obj(data.get("source")).get("kind") == "user":
        typed += 1
      continue
    if kind == "request/header":
      request = obj(obj(data.get("header")).get("config"))
      provider, model = str(request.get("provider") or ""), str(request.get("model") or "")
      continue
    if kind == "llm/retry-started":
      if last == (data.get("turn"), data.get("step")):
        last = None
      continue
    if kind not in ("assistant/message", "assistant/attempt"):
      continue
    usage = dsh_usage_sample(event)
    if usage is None:
      continue
    slot = (data.get("turn"), data.get("step"))
    sample = [
      number(usage.get("inputTokens")),
      number(usage.get("outputTokens")),
      number(usage.get("cacheReadTokens")),
      number(usage.get("cacheWriteTokens")),
    ]
    entry = [index >= start and accept(provider, model, request), local_day(event.get("time")), provider, model, sample]
    if last == slot and slots:
      slots[-1] = entry + [slots[-1][5]]
    else:
      slots.append(entry + [typed])
      typed = 0
    last = slot

  rows = []
  for counted, day, slot_provider, slot_model, (input_tokens, output_tokens, cache_read, cache_write), prompts in slots:
    if counted and day is not None and (input_tokens or output_tokens or cache_read or cache_write or prompts):
      rows.append(UsageRow(day, session, slot_provider, slot_model, input_tokens, output_tokens, cache_read, cache_write, prompts))
  return rows, complete


def scan_dsh_sessions(accept: Accept) -> tuple[list[UsageRow], bool]:
  """The billed attempts in every dsh session log on a route `accept`
  (provider, model, request config) takes, a fork's inherited history left
  out, and whether every log was read in full. Each attempt carries the
  typed messages it answered as its prompts: the first attempt of a typed
  turn answers them, its tool steps and retries none."""
  root = dsh_home() / "sessions"
  if not root.is_dir():
    return [], True
  try:
    logs, complete = dsh_session_logs(root)
  except OSError:
    return [], False
  rows: list[UsageRow] = []
  for path in logs:
    try:
      found, read = _dsh_rows(path, accept)
    except OSError:
      complete = False
      continue
    rows.extend(found)
    complete = read and complete
  return rows, complete



# ------------------------------------------------------- MiniMax Code
#
# MiniMax Code keeps one directory per session under its data dir's
# v2/sessions, with a messages.jsonl whose assistant lines name the route
# they ran on: its own (`minimax`, `minimax_api`, `minimax_oauth`) bill
# MiniMax, and `custom_provider:<name>` (a custom endpoint, or a models.dev
# preset such as Z.AI or OpenRouter) bills whoever runs that provider's
# baseURL in config.yaml.

# MiniMax Code's own routes: `minimax` is its signed-in Token Plan (or a key
# set on it), `minimax_api` the MiniMax API key it reserves, and
# `minimax_oauth` the name its provider list gives the sign-in.
MCODE_PROVIDERS = ("minimax", "minimax_api", "minimax_oauth")


def mcode_data_dir() -> Path:
  for name in ("MINIMAX_DATA_DIR", "MAVIS_DATA_DIR"):
    value = os.environ.get(name, "").strip()
    if value:
      return Path(os.path.abspath(os.path.expanduser(value)))
  return Path.home() / ".minimax"


def _yaml_blocks(text: str) -> dict[str, Any]:
  """The block mappings of a YAML file, scalars as plain strings: enough to
  read MiniMax Code's config.yaml without a YAML dependency. Lists, flow
  values, anchors and multi-line scalars aren't read."""
  root: dict[str, Any] = {}
  stack: list[tuple[int, dict[str, Any]]] = [(-1, root)]
  for raw in text.splitlines():
    body = raw.rstrip()
    stripped = body.lstrip(" ")
    if not stripped or stripped.startswith(("#", "-")):
      continue
    indent = len(body) - len(stripped)
    key, colon, value = stripped.partition(":")
    if not colon or (value and not value.startswith(" ")):
      continue
    while stack[-1][0] >= indent:
      stack.pop()
    key = key.strip().strip("'\"")
    value = value.split(" #", 1)[0].strip()
    if value:
      stack[-1][1][key] = value.strip("'\"")
    else:
      child: dict[str, Any] = {}
      stack[-1][1][key] = child
      stack.append((indent, child))
  return root


def mcode_routes(data_dir: Path | None = None) -> dict[str, str]:
  """custom_provider name -> the collector that bills its baseURL ("" for
  one nothing here can place), from MiniMax Code's config.yaml."""
  try:
    text = ((data_dir or mcode_data_dir()) / "config.yaml").read_text(encoding="utf-8", errors="replace")
  except OSError:
    return {}
  providers = _yaml_blocks(text).get("custom_provider")
  if not isinstance(providers, dict):
    return {}
  routes = {}
  for name, entry in providers.items():
    options = entry.get("options") if isinstance(entry, dict) else None
    routes[str(name)] = endpoint_owner(options.get("baseURL")) if isinstance(options, dict) else ""
  return routes


def mcode_route_owner(provider: Any, routes: dict[str, str], model: Any = None) -> str | None:
  """The collector that bills a MiniMax Code reply by `model` on route
  `provider`. A reply naming none predates third-party routes and ran on
  MiniMax. A custom provider is its baseURL's (a provider's host, or the
  user's own hardware, where a cloud-tagged model only passed through a
  local Ollama daemon to Ollama's servers); one gone from the config, or
  behind a gateway nothing here can place, is nobody's here."""
  if provider in (None, "", *MCODE_PROVIDERS):
    return "minimax"
  name = str(provider)
  if name.startswith("custom_provider:"):
    owner = routes.get(name.partition(":")[2]) or None
    return "ollama" if owner == "local" and cloud_model(model) else owner
  return None


def mcode_scan_match() -> dict[str, Any]:
  """For a collector's cached_scan(match=...): which collector each custom
  provider bills, which the config can change without a session changing."""
  return {"mcodeRoutes": [list(item) for item in sorted(mcode_routes().items())]}


def _mcode_tokens(usage: dict[str, Any]) -> tuple[int, int, int, int]:
  input_tokens = token_count(usage.get("input"))
  output_tokens = token_count(usage.get("output"))
  cache_read = token_count(usage.get("cacheRead"))
  cache_write = token_count(usage.get("cacheWrite"))
  if not (input_tokens or output_tokens):
    # Only a total: MiniMax's input excludes the cache tokens, which keep
    # their own buckets.
    input_tokens = max(0, token_count(usage.get("totalTokens")) - cache_read - cache_write)
  return input_tokens, output_tokens, cache_read, cache_write


def _mcode_day(message: dict[str, Any], entry: dict[str, Any]) -> str | None:
  """The day of a MiniMax Code line: the message's time, else the line's.
  A line with neither, or with neither trusted, is skipped."""
  for value in (message.get("timestamp"), entry.get("timestamp")):
    if value is not None and (day := local_day(value)):
      return day
  return None


def scan_mcode(owner: str) -> tuple[list[UsageRow], bool]:
  """MiniMax Code's replies and typed prompts that `owner` bills, as rows
  (replies with no prompts of their own, prompts with no tokens), and
  whether every session was read. A prompt goes with the route and model of
  the reply that answers it, so a collector keeping some models alone keeps
  their prompts too; one left unanswered with the session's last route and
  no model."""
  root = mcode_data_dir() / "v2" / "sessions"
  if not root.is_dir():
    return [], True
  routes = mcode_routes()
  # A directory the walk can't list has sessions the scan missed.
  unlisted: list[OSError] = []
  found = [directory / "messages.jsonl" for directory, _, names in root.walk(on_error=unlisted.append) if "messages.jsonl" in names]
  complete = not unlisted
  rows: list[UsageRow] = []
  for path in sorted(found):
    # One directory per session; its messages carry no session id of their own.
    session = "mcode:" + str(path.parent)
    pending: list[str] = []
    route = "minimax"
    try:
      with path.open("r", encoding="utf-8", errors="replace") as handle:
        for raw in handle:
          try:
            entry = json.loads(raw)
          except Exception:
            # A line nested too deep to parse is a RecursionError, not a
            # ValueError; either way only that line is lost.
            continue
          message = entry.get("message") if isinstance(entry, dict) else None
          if not isinstance(message, dict):
            continue
          day = _mcode_day(message, entry)
          if day is None:
            continue
          # MiniMax Code books a typed prompt and the assistant's usage on
          # lines of their own.
          if message.get("role") == "user":
            pending.append(day)
            continue
          if message.get("role") != "assistant":
            continue
          model = str(message.get("model") or entry.get("model") or "minimax").strip() or "minimax"
          route = mcode_route_owner(message.get("provider"), routes, model)
          if route == owner:
            rows.extend(UsageRow(prompt_day, session, owner, model, 0, 0, 0, 0) for prompt_day in pending)
          pending = []
          usage = message.get("usage")
          if route != owner or not isinstance(usage, dict):
            continue
          input_tokens, output_tokens, cache_read, cache_write = _mcode_tokens(usage)
          if not (input_tokens or output_tokens or cache_read or cache_write):
            continue
          rows.append(UsageRow(day, session, owner, model, input_tokens, output_tokens, cache_read, cache_write, prompts=0))
      if route == owner:
        rows.extend(UsageRow(prompt_day, session, owner, "", 0, 0, 0, 0) for prompt_day in pending)
    except OSError:
      complete = False
  return rows, complete


# -------------------------------------------- harnesses routed by base URL
#
# Claude Code, MiniMax Code and Codex send to whatever endpoint they are
# given, and record only a model or a route's name, so the collector of every
# provider they can be pointed at (and `local`, for the user's own hardware)
# reads them, each keeping what claude_code_owner(), mcode_route_owner() and
# codex_route_owner() say it bills. The local collector reads Codex with a
# rule of its own, since it also counts provider ids no base_url names.


def routed_sources() -> list[Path]:
  """The stores scan_routed() reads, for a collector's scan sources."""
  return [claude_code_dir() / "projects", mcode_data_dir(), codex_home()]


def routed_match() -> dict[str, Any]:
  """What scan_routed() decided owners under, for cached_scan(match=...)."""
  return {**claude_code_scan_match(), **mcode_scan_match(), **codex_scan_match()}


def scan_routed(owner: str, reuse: bool = True) -> tuple[list[UsageRow], bool]:
  """Claude Code's, MiniMax Code's and Codex's usage that `owner` bills, and
  whether every session was read. `reuse=False` reads every Codex rollout
  again rather than from its per-file cache."""
  claude_rows, claude_complete = claude_code_usage(owner)
  mcode_rows, mcode_complete = scan_mcode(owner)
  codex_rows, codex_complete = ([], True) if owner == "local" else scan_codex_routed(owner, reuse)
  return claude_rows + mcode_rows + codex_rows, claude_complete and mcode_complete and codex_complete


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
    roll a newer answer back. This run still uses its own answer. Only a
    stamp up to five minutes ahead counts as newer: one further ahead was
    written before the clock went back and would otherwise never be
    replaced.
    """
    fetched_at = now_ms()
    payload = {"fetchedAtMs": fetched_at, "limits": limits, **extra}
    try:
      kept = stamp(read_json(self.path).get("fetchedAtMs")) if only_if_newer else 0
      if not fetched_at < kept <= fetched_at + 300_000:
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


class _TooSlow(Exception):
  """A reply still arriving at the deadline."""


def _read_by(response: Any, size: int, deadline: float) -> bytes:
  """Up to `size` bytes of a reply, by `deadline`. The socket timeout only
  bounds each wait, so a server dripping a byte at a time would otherwise
  hold a collector forever."""
  if not isinstance(response, http.client.HTTPResponse):
    return response.read(size)
  chunks, got = [], 0
  while got < size:
    if time.monotonic() > deadline:
      raise _TooSlow()
    chunk = response.read1(min(65536, size - got))
    if not chunk:
      break
    chunks.append(chunk)
    got += len(chunk)
  return b"".join(chunks)


def open_json(request: urllib.request.Request, timeout: float = 10, limit: int = HTTP_BODY_LIMIT) -> Any:
  """The JSON a request answers with, or HttpError saying why there's none."""
  deadline = time.monotonic() + 3 * timeout
  try:
    with urllib.request.urlopen(request, timeout=timeout) as response:
      body = _read_by(response, limit + 1, deadline)
      # A sized read hands back what arrived when the server stops short of
      # its Content-Length, with the rest still owed.
      owed = getattr(response, "length", None)
  except urllib.error.HTTPError as error:
    # An error's body drips like any other; past the deadline it is left out.
    try:
      body = _read_by(error.fp, limit, deadline) if error.fp else b""
    except Exception:
      body = b""
    raise HttpError(status=error.code, body=body, headers=error.headers) from error
  except _TooSlow as error:
    # The server answered, just never finished: a reply cut short, so no
    # reason to ask again sooner.
    raise HttpError(cut_short=True) from error
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
  except ValueError:
    # A header http.client won't send: a key with a line break or a
    # character outside Latin-1. Not chained, as the error quotes the key.
    raise HttpError() from None
  if len(body) > limit:
    raise HttpError()
  if isinstance(owed, int) and owed > 0:
    raise HttpError(cut_short=True)
  try:
    return json.loads(body.decode("utf-8", errors="replace"))
  except (ValueError, RecursionError) as error:
    # RecursionError: a body nested deeper than the parser will go.
    raise HttpError() from error


def trusted_endpoint(url: str) -> bool:
  """Whether a credential may go to `url`, an endpoint the environment can
  move: HTTPS, or plain HTTP to loopback alone, and no credentials of its
  own in the URL."""
  try:
    parts = urllib.parse.urlsplit(url)
  except ValueError:
    return False
  if parts.username is not None or parts.password is not None:
    return False
  loopback = (parts.hostname or "").lower() in ("localhost", "127.0.0.1", "::1")
  return parts.scheme == "https" or (parts.scheme == "http" and loopback)


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
  """The token the user exported, the credential the Cursor CLI stores, or
  the editor's sign-in, in that order.

  CURSOR_AUTH_TOKEN is a bearer as it stands. CURSOR_API_KEY is not: the CLI
  trades it for an access token and keeps that beside the key in its auth
  file, so the stored token stands for the key only while it was traded for
  this one. The key itself never goes out as a bearer.

  A sign-in that has lapsed gives way to the next one that hasn't: someone
  who ran the CLI once and now lives in the editor would otherwise wait on a
  token nothing renews. With all of them lapsed, the first one decides.
  """
  bearer = str(os.environ.get("CURSOR_AUTH_TOKEN") or "").strip()
  if bearer:
    return bearer
  auth = read_json(auth_path or cursor_auth_path())
  key = str(os.environ.get("CURSOR_API_KEY") or "").strip()
  traded = str(auth.get("accessToken") or "").strip()
  if key:
    # With no token traded for this key, any other sign-in is someone else's
    # account than the one the CLI runs as.
    return traded if str(auth.get("apiKey") or "").strip() == key else ""
  cli = traded
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
  # The threshold reads as `omarchy agent account` reads it: a percentage
  # held to 50-100, 95 when it isn't one.
  try:
    threshold = max(50, min(100, int(registry.get("threshold"))))
  except Exception:
    threshold = 95
  for account in accounts:
    account["active"] = account["id"] == active_id
    account["switch"] = {
      "mode": "auto" if registry.get("switch") == "auto" else "manual",
      "threshold": threshold,
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
    "stale": not limits["live"] and bool(limits["limits"]),
    "fetchedAt": limits["fetchedAtMs"],
    "usageStatusText": limits["usageStatusText"],
    "authHelpText": limits["authHelpText"],
    "retryAdvised": bool(limits.get("retryAdvised")),
    **extra,
  }
