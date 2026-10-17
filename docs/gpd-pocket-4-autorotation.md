# Optional GPD Pocket 4 autorotation

This service extends the fixed landscape display/touch support in source PR #9160. It is not required to correct boot or Hyprland orientation. The service is shipped without first-run enablement and uses the GPD detector from that compatibility change; enabling it requires that support and the service packaging from omarchy-pkgs #918 to be installed.

On a supported GPD Pocket 4 with those packages, opt in with:

```bash
omarchy pkg add iio-sensor-proxy
systemctl --user daemon-reload
systemctl --user enable --now omarchy-gpd-pocket-4-rotate.service
```

The daemon watches the system-bus accelerometer and applies matching transforms to the internal output and digitizer. It requires Python's Gio bindings, supplied by Omarchy's python-gobject dependency. The unit checks the GPD detector and Wayland environment, so it stays inert on other hardware. Sensor startup failures retry through systemd. Losing or replacing the sensor's D-Bus owner exits the daemon with failure so systemd can restart it and claim the replacement sensor. A periodic reconciliation restores the last orientation after a compositor configuration reload.

The imported HYPRLAND_INSTANCE_SIGNATURE selects the session normally. If it is absent, fallback probes instance directories newest-first by modification time and only retains an instance that responds with a nonempty monitor list. No reachable instance causes a failed startup and systemd retry rather than rotation against an unverified directory.

The mapping normal=0, left-up=1, bottom-up=2, right-up=3 was calibrated on a GPD Pocket 4 whose laptop pose reports right-up. An integer offset in `~/.config/omarchy/gpd-pocket-4-orientation` shifts that mapping modulo four; restart the service after changing it. Other sensor calibrations still require real-device verification.

To opt out:

```bash
systemctl --user disable --now omarchy-gpd-pocket-4-rotate.service
hyprctl reload
```

Reloading restores the fixed landscape baseline from #9160 (or the user's later monitor/input overrides). It leaves the optional sensor package and calibration file in place. Existing users who enabled the combined development version keep their service enabled; the split adds no migration that enables it for anyone else. User display/input overrides may be replaced while autorotation is enabled, so disable the service before selecting a fixed custom orientation.
