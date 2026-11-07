echo "Configure gnome-libsecret password store for VS Code"

# Configure the VS Code password store for both Microsoft VS Code and VS Code OSS.
#
# Migration flow:
#   1. Check that Python 3 is available (only Python's standard library is used).
#   2. Process ~/.vscode/argv.json and ~/.vscode-oss/argv.json independently.
#   3. Create a default argv.json when the file is missing or empty.
#   4. Otherwise, normalize and validate the existing JSONC without changing the file.
#   5. Preserve existing custom password-store values; replace only "basic" or an
#      empty string, or add the property when it is missing.
#   6. Validate the candidate and verify that all unrelated settings are unchanged.
#   7. Write the candidate through a temporary file and atomically replace the target.
#
# Package-manager compatibility:
#   This migration works whether VS Code was installed with pacman or yay/AUR.
#   Both installation methods use the same per-user argv.json locations; this script
#   does not invoke either package manager or depend on how VS Code was installed.
#
# Safety notes:
#   Existing non-empty configuration files are never replaced wholesale. JSONC comments
#   and formatting are preserved by editing only the required value or insertion point.
#   Invalid JSONC is reported and left untouched. Each configuration file is processed
#   independently, so a failure for one file stops the migration before processing the next.


if ! command -v python3 >/dev/null 2>&1; then
  echo "Error [E000]: Python 3 is required to validate VS Code JSONC configuration." >&2
  exit 1
fi

for config_dir in "$HOME/.vscode" "$HOME/.vscode-oss"; do
  if ! mkdir -p "$config_dir"; then
    echo "Error [E001]: Cannot create VS Code configuration directory $config_dir." >&2
    exit 1
  fi

  argv_file="$config_dir/argv.json"

  if ! python3 - "$argv_file" <<'PYTHON'
import json
import os
import stat
import sys
import tempfile
from typing import Any, Dict, List, NoReturn, Optional, Tuple

CONFIG_KEY = "password-store"
CONFIG_VALUE = "gnome-libsecret"
DEFAULT_CONTENT = '''// This configuration file allows you to pass permanent command line arguments to VS Code.
// Only a subset of arguments is currently supported to reduce the likelihood of breaking
// the installation.
//
// PLEASE DO NOT CHANGE WITHOUT UNDERSTANDING THE IMPACT
//
// NOTE: Changing this file requires a restart of VS Code.
{
  "password-store": "gnome-libsecret"
}
'''


def report_error(code: str, message: str) -> NoReturn:
    """Print a migration error to stderr and terminate with a failure status.

    Args:
        code: Stable migration error identifier (for example, ``E007``).
        message: Human-readable explanation including the affected path when relevant.

    Returns:
        NoReturn: This function always raises SystemExit(1); it never returns normally.
    """
    # sys.stderr ensures this prints as an error stream, bypassing standard output.
    print(f"Error [{code}]: {message}", file=sys.stderr)
    # Raising SystemExit(1) instantly kills the Python script with a failure code (1),
    # which Bash catches to stop the migration.
    raise SystemExit(1)


def reject_duplicate_keys(pairs: List[Tuple[str, Any]]) -> Dict[str, Any]:
    """Build a JSON object while rejecting duplicate property names.

    Python's JSON decoder normally accepts duplicate keys and keeps one of their values.
    For a user configuration migration, silently choosing one value is unsafe, so this
    function is supplied as ``object_pairs_hook`` to the JSON decoder. The hook is called
    for every object, including nested objects.

    Args:
        pairs: Ordered key/value pairs supplied by ``json.JSONDecoder`` for one object.

    Returns:
        Dict[str, Any]: The decoded object when every key is unique.

    Raises:
        ValueError: If the object contains a property name more than once.
    """
    result: Dict[str, Any] = {}
    # Loop over every key-value pair the JSON parser finds.
    for key, value in pairs:
        # If the key is already in our 'result' dictionary, it's a duplicate!
        if key in result:
            raise ValueError(f"duplicate object key {key!r}")
        # Otherwise, safely add it to the dictionary.
        result[key] = value
    return result


def reject_non_json_constant(value: str) -> NoReturn:
    """Reject JavaScript constants that are not part of standard JSON.

    Python's JSON decoder can accept ``NaN`` and infinity values by default. The
    ``parse_constant`` callback routes those tokens here so the migration accepts only
    standard JSON values after JSONC comments and trailing commas have been normalized.

    Args:
        value: Non-standard token encountered by the JSON decoder.

    Returns:
        NoReturn: Always raises ValueError; it never returns normally.

    Raises:
        ValueError: The supplied token is not a standard JSON constant.
    """
    # Instantly block things like NaN or Infinity that aren't valid in strict VS Code config.
    raise ValueError(f"non-JSON constant {value!r}")


def normalize_jsonc(source: str) -> str:
    """Convert JSONC text to strict-JSON-compatible text without shifting offsets.

    The scanner replaces ``//`` and ``/* ... */`` comments with spaces while retaining
    CR/LF characters. It recognizes quoted strings and escaped characters, so comment
    markers inside strings are not treated as comments. A second pass replaces trailing
    commas immediately before ``}`` or ``]`` with spaces. Replacing rather than deleting
    characters keeps source offsets aligned with the original text, which allows later
    code to use parser offsets when editing the original file.

    A leading UTF-8 BOM is replaced with a space for parsing. The original source string
    is not modified.

    Args:
        source: Original VS Code JSONC document as a Python string.

    Returns:
        str: A normalized string suitable for strict JSON parsing, with the same length
        and newline positions as the source.

    Raises:
        ValueError: If a block comment is opened but never closed.
    """
    # Convert the entire file string into an array of individual characters for fast mutation.
    chars = list(source)
    in_string = False
    escaped = False
    in_line_comment = False
    in_block_comment = False
    i = 0

    # A UTF-8 BOM is tolerated while preserving all source offsets.
    if chars and chars[0] == "\ufeff":
        chars[0] = " "

    # PASS 1: Identify and blank out comments (// and /* */) without removing newlines
    while i < len(chars):
        char = chars[i]
        next_char = chars[i + 1] if i + 1 < len(chars) else ""

        # Handle active single-line comments (//)
        if in_line_comment:
            if char in "\r\n":
                in_line_comment = False # Turn off when we hit a line break
            else:
                chars[i] = " " # Blank out the character
            i += 1
            continue

        # Handle active multi-line comments (/*)
        if in_block_comment:
            if char == "*" and next_char == "/":
                chars[i] = " "
                chars[i + 1] = " "
                in_block_comment = False # Turn off when we hit */
                i += 2
                continue
            if char not in "\r\n":
                chars[i] = " " # Blank out the character, preserve line breaks
            i += 1
            continue

        # Ignore comment syntaxes if they are typed inside a literal JSON string
        if in_string:
            if escaped:
                escaped = False # Skip the escaped character (e.g. \")
            elif char == "\\":
                escaped = True  # Next character is escaped
            elif char == '"':
                in_string = False # End of string
            i += 1
            continue

        # Detect the start of a JSON string
        if char == '"':
            in_string = True
            i += 1
            continue

        # Detect the start of a single-line comment
        if char == "/" and next_char == "/":
            chars[i] = " "
            chars[i + 1] = " "
            in_line_comment = True
            i += 2
            continue

        # Detect the start of a multi-line comment
        if char == "/" and next_char == "*":
            chars[i] = " "
            chars[i + 1] = " "
            in_block_comment = True
            i += 2
            continue

        i += 1

    if in_block_comment:
        raise ValueError("unterminated block comment")

    # PASS 2: Remove trailing commas before '}' or ']' while retaining source offsets.
    # Standard JSON crashes if an object ends with a comma (e.g., {"a": 1,} ).
    i = 0
    in_string = False
    escaped = False
    while i < len(chars):
        char = chars[i]
        
        # Safely ignore commas inside strings
        if in_string:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
            i += 1
            continue

        if char == '"':
            in_string = True
            i += 1
            continue

        # If we find a comma, look ahead to see if the next non-space character is a closing bracket
        if char == ",":
            lookahead = i + 1
            while lookahead < len(chars) and chars[lookahead].isspace():
                lookahead += 1
            if lookahead < len(chars) and chars[lookahead] in "}]":
                chars[i] = " " # It's a trailing comma, blank it out
        i += 1

    # Rejoin the character array back into a single string
    return "".join(chars)


def parse_jsonc(
    source: str,
) -> Tuple[Optional[Dict[str, Any]], str, Optional[int]]:
    """Normalize and validate a JSONC document whose root must be an object.

    The function first removes JSONC comments/trailing commas in an in-memory copy, then
    parses exactly one JSON value. Duplicate keys and non-standard constants are rejected.
    Whitespace/comment-only input is returned as an empty configuration fragment so the
    caller can preserve its comments and append a new root object.

    Args:
        source: Original JSONC document text.

    Returns:
        Tuple[Optional[Dict[str, Any]], str, Optional[int]]: The decoded root dictionary
        (or ``None`` for whitespace/comment-only input), normalized text, and character
        offset of the root opening brace in the normalized/original-aligned text.

    Raises:
        ValueError: If comments are malformed, JSON syntax is invalid, duplicate keys
        exist, trailing non-whitespace content exists, or the root is not an object.
    """
    # 1. Strip comments out using our helper function
    normalized = normalize_jsonc(source)
    
    # 2. If the file was literally just comments and whitespace, return empty state
    if not normalized.strip():
        return None, normalized, None

    # 3. Configure a strict Python JSON Decoder using our custom rules
    decoder = json.JSONDecoder(
        object_pairs_hook=reject_duplicate_keys,
        parse_constant=reject_non_json_constant,
    )

    # 4. Find the first actual character and attempt to parse the JSON object
    start = len(normalized) - len(normalized.lstrip())
    try:
        # raw_decode returns the parsed dictionary AND the character offset where it finished reading
        parsed, end = decoder.raw_decode(normalized, start)
    except (json.JSONDecodeError, ValueError) as error:
        raise ValueError(f"invalid JSONC: {error}") from error

    # 5. Post-validation checks
    if normalized[end:].strip():
        raise ValueError("unexpected content after the JSON value")
    if not isinstance(parsed, dict):
        raise ValueError("the root value must be a JSON object")

    if start >= len(normalized) or normalized[start] != "{":
        raise ValueError("the root value must be a JSON object")

    # Return the dictionary, the blanked-out string, and the index of the first '{'
    return parsed, normalized, start


def find_root_property_value(
    normalized: str, wanted_key: str
) -> Optional[Tuple[int, int, Any]]:
    """Find a direct root-object property and return its source span and value.

    The function walks only the root object's key/value pairs. Each value is decoded with
    ``raw_decode``, so nested objects and arrays are skipped as complete values rather
    than accidentally searching their contents for a matching property name.

    Args:
        normalized: Validated, comment-free JSON text returned by ``normalize_jsonc``.
        wanted_key: Root-level property name to locate, such as ``password-store``.

    Returns:
        Optional[Tuple[int, int, Any]]: ``(value_start, value_end, decoded_value)`` when
        the key exists, otherwise ``None``. The offsets refer to the normalized text and
        can also be applied to the original text because normalization preserves offsets.

    Raises:
        ValueError: If a root key/value pair cannot be read or the object structure is
        unexpectedly malformed.
    """
    decoder = json.JSONDecoder(
        object_pairs_hook=reject_duplicate_keys,
        parse_constant=reject_non_json_constant,
    )
    
    # 1. Locate the opening brace {
    i = len(normalized) - len(normalized.lstrip())
    if i >= len(normalized) or normalized[i] != "{":
        raise ValueError("the root value must be a JSON object")
    i += 1

    # 2. Walk through root-level key/value pairs
    while True:
        # Skip leading whitespace
        while i < len(normalized) and normalized[i].isspace():
            i += 1

        if i >= len(normalized):
            raise ValueError("unexpected end of root object")
        if normalized[i] == "}":
            return None # Reached the end of the JSON object, key not found

        # Parse the Key
        try:
            key, key_end = decoder.raw_decode(normalized, i)
        except (json.JSONDecodeError, ValueError) as error:
            raise ValueError(f"could not read a root object key: {error}") from error
        if not isinstance(key, str):
            raise ValueError("root object keys must be strings")

        # Jump to the colon (:)
        i = key_end
        while i < len(normalized) and normalized[i].isspace():
            i += 1
        if i >= len(normalized) or normalized[i] != ":":
            raise ValueError("missing colon after a root object key")

        i += 1
        
        # Jump to the Value
        while i < len(normalized) and normalized[i].isspace():
            i += 1
        value_start = i

        # Parse the Value. 
        # (If this value is a huge nested {object}, raw_decode parses the whole thing at once and jumps to the end of it).
        try:
            value, value_end = decoder.raw_decode(normalized, value_start)
        except (json.JSONDecodeError, ValueError) as error:
            raise ValueError(f"could not read value for root key {key!r}: {error}") from error

        # 3. Check if this is the target key
        if key == wanted_key:
            return value_start, value_end, value # Success! Return exactly where the value is located.

        # 4. If not, jump past the value and find the comma to start the loop over for the next key
        i = value_end
        while i < len(normalized) and normalized[i].isspace():
            i += 1

        if i < len(normalized) and normalized[i] == ",":
            i += 1
            continue
        if i < len(normalized) and normalized[i] == "}":
            return None
        raise ValueError("expected a comma or closing brace in the root object")


def atomic_write(path: str, content: str) -> None:
    """Write content through a same-directory temporary file and atomic replacement.

    An existing symlink is followed and its target is replaced, leaving the symlink
    itself in place. Existing file mode and (where permitted) ownership are retained.
    The temporary file is flushed and fsynced before ``os.replace`` so readers do not
    observe a partially written configuration. A failed write removes the temporary file.

    Args:
        path: User-facing argv.json path; may be a symlink.
        content: Fully validated candidate text to commit.

    Returns:
        None: The function returns after the replacement succeeds.

    Raises:
        SystemExit: Via ``report_error`` if the target cannot be inspected or safely
        replaced. The original target is not truncated by the write operation.
    """
    target_path = os.path.realpath(path)
    path_exists = os.path.exists(path)

    # 1. Security & Permission Validation
    # Before we do anything, make sure we actually have permission to modify this file.
    if path_exists:
        if not os.path.isfile(target_path):
            report_error("E002", f"Configuration path is not a regular file: {path}.")
        try:
            original_stat = os.stat(target_path)
        except OSError as error:
            report_error("E002", f"Cannot inspect {path}: {error}.")
        if not os.access(target_path, os.W_OK):
            report_error("E002", f"Configuration file is not writable: {path}.")
        # Save the original permissions (e.g., 644 or 600) so we can apply them to our new file
        mode = stat.S_IMODE(original_stat.st_mode)
    else:
        original_stat = None
        mode = 0o644 # Default read/write permissions if creating from scratch

    parent = os.path.dirname(target_path) or "."
    temp_path: Optional[str] = None
    try:
        # 2. Write to a Temporary File First
        # mkstemp creates a hidden file like `.argv.json.xYz123` right next to the real file.
        fd, temp_path = tempfile.mkstemp(prefix=".argv.json.", dir=parent)
        with os.fdopen(fd, "w", encoding="utf-8", newline="") as output:
            output.write(content)
            output.flush()            # Flush Python's memory buffer
            os.fsync(output.fileno()) # Ask the operating system to sync the file contents to stable storage.

        # 3. Apply Original Permissions & Ownership
        os.chmod(temp_path, mode)
        if original_stat is not None:
            try:
                os.chown(temp_path, original_stat.st_uid, original_stat.st_gid)
            except PermissionError:
                # A non-root migration cannot always restore a file's group. The file
                # remains owned by the invoking user and retains its original mode.
                if original_stat.st_uid != os.geteuid():
                    raise

        # 4. Atomic Swap
        # os.replace() atomically swaps the temporary file into place on the same filesystem.
        # Readers see the old file or the complete new file, not a partially written file.
        os.replace(temp_path, target_path)
        temp_path = None

        # 5. Directory Sync
        # Best-effort directory sync helps persist the rename across a crash on filesystems
        # that support directory fsync. Errors are ignored after replacement succeeds.
        try:
            directory_fd = os.open(parent, os.O_RDONLY | getattr(os, "O_DIRECTORY", 0))
            try:
                os.fsync(directory_fd)
            finally:
                os.close(directory_fd)
        except OSError:
            # The file replacement has already succeeded; directory fsync is best effort.
            pass
    except OSError as error:
        report_error("E003", f"Cannot safely write configuration file {path}: {error}.")
    finally:
        # Cleanup: If something failed and the temporary file still exists, delete it.
        if temp_path is not None:
            try:
                os.unlink(temp_path)
            except OSError:
                pass


def main(path: str) -> None:
    """Migrate one argv.json file while preserving unrelated user configuration.

    Missing/empty files receive the standard default. Existing JSONC is validated before
    inspection. The root-level ``password-store`` value is added when missing, changed
    only when it is ``basic`` or blank, and otherwise preserved (with a warning for
    non-string values). Every candidate is validated and compared with the original
    configuration before it is committed through ``atomic_write``.

    Args:
        path: Full path to one VS Code or VS Code OSS argv.json file.

    Returns:
        None: Returns normally when this file needs no change or is migrated successfully.

    Raises:
        SystemExit: Via ``report_error`` when reading, validation, or writing fails.
    """
    
    # === PART 1: Read the Source File ===
    # Open the user's config file and load it fully into memory as a string.
    exists = os.path.exists(path)
    try:
        with open(path, "r", encoding="utf-8", newline="") as source_file:
            original = source_file.read()
    except FileNotFoundError:
        original = ""
    except (OSError, UnicodeError) as error:
        report_error("E004", f"Cannot read configuration file {path}: {error}.")

    # === PART 2: Handle Missing or Empty Files ===
    # If the file is missing, empty, or contains only whitespace, use the default:
    # validate it, and write it to disk.
    if not exists or not original.strip():
        candidate = DEFAULT_CONTENT
        try:
            after, _, _ = parse_jsonc(candidate)
        except ValueError as error:
            report_error("E005", f"Internal default configuration failed validation: {error}.")
        if after is None or after.get(CONFIG_KEY) != CONFIG_VALUE:
            report_error("E006", "Default configuration did not contain the expected password-store value.")
        atomic_write(path, candidate)
        print(f"Configured {path}.")
        return

    # === PART 3: Parse Existing JSON Data ===
    # A comments-only file is accepted as an empty configuration fragment. Preserve its
    # comments and append a root object rather than replacing the user's comment text.
    try:
        before, normalized, root_open_offset = parse_jsonc(original)
    except ValueError as error:
        report_error("E007", f"Invalid JSONC in {path}; leaving it unchanged ({error}).")

    if before is None:
        # === PART 4: Handle "Comments Only" Files ===
        # The file had text, but it contained only comments and whitespace (no JSON object).
        # We take their existing comments, add a newline, and append our JSON object at the bottom.
        prefix = original
        if prefix and not prefix.endswith(("\n", "\r")):
            prefix += "\n"
        candidate = prefix + '{\n  "password-store": "gnome-libsecret"\n}\n'
    else:
        # === PART 5: Scan for Target Key in Populated JSON ===
        # Find exactly where the "password-store" value sits in the text document.
        try:
            existing_property = find_root_property_value(normalized, CONFIG_KEY)
        except ValueError as error:
            report_error("E008", f"Cannot inspect {CONFIG_KEY} in {path}; leaving it unchanged ({error}).")

        if existing_property is not None:
            # === PART 6: Update Existing Key ===
            # We found "password-store". Extract its exact start/end index and its current value.
            value_start, value_end, value = existing_property

            if isinstance(value, str) and (value == "basic" or not value.strip()):
                # It is set to "basic" or a blank/whitespace-only string. Replace only the value,
                # preserving the rest of the original text, including comments and formatting.
                replacement = json.dumps(CONFIG_VALUE)
                candidate = original[:value_start] + replacement + original[value_end:]
            elif isinstance(value, str):
                # Preserve an existing active non-basic setting (e.g. "kwallet").
                print(f"Preserving existing {CONFIG_KEY} value in {path}.")
                return
            else:
                print(
                    f"Warning [W001]: {CONFIG_KEY} has a non-string value in {path}; "
                    "leaving it unchanged.",
                    file=sys.stderr,
                )
                return
        else:
            # === PART 7: Inject Missing Key ===
            # The JSON object exists, but "password-store" isn't in it.
            # Insert immediately after the actual root opening brace { to ensure we don't accidentally
            # insert it inside a nested object. Add a trailing comma if other properties exist.
            has_properties = bool(before)
            if has_properties:
                insertion = '\n  "password-store": "gnome-libsecret",'
                candidate = (
                    original[:root_open_offset + 1]
                    + insertion
                    + original[root_open_offset + 1:]
                )
            else:
                # For an empty object, normalize whitespace-only content to a clean
                # multi-line object. This handles both {} and { \n } consistently.
                # If the empty object contains comments, keep them and add the property
                # after the comments rather than silently discarding user text.
                root_close_offset = normalized.rfind("}")
                body_start = root_open_offset + 1
                original_body = original[body_start:root_close_offset]
                normalized_body = normalized[body_start:root_close_offset]

                if original_body == normalized_body:
                    candidate = (
                        original[:body_start]
                        + '\n  "password-store": "gnome-libsecret"\n'
                        + original[root_close_offset:]
                    )
                else:
                    separator = "" if original_body.endswith(("\n", "\r")) else "\n"
                    candidate = (
                        original[:root_close_offset]
                        + separator
                        + '  "password-store": "gnome-libsecret"\n'
                        + original[root_close_offset:]
                    )

    # === PART 8: Safety Validation & Atomic Commit ===
    # Validate the complete candidate before writing anything to the destination file.
    try:
        after, _, _ = parse_jsonc(candidate)
    except ValueError as error:
        report_error(
            "E009",
            f"Modified configuration failed JSONC validation; original file was not changed ({error}).",
        )

    # Confirm the candidate contains the expected root-level password-store value.
    if after is None or after.get(CONFIG_KEY) != CONFIG_VALUE:
        report_error(
            "E010",
            f"Modified configuration does not contain the expected {CONFIG_KEY} value; "
            "original file was not changed.",
        )

    # Compare the state of the JSON dictionary 'before' and 'after' without our key.
    # If anything else changed (accidentally deleted a user's setting), abort the migration!
    before_without_key = dict(before) if before is not None else {}
    after_without_key = dict(after)
    before_without_key.pop(CONFIG_KEY, None)
    after_without_key.pop(CONFIG_KEY, None)
    if before_without_key != after_without_key:
        report_error(
            "E011",
            f"Unexpected configuration changes detected in {path}; original file was not changed.",
        )

    # All checks passed. Commit the candidate using the atomic-write helper.
    atomic_write(path, candidate)
    print(f"Configured {path}.")


if __name__ == "__main__":
    main(sys.argv[1])
PYTHON
  then
    exit 1
  fi
done