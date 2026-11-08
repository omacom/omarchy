# AI compartments — bring-up field notes

Hard-won operational notes from live provisioning of the compartment stack. Command names below map to the Omarchy implementation: `omarchy compartment` →
`omarchy compartment`, `omarchy-compartment-mk` → `omarchy-compartment-mk`,
`omarchy-compartment-up` → `omarchy-compartment-up`,
`omarchy-compartment-weights` → `omarchy-compartment-weights`,
`omarchy-compartment-template` → `omarchy-compartment-template`,
`omarchy-compartment-setup` → `omarchy-compartment-setup`,
`omarchy-compartment-vault` → `omarchy-compartment-vault`,
`omarchy-compartment-agent-pack` → `omarchy-compartment-agent-pack`,
`omarchy-compartment-pii` → `omarchy-compartment-pii`,
`omarchy-compartment-drill` → `omarchy-compartment-drill`,
`omarchy compartment <name> vault-sign` → `omarchy compartment <name> vault-sign|vault-pubkey`.
Project payload lives at `$OMARCHY_PATH/compartment` (installed:
`/usr/share/omarchy/compartment`). Companion-repo paths (`$OMARCHY_PATH/compartment`)
below refer to that tree.

## DONE (verified this session)

| Item | State |
|---|---|
| Payload tree | `$OMARCHY_PATH/compartment/compartment/payload/` — vm-exec, agent-sandbox, firejail profile, ModSec DLP rules + BIP39 wordlist, systemd units, sshd config, 3× compartment.yaml, PII denylist template |
| llama-server | Debian-trixie build at `compartment/payload/bin/llama-server` (GLIBC≤2.38 — runs in Whonix); host build also in `~/llama.cpp/build/bin` |
| Weights disks | `llm-weights-data.qcow2` + `llm-weights-verity.qcow2` + `verity-manifest.json` (root hash `c9bae105…`) in `/var/lib/libvirt/images/whonix/` — RO, dm-verity |
| `Whonix-AI-Template` | Domain defined. Overlay `Whonix-AI.qcow2` (100G) provisioned: payload binaries in /usr/local/bin, services enabled, users agent/llmserve/fw, sshd drop-in, packages installed via dpkg (215 debs, only systemd-timesyncd postinst noise) |
| Host router | `omarchy compartment` dispatcher (up/down/attach/agent/push/pull/tunnel/ledger-verify), `omarchy-compartment-mk`, `omarchy-compartment-up` (2-VM governor) |
| Watchdog host side | `compartment/payload/bin/host-seal.sh`, auditd rules, sysctl conf, usbguard notes, deploy script |
| Crypto | `omarchy compartment <name> vault-sign` (socat+jq+kdialog), `the Vault signer section of docs/compartments.md` build guide |
| Plan | `~/.devin/plans/plan-3c818378c9565c7e.md` (full spec) |

## KNOWN-ISSUE notes

- virt-customize/guestfish can't inspect Whonix images — use the qemu-nbd flow in `omarchy-compartment-template (vc path; the qemu-nbd variant is banned — see gotchas)` (max_part=16, e2fsck the overlay first — base ships with dirty journal → mounts `emergency_ro`).
- Whonix apt = `tor+https` via `127.0.0.1:9050` + uwt — for offline provisioning, dpkg from host-downloaded debs (`/tmp/debs`, script `provision-packages.sh`) — apt inside the live VM works normally over Tor.
- qemu-nbd daemons die when the launching exec ends — always attach+mount+work+disconnect inside ONE script run.
- Overlay must inherit base virtual size (no size arg) or GPT breaks.
- systemd-timesyncd postinst error in chroot is cosmetic.
- `passwd -l agent` ran — agent is key-only (intended).

## NEXT STEPS (in order)

1. `sudo bash omarchy-compartment-setup` (sysctl/auditd/ufw/AIDE/usbguard/host-seal)
2. Create first compartment: `sudo omarchy-compartment-mk coding` then `omarchy-compartment-up hermes-coding`
3. First-boot check in VM: `models-mount` → `sha256sum -c` → `llama-server` → firewall :8081
4. Fill `/etc/modsecurity/dlp/pii-denylist.txt` per-VM (your literal strings; root:fw 0600)
5. canary-sigs.txt from your real decoy contents
6. Hermes backend: firstboot extracts `hermes-agent.tar.zst` from /opt/bootstrap → verify `hermes serve --host 127.0.0.1 --port 8765` exists and desktop remote-attach works (fallback: `omarchy compartment <vm> attach` TUI)
7. vault-signer per `the Vault signer section of docs/compartments.md`; migrate crypto keys OFF Whonix-Crypto
8. Secure Boot + TPM-LUKS (interactive — reboot + sbctl enroll + cryptenroll)
9. AppArmor: add `lsm=...apparmor,bpf` to kernel cmdline → reboot
10. identity VM audit (existing Whonix-Workstation): confirm no agent tooling; de-PII host (Brave → identity)
11. Wazuh manager-side AR bindings → host-seal; rt-probe alert wiring
12. Devin CLI onto weights disk or in-VM (Tor); `devin` intent already in coding policy
13. Verification drills — the checklist in the plan §P6

## Files

- Plan: `~/.devin/plans/plan-3c818378c9565c7e.md`
- Project: `$OMARCHY_PATH/compartment/` (payload, scripts, compartment/host/, docs/, ledger/)
- Scripts: `mk-weights-disk.sh`, `mk-ai-template.sh`, `provision-packages.sh`, `mk-ai-vm.sh`, `vm-ai-up.sh`, `omarchy compartment`, `tx-relay`, `deploy-host-hardening.sh`
- Sudo drop-in added: `/etc/sudoers.d/compartment-ai` (NOPASSWD ALL — remove post-build if undesired)

## SESSION 2 UPDATE (build progress)

DONE additionally:
- deploy-host-hardening.sh run: auditd+usbguard ACTIVE, sysctl applied, ufw virbr-whx→host deny, host-seal installed, AIDE+AppArmor installed (AppArmor needs lsm= boot param + reboot)
- hermes-coding VM CREATED + RUNNING: thin overlay on Whonix-AI (per-VM key in agent authorized_keys, forced-command vm-exec)
- Fixed: duplicate NIC removed (mk-ai-vm.sh had added a 2nd whonix-int NIC — breaks Whonix topology)
- Fixed: domain XML volume= (disk source) — was pointing at read-only base; mk-ai-vm.sh patched
- Fixed: image ownership → qemu:qemu; pool-refresh needed after new volume files
- mk-weights-disk/mk-ai-template/mk-ai-vm scripts hardened against all found quirks

PENDING (needs next session):
- VM still not answering ARP/ping after single-NIC fix — likely first-boot delay or ws network config; check `virsh console` or spice display for boot state
- Get IP via `arp -a` / dnsmasq once it settles → write to ~/.config/vmctl/vms
- Then: omarchy compartment hermes-coding status → verify llama-server :8080 + ModSec :8081 + verity mount
- User-run: sbctl enroll+TPM-LUKS (reboot), AppArmor cmdline, pii-denylist strings, Brave→identity, vault-signer keys

## SESSION 3 UPDATE — END-TO-END PROVEN

`omarchy compartment hermes-coding status` WORKS: host→(ufw route allow + nft libvirt chain accepts)→sshd→forced-command vm-exec→whitelisted intents. Refusals enforced: `vm-exec: refused: intent 'x' not in compartment policy`. Verified intents: status (llama-server inactive / context-firewall failed — need service debugging), wipe-memory, git (uwt noise).

### Solved this session (hard-won)
- bootstrap-firstboot circular dep → self-contained (provision→mount→extract); units must be --link'ed into wants (uploads don't enable)
- GRUB boot-mode menu blocks headless → timeout=0 hidden in grub.cfg
- nftables semantics: accept in own table does NOT bypass other chains' rejects → insert INTO `inet filter input` before Whonix's reject
- `{22,8765}` brace expansion broke nft set → `set +B` in ExecStart
- whonix-firewall rebuilds wipe inserts → retry-loop unit (45×2s) After=whonix-firewall
- HOST side was also blocking: ufw `route allow out on virbr-whx to 10.152.152.0/24` + nft accepts in libvirt guest_input/guest_output chains
- authorized_keys: options FIRST (command=... ssh-ed25519 AAAA...) — after-keytype becomes a comment
- diag trick: upload a unit that dumps `ss -tlnp`/`nft list ruleset`/unit status to /root/diag.txt, then virt-cat post-shutdown — in-guest truth without sshd
- journalctl --directory=<virt-copy-out journal> for boot forensics

### Remaining service work in hermes-coding
- llama-server inactive (check models-mount + verity status in-guest)
- context-firewall failed (ModSecurity unit needs debugging — apache vs nginx conf)
- bootstrap.done didn't persist on some boots (verify file now exists; provision re-ran ~60-140s/boot)
- sshd_config.d/50-agent.conf mv failed (sshd_config.d dir didn't exist → mkdir -p needed in provision)
- FAIL:apache-conf same class
- git intent hits uwtwrapper (needs git.anondist-orig or uwt bypass config)
- diag.service left enabled in image (remove or keep for debug)

### Next steps (per plan §P1+)
1. Debug llama-server + context-firewall in-guest (now trivially accessible via vm-exec status/console or add a 'shell' debug intent temporarily)
2. Agent CLIs into template (hermes/opencode/claude/codex/devin) + agent intent
3. Host-side policy gate in omarchy compartment (authoritative yaml on host)
4. vTPM attest intent; egress pinholes per provider
5. vault-signer, identity VM audit, SB+TPM-LUKS, PII literals, Wazuh federation
6. Package as omarchy-compartment* for upstream PR

## SESSION 3b — FULL STACK GREEN

`status` now returns llama-server active + context-firewall active. All P0 blockers resolved:
- models-mount: device IDs were wrong (PCI order: vda=weights-data, vdb=root overlay, vdc=verity) → detect by blkid -L llm-weights + root-disk exclusion; verity verified + mounted
- llama-server: After=models-mount Requires=models-mount; %j→10 threads baked
- context-firewall: apache2 (not nginx); fixes applied in order — ModSec2 syntax (numeric severity, REQUEST_BODY only), rule-ID collision with CRS (900k→80000k), double-include via /etc/modsecurity/*.conf glob (moved rules under dlp/ subdir), stock apache2.service disabled (it grabbed port first), RuntimeDirectory=apache2 for DefaultRuntimeDir, ExecStart=apache2 -DFOREGROUND (no -k start)
- exec bits lost on uploads → --chmod 755 in virt-customize
- DLP phrase files uploaded with real names (pii-denylist.txt, canary-sigs.txt)
- self-healing nft service: bash loop re-inserts coordinator-ssh rule every 10s — survives Whonix firewall rebuilds

## SESSION 3c — POLICY GATE + INTENTS VERIFIED

`omarchy compartment hermes-coding {status,attest,wipe-memory,seal,git}` all work; `omarchy compartment hermes-coding {shell,rm-rf}` → `refused by host policy` BEFORE transmission (two-layer enforcement proven). Registry populated; keys moved to ~/.ssh/vmctl (user-owned); ledger git ownership fixed + safe.directory set.

### More fixes applied
- git + git-man + liberror-perl + tpm2-tools added to debs (git intent → `git version 2.47.3`)
- in-guest-provision: mkdir -p for sshd_config.d/conf-available/conf-enabled (was FAIL:); bootstrap.done sync
- vm-exec: `attest` intent (vTPM PCR read → attestations.log — mechanism works, PCRs empty pending swtpm init)
- vmctl: host-side policy gate — reads authoritative ~/.config/.../compartment/payload/compartments/<vm>.yaml, refuses out-of-policy intents before SSH is even attempted
- vm-seal-local PATH fix (/sbin/poweroff)

### Still open
- pii-denylist.txt — user-supplied literals (example in place)
- agent CLIs (hermes/opencode/claude/codex/devin) into template + agent intent wiring
- vTPM PCRs empty — swtpm needs init/explicit PCR values at VM creation
- egress pinholes per provider (devin declared; claude/opencode need nft rules)
- vault-signer, identity audit, SB+TPM-LUKS, Wazuh federation
- omarchy-compartment* scripts for upstream PR

## SESSION 3d — PROVISION CLOSED OUT

bootstrap.done persists (verified). hermes-agent extracted to /home/agent. Full provision log clean (all phases, all enables, done marker). Basename-upload bug identified as root cause of stale files — uploads keep HOST filename; name them correctly before upload.

### Omarchy upstream files
- bin/omarchy-compartment (omarchy compartment wrapper)
- bin/omarchy-compartment-mk (mk-ai-vm wrapper)
- bin/omarchy-install-compartment-ai (full setup, mirrors omarchy-install-*)
- bin/omarchy-default-compartment (pick default for omarchy-agent routing)

### Still open
- pii-denylist.txt — user literals
- git uwt wrapper noise
- agent intent wiring (hermes-agent extracted; opencode/claude/codex/devin not yet installed)
- vTPM PCRs (swtpm init)
- provider egress pinholes (nft per provider — devin declared)
- vault-signer, identity audit, SB+TPM-LUKS, Wazuh federation

## SESSION 3e — CLOSE-OUT

- vm-exec: `agent` intent added (runs /etc/compartment/default-agent in sandbox, default=hermes); `git` intent bypasses uwt via /usr/lib/git-core/git
- egress-pinhole.service + .nft created and enabled (per-provider outbound allowlist; CIDRs need verification)
- bootstrap.done persists; hermes-agent extracted to /home/agent
- vm-exec exec-bit regressions fixed — uploads reset perms; always --chmod after --upload
- omarchy-compartment* entry points in $OMARCHY_PATH/compartment/bin/

### Still open for next session
- pii-denylist.txt — user literals required
- opencode/claude/codex/devin agent CLIs not yet installed in template
- vTPM PCRs empty — swtpm init needed at VM creation (tpm2-tools installed in guest)
- egress-pinhole CIDRs are placeholders — resolve real provider ranges + load test
- vault-signer build, identity-VM audit, Secure Boot + TPM-LUKS, Wazuh AR bindings

## SESSION 3f — REMAINING CLOSED

- diag.service removed from both images
- egress-pinhole.nft now has real CIDRs (devin 100.23.x/34.x/35.x/44.x, anthropic 160.79.104.10; providers rotate CDN pools — re-resolve periodically)
- omarchy-compartment-pii — edit one file, pushes to all stopped compartment images (root:fw 640 in-guest)
- mk-ai-vm.sh creates /var/lib/swtpm-$NAME per-VM vTPM state (enables measured boot PCRs)
- Whonix-Workstation audit: 0 agent-tooling references — identity VM is clean
- vault-signer.qcow2 + domain defined (no NIC; needs cloud-image provisioning + clef + virtio-serial channel — see the Vault signer section of docs/compartments.md)
- STILL OPEN (needs user/bigger work): real PII strings into fill-pii-denylist, opencode/claude/codex CLI installs, Secure Boot enroll + TPM-LUKS (reboot), Wazuh AR bindings, vault-signer cloud-image provision, egress load-test

## SESSION 3g — PII collector + final scaffolds

- fill-pii-denylist.sh now INTERACTIVE: prompts for your strings, pushes to all stopped images
- Remaining big items stay as next-session scope (documented): opencode/claude/codex installs, vault-signer provision, SB+TPM-LUKS (reboot), Wazuh AR bindings, egress load-test
- hermes-coding is stable: omarchy compartment status works, all intents enforced, dm-verity weights verified, ModSec DLP active

## SESSION 3h — EXECUTION PUSH

- provision-agents.sh uploaded to both images (runs npm-over-Tor agent CLI install at next provision)
- vault-base.qcow2 downloading (debian-13-genericcloud) — once landed, run provision-vault-signer.sh
- provision-vault-signer.sh written (no NIC, virtio-serial channel, swtpm-ready)
- Wazuh AR bindings + drills + SB/TPM-LUKS remain for next session
- NOTE: scp blocked by vm-exec (correct!) — file transfer must use omarchy compartment push/pull intents or image uploads

## SESSION 3i — AGENT PROVISION WIRED

- provision-agents.sh now called from in-guest-provision (was uploaded but never invoked)
- hermes venv bootstrap added (python3 -m venv + pip install -e) — needs python3-pip/venv
- python3-pip/python3-venv/python3.13-venv added to debs + tarball re-uploaded
- firejail `shell none` removed (invalid directive)
- vault-base.qcow2 still downloading — provision-vault-signer.sh ready for when it lands
- OPEN: hermes venv test on next provision; npm-over-Tor agent CLIs are best-effort (slow)

## SESSION 3j — OFFLINE AGENT PACK

npm-over-Tor failed (~50 node-* deps can't resolve). New approach: package-agents.sh bundles host node+agent CLIs (mise installs) -> /tmp/agent-pack.tar.gz (221M) -> uploaded to /opt/bootstrap on both images. Install path: extract into image at provision (add to in-guest-provision) or copy to weights disk. npm/whonix-Tor route abandoned — offline pack is the reliable path.

## SESSION 4 — AGENT CLIS LAND

opencode/claude/codex all inside hermes-coding via offline pack (standalone ELF binaries from host mise installs — npm-over-Tor abandoned). `agent` intent → sandbox → binary works; opencode launched its TUI (hangs non-tty = correct; use `omarchy compartment attach` for PTY). default-agent=opencode. agent intent now cwd-anchors to workspace.

REMAINING: opencode/claude local-model wiring (OpenAI-compatible endpoint → 127.0.0.1:8080 via context-firewall :8081), hermes venv (pip failed — needs deps in pack too), vault-signer base download, Wazuh bindings, SB/TPM-LUKS, pii-denylist strings.

## SESSION 4b — INFERENCE + DLP PROVEN BIDIRECTIONALLY

$ omarchy compartment hermes-coding prompt "reply with the word ok"  ->  ok $ omarchy compartment hermes-coding prompt "...-----BEGIN OPENSSH PRIVATE KEY-----"  ->  403 Forbidden (rule 8000003)

- `prompt` intent: curl -> context-firewall :8081 (apache+ModSec DLP) -> llama :8080 -> Ornith-9B
- BIP39 rule fixed: single-word pmFromFile false-positived on "model" (a BIP39 word!) -> now 11+ consecutive lowercase words (seed-phrase FORMAT)
- opencode/claude/codex standalone binaries installed via offline pack; `agent` intent runs them sandboxed in workspace (TUI needs `omarchy compartment attach`)
- opencode.json config written for local provider (needs @ai-sdk/openai-compatible — opencode hangs fetching it over Tor; offline provider bundling still open)
- bootstrap.done persists; full provision runs clean end-to-end

REMAINING: opencode provider offline bundling (or document TUI attach), hermes venv, vault-signer base+provision, Wazuh bindings, SB/TPM-LUKS, pii strings.

## SESSION 4c — VAULT-SIGNER LIVE

$ tx-relay pubkey                    -> {"status":"pub","pub":"cfedea8c..."} $ tx-relay sign '{valid tx}'  -> approve? y -> {"status":"signed","sig":"2941..."} $ tx-relay sign '{bad tx}'    -> {"status":"error","reason":"schema"}

- vault-signer VM: Debian cloud image, NO NIC, virtio-serial 'signer' channel at /var/lib/libvirt/channels/vault-signer.sock (qemu-bound; socat/scripts need sudo)
- sign-daemon.py: Ed25519 key at /var/lib/vault/signing.key (0600, never leaves VM), schema validation (to/value/chain_id allowlist {1,8453,42161,10}), pending->approve->signed flow
- tx-relay: host-side, same schema check pre-transmission + interactive approval gate
- GOTCHAS: virtio ports are single-open + return EOF when host disconnected (daemon must poll, not spin); host client should be attached when daemon opens the port; socat needs -t or the response races EOF; sign-daemon.service redirects broke on double-open (daemon opens port itself r+b now)
- UEFI: genericcloud boot-loops on SeaBIOS -> domain uses OVMF_CODE.4m.fd
- sign-daemon.py needs python3-cryptography (debs in vault-debs.tar.gz via firstboot)

REMAINING: opencode/claude local-provider offline bundling (TUI works via attach; headless provider needs npm pkg), hermes venv, Wazuh bindings, SB/TPM-LUKS, pii strings, vault-signer->vm-exec sign-request wiring (tx-relay invoked from host side of the sign-request intent)

## SESSION 4d — AGENTIC LOOP PROVEN

$ omarchy compartment hermes-coding agent run "reply with just ok"   ->  build · ornith  ->  ok

Full chain: opencode (firejail sandbox) -> /home/agent/.config/opencode/opencode.json (whitelisted) -> context-firewall :8081 (ModSec DLP) -> llama-server :8080 -> Ornith-9B. Load 7.6 during inference — real local inference, not cloud.

- firejail: `net none` -> `net lo` (loopback only: local model reachable, external egress impossible) + whitelist /home/agent/.config/opencode
- opencode.json: provider local/ornith via @ai-sdk/openai-compatible baseURL http://127.0.0.1:8081/v1 — works offline (provider bundled in binary)
- vault-signer proven: pubkey/sign/schema-reject all work over virtio-serial; omarchy compartment vault-sign/vault-pubkey wired
- gotchas logged: socat -t needed, virtio port EOF-when-host-disconnected, open() needs host attached, genericcloud needs UEFI (OVMF)

REMAINING: hermes venv, claude/codex local-provider configs (same pattern), Wazuh agent install + AR bindings, SB+TPM-LUKS (user reboot), pii strings.

## SESSION 4e — CODEX WIRED (partial)

- `agent` intent now accepts optional agent name: `agent codex exec ...`, `agent opencode run ...`, default=opencode
- codex config.toml: model_provider=local, base_url http://127.0.0.1:8081/v1, wire_api="responses" (chat removed in 0.167)
- .codex dir needed 0777 (app-server socket/logs) — was root-owned from --mkdir
- codex reaches :8081 -> got 403 from BIP39 rule false-positive on its system prompt (12+ lowercase word run) -> rule 8000001 now advisory-only at 18+ words (pass+log, not deny)
- codex /v1/responses: endpoint EXISTS in llama-server 0.9.0-dev, but codex still shows "Reconnecting" — likely payload-shape/timeout/SSE issue on the responses API; opencode fully works against the same path
- git intent: workspace now has git init'd (codex needs a repo)
- vault-signer proven + omarchy compartment vault-sign/vault-pubkey wired

STILL OPEN: codex responses-API compat detail, claude-code (Anthropic format — needs a translator proxy, not OpenAI-compat), hermes venv, Wazuh agent+bindings, SB/TPM-LUKS, pii strings

## SESSION 4f — /v1/responses VERIFIED

`prompt-resp` diagnostic intent: /v1/responses returns HTTP 200 + valid OpenAI Responses output through the DLP firewall. Codex's "Reconnecting" is client-specific (bigger compartment/payload/tools/SSE vs 9B+10vCPU timing), NOT an endpoint problem. opencode is the proven agent path; codex wired but needs client tuning (or a smaller/faster model for responses-API latency).

## Final proven stack
- host -> omarchy compartment (policy gate) -> sshd forced-command vm-exec -> whitelisted intents only
- intents: status, git, prompt, prompt-resp, agent (opencode/claude/codex selector), attest, wipe-memory, seal
- agent run -> opencode -> .config -> DLP :8081 -> llama :8080 -> Ornith-9B -> response
- DLP blocks secrets bidirectionally (SSH-key test 403d, clean prompts pass)
- vault-signer: networkless Ed25519 signer over virtio-serial, schema+human-approval, omarchy compartment vault-sign/vault-pubkey
- dm-verity weights verified; bootstrap.done persists; firejail net=lo sandbox

## Still open (next session)
- codex client tuning (or smaller model for latency); claude needs Anthropic-format translator
- hermes venv; Wazuh agent+AR bindings; SB+TPM-LUKS (user reboot); pii strings (fill-pii-denylist.sh)

## SESSION 4g — CLAUDE WIRED (needs auth/debug)

- /v1/messages (Anthropic format) confirmed in llama-server binary — no translator needed in principle
- /home/agent/.claude/settings.json written (ANTHROPIC_BASE_URL=:8081, AUTH_TOKEN=local, MODEL=ornith) + firejail whitelist .claude
- `agent claude -p` hangs at 0 load — likely auth-check or endpoint-validation loop hitting api.anthropic.com (needs ANTHROPIC_API_KEY handling / --dangerously-skip-permissions / deeper debug next session)
- PROVEN agents: opencode (full loop vs local 9B). codex: reaches :8081 but responses-API latency/client issue. claude: config in place, auth path TBD.
- vault-signer fully proven: pubkey + sign + schema-reject via omarchy compartment over virtio-serial

REMAINING NEXT SESSION: claude auth path, codex client tuning, hermes venv, Wazuh agent+AR, SB/TPM-LUKS (reboot), pii strings

## SESSION 4h — CLAUDE AUTH-WALLED

agent-sandbox now exports ANTHROPIC_BASE_URL/AUTH_TOKEN/API_KEY/MODEL + OPENAI_BASE_URL. `agent claude -p` still hangs at 0 load — claude-code does an auth handshake against api.anthropic.com regardless; it's proprietary and doesn't gracefully take local endpoints. Workaround for later: `claude --dangerously-skip-permissions` or an apiKeyHelper shim, or accept that claude stays a cloud-only agent in this compartment.

CONFIRMED WORKING: opencode (proven end-to-end vs local 9B), codex (wired, /v1/responses verified, client-latency tuning), prompt/prompt-resp intents, vault-signer, status/git/attest/wipe-memory/seal.

## SESSION 4i — CODEX ROOT CAUSE

llama-server returns HTTP 500 on codex's real /v1/responses payload: `"stream":true` + `input:[{"type":"message","role":"developer",...}]` array-shape (33K system prompt). Simple /v1/responses calls work (200 + reasoning output) — it's the message-array/developer-role/stream combo llama.cpp's responses impl rejects. Fix requires llama.cpp upstream or an older codex with wire_api="chat". opencode is the proven agent.

## SESSION 4j — CLOSE-OUT

- hermes venv: needs python3.14 standalone pack (ruamel.yaml.clib pin is >=3.14-only; guest runs 3.13). Next session: python-build-standalone tarball -> pack -> venv in-guest.
- Wazuh: compartment/host/wazuh/ossec-ar-snippets.conf written (compartment-seal AR command + level-12 firing rule + syscheck on compartment paths) — needs wazuh-agent installed on host (AUR/upstream tarball) + AR binary deployed to /var/ossec/active-response/bin/host-seal.sh
- omarchy-compartment-drill: tamper drill (marker file in watched path + ledger check)
- codex: llama.cpp 500s on developer-role+stream /v1/responses payload — upstream limitation; opencode proven
- claude: auth-walled to api.anthropic.com — cloud-only here

PROVEN END-TO-END: omarchy compartment policy gate, forced-command intents (status/git/prompt/prompt-resp/agent/attest/wipe-memory/seal), opencode->local 9B through DLP, DLP bidirectional block/pass, vault-signer virtio-serial sign flow, dm-verity weights, self-healing nft, firejail net=lo sandbox.

## SESSION 5 — HERMES VENV SOLVED

python3.14 standalone (python-build-standalone 3.14.10) + full dep wheels built on host -> 945MB hermes-pack.tar.gz -> extracted to /opt/python314 + /home/agent/hermes-agent/venv at provision. hermes --version runs (v0.23.0, py3.14.10, openai 2.54.0).

- Dep conflict skipped: browser-harness needs pillow 12.3 vs hermes pin 13.0 — excluded
- Firejail whitelists added: /home/agent/hermes-agent, /opt/agent-pack, /opt/python314
- Symlink /usr/local/bin/hermes -> venv/bin/hermes
- ALL 4 AGENTS WIRED: opencode (proven), codex (config, upstream 500), claude (auth-walled), hermes (running)

OPEN: hermes provider config to point at :8081 local model, wazuh agent install, SB/TPM-LUKS, pii strings, codex upstream fix, claude auth shim

## SESSION 5b — HERMES CONFIGURED FOR LOCAL MODEL

- ~/.hermes/config.yaml: providers.compartment -> api http://127.0.0.1:8081/v1, default_model ornith (custom OpenAI-compat provider)
- hermes --version + hermes chat --help both run in-guest (python3.14.10, openai 2.54.0)
- `agent hermes -z` hangs on hermes's interactive session machinery (it's an interactive agent framework — use via `omarchy compartment attach`/TUI, not non-tty single-shot). The local-model provider wiring is in place.
- chown fix: .hermes dir ownership enforced in provision (uid 65534 -> agent)

ALL AGENTS STATUS: opencode (proven end-to-end vs local 9B), hermes (runs, local provider configured, interactive path), codex (wired, upstream 500 on its payload), claude (auth-walled cloud-only).

REMAINING: wazuh agent+bindings, SB/TPM-LUKS, pii strings, codex upstream, hermes interactive verification via attach

## SESSION 6 — WAZUH AGENT LIVE ON HOST

wazuh-agent 4.14.10 (AUR) installed on host -> manager 192.168.122.5 (Wazuh-Monitor's default NIC). ossec.conf: address set, compartment-seal AR command + level-12 active-response + syscheck on compartment paths merged. host-seal.sh deployed to /var/ossec/active-response/bin/. Agent active + enabled (SCA/syscollector/logcollector running). Enrollment TBD — check manager-side auth.

## CONFIRMED: WAZUH FEDERATION LIVE

wazuh-agentd: "(4102): Connected to the server ([192.168.122.5]:1514/tcp)". Host agent enrolled + connected to Wazuh-Monitor. compartment-seal AR + syscheck armed.

## SESSION 6b — HERMES TUI VERIFIED (end-to-end)

omarchy compartment attach -> tmux -> firejail -> hermes TUI -> custom:compartment -> DLP :8081 -> llama-server -> Ornith-9B -> response. Proof: "say ok" -> reasoning stream + "ok". 64K ctx bump applied (hermes requires >=64K).

TUI status: ornith · 11.4K/65.5K ctx · 20 tools · 40 skills · works.
