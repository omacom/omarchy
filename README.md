# Omarchy

> **Personal fork of Omarchy for contributing fixes and improvements to the project.**

## Current Contribution

### Fix directional focus in Scrolling Layout with Full Width

This fork currently contains a fix for an issue affecting directional window navigation in Omarchy's Scrolling Layout.

When a window is placed in **Full Width** mode using `SUPER + ALT + F`, the `SUPER + LEFT` and `SUPER + RIGHT` shortcuts may stop moving focus correctly between columns.

The fix updates the directional focus bindings to handle both states:

* **Normal layout:** preserves the existing directional focus behavior.
* **Full Width:** uses the Scrolling Layout-specific focus dispatcher to correctly move between columns.

### Demonstration

A screen recording demonstrating the issue and the behavior after applying the fix is included in the Pull Request.

### Related

* **Issue:** [#13687](https://github.com/omacom/omarchy/issues/13687)
* **Pull Request:** [#13885](https://github.com/omacom/omarchy/pull/13885)

---

Omarchy is a beautiful, fun & agentic Linux distribution by DHH.

Read more at [omarchy.org](https://omarchy.org).

## The Omarchy Manual

The manual lives in [`manual/`](manual), which is its authoritative source.

* [Welcome to Omarchy!](manual/01-welcome-to-omarchy.md)

**The Basics**

* [Getting Started](manual/02-getting-started.md)
* [Coming From Mac or Windows](manual/03-coming-from-mac-or-windows.md)
* [Navigation](manual/04-navigation.md)
* [The top bar](manual/05-the-top-bar.md)
* [Themes](manual/06-themes.md)
* [Hotkeys](manual/07-hotkeys.md)
* [Unified Clipboard & History](manual/08-unified-clipboard-history.md)
* [Reminders](manual/09-reminders.md)
* [Notices](manual/10-notices.md)
* [Text Extraction & Dictation](manual/11-text-extraction-dictation.md)
* [Screenshots & Recording](manual/12-screenshots-recording.md)
* [Toggles, idle & screensaver](manual/13-toggles-idle-screensaver.md)
* [Omarchy CLI](manual/14-omarchy-cli.md)

## License

Omarchy is released under the [MIT License](https://opensource.org/licenses/MIT).
