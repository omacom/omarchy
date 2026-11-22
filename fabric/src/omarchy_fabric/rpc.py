"""Newline-delimited JSON RPC between the daemon and its clients.

  -> {"id": 1, "method": "hello", "params": {"role": "agent", "agent": "claude-code"}}
  <- {"id": 1, "result": {"role": "agent", "agent": "claude-code", ...}}
  -> {"id": 2, "method": "invoke", "params": {"thing": "...", "command": "turn_on"}}
  <- {"id": 2, "result": {...}}            or {"id": 2, "error": {"code": "...", "message": "..."}}
  <- {"event": {...}}                      after {"method": "subscribe"}

Transports
  unix   $XDG_RUNTIME_DIR/omarchy-fabric/fabric.sock, mode 0600. The peer declares its
         role; console approvals count as rpc.local_assurance.
  tcp    optional, bearer tokens from [[rpc.tokens]] decide role + agent name.
  ssh    `ssh -T fabric@pi5 ofab rpc-stdio ...`: put the identity in an authorized_keys
         forced command, and an agent's SSH key can never become a console.
"""

from __future__ import annotations

import asyncio
import hmac
import json
import logging
import os
import shlex
import sys
from pathlib import Path
from typing import Any, AsyncIterator

from . import __version__
from .api import ROLES, Session, dispatch
from .model import Assurance, FabricError, PermissionDenied
from .util import clean_text

log = logging.getLogger("omarchy_fabric.rpc")
MAX_LINE = 1 << 20


class RpcError(FabricError):
    def __init__(self, code: str, message: str):
        super().__init__(message, code)


def _encode(obj: Any) -> bytes:
    return (json.dumps(obj, default=str, ensure_ascii=False) + "\n").encode()


class RpcServer:
    def __init__(self, fabric, config):
        self.fabric = fabric
        self.config = config
        self._servers: list[asyncio.AbstractServer] = []

    async def start(self) -> None:
        path = Path(self.config.socket)
        path.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
        if path.exists():
            try:
                _, writer = await asyncio.open_unix_connection(str(path))
                writer.close()
                raise RuntimeError(f"another fabric is already serving {path}")
            except (ConnectionRefusedError, FileNotFoundError, OSError) as exc:
                if isinstance(exc, RuntimeError):
                    raise
                path.unlink()
        old = os.umask(0o177)
        try:
            server = await asyncio.start_unix_server(lambda r, w: self._client(r, w, "unix"), path=str(path),
                                                     limit=MAX_LINE)
        finally:
            os.umask(old)
        os.chmod(path, 0o600)
        self._servers.append(server)
        if self.config.tcp:
            host, _, port = self.config.tcp.rpartition(":")
            if not self.config.tokens:
                raise RuntimeError("rpc.tcp is set but no [[rpc.tokens]] are configured")
            server = await asyncio.start_server(lambda r, w: self._client(r, w, "tcp"), host or "127.0.0.1",
                                                int(port), limit=MAX_LINE)
            self._servers.append(server)

    async def stop(self) -> None:
        for server in self._servers:
            server.close()
        try:
            Path(self.config.socket).unlink()
        except FileNotFoundError:
            pass

    def _authenticate(self, transport: str, params: dict[str, Any]) -> Session:
        if transport == "unix":
            role = params.get("role", "agent")
            if role not in ROLES:
                raise PermissionDenied(f"unknown role {role!r}")
            agent = clean_text(params.get("agent") or ("console" if role != "agent" else "local-agent"), 64)
            assurance = self.config.local_assurance if role != "agent" else Assurance.NONE
            return Session(role, agent, assurance, "unix")
        token = str(params.get("token") or "")
        for entry in self.config.tokens:
            if token and hmac.compare_digest(entry.token.encode(), token.encode()):
                assurance = entry.max_assurance if entry.role != "agent" else Assurance.NONE
                return Session(entry.role, entry.agent, assurance, transport)
        raise PermissionDenied("invalid or missing token")

    async def _client(self, reader: asyncio.StreamReader, writer: asyncio.StreamWriter, transport: str) -> None:
        session: Session | None = None
        lock = asyncio.Lock()
        tasks: set[asyncio.Task] = set()
        listener = None
        pump = None

        async def send(obj: Any) -> None:
            async with lock:
                writer.write(_encode(obj))
                await writer.drain()

        try:
            while True:
                try:
                    line = await reader.readline()
                except (asyncio.LimitOverrunError, ValueError):
                    await send({"error": {"code": "invalid", "message": "message too large"}})
                    break
                if not line:
                    break
                try:
                    msg = json.loads(line)
                    mid, name, params = msg.get("id"), msg.get("method"), msg.get("params") or {}
                except (json.JSONDecodeError, AttributeError):
                    await send({"error": {"code": "invalid", "message": "not a JSON object"}})
                    continue
                if name == "hello":
                    try:
                        session = self._authenticate(transport, params)
                    except FabricError as exc:
                        await send({"id": mid, "error": {"code": exc.code, "message": str(exc)}})
                        break
                    await send({"id": mid, "result": {"role": session.role, "agent": session.agent,
                                                      "fabric": self.fabric.config.name, "version": __version__}})
                    continue
                if session is None:
                    await send({"id": mid, "error": {"code": "forbidden", "message": "send hello first"}})
                    continue
                if name == "subscribe":
                    if listener is None:
                        queue: asyncio.Queue = asyncio.Queue(maxsize=1000)
                        hidden_ok = session.at_least("console")

                        def listener(event: dict[str, Any], q=queue, hidden_ok=hidden_ok) -> None:
                            tid = event.get("thing")
                            if tid and not hidden_ok:
                                thing = self.fabric.registry.get(tid)
                                if thing is not None and not thing.expose:
                                    return
                            try:
                                q.put_nowait(event)
                            except asyncio.QueueFull:
                                pass

                        async def run_pump(q=queue) -> None:
                            while True:
                                await send({"event": await q.get()})

                        self.fabric.registry.listeners.append(listener)
                        pump = asyncio.ensure_future(run_pump())
                    await send({"id": mid, "result": {"subscribed": True}})
                    continue
                task = asyncio.ensure_future(self._handle(send, session, mid, name, params))
                tasks.add(task)
                task.add_done_callback(tasks.discard)
        except (ConnectionResetError, BrokenPipeError):
            pass
        finally:
            if listener is not None and listener in self.fabric.registry.listeners:
                self.fabric.registry.listeners.remove(listener)
            if pump is not None:
                pump.cancel()
            for task in tasks:
                task.cancel()
            writer.close()

    async def _handle(self, send, session: Session, mid: Any, name: str, params: dict[str, Any]) -> None:
        try:
            result = await dispatch(self.fabric, session, name, params)
            await send({"id": mid, "result": result})
        except FabricError as exc:
            await send({"id": mid, "error": {"code": exc.code, "message": str(exc)}})
        except asyncio.CancelledError:
            raise
        except Exception as exc:  # never kill the connection over one bad request
            log.exception("rpc %s failed", name)
            await send({"id": mid, "error": {"code": "internal", "message": f"{type(exc).__name__}: {exc}"}})


class RpcClient:
    def __init__(self, reader: asyncio.StreamReader, writer: asyncio.StreamWriter, proc=None):
        self.reader, self.writer, self.proc = reader, writer, proc
        self._next = 1
        self._pending: dict[int, asyncio.Future] = {}
        self._events: asyncio.Queue = asyncio.Queue()
        self._task = asyncio.ensure_future(self._read())
        self._subscribed = False
        self.identity: dict[str, Any] = {}

    @classmethod
    async def connect(cls, target: str | Path | None = None, *, role: str = "agent", agent: str = "cli",
                      token: str | None = None) -> "RpcClient":
        from .config import default_socket

        text = str(target) if target else str(default_socket())
        proc = None
        if text.startswith("tcp://"):
            host, _, port = text[6:].rpartition(":")
            reader, writer = await asyncio.open_connection(host, int(port), limit=MAX_LINE)
        elif text.startswith("ssh://"):
            dest = text[6:]
            port_args: list[str] = []
            if dest.count(":") == 1:
                dest, port = dest.split(":")
                port_args = ["-p", port]
            remote = os.environ.get("OFAB_REMOTE_COMMAND", "ofab rpc-stdio")
            proc = await asyncio.create_subprocess_exec(
                "ssh", "-T", "-o", "BatchMode=yes", *port_args, dest, *shlex.split(remote),
                stdin=asyncio.subprocess.PIPE, stdout=asyncio.subprocess.PIPE, limit=MAX_LINE)
            reader, writer = proc.stdout, proc.stdin
        else:
            path = text[5:] if text.startswith("unix:") else text
            try:
                reader, writer = await asyncio.open_unix_connection(path, limit=MAX_LINE)
            except (FileNotFoundError, ConnectionRefusedError):
                raise RpcError("unavailable", f"no fabric daemon at {path} (start one with `ofab serve`)") from None
        client = cls(reader, writer, proc)
        client.identity = await client.call("hello", role=role, agent=agent, token=token)
        return client

    async def _read(self) -> None:
        try:
            while line := await self.reader.readline():
                msg = json.loads(line)
                if "event" in msg:
                    await self._events.put(msg["event"])
                    continue
                future = self._pending.pop(msg.get("id"), None)
                if future is None or future.done():
                    continue
                if "error" in msg:
                    err = msg["error"]
                    future.set_exception(RpcError(err.get("code", "error"), err.get("message", "")))
                else:
                    future.set_result(msg.get("result"))
        finally:
            for future in self._pending.values():
                if not future.done():
                    future.set_exception(RpcError("unavailable", "connection to the fabric closed"))
            await self._events.put(None)

    async def call(self, name: str, **params: Any) -> Any:
        mid = self._next
        self._next += 1
        future = asyncio.get_running_loop().create_future()
        self._pending[mid] = future
        self.writer.write(_encode({"id": mid, "method": name,
                                   "params": {k: v for k, v in params.items() if v is not None}}))
        await self.writer.drain()
        return await future

    async def subscribe(self) -> None:
        """Start receiving events. Returns once the server has confirmed, so nothing
        that happens afterwards can be missed."""
        if not self._subscribed:
            await self.call("subscribe")
            self._subscribed = True

    async def events(self) -> AsyncIterator[dict[str, Any]]:
        await self.subscribe()
        while (event := await self._events.get()) is not None:
            yield event

    async def close(self) -> None:
        self._task.cancel()
        self.writer.close()
        if self.proc is not None:
            try:
                self.proc.terminate()
            except ProcessLookupError:
                pass


async def stdio_bridge(socket: Path, role: str, agent: str) -> None:
    """`ofab rpc-stdio`: speak the RPC on stdin/stdout with a fixed identity.
    Meant as an SSH forced command, so the identity is the key's, not the caller's."""
    reader, writer = await asyncio.open_unix_connection(str(socket), limit=MAX_LINE)
    writer.write(_encode({"id": 0, "method": "hello", "params": {"role": role, "agent": agent}}))
    await writer.drain()
    hello = json.loads(await reader.readline())
    loop = asyncio.get_running_loop()
    stdin = asyncio.StreamReader(limit=MAX_LINE)
    await loop.connect_read_pipe(lambda: asyncio.StreamReaderProtocol(stdin), sys.stdin)
    out = sys.stdout.buffer

    async def upstream() -> None:
        while line := await stdin.readline():
            try:
                msg = json.loads(line)
            except json.JSONDecodeError:
                continue
            if msg.get("method") == "hello":  # identity is fixed here; answer locally
                out.write(_encode({"id": msg.get("id"), "result": hello.get("result")}))
                out.flush()
                continue
            writer.write(line if line.endswith(b"\n") else line + b"\n")
            await writer.drain()
        writer.close()

    async def downstream() -> None:
        while line := await reader.readline():
            out.write(line)
            out.flush()

    up = asyncio.ensure_future(upstream())
    down = asyncio.ensure_future(downstream())
    await asyncio.wait({up, down}, return_when=asyncio.FIRST_COMPLETED)
    up.cancel()
    down.cancel()
