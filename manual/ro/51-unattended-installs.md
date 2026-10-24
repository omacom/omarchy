# Instalări nesupravegheate

ISO-ul Omarchy se poate instala singur fără nimeni la tastatură. Dacă programul de instalare găsește o a doua unitate etichetată `cidata` care conține fișierele sale de configurare, le copiază, omite complet asistentul de configurare și repornește singur în sistemul terminat. Nicio construcție specială ISO, nicio intrare suplimentară în meniul de pornire — fără o astfel de unitate atașată, nimic nu se schimbă și primești asistentul normal.

Asta face Omarchy grozav ca imagine de bază pentru medii de dezvoltare de unică folosință: creează o mașină virtuală în Proxmox sau cu Packer, pornește-o, pleacă, intră prin SSH. `cidata` este eticheta cloud-init `NoCloud`, așa că toate instrumentele obișnuite de virtualizare știu deja cum să atașeze o astfel de unitate.

## Fișierele de configurare

Fișierele sunt exact ceea ce scrie propriul asistent al programului de instalare, așa că cel mai ușor mod de a obține un set de pornire este să rulezi o instalare interactivă (să zicem, într-o mașină virtuală) și să copiezi ce a scris în `/root`:

| Fișier | Obligatoriu | Scop |
|------|----------|---------|
| `user_configuration.json` | Da | Disc, nume de gazdă, fus orar, tastatură |
| `user_credentials.json` | Da | Nume de utilizator și hashul parolei |
| `user_full_name.txt` | Nu | Numele complet Git |
| `user_email_address.txt` | Nu | E-mail Git |
| `user_encrypt_installation.txt` | Nu | `true` când configurația conține un bloc `disk_encryption` |
| `authorized_keys` | Nu | Chei publice SSH, câte una pe rând |
| `tailscale_authkey` | Nu | Cheie de autentificare Tailscale pentru alăturarea la tailnetul tău la prima pornire |

Generează hashul parolei pentru `user_credentials.json` cu `openssl passwd -6 "yourpassword"`.

Poți pune și un fișier gol numit `defer-provisioning` în locul `user_credentials.json`. Asta rulează aceeași [instalare de pregătire pentru alt proprietar](02-getting-started.md) pe care o poți declanșa interactiv: mașina se instalează fără detalii personale, iar oricine o pornește prima dată își alege tastatura și își creează utilizatorul. Acesta este modul pentru platformele de imagistică, unde unitatea nu ar trebui să conțină deloc acreditările cuiva.

## Acces SSH

Când `authorized_keys` este prezent, instalarea configurează cheile ca `~/.ssh/authorized_keys` al utilizatorului, activează `sshd` și deschide firewallul pentru acesta. (O instalare Omarchy standard livrează openssh cu serviciul dezactivat și portul închis, așa că o mașină nesupravegheată ar fi altfel de neatins.) Instalarea adaugă doar cheile tale — nu relaxează niciuna dintre celelalte setări de autentificare ale daemonului SSH.

Când `tailscale_authkey` este prezent, mașina se alătură în schimb tailnetului tău la prima pornire: Tailscale este instalat din pachetele incluse în ISO, firewallul permite interfața tailnet, iar o sarcină în fundal rulează alăturarea imediat ce mașina are cu adevărat rețea, reîncercând până reușește. Folosește o cheie reutilizabilă, preautorizată, astfel încât o singură imagine de unitate să poată servi multe mașini.

## Construirea unității cidata

Funcționează orice sistem de fișiere cu eticheta potrivită. Un ISO mic este modul ușor:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Apoi atașează-l la mașina virtuală alături de ISO-ul Omarchy. Iată un exemplu complet Proxmox:

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

Ordinea de pornire listează discul primul în mod intenționat: discul gol trece la ISO la prima pornire, iar sistemul instalat pornește de pe disc de atunci încolo.

## Două avertismente

Instalările nesupravegheate criptate nu sunt complet nesupravegheate — cineva tot trebuie să tasteze fraza de acces LUKS la prima pornire. Iar blocul `disk_encryption` din `user_configuration.json` conține acea frază de acces în text clar, așa că tratează o unitate cidata construită dintr-o instalare criptată ca pe secretul care este.
