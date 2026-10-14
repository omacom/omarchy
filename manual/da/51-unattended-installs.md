# Uovervågede installationer

Omarchy-ISO'en kan installere sig selv, uden at nogen sidder ved tastaturet. Hvis installeren finder et andet drev mærket `cidata`, der bærer dens konfigurationsfiler, kopierer den dem af, springer opsætningsguiden helt over og genstarter til det færdige system på egen hånd. Ingen speciel ISO-build, ingen ekstra bootmenupost — uden et sådant drev tilsluttet ændres intet, og du får den normale guide.

Det gør Omarchy fantastisk som et basisimage til engangs-udviklingsmiljøer: opret en VM i Proxmox eller med Packer, boot den, gå væk, SSH ind. `cidata` er cloud-init `NoCloud`-etiketten, så alle de almindelige virtualiseringsværktøjer ved allerede, hvordan man tilslutter et sådant drev.

## Konfigurationsfilerne

Filerne er præcis, hvad installerens egen guide skriver, så den nemmeste måde at få et startsæt på er at køre én interaktiv installation (i en VM, f.eks.) og kopiere, hvad den skrev ind i `/root`:

| Fil | Påkrævet | Formål |
|------|----------|---------|
| `user_configuration.json` | Ja | Disk, værtsnavn, tidszone, tastatur |
| `user_credentials.json` | Ja | Brugernavn og adgangskodehash |
| `user_full_name.txt` | Nej | Git fulde navn |
| `user_email_address.txt` | Nej | Git email |
| `user_encrypt_installation.txt` | Nej | `true`, når konfigurationen bærer en `disk_encryption`-blok |
| `authorized_keys` | Nej | SSH offentlige nøgler, én pr. linje |
| `tailscale_authkey` | Nej | Tailscale auth-nøgle til at joine dit tailnet ved første opstart |

Generer adgangskodehashen til `user_credentials.json` med `openssl passwd -6 "yourpassword"`.

Du kan også droppe en tom fil ved navn `defer-provisioning` i stedet for `user_credentials.json`. Det kører den samme [forbered-til-en-anden-ejer-installation](02-getting-started.md), du kan udløse interaktivt: maskinen installerer uden personlige detaljer, og hvem der end booter den først, vælger sit tastatur og opretter sin bruger. Det er tilstanden til imaging-rigs, hvor drevet slet ikke bør bære nogens legitimationsoplysninger.

## SSH-adgang

Når `authorized_keys` er til stede, sætter installationen nøglerne op som brugerens `~/.ssh/authorized_keys`, aktiverer `sshd` og åbner firewallen for den. (En standard Omarchy-installation leverer openssh med tjenesten deaktiveret og porten lukket, så en uovervåget maskine ellers ville være utilgængelig.) Installationen tilføjer kun dine nøgler — den løsner ikke nogen af SSH-dæmonens andre godkendelsesindstillinger.

Når `tailscale_authkey` er til stede, joiner maskinen i stedet dit tailnet ved første opstart: Tailscale installeres fra ISO'ens medfølgende pakker, firewallen tillader tailnet-grænsefladen, og et baggrundsjob kører tilmeldingen, så snart maskinen faktisk har netværk, og prøver igen, indtil det lykkes. Brug en genbrugelig, forhåndsgodkendt nøgle, så ét drevimage kan betjene mange maskiner.

## Byg cidata-drevet

Ethvert filsystem med den rigtige etiket virker. En lille ISO er den nemme måde:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Tilslut det derefter til VM'en ved siden af Omarchy-ISO'en. Her er et fuldt Proxmox-eksempel:

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

Bootrækkefølgen lister disken først med vilje: den tomme disk falder igennem til ISO'en ved første opstart, og det installerede system booter fra disk derefter.

## To forbehold

Krypterede uovervågede installationer er ikke fuldt uovervågede — nogen skal stadig indtaste LUKS-adgangsfraasen ved første opstart. Og `disk_encryption`-blokken i `user_configuration.json` bærer den adgangsfrase i klartekst, så behandl et cidata-drev bygget fra en krypteret installation som den hemmelighed, det er.
