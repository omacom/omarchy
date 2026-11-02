# Other Packages

Arch has an amazing wealth of packages available for almost any type of software between the official repository and the Arch User Repository (AUR).

It couldn't be easier to use either. You install a new Arch package by going to _Install > Package_ in the Omarchy menu (`Super + Space`) and typing the package you want. It'll automatically fuzzy filter the list of all packages. (You can also do it manually using `omarchy pkg add [package]` in the terminal).

You can also install an Arch package group, such as `omarchy pkg add lv2-plugins`. The command checks that every group member is installed before reporting success. Members that are already up to date are skipped by pacman.

You can do the same with AUR, just use _Install > AUR_. Just remember that the AUR isn't vetted by the Arch team. It's like RubyGems or npm. Anyone can upload.

If you want to remove a package, you can use _Remove > Package_ from the Omarchy menu. It'll remove package, config files, and dependencies. (You can also do it manually using `omarchy pkg drop [package]`).
