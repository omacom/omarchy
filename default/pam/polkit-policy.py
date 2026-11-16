"""Publish the Polkit PAM stack in one replacement, after runtime validation."""

import os
from pathlib import Path
import re
import tempfile


def auth_entry(line):
  return re.match(r'^\s*-?auth\s+(\[[^\]]+\]|\S+)\s+(\S+)(?:\s|$)', line, re.IGNORECASE)


def validate_syntax(body):
  if "\\\n" in body:
    raise ValueError("Continued PAM entries require manual lock-guard integration")
  for line in body.splitlines():
    if not line.strip() or line.lstrip().startswith("#"):
      continue
    # PAM accepts additional token quoting forms. Refuse those explicitly;
    # silently ignoring an unparsed auth entry could leave a factor unguarded.
    if not re.match(r'^\s*-?(auth|account|password|session)\s+(\[[^\]]+\]|required|requisite|sufficient|optional|include|substack)\s+([A-Za-z0-9_./+-]+)(?:\s|$)', line, re.IGNORECASE):
      raise ValueError("Unsupported PAM entry requires manual lock-guard integration")


def render(body, method=None):
  validate_syntax(body)
  auth = re.compile(r'^\s*-?auth\s+(\[[^\]]+\]|\S+)\s+(\S+)(?:\s|$)', re.IGNORECASE)
  presence = {"pam_fprintd.so", "pam_u2f.so"}

  def module(line):
    match = auth.match(line)
    return Path(match[2]).name if match else None

  def clamshell(line):
    match = auth.match(line)
    return (match is not None and module(line) == "pam_exec.so"
            and set(re.sub(r'\s*=\s*', '=', match[1].lower().strip("[]")).split()) == {"success=1", "default=ignore"}
            and line[match.end():].split() == ["quiet", "/usr/bin/omarchy-hw-laptop-closed"])

  lines = []
  for line in body.splitlines(keepends=True):
    entry = re.match(r'^\s*-?(auth|account)\s+(\[[^\]]+\]|\S+)\s+(\S+)(?:\s|$)', line, re.IGNORECASE)
    if entry is None or Path(entry[3]).name != "pam_omarchy_lock.so":
      lines.append(line)
  if method == "fingerprint":
    if not any(module(line) == "pam_fprintd.so" for line in lines):
      lines.insert(0, "auth sufficient pam_fprintd.so\n")
    if not any(clamshell(line) for line in lines):
      index = next(i for i, line in enumerate(lines) if module(line) == "pam_fprintd.so")
      lines.insert(index, "auth [success=1 default=ignore] pam_exec.so quiet /usr/bin/omarchy-hw-laptop-closed\n")
  elif method == "fido2":
    if not any(module(line) == "pam_u2f.so" for line in lines):
      lines.insert(0, "auth sufficient pam_u2f.so cue authfile=/etc/fido2/fido2\n")
  elif method == "remove-fingerprint":
    lines = [line for line in lines if module(line) != "pam_fprintd.so" and not clamshell(line)]
  elif method == "remove-fido2":
    lines = [line for line in lines if module(line) != "pam_u2f.so"]
  elif method is not None:
    raise ValueError("unknown authentication method")

  # Count PAM entries, not physical lines: comments, blanks and other phases
  # do not consume an auth jump. Preserve them inside the guarded gate block.
  entries = [i for i, line in enumerate(lines) if auth.match(line)]
  paired = {}
  for position, index in enumerate(entries):
    line = lines[index]
    match = auth.match(line)
    if module(line) in presence and match[1].lower() != "sufficient":
      raise ValueError("Polkit presence factors must use sufficient control")
    if clamshell(line):
      if position + 1 == len(entries) or module(lines[entries[position + 1]]) != "pam_fprintd.so":
        raise ValueError("Clamshell gate must precede the fingerprint factor")
      paired[index] = entries[position + 1]
    elif match[1].startswith("["):
      raise ValueError("Custom Polkit PAM controls require manual lock-guard integration")

  guarded = []
  active = False
  index = 0
  while index < len(lines):
    line = lines[index]
    if index in paired:
      guarded.append("auth [success=ignore default=2] pam_omarchy_lock.so\n")
      end = paired[index] + 1
      guarded.extend(lines[index:end])
      active = True
      index = end
      continue
    if auth.match(line):
      if module(line) in presence:
        guarded.append("auth [success=ignore default=1] pam_omarchy_lock.so\n")
        active = True
      elif active:
        guarded.append("auth optional pam_omarchy_lock.so password\n")
        active = False
    guarded.append(line)
    index += 1
  return "account requisite pam_omarchy_lock.so\n" + ''.join(guarded)


def validate_password_includes(body, roots, visiting=()):
  validate_syntax(body)
  for line in body.splitlines():
    if line.lstrip().startswith("@include"):
      raise ValueError("Global PAM includes require manual lock-guard integration")
    match = auth_entry(line)
    if not match:
      continue
    if Path(match[2]).name in {"pam_fprintd.so", "pam_u2f.so"} and visiting:
      raise ValueError("Presence factors in included PAM stacks require manual lock-guard integration")
    if match[1].lower() not in {"include", "substack"}:
      continue
    service = match[2]
    if not re.fullmatch(r'[A-Za-z0-9_.-]+', service) or service in {".", ".."} or service in visiting or len(visiting) >= 16:
      raise ValueError("Invalid or recursive PAM include")
    source = next((root / service for root in roots if (root / service).is_file()), None)
    if source is None:
      raise ValueError("Missing included PAM stack: " + service)
    included = source.read_text()
    if "\\\n" in included:
      raise ValueError("Continued included PAM entries require manual lock-guard integration")
    validate_password_includes(included, roots, (*visiting, service))


def publish(target, vendor, method=None):
  target = Path(target)
  if target.is_symlink() or (target.exists() and not target.is_file()):
    raise ValueError("polkit-1 is not a regular PAM configuration file")
  source = target if target.exists() else Path(vendor)
  body = render(source.read_text(), method)
  validate_password_includes(body, (target.parent, Path(vendor).parent))
  if target.exists() and target.read_text() == body:
    return
  fd, name = tempfile.mkstemp(prefix=".polkit-1.", dir=target.parent)
  try:
    with os.fdopen(fd, "w") as output:
      output.write(body)
      output.flush()
      os.fchmod(output.fileno(), 0o644)
      os.fsync(output.fileno())
    os.replace(name, target)
    directory = os.open(target.parent, os.O_RDONLY | os.O_DIRECTORY)
    try:
      os.fsync(directory)
    finally:
      os.close(directory)
  finally:
    if os.path.exists(name):
      os.unlink(name)
