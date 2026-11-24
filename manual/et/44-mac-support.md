# Maci tugi

## Omarchy Apple Siliconile

Omarchy Apple Siliconile on Omacomi ametlik lahendus, mis ilmus esimest korda koos Omarchy 4.5-ga. See paigaldatakse macOS-i kõrvale ja sa valid nende kahe vahel, kui sinu Mac käivitub.

Said teate Omarchy Maci kohta? Mine jaotisse [Omarchy Macilt tulek](#coming-from-omarchy-mac).

See töötab neil Macidel:

| Mac | Kiibid |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

M4 ja uuemaid Mace veel ei toetata. M4 tugi on edge-kanalis testimisel ja tuleb järgmisena. Paigaldaja kontrollib sinu Maci enne, kui see midagi muudab.

Igal Apple Silicon Macil, kaasa arvatud M4 ja uuematel, saad Omarchy't käitada virtuaalmasinas [Try Omarchy](https://github.com/omacom/try-omarchy) abil.

### Mida sul vaja on

- macOS 15 Sequoia või uuem ning administraatori konto
- Vaba kettaruumi Omarchy jaoks. Paigaldaja soovitab suuruse ja laseb sul seda muuta.
- Oma Maci varukoopia, toide ja internetiühendus. Paigaldus laadib alla mitu gigabaiti.

### Paigaldamine

Paigaldad macOS-ist. Paigalda Omarchy Installer [Homebrew](https://brew.sh) abil:

```sh
brew install omacom/mac/omarchy
```

Või laadi uusim Omarchy Installer alla selle [väljalasete lehelt](https://github.com/omacom/omarchy-mac-installer/releases) ja ava see.

Paigaldaja kontrollib sinu Maci, näitab sulle plaani ja teeb macOS-i partitsiooni kahandades Omarchy jaoks ruumi. macOS jääb kettale alles ja USB-mäluseadet pole vaja. Kui esimene etapp on valmis, juhendab see sind seadistuse lõpetamisel macOS Recovery's: lülita välja, hoia toitenuppu all, kuni ilmub „Loading startup options“, vali Omarchy ja järgi juhiseid.

Esimesel käivitamisel küsib Omarchy parooli, mis krüpteerib selle ketta. Taastevõtit pole: kui parooli unustad, ei saa sinu Omarchy faile taastada.

Et hiljem Omarchy ja macOS-i vahel vahetada, lülita välja, seejärel hoia toitenuppu all, kuni ilmuvad käivitusvalikud, ja vali üks.

### Omarchy Macilt tulek

Omarchy Mac on nüüd osa Omarchy Apple Siliconile lahendusest ja iga Mac, millel see töötas, on toetatud. Sinu praegune paigaldus töötab edasi ja selle süsteemipaketid uuenevad endiselt, kuid see ei saa enam Omarchy uuendusi. Tähtaega pole ja kohapealset uuendamist pole: teed varukoopia, eemaldad vana paigalduse, paigaldad puhtalt ja taastad. Sammud 2 kuni 5 toimuvad macOS-is, nii et ava see leht oma telefonis enne taaskäivitamist.

1. **Tee varukoopia Omarchy'st, Macist välja.** Vana paigalduse eemaldamine kustutab selle ja macOS ei oska Omarchy ketast lugeda. Kopeeri oma kodukataloog välisele kettale või teise arvutisse, kaasa arvatud SSH- ja GPG-võtmed, brauseri profiilid ja push'imata töö. Salvesta oma pakettide loend käsuga `pacman -Qqe > ~/packages.txt`. Tee varukoopia ka macOS-ist, sest nii eemaldamine kui ka paigaldamine muudavad selle ketta suurust.
2. **Käivita oma Mac macOS-is.** Lülita välja, hoia toitenuppu all, kuni ilmuvad käivitusvalikud, ja vali macOS.
3. **Paigalda Omarchy Installer** nagu näidatud jaotises [Paigaldamine](#installing).
4. **Eemalda vana paigaldus.** Ava Omarchy Installer ja vali Installation > Remove Omarchy. See näitab, mida see kustutab, ja tagastab ruumi macOS-ile. Kui see sinu paigaldust ära ei tunne, peatub see ketast muutmata. Küsi abi [Discordis](https://discord.gg/tXFUdasqhY), selle asemel et partitsioone käsitsi kustutada, mis võib macOS-i kustutada.
5. **Paigalda Omarchy Apple Siliconile** paigaldaja abil.
6. **Taasta oma failid.** Too oma seaded tagasi tükkhaaval, selle asemel et kopeerida kogu `~/.config` uute vaikeseadete peale, sest vanad seaded võivad need üle kirjutada.

### Hea teada

- M1 ja M2 MacBookidel ärata unerežiimist kaane avamisega või toitenupu vajutamisega.
- Küsimused või probleemid: küsi meie [Discordis](https://discord.gg/tXFUdasqhY).

[Paigaldaja README](https://github.com/omacom/omarchy-mac-installer#readme) käsitleb väljalaskekanaleid, paigaldaja uuendamist ja Omarchy eemaldamist.

## Inteli Macid

Lihtsas testis suutsime 2019. aasta MacBook Prol saavutada 36% jõudluse kasvu ainuüksi Omarchy paigaldamisega.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy paigaldamine Macile

Omarchy toetab praegu ainult **ainsa** operatsioonisüsteemina paigaldamist. Paigaldamise ajal tühjendatakse ketas ja MacOS ei ole enam käivitatav.

Soovi korral saad selle hiljem Internet Recovery kaudu siiski taastada.

Selle osa jaoks eeldame, et oled juba üle vaadanud [Alustamise](02-getting-started.md) ja sul on USB-mäluseade valmis. Kui ei ole, mine tee seda kohe.

#### Secure Booti keelamine

Apple'i Secure Booti keelamine on vajalik, et käivitada käivitatav USB, samuti operatsioonisüsteem. Selle keelamiseks tee järgmist:

1. Lülita oma Mac välja
2. Lülita see sisse ja vajuta _kohe_ ning hoia all Command-R, kuni näed laadimisekraani ilmumist
3. Vali oma kasutaja ja sisesta küsimisel oma parool
4. Kui oled taasteekraanil, vali menüüribalt **Utilities > Startup Security Utility**
5. Sisesta autentimiseks küsimisel oma parool
6. Vali Secure Booti valikutest „No Security“
7. Vali External Booti valikutest „Allow booting from external or removable media“

#### Alusta paigaldamist

1. Sisesta USB-mäluseade
2. Taaskäivita oma Mac ja vajuta _kohe_ ning hoia all Option, kuni näed käivitusseadmete ekraani
3. Vali oranž EFI Boot seade
4. Jätka [tavapärase paigaldusega](02-getting-started.md)

Paigaldaja tuvastab Maci riistvara ja rakendab vajalikud parandused automaatselt: Broadcomi Wi-Fi draiverid ja püsivara, FaceTime HD kaamera draiver masinatel, millel on Broadcom 1570 (selle püsivara laaditakse Apple'ilt alla, kui Mac on võrgus, sest paigaldaja töötab võrguühenduseta), SPI klaviatuuri draiver MacBooki mudelitel, mis seda vajavad, ja NVMe unerežiimi parandus neil samadel mudelitel.

### Teadaolevad piirangud

Kogukonna liikmed töötavad pidevalt nende väljakutsete lahenduste kallal, nii et kui need on sinu jaoks probleemsed, liitu meie [Discordis](https://discord.gg/tXFUdasqhY) kanaliga #omarchy-on-other ja vaata, kas nende lahendamiseks on ajakohaseid meetodeid.

#### FaceTime HD kaamera

Kaamera draiver paneb masina kinni jooksma, kui see on laaditud, kui Mac läheb talveunne, nii et see laaditakse enne maha. Seda ei saa maha laadida, kui mõnel rakendusel on kaamera avatud, nii et talveuni tühistatakse teavitusega, mis nimetab rakenduse: sulge see ja mine uuesti talveunne. See hõlmab automaatset talveunne minekut kriitilise aku korral ja suspend-then-hibernate'i, millest keeldutakse enne unerežiimi minekut. Tavalise unerežiimi keelab draiver ise, kui kaamera on avatud, ilma teavituseta.

Kaamera püsivara laaditakse Apple'ilt alla, nii et kaamera töötab alles siis, kui Mac on võrgus käinud. Allalaadimine algab käivitamisel ja seda proovitakse iga 15 minuti järel uuesti, kui probleem on võrgus; kui Apple'i fail on muutunud, see peatub ja ootab Omarchy uuendust. Kui kaamera ei ilmu, ütleb `journalctl -u facetimehd-firmware-fetcher`, miks, `sudo systemctl restart facetimehd-firmware-fetcher` proovib uuesti ja taaskäivitamine laadib draiveri, kui allalaadimine lõppes, kuid kaamerat ikka pole.

#### T1 kiibiga seadmed

Apple T1 kiip toodi turule 2016. aasta lõpus ja seda kasutati ainult Touch Bariga esimese põlvkonna MacBook Pro mudelites.
- MacBook Pro 13-tolline (2016, kaks Thunderbolt 3 porti) – Mudel: A1706
- MacBook Pro 13-tolline (2016, neli Thunderbolt 3 porti) – Mudel: A1708
- MacBook Pro 15-tolline (2016) – Mudel: A1707

#### Teadaolevad probleemid

- Touch Bar ei tööta
- Heli ei tööta

#### T2 kiibiga seadmed

Apple T2 Security Chip toodi turule 2017. aastal. T2 kiibi tootmine lõpetati üleminekuga Apple siliconile (M-seeria kiibid) alates 2020. aastast.

- iMac Pro (2017) – Mudel: A1862
- MacBook Pro 13-tolline (2018, neli Thunderbolt 3 porti) – Mudel: A1989
- MacBook Pro 15-tolline (2018) – Mudel: A1990
- MacBook Air (Retina, 13-tolline, 2018) – Mudel: A1932
- Mac mini (2018) – Mudel: A1998
- MacBook Pro 13-tolline (2019, kaks Thunderbolt 3 porti) – Mudel: A2159
- MacBook Pro 13-tolline (2019, neli Thunderbolt 3 porti) – Mudel: A2178
- MacBook Pro 15-tolline (2019) – Mudel: A1990
- iMac (Retina 5K, 27-tolline, 2020) – Mudel: A2115 (iMac20,1 ja iMac20,2)
- MacBook Pro 13-tolline (2020, kaks Thunderbolt 3 porti) – Mudel: A2265
- MacBook Pro 15-tolline (2020) – Mudel: A1990

Neil mudelitel seadistab paigaldaja automaatselt paigatud `linux-t2` kerneli, T2 heli konfiguratsiooni, Apple'i Broadcomi Wi-Fi/Bluetoothi püsivara ja ventilaatori juhtimise `t2fanrd` kaudu. Touch Bar töötab kerneli sisseehitatud Boot Campi stiilis toel.

#### iMac Retina 5K (2017)

2017. aasta 27-tollisel iMacil pole T2 kiipi, nii et paigaldaja seadistab selle nagu teised Inteli Macid.

- iMac (Retina 5K, 27-tolline, 2017) – Mudel: A1419

#### Teadaolevad probleemid

- Ekraan ei tööta selle omase 5120×2880 eraldusvõimega: paneel koosneb kahest plaadist ja tavapärane draiver valgustab ainult ühte
- Heli ei tööta
- Heleduse reguleerimisel pole mõju
- Unerežiim paneb masina kinni jooksma; sellest taastab ainult toite välja ja uuesti sisse lülitamine

Selle mudeli kogukonna paigaja parandab ekraani, heli ja heleduse: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
