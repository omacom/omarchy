# Plan: Remote — Gliff is the remote desktop

Revision 2. Revision 1 planned to finish Sunshine and Moonlight into a remote desktop. Gliff replaced that plan: a Hyprland-to-Hyprland remote desktop over ssh, installed by default (#14712) and brought to existing installs on x86_64 and aarch64 by migration, with a bar indicator that lights up on the machine being controlled and 1Password kept shareable during a session. Sunshine and Moonlight go back to being game streaming: Moonlight moved from a default install to _Install > Gaming > Moonlight_ (#18397), and Sunshine stays an opt-in host.

## Problem

Gliff answers the hard parts revision 1 was designing around:

- **Pairing.** There is none. ssh keys are the trust model, so there are no ports to open, no web admin, no PIN, and no certificate warning.
- **A remote desktop, not a mirrored desk.** `gliff --headless` gives the session a private screen sized to the window and removed on disconnect; mirroring a real screen is the other mode.
- **Clipboard.** Both directions, including images and files, which revision 1 had to rule out because Moonlight has no transport for it.
- **Reach.** Whatever ssh reaches: the LAN, or the tailnet when away from home.

What's left is on the Omarchy side:

- **Nobody can find it.** The manual mentions Gliff once, as the bar indicator. There is no chapter that says Omarchy ships a remote desktop or how to use it, and Gliff only shows up in the app launcher.
- **The machine you connect to needs sshd, which is off by default.** _Setup > Security > SSHD_ (`omarchy-setup-security-sshd`, which can pull keys from a GitHub user) already does the job, but nothing ties it to Gliff, so the first connection attempt fails with an ssh error instead of a pointer.
- **No audio.** Gliff carries video, input, and clipboard. Revision 1's audio design was a Sunshine virtual sink and doesn't carry over.
- **It needs a running session.** `gliff-server` attaches to the logged-in Hyprland session, so a machine sitting at the full-disk-encryption passphrase prompt can't be reached. The same limit applied to Sunshine.

## Shape

Documentation and pointers, not new machinery:

- **A manual chapter, `manual/52-remote-desktop.md`.** Covers what Gliff is, turning on SSHD on the machine you want to reach, opening Gliff from the launcher and adding `user@host`, mirror versus `--headless`, `Shift+Esc` to take your shortcuts back, the clipboard trust note and `--no-clipboard`, Tailscale for reaching home from elsewhere, the bar indicator on the controlled machine, and the limits: Hyprland on both ends, a logged-in session, no audio. Reaching Mac or Windows machines is out of scope and gets a one-line pointer to Remmina.
- **`manual/26-gaming.md`** keeps Moonlight and Sunshine for game streaming and links to the new chapter for working on another machine.
- **A hint where the first connection fails.** If ssh to the host is refused, the user should learn that the other machine needs _Setup > Security > SSHD_. Whether that hint lives in Gliff's error message or only in the manual is open question 2.

## Not in this plan

- **Sunshine as a remote desktop.** Revision 1's phases (terminal pairing, virtual display, audio sink, `setup.sunshine` menu) are dropped. Its findings about the game-streaming host still hold and are worth a small separate fix: `omarchy-install-service-sunshine` starts the daemon twice (systemd user unit plus a Hyprland autostart line); its Tailscale firewall rules are only added if `tailscale0` already exists at install time; `omarchy-remove-service-sunshine` leaves `~/.config/sunshine/` behind; and there are no Install or Remove menu rows for it.
- **Gliff's own roadmap.** AV1 for wide screens, an optional UDP transport, and multi-output selection live in Gliff's `docs/architecture.md`.
- **Mac, Windows, and phone clients or hosts.** Gliff is Hyprland on both ends by design.

## Open questions

1. **Audio.** It belongs in Gliff (Opus over the same ssh channel), not in Omarchy. Leaning: raise it in the Gliff repository and document the limit here until it lands.
2. **Where the sshd hint lives.** Gliff could recognize a refused connection and say "turn on SSHD on that machine", or the manual alone carries it. Leaning: Gliff's error message, since that's where the user is when it fails.
3. **A menu row.** Is the launcher enough, or should Gliff get a menu entry (for example, connect to a recent host)? Leaning: the launcher. Gliff's tabs already remember hosts.
4. **Headless boot under full-disk encryption.** TPM auto-unlock or remote unlock is its own security design. Document the limit for now.
