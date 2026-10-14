"""Change one theme setting while preserving unrelated TOML and dotfile links."""

import copy
import datetime
import json
import math
from pathlib import Path
import sys
import tomllib


def statements(source):
    """Yield complete statements, including multiline values and quoted keys."""
    start = index = depth = 0
    quote = None
    comment = False
    while index < len(source):
        char = source[index]
        if comment:
            if char == "\n":
                comment = False
        elif quote:
            if quote[0] == '"' and char == "\\":
                index += 2
                continue
            if source.startswith(quote, index):
                index += len(quote)
                if len(quote) == 3:
                    # TOML permits one or two literal quotes before this delimiter.
                    while index < len(source) and source[index] == quote[0]:
                        index += 1
                quote = None
                continue
        elif char == "#":
            comment = True
        elif char in "\"'":
            quote = char * 3 if source.startswith(char * 3, index) else char
            index += len(quote)
            continue
        elif char in "[{":
            depth += 1
        elif char in "]}":
            depth -= 1
        if char == "\n" and not quote and depth == 0:
            yield start, index + 1, source[start:index + 1]
            start = index + 1
        index += 1
    if start < len(source):
        yield start, len(source), source[start:]


def key_path(document):
    result = []
    while isinstance(document, dict) and len(document) == 1:
        key, document = next(iter(document.items()))
        result.append(key)
    return tuple(result)


def assignment_path(statement):
    """Read just the key, so a dotted assignment cannot look like an inline table."""
    index = 0
    quote = None
    while index < len(statement):
        char = statement[index]
        if quote:
            if quote == '"' and char == "\\":
                index += 2
                continue
            if char == quote:
                quote = None
        elif char in "\"'":
            quote = char
        elif char == "=":
            return key_path(tomllib.loads(statement[:index] + "= 0"))
        index += 1
    raise ValueError("assignment has no value")


def header_path(document):
    result = []
    while document:
        if isinstance(document, list):
            document = document[-1]
        else:
            key, document = next(iter(document.items()))
            result.append(key)
    return tuple(result)


def inline(value):
    if isinstance(value, str):
        return json.dumps(value, ensure_ascii=False)
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, dict):
        return "{ " + ", ".join(f"{inline(key)} = {inline(item)}" for key, item in value.items()) + " }"
    if isinstance(value, list):
        return "[" + ", ".join(map(inline, value)) + "]"
    if isinstance(value, (datetime.date, datetime.time)):
        return value.isoformat()
    return str(value)


def equivalent(left, right):
    if isinstance(left, dict) and isinstance(right, dict):
        return left.keys() == right.keys() and all(equivalent(left[key], right[key]) for key in left)
    if isinstance(left, list) and isinstance(right, list):
        return len(left) == len(right) and all(equivalent(a, b) for a, b in zip(left, right))
    if isinstance(left, float) and isinstance(right, float) and math.isnan(left) and math.isnan(right):
        return True
    return left == right


def activate(path, table, theme):
    source = path.read_text() if path.exists() else ""
    document = tomllib.loads(source)
    expected = copy.deepcopy(document)
    section = expected.setdefault(table, {})
    if not isinstance(section, dict):
        raise ValueError(f"{table} must be a TOML table")
    section["theme"] = theme
    if equivalent(document, expected):
        return
    context = ()
    insertion = 0
    replacement = None
    for start, end, statement in statements(source):
        stripped = statement.lstrip()
        parsed = tomllib.loads(statement)
        if stripped.startswith("["):
            context = header_path(parsed)
            if context == (table,):
                insertion = end
        elif parsed:
            keys = assignment_path(statement)
            if context + keys == (table, "theme"):
                prefix = "theme" if context else f"{table}.theme"
                replacement = (start, end, f"{prefix} = {inline(theme)}\n")
            elif not context and keys == (table,) and isinstance(parsed[table], dict):
                # An inline table cannot be extended by a dotted assignment.
                replacement = (start, end, f"{inline(table)} = {inline(section)}\n")
    if replacement:
        start, end, value = replacement
        candidate = source[:start] + value + source[end:]
    else:
        key = "theme" if insertion else f"{table}.theme"
        separator = "" if insertion == 0 or source[:insertion].endswith("\n") else "\n"
        candidate = source[:insertion] + separator + f"{key} = {inline(theme)}\n" + source[insertion:]
    if not equivalent(tomllib.loads(candidate), expected):
        raise ValueError("candidate would change unrelated TOML settings")
    if candidate != source:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(candidate)


if __name__ == "__main__":
    try:
        activate(Path(sys.argv[1]), sys.argv[2], sys.argv[3])
    except (OSError, ValueError) as error:
        sys.exit(f"Theme activation failed; original configuration preserved: {error}")
