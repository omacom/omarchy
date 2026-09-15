# Plugin uninstall entry point

A plugin may declare an optional executable alongside its QML entry points:

```json
"entryPoints": {
  "barWidget": "Widget.qml",
  "uninstall": "bin/cleanup"
}
```

The CLI validates the path during add/update and revalidates it immediately before removal. It must be a non-empty relative path to an executable regular file, without control characters, `..`, dot/empty components or symlinks. The same hidden path helper owns both checks. The shell registry treats it as an ordinary safe entry-point path; no new plugin kind or QML lifecycle callback is introduced.

`omarchy plugin remove` obtains user confirmation, disables the plugin and runs the executable with the plugin directory as its working directory. `OMARCHY_PLUGIN_REMOVAL_ID` names the plugin and `OMARCHY_PLUGIN_DIR` names its directory. The hook runs synchronously with the caller's stdin/stdout/stderr and user privileges. `--yes` is passed to the hook only when supplied to removal; it explicitly approves executing the disclosed plugin code, including for a plugin that has never been enabled. No other command-line text is forwarded.

The hook owns only its external local cleanup. It must not remove or move its own plugin directory or recursively call `omarchy plugin remove`: Omarchy owns disabling, deleting/unlinking/backing up the folder and rescanning the registry. Use the environment marker to share a cleanup implementation with a plugin's own uninstall UI without recursion.

Exit zero only after cleanup completed and its outcomes were verified. Nonzero exits, including cancellation, abort file removal and leave the plugin directory available for retry. Cleanup is not transactional: earlier hook changes may have taken effect, and the plugin remains disabled if it was disabled before the failure. Make the hook idempotent, retain recovery information on partial failure, and explain how to retry. Do not claim that uninstallation succeeded until the outer command finishes.

For non-interactive use, honor `--yes` without unexpectedly prompting. Preserve shared tools, credentials for unrelated integrations and SSH keys unless the user explicitly chose their removal. If a required privilege prompt cannot be shown, fail with instructions; Omarchy does not silently run the hook as root. Warn explicitly when billable cloud resources are left behind. A cleanup hook is unsandboxed plugin code, not a guarantee that any of these plugin-author policies are enforced by the host.

`--skip-cleanup` bypasses hook parsing and execution for recovery or untrusted plugins, warning that external setup may remain. Symlinked plugin directories are always unlinked without executing code. Plugins without the entry point keep the existing removal behavior. No hook runs during add, update, disable, shell reload or logout.
