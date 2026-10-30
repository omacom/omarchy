# Instalări nesupravegheate

ISO-ul Omarchy se poate instala singur, fără nimeni la tastatură. Dacă programul de instalare găsește o a doua unitate etichetată `cidata` care conține fișierele sale de configurare, le copiază de pe ea, sare complet peste asistentul de configurare și repornește singur în sistemul finit. Fără o versiune specială de ISO, fără o intrare suplimentară în meniul de pornire — fără o astfel de unitate conectată, nu se schimbă nimic și primești asistentul normal.

Asta face din Omarchy o imagine de bază excelentă pentru medii de dezvoltare de unică folosință: creezi un VM în Proxmox sau cu Packer, îl pornești, pleci de lângă el și intri prin SSH. `cidata` este eticheta cloud-init `NoCloud`, așa că toate instrumentele comune de virtualizare știu deja cum să atașeze o astfel de unitate.

## Fișierele de configurare

Fișierele sunt exact cele pe care le scrie asistentul propriu al programului de instalare, așa că cel mai ușor mod de a obține un set de pornire este să rulezi o instalare interactivă (într-un VM, de exemplu) și să copiezi ce a scris în `/root`:

| Fișier | Obligatoriu | Scop |
|------|----------|---------|
| `user_configuration.json` | Da | Disc, nume de gazdă, fus orar, tastatură |
| `user_credentials.json` | Da | Nume de utilizator și hash al parolei |
| `user_encrypt_installation.txt` | Nu | `true` când configurarea conține un bloc `disk_encryption` |
| `authorized_keys` | Nu | Chei publice SSH, câte una pe linie |
| `tailscale_authkey` | Nu | Cheie de autentificare Tailscale pentru adăugarea în tailnet la prima pornire |

Generează hash-ul parolei pentru `user_credentials.json` cu `openssl passwd -6 "yourpassword"`.

Numele și adresa de e-mail pentru commit-urile git nu fac parte din instalare. Setează-le după ce mașina este pornită, prin SSH de exemplu, cu `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Poți pune și un fișier gol numit `defer-provisioning` în locul lui `user_credentials.json`. Asta rulează aceeași [instalare pentru pregătirea pentru alt proprietar](02-getting-started.md) pe care o poți declanșa interactiv: mașina se instalează fără date personale, iar cine o pornește primul își alege tastatura și își creează utilizatorul. Acesta este modul pentru stațiile de creare a imaginilor, unde unitatea nu ar trebui să conțină deloc datele de autentificare ale nimănui.

## Acces SSH

Când `authorized_keys` este prezent, instalarea configurează cheile ca `~/.ssh/authorized_keys` al utilizatorului, activează `sshd` și deschide firewall-ul pentru el. (O instalare Omarchy standard vine cu openssh cu serviciul dezactivat și portul închis, așa că o mașină nesupravegheată ar fi altfel inaccesibilă.) Instalarea adaugă doar cheile tale — nu slăbește niciuna dintre celelalte setări de autentificare ale demonului SSH.

Când `tailscale_authkey` este prezent, mașina se alătură în schimb tailnet-ului tău la prima pornire: Tailscale este instalat din pachetele incluse în ISO, firewall-ul permite interfața tailnet, iar o sarcină în fundal rulează alăturarea imediat ce mașina are efectiv rețea, reîncercând până reușește. Folosește o cheie reutilizabilă, preautorizată, ca o singură imagine de unitate să poată servi multe mașini.

## Construirea unității cidata

Orice sistem de fișiere cu eticheta corectă funcționează. Un ISO mic este calea ușoară:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Apoi atașează-l la VM alături de ISO-ul Omarchy. Iată un exemplu complet pentru Proxmox:

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

Ordinea de pornire listează intenționat discul primul: discul gol trece mai departe la ISO la prima pornire, iar sistemul instalat pornește de pe disc pentru totdeauna după aceea.

## Două avertismente

Instalările nesupravegheate criptate nu sunt complet nesupravegheate — cineva tot trebuie să tasteze fraza de acces LUKS la prima pornire. Iar blocul `disk_encryption` din `user_configuration.json` conține acea frază de acces în text clar, așa că tratează o unitate cidata construită dintr-o instalare criptată ca pe secretul care este.
