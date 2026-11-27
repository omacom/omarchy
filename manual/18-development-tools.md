# Development Tools

## Alternative Editors

Omarchy ships with Plain as the default editor on new installs and [Neovim](https://neovim.io/) preinstalled, but if you'd like something a bit more mainstream and familiar, you can run the Omarchy Menu (`Super + Space`) and see the options under _Install > Editor_. We have VSCode, Cursor, Zed, Sublime Text, Helix, Vim, and Emacs listed there. If you don't find what you're looking for, checkout _Install > Package_, and see if it isn't in an Arch package (and if not, try _Install > AUR_ to check the AUR).

The original `vi` editor is also available out of the box. Run `vi filename` to edit a file in the terminal.

Theme matching is offered for `VSCode`, `Cursor`, `VSCodium`, and `Helix`.

You can set the system-wide default editor under `Setup > Defaults > Editor`.

## Environment

Omarchy supports setting up a whole host of development environments through the _Install > Development_ section of the Omarchy Menu (`Super + Space`). You'll of course find _Ruby on Rails_, but also all three major runtimes for JavaScript (Node.js, Bun, Deno), as well as popular PHP frameworks like Laravel and Symfony. Oh, and there's Go, Rust, Python, Java, Elixir (with Phoenix), .NET, OCaml, Zig, Clojure, and Scala too. It's a very broad selection!

The majority of these environments are managed by [Mise](https://mise.jdx.dev/). It's a tool that lets you install and run multiple versions of a programming language on the same machine. It's like rbenv or rvm for Ruby or virtualenv for Python, but it works for a bunch of different environments.

To install, say, Ruby, you'd run `mise use -g ruby`, which will both install Ruby and set it as the global default. Or, if your project has a .ruby-version file, you can just run `mise i` in the root of that project.

## Preinstalled CLI tools

`uv`, Node.js, and `playwright-cli` (for agents to drive a browser, using the installed Chrome) come installed as packages, and `omarchy update` keeps them current with the rest of the system. [Hunk](https://github.com/modem-dev/hunk) and the GitHub, Basecamp, Cloudflare and HEY CLIs are a pick away under _Install > CLI_, and [coding agents](17-ai.md) under _Install > AI > CLI_.

mise only manages the runtimes you set up from _Install > Development_; Omarchy installs nothing through it on its own. Run `omarchy update` to update them with the rest of Omarchy; the `mup` alias updates mise-managed tools only. To add another tool to your own configuration, use `mise use -g <tool>`.

## Docker

[Docker](https://www.docker.com/) hardly needs any introduction. It allows you to run isolated containers, and Omarchy installs everything needed to run it well, including Docker itself and [Docker Compose](https://docs.docker.com/compose/).

By default your user is *not* in the `docker` group. That group is effectively passwordless root — anything in it can `docker run -v /:/host` and take over the machine — so a single rogue script or dependency running as you would otherwise be one command away from root. So on the command line you run Docker with `sudo` (`sudo docker ps`, `sudo docker compose up`), and the graphical tools that talk to the daemon — the Windows VM — ask for authorization when they need it. If you want the convenience of a groupless setup back and understand the tradeoff, enable it from **Setup > Security > Sudoless Docker** (or run `omarchy-setup-security-sudoless-docker`), which adds you to the `docker` group after a warning; then plain `docker` and the `d` alias work without `sudo` again.

You can setup the common databases for local development in Docker using _Install > Development > Docker DB_ in the Omarchy menu.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) is `gh`, for working with repositories, issues, and pull requests from the terminal. _Setup > Git_ installs it when you choose to sign in to GitHub there, or install it on its own from _Install > CLI > GitHub_. Then `gh repo clone org/repo` clones a repository; run `gh --help` to explore its commands.

[Lazygit](https://github.com/jesseduffield/lazygit) is preinstalled for working with Git itself.
