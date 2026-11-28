# Uovervågede installationer

Omarchy-ISO'en kan installere sig selv, uden at nogen sidder ved tastaturet. Hvis installationsprogrammet finder et andet drev med mærkaten `cidata`, der indeholder dets konfigurationsfiler, kopierer det dem derfra, springer opsætningsguiden helt over og genstarter af sig selv til det færdige system. Ingen særlig ISO-bygning, ingen ekstra post i opstartsmenuen — uden et sådant drev tilsluttet ændrer intet sig, og du får den normale guide.

Det gør Omarchy oplagt som basisimage til flygtige udviklingsmiljøer: opret en VM i Proxmox eller med Packer, start den, gå din vej, og log ind via SSH. `cidata` er cloud-inits `NoCloud`-mærkat, så alle de almindelige virtualiseringsværktøjer ved allerede, hvordan man tilslutter et sådant drev.

## Konfigurationsfilerne

Filerne er præcis dem, installationsprogrammets egen guide skriver, så den nemmeste måde at få et startsæt på er at køre én interaktiv installation (for eksempel i en VM) og kopiere det, den skrev, til `/root`:

| Fil | Påkrævet | Formål |
|------|----------|---------|
| `user_configuration.json` | Ja | Disk, værtsnavn, tidszone, tastatur |
| `user_credentials.json` | Ja | Brugernavn og adgangskodehash samt LUKS-adgangskoden til en krypteret installation |
| `user_encrypt_installation.txt` | Nej | `true`, når konfigurationen indeholder en `disk_encryption`-blok |
| `authorized_keys` | Nej | Offentlige SSH-nøgler, én pr. linje |
| `tailscale_authkey` | Nej | Tailscale-godkendelsesnøgle til at tilslutte dit tailnet ved første opstart |

Generér adgangskodehashen til `user_credentials.json` med `openssl passwd -6 "yourpassword"`.

Navnet og e-mailen til git-commits er ikke en del af installationen. Indstil dem, når maskinen er oppe at køre, for eksempel via SSH, med `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Du kan også lægge en tom fil ved navn `defer-provisioning` i stedet for `user_credentials.json`. Det kører den samme [installation med klargøring til en anden ejer](02-getting-started.md), som du kan udløse interaktivt: maskinen installeres uden personlige oplysninger, og den, der starter den først, vælger sit tastatur og opretter sin bruger. Det er tilstanden til imaging-rigge, hvor drevet slet ikke bør indeholde nogens loginoplysninger.

## SSH-adgang

Når `authorized_keys` er til stede, sætter installationen nøglerne op som brugerens `~/.ssh/authorized_keys`, aktiverer `sshd` og åbner firewallen for den. (En standardinstallation af Omarchy leveres med openssh, hvor tjenesten er deaktiveret og porten lukket, så en maskine uden opsyn ellers ville være uopnåelig.) Installationen tilføjer kun dine nøgler — den løsner ikke nogen af SSH-dæmonens øvrige indstillinger for godkendelse.

Når `tailscale_authkey` er til stede, tilslutter maskinen sig i stedet dit tailnet ved første opstart: Tailscale installeres fra ISO'ens medfølgende pakker, firewallen tillader tailnet-grænsefladen, og et baggrundsjob kører tilslutningen, så snart maskinen faktisk har netværk, og prøver igen, indtil det lykkes. Brug en genanvendelig, forhåndsgodkendt nøgle, så ét drevimage kan betjene mange maskiner.

## Sådan bygger du cidata-drevet

Ethvert filsystem med den rigtige mærkat fungerer. En lille ISO er den nemme måde:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Slut den derefter til VM'en ved siden af Omarchy-ISO'en. Her er et komplet Proxmox-eksempel:

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

Opstartsrækkefølgen angiver bevidst disken først: den tomme disk falder igennem til ISO'en ved første opstart, og det installerede system starter fra disk for altid derefter.

## To forbehold

Krypterede installationer uden opsyn er ikke helt uden opsyn — nogen skal stadig indtaste LUKS-adgangskoden ved første opstart. Og den adgangskode ligger på øverste niveau i `user_credentials.json` som `encryption_password` — archinstall læser den der, ikke fra `disk_encryption`-blokken i `user_configuration.json` — så behandl et cidata-drev, der er bygget ud fra en krypteret installation, som den hemmelighed, det er.
