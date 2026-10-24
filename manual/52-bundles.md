# Bundles

A bundle is a folder of data that describes one activity: the Arch packages to install, the shell plugins to add, the agent skills to link, a few config files to copy, and optionally a project layout. Installing a bundle copies that folder and follows the list. It does not run anything inside it.

```
omarchy bundle add ./web-developer
omarchy bundle list
omarchy bundle remove web-developer
omarchy bundle reset web-developer
```

`omarchy bundle add` takes a local folder or a git URL. A git URL is a development source: the command prints a development/unsafe source warning, then clones and validates. It is not a reviewed release. A name shaped like `publisher/name` or `publisher/name@version` is reserved for the plugin registry. The command recognizes it and stops with "registry not available yet". Signing, revocation, publishing, and search belong to that registry and are not part of this command.

Add `--dry-run` to print the plan and change nothing. Add `--yes` to skip the confirmation. Without a terminal, and without `--yes`, the command refuses to install or remove.

The Install menu has a Bundles row that asks for a path or URL. Remove has a Bundles row when at least one bundle is installed, and it lists them.

## The manifest

A bundle is a directory with `bundle.json` at the root. `omarchy bundle validate ./my-bundle` checks it before you install.

```json
{
  "schemaVersion": 1,
  "packageType": "bundle",
  "id": "web-developer",
  "name": "Web Developer",
  "version": "1.0.0",
  "description": "A local web project setup.",
  "packages": ["libyaml"],
  "aurPackages": [],
  "plugins": [],
  "skills": ["skills/web-setup"],
  "config": [{"source": "config/editorconfig", "target": "~/.config/omarchy-bundles/web-developer/editorconfig"}],
  "conflicts": ["other-bundle"],
  "project": {
    "root": "~/Work",
    "layout": ["src", "public"],
    "create": "project/create.sh"
  }
}
```

`schemaVersion` must be the number 1. `id`, `name`, `version`, and `description` are required strings. The id uses the same shape as a plugin id, and it cannot use the reserved `omarchy.*` namespace. Unknown top-level keys are rejected.

`packageType` is optional. When you set it, it must be `"bundle"`. That is the same idea as a theme package's `"packageType": "theme"`: a bundle is data, not a plugin, and a later registry can publish it beside plugins and themes without changing this file's shape. Themes already refuse executables, symlinks, and install hooks. A bundle follows that rule at install time: symlinks and special files are rejected, `packages` go through `omarchy-pkg-add` and `omarchy-pkg-drop`, `aurPackages` go through `omarchy-pkg-aur-add` and `omarchy-pkg-aur-drop`, and plugins go through `omarchy-plugin-add`. New plugins are enabled when you pass `--yes`. Otherwise the install asks once whether to enable them, and declining leaves them installed and disabled. No file from the bundle is executed.

| Field | Meaning |
| --- | --- |
| `packages` | Official Arch package names from core, extra, or multilib. Missing ones are installed with `omarchy-pkg-add`. Names already on the machine are left as they are. |
| `aurPackages` | AUR package names. Missing ones are installed with `omarchy-pkg-aur-add`. Removal uses `omarchy-pkg-aur-drop`. |
| `plugins` | A plugin git URL, or the id of a plugin that is already installed. A git URL is added with `omarchy-plugin-add`. `--yes` also passes `--enable`. An interactive install asks once whether to enable the new plugins. |
| `skills` | Folders inside the bundle. Each one contains a `SKILL.md`. |
| `config` | Files to copy. `source` is a relative path in the bundle. `target` is under your home directory, usually `~/...`. |
| `conflicts` | Bundle ids that may not be installed at the same time. |
| `project` | Optional. `root` defaults to `~/Work`. `layout` is folders to create. `create` is a script path, used only by `omarchy bundle project new`. |
| `introduction` | Optional path to a Markdown file in the bundle. After install, a notification says the bundle is installed. The click opens the file in Omawrite, floating in the center. |

Paths in the manifest are relative. `..` is rejected. Config targets cannot be absolute paths outside your home directory.

Examples live in `test/fixtures/bundles/` in the Omarchy repo. They are for trying the commands. They are not installed with Omarchy.

## Where it lands

The folder is copied to `~/.local/share/omarchy-bundles/<id>/`. On an installed system `~/.local/share/omarchy` is a symlink to `/usr/share/omarchy`, so the copy lives beside that link. The ledger is `~/.local/state/omarchy/bundles/ledger.json`. Writes go to a temporary file in that directory and then `mv`, so a crash mid-write does not leave a half-written ledger.

Each installed bundle has a receipt with the same field names as a registry install receipt where they mean the same thing:

| Field | Meaning |
| --- | --- |
| `source` | The folder path or git URL you gave |
| `version` | The manifest version |
| `sha256` | Checksum of the files that were copied |
| `commit` | Git commit, when the source was a git URL. Otherwise null |
| `installed_at` | UTC time the bundle was installed |

The ledger also records, for every package, plugin, skill link, and config file, which bundle ids own it and whether it was yours before any bundle owned it. A package counts as yours when it was already listed by `pacman -Qqe` (explicitly installed, not pulled in as a dependency). A file or link counts as yours when it already existed. A config file the bundle copies is checksummed at install. Removing it later compares that checksum to the file on disk.

Installing prints a plan of what is new and what is already present, then asks. It installs missing packages first, then plugins, then skill links and config files. Removing drops this bundle's ownership, prints a plan, and asks. Something is deleted only when no remaining bundle owns it and it was not yours. A copied config file is also left in place when the bytes no longer match the checksum, which is how an edit you made after install survives remove. Packages are removed with `omarchy-pkg-drop` after that check. Plugins are removed with `omarchy-plugin-remove` after that check. Your own packages and files stay.

A later `omarchy bundle add` of the same bundle sees that live file and leaves it. `omarchy bundle reset <id>` writes the config files from the installed bundle over those targets. A live file that differs is moved to `<target>.bak.<timestamp>` first. After a reset, the live file is the bundle's copy again, so a later remove will delete it if you have not edited it.

When `introduction` is set, a successful install sends a notification. The headline is `Bundle <name> installed` and the body is `Click to see the introduction.` The click opens that file in [Omawrite](https://github.com/omacom-io/omawrite), floating in the center of the screen. Install does not run the file.

## Skills

Skill folders are linked into the agent skill directories that already exist, the same ones `omarchy-provision-user` fills: `~/.agents/skills`, `~/.claude/skills`, `~/.codex/skills`, `~/.pi/agent/skills`, `~/.gemini/config/skills`, and `~/.hermes/skills`, plus an existing Hermes profile `skills` directory. The link name is `<bundle-id>-<skill-folder>`. Directories that are not there yet are skipped. The links are recorded in the ledger and removed with the bundle when nothing else owns them.

## Projects

```
omarchy bundle project new web-developer my-site
```

This creates `~/Work/my-site` (or the bundle's `project.root`), the layout folders, and a `.omarchy-project` file recording the bundle id, version, and the time it was created. It then prints the create script. In a terminal it asks before running it. The script's working directory is the new project folder, and `PROJECT_DIR` and `BUNDLE_DIR` are set. Anywhere else, or if you say no, the folders and the marker stay and the script does not run.

## Registry, later

A bundle is meant to be a third package type next to `plugin` and `theme`: data only, `schemaVersion` 1, an id and a version, installed from `publisher/name@version` once the registry can serve it. Until then the client stores a local receipt in the ledger and leaves signing, yank, revocation, and the directory website alone.
