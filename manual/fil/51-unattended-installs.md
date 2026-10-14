# Mga Pag-install nang Walang Nagbabantay

Ang Omarchy ISO ay maaaring i-install ang sarili nito nang walang tao sa keyboard. Kung makahanap ang installer ng ikalawang drive na may label na `cidata` na may dala nitong mga file ng konpigurasyon, kinokopya nito ang mga ito, nilalaktawan nang buo ang setup wizard, at nagre-reboot papunta sa natapos na sistema nang kusa. Walang espesyal na build ng ISO, walang dagdag na entry sa menu ng boot — kapag walang nakakabit na ganoong drive, walang nagbabago at makukuha mo ang normal na wizard.

Ginagawa nitong napakahusay ang Omarchy bilang isang base image para sa mga disposable na environment ng dev: gumawa ng VM sa Proxmox o gamit ang Packer, i-boot ito, umalis, mag-SSH in. Ang `cidata` ang label na `NoCloud` ng cloud-init, kaya alam na ng lahat ng karaniwang tool ng virtualization kung paano magkabit ng ganoong drive.

## Ang mga file ng konpigurasyon

Ang mga file ay eksaktong kung ano ang isinusulat ng sariling wizard ng installer, kaya ang pinakamadaling paraan para makakuha ng panimulang hanay ay magpatakbo ng isang interaktibong pag-install (sa isang VM, sabihin nating) at kopyahin kung ano ang isinulat nito sa `/root`:

| File | Kailangan | Layunin |
|------|----------|---------|
| `user_configuration.json` | Oo | Disk, hostname, timezone, keyboard |
| `user_credentials.json` | Oo | Username at hash ng password |
| `user_full_name.txt` | Hindi | Buong pangalan para sa Git |
| `user_email_address.txt` | Hindi | Email para sa Git |
| `user_encrypt_installation.txt` | Hindi | `true` kapag dala ng konpigurasyon ang isang block na `disk_encryption` |
| `authorized_keys` | Hindi | Mga pampublikong key ng SSH, isa bawat linya |
| `tailscale_authkey` | Hindi | Auth key ng Tailscale para sumali sa tailnet mo sa unang boot |

Buuin ang hash ng password para sa `user_credentials.json` gamit ang `openssl passwd -6 "yourpassword"`.

Maaari ka ring maghulog ng walang laman na file na pinangalanang `defer-provisioning` imbes na `user_credentials.json`. Nagpapatakbo iyon ng parehong [pag-install na paghahanda para sa ibang may-ari](02-getting-started.md) na maaari mong i-trigger nang interaktibo: ang makina ay nag-i-install nang walang personal na detalye, at sinumang unang mag-boot nito ang pipili ng kanilang keyboard at gagawa ng kanilang user. Iyon ang mode para sa mga imaging rig, kung saan hindi dapat dalhin ng drive ang mga kredensyal ng sinuman.

## Access sa SSH

Kapag naroroon ang `authorized_keys`, sine-setup ng pag-install ang mga key bilang `~/.ssh/authorized_keys` ng user, pinapagana ang `sshd`, at binubuksan ang firewall para dito. (Ang isang stock na pag-install ng Omarchy ay may kasamang openssh na naka-disable ang serbisyo at sarado ang port, kaya ang isang makinang walang nagbabantay ay hindi sana maaabot kung hindi.) Idinaragdag lang ng pag-install ang mga key mo — hindi nito niluluwagan ang anumang iba pang setting ng awtentikasyon ng SSH daemon.

Kapag naroroon ang `tailscale_authkey`, sa halip ay sumasali ang makina sa tailnet mo sa unang boot: ini-install ang Tailscale mula sa mga naka-bundle na pakete ng ISO, pinapayagan ng firewall ang interface ng tailnet, at isang background job ang nagpapatakbo ng pagsali sa sandaling magkaroon talaga ng network ang makina, na umuulit hanggang sa magtagumpay ito. Gumamit ng isang reusable, pre-authorized na key para ang isang imahe ng drive ay makapaglingkod sa maraming makina.

## Pagbuo ng cidata drive

Gumagana ang anumang filesystem na may tamang label. Ang isang maliit na ISO ang madaling paraan:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Pagkatapos ay ikabit ito sa VM kasama ang Omarchy ISO. Narito ang isang buong halimbawa para sa Proxmox:

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

Sadya ang paglista ng order ng boot sa disk muna: ang walang laman na disk ay dumaraan patungong ISO sa unang boot, at ang naka-install na sistema ay magbu-boot mula sa disk mula noon.

## Dalawang babala

Ang mga naka-encrypt na pag-install nang walang nagbabantay ay hindi ganap na walang nagbabantay — may kailangan pa ring mag-type ng passphrase ng LUKS sa unang boot. At ang block na `disk_encryption` sa `user_configuration.json` ay dala ang passphrase na iyon sa plaintext, kaya ituring ang isang cidata drive na binuo mula sa isang naka-encrypt na pag-install bilang ang sikretong taglay nito.
