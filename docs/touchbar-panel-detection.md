# Touch Bar and laptop panel detection

A Touch Bar can appear in Hyprland as a `DSI-*` monitor before the laptop's `eDP-*` panel. Choosing the first internal-looking connector then disables the Touch Bar instead of the laptop screen during a docked lid close.

`omarchy-hyprland-monitor-laptop` retains the existing eDP/LVDS/DSI candidate order but excludes connectors whose matching DRM cards all report the Touch Bar driver `adp` or `appletbdrm` in `device/uevent`. Genuine DSI panels remain eligible. Missing/unknown driver evidence and ambiguous connector names shared with another driver retain the original fallback rather than risking exclusion of a real panel. Disabled laptop outputs remain discoverable for lid-open recovery. Card numbers, laptop model names and connector numbers are not hard-coded.

This changes panel selection only. Existing physical/active external-monitor predicates continue to exclude DSI connectors from the external-display count. USB-connected monitors remain eligible external displays. Undocked lid close still takes the existing lock path; logind retains responsibility for suspend. The fix adds no polling process, service, package dependency, compiler or user-configuration override.

Validation uses isolated DRM, lid and compositor fixtures in `test/shell.d/hw-display-test.sh`: Touch Bar first with an enabled/disabled eDP panel, both Touch Bar drivers, genuine/unknown DSI, missing sysfs, ambiguous connector names, real docked lid-close disable, lid-open restoration and undocked close without falsely treating the Touch Bar as an external screen. The existing monitor/clamshell and lid suites cover the surrounding paths. Fixture results do not constitute a physical sleep or lid-cycle test; live hardware validation is reported separately.
