# Uovervåkede installasjoner

Omarchy ISO-en kan installere seg selv uten noen ved tastaturet. Hvis installasjonsprogrammet finner en andre stasjon merket `cidata` som bærer konfigurasjonsfilene sine, kopierer det dem av, hopper over oppsettsveiviseren helt og starter på nytt inn i det ferdige systemet på egen hånd. Ingen spesiell ISO-bygg, ingen ekstra oppstartsmenyoppføring — uten en slik stasjon tilkoblet endres ingenting, og du får den vanlige veiviseren.

Dette gjør Omarchy flott som et basisavbilde for engangs utviklingsmiljøer: opprett en VM i Proxmox eller med Packer, start den opp, gå bort, SSH inn. `cidata` er cloud-init `NoCloud`-etiketten, så alle vanlige virtualiseringsverktøy vet allerede hvordan de skal koble til en slik stasjon.

## Konfigurasjonsfilene

Filene er nøyaktig det installasjonsprogrammets egen veiviser skriver, så den enkleste måten å få et startsett på er å kjøre én interaktiv installasjon (i en VM, for eksempel) og kopiere det den skrev inn i `/root`:

| Fil | Påkrevd | Formål |
|------|----------|---------|
| `user_configuration.json` | Ja | Disk, vertsnavn, tidssone, tastatur |
| `user_credentials.json` | Ja | Brukernavn og passordhash |
| `user_full_name.txt` | Nei | Git fullt navn |
| `user_email_address.txt` | Nei | Git-e-post |
| `user_encrypt_installation.txt` | Nei | `true` når konfigurasjonen bærer en `disk_encryption`-blokk |
| `authorized_keys` | Nei | SSH-offentlige nøkler, én per linje |
| `tailscale_authkey` | Nei | Tailscale-autentiseringsnøkkel for å bli med i tailnet-et ditt ved første oppstart |

Generer passordhashen for `user_credentials.json` med `openssl passwd -6 "yourpassword"`.

Du kan også slippe inn en tom fil kalt `defer-provisioning` i stedet for `user_credentials.json`. Det kjører den samme [klargjør-for-en-annen-eier-installasjonen](02-getting-started.md) du kan utløse interaktivt: maskinen installeres uten personlige opplysninger, og den som starter den først, velger tastaturet sitt og oppretter brukeren sin. Det er modusen for avbildningsrigger, der stasjonen ikke skal bære noens legitimasjon i det hele tatt.

## SSH-tilgang

Når `authorized_keys` er til stede, setter installasjonen nøklene opp som brukerens `~/.ssh/authorized_keys`, aktiverer `sshd` og åpner brannmuren for den. (En standard Omarchy-installasjon leverer openssh med tjenesten deaktivert og porten lukket, så en uovervåket maskin ellers ville vært utilgjengelig.) Installasjonen legger bare til nøklene dine — den løsner ikke noen av SSH-daemonens andre autentiseringsinnstillinger.

Når `tailscale_authkey` er til stede, blir maskinen i stedet med i tailnet-et ditt ved første oppstart: Tailscale installeres fra ISO-ens medfølgende pakker, brannmuren tillater tailnet-grensesnittet, og en bakgrunnsjobb kjører tilmeldingen så snart maskinen faktisk har nettverk, og prøver på nytt til den lykkes. Bruk en gjenbrukbar, forhåndsgodkjent nøkkel slik at ett stasjonsavbilde kan betjene mange maskiner.

## Bygge cidata-stasjonen

Ethvert filsystem med riktig etikett fungerer. En bitteliten ISO er den enkle måten:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Koble den deretter til VM-en ved siden av Omarchy ISO-en. Her er et fullt Proxmox-eksempel:

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

Oppstartsrekkefølgen lister disken først med vilje: den tomme disken faller gjennom til ISO-en ved første oppstart, og det installerte systemet starter fra disk for alltid etterpå.

## To forbehold

Krypterte uovervåkede installasjoner er ikke fullt uovervåkede — noen må fortsatt skrive LUKS-passfrasen ved første oppstart. Og `disk_encryption`-blokken i `user_configuration.json` bærer den passfrasen i klartekst, så behandle en cidata-stasjon bygget fra en kryptert installasjon som den hemmeligheten den er.
