#!/usr/bin/env python3
"""Loopback-only JSON bridge to RavenGram's raw Telegram wallet MTProto API."""
import asyncio
import base64
import hmac
import json
import os
import re
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import Any

from pyrogram import Client, raw

ALLOWED = {
    "getState", "getUserAddresses", "getTransactions", "getTransactionsByIDs",
    "getTransactionsByMsgHash", "exportSecretPhrase", "fetchEncryptedSecretPhrasePart",
    "replaceWallet", "disableBackup", "getBackupHolderDcs", "enableBackup",
    "getProofChallenge", "sendTransfer", "getGaslessInfo", "getExistingWaltBalance",
    "getNfts", "tonConnectCreateSession", "tonConnectRegisterKey",
    "tonConnectSubmitConnectResult", "tonConnectGetPending", "tonConnectClaimRequest",
    "tonConnectSubmitResponse", "tonConnectNextEventId", "tonConnectCloseSession",
    "tonConnectGetSessions",
}

def class_name(value: str) -> str:
    words = re.sub(r"([a-z0-9])([A-Z])", r"\1 \2", value).replace("_", " ").split()
    return "".join(word[:1].upper() + word[1:] for word in words)

def decode(value: Any) -> Any:
    if isinstance(value, list):
        return [decode(x) for x in value]
    if not isinstance(value, dict):
        return value
    if set(value) == {"@bytes"}:
        return base64.b64decode(value["@bytes"], validate=True)
    fields = {k: decode(v) for k, v in value.items() if k != "@type"}
    kind = value.get("@type")
    if kind is None:
        return fields
    cls = getattr(raw.types, class_name(kind), None)
    if cls is None:
        raise ValueError("unknown TL object type: " + kind)
    return cls(**fields)

def encode(value: Any) -> Any:
    if value is None or isinstance(value, (str, int, float, bool)):
        return value
    if isinstance(value, bytes):
        return {"@bytes": base64.b64encode(value).decode("ascii")}
    if isinstance(value, (list, tuple)):
        return [encode(x) for x in value]
    if hasattr(value, "__dict__"):
        result = {k: encode(v) for k, v in vars(value).items() if not k.startswith("_")}
        result["@type"] = value.__class__.__name__
        return result
    slots = getattr(value.__class__, "__slots__", ())
    if slots:
        result = {k: encode(getattr(value, k)) for k in slots if hasattr(value, k)}
        result["@type"] = value.__class__.__name__
        return result
    return str(value)

class Handler(BaseHTTPRequestHandler):
    def do_POST(self) -> None:
        if self.path != "/rpc":
            return self.reply(404, {"error": "not found"})
        expected = os.environ["TITOGRAM_WALLET_BRIDGE_TOKEN"].encode()
        supplied = self.headers.get("Authorization", "").removeprefix("Bearer ").encode()
        if not hmac.compare_digest(expected, supplied):
            return self.reply(401, {"error": "unauthorized"})
        try:
            size = int(self.headers.get("Content-Length", "0"))
            if size < 2 or size > 1_000_000:
                raise ValueError("invalid request size")
            body = json.loads(self.rfile.read(size))
            method = body.get("method", "")
            namespace, dot, name = method.partition(".")
            if not dot or namespace != "wallet" or name not in ALLOWED:
                raise ValueError("only supported wallet.* methods are allowed")
            cls = getattr(raw.functions.wallet, class_name(name), None)
            if cls is None:
                raise ValueError("RavenGram does not expose " + method)
            params = decode(body.get("params") or {})
            future = asyncio.run_coroutine_threadsafe(
                self.server.client.invoke(cls(**params)), self.server.loop
            )
            self.reply(200, {"result": encode(future.result(timeout=60))})
        except Exception as error:
            self.reply(400, {"error": str(error)})

    def reply(self, status: int, value: dict[str, Any]) -> None:
        data = json.dumps(value, separators=(",", ":")).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def log_message(self, *_: Any) -> None:
        return

async def main() -> None:
    token = os.environ["TITOGRAM_WALLET_BRIDGE_TOKEN"]
    if len(token) < 32:
        raise SystemExit("TITOGRAM_WALLET_BRIDGE_TOKEN must be at least 32 characters")
    session_dir = Path(
        os.environ.get(
            "RAVENGRAM_SESSION_DIR",
            str(Path.home() / ".local" / "share" / "titogramlua-wallet"),
        )
    ).expanduser()
    session_dir.mkdir(parents=True, exist_ok=True, mode=0o700)
    if os.name != "nt":
        os.chmod(session_dir, 0o700)
        os.umask(0o077)

    client = Client(
        os.environ.get("RAVENGRAM_SESSION", "titogramlua_wallet"),
        workdir=str(session_dir),
        api_id=int(os.environ["TELEGRAM_API_ID"]),
        api_hash=os.environ["TELEGRAM_API_HASH"],
    )
    await client.start()
    loop = asyncio.get_running_loop()
    server = ThreadingHTTPServer(("127.0.0.1", 8765), Handler)
    server.client = client
    server.loop = loop
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    print("RavenGram wallet MTProto bridge listening on 127.0.0.1:8765")
    try:
        await asyncio.Event().wait()
    finally:
        server.shutdown()
        server.server_close()
        await client.stop()

if __name__ == "__main__":
    asyncio.run(main())
