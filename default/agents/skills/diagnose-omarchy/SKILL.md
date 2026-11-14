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

Work from evidence. The goal is to identify the failing layer and produce a useful next step, not to guess from a familiar symptom.

This is the general entry point. When a coredump exists, hand the crash-specific work to the `diagnose-crash` skill; otherwise continue here.

## Start with the symptom

Ask the user for:

- what they expected and what actually happened;
- the exact reproduction steps, including the focused window, workspace, and monitor;
- whether the behavior is repeatable and whether it affects one application or several;
- when it started and whether an update, configuration change, or restart preceded it.

Do not assume that every desktop problem is an Omarchy problem. Keep application, Hyprland, Omarchy shell/menu, local configuration, and hardware causes separate until evidence connects them.

## Gather low-risk evidence

Prefer targeted, read-only diagnostics. Start with the smallest useful set:

- `omarchy version` and `hyprctl version`;
- relevant fields from `hyprctl monitors -j`, `hyprctl workspaces -j`, and `hyprctl clients -j`;
- relevant fields from `hyprctl activewindow -j` when the symptom involves focus or visibility;
- narrowly filtered, relevant user-journal entries and Omarchy logs, after explaining what is needed and asking the user before reading potentially personal content.

For an invisible or misplaced window, compare the client's `mapped`, `hidden`, `workspace`, `monitor`, `at`, `size`, `grouped`, `fullscreen`, and `pinned` fields with the visible layout. Check whether Hyprland still owns the client even when the compositor is not drawing it.

Read-only output can still contain personal information. Diagnostics returned to the agent enter the conversation with its configured model provider. Filter out window titles, usernames, home paths, tokens, and unrelated data locally before returning command output to the conversation. Inspect only the relevant configuration; ask before reading potentially sensitive contents. Do not upload diagnostics to a log host or issue tracker automatically.

## Follow crash evidence when it exists

If the symptom produced a coredump, use the `diagnose-crash` skill and preserve the crash timeline. A missing window or frozen shell without a coredump remains a non-crash investigation; do not manufacture a crash just to use that workflow.

## Classify and report

Conclude which layer is most likely responsible and say what evidence supports that conclusion. If the issue is reproducible, prepare an issue containing the version, hardware or monitor context, exact steps, expected result, actual result, and minimal relevant diagnostics. Identify the likely upstream project before drafting the report.

If a broader report is necessary, explain what `omarchy-debug --no-sudo --print` collects and ask first. It writes `/tmp/omarchy-debug.log` and prints the hostname, system information, current-boot warnings and errors, and installed packages. `--no-sudo` skips privileged kernel logs; it does not make the report non-sensitive. Run it as `omarchy-debug --no-sudo --print >/dev/null` so the full report is not returned to the conversation. Have the user review and redact the local file before returning its contents to the conversation or sharing it elsewhere.

Ask before editing configuration, killing or restarting processes, changing system state, uploading logs, posting an issue, or opening a pull request. When a fix is appropriate, propose the smallest reversible change and explain how to verify it.
