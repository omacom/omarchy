# Active Directory

If your computer belongs to a company that runs Active Directory, you can join it to the domain so people can sign in with their directory account and password. It's optional: until you set it up, nothing about Omarchy changes.

## Joining the domain

Run _Setup > Active Directory_ in the Omarchy menu (`Super + Space`). It asks for the domain, then for the directory account that is allowed to join computers. You can also run it directly and pass everything up front:

```bash
omarchy setup ad --domain example.corp --group "Linux Users" --join-user admin
```

Before you start, you'll want:

- A DNS server that points at one of the domain controllers. If `realm discover example.corp` can't find the domain, the setup can't either.
- A correct clock. Kerberos refuses a computer that is more than five minutes off, so the setup turns on time synchronization first.
- An account that is allowed to join computers. Your IT team knows which one. Its password is asked for once, by `realm`, and never stored.

The setup then does the following:

- Installs the directory client packages, two of them from the AUR (`realmd` and `adcli`).
- Joins the domain. If the computer already has an account in the directory, it's reused.
- Lets directory accounts sign in with their short name, so `jean` rather than `jean@example.corp`, with a home in `/home/jean` created the first time they log in.
- Teaches the system to look up directory accounts, so `id`, `su`, and the lock screen know them.

Local accounts, including yours, are left exactly as they were.

## Limiting who can sign in

Pass `--group` with the name of one directory group, and only its members can sign in to this computer. Without it, the domain's own access rules apply. Local accounts are never affected either way. Run the setup again with a different `--group` to change it; a computer that's already joined isn't joined a second time.

## Checking that it works

Ask for a directory account by its short name:

```bash
id jean
```

You should see its numbers and the groups it belongs to. Then `su - jean` asks for that account's directory password. A directory account that is signed in can also unlock the lock screen (`Super + Ctrl + L`) with its directory password, the way a local account does with its own.

## Staying joined through updates

An Omarchy update can reset the system's account lookup, and when it does, SSSD keeps running but every directory account turns into "no such user". So `omarchy update` puts it back after the packages are installed. On a computer that isn't joined, it does nothing and asks for nothing.

## What this doesn't do

It doesn't give directory accounts `sudo`, and it doesn't touch your disk encryption password, which is separate from every account. It doesn't change the graphical login either: Omarchy still signs its own user in at boot.

## If something goes wrong

- **The setup can't find the domain.** Check that DNS points at a domain controller, and that the name is the domain's, like `example.corp`, not a computer's.
- **`id jean` says there is no such user** on a computer that did join. Run `omarchy-apply-sssd`, then try again.
- **Several wrong passwords in a row** can lock a directory account for the whole company, not just this computer. If a password is refused, stop and check it somewhere else before trying again.

To take the computer out of the domain, run `sudo realm leave example.corp`. Local accounts aren't touched.
