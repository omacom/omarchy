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

## Preinstalled CLI tools

Omarchy makes tools such as `gh`, `uv`, and most [coding agents](17-ai.md) available through [mise's lazy installation](https://mise.jdx.dev/dev-tools/shims.html#lazy-tools). The first time you run one, mise installs it. Later runs reuse the installed version; they do not check for an update on every launch.

You can also inspect the defaults or install them ahead of time:

```bash
mise ls --current              # List the tools configured for this directory
mise install gh               # Install one tool now
mise install --include-lazy    # Install all configured tools, including lazy tools
```

Run `omarchy update` to update installed tools with the rest of Omarchy. The `mup` alias updates mise-managed tools only. To add another tool to your own configuration, use `mise use -g <tool>`.

Python setup also installs `uv` through mise. Removing the Python development environment leaves `uv` available as an independent tool.

### Using your own installation

To use a separately installed tool, disable mise's copy in `~/.config/mise/config.toml`. For example, if you installed Cursor CLI yourself:

```toml
[settings]
disable_tools = ["cursor-agent"]
```

If you already have a `[settings]` table, add the entry there; extend an existing `disable_tools` list rather than replacing it. Make sure your installation is on `PATH`. Use the mise tool name, which can differ from its command: `oh-my-pi` provides `omp`, for example. The default-agent launcher also prefers a user-installed Cursor or Muse in `~/.local/bin`.

### Removing and restoring defaults

_Remove Preinstalls_ removes the default lazy-tool configuration, and _Restore Preinstalls_ restores it. This configuration is shared by all users, so removing or restoring it affects the defaults for everyone on the machine. To disable only selected tools for yourself, use `disable_tools` instead.

## Docker

[Docker](https://www.docker.com/) hardly needs any introduction. It allows you to run isolated containers, and Omarchy installs everything needed to run it well, including Docker itself and [Docker Compose](https://docs.docker.com/compose/).

By default your user is *not* in the `docker` group. That group is effectively passwordless root — anything in it can `docker run -v /:/host` and take over the machine — so a single rogue script or dependency running as you would otherwise be one command away from root. So on the command line you run Docker with `sudo` (`sudo docker ps`, `sudo docker compose up`), and the graphical tools that talk to the daemon — the Docker TUI on `Super + Shift + D` and the Windows VM — ask for authorization when they need it. If you want the convenience of a groupless setup back and understand the tradeoff, enable it from **Setup > Security > Sudoless Docker** (or run `omarchy-setup-security-sudoless-docker`), which adds you to the `docker` group after a warning; then plain `docker` and the `d` alias work without `sudo` again.

Remember to checkout the Lazydocker command to manage your containers in a cool TUI using `Super + Shift + D`; it asks for authorization the first time unless you have enabled sudoless Docker.

You can setup the common databases for local development in Docker using _Install > Development > Docker DB_ in the Omarchy menu.

## GitHub CLI

[GitHub CLI](https://cli.github.com/) is available as `gh` for working with repositories, issues, and pull requests from the terminal. Run `gh auth login` to install it on first use and authenticate, then `gh repo clone org/repo` to clone a repository. Run `gh --help` to explore its commands.

For a terminal interface to pull requests, run `ghui`; mise installs it on first use too. [Lazygit](https://github.com/jesseduffield/lazygit) is preinstalled for working with Git itself.
