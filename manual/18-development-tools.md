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

## Podman

[Podman](https://podman.io/) runs containers without a root daemon. Use `podman run`, `podman build`, and `podman compose up`; the `d` alias also runs Podman. Compose uses the installed Podman Compose provider. Press `Super + Shift + D` for [Podman TUI](https://github.com/containers/podman-tui), the terminal interface for containers, pods, images, volumes, and networks. You can also launch it with `omarchy launch podman-tui`. [Podman Desktop](https://podman-desktop.io/) remains available from the application launcher or `omarchy launch podman` for graphical management.

Development containers run as your user. You do not need sudo or membership in a privileged group. Container images and volumes belong to your account; `sudo podman` has a separate store. The Windows VM uses that root-owned store and asks for authorization when needed.

### Database services

Install common development databases from _Install > Development > Podman DB_ or run `omarchy install podman-dbs Redis PostgreSQL`. New databases use [Quadlet](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html), which gives each database a systemd user service and a persistent named Podman volume. Ports bind to localhost. Redis enables append-only persistence. The development credentials and authentication settings are intended for local development.

For Redis, use:

```bash
systemctl --user status omarchy-db-redis.service
systemctl --user restart omarchy-db-redis.service
systemctl --user stop omarchy-db-redis.service
journalctl --user -u omarchy-db-redis.service
```

Services start when your user manager starts, normally at login. Stopping a service stops it for the current session; use `systemctl --user mask --now omarchy-db-redis.service` to keep it stopped across logins, and `systemctl --user unmask omarchy-db-redis.service` followed by `systemctl --user start omarchy-db-redis.service` to restore it. To keep services running after logout, enable lingering deliberately with `sudo loginctl enable-linger "$USER"`.

Definitions live under `~/.config/containers/systemd/` (or `$XDG_CONFIG_HOME/containers/systemd/` when configured). The container names are `omarchy-db-mysql8`, `omarchy-db-postgres18`, `omarchy-db-mariadb11`, `omarchy-db-redis`, `omarchy-db-mongodb`, and `omarchy-db-mssql`; their service names add `.service`, and their data volumes add `-data`. Manage their lifecycle through systemd; Podman TUI can inspect the containers and logs. Service restarts recreate the container while retaining its named volume. Changes outside the mounted database data directory are disposable.

The installer preserves existing definitions, containers, and volumes and refuses conflicts. It does not convert migrated databases to a new image or service definition. Migrated containers retain their previous restart policies and resume through `podman-restart.service`; continue managing those with Podman until you explicitly transfer them. To remove a new database service, stop it, remove its `.container` and `-data.volume` definitions and its matching drop-in directory under `~/.config/systemd/user/` (or `$XDG_CONFIG_HOME/systemd/user/`), then run `systemctl --user daemon-reload`. The data volume remains until you explicitly remove it with `podman volume rm`.

### Docker compatibility

Omarchy's container commands and database services use Podman directly. Fresh installations do not include the `docker` command. Add it from _Install > Development > Docker Compatibility_ or with `omarchy install docker-compat`. The optional `podman-docker` package provides commands such as `docker ps`, `docker build`, and `docker compose up`. Docker Engine is not installed; compatibility follows Podman's supported commands and Compose options. The installer refuses to replace an existing Docker engine before migration.

Upgrades from Docker retain this layer to preserve existing scripts and satisfy installed packages that depend on `docker`. To remove it, run `omarchy remove docker-compat`; package dependencies may require keeping it. Native Podman and its containers remain available. Log out and back in after changing compatibility to refresh terminal and application environments.

With compatibility installed, Docker SDK clients in the desktop session use the rootless socket through `DOCKER_HOST`. An explicitly configured endpoint is preserved. For an SSH session or a tool with its own environment, set `DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock` as needed. Native CLI and Quadlet operations do not require this compatibility API; TUI, Desktop, and API clients use the socket-activated Podman service.


## GitHub CLI

[The GitHub CLI](https://cli.github.com/) let's you authenticate with your GitHub account and clone private repositories using it. It's wired up as one of the lazy-loading mise stubs, so the first time you run `gh`, it installs itself. To authenticate, run `gh auth login`. Then you can checkout private repositories using `gh repo clone org/repo`.

You can also perform a bunch of other GitHub operations using this command. Just run `gh` to see everything that's possible.

There's a lazy-installing stub for `ghui` for managing your pull requests in a TUI too. And [lazygit](https://github.com/jesseduffield/lazygit) is preinstalled, if you'd like to drive git itself from a TUI as well.

## Moving existing containers

During the update, Omarchy moves compatible unprivileged containers, including its development databases, into the Podman store of the account running the update. It stops each container, snapshots its image and writable layer, transfers and verifies volume contents, numeric ownership, permissions, timestamps, ACLs and extended attributes, and restores its previous running state in Podman. Windows keeps its existing virtual disk and shared folder. The old Docker data stays on disk as a recovery copy. Restart when the updater asks to clear Docker's temporary networking state.

Ordinary containers can migrate automatically regardless of their name or image when they use the default bridge, localhost ports, private local volumes and supported resource limits. Simple named volumes retain their names; CPU, memory, PID and shared-memory limits and restrictive security settings are preserved and checked before the application starts.

Privileged containers, GPUs and other devices, host-directory or socket mounts, custom networks, shared volumes and unsupported settings need an explicit transfer using the project's own configuration. The migration identifies these before stopping workloads and stays pending until they are moved. Back up the application data, recreate the project using `podman-compose`, verify its data and behavior, then remove the old Docker containers and retry the update. Docker is removed only after the remaining workloads have moved successfully.

The automatic transfer stays rootless and uses only the local engines. It never silently retries with sudo, grants additional capabilities, disables confinement or weakens host permissions to make a container start. It does not transfer every cached image, unused volume, GPU worker, CI runner, or persistent BuildKit builder. A familiar database name does not make a custom configuration safe to migrate automatically.

For a custom transfer, inventory all containers, images, volumes and networks first, including stopped containers and unattached volumes. Keep the original image versions and writable layers, mount options, health checks, resource limits, network aliases, and running/stopped state. Transfer volume contents only while their writers are stopped; preserve and verify metadata as well as file contents. Do not let a newer project Compose file implicitly upgrade an old database's major version.

Privileged Docker-in-Docker runners may need rootful Podman; rootless and rootful stores are separate. NVIDIA workloads require the NVIDIA Container Toolkit's CDI devices and a real GPU test. A persistent BuildKit daemon can use the optional `buildkit` client through `sudo buildctl --addr=podman-container://CONTAINER ...`; Podman's `buildx` compatibility does not cover every Docker Buildx workflow. Enable startup for these custom services deliberately and verify it after reboot.

Retained Docker data is a recovery checkpoint, not a synchronized backup. After Podman accepts new writes, preserve those writes before rolling back. Root filesystem snapshots may exclude your home directory and its rootless containers. Keep application backups and recovery copies until you have verified the migrated workloads and reboot behavior.
