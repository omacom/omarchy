# Valvomattomat asennukset

Omarchy-ISO voi asentaa itsensä ilman ketään näppäimistöllä. Jos asennusohjelma löytää toisen aseman nimeltä `cidata`, joka sisältää sen määritystiedostot, se kopioi ne pois, ohittaa asennusvelhon kokonaan ja käynnistää itsensä valmiiseen järjestelmään. Ei erityistä ISO-koontia, ei ylimääräistä käynnistysvalikon kohtaa — ilman ko. asemaa mikään ei muutu ja saat normaalin velhon.

Tämä tekee Omarchysta loistavan peruslevykuvan kertakäyttöisille kehitysympäristöille: luo virtuaalikone Proxmoxissa tai Packerilla, käynnistä se, kävele pois, SSH sisään. `cidata` on cloud-initin `NoCloud`-tunniste, joten kaikki yleiset virtualisointityökalut osaavat jo liittää sellaisen aseman.

## Määritystiedostot

Tiedostot ovat täsmälleen sitä, mitä asennusohjelman oma velho kirjoittaa, joten helpoin tapa saada lähtösarja on ajaa yksi interaktiivinen asennus (esimerkiksi virtuaalikoneessa) ja kopioida se, mitä se kirjoitti kansioon `/root`:

| Tiedosto | Pakollinen | Tarkoitus |
|------|----------|---------|
| `user_configuration.json` | Kyllä | Levy, isäntänimi, aikavyöhyke, näppäimistö |
| `user_credentials.json` | Kyllä | Käyttäjänimi ja salasanan tiiviste |
| `user_full_name.txt` | Ei | Gitin koko nimi |
| `user_email_address.txt` | Ei | Gitin sähköposti |
| `user_encrypt_installation.txt` | Ei | `true`, kun määrityksessä on `disk_encryption`-lohko |
| `authorized_keys` | Ei | SSH-julkiset avaimet, yksi per rivi |
| `tailscale_authkey` | Ei | Tailscalen valtuutusavain tailnetiin liittymistä varten ensikäynnistyksellä |

Luo salasana tiiviste tiedostolle `user_credentials.json` komennolla `openssl passwd -6 "yourpassword"`.

Voit myös pudottaa tyhjän tiedoston nimeltä `defer-provisioning` tiedoston `user_credentials.json` sijaan. Se ajaa saman [valmistele toiselle omistajalle -asennuksen](02-getting-started.md), jonka voit käynnistää interaktiivisesti: kone asentuu ilman henkilökohtaisia tietoja, ja kuka sen ensimmäisenä käynnistää saa valita näppäimistönsä ja luoda käyttäjänsä. Se on tila levykuvaus laitteistoille, joissa asemalla ei pitäisi olla kenenkään tunnistetietoja.

## SSH-käyttöoikeus

Kun `authorized_keys` on läsnä, asennus asettaa avaimet käyttäjän tiedostoksi `~/.ssh/authorized_keys`, ottaa `sshd`:n käyttöön ja avaa sille palomuurin. (Vakio-Omarchy-asennus toimittaa openssh:n palvelu poistettuna käytöstä ja portti suljettuna, joten valvomaton kone olisi muuten tavoittamattomissa.) Asennus lisää vain avaimesi — se ei löysennä mitään SSH-daemonin muista todennusasetuksista.

Kun `tailscale_authkey` on läsnä, kone liittyy sen sijaan tailnetiisi ensimmäisellä käynnistyksellä: Tailscale asennetaan ISO:n mukana toimitetuista paketeista, palomuuri sallii tailnet-liitännän, ja taustatehtävä ajaa liittymisen heti, kun koneella tosiasiallisesti on verkkoyhteys, yrittäen uudelleen, kunnes se onnistuu. Käytä uudelleenkäytettävää, ennakkovaltuutettua avainta, jotta yksi asemakuva voi palvella monia koneita.

## cidata-aseman rakentaminen

Mikä tahansa tiedostojärjestelmä oikealla tunnisteella toimii. Pieni ISO on helppo tapa:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Liitä se sitten virtuaalikoneeseen Omarchy-ISO:n rinnalle. Tässä on koko Proxmox-esimerkki:

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

Käynnistysjärjestys luettelee levyn ensimmäisenä tarkoituksella: tyhjä levy putoaa läpi ISO:on ensimmäisellä käynnistyksellä, ja asennettu järjestelmä käynnistyy levyltä sen jälkeen.

## Kaksi varausta

Salatut valvomattomat asennukset eivät ole täysin valvomattomia — jonkun täytyy silti kirjoittaa LUKS-salasanalause ensimmäisellä käynnistyksellä. Ja `disk_encryption`-lohko tiedostossa `user_configuration.json` sisältää kyseisen salasanalauseen selkokielisenä, joten käsittele salatusta asennuksesta rakennettua cidata-asemaa salaisuutena, joka se on.
