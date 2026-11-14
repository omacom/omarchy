[`pacman`](https://wiki.archlinux.org/index.php/pacman) defines subcommands via flags.

Here, `-S` is a short flag subcommand:
```console
$ pacman -S package
Installing package...

```

Here `--sync` is a long flag subcommand:
```console
$ pacman --sync package
Installing package...

```

Now the short flag subcommand (`-S`) with a long flag:
```console
$ pacman -S --search name
Searching for name...

```

And the various forms of short flags that work:
```console
$ pacman -S -s name
Searching for name...

$ pacman -Ss name
Searching for name...

```
*(users can "stack" short subcommands with short flags or with other short flag subcommands)*

In the help, this looks like:
```console
$ pacman -h
package manager utility

Usage: pacman[EXE] <COMMAND>

Commands:
  query, -Q, --query  Query the package database.
  sync, -S, --sync    Synchronize packages.
  help                Print this message or the help of the given subcommand(s)

Options:
  -h, --help     Print help
  -V, --version  Print version

$ pacman -S -h
Synchronize packages.

Usage: pacman[EXE] {sync|--sync|-S} [OPTIONS] [package]...

Arguments:
  [package]...  packages

Options:
  -s, --search <search>...  search remote repositories for matching strings
  -i, --info                view package information
  -h, --help                Print help

```

And errors:
```console
$ pacman -S -s foo -i bar
? failed
error: the argument '--search <search>...' cannot be used with '--info'

Usage: pacman[EXE] {sync|--sync|-S} --search <search>... <package>...

For more information, try '--help'.

```

<div class="warning">

**NOTE:** Keep in mind that subcommands, flags, and long flags are *case sensitive*: `-Q` and `-q` are different flags/subcommands. For example, you can have both `-Q` subcommand and `-q` flag, and they will be properly disambiguated.
Let's make a quick program to illustrate.

</div>

## Reviewing help output

The test renders every command's long help.
Each Markdown heading contains the complete command path.
Generated `help` subcommands are skipped.
`term_width(0)` prevents terminal-dependent wrapping.

[`snapbox`](https://docs.rs/snapbox) compares this output with a snapshot.
The resulting diff makes CLI changes easy to review.
Set `SNAPSHOTS=overwrite` to accept intentional changes.
