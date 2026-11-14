# Managing Additional Users

Omarchy sets up one owner account on first boot. When you need a second login on the same machine — a family member, a handoff, a separate work account — manage it with the `user` command group. Every command works interactively (gum prompts) or scripted with explicit flags plus `--yes`.

## Create a user

```bash
omarchy user add
omarchy user add alice --groups '' --yes
```

This creates the account, puts it in the given groups (default: none), and sets its password. Sudo is managed separately via the `omarchy user privileges` command. The greeter needs a password, so if you pass `--skip-password`, set one later with `sudo passwd <username>`. The first graphical login provisions the desktop automatically.

A plain user needs no supplementary groups. `--groups ''` explicitly selects none, including in a terminal. Add only trusted administrators to `wheel`: Omarchy grants wheel members password sudo, and polkit also treats them as administrators, allowing root access through `pkexec` or `run0` with their own password. `omarchy user add alice --groups wheel --yes` therefore creates an administrator.

If `/etc/sudoers.d/alice` already exists, creation is refused to avoid inheriting an old sudo grant. Inspect it with `sudo visudo -f /etc/sudoers.d/alice` and resolve it before reusing the name. This check covers the per-user path used by the older standalone tools; independently configured grants elsewhere in sudoers need separate review.

## Change groups

```bash
omarchy user groups
omarchy user groups alice --add wheel --yes
```

Adjusts supplementary groups (`--add`/`--remove` combine, `--set` replaces). The primary group is never touched, and changes take effect on next login. With no flags it shows a gum checklist preselected with the user's current groups.

Use `omarchy user groups alice --set '' --yes` to clear supplementary groups. Removing your own `wheel` membership or removing it from the last administrator is refused, including with `--yes`. Another login user counts as an administrator through primary or supplementary `wheel` membership, or an unrestricted sudo grant; a command-specific sudo grant does not count. Sign in as another administrator before changing your own access.

## Set sudo level

```bash
omarchy user privileges
omarchy user privileges alice --level password --yes
```

Sets administrator access via the wheel group: `password` adds the user to `wheel`, granting password sudo and polkit administrator access; `none` removes supplementary `wheel` membership. This is a permanent grant — different from the temporary Passwordless Sudo toggle under Setup > Security, which expires automatically (see Security).

The same self and last-administrator protections apply here. If `wheel` is the primary group, change that group separately first; `gpasswd -d` cannot remove primary membership. Existing sessions retain their group access until logout.

Removing `wheel` does not remove independent sudoers rules. After `--level none`, the command checks effective sudo access and reports whether a grant remains, no grant remains, or the check failed. For remaining grants, run `sudo -l -U alice` from an administrator session and review `/etc/sudoers` and `/etc/sudoers.d` with `sudo visudo`. A failed query does not prove that access was removed.

## Remove a user

```bash
omarchy user remove
omarchy user remove alice --remove-home --yes
```

Removes the account (never root, system accounts, your own, or the last administrator). Safety checks run before terminating the user's session. Logs the user out first, then optionally removes the home directory. Wheel membership is removed automatically with the account. Independent sudoers rules are left in place; review them before reusing the login name.

All account-management commands require the login name rather than a numeric UID, and group/privilege changes refuse system accounts as well.

## First login as a plain user

A plain user can log in and gets a separate desktop configuration. System administration still requires an administrator. Omarchy may show an "Update system" notification that the plain user cannot act on; an administrator has to run the update. Polkit prompts for system actions expect an administrator's password, so the plain user's own password will not authorize those actions.

## See also

- Security: temporary Passwordless Sudo vs the permanent `user privileges` grant above.
- Passing on a machine you've already used: for a full handoff, Reset Computer wipes every account; the commands above are for adding or removing individual users.
