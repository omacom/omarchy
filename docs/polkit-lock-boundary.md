# Polkit authentication and session locking

Omarchy's native desktop Polkit agent cancels pending authentication when locking is requested and rejects new requests until the session is unlocked. It also blocks during startup lock discovery or if the lock service is missing. The agent stays registered, clears its dialog and entered password on rejection, and requires a fresh request after unlocking. Successful screen unlocking resolves startup lock discovery.

The private authentication store coordinates the shipped lock and Polkit services without exposing them through the public service map. Existing lock clones use the same contract. The cancellation gate rejects overlapping requests, newest first, because the current Quickshell Polkit implementation exposes only its newest flow and can otherwise lose track of an older request.

The lock shows its normal fingerprint invitation only after its own PAM conversation reaches the reader. While waiting, it preserves the layout; repeated failures show the existing unavailable warning. Preview illustrates the configured method without authenticating. Canceling a Polkit request does not guarantee immediate reader release: that depends on Polkit, PAM and fprintd cleaning up the canceled transaction. Password unlocking remains available.

This fix covers the desktop authentication agent Omarchy ships. Independently registered agents, existing customized Polkit clones, terminal agents, cached authorizations and actions already authorized are outside this change. It adds no PAM module, root service, package or authentication-policy change. Ordinary unlocked password and fingerprint authorization retain their existing behavior; overlapping requests are dismissed and must be retried individually.

Existing installations receive the shared shell code through the normal update. The updater already restarts the shell, so no migration or user configuration rewrite is needed. If a locked session or a terminal-only update prevents that restart, the fix becomes active at the next successful shell restart or graphical login. Custom agent copies must adopt the gate themselves.

Validation covers lock discovery and service replacement, cancellation of active and new requests, overlapping requests, reader readiness, ordinary authentication and fresh authorization after unlocking. Real fprintd with libfprint's virtual device can validate software cleanup, but does not establish physical-reader behavior.
