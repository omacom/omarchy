# Valvomattomat asennukset

Omarchy-ISO voi asentaa itsensä ilman ketään näppäimistön ääressä. Jos asennusohjelma löytää toisen aseman, jonka nimiö on `cidata` ja jolla on sen määritystiedostot, se kopioi ne talteen, ohittaa ohjatun asennuksen kokonaan ja käynnistyy uudelleen valmiiseen järjestelmään omatoimisesti. Ei erityistä ISO-koontiversiota, ei ylimääräistä käynnistysvalikon kohtaa — jos sellaista asemaa ei ole liitetty, mikään ei muutu ja saat normaalin ohjatun asennuksen.

Siksi Omarchy sopii erinomaisesti pohjakuvaksi kertakäyttöisiin kehitysympäristöihin: luo VM Proxmoxissa tai Packerilla, käynnistä se, kävele pois ja ota SSH-yhteys sisään. `cidata` on cloud-initin `NoCloud`-nimiö, joten kaikki yleiset virtualisointityökalut osaavat jo liittää sellaisen aseman.

## Määritystiedostot

Tiedostot ovat täsmälleen niitä, jotka asennusohjelman oma ohjattu asennus kirjoittaa, joten helpoin tapa saada aloitusjoukko on tehdä yksi interaktiivinen asennus (vaikkapa VM:ään) ja kopioida, mitä se kirjoitti hakemistoon `/root`:

| Tiedosto | Pakollinen | Tarkoitus |
|------|----------|---------|
| `user_configuration.json` | Kyllä | Levy, isäntänimi, aikavyöhyke, näppäimistö |
| `user_credentials.json` | Kyllä | Käyttäjänimi ja salasanan tiiviste sekä LUKS-salasana salattua asennusta varten |
| `user_encrypt_installation.txt` | Ei | `true`, kun määritys sisältää `disk_encryption`-lohkon |
| `authorized_keys` | Ei | SSH-julkiset avaimet, yksi riville |
| `tailscale_authkey` | Ei | Tailscale-todennusavain tailnetiisi liittymiseen ensimmäisellä käynnistyksellä |

Luo `user_credentials.json`-tiedoston salasanan tiiviste komennolla `openssl passwd -6 "yourpassword"`.

Git-commitien nimi ja sähköpostiosoite eivät kuulu asennukseen. Aseta ne, kun kone on käynnissä, esimerkiksi SSH:n kautta komennolla `omarchy setup git --name "Jane Doe" --email jane@example.com`.

Voit myös pudottaa paikalle tyhjän tiedoston nimeltä `defer-provisioning` tiedoston `user_credentials.json` sijasta. Se ajaa saman [valmistele toiselle omistajalle -asennuksen](02-getting-started.md), jonka voit käynnistää interaktiivisesti: kone asentuu ilman henkilötietoja, ja ensimmäinen käynnistäjä valitsee näppäimistönsä ja luo käyttäjänsä. Se on levykuva-asennuksiin tarkoitettu tila, jossa asemalla ei kuulu olla kenenkään kirjautumistietoja lainkaan.

## SSH-pääsy

Kun `authorized_keys` on läsnä, asennus määrittää avaimet käyttäjän `~/.ssh/authorized_keys`-tiedostoksi, ottaa `sshd`:n käyttöön ja avaa palomuurin sitä varten. (Vakio-Omarchy-asennuksessa openssh toimitetaan palvelu poistettuna käytöstä ja portti suljettuna, joten valvomaton kone olisi muuten tavoittamattomissa.) Asennus lisää vain avaimesi — se ei löysää mitään SSH-taustapalvelun muita todennusasetuksia.

Kun `tailscale_authkey` on läsnä, kone liittyy sen sijaan tailnetiisi ensimmäisellä käynnistyksellä: Tailscale asennetaan ISO:n mukana toimitetuista paketeista, palomuuri sallii tailnet-liitännän, ja taustatyö suorittaa liittymisen heti, kun koneella on oikeasti verkko, ja yrittää uudelleen, kunnes se onnistuu. Käytä uudelleenkäytettävää, etukäteen valtuutettua avainta, jotta yksi aseman levykuva voi palvella monia koneita.

## `cidata`-aseman rakentaminen

Mikä tahansa oikealla nimiöllä varustettu tiedostojärjestelmä toimii. Pieni ISO on helppo tapa:

```bash
mkdir cidata
cp user_configuration.json user_credentials.json authorized_keys cidata/
genisoimage -output cidata.iso -volid cidata -joliet -rock cidata/
```

Liitä se sitten VM:ään Omarchy-ISO:n rinnalle. Tässä on täydellinen Proxmox-esimerkki:

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

Käynnistysjärjestys listaa levyn ensimmäisenä tarkoituksella: tyhjä levy jatkaa ISO:hon ensimmäisellä käynnistyksellä, ja asennettu järjestelmä käynnistyy levyltä siitä lähtien aina.

## Kaksi varausta

Salatut valvomattomat asennukset eivät ole täysin valvomattomia — jonkun on silti kirjoitettava LUKS-salasana ensimmäisellä käynnistyksellä. Ja tuo salasana sijoitetaan `user_credentials.json`-tiedoston ylätasolle nimellä `encryption_password` — archinstall lukee sen sieltä, ei `user_configuration.json`-tiedoston `disk_encryption`-lohkosta — joten kohtele salatusta asennuksesta rakennettua cidata-asemaa sellaisena salaisuutena kuin se on.
