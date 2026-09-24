# mise-managed tools

Read this before adding or changing a mise-managed tool. Default tools belong in `default/mise/config.toml`; `install/user/mise.sh` creates their native mise shims during user setup.

## Declare a default tool

Use a registry shorthand and set `lazy = true` so the first command invocation installs the tool. Follow the existing defaults' release policy: `minimum_release_age = "0s"` makes new releases eligible immediately.

```toml
[tools]
codex = { version = "latest", lazy = true, minimum_release_age = "0s" }
```

Do not add handwritten wrappers for ordinary tools. Hermes keeps its custom installer because it needs Python 3.13 and must defer to Hermes Desktop when that app owns the command.

## Choose the registry name

Before adding a GitHub- or Aqua-backed tool, run `mise registry <name>` and inspect the result. The tool name and command may differ: `hey-cli` provides `hey`, for example.

Use the registry shorthand instead of an explicit `github:` or `aqua:` backend. Shorthands let mise use <https://mise-versions.jdx.dev> for cached version and public GitHub release metadata, reducing GitHub API requests during installation and updates.

If a GitHub- or Aqua-backed tool has no registry entry, request one upstream with the repository or package URL and the required command name. Wait for that entry before adding the tool to Omarchy; do not substitute an explicit `github:` or `aqua:` declaration.

## Handle backend exceptions

Other explicit backends, such as `pipx:`, may be used when their behavior or options are required. Check that a shorthand refers to the intended tool: `cf` names Cloud Foundry in mise's registry, so Omarchy uses `npm:cf` for the Cloudflare CLI.

When an explicit backend has no registry binary metadata, declare the commands mise should create lazy shims for:

```toml
[tools]
"npm:cf" = { version = "latest", lazy = true, lazy_bins = ["cf"], minimum_release_age = "0s" }
```

After changing declarations, verify that `mise reshim --system` creates the expected commands in an isolated test environment. Test first-use installation as well as an already-installed tool; a declaration alone does not prove its shim works.
