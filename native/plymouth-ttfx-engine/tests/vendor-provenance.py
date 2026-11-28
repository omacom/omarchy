#!/usr/bin/env python3
"""Verify the pinned upstream TTFX import, local delta, and offline crate closure.

With --write and --upstream-archive, regenerate vendor/ttfx-provenance.json from
the vendored tree and the immutable upstream archive instead of verifying it.
"""

import argparse
import hashlib
import json
from pathlib import Path
import tarfile
import tomllib

ROOT = Path(__file__).resolve().parents[1]

REPOSITORY = "https://github.com/omacom/ttfx"
VERSION = "0.5.1"
TAG = "v0.5.1"
REVISION = "14ed2742596f0056b13e25d14a83ea851adc2294"
IMPORTED_PATHS = ["Cargo.toml", "Cargo.lock", "LICENSE", "NOTICE", "README.md", "src"]


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def vendored_inventory(vendor):
    return sorted(
        path.relative_to(vendor).as_posix()
        for path in vendor.rglob("*")
        if path.is_file() and "target" not in path.relative_to(vendor).parts
    )


def registry_packages(lock_bytes):
    lock = tomllib.loads(lock_bytes.decode())
    return {
        (package["name"], package["version"]): package["checksum"]
        for package in lock["package"]
        if package.get("source", "").startswith("registry+")
    }


def archive_member(source, relative):
    with source.extractfile(f"ttfx-{REVISION}/{relative}") as stream:
        return stream.read()


def write(root, archive):
    vendor = root / "vendor/ttfx"
    files = {}
    with tarfile.open(archive) as source:
        for relative in vendored_inventory(vendor):
            files[relative] = {
                "upstream_sha256": sha256(archive_member(source, relative)),
                "vendored_sha256": sha256((vendor / relative).read_bytes()),
            }
    lock_bytes = (root / "Cargo.lock").read_bytes()
    packages = [
        {"name": name, "version": version, "checksum": checksum, "directory": name}
        for (name, version), checksum in sorted(registry_packages(lock_bytes).items())
    ]
    manifest = {
        "repository": REPOSITORY,
        "version": VERSION,
        "tag": TAG,
        "revision": REVISION,
        "archive_url": f"https://codeload.github.com/omacom/ttfx/tar.gz/{REVISION}",
        "archive_sha256": sha256(archive.read_bytes()),
        "imported_paths": IMPORTED_PATHS,
        "patch_sha256": sha256((root / "vendor/ttfx-plymouth.patch").read_bytes()),
        "bridge_lock_sha256": sha256(lock_bytes),
        "registry_packages": packages,
        "files": files,
    }
    (root / "vendor/ttfx-provenance.json").write_text(json.dumps(manifest, indent=2) + "\n")
    print(f"vendor provenance: wrote {len(files)} source files, {len(packages)} registry packages")


def verify(root, archive=None):
    vendor = root / "vendor/ttfx"
    manifest = json.loads((root / "vendor/ttfx-provenance.json").read_text())
    assert manifest["repository"] == REPOSITORY
    assert manifest["version"] == VERSION
    assert manifest["tag"] == TAG
    assert manifest["revision"] == REVISION
    assert f'version = "{VERSION}"' in (vendor / "Cargo.toml").read_text(), "vendored version drift"
    inventory = vendored_inventory(vendor)
    assert set(inventory) == set(manifest["files"]), "upstream source inventory drift"
    assert all(
        relative in IMPORTED_PATHS or relative.split("/", 1)[0] in IMPORTED_PATHS for relative in inventory
    ), "file outside the imported paths"
    for relative, hashes in manifest["files"].items():
        assert sha256((vendor / relative).read_bytes()) == hashes["vendored_sha256"], relative
    patch = root / "vendor/ttfx-plymouth.patch"
    assert sha256(patch.read_bytes()) == manifest["patch_sha256"], "local delta drift"
    lock_bytes = (root / "Cargo.lock").read_bytes()
    assert sha256(lock_bytes) == manifest["bridge_lock_sha256"], "lockfile drift"
    packages = registry_packages(lock_bytes)
    assert packages == {
        (package["name"], package["version"]): package["checksum"]
        for package in manifest["registry_packages"]
    }, "registry dependency closure drift"
    for package in manifest["registry_packages"]:
        directory = root / "vendor/crates" / package["directory"]
        checksums = json.loads((directory / ".cargo-checksum.json").read_text())
        assert checksums["package"] == package["checksum"], directory
        for relative, expected in checksums["files"].items():
            assert sha256((directory / relative).read_bytes()) == expected, directory / relative
    vendored_crates = {path.name for path in (root / "vendor/crates").iterdir() if path.is_dir()}
    assert vendored_crates == {package["directory"] for package in manifest["registry_packages"]}, (
        "vendored crate directories drift"
    )
    if archive:
        assert sha256(archive.read_bytes()) == manifest["archive_sha256"], "archive digest"
        with tarfile.open(archive) as source:
            for relative, hashes in manifest["files"].items():
                assert sha256(archive_member(source, relative)) == hashes["upstream_sha256"], relative
    print(
        f"vendor provenance: PASS (TTFX {VERSION}, {len(inventory)} source files, "
        f"{len(packages)} registry packages)"
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=ROOT)
    parser.add_argument("--upstream-archive", type=Path)
    parser.add_argument("--write", action="store_true")
    args = parser.parse_args()
    if args.write:
        if not args.upstream_archive:
            parser.error("--write needs --upstream-archive")
        write(args.root, args.upstream_archive)
    verify(args.root, args.upstream_archive)
