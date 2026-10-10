# Managing Additional Users

Omarchy sets up one owner account on first boot. When you need a second login on the same machine — a family member, a handoff, a separate work account — manage it with the `user` command group. Every command works interactively (gum prompts) or scripted with explicit flags plus `--yes`.

## Create a user

```bash
omarchy user add
omarchy user add alice --groups wheel --yes
```

This creates the account, puts it in the given groups (default: none), and sets its password. Sudo is managed separately via the `omarchy user privileges` command. The greeter needs a password, so if you pass `--skip-password`, set one later with `sudo passwd <username>`. The first graphical login provisions the desktop automatically.

## Change groups

```bash
omarchy user groups
omarchy user groups alice --add wheel --yes
```

Adjusts supplementary groups (`--add`/`--remove` combine, `--set` replaces). The primary group is never touched, and changes take effect on next login. With no flags it shows a gum checklist preselected with the user's current groups.

## Set sudo level

```bash
omarchy user privileges
omarchy user privileges alice --level password --yes
```

Sets sudo via the wheel group: `password` adds the user to the `wheel` group (granting sudo that asks for a password), `none` removes the user from the `wheel` group. Like the rest of Omarchy, sudo always asks for a password. This is a permanent grant — different from the temporary Passwordless Sudo toggle under Setup > Security, which expires automatically (see Security).

## Remove a user

```bash
omarchy user remove
omarchy user remove alice --remove-home --yes
```

Removes the account (never root, system accounts, or your own). Logs the user out first, then optionally removes the home directory. The user's sudo access (via wheel group) is removed automatically when the user is removed.

## See also

- Security: temporary Passwordless Sudo vs the permanent `user privileges` grant above.
- Passing on a machine you've already used: for a full handoff, Reset Computer wipes every account; the commands above are for adding or removing individual users.

