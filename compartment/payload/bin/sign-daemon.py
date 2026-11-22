#!/usr/bin/env python3
# sign-daemon.py — networkless signing daemon for vault-signer.
# Protocol on /dev/vport1p1 (virtio-serial 'signer' channel):
#   <- line: {"req": "sign", "to": "0x...", "value": "...", "chain_id": 1, "data": "0x..."}
#   -> line: {"status": "pending", "id": N}          (waits for approval)
#   <- line: {"req": "approve", "id": N, "ok": true}
#   -> line: {"status": "signed", "id": N, "sig": "0x...", "digest": "0x..."}
# Validation is deterministic: schema + chain_id allowlist + size limits only.
# The key never leaves this VM. No network exists here by construction.
import json, os, sys, hashlib, time, select
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey
from cryptography.hazmat.primitives import serialization

PORT = os.environ.get("SIGN_PORT", "/dev/virtio-ports/signer")
KEY_PATH = "/var/lib/vault/signing.key"
ALLOWED_CHAINS = {1, 8453, 42161, 10}          # ethereum, base, arbitrum, optimism
MAX_PAYLOAD = 16384
pending = {}

def load_key():
    if os.path.exists(KEY_PATH):
        with open(KEY_PATH, "rb") as f:
            return Ed25519PrivateKey.from_private_bytes(f.read())
    k = Ed25519PrivateKey.generate()
    os.makedirs("/var/lib/vault", exist_ok=True)
    with open(KEY_PATH, "wb") as f:
        f.write(k.private_bytes(serialization.Encoding.Raw,
                                serialization.PrivateFormat.Raw,
                                serialization.NoEncryption()))
    os.chmod(KEY_PATH, 0o600)
    return k

def valid_tx(t):
    return (isinstance(t.get("to"), str) and t["to"].startswith("0x") and len(t["to"]) == 42
            and isinstance(t.get("value"), (int, str)) and int(str(t["value"]), 0) >= 0
            and t.get("chain_id") in ALLOWED_CHAINS
            and len(json.dumps(t)) < MAX_PAYLOAD)

def pub_hex(key):
    return key.public_key().public_bytes(serialization.Encoding.Raw,
                                        serialization.PublicFormat.Raw).hex()

def main():
    key = load_key()
    port = open(PORT, "r+b", buffering=0)   # virtio-serial ports are single-open
    def send(obj):
        port.write(json.dumps(obj).encode() + b"\n"); port.flush()
    nid = 0
    buf = b""
    poller = select.poll()
    poller.register(port.fileno(), select.POLLIN | select.POLLHUP)
    while True:
        # virtio ports return b"" immediately when no host client is attached —
        # poll first or we spin at 100% CPU
        events = poller.poll(500)
        if not events:
            continue
        fd, ev = events[0]
        if ev & select.POLLHUP:
            time.sleep(0.1); continue
        chunk = port.read(4096)
        if not chunk:
            time.sleep(0.1); continue
        buf += chunk
        while b"\n" not in buf and len(buf) > MAX_PAYLOAD:
            buf = buf[MAX_PAYLOAD:]
        while b"\n" in buf:
            raw, buf = buf.split(b"\n", 1)
            line = raw.decode(errors="replace").strip()
            if not line:
                continue
            try:
                req = json.loads(line)
            except json.JSONDecodeError:
                send({"status": "error", "reason": "bad-json"})
                continue
            kind = req.get("req")
            if kind == "sign":
                tx = {k: req.get(k) for k in ("to", "value", "chain_id", "data", "nonce")}
                if not valid_tx(tx):
                    send({"status": "error", "reason": "schema"})
                    continue
                nid += 1
                pending[nid] = tx
                send({"status": "pending", "id": nid})
            elif kind == "approve":
                i = req.get("id")
                if i not in pending:
                    send({"status": "error", "reason": "no-pending"})
                    continue
                if req.get("ok") is not True:
                    del pending[i]
                    send({"status": "rejected", "id": i})
                    continue
                tx = pending.pop(i)
                digest = hashlib.sha256(json.dumps(tx, sort_keys=True).encode()).digest()
                sig = key.sign(digest)
                send({"status": "signed", "id": i,
                      "sig": sig.hex(), "digest": digest.hex()})
            elif kind == "pubkey":
                send({"status": "pub", "pub": pub_hex(key)})
            else:
                send({"status": "error", "reason": "unknown-req"})

if __name__ == "__main__":
    sys.exit(main())
