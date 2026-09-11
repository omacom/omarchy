# Plugin video fixtures

These are opt-in demonstration sources, not automatically installed first-party plugins. Run `OMARCHY_PATH`'s `dev/plugin-demo/stage` to create disposable local Git repositories under a new `/tmp/omarchy-plugin-demo.*` directory. It prints their paths and does not install, approve, start, or publish anything.

Use **Setup → Plugins → Add Plugin** to validate and add the hostile source in the default Ward mode. Review the exact revision, select the one required `printf` leaf, approve, then enable. Open its `!` widget and press **Malicious Execution**. It actually asks Ward to run a different, unapproved argument. The real broker must deny that request before spawning a host job. Even if this specific policy regresses, the candidate command only prints harmless text; no personal files, credentials or external destination are targeted. The panel reports the actual structured response, not a timed or manufactured success message.

Omarchy displays a separate host-owned blocked-operation notification from Ward's authenticated decision event. The plugin requests no notification grant and cannot manufacture that event. The operation is denied; the plugin is not automatically killed. Use **Disable & revoke** to demonstrate stopping it. These events cover broker policy denials, not every kernel-denied syscall, and are rate limited; repeated clicks may produce no additional toast.

Add the `yolo` source with the explicit YOLO switch, validate it, and acknowledge unsandboxed trust. Enable separately. This simple clock is deliberately harmless, but runs in-process without Ward containment. It uses a different identity from the Ward fixture; never strip `sandbox` from an isolated identity to demonstrate YOLO.

After recording, remove `demo.ward-hostile` and `demo.yolo-clock` through the manager. This unloads their UI and revokes the Ward approval before deleting the installed checkouts. Reviewed snapshots, host-owned provenance/isolation identities and any saved plugin data are retained intentionally; they confer no active grant after revocation. The disposable Git source directories remain available for another take. No package recipe or system-wide installation is changed by staging these fixtures.

Omagotchi and Radio trials remain separate external source checkouts, pinned and reviewed before use. They are not replaced by these synthetic fixtures or copied into Omarchy's automated containment tests.

## Reversible desktop preparation

Stage a matching native executable/Qt module and a fresh Omarchy adapter using [the runtime staging workflow](../../docs/ward-runtime.md#installed-style-verification). Keep them in a versioned development directory; do not overwrite a runtime used by a running session or install a system package for this demonstration. The controlled capture session selects `OMARCHY_WARD_HOST`, `OMARCHY_WARD_RUNTIME` and the matching `QML_IMPORT_PATH`.

Before switching the live desktop, identify its actual Omarchy checkout and launcher environment, save the existing `shell.json`, and record any existing Ward overrides. `omarchy-restart-shell` deliberately inherits the compositor's environment, not temporary overrides from its caller. Do not start a second shell beside the existing desktop or assume this source checkout owns the active session. The capture deployment must preserve that ownership and have an exact restore path.

After the take, disable/remove only the demo identities and the two external plugins installed for the video, restore the prior layout/launcher selection, and restart the original shell. Stop all demo Ward sessions before retiring the staged native/adapter directories. Leave pre-existing plugin installations and user data untouched; retained reviewed snapshots are not active sessions or approvals. Staging alone changes none of the live session's configuration.
