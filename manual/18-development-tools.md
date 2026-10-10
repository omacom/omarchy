# Development Tools

## Alternative Editors

Omarchy ships with [Neovim](https://neovim.io/) by default, but if you'd like something a bit more mainstream and familiar, you can run the Omarchy Menu (`Super + Space`) and see the options under _Install > Editor_. We have VSCode, Cursor, Zed, Sublime Text, Helix, Vim, and Emacs listed there. If you don't find what you're looking for, checkout _Install > Package_, and see if it isn't in an Arch package (and if not, try _Install > AUR_ to check the AUR).

The original `vi` editor is also available out of the box. Run `vi filename` to edit a file in the terminal.

Theme matching is offered for `VSCode`, `Cursor`, `VSCodium`, and `Helix`.

You can set the system-wide default editor under `Setup > Defaults > Editor`.

## Environment

Omarchy supports setting up a whole host of development environments through the _Install > Development_ section of the Omarchy Menu (`Super + Space`). You'll of course find _Ruby on Rails_, but also all three major runtimes for JavaScript (Node.js, Bun, Deno), as well as popular PHP frameworks like Laravel and Symfony. Oh, and there's Go, Rust, Python, Java, Elixir (with Phoenix), .NET, OCaml, Zig, Clojure, and Scala too. It's a very broad selection!

The majority of these environments are managed by [Mise](https://mise.jdx.dev/). It's a tool that lets you install and run multiple versions of a programming language on the same machine. It's like rbenv or rvm for Ruby or virtualenv for Python, but it works for a bunch of different environments.

To install, say, Ruby, you'd run `mise use -g ruby`, which will both install Ruby and set it as the global default. Or, if your project has a .ruby-version file, you can just run `mise i` in the root of that project.

## Docker

[Docker](https://www.docker.com/) hardly needs any introduction. It allows you to run isolated containers, and Omarchy installs everything needed to run it well, including Docker itself and [Docker Compose](https://docs.docker.com/compose/).

By default your user is *not* in the `docker` group. That group is effectively passwordless root — anything in it can `docker run -v /:/host` and take over the machine — so a single rogue script or dependency running as you would otherwise be one command away from root. So on the command line you run Docker with `sudo` (`sudo docker ps`, `sudo docker compose up`), and the graphical tools that talk to the daemon — the Windows VM — ask for authorization when they need it. If you want the convenience of a groupless setup back and understand the tradeoff, enable it from **Setup > Security > Sudoless Docker** (or run `omarchy-setup-security-sudoless-docker`), which adds you to the `docker` group after a warning; then plain `docker` and the `d` alias work without `sudo` again.

You can setup the common databases for local development in Docker using _Install > Development > Docker DB_ in the Omarchy menu.

Published ports default to localhost on the default bridge and newly created bridge networks. For example, `sudo docker run -p 8080:80 ...` is reachable from your own computer. To deliberately share a service on your network, name the listening address, such as `-p 0.0.0.0:8080:80`. Private-address networks are trusted by the Docker firewall integration, so an explicit public binding can also be reachable by other people on shared Wi-Fi. Keep authentication enabled on services you share.

The default applies after Docker next starts. Existing containers keep their published addresses, and existing bridge networks keep their options; inspect them before assuming an upgrade has made a running service private. Recreate the containers and, where appropriate, their networks with the intended binding. An explicit `127.0.0.1:8080:80` mapping works for an existing network too. If you customized `/etc/docker/daemon.json`, review the packaged `.pacnew` settings rather than replacing your configuration.

## GitHub CLI

[The GitHub CLI](https://cli.github.com/) let's you authenticate with your GitHub account and clone private repositories using it. It's wired up as one of the lazy-loading mise stubs, so the first time you run `gh`, it installs itself. To authenticate, run `gh auth login`. Then you can checkout private repositories using `gh repo clone org/repo`.

You can also perform a bunch of other GitHub operations using this command. Just run `gh` to see everything that's possible.

There's a lazy-installing stub for `ghui` for managing your pull requests in a TUI too. And [lazygit](https://github.com/jesseduffield/lazygit) is preinstalled, if you'd like to drive git itself from a TUI as well.
