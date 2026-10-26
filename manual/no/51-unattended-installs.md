# Ubetjente installasjoner

Omarchy-ISO-en kan installere seg selv uten noen ved tastaturet. Hvis installasjonsprogrammet finner en ekstra disk merket `cidata` som bærer konfigurasjonsfilene sine, kopierer det dem av, hopper over oppsettsveiviseren helt og starter på nytt inn i det ferdige systemet på egen hånd. Ingen spesiell ISO-bygg, ingen ekstra oppføring i oppstartsmenyen — uten en slik disk tilkoblet endres ingenting, og du får den vanlige veiviseren.

Dette gjør Omarchy ypperlig som grunnimage for disponible utviklingsmiljøer: opprett en VM i Proxmox eller med Packer, start den, gå din vei, SSH inn. `cidata` er cloud-init `NoCloud`-etiketten, så alle de vanlige virtualiseringsverktøyene vet allerede hvordan de fester en slik disk.

## Konfigurasjonsfilene

Filene er nøyaktig det installasjonsprogrammets egen veiviser skriver, så den enkleste måten å få et startsett på er å kjøre én interaktiv installasjon (i en VM, for eksempel) og kopiere det den skrev, inn i `/root`:

| Fil | Påkrevd | Formål |
|------|----------|---------|
| `user_configuration.json` | Ja | Disk, vertsnavn, tidssone, tastatur |
| `user_credentials.json` | Ja | Brukernavn og passordhash |
| `user_encrypt_installation.txt` | Nei | `true` når konfigurasjonen bærer en `disk_encryption`-blokk |
| `authorized_keys` | Nei | Offentlige SSH-nøkler, én per linje |
| `tailscale_authkey` | Nei | Tailscale-autentiseringsnøkkel for å bli med i tailnet-et ditt ved første oppstart |

Generer passordhashen for `user_credentials.json` med `openssl passwd -6 "yourpassword"`.

Navnet og e-postadressen for git-commits er ikke en del av installasjonen. Angi dem når maskinen er oppe, over SSH for eksempel, med `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Du kan også legge inn en tom fil med navnet `defer-provisioning` i stedet for `user_credentials.json`. Det kjører den samme [installasjonen som klargjøres for en annen eier](02-getting-started.md) som du kan utløse interaktivt: maskinen installeres uten personlige opplysninger, og den som starter den først, velger tastaturet sitt og oppretter brukeren sin. Det er modusen for imaging-rigger, der disken ikke bør bære noens legitimasjon i det hele tatt.

## SSH-tilgang

Når `authorized_keys` er til stede, setter installasjonen opp nøklene som brukerens `~/.ssh/authorized_keys`, aktiverer `sshd` og åpner brannmuren for den. (En standard Omarchy-installasjon leveres med openssh med tjenesten deaktivert og porten lukket, så en ubetjent maskin ellers ville vært utilgjengelig.) Installasjonen legger bare til nøklene dine — den løsner ikke på noen av SSH-daemonens andre autentiseringsinnstillinger.

Når `tailscale_authkey` er til stede, blir maskinen i stedet med i tailnet-et ditt ved første oppstart: Tailscale installeres fra ISO-ens medfølgende pakker, brannmuren tillater tailnet-grensesnittet, og en bakgrunnsjobb kjører tilkoblingen så snart maskinen faktisk har nettverk, og prøver på nytt til den lykkes. Bruk en gjenbrukbar, forhåndsgodkjent nøkkel, så ett diskimage kan betjene mange maskiner.

## Å bygge cidata-disken

Ethvert filsystem med riktig etikett fungerer. En bitteliten ISO er den enkle måten:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Fest den deretter til VM-en ved siden av Omarchy-ISO-en. Her er et fullstendig Proxmox-eksempel:

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

Krypterte ubetjente installasjoner er ikke helt ubetjente — noen må fortsatt taste inn LUKS-passfrasen ved første oppstart. Og `disk_encryption`-blokken i `user_configuration.json` bærer den passfrasen i klartekst, så behandle en cidata-disk bygget fra en kryptert installasjon som den hemmeligheten den er.
