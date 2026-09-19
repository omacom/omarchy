---
name: diagnose-omarchy
description: >
  Diagnose an Omarchy or Hyprland desktop problem that does not necessarily crash.
  Use when a window, workspace, monitor, window group, menu, shell, keybinding,
  theme, or configuration behaves unexpectedly, or when asked to establish
  whether a symptom belongs to Omarchy, Hyprland, an application, or local
  configuration. Triggers: investigate problem, bug, issue, invisible window,
  missing window, workspace, monitor, window group, Hyprland, Omarchy diagnosis.
---

# Diagnosing an Omarchy Problem

Work from evidence. The goal is to identify the failing layer and produce a
useful next step, not to guess from a familiar symptom.

This is the general entry point. When a coredump exists, hand the crash-specific work to the `diagnose-crash` skill; otherwise continue here.

## Start with the symptom

Ask the user for:

- what they expected and what actually happened;
- the exact reproduction steps, including the focused window, workspace, and monitor;
- whether the behavior is repeatable and whether it affects one application or several;
- when it started and whether an update, configuration change, or restart preceded it.

Do not assume that every desktop problem is an Omarchy problem. Keep application,
Hyprland, Omarchy shell/menu, local configuration, and hardware causes separate
until evidence connects them.

## Gather low-risk evidence

Prefer read-only, non-sensitive diagnostics. Start with the smallest useful set:

- `omarchy version` and `hyprctl version`;
- `hyprctl monitors -j`, `hyprctl workspaces -j`, and `hyprctl clients -j`;
- `hyprctl activewindow -j` when the symptom involves focus or visibility;
- relevant `journalctl --user -b --no-pager` output and Omarchy logs;
- `omarchy-debug --no-sudo --print` when that command is available.

For an invisible or misplaced window, compare the client's `mapped`, `hidden`,
`workspace`, `monitor`, `at`, `size`, `grouped`, `fullscreen`, and `pinned`
fields with the visible layout. Check whether Hyprland still owns the client
even when the compositor is not drawing it.

Inspect only the relevant configuration and redact usernames, home paths, window
titles, tokens, and other personal data before displaying or sharing diagnostics.
Do not upload diagnostics automatically.

## Follow crash evidence when it exists

If the symptom produced a coredump, use the `diagnose-crash` skill and preserve
the crash timeline. A missing window or frozen shell without a coredump remains a
non-crash investigation; do not manufacture a crash just to use that workflow.

## Classify and report

Conclude which layer is most likely responsible and say what evidence supports
that conclusion. If the issue is reproducible, prepare an issue containing the
version, hardware or monitor context, exact steps, expected result, actual result,
and minimal relevant diagnostics. Identify the likely upstream project before
drafting the report.

Ask before editing configuration, killing or restarting processes, changing
system state, uploading logs, posting an issue, or opening a pull request.
When a fix is appropriate, propose the smallest reversible change and explain how
to verify it.
