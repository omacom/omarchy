# Testing NetClaw integration

## Arch Linux container

The repository includes an x86-64 Arch Linux validation image and a runner. On the development Mac, OrbStack supplies the Docker engine:

```bash
DOCKER_CONTEXT=orbstack ./test/netclaw-container
```

On a Linux Docker host, use `./test/netclaw-container` with your usual context. The runner builds `omarchy-netclaw-test`, then runs it as an unprivileged test user with networking disabled. No host home, SSH agent, credentials, Docker socket, or network devices are mounted into the test container. The image contains the fork's integration source and test fixtures; it does not contain a fully installed NetClaw MCP dependency set.

The suite exercises NetClaw provisioning and setup contracts, CLI metadata and dispatch, the existing default-agent tests, and the menu model. Packages, provider onboarding, upstream component installation, and gateway responses are stubbed in the isolated integration tests. Git checkout, filesystem state, locks on Linux, recovery markers, and backup preservation use real operations.

The build requires network access for Arch packages. Its pacman command disables the downloader's syscall sandbox because Rosetta cannot implement that seccomp filter when running x86 binaries on Apple Silicon. Package signature verification and Docker's container isolation remain enabled; this adjustment is confined to the disposable test image.

To inspect the image:

```bash
docker --context orbstack run --rm -it --platform linux/amd64 --network none omarchy-netclaw-test bash
```

## Real upstream source smoke test

After building the image, this separate command fetches the real pinned source into an ephemeral container and runs upstream's catalog coverage checker. It requires network access but no provider credentials:

```bash
docker --context orbstack run --rm --platform linux/amd64 omarchy-netclaw-test bash -lc '
  export OMARCHY_PATH=/workspace/omarchy
  export PATH="$OMARCHY_PATH/bin:$PATH"
  omarchy-netclaw-prepare
  python3 "$HOME/.local/share/omarchy/netclaw/scripts/verify-catalog-coverage.py"
'
```

This verifies source provisioning and catalog coverage. It does not install or authenticate every integration. At the initial pinned revision, upstream's inventory checker also reports a documentation discrepancy in its advertised MCP total; the fork consequently promises full upstream catalog selection rather than a fixed advertised count.

## Systemd and desktop acceptance

A container test is insufficient to claim a working Omarchy OS image. Use a disposable x86-64 VM for fresh installation, per-user migration, graphical launcher and menu checks, first-run onboarding, a real MCP request against an authorized lab, gateway login persistence, and update/recovery behavior. Follow [the repository's VM acceptance workflow](../agents/skills/acceptance-tests.md) and [visual verification guide](../agents/skills/visual-verification.md).

OrbStack Linux machines can test systemd services, but do not provide a complete Omarchy graphical desktop by default. UTM can emulate an x86-64 guest on this Apple Silicon Mac. Hyper-V is an option on a separate compatible Windows host. A full acceptance run requires the companion Omarchy package and ISO builder repositories, a freshly built image incorporating this fork, and user-supplied provider and lab credentials.

References: [Docker multi-platform builds](https://docs.docker.com/build/building/multi-platform/), [OrbStack Linux machines](https://docs.orbstack.dev/machines/), [UTM system emulation](https://docs.getutm.app/settings-qemu/system/), and [pacman sandbox options](https://man.archlinux.org/man/pacman.8.en).
