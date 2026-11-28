# Installasjoner uten tilsyn

Omarchy-ISO-en kan installere seg selv uten at noen sitter ved tastaturet. Hvis installasjonsprogrammet finner en ekstra stasjon merket `cidata` med konfigurasjonsfilene sine, kopierer det dem over, hopper over oppsettsveiviseren fullstendig og starter på nytt i det ferdige systemet på egen hånd. Ingen spesiell ISO-bygging, ingen ekstra oppføring i oppstartsmenyen — uten en slik stasjon tilkoblet endres ingenting, og du får den vanlige veiviseren.

Dette gjør Omarchy ypperlig som baseavbilde for forgjengelige utviklingsmiljøer: opprett en VM i Proxmox eller med Packer, start den, gå din vei, logg inn via SSH. `cidata` er cloud-init-etiketten `NoCloud`, så alle de vanlige virtualiseringsverktøyene vet allerede hvordan en slik stasjon kobles til.

## Konfigurasjonsfilene

Filene er nøyaktig det installasjonsprogrammets egen veiviser skriver, så den enkleste måten å få et startsett på er å kjøre én interaktiv installasjon (i en VM, for eksempel) og kopiere det den skrev, til `/root`:

| Fil | Påkrevd | Formål |
|------|----------|---------|
| `user_configuration.json` | Ja | Disk, vertsnavn, tidssone, tastatur |
| `user_credentials.json` | Ja | Brukernavn og passordhash, samt LUKS-passfrasen for en kryptert installasjon |
| `user_encrypt_installation.txt` | Nei | `true` når konfigurasjonen inneholder en `disk_encryption`-blokk |
| `authorized_keys` | Nei | Offentlige SSH-nøkler, én per linje |
| `tailscale_authkey` | Nei | Tailscale-autentiseringsnøkkel for å bli med i tailnet-et ditt ved første oppstart |

Generer passordhashen for `user_credentials.json` med `openssl passwd -6 "yourpassword"`.

Navnet og e-postadressen for git-commits er ikke en del av installasjonen. Sett dem når maskinen er oppe, over SSH for eksempel, med `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Du kan også legge inn en tom fil med navnet `defer-provisioning` i stedet for `user_credentials.json`. Det kjører den samme [installasjonen for klargjøring til en annen eier](02-getting-started.md) som du kan utløse interaktivt: maskinen installeres uten personlige opplysninger, og den som starter den først, velger tastaturet sitt og oppretter brukeren sin. Det er modusen for avbildningsrigger, der stasjonen ikke skal bære noens legitimasjon i det hele tatt.

## Tilgang via SSH

Når `authorized_keys` er til stede, setter installasjonen opp nøklene som brukerens `~/.ssh/authorized_keys`, aktiverer `sshd` og åpner brannmuren for den. (En standard Omarchy-installasjon leveres med openssh med tjenesten deaktivert og porten lukket, så en maskin uten tilsyn ellers ville vært utilgjengelig.) Installasjonen legger bare til nøklene dine — den løsner ikke på noen av SSH-daemonens andre autentiseringsinnstillinger.

Når `tailscale_authkey` er til stede, blir maskinen i stedet med i tailnet-et ditt ved første oppstart: Tailscale installeres fra ISO-ens medfølgende pakker, brannmuren tillater tailnet-grensesnittet, og en bakgrunnsjobb kjører tilkoblingen så snart maskinen faktisk har nettverk, og prøver på nytt til den lykkes. Bruk en gjenbrukbar, forhåndsgodkjent nøkkel, slik at ett stasjonsavbilde kan betjene mange maskiner.

## Bygge cidata-stasjonen

Ethvert filsystem med riktig etikett fungerer. En liten ISO er den enkle måten:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Koble den deretter til VM-en sammen med Omarchy-ISO-en. Her er et fullstendig Proxmox-eksempel:

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

Oppstartsrekkefølgen lister disken først med vilje: den tomme disken faller gjennom til ISO-en ved første oppstart, og det installerte systemet starter fra disk i all fremtid etter det.

## To forbehold

Krypterte installasjoner uten tilsyn er ikke helt uten tilsyn — noen må fortsatt skrive inn LUKS-passfrasen ved første oppstart. Og den passfrasen plasseres på øverste nivå i `user_credentials.json` som `encryption_password` — archinstall leser den der, ikke fra `disk_encryption`-blokken i `user_configuration.json` — så behandle en cidata-stasjon bygget fra en kryptert installasjon som den hemmeligheten den er.
