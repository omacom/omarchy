---
name: omarchy-contribute
description: >
  Report an Omarchy bug, suggest a feature, or submit a fix upstream to omacom/omarchy: deciding whether it is Omarchy's bug at all, where it belongs (issue, Discussions, Discord), gathering diagnostics and a capture, searching for duplicates, getting the user's go-ahead, filing or commenting with gh, and opening a pull request from a fork. Triggers: report a bug, file an issue, is this an Omarchy bug, feature request, suggestion, contribute, submit a fix, open a PR to Omarchy.
---

# Contributing to Omarchy

Omarchy lives at https://github.com/omacom/omarchy. Route each request to the right place:

- **Verified bugs** -> GitHub issues. Issues are for validated bugs only, not support requests.
- **Feature ideas and suggestions** -> https://github.com/omacom/omarchy/discussions/categories/suggestions
- **Support and "is this a bug?" questions** -> the Discord community at https://omarchy.org/discord. Start here when the problem isn't clearly a bug in Omarchy itself.

## Is It Even Omarchy's Bug?

Be strict here. Omarchy is a configuration layer over Arch Linux, so a bug inside a third-party application — a file manager, a browser, a GNOME or Qt library — is almost always an upstream bug in **that** project, not in Omarchy.

Omarchy's sphere of control is roughly:

- the `omarchy-*` commands
- the Quickshell shell and its plugins
- the Hyprland and terminal configuration it ships
- its themes
- its install and migration scripts
- how it packages and configures what it installs

A bug in a program Omarchy merely installs is **not** an Omarchy bug unless Omarchy's own packaging or configuration is implicated. If it is not Omarchy's, say so and stop. Suggesting the right upstream project is useful; filing there yourself is not part of this.

## Three Conditions, All Required

1. **It is a verified bug in Omarchy's sphere**, established on evidence.
2. **The user has explicitly agreed.** Show them the exact title and body you propose, and wait for a yes. Never file unprompted.
3. **The machine can file it** — `gh auth status` must succeed. If `gh` is missing or unauthenticated, do not install or authenticate it. Say so, and hand the user the finished text to submit themselves.

## Gather the Details

The bug template asks for system details (CPU, GPU, Omarchy version), a description with steps to reproduce, and diagnostics:

```bash
omarchy version

# Generate the diagnostic log (also written to /tmp/omarchy-debug.log)
omarchy-debug --no-sudo --print

# Interactive variant: `omarchy-debug` offers to upload the log to
# logs.omarchy.org (expires after 24h) and prints a shareable URL to
# include in the issue.
```

**Capture the problem on screen.** A screenshot or short recording of the bug is often worth more than the description: `omarchy capture screenshot region`, or `omarchy screenrecord --fullscreen` and `omarchy screenrecord --stop-recording`. Keep recordings short and focused on the misbehavior. When the bug or feature is visual, attach the capture with `gh --attach` wherever you file, comment, or open a PR (below).

For screen-recording failures specifically, rerun with `OMARCHY_SCREENRECORD_DEBUG=true` and paste the contents of `$XDG_RUNTIME_DIR/omarchy-screenrecord.log` (or `${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/omarchy-screenrecord.log` without a session runtime directory).

## Search Before Filing

A duplicate issue costs a maintainer more time than no report at all.

```bash
gh search issues --repo omacom/omarchy "<program> <symptom>"
gh issue list --repo omacom/omarchy --state all --search "<distinctive words>"
```

Search on the program, the symptom, and distinctive details (an error message, a symbol from a backtrace) — not on the wording of the title you were about to write.

`gh search issues` accepts only `open` or `closed` for `--state`, and errors on anything else. Leaving it off searches both, which is what you want here.

Include **closed** issues. A matching issue closed as fixed, when the bug still reproduces on a current system, is a regression — and reporting that is worth far more than another duplicate.

## Adding to an Existing Report

If a plausible match comes back, read it properly first:

```bash
gh issue view <number> --repo omacom/omarchy --comments
```

Confirm it is genuinely the same failure. The same program misbehaving is not the same bug if the trigger or the cause differs.

If it is the same, add to that issue rather than opening a new one — but only when you have something the thread does not already contain: a different reproduction, a symbolized stack where it has none, a narrower trigger, a version where it regressed. A comment that only says the bug happens to you too is noise. If that is all you have, tell the user so and file nothing.

```bash
gh issue comment <number> --repo omacom/omarchy --body "..." [--attach './bug.png#What the bug looks like']
```

## Filing a New Issue

Only when the search turns up nothing that matches:

```bash
gh issue create --repo omacom/omarchy --title "..." --body "..." [--attach './bug.png#What the bug looks like']
```

Include what happened, what was expected, steps to reproduce, system details, and the debug log URL (or the log itself). For a visual problem, attach the screenshot or recording with `--attach` (repeat it for several files; alt text for an image goes after `#`, and a video has none).

## Signing

End the issue or comment with a line naming the model and agent harness that produced it, so a human reader knows it was machine-authored:

> Filed by \<model name\> via \<agent harness\>.

Use your actual model and harness names. If you are not certain of them, say so plainly rather than inventing a version string.

## Submitting a PR

Never develop against `/usr/share/omarchy`. Clone a working copy instead:

```bash
gh repo fork omacom/omarchy --clone
cd omarchy
```

Follow the repository's own `AGENTS.md` for style, testing, and commit conventions — it is the authority on contributions. Keep commits atomic, run `./test/all` before pushing, and open the PR with `gh pr create`. A PR that fixes a visual problem or adds a visual feature includes screenshots or a screencast of it, before and after when something changed, attached with `gh pr create --attach './before.png#Before' --attach './after.png#After'`.
