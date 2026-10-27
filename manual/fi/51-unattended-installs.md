# Valvomattomat asennukset

Omarchy ISO osaa asentaa itsensä ilman ketään näppäimistön ääressä. Jos asennusohjelma löytää toisen aseman, jonka nimi on `cidata` ja jolla on sen määritystiedostot, se kopioi ne talteen, ohittaa ohjatun asennuksen kokonaan ja käynnistyy itsestään uudelleen valmiiseen järjestelmään. Ei tarvita erikoista ISO-koontia eikä ylimääräistä käynnistysvalikon kohtaa — jos sellaista asemaa ei ole liitetty, mikään ei muutu ja saat normaalin ohjatun asennuksen.

Tämän ansiosta Omarchy sopii erinomaisesti kertakäyttöisten kehitysympäristöjen pohjalevykuvaksi: luo VM Proxmoxissa tai Packerilla, käynnistä se, kävele pois ja ota yhteys SSH:lla. `cidata` on cloud-init `NoCloud` -nimiö, joten kaikki yleiset virtualisointityökalut osaavat jo liittää sellaisen aseman.

## Määritystiedostot

Tiedostot ovat täsmälleen niitä, jotka asennusohjelman oma ohjattu asennus kirjoittaa, joten helpoin tapa saada aloitusjoukko on tehdä yksi interaktiivinen asennus (esimerkiksi VM:ssä) ja kopioida sen `/root`-kansioon kirjoittamat tiedostot:

| Tiedosto | Pakollinen | Tarkoitus |
|------|----------|---------|
| `user_configuration.json` | Kyllä | Levy, isäntänimi, aikavyöhyke, näppäimistö |
| `user_credentials.json` | Kyllä | Käyttäjänimi ja salasanan tiiviste |
| `user_encrypt_installation.txt` | Ei | `true`, kun määrityksessä on `disk_encryption`-lohko |
| `authorized_keys` | Ei | SSH:n julkiset avaimet, yksi riville |
| `tailscale_authkey` | Ei | Tailscale-todennusavain tailnetiisi liittymiseen ensimmäisellä käynnistyksellä |

Luo salasanan tiiviste `user_credentials.json`-tiedostoa varten komennolla `openssl passwd -6 "yourpassword"`.

Git-committeihin käytettävät nimi ja sähköposti eivät kuulu asennukseen. Aseta ne, kun kone on käynnissä, esimerkiksi SSH:n kautta komennolla `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Voit myös pudottaa paikalle tyhjän tiedoston nimeltä `defer-provisioning` tiedoston `user_credentials.json` sijasta. Tämä ajaa saman [valmistele toiselle omistajalle -asennuksen](02-getting-started.md), jonka voit käynnistää interaktiivisesti: kone asennetaan ilman henkilötietoja, ja se, joka käynnistää sen ensimmäisenä, valitsee näppäimistönsä ja luo käyttäjänsä. Tämä on tila levykuvien tekoon tarkoitetuille koneille, joilla aseman ei pidä sisältää kenenkään tunnuksia lainkaan.

## SSH-yhteys

Kun `authorized_keys` on mukana, asennus asettaa avaimet käyttäjän `~/.ssh/authorized_keys`-tiedostoksi, ottaa `sshd`:n käyttöön ja avaa sille palomuurin. (Tavallinen Omarchy-asennus toimittaa openssh:n palvelu poistettuna käytöstä ja portti suljettuna, joten valvomaton kone olisi muuten tavoittamattomissa.) Asennus lisää vain avaimesi — se ei löysennä mitään muita SSH-daemonin todennusasetuksia.

Kun `tailscale_authkey` on mukana, kone liittyy sen sijaan tailnetiisi ensimmäisellä käynnistyksellä: Tailscale asennetaan ISO:n mukana toimitetuista paketeista, palomuuri sallii tailnet-liitännän, ja taustatyö suorittaa liittymisen heti, kun koneella todella on verkko, ja yrittää uudelleen, kunnes se onnistuu. Käytä uudelleenkäytettävää, valmiiksi valtuutettua avainta, jotta yksi asemakuva voi palvella monia koneita.

## cidata-aseman rakentaminen

Mikä tahansa tiedostojärjestelmä oikealla nimiöllä toimii. Pieni ISO on helppo tapa:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Liitä se sitten VM:ään Omarchy ISO:n rinnalle. Tässä on täysi Proxmox-esimerkki:

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

Käynnistysjärjestys listaa levyn ensimmäisenä tarkoituksella: tyhjä levy putoaa läpi ISO:lle ensimmäisellä käynnistyksellä, ja asennettu järjestelmä käynnistyy levyltä siitä lähtien aina.

## Kaksi varoitusta

Salatut valvomattomat asennukset eivät ole täysin valvomattomia — jonkun on silti kirjoitettava LUKS-salasana ensimmäisellä käynnistyksellä. Ja `user_configuration.json`-tiedoston `disk_encryption`-lohko sisältää kyseisen salasanan selväkielisenä, joten käsittele salatusta asennuksesta rakennettua cidata-asemaa sellaisena salaisuutena kuin se on.
