# Validation — v1.0.0

Checked on 21 September 2026. Installed baseline: Omarchy 4.0.4-1, Hyprland 0.56.2. Upstream comparison: `omacom/omarchy`, branch `quattro`, commit `8f324c90b82790d31ab33565441e07cbdb8d2308`.

## Passed

- TOML parsing, required palette values and distributable asset checks.
- Foreground, accent, muted and six signal colours each have at least 4.5:1 contrast against the palette background. Foreground: 14.35:1; accent: 11.30:1; muted: 5.68:1. This is a palette check, not a claim that every application surface is accessibility-audited.
- All three wallpapers are 3840 × 2400; both previews are 1920 × 1080. The wallpapers are upscaled AI-assisted artwork, as documented in ARTWORK.md.
- Both the installed and upstream Omarchy template engines generated 20 application configuration files without unresolved colour placeholders, in isolated output directories.
- Upstream `./test/cli` after aligning the palette with the built-in theme convention (no cursor token).
- Upstream theme staging, user-theme setup and theme-install guard tests.
- Packaging config, package ownership and snapshot tests after providing the official `omarchy-pkgs` and `omarchy-iso` companion checkouts.
- Theme activation and visual inspection on the running desktop. The preview is an actual capture with public demo content. Hyprland reports no configuration errors.
- The separate desktop installer passed all 11 local tests, including installation, repeat installation, rollback, conflict handling, preservation of idle settings and isolated login-appearance operations.

## Full-suite limitation

`./test/all` was run. Its initial failures included the cursor-token convention (fixed), unavailable companion checkouts (provided and affected tests rerun successfully), and `factory-reset-accounts-test.sh` reporting `not ok - normal reset stages successfully`.

That last failure also occurs on a separate, untouched worktree at the exact upstream commit above. It remains unresolved and is not reported as passing. The full run also reported skipped checks in 18 of 248 shell test files because their runtime prerequisites were unavailable. No claim is made that the entire upstream suite is green.

## Not exercised

A fresh-machine installation, the disposable-VM graphical acceptance suite, a real password submission, and boot decryption with the new artwork were not exercised. The unlock preview is a rendering, not a boot-session screenshot. Authentication services, password configuration, autologin configuration and idle durations were not changed for this theme.
