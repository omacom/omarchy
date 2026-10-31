# Plan: Users — more than one person per machine, picked by password

Revision 3. Rev 3 makes the login screen a password alone that finds its account, with `omarchy-login-match` ending attempts on the wrong account before they count. Rev 2 incorporates adversarial review by codex (medium): the first change that adds a second disk key also retires the static owner autologin, the boot selection is a one-use authorisation consumed at each SDDM start, the initramfs wrapper runs `cryptsetup` once and never changes its exit status, the login screen selects an account instead of discovering it through failed logins, uniqueness is checked against the disk's slots as well as the login hashes, the slot map is bound to the volume, account changes are journaled under one root lock, a child's own password change goes through a narrow helper, and root's password has an owner.

## Problem

Omarchy is built for one person. On an encrypted install one password opens the disk, logs in, and is root's (`omarchy-provision-owner` sets both with `chpasswd`), and SDDM autologins the owner from a static `/etc/sddm.conf.d/autologin.conf`. There is no supported way to add a second person, and the requests that need one have each grown their own answer:

- #9750 and omarchy-iso#146 make a *child install*: one account, the kid's, with root's password as a "parent password" typed into the kid's session. The parent has no account, and the parent's secret is entered into a session the kid controls (a fake `sudo` on `PATH` or a modified shell can capture it, and it is root and a disk key at once).
- #16100 makes a general multi-user model, but splits the one password: a shared disk password everyone knows, a locked root, autologin off, and a username box on the login screen.
- #14366 adds `omarchy user` commands with no answer for the disk or the login screen.

This plan keeps Omarchy's "type your password and you're in" for every person on the machine, and makes a child an account the parent adds after setting up their own.

## The model

- **Every account's password is also its own LUKS key slot.** Typing your password at the disk prompt opens the disk *and* tells the machine who you are.
- **The slot that opened the disk picks the autologin, once.** The selection is consumed by the SDDM start it was made for; any later SDDM start in the same boot shows the login screen.
- **No username box anywhere.** The disk prompt, the login screen and the lock screen take only a password; the disk prompt and the login screen find the account it belongs to.
- **Adults are in `wheel`; children are not.** A child is a limited account in the `omarchy-child` group, which later features (screen time, an app list) key on. Admin work happens in an adult's own session, never by typing an adult's password into a child's.
- **One account behaves exactly as today.** Nothing changes until a second account is added, and deleting back down to one restores today's setup for whoever remains.

## Setup > Users

```
Setup > Users
  dhh (Adult)
    Change password
    Delete
  emma (Child)
    Change password
    Delete
  Add
    Adult / Child → name → password → confirm → your password
```

- **Add** creates the account (Adult: `wheel`; Child: `omarchy-child` and nothing else — not `input`, not `docker`, none of the owner's recorded groups), sets its password, adds a LUKS slot for it, and records the slot in the slot map. Adding a slot needs a key that already opens the disk, and sudo's authorisation is not one (a cached timestamp or a passwordless grant proves nothing about the disk), so the flow ends by asking the adult for their own password, which must open their own mapped slot. The user's desktop is set up at first login by the existing `omarchy-provision-user` path.
- **Change password** changes the login password and the slot together, keeping the old slot until the new one is proven. For yourself, the old password authorises re-keying your slot. For someone else (a child who forgot theirs), it asks for your own password, as Add does.
- **Delete** ends the user's sessions, removes their slot, their map entry, any sudoers grant naming them (including `omarchy-sudo-passwordless`'s username-scoped `NOPASSWD: ALL` rule, which would otherwise pass to a later account of the same name), then the account, and asks whether to keep their home. It is not offered for the last adult (someone must be able to administer the machine) or for the account you are signed in as.
- **Adults see every user; a child sees only their own entry, with only Change password.**

The menu's rows come from a `users` provider in `Menu.qml` (one per account, a check on yours, only yourself for a child), and each opens `omarchy user manage NAME`, which offers what the helper would allow; Add is a static row shown to adults. Underneath are `omarchy user list|add|delete|password`. Menu visibility is not the boundary: the privileged work happens in one root helper, `omarchy-user-helper`, which authorises each request itself:

- an adult (in `wheel`, through `sudo`) may add, delete and set any password;
- a child may only change their own password, through a `NOPASSWD` sudoers grant for `%omarchy-child` to that one helper subcommand, and the helper requires their current password before anything changes;
- nobody gets `cryptsetup`, `chpasswd` or a shell through it.

### Passwords

- **At least 6 characters**, enforced by the helper and by the shared setup form (`install/provisioning/setup-form.sh`, which today accepts any nonempty match), so the installer's owner prompt follows the same rule. Existing passwords are kept; the rule applies when one is set. Six is a floor against a child's first password, not a strong disk key: offline guessing is limited only by LUKS's key derivation, and the disk is as strong as its weakest password, so the prompt asks for something longer.
- **Unique across accounts and across the disk.** A candidate is refused if it matches another account's shadow hash *or* opens any LUKS slot at all, the target's own included (tested with tokens disabled, as `luks_key_slot` and `omarchy-drive-password` already do). Shadow alone is not enough: an old password left in a slot after a `passwd` change no longer matches any hash but still opens that slot. Root's hash is skipped when it is deliberately the same password as its holder's (see *Root*).
- The refusal says only that the password is taken. It does reveal that a guess is somebody's password, but so does the disk prompt at every boot, without limit; the helper adds a delay and a lockout after repeated refusals so it is no cheaper than that.
- _Update > Password > User_ (plain `passwd`) goes away in favour of _Setup > Users > (you) > Change password_. _Drive Encryption_ stays for data drives, and `omarchy-drive-password` refuses the system disk once Setup > Users manages it.
- **Apple Silicon** records every kept key slot for its boot check (`omarchy-lifecycle-dispatch luks-slots`), which a second person's slot would fail, so the helper refuses to add one wherever a slot recorder exists until the Mac boot package can record user slots.

### Drift

Removing menu entries does not stop anyone running `passwd`. So the map records, for each account, a fingerprint of its shadow entry at the moment its slot was last synchronised. If an account's shadow entry has changed since, its slot no longer selects an autologin: boot falls through to the login screen, and _Setup > Users_ marks the account "password out of sync" and offers Change password to put the slot back in step. Drift costs the convenience, never the boundary.

## Boot: the slot picks the user

On x86 the root disk is opened by mkinitcpio's busybox `encrypt` hook. With Plymouth running, it calls `plymouth ask-for-password --command="cryptsetup open --type luks --key-file=- <device> <name> …"`; Plymouth splits that command into arguments itself and `execvp`s it with the password on stdin, so `cryptsetup` is resolved through the initramfs `PATH`, and shell syntax in the command is passed as literal arguments (the hook's `${CSQUIET}` becomes a literal `>/dev/null` argument under `quiet`, which the wrapper forwards untouched).

- **`omarchy-luks-slot`**, added after `encrypt` by `00-omarchy-hooks.conf` only once `/etc/omarchy/users` exists, so a machine with one person never carries it; the helper rebuilds the boot image (`limine-mkinitcpio`) the first time someone is added to an encrypted machine. It is a mkinitcpio hook shipped as `etc/initcpio/install/omarchy-luks-slot` (mkinitcpio searches `/etc/initcpio/install` before `/usr/lib/initcpio/install`, and `etc/**` already ships in `omarchy-settings`). Ordered after `encrypt` in the `00-omarchy-hooks.conf` baseline, it adds the real binary as `/usr/bin/cryptsetup.real` and puts a busybox `sh` wrapper at `/usr/bin/cryptsetup` (`add_file` overwrites).
  - Every call other than an `open` is `exec`ed unchanged.
  - An `open`, whether Plymouth hands it the password on stdin or `cryptsetup` prompts on the console itself, runs `cryptsetup.real --verbose` with the original arguments exactly once, keeps only its stdout aside (where verbose names the slot; the prompt and errors stay on screen), and exits with the real command's status. The password is never read, copied or replayed by the wrapper.
  - Only after success, and only as best effort, it parses `Key slot N unlocked.` and writes `<LUKS UUID> <slot>` to `/run/omarchy/luks-slot`. A failure to parse or write is ignored and never changes the exit status: the worst a recording fault can do is lose the autologin.
  - A wrapper that is missing or does not parse would break the unlock itself, which no runtime care can contain. The hook therefore checks the wrapper with `sh -n` at build time and refuses to install it (leaving the real `cryptsetup` in place) if it fails, and phase 3 proves every unlock path on a worker before it ships: Plymouth, the tty fallback, a keyfile, a wrong password then a right one, and `quiet`.
  - `/run` is a tmpfs mounted by `init_functions`, and util-linux `switch_root` moves it into the real root, so the record is there for the boot that follows.
  - A keyfile's slot is recorded like any other and maps to nobody; a token unlock reports its token's slot, which maps to nobody either, so both show the login screen.
- **`omarchy-login-select`**, run as two `ExecStartPre=` steps of `sddm.service` through a drop-in, so it runs at *every* SDDM start, not just at boot. The first, `--clear`, must succeed for SDDM to start: it removes the installer's `autologin.conf` and writes `zz-omarchy-autologin.conf`, which sorts after every other drop-in, with an empty `User=`, and stops SDDM if `/etc/sddm.conf` (which outranks all drop-ins) names someone. The second, which may fail into the login screen, fills in the user:
  - with one account, writes autologin for that account on an encrypted install (today's behaviour, for whoever remains);
  - with more than one, consumes `/run/omarchy/luks-slot` (renaming it so no later start can reuse it), and writes autologin only if the UUID is the root volume's, the slot is mapped, the account exists, and its shadow fingerprint matches; otherwise it leaves the drop-in removed and SDDM shows the login screen.
  - It never falls back to the owner and writes `Relogin=false`. The helper refuses to add a second person while `/etc/sddm.conf` names an autologin user.
- **The slot map**, `/etc/omarchy/users/slots`, root-owned `0600`, one line per account: `<LUKS UUID> <slot> <uid> <user> <shadow fingerprint>`. Written only by the helper, atomically, under its lock. Duplicate slots, duplicate users, a UUID that is not the root volume's, or a journal left mid-change make the whole map untrusted, and boot shows the login screen. It holds slot numbers and names, never key material.

Hibernation resume never reaches SDDM and is unaffected. Apple Silicon boots a systemd initramfs, where `systemd-cryptsetup` caches the passphrase in the kernel keyring instead; reading it there (and testing it with `luks_key_slot`) is a second source for the same selector and lands after x86 is proven. Until then those machines show the login screen when there is more than one account.

## The login screen

The Omarchy SDDM theme is a single password field, and it stays one: no name, no arrows. Return tries the password for `userModel.lastUser`, then for each other account in `userModel`, until one logs in, the way the disk prompt finds a key slot.

SDDM's greeter can only call `sddm.login(user, password, session)`, so on its own that would be a failed PAM login against every wrong account: a correct password for B would first count against A, and pay `pam_unix`'s delay. So the first line of `/etc/pam.d/sddm` is `auth [success=die default=ignore] pam_exec.so quiet expose_authtok /usr/bin/omarchy-login-match`. As root, it succeeds, which ends the attempt before `pam_unix` and `faillock`, only when the password belongs to another account; a correct password and a password that is nobody's fall through to the usual stack, and so does any failure of the script, which fails open to the stack as it was. Linux-PAM never returns success from a `die` on a successful module, so ending the attempt can only refuse it. It ends an attempt early only when the password's owner has no failed logins on record: a locked owner's password takes the same slow refusal as a wrong one, so a fast refusal never tells someone guessing at the screen what a lockout is hiding. It gives up after ten seconds, so a stalled account lookup leaves the attempt to the usual stack rather than holding every login.

A password that is nobody's is still tried for every account, and counts once against each (`deny=10`, `unlock_time=120` in `system-auth`). That is what a guess at a password-only screen is: a guess at every account, as at the disk prompt. SDDM reports a failure twice, and before its helper has exited, and drops a `login` sent while that helper still runs; so the theme takes each failure as a pair, waits 300 ms before the next account, and resends an unanswered attempt a few times before reporting the password wrong.

Unencrypted installs use the same screen. The lock screen is unchanged: it belongs to one session and knows its user.

## Changes are journaled

Account, shadow, root's shadow, LUKS metadata and the map cannot change atomically together. The helper serialises every change under one root lock (`/run/omarchy-users.lock`) and records each in a root-owned journal (`/var/lib/omarchy/users/journal`), holding the operation, the account, the UUID, slot numbers and the phase, never key material. Each operation keeps old access until its replacement is verified:

- **Add:** journal a free slot → create the account → add the key in that slot (authorised by the adult's slot) and prove it opens it → set the password → publish the map entry. Interrupted before the account took its password, the next run kills the journaled slot and removes the half-made account.
- **Change password:** journal a free slot and the account's shadow fingerprint → add the key there → set the account's password and, for root's holder, root's in one `chpasswd` run → publish the map entry → kill the old slot. Whether to roll back or forward is read from shadow: if the fingerprint changed the account took the new password and the change finishes, otherwise the new slot goes and the old password works everywhere.
- **Delete:** root is handed over first, then the journal records the slot and the run only ever rolls forward: lock the account and end its sessions → remove the map entry → kill the slot → remove grants → remove the account. A disk whose slots cannot be read stops it rather than passing as revoked.

The journal and map are synced before and after each rename, and the journal records the volume's UUID; one recording another disk is never replayed. Once the map knows someone, the password that opens their own slot proves who they are, which is how a person whose login password was changed with `passwd` gets back in step.

While the journal holds an unfinished change, boot shows the login screen and the helper refuses new changes until it has finished the old one.

## Root

Root's password is the installer owner's today. The helper records root's holder in `/etc/omarchy/users/root` (the installer owner, on the first `omarchy user add`). Change password for the holder updates root's password in the same journaled step. Deleting the holder transfers root to the adult doing the deleting, whose password the flow already asks for, so root never keeps a deleted person's password. With only children left this cannot happen: the last adult cannot be deleted.

## Children

A child is an account in `omarchy-child`, and three things follow from that group, each read in the child's own session:

- **Theme collections, per person.** Themes all live in `themes/`; `default/omarchy/theme-collections/kids` names #12488's Kids collection, and General is every theme in no collection. An adult picks which collections each person's theme picker offers under _Setup > Users > (person) > Themes_ (kept in `/etc/omarchy/theme-collections/<user>`, root's to write, theirs to read); until then a child sees Kids and anyone else everything. `omarchy-theme-collections --allowed` answers the picker (`omarchy-theme-switcher`'s rows), which falls back to every theme while none of the person's is installed, and a child's first login (`install/user/first-run/child.sh`) sets the first Kids theme when Kids is theirs. The themes themselves land with #12488.
- **Blocked apps, per person.** Every package stays installed for the whole machine; each person has a list of desktop ids (`/etc/omarchy/blocked-apps/<user>`, root's to write, theirs to read) that they neither see nor run. Their launcher, dock and Apps menu leave them out, and `omarchy-user-apps-apply` denies each one's program to that person with an ACL taking read and execute both, re-applied by a pacman hook after every transaction, since an upgrade replaces the program. A program other things run through (a shell, an interpreter, `env`, an Omarchy launcher) is never denied, so web apps are hidden only. A new child starts with the shipped list (`default/omarchy/child-blocked-apps`: the messaging, social and work web apps); adults change anyone's under _Setup > Users > (person) > Apps_.
- **Screen time**, from #11196: a root daemon counting the minutes a child's session is actually in use, warning as the day's budget runs down and locking at zero, with a bedtime, earning minutes by solving sums, and an Agreement mode with no lock. Adding a child puts them under it; the bar's pill opens their day, and its parent drawer and settings window take a grown-up's password, any adult's, typed right there in the child's session and checked by the same rate-limited, logged check that lets an adult's password open a child's lock screen. After the screen locks at zero, only a grown-up's unlock earns the grace to hand out minutes; the child's own relocks at once.
- **A web allowlist**, switched on and kept from the screen time settings. Browser policy is machine-wide, so it is held in the network by uid (`omarchy-web-allowlist-apply`): the child's DNS goes to a dnsmasq answering only the listed domains and their subdomains, DNS-over-TLS, resolved's socket and resolved's D-Bus API are closed to them, and DNS-over-HTTPS is off in Chromium-family browsers and off and locked in Firefox and Zen while anyone's list is on. It starts from `default/omarchy/web-allowlist-starter`, and deleting a child takes their list and its rules with them. A site reached by bare IP is not caught.
- **The cost of a grown-up's password in a child's session.** The screen time controls and a child's lock screen take an adult's password where the child is sitting, as the maintainer chose. They run their commands by absolute path, so a script on the child's `PATH` cannot capture it, but a child able to alter their own session (`LD_PRELOAD`, a shell of their own) could; the screen time daemon likewise believes a "locked" answer only from the real Quickshell, which a child running Quickshell with a config of their own could still forge. A child's own password changes are limited to three an hour, since each says whether a password is someone else's.
- **No Install or Remove.** Those menus are hidden in a child's session, and the git identity prompt at first login is skipped.

## What else multiple logins need

From #16100, without its disk and login-screen model:

- **The `%wheel` grant.** `omarchy-provision-owner` writes `%wheel ALL=(ALL:ALL) ALL`; an ISO install grants the owner by name, so the first `omarchy user add` writes the same `00-omarchy-wheel` drop-in if it is missing.
- **A per-user update log** (#15683), so a second account can update after the first has.
- **Children are told, not prompted.** Install, remove and update entries decline in a child's session with "Ask a grown-up to do this from their account", via an `omarchy-sudo-allowed`-style predicate, before `sudo` asks for a password it would refuse. Polkit's admin identities are `wheel`, so actions that would ask for an adult's password inside a child's session are listed and either declined the same way or left to the actions' own `allow_active` policy (NetworkManager's Wi-Fi toggle, for one).
- **Migrations in a limited account** run their sudo steps only after an adult's run, as #16100 does.

## Costs, stated plainly

- **Every account's password opens the whole disk.** With a disk key and a live USB, a child can read everything, and can also *change* anything offline: plant a program that runs in an adult's session, or edit the boot entry to start another init. That is true of any design where a child can start the machine alone (a shared disk password is the same). The restrictions here hold while the installed system runs as installed; against a child willing to alter the boot environment they need a firmware password, external boot off, and a boot chain that cannot be edited, which is a separate project (TPM unlock with a measured boot).
- **The disk is as strong as the weakest password on it**, hence the minimum and the prompt's advice.
- **Each slot adds a key-derivation pass to a wrong password** at the disk prompt (and a correct one pays for every slot ahead of it), roughly a second each. Households are a handful of accounts; this is not built for dozens.
- **Omarchy-only boot code.** The wrapper is small and checked at build time, but it is in the initramfs, the worst place to break; phase 3 does not ship until every unlock path is proven on a worker.

## Phases

1. **Accounts and the login screen, together.** `omarchy-user-helper` with its journal, lock and authorisation; `omarchy user list|add|delete|password`; the slot map with fingerprints; password rules in the helper and the setup form; the `%wheel` drop-in; root's holder; _Setup > Users_; retiring _Update > Password_'s two entries; the theme's password matching with `omarchy-login-match`; and `omarchy-login-select` in its one-account and login-screen modes. This phase must ship whole: from the moment a second person has a disk key, the static owner autologin is gone and every boot with more than one account shows the login screen.
2. **Boot selection.** The `omarchy-luks-slot` hook, proven on a worker built from the ISO across every unlock path, then `omarchy-login-select` consuming its record.
3. **Children.** Blocked apps, theme collections, screen time with an adult's password, the web allowlist, an adult's password on a child's lock screen, and System > Switch User; then declined admin entries, polkit coverage and the Apple Silicon keyring source.

## What happens to the open pull requests

- **#9750, omarchy-iso#146:** superseded. Their prompt wording and the `omarchy-parent <feature>` idea feed phase 3; the child install and the parent password typed into the kid's session do not carry over.
- **#11196:** rebased onto `omarchy-child` in phase 3.
- **#16100:** the pieces under *What else multiple logins need* are taken from it; its shared disk password, locked root and username box are not.
- **#14366:** superseded by phase 1.
- **#12488, omarchy-site#180/#181:** themes, independent of all of this.
