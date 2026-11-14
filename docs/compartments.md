# AI compartments

Privacy-first AI isolation: agents run inside thin-fork Whonix VMs, never on the host. Each compartment has its own local model server, its own agent CLIs, and a fixed whitelisted intent interface — model output is never interpreted as arbitrary shell commands.

```
host (trusted control plane)
  omarchy compartment <name> <intent>   →  vm-exec forced command in guest
  host policy gate                      →  refuses out-of-policy intents pre-transmission
  DLP context firewall (guest :8081)    →  blocks secrets/PII before inference
  llama-server (guest :8080)            →  local Ornith-9B, loopback only
  vault-signer VM (no NIC)              →  Ed25519 signing via virtio-serial + human approval
```

## Commands

| Command | Purpose |
|---|---|
| `omarchy install compartment-ai` | Full setup: hardening, weights disk, template, first compartment, vault-signer |
| `omarchy compartment <name> <intent>` | Dispatch a whitelisted intent (`attach`, `agent`, `prompt`, `status`, `git`, `sign-request`, …) |
| `omarchy compartment mk <name>` | Thin-fork a new compartment from the Whonix-AI template |
| `omarchy compartment list` | List registered compartments |
| `omarchy default compartment [name]` | Pick which compartment `omarchy agent` routes into |
| `omarchy agent` | With a default compartment set, launches inside it (prompts forwarded, `--agent`/`--local` stay host-side) |

Hidden helpers (used by the installer, runnable directly): `omarchy-compartment-setup`, `-weights`, `-template`, `-up`, `-vault`, `-pii`, `-drill`, `-agent-pack`.

## Prerequisites

```bash
# virtualization + image tooling
sudo pacman -S qemu-desktop libvirt virt-manager dnsmasq edk2-ovmf swtpm \
  libguestfs virt-customize nbd pciutils
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt "$USER"   # optional: virsh without sudo
```

Whonix-CLI base image is fetched during template setup; the AI template is built from `Whonix-Workstation-CLI.qcow2` copied to `Whonix-AI.qcow2` in the compartment image dir (`/var/lib/libvirt/images/whonix`).

## Artifacts you provide

These are NOT shipped in the repo — build or fetch them first:

### Model weights

Place GGUF model(s) in `~/.hermes/models/` (override with `COMPARTMENT_MODELS`). Any OpenAI-compatible GGUF works; the default tested model is `Ornith-1.5-9B-uncensored.Q4_K_M.gguf` (~6 GB). mmproj files are picked up automatically.

### llama-server binary

Build from source (glibc ≤ 2.38 for the Debian guest) or drop a static build at `~/.cache/omarchy/compartment/llama-server` (override with `LLAMA_SERVER` for `omarchy-compartment-template`):

```bash
git clone https://github.com/ggml-org/llama.cpp && cd llama.cpp
cmake -B build -DGGML_NATIVE=OFF && cmake --build build --target llama-server -j
cp build/bin/llama-server ~/.cache/omarchy/compartment/
```

### Agent CLIs (optional offline pack)

```bash
mise install claude codex opencode
omarchy-compartment-agent-pack   # → ~/.cache/omarchy/compartment/agent-pack.tar.gz
```

Without the pack, the guest installs agents at first boot (slower, over Tor).

### Hermes backend pack (optional)

Hermes Agent needs CPython 3.14 (python-build-standalone) + a venv with its dependencies. Pack `hermes-agent/` (excl. venv/.git) to `~/.cache/omarchy/compartment/hermes-pack.tar.gz`. Without the pack the guest falls back to `provision-agents.sh` at first boot.

### Debian .debs (optional speedup)

`DEBS_DIR=/path/to/debs omarchy-compartment-template` uploads a debs tarball for offline `dpkg -i` at first boot. Without it the guest runs `apt-get install` over Whonix Tor — slower but fully automatic.

## Install

```bash
omarchy install compartment-ai
```

Steps: host hardening → weights disk (dm-verity) → Whonix-AI template → `hermes-coding` compartment → boot → `vault-signer` VM. Idempotent — existing resources are detected and skipped, failures abort.

## Daily use

```bash
omarchy compartment hermes-coding attach        # interactive agent TUI
omarchy compartment hermes-coding prompt "..."  # one-shot through DLP firewall
omarchy compartment hermes-coding status        # inference stack health
omarchy compartment hermes-coding shell         # refused by host policy gate
omarchy default compartment hermes-coding       # omarchy agent routes here
omarchy compartment-pii                         # fill literal PII denylist
omarchy compartment-drill                       # integrity watch drill
```

## Security model

- **No shared inference** — each compartment runs its own llama-server; no transient service sees multiple compartments' prompts.
- **No identity data in AI VMs** — logins, email, wallets, browser sessions stay on the host or in non-AI compartments.
- **Fixed intents only** — `vm-exec` forced command + per-compartment yaml allowlist; the host policy gate refuses unknown intents before transmission.
- **DLP firewall** — ModSecurity rules block secrets/PII patterns before requests reach the model; your literal denylist via `omarchy-compartment-pii`.
- **Canaries** — `dlp/canary-sigs.txt` ships empty; generate per compartment from canarytoken decoy contents so any honeypot read reaching the model trips a CANARY alert.
- **Seal chain** — `vm-seal-local` (guest) delegates to `wazuh-vm-seal.sh`: blocks attacker IPs, blackholes the gateway route, kills known-malware markers, reboots to snapshot. Host-side `host-seal.sh` is the Wazuh active-response target that destroys a tripped compartment VM.
- **Watchdog coverage** — auditd watchpoints + AIDE + usbguard on the host; `omarchy-compartment-drill` verifies the integrity chain end-to-end. Wazuh agent (optional) provides alerting → active response; merge `compartment/host/wazuh/ossec-ar-snippets.conf` into `ossec.conf`.
- **Sandboxed agents** — firejail profile: loopback-only network, workspace as the only writable area, credential dirs blacklisted.
- **Read-only weights** — dm-verity hash tree; manifest signed into the guest.
- **Vault-signer** — networkless VM, Ed25519 only, every transaction requires interactive host approval (`omarchy compartment <name> vault-sign '<json>'`).
- **Host hardening** (`omarchy-compartment-setup`, idempotent):
  - sysctl: `90-compartment-ai.conf` + `99-hardening.conf` (ipv6/bpf/perf/suid_dumpable)
  - auditd: `hardening.rules` (identity, logins, syscalls, libvirt, network) + `compartment-ai.rules` (watchpoints on VM images, keys, registry, sudoers, sshd, compartment payload)
  - ufw: deny new connections from `virbr-whx`, allow DNS/DHCP only
  - usbguard: generates device policy, blocks new devices
  - AIDE: file-integrity DB initialized on first run
  - AppArmor: enabled automatically when already in the kernel LSM list; otherwise prints the required kernel cmdline
  - Wazuh: if `wazuh-agent` is installed, prints the active-response merge step (`compartment/host/wazuh/ossec-ar-snippets.conf` → `ossec.conf`, then restart)

### Manual steps the installer cannot do

- **AppArmor first-time enable**: add `lsm=landlock,lockdown,yama,integrity,apparmor,bpf apparmor=1` to the kernel cmdline, reboot, then `sudo systemctl enable --now apparmor`.
- **Secure Boot**: `sudo sbctl create-keys && sudo sbctl enroll-keys` then reboot and enable SB in firmware setup.
- **TPM-LUKS binding**: `sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/<luks-partition>` so the disk unlocks only on this machine's measured boot.
- **Wazuh manager**: run a Wazuh manager (e.g. a dedicated VM), point `wazuh-agent` at it, then merge the AR snippets.

## Troubleshooting

Field notes from live provisioning — every gotcha hit and fixed — live in [`docs/compartments-bringup.md`](compartments-bringup.md). Read it before a clean rebuild.

- `omarchy compartment <name> status` → both services `active`?
- First boot provisioning log inside guest: `journalctl -u bootstrap-firstboot` / `/var/log/provision.log`
- Prompt path: `omarchy compartment <name> prompt "say ok"` → `ok` through DLP
- Policy refusals are expected for non-allowlisted intents — check `compartment/payload/compartments/<name>.yaml`
- Codex `/v1/responses` may fail on some llama.cpp builds — OpenCode chat completions is the proven path
- Claude Code requires cloud auth — treat as cloud-walled, not local
- virt-customize is upload-only on this stack — all provisioning runs inside the first real boot via `bootstrap-firstboot.service` (qemu-nbd crashes the desktop; never use it for image edits)

## Vault signer (optional crypto compartment)

`omarchy-compartment-vault` builds a Debian cloud-image VM with **no NIC** — the security guarantee. Signing happens over a virtio-serial channel:

- Host side: `compartment/bin/tx-relay` validates the tx schema (to/value/chain_id allowlist), prompts for interactive approval, returns the signature. Reach it via `omarchy compartment <name> vault-sign '<json>'` or `vault-pubkey`.
- Guest side: `clef` (or your chain's signer) + `sign-daemon.py` (`compartment/payload/bin/`, unit `sign-daemon.service`) minding the `/dev/virtio-ports/signer` channel.

Setup: `apt install clef jq socat` in the vault VM, import keys into its keystore (keys live ONLY there — the crypto compartment holds zero key material), enable `sign-daemon.service`. virtio-serial ports are single-open — the daemon must own the port; never `cat` it from a shell.

Migration checklist: generate/import keys in vault-signer → delete key material from any crypto compartment → test unsigned tx → approval prompt → signature → broadcast over Tor.
