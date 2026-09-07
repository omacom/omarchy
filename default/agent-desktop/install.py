#!/usr/bin/env python3
"""Install an optional, per-user agent desktop runtime."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import secrets
import socket
import shutil
import subprocess
import tempfile
import time

SOURCE = Path(__file__).resolve().parent
MARKER = "# Managed by agent-desktop install.py"
HOOK = 'require("hypr.agent-desktop")'


def run(*args, **kwargs):
    return subprocess.run(args, check=True, text=True, **kwargs)


def check_owned(path, previous):
    if path.is_symlink():
        raise RuntimeError(f"Refusing to replace symlink: {path}")
    if path.exists() and previous.get(str(path)) != hashlib.sha256(path.read_bytes()).hexdigest():
        raise RuntimeError(f"Existing or modified file: {path}. Preserve it before installing.")


def configuration(home, runtime, node, port, monitor):
    state = home / ".local/share/hypr-desktop"
    # systemd expands percent specifiers and dollar variables even inside quotes.
    def unit_quote(value):
        return '"' + str(value).replace('\\', '\\\\').replace('"', '\\"').replace('%', '%%').replace('$', '$$') + '"'
    rule = '-- Managed by agent-desktop install.py\nhl.window_rule({\n  match = { class = "^aquamarine$", title = "^aquamarine - WAYLAND-1$" },\n  no_initial_focus = true,\n'
    if monitor:
        rule += f'  monitor = {json.dumps(monitor + " silent")},\n'
    rule += '})\n'
    service = f'''{MARKER}
[Unit]
Description=Agent desktop MCP on loopback
After=graphical-session.target
PartOf=graphical-session.target

[Service]
Type=simple
Environment=HYPR_DESKTOP_PORT={port}
ExecStart={unit_quote(node)} {unit_quote(runtime / 'mcp/index.js')}
Restart=on-failure
RestartSec=3

[Install]
WantedBy=graphical-session.target
'''
    return {
        home / ".config/hypr/agent-desktop.lua": rule,
        home / ".config/systemd/user/hypr-desktop.service": service,
        state / "url": f"http://127.0.0.1:{port}/mcp\n",
        state / "local-url": f"http://127.0.0.1:{port}/mcp\n",
    }


def install(home, source, port, monitor, start):
    state = home / ".local/share/hypr-desktop"
    manifest = state / "installation.json"
    previous = json.loads(manifest.read_text()) if manifest.exists() else {}
    root = home / ".local/share/agent-desktop"
    runtime = root / "package"
    node = shutil.which("node")
    if not node:
        raise RuntimeError("Node.js 20 or later is required")
    major = int(run(node, '-p', 'process.versions.node.split(".")[0]', capture_output=True).stdout)
    if major < 20:
        raise RuntimeError("Node.js 20 or later is required")
    config = home / ".config/hypr/hyprland.lua"
    if not config.is_file():
        raise RuntimeError("A Lua-based Hyprland configuration is required")
    config_target = config.resolve()
    original_config = config_target.read_text()
    files = configuration(home, runtime, node, port, monitor)
    for path, content in files.items():
        check_owned(path, previous.get("files", {}))
    links = {
        home / ".local/bin/agent-desktop": runtime / "bin/agent-desktop",
        home / ".codex/skills/agent-desktop": runtime / "skill",
        home / ".claude/skills/agent-desktop": runtime / "skill",
    }
    for link, target in links.items():
        if link.exists() or link.is_symlink():
            if not link.is_symlink() or link.readlink() != target:
                raise RuntimeError(f"Existing installation at {link}; refusing to replace it")
    if runtime.exists() and previous.get("runtime") != str(runtime):
        raise RuntimeError(f"Unmanaged runtime at {runtime}")
    if runtime.exists() and not start:
        raise RuntimeError("--no-start is for first-time staging; use a normal install to update a runtime")
    if runtime.is_symlink():
        raise RuntimeError(f"Refusing symlink runtime: {runtime}")
    if state.exists() and not manifest.exists():
        raise RuntimeError(f"Existing MCP state at {state}; migrate that installation explicitly")
    if start:
        for name in ('Hyprland', 'hyprctl', 'jq', 'wtype', 'wlrctl', 'grim', 'Xwayland', 'notify-send', 'systemd-run'):
            if not shutil.which(name):
                raise RuntimeError(f"Missing runtime dependency: {name}")
        if monitor:
            monitors = json.loads(run('hyprctl', '-j', 'monitors', capture_output=True).stdout)
            if monitor not in {m['name'] for m in monitors}:
                raise RuntimeError(f"Monitor is not connected: {monitor}")
        if not previous:
            with socket.socket() as probe:
                probe.bind(('127.0.0.1', port))
        active = run('systemctl', '--user', 'list-units', '--state=active,activating', '--no-legend', 'agent-desktop-*.service', capture_output=True).stdout
        if active.strip():
            raise RuntimeError("Release active agent desktops before updating their runtime")
        if 'hypr-desktop.service' in Path('/proc/self/cgroup').read_text():
            raise RuntimeError("Run the installer from a terminal outside hypr-desktop.service")
        errors = run('hyprctl', 'configerrors', capture_output=True).stdout.strip()
        if errors:
            raise RuntimeError(f"Fix existing Hyprland configuration errors first: {errors}")
    root.mkdir(parents=True, exist_ok=True)
    staged = Path(tempfile.mkdtemp(prefix='package-', dir=root))
    backup = root / f"previous-{secrets.token_hex(4)}"
    saved = {path: path.read_bytes() if path.exists() else None for path in files}
    added_links = []
    was_active = False
    was_enabled = False
    token_created = False
    swapped = False
    try:
        for name in ('bin', 'config', 'mcp', 'skill'):
            shutil.copytree(source / name, staged / name, ignore=shutil.ignore_patterns('node_modules', '__pycache__'))
        for name in ('README.md', 'LICENSE'):
            shutil.copy2(source / name, staged / name)
        run('npm', 'ci', '--omit=dev', '--ignore-scripts', '--no-audit', '--no-fund', cwd=staged / 'mcp')
        if start:
            was_enabled = subprocess.run(['systemctl', '--user', 'is-enabled', '--quiet', 'hypr-desktop.service']).returncode == 0
            was_active = subprocess.run(['systemctl', '--user', 'is-active', '--quiet', 'hypr-desktop.service']).returncode == 0
            if was_active:
                run('systemctl', '--user', 'stop', 'hypr-desktop.service')
        if runtime.exists():
            runtime.rename(backup)
        staged.rename(runtime)
        swapped = True
        state.mkdir(parents=True, exist_ok=True, mode=0o700)
        state.chmod(0o700)
        token = state / 'token'
        if not token.exists():
            fd = os.open(token, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
            with os.fdopen(fd, 'w') as f:
                f.write(secrets.token_hex(32) + '\n')
            token_created = True
        for path, content in files.items():
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(content)
        for link, target in links.items():
            link.parent.mkdir(parents=True, exist_ok=True)
            if not link.is_symlink():
                link.symlink_to(target)
                added_links.append(link)
        if HOOK not in original_config.splitlines():
            config_target.write_text(original_config + ('\n' if not original_config.endswith('\n') else '') + '\n' + HOOK + '\n')
        if start:
            run('hyprctl', 'reload')
            errors = run('hyprctl', 'configerrors', capture_output=True).stdout.strip()
            if errors:
                raise RuntimeError(f"Hyprland rejected the rule: {errors}")
            run('systemctl', '--user', 'daemon-reload')
            run('systemctl', '--user', 'enable', '--now', 'hypr-desktop.service')
            for attempt in range(20):
                status = subprocess.run([str(runtime / 'bin/agent-desktop'), 'tool', 'status', '{}'], capture_output=True, text=True, timeout=10)
                if status.returncode == 0:
                    break
                time.sleep(.5)
            else:
                raise RuntimeError(f"MCP status failed: {status.stderr}")
        manifest_temp = manifest.with_suffix('.tmp')
        manifest_temp.write_text(json.dumps({
            'runtime': str(runtime),
            'files': {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in files},
        }, indent=2) + '\n')
        manifest_temp.replace(manifest)
    except Exception:
        if swapped:
            if start:
                subprocess.run(['systemctl', '--user', 'stop', 'hypr-desktop.service'], check=False)
                if not was_enabled:
                    subprocess.run(['systemctl', '--user', 'disable', 'hypr-desktop.service'], check=False)
            for path, content in saved.items():
                if content is None:
                    path.unlink(missing_ok=True)
                else:
                    path.write_bytes(content)
            if token_created:
                (state / 'token').unlink()
            if not previous and state.exists() and not any(state.iterdir()):
                state.rmdir()
            for link in added_links:
                link.unlink()
            config_target.write_text(original_config)
            # Keep the failed runtime for diagnosis; restore the previous copy.
            runtime.rename(root / f"failed-{secrets.token_hex(4)}")
            if backup.exists():
                backup.rename(runtime)
            if start:
                subprocess.run(['hyprctl', 'reload'], check=False)
                subprocess.run(['systemctl', '--user', 'daemon-reload'], check=False)
                if was_active:
                    subprocess.run(['systemctl', '--user', 'start', 'hypr-desktop.service'], check=False)
        raise
    finally:
        if staged.exists():
            shutil.rmtree(staged)
    if backup.exists():
        print(f"Previous runtime retained at {backup}")
    print('Agent desktop installed' if start else 'Files installed; service and Hyprland reload skipped (--no-start)')
    print(f'Native MCP registration examples: {source / "README.md"}')
    print('The bundled skill can use agent-desktop tool immediately; restart agents to discover the skill.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--monitor', help='Hyprland output name; default uses normal placement without initial focus')
    parser.add_argument('--port', type=int, default=7873)
    parser.add_argument('--no-start', action='store_true', help='install files without reloading Hyprland or enabling/starting the service')
    args = parser.parse_args()
    if not 1024 <= args.port <= 65535:
        parser.error('port must be between 1024 and 65535')
    if args.monitor and not all(c.isalnum() or c in '-_.' for c in args.monitor):
        parser.error('monitor must be an output name such as DP-1')
    try:
        install(Path.home(), SOURCE, args.port, args.monitor, not args.no_start)
    except (RuntimeError, OSError, subprocess.SubprocessError) as error:
        parser.exit(1, f'agent-desktop: {error}\n')


if __name__ == '__main__':
    main()
