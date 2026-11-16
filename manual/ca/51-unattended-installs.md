# Instal·lacions desateses

La ISO d'Omarchy es pot instal·lar tota sola, sense ningú al teclat. Si l'instal·lador troba una segona unitat amb l'etiqueta `cidata` que contingui els seus fitxers de configuració, els copia, se salta completament l'assistent de configuració i es reinicia tot sol en el sistema acabat. Cap compilació especial de la ISO, cap entrada addicional al menú d'arrencada: sense una unitat així connectada, res no canvia i obtens l'assistent normal.

Això fa que Omarchy sigui fantàstic com a imatge base per a entorns de desenvolupament d'un sol ús: crea una VM a Proxmox o amb Packer, arrenca-la, ves-te'n i entra-hi per SSH. `cidata` és l'etiqueta `NoCloud` de cloud-init, així que totes les eines de virtualització habituals ja saben com connectar una unitat així.

## Els fitxers de configuració

Els fitxers són exactament els que escriu el mateix assistent de l'instal·lador, així que la manera més fàcil d'obtenir un conjunt inicial és fer una instal·lació interactiva (en una VM, per exemple) i copiar el que ha escrit a `/root`:

| Fitxer | Obligatori | Finalitat |
|------|----------|---------|
| `user_configuration.json` | Sí | Disc, nom d'amfitrió, zona horària, teclat |
| `user_credentials.json` | Sí | Nom d'usuari i hash de contrasenya |
| `user_encrypt_installation.txt` | No | `true` quan la configuració conté un bloc `disk_encryption` |
| `authorized_keys` | No | Claus públiques SSH, una per línia |
| `tailscale_authkey` | No | Clau d'autenticació de Tailscale per unir-se a la teva tailnet a la primera arrencada |

Genera el hash de contrasenya per a `user_credentials.json` amb `openssl passwd -6 "yourpassword"`.

El nom i el correu electrònic per als commits de git no formen part de la instal·lació. Configura'ls un cop la màquina estigui en marxa, per SSH per exemple, amb `omarchy setup git --name "Jane Doe" --email jane@example.com`.

També pots deixar-hi un fitxer buit anomenat `defer-provisioning` en lloc de `user_credentials.json`. Això executa la mateixa [instal·lació de preparació per a un altre propietari](02-getting-started.md) que pots activar interactivament: la màquina s'instal·la sense cap dada personal, i qui l'arrenqui primer tria el seu teclat i crea el seu usuari. Aquest és el mode per als equips de creació d'imatges, on la unitat no hauria de portar les credencials de ningú.

## Accés SSH

Quan `authorized_keys` hi és present, la instal·lació configura les claus com a `~/.ssh/authorized_keys` de l'usuari, activa `sshd` i obre el tallafoc per a aquest servei. (Una instal·lació estàndard d'Omarchy inclou openssh amb el servei desactivat i el port tancat, així que una màquina desatesa seria altrament inabastable.) La instal·lació només afegeix les teves claus: no relaxa cap altra configuració d'autenticació del dimoni SSH.

Quan `tailscale_authkey` hi és present, la màquina s'uneix a la teva tailnet a la primera arrencada: Tailscale s'instal·la des dels paquets inclosos a la ISO, el tallafoc permet la interfície de la tailnet i una tasca en segon pla executa la unió tan bon punt la màquina té xarxa de debò, i ho reintenta fins que ho aconsegueix. Fes servir una clau reutilitzable i preautoritzada perquè una sola imatge d'unitat pugui servir per a moltes màquines.

## Creació de la unitat cidata

Qualsevol sistema de fitxers amb l'etiqueta correcta funciona. Una ISO petita és la manera fàcil:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Després connecta-la a la VM juntament amb la ISO d'Omarchy. Aquí tens un exemple complet de Proxmox:

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

L'ordre d'arrencada posa el disc primer a propòsit: el disc buit passa de llarg cap a la ISO a la primera arrencada, i el sistema instal·lat arrenca des del disc per sempre més.

## Dues advertències

Les instal·lacions desateses xifrades no són del tot desateses: algú encara ha d'escriure la frase de pas de LUKS a la primera arrencada. I el bloc `disk_encryption` de `user_configuration.json` conté aquesta frase de pas en text pla, així que tracta una unitat cidata creada a partir d'una instal·lació xifrada com el secret que és.
