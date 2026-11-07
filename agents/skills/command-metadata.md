# Command Metadata

Read this before adding or changing commands in `bin/`.

Commands in `bin/` can declare CLI metadata in comments near the top of the
file. `bin/omarchy` scans the first 80 lines, and tests expect command metadata
to remain valid.

Supported metadata keys:

- `# omarchy:group=...` - override the command group inferred from the filename
- `# omarchy:name=...` - override the command name inferred from the filename
- `# omarchy:summary=...` - short help text
- `# omarchy:args=...` - usage arguments
- `# omarchy:examples=...` - examples separated with ` | `
- `# omarchy:alias=...` / `# omarchy:aliases=...` - alternate routes
- `# omarchy:hidden=true` - hide from default command listings
- `# omarchy:requires-sudo=true` - mark commands that require sudo

Only use `omarchy:examples` where there are args that need explaining.

`omarchy:args` also decides how the dispatcher reads a word after the command. A
group parent (a command with `omarchy-<name>-*` children) that documents only
flags, or no arguments at all, refuses a bare word as a mistyped subcommand:
`omarchy update firmwre` reports the unknown command instead of starting a full
update with the typo ignored. A parent that legitimately takes an operand
documents it (`# omarchy:args=<name>`), and its leftovers are passed through.

Prefer explicit metadata for user-facing commands. Keep routes consistent with
the filename unless there is a deliberate alias or compatibility route.

Example:

```bash
# omarchy:summary=Take a screenshot
# omarchy:args=[smart|region|windows|fullscreen] [slurp|copy]
# omarchy:examples=omarchy screenshot | omarchy capture screenshot region
```
