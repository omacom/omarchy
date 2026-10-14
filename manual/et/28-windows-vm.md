# Windowsi virtuaalmasin

Omarchy pakub lihtsat viisi Windowsi käitamiseks Dockeri virtuaalmasina kaudu. Saad selle paigaldada Omarchy menüü (`Super + Space`) jaotise _Paigalda > Windows_ abil.

Sinu masin vajab selleks KVM virtualiseerimist, mida enamik teeb — kuid see on mõnikord BIOS-is välja lülitatud ja paigaldaja ütleb sulle, kui see nii on. Sul läheb vaja ka kettaruumi: mida iganes Windowsile annad, pluss umbes 10GB kujutise enda jaoks.

Paigaldaja küsib, kui palju RAM-i, mitu CPU tuuma ja kui palju ketast üle anda (64GB või rohkem on mõistlik alampiir), seejärel Windowsi kasutajanime ja parooli. Jäta need tühjaks ja saad `docker` / `admin`. Allalaadimine võtab aega — 10-15 minutit on normaalne — ja saad edenemist jälgida brauseris aadressil `http://127.0.0.1:8006`. Brauser küsib enne konsooli avamist sama kasutajanime ja parooli.

 ![windows-vm](images/windows-vm.webp)

## Selle kasutamine

Kui see on paigaldatud, käivita rakenduste käivitajast _Windows_. See käivitab virtuaalmasina, kui see veel ei tööta, ja ühendab su RDP kaudu täisekraanil. Anna külmkäivitusele 15-30 sekundit.

RDP seanss kannab heli, sinu mikrofoni ja jagatud lõikelauda, nii et teksti kopeerimine Linuxi ja Windowsi vahel lihtsalt töötab. Eraldusvõime järgib sinu akent ja Omarchy annab sinu ekraani skaleerimise läbi, nii et see pole HiDPI ekraanil hägune segadus.

Kui sulged RDP akna, lülitub virtuaalmasin automaatselt välja. Kui eelistad selle töötama jätta — ütleme, et sul on seal midagi töötamas — käivita see selle asemel käsuga `omarchy windows vm launch --keep-alive`.

Ülejäänud juhtnupud on samal käsul:

```bash
omarchy windows vm status    # is it running?
omarchy windows vm stop      # shut it down
omarchy windows vm launch    # start and connect
```

## Failide jagamine

Kaust `~/Windows` sinu kodukaustas jagatakse virtuaalmasinaga automaatselt. Pane failid sinna, kui soovid, et need oleksid Windowsile kättesaadavad. Virtuaalmasinal puudub juurdepääs sinu failisüsteemi muule osale, nii et oled Windowsi poolel kõige vastiku eest kaitstud. Selle oma virtuaalketas on saadaval aadressil `~/.windows`.

Need tuttavad koduteed jäävad oma failisüsteemidele. Need võivad olla ka sümbolviidad sinu enda kaustadele, mis on kasulik, kui virtuaalketas elab suuremal kettal. Paigaldaja mõõdab vaba ruumi failisüsteemil, mis tegelikult sisaldab kausta `~/.windows`, mitte tingimata sinu kodukausta sisaldaval failisüsteemil.

Hoia ketta- ja jagatud teid eraldi, kattumatute kaustadena. Eemaldamine tühjendab tahtlikult ketta kausta, kuid säilitab jagatud kausta. Vahetult enne kustutamist teeb Omarchy piiratud ohjelduskontrolli ja keeldub midagi eemaldamast, kui see kontroll aegub või ei suuda tõestada, et kaks puud on eraldi.

Enne virtuaalmasina käivitumist avab ja kinnistab Omarchy need kaks kausta, seejärel ühendab täpsed kausta inode'id bind-mountiga privaatsetele kasutajapõhistele ankrutele kausta `/var/lib/omarchy/windows/mounts` all. Docker näeb ainult neid rootiga kaitstud ankruid. See säilitab kohandatud kettaasukohad, takistades samal ajal teisel sinu nimel töötaval protsessil kontrollitud tee välja vahetamist enne, kui privilegeeritud konteiner seda tarbib. Olemasolevad ketta- ja jagatud kaustad pingutatakse migratsiooni ajal režiimile `0700`, et teised kohalikud kontod ei saaks nende sisu sirvida.

Virtuaalmasina pordid on seotud ainult localhostiga, nii et miski sinu võrgus ei pääse Windowsi masinale ligi. Veebikonsool nõuab ka konfigureeritud Windowsi kasutajanime ja parooli, takistades teiselt kohalikult kontolt virtuaalmasina juhtimist pordi 8006 kaudu.

## Piirangud ja litsentsimine

Selle seadistusega GPU läbipääsu pole, nii et see ei sobi mängimiseks ega videotöötluseks. See on suurepärane viis Microsoft Office'i või kõige muu käitamiseks, mida sul absoluutselt vaja on.

Paigaldatud versioon on Windows 11 Pro, aktiveerimata. Piiratud funktsioonide kasutamiseks vajad oma litsentsivõtit.

Kui see arvuti tuli koos Windowsiga, on OEM-võti endiselt püsivaras ka pärast Omarchy paigaldamist. Prindi see käsuga `omarchy windows key`. See võti on seotud selle masinaga — see aktiveerib Windowsi, mis on sellele riistvarale uuesti paigaldatud, kuid tavaliselt ei aktiveeri see virtuaalmasinat.

Ressursside jaotust saad hiljem muuta, käivitades uuesti `omarchy-windows-vm install`, mis kirjutab virtuaalmasina konfiguratsiooni sinu vastustest ümber. Compose-fail ise elab nüüd aadressil `/var/lib/omarchy/windows/docker-compose.yml` ja kuulub rootile — see on tahtlik, et sinu nimel töötav protsess ei saaks seda ümber kirjutada ega panna privilegeeritud ülesäivitust kogu sinu ketast konteinerisse ühendama. Kui pead seda käsitsi redigeerima (näiteks USB-seadme ühendamiseks), redigeeri seda `sudo` abil ja vaata kõiki valikuid projektis [Dockur Windows](https://github.com/dockur/windows).

Kogu asjast vabanemiseks kasuta Omarchy menüü jaotist _Eemalda > Windows_. See kustutab virtuaalmasina ketta ja kõik selle andmed, nii et veendu, et kõik, millest hoolid, on kõigepealt kaustast `~/Windows` väljas.
