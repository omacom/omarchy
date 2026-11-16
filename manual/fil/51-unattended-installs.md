# Mga Pag-install na Walang Nagbabantay

Kayang i-install ng Omarchy ISO ang sarili nito nang walang tao sa keyboard. Kung makakahanap ang installer ng pangalawang drive na may label na `cidata` na naglalaman ng mga configuration file nito, kokopyahin nito ang mga iyon, lalaktawan nang buo ang setup wizard, at magre-reboot papunta sa tapos nang system nang mag-isa. Walang espesyal na ISO build, walang dagdag na boot menu entry — kung walang ganoong drive na nakakabit, walang magbabago at makukuha mo ang normal na wizard.

Dahil dito, mahusay ang Omarchy bilang base image para sa mga disposable na dev environment: gumawa ng VM sa Proxmox o gamit ang Packer, i-boot ito, umalis, mag-SSH papasok. Ang `cidata` ay ang cloud-init `NoCloud` label, kaya alam na ng lahat ng karaniwang virtualization tooling kung paano magkabit ng ganoong drive.

## Ang mga configuration file

Ang mga file ay eksaktong isinusulat ng sariling wizard ng installer, kaya ang pinakamadaling paraan para makakuha ng panimulang set ay magpatakbo ng isang interactive na install (sa isang VM, halimbawa) at kopyahin ang isinulat nito sa `/root`:

| File | Kinakailangan | Layunin |
|------|----------|---------|
| `user_configuration.json` | Oo | Disk, hostname, timezone, keyboard |
| `user_credentials.json` | Oo | Username at password hash |
| `user_encrypt_installation.txt` | Hindi | `true` kapag may `disk_encryption` block ang configuration |
| `authorized_keys` | Hindi | Mga SSH public key, isa bawat linya |
| `tailscale_authkey` | Hindi | Tailscale auth key para sumali sa tailnet mo sa unang boot |

Buuin ang password hash para sa `user_credentials.json` gamit ang `openssl passwd -6 "yourpassword"`.

Ang pangalan at email para sa mga git commit ay hindi bahagi ng install. Itakda ang mga ito kapag tumatakbo na ang machine, sa SSH halimbawa, gamit ang `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Maaari ka ring maglagay ng walang lamang file na pinangalanang `defer-provisioning` kapalit ng `user_credentials.json`. Pinapatakbo nito ang parehong [install na paghahanda para sa ibang may-ari](02-getting-started.md) na maaari mong paganahin nang interactive: nag-i-install ang machine nang walang personal na detalye, at kung sino ang unang mag-boot nito ang pipili ng kanilang keyboard at gagawa ng kanilang user. Iyon ang mode para sa mga imaging rig, kung saan hindi dapat magdala ang drive ng credentials ng kahit sino.

## Access sa SSH

Kapag naroon ang `authorized_keys`, ise-setup ng install ang mga key bilang `~/.ssh/authorized_keys` ng user, ie-enable ang `sshd`, at bubuksan ang firewall para dito. (May kasamang openssh ang stock na Omarchy install na naka-disable ang service at sarado ang port, kaya hindi maaabot ang isang unattended na machine kung hindi.) Idinaragdag lang ng install ang mga key mo — hindi nito niluluwagan ang alinman sa iba pang authentication setting ng SSH daemon.

Kapag naroon ang `tailscale_authkey`, sasali sa halip ang machine sa tailnet mo sa unang boot: ii-install ang Tailscale mula sa mga bundled na package ng ISO, papayagan ng firewall ang tailnet interface, at magpapatakbo ang isang background job ng pagsali sa sandaling magkaroon talaga ng network ang machine, at uulit ito hanggang magtagumpay. Gumamit ng reusable, pre-authorized na key para makapagsilbi ang isang drive image sa maraming machine.

## Pagbuo ng cidata drive

Gumagana ang anumang filesystem na may tamang label. Ang isang maliit na ISO ang madaling paraan:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Pagkatapos, ikabit ito sa VM kasama ng Omarchy ISO. Narito ang isang buong halimbawa sa Proxmox:

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

Sinasadyang unahin ng boot order ang disk: babagsak ang walang lamang disk papunta sa ISO sa unang boot, at magbu-boot mula sa disk ang naka-install na system magpakailanman pagkatapos noon.

## Dalawang babala

Hindi ganap na unattended ang mga naka-encrypt na unattended install — may kailangan pa ring mag-type ng LUKS passphrase sa unang boot. At dala ng `disk_encryption` block sa `user_configuration.json` ang passphrase na iyon sa plaintext, kaya ituring ang isang cidata drive na binuo mula sa isang naka-encrypt na install bilang ang sikreto na tunay na taglay nito.
