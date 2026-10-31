-- The Copilot key confirms face scans (omarchy setup security face). Bound
-- here it reaches no window, so it can never end up in a password, and the
-- polkit dialog hears it through the shell. Root reads the key from the
-- keyboard itself (omarchy-face-key), so this binding only drives the dialog.
o.rebind("SUPER + SHIFT + code:201", "Confirm with your face", { ipc = "polkit.faceKey" })
