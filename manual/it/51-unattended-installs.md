# Installazioni non presidiate

L'ISO di Omarchy può installarsi da sola senza nessuno alla tastiera. Se il programma di installazione trova un secondo disco etichettato `cidata` che trasporta i suoi file di configurazione, li copia, salta completamente la procedura guidata di configurazione e si riavvia da solo nel sistema finito. Nessuna build ISO speciale, nessuna voce extra nel menu di avvio: senza un disco del genere collegato, non cambia nulla e ottieni la normale procedura guidata.

Questo rende Omarchy ottimo come immagine di base per ambienti di sviluppo usa e getta: crea una VM in Proxmox o con Packer, avviala, allontanati, accedi via SSH. `cidata` è l'etichetta `NoCloud` di cloud-init, quindi tutti i comuni strumenti di virtualizzazione sanno già come collegare un disco del genere.

## I file di configurazione

I file sono esattamente quelli che scrive la procedura guidata del programma di installazione, quindi il modo più semplice per ottenere una serie di partenza è eseguire un'installazione interattiva (in una VM, per esempio) e copiare ciò che ha scritto in `/root`:

| File | Obbligatorio | Scopo |
|------|----------|---------|
| `user_configuration.json` | Sì | Disco, hostname, fuso orario, tastiera |
| `user_credentials.json` | Sì | Nome utente e hash della password |
| `user_full_name.txt` | No | Nome completo per Git |
| `user_email_address.txt` | No | Email per Git |
| `user_encrypt_installation.txt` | No | `true` quando la configurazione contiene un blocco `disk_encryption` |
| `authorized_keys` | No | Chiavi pubbliche SSH, una per riga |
| `tailscale_authkey` | No | Chiave di autenticazione Tailscale per unirsi alla tailnet al primo avvio |

Genera l'hash della password per `user_credentials.json` con `openssl passwd -6 "yourpassword"`.

Al posto di `user_credentials.json` puoi anche inserire un file vuoto chiamato `defer-provisioning`. Questo esegue la stessa [installazione prepara-per-un-altro-proprietario](02-getting-started.md) che puoi attivare in modo interattivo: la macchina si installa senza dettagli personali e chi la avvia per primo sceglie la propria tastiera e crea il proprio utente. È la modalità per le postazioni di imaging, dove il disco non dovrebbe trasportare le credenziali di nessuno.

## Accesso SSH

Quando è presente `authorized_keys`, l'installazione configura le chiavi come `~/.ssh/authorized_keys` dell'utente, abilita `sshd` e apre il firewall per esso. (Un'installazione Omarchy standard fornisce openssh con il servizio disabilitato e la porta chiusa, quindi una macchina non presidiata sarebbe altrimenti irraggiungibile.) L'installazione aggiunge solo le tue chiavi: non allenta nessuna delle altre impostazioni di autenticazione del demone SSH.

Quando è presente `tailscale_authkey`, la macchina si unisce invece alla tua tailnet al primo avvio: Tailscale viene installato dai pacchetti inclusi nell'ISO, il firewall consente l'interfaccia tailnet e un processo in background esegue l'unione non appena la macchina ha davvero la rete, riprovando finché non riesce. Usa una chiave riutilizzabile e preautorizzata, così un'immagine disco può servire molte macchine.

## Costruire il disco cidata

Qualsiasi filesystem con l'etichetta giusta funziona. Una piccola ISO è il modo semplice:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Poi collegala alla VM accanto all'ISO di Omarchy. Ecco un esempio completo per Proxmox:

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

L'ordine di avvio elenca di proposito il disco per primo: il disco vuoto passa all'ISO al primo avvio e il sistema installato si avvia dal disco da quel momento in poi.

## Due avvertenze

Le installazioni non presidiate crittografate non sono del tutto non presidiate: qualcuno deve comunque digitare la passphrase LUKS al primo avvio. E il blocco `disk_encryption` in `user_configuration.json` trasporta quella passphrase in chiaro, quindi tratta un disco cidata costruito da un'installazione crittografata come il segreto che è.
