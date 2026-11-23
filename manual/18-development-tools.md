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

`gh`, `uv`, `hunk`, `ghui`, and the `basecamp` and `hey` CLIs come installed as packages, and `omarchy update` keeps them current with the rest of the system. [Coding agents](17-ai.md) are packages too, installed the first time you pick one.

mise keeps the language runtimes and the tools that run on them: Omarchy declares Node.js, Playwright, and Cloudflare's `cf` there, each installed the first time you run it. Run `omarchy update` to update them with the rest of Omarchy; the `mup` alias updates mise-managed tools only. To add another tool to your own configuration, use `mise use -g <tool>`.

### Removing and restoring defaults

_Remove > Preinstalls_ removes Omarchy's preinstalled web apps, TUIs and apps, and has mise skip Omarchy's tool declarations for your user, by adding them to `ignored_config_paths` in `~/.config/mise/miserc.toml`. _Install > Preinstalls_ brings them back and removes that line again. Tools you declare yourself, in your own config or in a project's `mise.toml`, keep working either way. The mise setting applies only to your user, and other users keep their own choice; the apps are packages, though, so removing or restoring them changes them for everyone on the machine.

## Docker

[Docker](https://www.docker.com/) hardly needs any introduction. It allows you to run isolated containers, and Omarchy installs everything needed to run it well, including Docker itself and [Docker Compose](https://docs.docker.com/compose/).

By default your user is *not* in the `docker` group. That group is effectively passwordless root — anything in it can `docker run -v /:/host` and take over the machine — so a single rogue script or dependency running as you would otherwise be one command away from root. So on the command line you run Docker with `sudo` (`sudo docker ps`, `sudo docker compose up`), and the graphical tools that talk to the daemon — the Windows VM — ask for authorization when they need it. If you want the convenience of a groupless setup back and understand the tradeoff, enable it from **Setup > Security > Sudoless Docker** (or run `omarchy-setup-security-sudoless-docker`), which adds you to the `docker` group after a warning; then plain `docker` and the `d` alias work without `sudo` again.

You can setup the common databases for local development in Docker using _Install > Development > Docker DB_ in the Omarchy menu.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) is available as `gh` for working with repositories, issues, and pull requests from the terminal. Run `gh auth login` to authenticate, then `gh repo clone org/repo` to clone a repository. Run `gh --help` to explore its commands.

For a terminal interface to pull requests, run `ghui`. [Lazygit](https://github.com/jesseduffield/lazygit) is preinstalled for working with Git itself.
