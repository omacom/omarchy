# Face Authentication

Omarchy can unlock the lock screen, and approve `sudo` and polkit requests, by looking at you with your laptop's infrared camera. It needs an IR camera of the kind Windows Hello uses; a colour webcam is deliberately not enough, because it cannot see in the dark and a photo fools it.

## Setting up

Open the Omarchy menu, then Setup, Security, Face. It only appears when an IR camera is detected. Setup installs the face authentication package, fetches and verifies the recognition models (about 260 MB, once), enrols your face, verifies it, and only then wires it into the lock screen, `sudo` and polkit. Your enrolment is a set of numbers derived from your face, never images, kept root-only in `/var/lib/faceauth`.

To enrol another look later, such as glasses or a beard, use Setup, Security, Face: Add Look. It merges into the same identity.

## How it behaves

- **Lock screen**: look at the camera and it opens, usually in under two seconds. If you walk away and the screen goes dark, sitting back down wakes it and opens it; nothing needs to be touched.
- **Walk-away lock**: optional. `sudo faceauth presence on` locks the session ten seconds after the camera stops seeing you, and keeps the panel lit for ten minutes so you can see it waiting from across the desk. `sudo faceauth presence off` turns it off. The watch takes one short look every two seconds on mains and every five on battery, about a twentieth of one core.
- **`sudo` and polkit**: every request opens a window naming the command and the program asking. Nod twice to allow it, or type your password into the window; the buttons let you dismiss it, deny and kill the requester, or block it for ten minutes. The window waits for you, without a time limit: it sits there until you answer it, and if you walk away meanwhile the session locks and the request resumes when your face unlocks it. Nothing can elevate silently: without a window on your desktop there is no face approval, and no key or click can stand in for the nod.
- **Notifications** that arrive while the screen is locked show on the lock screen by app name and count only.

## What it defends against, and what it does not

A phone showing your photo is never even seen as a face: the IR camera sees only its own illuminator reflected in the glass. A paper print is seen, but refused by two physical checks: paper reflects infrared several times more strongly than skin, and a print's surround lights up with the face while a real head's background stays dark. These are measurements, not a model, and their thresholds are published in the project's documentation.

Not defended: a person who looks like you, a 3D mask, or malware already running as your user with your password. Face authentication is not a substitute for a strong password, and it never replaces it: every failure, from a covered camera to a stopped service, falls back to the password.

## Checking on it

`faceauth doctor` reports every part: camera, illuminator, models, service, enrolment, each PAM stack, and the two things it will always warn about, that templates are stored in plain form when the machine has no TPM, and that a face match does not reset the password lockout counter.

## Removing it

Setup, Security, Remove, Face (or `omarchy remove security face`) restores the original PAM files, deletes your enrolment unless you pass `--keep-templates`, stops the service and removes the package.
