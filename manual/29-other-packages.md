# Other Packages

Arch has an amazing wealth of packages available for almost any type of software between the official repository and the Arch User Repository (AUR).

It couldn't be easier to use either. You install a new Arch package by going to _Install > Package_ in the Omarchy menu (`Super + Space`) and typing the package you want. It'll automatically fuzzy filter the list of all packages. (You can also do it manually using `omarchy pkg add [package]` in the terminal).

You can do the same with AUR, just use _Install > AUR_. Just remember that the AUR isn't vetted by the Arch team. It's like RubyGems or npm. Anyone can upload.

If you want to remove a package, you can use _Remove > Package_ from the Omarchy menu. It'll remove package, config files, and dependencies. (You can also do it manually using `omarchy pkg drop [package]`).

## Packages you compile yourself

Omarchy sets `makepkg` to compile packages for the CPU of your computer (`-march=native` and `-C target-cpu=native`). This applies to AUR packages and to all other packages that you compile with `makepkg`. These packages can operate faster. But they can fail to start on a computer with an older CPU.

CAUTION: Do not install these packages on other computers. The packages can stop with an "illegal instruction" error on a different CPU.

To use different flags, put them in `~/.config/pacman/makepkg.conf`. `makepkg` reads that file after the Omarchy flags in `/etc/makepkg.conf.d/zz-omarchy.conf`. For example, to compile for all x86-64 CPUs again:

```bash
CFLAGS=${CFLAGS/-march=native/-march=x86-64 -mtune=generic}
CXXFLAGS=${CXXFLAGS/-march=native/-march=x86-64 -mtune=generic}
RUSTFLAGS=${RUSTFLAGS/ -C target-cpu=native/}
FFLAGS=${FFLAGS/-march=native/-march=x86-64 -mtune=generic}
FCFLAGS=${FCFLAGS/-march=native/-march=x86-64 -mtune=generic}
```
