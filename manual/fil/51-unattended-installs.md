# Mga Pag-install na Walang Nagbabantay

Kaya ng Omarchy ISO na i-install ang sarili nito nang walang tao sa keyboard. Kung makahanap ang installer ng pangalawang drive na may label na `cidata` na naglalaman ng mga configuration file nito, kokopyahin nito ang mga iyon, lalaktawan nang buo ang setup wizard, at magre-reboot papunta sa tapos nang sistema nang mag-isa. Walang espesyal na ISO build, walang dagdag na entry sa boot menu — kapag walang ganoong drive na nakakabit, walang magbabago at makukuha mo ang normal na wizard.

Dahil dito, mahusay ang Omarchy bilang base image para sa mga disposable na dev environment: gumawa ng VM sa Proxmox o gamit ang Packer, i-boot ito, umalis ka na, mag-SSH ka na lang papasok. Ang `cidata` ay ang cloud-init `NoCloud` label, kaya alam na ng lahat ng karaniwang virtualization tooling kung paano magkabit ng ganoong drive.

## Ang mga configuration file

Ang mga file ay eksaktong isinusulat ng sariling wizard ng installer, kaya ang pinakamadaling paraan para makakuha ng panimulang set ay magpatakbo ng isang interactive na install (sa isang VM, halimbawa) at kopyahin ang isinulat nito sa `/root`:

| File | Required | Purpose |
|------|----------|---------|
| `user_configuration.json` | Oo | Disk, hostname, timezone, keyboard |
| `user_credentials.json` | Oo | Username at password hash, at ang LUKS passphrase para sa naka-encrypt na install |
| `user_encrypt_installation.txt` | Hindi | `true` kapag may `disk_encryption` block ang configuration |
| `authorized_keys` | Hindi | Mga SSH public key, isa bawat linya |
| `tailscale_authkey` | Hindi | Tailscale auth key para sumali sa tailnet mo sa unang boot |

Buuin ang password hash para sa `user_credentials.json` gamit ang `openssl passwd -6 "yourpassword"`.

Hindi bahagi ng install ang pangalan at email para sa mga git commit. Itakda ang mga iyon kapag umaandar na ang makina, sa pamamagitan ng SSH halimbawa, gamit ang `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Maaari ka ring maglagay ng walang lamang file na pinangalanang `defer-provisioning` bilang kapalit ng `user_credentials.json`. Pinapatakbo nito ang parehong [install na paghahanda para sa ibang may-ari](02-getting-started.md) na maaari mong patakbuhin nang interactive: nag-i-install ang makina nang walang personal na detalye, at kung sino man ang unang mag-boot nito ang pipili ng keyboard niya at gagawa ng user niya. Iyon ang mode para sa mga imaging rig, kung saan hindi dapat maglaman ang drive ng credentials ng kahit sino.

## Pag-access sa SSH

Kapag may `authorized_keys`, itinatakda ng install ang mga key bilang `~/.ssh/authorized_keys` ng user, pinapagana ang `sshd`, at binubuksan ang firewall para dito. (Sa stock na Omarchy install, kasama ang openssh pero naka-disable ang service at sarado ang port, kaya hindi maaabot ang isang makinang walang nagbabantay kung hindi ganito.) Idinaragdag lang ng install ang mga key mo — hindi nito niluluwagan ang alinman sa iba pang setting ng authentication ng SSH daemon.

Kapag may `tailscale_authkey`, sa halip ay sasali ang makina sa tailnet mo sa unang boot: ini-install ang Tailscale mula sa mga bundled na package ng ISO, pinapayagan ng firewall ang tailnet interface, at may background job na magpapatakbo ng pagsali sa sandaling magkaroon na talaga ng network ang makina, at uulit ito hanggang magtagumpay. Gumamit ng reusable at pre-authorized na key para makapagsilbi ang isang drive image sa maraming makina.

## Paggawa ng cidata drive

Gagana ang anumang filesystem na may tamang label. Ang maliit na ISO ang madaling paraan:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Pagkatapos ay ikabit ito sa VM kasama ng Omarchy ISO. Narito ang isang buong halimbawa sa Proxmox:

```bash
qm create 101 --name my-omarchy \
  --bios ovmf --machine q35 --cpu host --cores 4 --memory 8192 \
  --ostype l26 --scsihw virtio-scsi-single \
  --efidisk0 local-lvm:0,efitype=4m,pre-enrolled-keys=0 \
  --scsi0 local-lvm:40,discard=on,iothread=1 \
  --net0 virtio,bridge=vmbr0 --vga virtio --serial0 socket \
  --ide2 local:iso/omarchy.iso,media=cdrom \
  --ide3 local:iso/cidata.iso,media=cdrom \
  --boot order='scsi0;ide2'

qm start 101
```

Sinadya na unahin sa boot order ang disk: ang walang lamang disk ay babagsak papunta sa ISO sa unang boot, at ang naka-install nang sistema ay magbu-boot mula sa disk magpakailanman pagkatapos noon.

## Dalawang babala

Hindi ganap na walang nagbabantay ang mga naka-encrypt na unattended install — may kailangan pa ring mag-type ng LUKS passphrase sa unang boot. At ang passphrase na iyon ay napupunta sa top level ng `user_credentials.json` bilang `encryption_password` — doon ito binabasa ng archinstall, hindi mula sa `disk_encryption` block sa `user_configuration.json` — kaya ituring ang isang cidata drive na ginawa mula sa naka-encrypt na install bilang sikreto na nga ito.
