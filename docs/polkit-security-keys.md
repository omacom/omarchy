# Security-key feedback in Polkit

The Polkit dialog reads the direct `auth sufficient pam_u2f.so` entries in `/etc/pam.d/polkit-1`. A matching PAM cue activates an inline security-key indicator. An explicit `userverification=1` selects the fingerprint glyph; other keys use a key glyph. Configuration alone does not indicate presence. Entries with `nodetect` are ignored because their cue is not evidence that a registered key was detected. Included PAM files and other control policies are not parsed.

While PAM waits on the key, the dialog says “Touch your key.” When PAM requests a response, it removes the key indicator and returns to text entry. The UI does not open the FIDO device, submit synthetic responses, or retry authentication itself.

## Optional prompt-attempt feedback

Polkit does not expose an authenticator's biometric retry counter. Do not display a fixed number as hardware retries remaining. An administrator who has configured multiple PAM attempts can give each attempt a distinct `cue_prompt` ending in `(N prompt tries left)` (singular: `(1 prompt try left)`). The dialog shows that explicitly supplied prompt budget. A decreasing budget flashes the key indicator red and says “Try again” for 1.2 seconds. A timeout also advances the PAM stack and is treated as an unsuccessful attempt; it is not presented as a definite fingerprint mismatch.

For an already configured biometric key, a three-attempt stack can use:

```text
auth sufficient pam_u2f.so cue authfile=/etc/fido2/fido2 userverification=1 [cue_prompt=Touch your security key (3 prompt tries left)]
auth sufficient pam_u2f.so cue authfile=/etc/fido2/fido2 userverification=1 [cue_prompt=Touch your security key (2 prompt tries left)]
auth sufficient pam_u2f.so cue authfile=/etc/fido2/fido2 userverification=1 [cue_prompt=Touch your security key (1 prompt try left)]
auth required pam_unix.so
```

This is the authentication portion only, not a replacement for an entire PAM file. Account, password, and session rules remain the administrator's responsibility. The UI change does not install this policy or alter existing authentication rules. Credential options, hardware lockout, and password fallback continue to be enforced by PAM and the authenticator. A key can exhaust its hardware retries before the prompt budget is spent.

Distinct messages matter: Quickshell exposes the last supplementary message as a property, so repeated identical cues do not produce a change notification. With ordinary or unnumbered custom cues, the indicator still works, but no count or inferred retry failure is shown. Explicit Polkit supplementary errors flash an active key indicator red.

## Verification

Run `bash test/shell.d/polkit-test.sh` for cue parsing and attempt transitions. In the running shell, verify the registered-key cue, retry feedback, password fallback, successful authentication, Escape cancellation, a subsequent fresh request, and a request with no registered key attached. Confirm the external key remains available with the laptop lid closed. Do not deliberately exhaust hardware retries merely to test the UI; a mock authentication flow can cover exhaustion and cancellation transitions.
