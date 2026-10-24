# Project workspaces

Save the tools you use for a project and reopen them together on a named workspace. Once a project has windows open, opening it again focuses that workspace instead of launching duplicates.

Create your first project:

```bash
omarchy project init shop ~/Work/shop
omarchy project open shop
```

The first command prints the recipe's path under `~/.config/omarchy/projects/` (or `$XDG_CONFIG_HOME/omarchy/projects/`). Edit that JSON file to choose your terminals and links:

```json
{
  "version": 1,
  "directory": "/home/you/Work/shop",
  "terminals": [
    [],
    ["omarchy-agent", "--inline"],
    ["npm", "run", "dev"]
  ],
  "urls": ["http://localhost:3000", "https://github.com/you/shop"]
}
```

Each terminal starts in the saved directory on the workspace `project-shop`. An empty array opens your default shell. Other arrays contain a command and its arguments; each argument stays literal. Executable paths such as `./bin/dev` are relative to the saved project directory. Use an explicit shell command such as `["bash", "-lc", "npm run dev && bash"]` if you want shell syntax. Commands and links are launched when you explicitly open a saved recipe; recipes in downloaded repositories are never discovered or executed automatically.

Browser links open through your default browser. An existing browser may reuse a window on another workspace; project workspaces do not move those windows or start separate browser profiles. Server terminals and browser links start independently, so reload a local page if its server is still starting.

Run `omarchy project` to choose a saved project, `omarchy project list` to list names, or `omarchy project show shop` to inspect a recipe. Use `omarchy project open shop --launch` to launch another copy of its tools on an occupied workspace. When all of its terminal windows close, opening the project launches the recipe again. This launches saved tools; it does not restore unsaved terminal state or documents.

`init` never overwrites a recipe. Names use lowercase letters, numbers, and hyphens. Remove a project by deleting its JSON file; that leaves its directory and running applications intact.
