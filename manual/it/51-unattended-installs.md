# Installazioni senza intervento

L'ISO di Omarchy può installarsi da sola, senza nessuno alla tastiera. Se il programma di installazione trova una seconda unità etichettata `cidata` contenente i suoi file di configurazione, li copia, salta completamente la procedura guidata di configurazione e si riavvia da sola nel sistema finito. Nessuna build speciale dell'ISO, nessuna voce aggiuntiva nel menu di avvio: senza un'unità di questo tipo collegata, non cambia nulla e ottieni la normale procedura guidata.

Questo rende Omarchy ottima come immagine di base per ambienti di sviluppo usa e getta: crea una VM in Proxmox o con Packer, avviala, allontanati e accedi via SSH. `cidata` è l'etichetta `NoCloud` di cloud-init, quindi tutti gli strumenti di virtualizzazione più comuni sanno già come collegare un'unità di questo tipo.

## I file di configurazione

I file sono esattamente quelli scritti dalla procedura guidata del programma di installazione, quindi il modo più semplice per ottenere un set di partenza è eseguire un'installazione interattiva (in una VM, per esempio) e copiare ciò che ha scritto in `/root`:

| File | Obbligatorio | Scopo |
|------|----------|---------|
| `user_configuration.json` | Sì | Disco, hostname, fuso orario, tastiera |
| `user_credentials.json` | Sì | Nome utente e hash della password |
| `user_encrypt_installation.txt` | No | `true` quando la configurazione contiene un blocco `disk_encryption` |
| `authorized_keys` | No | Chiavi pubbliche SSH, una per riga |
| `tailscale_authkey` | No | Chiave di autenticazione Tailscale per collegare la macchina alla tua tailnet al primo avvio |

Genera l'hash della password per `user_credentials.json` con `openssl passwd -6 "yourpassword"`.

Il nome e l'email per i commit git non fanno parte dell'installazione. Impostali una volta che la macchina è attiva, via SSH per esempio, con `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Puoi anche inserire un file vuoto chiamato `defer-provisioning` al posto di `user_credentials.json`. Questo esegue la stessa [installazione preparata per un altro proprietario](02-getting-started.md) che puoi avviare in modo interattivo: la macchina si installa senza alcun dettaglio personale, e chi la avvia per primo sceglie la propria tastiera e crea il proprio utente. È la modalità per le postazioni di imaging, dove l'unità non dovrebbe contenere le credenziali di nessuno.

## Accesso SSH

Quando `authorized_keys` è presente, l'installazione configura le chiavi come `~/.ssh/authorized_keys` dell'utente, abilita `sshd` e apre il firewall per esso. (Un'installazione standard di Omarchy include openssh con il servizio disabilitato e la porta chiusa, quindi una macchina installata senza intervento sarebbe altrimenti irraggiungibile.) L'installazione aggiunge solo le tue chiavi: non allenta nessuna delle altre impostazioni di autenticazione del demone SSH.

Quando `tailscale_authkey` è presente, la macchina si collega invece alla tua tailnet al primo avvio: Tailscale viene installato dai pacchetti inclusi nell'ISO, il firewall consente l'interfaccia della tailnet e un processo in background esegue il collegamento non appena la macchina dispone effettivamente di una rete, riprovando finché non riesce. Usa una chiave riutilizzabile e preautorizzata, così un'unica immagine dell'unità può servire molte macchine.

## Creazione dell'unità cidata

Funziona qualsiasi filesystem con l'etichetta giusta. Una piccola ISO è il modo più semplice:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Quindi collegala alla VM insieme all'ISO di Omarchy. Ecco un esempio completo per Proxmox:

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

L'ordine di avvio elenca per primo il disco di proposito: il disco vuoto passa all'ISO al primo avvio, e da lì in poi il sistema installato si avvia sempre dal disco.

## Due avvertenze

Le installazioni cifrate senza intervento non sono completamente senza intervento: qualcuno deve comunque digitare la passphrase LUKS al primo avvio. E il blocco `disk_encryption` in `user_configuration.json` contiene quella passphrase in chiaro, quindi tratta un'unità cidata creata da un'installazione cifrata per il segreto che è.
