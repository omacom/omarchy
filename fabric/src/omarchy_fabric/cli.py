"""ofab: the omarchy-fabric command line.

    ofab serve                         run the fabric daemon
    ofab mcp --agent claude-code       MCP server for an agent (stdio)
    ofab console                       desktop notifications + bar status
    ofab things | get | describe | do | simulate
    ofab approvals | approve | deny | freeze | thaw
    ofab events [-f] | audit verify | audit tail
    ofab sim human sim:entrance.front_door lock_state=unlocked
"""

from __future__ import annotations

import argparse
import asyncio
import json
import logging
import os
import signal
import sys
from typing import Any

from . import __version__
from . import config as config_mod
from .rpc import RpcClient, RpcError


def _value(text: str) -> Any:
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        return text


def _kv(pairs: list[str]) -> dict[str, Any]:
    out = {}
    for pair in pairs:
        if "=" not in pair:
            raise SystemExit(f"ofab: expected key=value, got {pair!r}")
        key, _, value = pair.partition("=")
        out[key] = _value(value)
    return out


def _print(obj: Any, as_json: bool) -> None:
    if as_json or not isinstance(obj, (dict, list)):
        print(json.dumps(obj, indent=2, default=str, ensure_ascii=False))
        return
    print(json.dumps(obj, indent=2, default=str, ensure_ascii=False))


def _table(rows: list[list[str]], headers: list[str]) -> None:
    widths = [max(len(str(x)) for x in col) for col in zip(headers, *rows)] if rows else [len(h) for h in headers]
    print("  ".join(h.upper().ljust(w) for h, w in zip(headers, widths)))
    for row in rows:
        print("  ".join(str(c).ljust(w) for c, w in zip(row, widths)))


def _target(args, cfg) -> str | None:
    return args.connect or os.environ.get("OFAB_CONNECT") or cfg.console.connect or (
        str(cfg.rpc.socket) if cfg.rpc else None)


async def _client(args, cfg, role: str = "console") -> RpcClient:
    agent = getattr(args, "as_agent", None) or ("cli" if role != "agent" else "cli")
    return await RpcClient.connect(_target(args, cfg), role=role, agent=agent,
                                   token=os.environ.get("OFAB_TOKEN"))


# ------------------------------------------------------------------ commands
async def cmd_serve(args, cfg) -> int:
    from .fabric import Fabric
    from .rpc import RpcServer

    logging.basicConfig(level=logging.INFO if not args.verbose else logging.DEBUG,
                        format="%(asctime)s %(levelname)s %(name)s: %(message)s", stream=sys.stderr)
    fabric = Fabric(cfg)
    await fabric.start()
    server = RpcServer(fabric, cfg.rpc)
    await server.start()
    source = cfg.source or "built-in simulator config"
    print(f"ofab {__version__}: serving fabric {cfg.name!r} on {cfg.rpc.socket} ({source})", file=sys.stderr, flush=True)
    status = fabric.status()
    if status.get("warning"):
        print(f"ofab: warning: {status['warning']}", file=sys.stderr)
    stop = asyncio.Event()
    loop = asyncio.get_running_loop()
    for sig in (signal.SIGINT, signal.SIGTERM):
        loop.add_signal_handler(sig, stop.set)
    await stop.wait()
    await server.stop()
    await fabric.stop()
    return 0


async def cmd_mcp(args, cfg) -> int:
    try:
        from .mcp_server import LocalBackend, RemoteBackend, build_server
        build_server  # noqa: B018 - import check for the optional dependency
    except ImportError:
        print("ofab: the MCP server needs the mcp extra: pip install 'omarchy-fabric[mcp]'", file=sys.stderr)
        return 2
    logging.basicConfig(level=logging.WARNING, stream=sys.stderr)
    fabric = None
    if args.embedded:
        from .fabric import Fabric

        fabric = Fabric(cfg)
        await fabric.start()
        backend = LocalBackend(fabric, args.agent)
    else:
        try:
            client = await RpcClient.connect(_target(args, cfg), role="agent", agent=args.agent,
                                             token=os.environ.get("OFAB_TOKEN"))
        except RpcError as exc:
            print(f"ofab mcp: {exc} (or pass --embedded for a private simulator)", file=sys.stderr)
            return 1
        backend = RemoteBackend(client)
    try:
        await build_server(backend).run_stdio_async()
    finally:
        if fabric is not None:
            await fabric.stop()
    return 0


async def cmd_rpc_stdio(args, cfg) -> int:
    from .rpc import stdio_bridge

    await stdio_bridge(cfg.rpc.socket, args.role, args.agent)
    return 0


async def cmd_console(args, cfg) -> int:
    from .console import Console

    console = Console(_target(args, cfg), cfg.console.status_file, notify=not args.quiet,
                      notify_executed_from=cfg.console.notify_executed_from)
    await console.run()
    return 0


async def cmd_remote(args, cfg) -> int:
    """Every command that talks to a running daemon."""
    role = "agent" if args.cmd in ("do",) and args.as_agent else "console"
    if args.cmd == "matter":
        role = "admin"
    client = await _client(args, cfg, role)
    try:
        c = args.cmd
        if c == "status":
            result = await client.call("status")
            if args.json:
                _print(result, True)
            else:
                frozen = result.get("frozen")
                print(f"fabric {result['name']} (ofab {result['version']}): {result['online']}/{result['things']} things online"
                      + (f", FROZEN by {frozen['by']}: {frozen['reason']}" if frozen else ""))
                for name, a in result["adapters"].items():
                    print(f"  {name:<14} {'connected' if a['connected'] else 'DISCONNECTED'}  {a.get('detail', '')}")
                print(f"  pending approvals: {result['pending_approvals']}")
                if result.get("warning"):
                    print(f"  warning: {result['warning']}")
        elif c == "things":
            result = await client.call("things", area=args.area, capability=args.capability, query=args.query)
            if args.json:
                _print(result, True)
            else:
                _table([[t["id"], t["name"], t.get("area") or "", t.get("kind") or "", ",".join(t["capabilities"]),
                         "yes" if t["online"] else "NO"] for t in result["things"]],
                       ["id", "name", "area", "kind", "capabilities", "online"])
        elif c == "get":
            _print(await client.call("state", thing=args.thing), args.json)
        elif c == "describe":
            _print(await client.call("describe", thing=args.thing), args.json)
        elif c in ("do", "simulate"):
            method = "invoke" if c == "do" else "simulate"
            result = await client.call(method, thing=args.thing, command=args.command, args=_kv(args.args),
                                       reason=getattr(args, "reason", "") or "operator via ofab",
                                       wait_s=getattr(args, "wait", 0))
            _print(result, args.json)
            return 0 if result.get("status") in ("executed", "simulated", "pending_approval") else 3
        elif c == "approvals":
            result = await client.call("approvals", recent=args.recent)
            if args.json:
                _print(result, True)
            elif not result["approvals"]:
                print("no pending approvals")
            else:
                _table([[a["id"], a["status"], a["tier"], a["requires"], a["summary"], a.get("reason", "")]
                        for a in result["approvals"]], ["id", "status", "tier", "needs", "request", "reason"])
        elif c in ("approve", "deny"):
            _print(await client.call(c, id=args.id, note=args.note), args.json)
        elif c == "freeze":
            _print(await client.call("freeze", reason=" ".join(args.reason) or "operator emergency stop"), args.json)
        elif c == "thaw":
            _print(await client.call("thaw"), args.json)
        elif c == "lease":
            _print(await client.call("lease", thing=args.thing, ttl_s=args.ttl, purpose=args.purpose), args.json)
        elif c == "release":
            _print(await client.call("release", thing=args.thing), args.json)
        elif c == "events":
            if args.follow:
                async for event in client.events():
                    print(json.dumps(event, default=str, ensure_ascii=False), flush=True)
            else:
                for event in (await client.call("events", limit=args.limit, thing=args.thing))["events"]:
                    print(json.dumps(event, default=str, ensure_ascii=False))
        elif c == "audit":
            if args.audit_cmd == "verify":
                result = await client.call("audit_verify")
                _print(result, args.json)
                return 0 if result["ok"] else 4
            for record in (await client.call("audit_tail", n=args.n))["records"]:
                print(json.dumps(record, ensure_ascii=False))
        elif c == "sim":
            _print(await client.call("sim", action=args.action, thing=args.thing, attrs=_kv(args.attrs),
                                     seconds=args.seconds, fault=args.fault), args.json)
        elif c == "matter":
            _print(await client.call("matter_commission", code=args.code, network_only=args.network_only), args.json)
        return 0
    finally:
        await client.close()


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(prog="ofab", description="omarchy-fabric: agents to the physical world, safely.")
    p.add_argument("--version", action="version", version=f"ofab {__version__}")
    p.add_argument("-c", "--config", help="config file (default ~/.config/omarchy-fabric/config.toml)")
    p.add_argument("--connect", help="fabric to talk to: socket path, ssh://user@host, tcp://host:port")
    p.add_argument("--json", action="store_true", help="machine-readable output")
    sub = p.add_subparsers(dest="cmd", required=True)

    s = sub.add_parser("serve", help="run the fabric daemon")
    s.add_argument("-v", "--verbose", action="store_true")
    s = sub.add_parser("mcp", help="MCP server for an agent, on stdio")
    s.add_argument("--agent", default=os.environ.get("OFAB_AGENT", "agent"), help="agent identity for policy and audit")
    s.add_argument("--embedded", action="store_true", help="run a private fabric in-process instead of using the daemon")
    s = sub.add_parser("rpc-stdio", help="RPC on stdin/stdout with a fixed identity (SSH forced command)")
    s.add_argument("--role", default="agent", choices=["agent", "console", "admin"])
    s.add_argument("--agent", default="remote-agent")
    s = sub.add_parser("console", help="desktop notifications and bar status")
    s.add_argument("--quiet", action="store_true", help="status file only, no notifications")

    sub.add_parser("status", help="fabric health")
    s = sub.add_parser("things", help="list things")
    s.add_argument("--area")
    s.add_argument("--capability")
    s.add_argument("--query")
    for name in ("get", "describe"):
        sub.add_parser(name, help=f"{name} one thing").add_argument("thing")
    for name, help_text in (("do", "act on a thing (through policy)"), ("simulate", "dry run")):
        s = sub.add_parser(name, help=help_text)
        s.add_argument("thing")
        s.add_argument("command")
        s.add_argument("args", nargs="*", help="key=value")
        s.add_argument("--reason", default="")
        s.add_argument("--wait", type=float, default=0)
        s.add_argument("--as", dest="as_agent", help="act as this agent identity (agent role)")
    s = sub.add_parser("approvals", help="pending approvals")
    s.add_argument("--recent", action="store_true")
    for name in ("approve", "deny"):
        s = sub.add_parser(name, help=f"{name} a pending request")
        s.add_argument("id")
        s.add_argument("--note", default="")
    s = sub.add_parser("freeze", help="emergency stop for all agent actions")
    s.add_argument("reason", nargs="*")
    sub.add_parser("thaw", help="resume after a freeze")
    s = sub.add_parser("lease", help="lease a thing (as the cli agent)")
    s.add_argument("thing")
    s.add_argument("--ttl", type=float, default=300)
    s.add_argument("--purpose", default="")
    sub.add_parser("release", help="release a lease").add_argument("thing")
    s = sub.add_parser("events", help="recent events")
    s.add_argument("-f", "--follow", action="store_true")
    s.add_argument("--limit", type=int, default=50)
    s.add_argument("--thing")
    s = sub.add_parser("audit", help="audit log")
    a = s.add_subparsers(dest="audit_cmd", required=True)
    a.add_parser("verify")
    t = a.add_parser("tail")
    t.add_argument("-n", type=int, default=20)
    s = sub.add_parser("sim", help="simulator controls: human, external, sensor, offline, online, fault, step")
    s.add_argument("action", choices=["human", "external", "sensor", "offline", "online", "fault", "step"])
    s.add_argument("thing", nargs="?", default="")
    s.add_argument("attrs", nargs="*", help="key=value")
    s.add_argument("--seconds", type=float, default=1)
    s.add_argument("--fault", default="error")
    s = sub.add_parser("matter", help="Matter admin")
    m = s.add_subparsers(dest="matter_cmd", required=True)
    c = m.add_parser("commission", help="commission a device with its setup code (MT:... or 11-digit)")
    c.add_argument("code")
    c.add_argument("--network-only", action="store_true", help="device is already on the network (no BLE)")
    return p


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    try:
        cfg = config_mod.load(args.config)
    except (FileNotFoundError, ValueError) as exc:
        print(f"ofab: {exc}", file=sys.stderr)
        return 2
    handlers = {"serve": cmd_serve, "mcp": cmd_mcp, "rpc-stdio": cmd_rpc_stdio, "console": cmd_console}
    handler = handlers.get(args.cmd, cmd_remote)
    try:
        return asyncio.run(handler(args, cfg))
    except RpcError as exc:
        print(f"ofab: {exc}", file=sys.stderr)
        return 1
    except KeyboardInterrupt:
        return 130


if __name__ == "__main__":
    sys.exit(main())
