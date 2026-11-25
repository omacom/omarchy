# Installazioni non presidiate

L'ISO di Omarchy può installarsi da sola senza nessuno alla tastiera. Se il programma di installazione trova una seconda unità con etichetta `cidata` contenente i suoi file di configurazione, li copia, salta completamente la procedura guidata di configurazione e si riavvia da sola nel sistema finito. Nessuna build speciale dell'ISO, nessuna voce aggiuntiva nel menu di avvio: senza un'unità del genere collegata, non cambia nulla e ottieni la normale procedura guidata.

Questo rende Omarchy ottima come immagine di base per ambienti di sviluppo usa e getta: crea una VM in Proxmox o con Packer, avviala, allontanati e accedi via SSH. `cidata` è l'etichetta `NoCloud` di cloud-init, quindi tutti gli strumenti di virtualizzazione più comuni sanno già come collegare un'unità del genere.

## I file di configurazione

I file sono esattamente quelli che scrive la procedura guidata del programma di installazione, quindi il modo più semplice per ottenere un set di partenza è eseguire un'installazione interattiva (in una VM, ad esempio) e copiare ciò che ha scritto in `/root`:

| File | Obbligatorio | Scopo |
|------|----------|---------|
| `user_configuration.json` | Sì | Disco, hostname, fuso orario, tastiera |
| `user_credentials.json` | Sì | Nome utente e hash della password, e passphrase LUKS per un'installazione cifrata |
| `user_encrypt_installation.txt` | No | `true` quando la configurazione contiene un blocco `disk_encryption` |
| `authorized_keys` | No | Chiavi pubbliche SSH, una per riga |
| `tailscale_authkey` | No | Chiave di autenticazione Tailscale per unire la macchina alla tua tailnet al primo avvio |

Genera l'hash della password per `user_credentials.json` con `openssl passwd -6 "yourpassword"`.

Il nome e l'email per i commit git non fanno parte dell'installazione. Impostali una volta che la macchina è attiva, via SSH ad esempio, con `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Puoi anche inserire un file vuoto chiamato `defer-provisioning` al posto di `user_credentials.json`. Questo esegue la stessa [installazione preparata per un altro proprietario](02-getting-started.md) che puoi avviare in modo interattivo: la macchina si installa senza alcun dato personale e chi la avvia per primo sceglie la propria tastiera e crea il proprio utente. È la modalità per le postazioni di imaging, dove l'unità non dovrebbe contenere le credenziali di nessuno.

## Accesso SSH

Quando `authorized_keys` è presente, l'installazione configura le chiavi come `~/.ssh/authorized_keys` dell'utente, abilita `sshd` e apre il firewall per esso. (Un'installazione Omarchy standard include openssh con il servizio disabilitato e la porta chiusa, quindi una macchina non presidiata sarebbe altrimenti irraggiungibile.) L'installazione aggiunge solo le tue chiavi: non allenta nessun'altra impostazione di autenticazione del daemon SSH.

Quando `tailscale_authkey` è presente, la macchina si unisce invece alla tua tailnet al primo avvio: Tailscale viene installato dai pacchetti inclusi nell'ISO, il firewall consente l'interfaccia della tailnet e un processo in background esegue l'unione non appena la macchina ha effettivamente accesso alla rete, riprovando finché non riesce. Usa una chiave riutilizzabile e preautorizzata, così una sola immagine dell'unità può servire molte macchine.

## Creare l'unità cidata

Funziona qualsiasi filesystem con l'etichetta giusta. Una piccola ISO è il modo più semplice:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Poi collegala alla VM insieme all'ISO di Omarchy. Ecco un esempio completo per Proxmox:

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

L'ordine di avvio elenca volutamente il disco per primo: al primo avvio il disco vuoto lascia passare l'avvio all'ISO e da quel momento in poi il sistema installato si avvia sempre dal disco.

## Due avvertenze

Le installazioni cifrate non presidiate non sono del tutto non presidiate: qualcuno deve comunque digitare la passphrase LUKS al primo avvio. E quella passphrase va al livello superiore di `user_credentials.json` come `encryption_password` — archinstall la legge lì, non dal blocco `disk_encryption` in `user_configuration.json` — quindi tratta un'unità cidata creata da un'installazione cifrata come il segreto che è.
