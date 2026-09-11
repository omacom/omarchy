# Simplify sandbox plugin authoring

Proposal, not implemented syntax. The [authoring reference](../docs/sandboxed-plugin-authoring.md) describes the current contract. Change parser, enforcement tests, approval UI/CLI, port manifests and documentation together if adopting this proposal; this greenfield preview should not accumulate aliases for old prototype forms.

## Make execution context visible in path names

Retain the two underlying resources: an approved read-only bundle and a private mutable home. Do not add another data directory or a manifest staging lifecycle.

- Local plugin code uses relative QML URLs or `/plugin` for assets and `$HOME` for data. The existing standard paths are sufficient.
- Rename the host-command-only tokens/variables from `OMARCHY_PLUGIN_PATH` to `OMARCHY_WARD_HOST_ASSETS` and from `OMARCHY_PLUGIN_DATA` to `OMARCHY_WARD_HOST_DATA`. The longer names make their execution context explicit; they must not look like ordinary local paths.
- Encourage literal tokens in broker argv, rather than reading the host-path environment variables. Host resolution remains an exec concern; entry-point paths stay repository-relative with no interpolation.
- Writing `$HOME/x` makes the same file available to an approved host command as `$OMARCHY_WARD_HOST_DATA/x` when storage is granted. Shipped read-only assets do not need copying into data. Plugins initialize mutable defaults on first use; no install hook or automatic data overwrite is introduced.

Do not teach `/plugin` as a usable path for a host process, or make `$HOME` mean different locations based on which manifest field contains it. Do not silently substitute paths in arbitrary arguments, regexes or QML strings.

## Replace author-written exec trees with named argv arrays

The current GitHub port has eleven independently selected command variants but approximately 680 manifest lines. Nested `next`/`arg`/`then` nodes and `{ "kind": "exact", "value": ... }` wrappers dominate the declaration. These are matcher representation details, not useful authoring concepts.

Use one named complete argv array per command variant. Plain strings mean exact arguments; retain the existing bounded nonliteral matcher objects. For example, the proposed `sandbox.requests.exec.gh` value is:

```json
{
  "executable": "/usr/bin/gh",
  "commands": {
    "check-sign-in": ["auth", "status", "-h", "github.com"],
    "mark-thread-read": [
      "api", "--method", "PATCH",
      { "kind": "pattern", "value": "/notifications/threads/[0-9]{1,32}", "max": 64 }
    ]
  }
}
```

Each command key replaces a tree leaf name, so existing explicit selections such as `--exec gh:mark-thread-read` retain their meaning. Required command names remain an explicit list. No prefixes, trailing flags, exclusions, precedence or implicit group approval are introduced. Shared prefixes can be compiled internally if useful, but authors should never write recursive matcher nodes.

Convert all eleven GitHub variants mechanically, prove that each complete old branch has exactly the same new constraints and run the original-helper integration tests, including mutation denial. Keep read and write variants independently selectable. Preserve exact GraphQL documents, bounded cursor/date/repository arguments and fixed API flags. Long GraphQL strings are actual permission-bearing data; removing those restrictions to save lines would broaden authority.

Do not start with templates, macros, includes, aliases or a second policy file. The flat form removes the main source of noise without another configuration language. If exact long documents remain the next material problem after flattening, consider a separately reviewed immutable asset reference with explicit byte limits and revision binding—not wildcard GraphQL access.

The fourteen GitHub settings appear once in each independent read/write list. That repetition is smaller and meaningful. Keep it initially rather than adding a shorthand that obscures whether read implies write. A future per-key access map could remove duplication, but must preserve independent selection and requiredness.

## Keep author documentation and validation together

Maintain one discoverable authoring reference for the complete current request schema, runtime helpers, grant introspection, limits, denial behavior, paths, data initialization and review/update/revocation lifecycle. Link it from shell architecture and the agent task guide. Validate examples through the native parser; a machine-readable editor schema should complement, not replace, native semantic checks such as file existence, policy size, canonical paths, required selections and executable identity.

Documentation must label implemented behavior versus proposals and unfinished capabilities. Schema simplification is not a reason to broaden permissions or claim compatibility that has not been exercised.
