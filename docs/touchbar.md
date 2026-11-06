# Optional Touch Bar integration proposal

The community [Omarchy Touch Bar plugin](https://github.com/guirossibrum/omarchy-touchbar) and its separately packaged tiny-dfr fork provide an animated Omarchy menu button, tap/hold dictation through Omarchy's selected backend, and event-driven system-font following. The plugin README includes a video recorded on an M1 13-inch MacBook Pro and installation instructions. This proposal does not claim official package ownership or a particular release target.

## Hardware boundary

`omarchy-hw-touchbar` selects only the Apple Silicon 13-inch MacBook Pro models with device-tree compatibles `apple,j293` (M1) and `apple,j493` (M2). It combines the existing platform and exact model predicates. An Apple Silicon architecture or family check alone would also select MacBook Airs, desktops and MacBook Pros without a Touch Bar.

The predicate does not depend on the current DRM connector being enabled: closing the lid or powering down an idle Touch Bar must not change whether the model supports it. Adding another supported model requires qualifying the daemon's input/display interfaces first. Intel T1/T2 machines are outside this integration's current scope.

Any future automatic package selection or setup must check `omarchy-hw-touchbar` before installing the daemon or enabling the plugin. Do not add the daemon to the common or family-wide package list. The companion installer, layout application, animation setup and font synchronization also guard their entry points, so an unsupported machine skips those operations before changing files or requesting privileges. Removal remains available independently of hardware detection.

## Package and session boundary

The package recipe lives in the [companion repository](https://github.com/guirossibrum/omarchy-touchbar/tree/feature/animated-menu-logo/packaging/omarchy-touchbar). It pins a source revision of the community fork, provides/conflicts with `tiny-dfr`, and preserves the existing executable, service and udev interfaces. The plugin supplies the layout, bindings and font hooks; it does not run an animation subprocess. The native renderer reuses Omarchy's ttfx Wipe effect.

This change adds no default package, first-boot action, migration, enabled plugin or background process. Package ownership, signed publication and replacement/rollback qualification must be agreed before selecting a default dependency. The final recipe belongs in the package repository selected by maintainers, rather than duplicating the Rust renderer in main Omarchy. The modified daemon and plugin are both required for the enhanced features; publishing a recipe alone does not install a complete user experience.

Current physical validation is on an M1 MacBook Pro; M2 is a supported model match, not a claim of a second hardware test. [Validation notes](https://github.com/guirossibrum/omarchy-touchbar/blob/feature/animated-menu-logo/VALIDATION.md) describe the native/package checks and the separate local lid workaround. A main-repository merge and release scheduling remain maintainer decisions.
