# Maci tugi

## Omarchy Apple Siliconile

Omarchy for Apple Silicon on ametlik Omacomi lahendus, mis ilmus esmakordselt koos Omarchy 4.5-ga. See installitakse macOS-i kõrvale ja sa valid nende kahe vahel, kui su Mac käivitub.

Said teate Omarchy Maci kohta? Mine jaotisse [Omarchy Macilt tulemine](#coming-from-omarchy-mac).

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

M4 ja uuemaid Mace veel ei toetata. M4 tugi on edge-kanalil testimises ja tuleb järgmisena. Installer kontrollib su Maci enne, kui see midagi muudab.

Igal Apple Siliconi Macil, ka M4 ja uuemal, saad Omarchyt virtuaalmasinas käitada rakendusega [Try Omarchy](https://github.com/omacom/try-omarchy).

### Mida sul vaja on

- macOS 15 Sequoia või uuem ja administraatori konto
- Vaba kettaruumi Omarchy jaoks. Installer soovitab suuruse ja laseb sul seda muuta.
- Maci varukoopia, toide ja internetiühendus. Installimine laadib alla mitu gigabaiti.

### Installimine

Installid macOS-ist. Installi Omarchy Installer [Homebrew](https://brew.sh) abil:

```sh
brew install omacom/mac/omarchy
```

Või laadi alla uusim Omarchy Installer selle [väljalasete lehelt](https://github.com/omacom/omarchy-mac-installer/releases) ja ava see.

Installer kontrollib su Maci, näitab sulle plaani ja teeb Omarchyle ruumi, kahandades macOS-i partitsiooni. macOS jääb kettale alles ja USB-mäluseadet pole vaja. Kui esimene etapp on valmis, juhatab see sind läbi seadistuse lõpetamise macOS Recoverys: lülita arvuti välja, hoia toitenuppu all, kuni ilmub "Loading startup options", vali Omarchy ja järgi juhiseid.

Esimesel käivitusel küsib Omarchy parooli, mis krüptib selle ketta. Taastevõtit pole: kui parooli unustad, ei saa su Omarchy faile taastada.

Et hiljem Omarchy ja macOS-i vahel vahetada, lülita arvuti välja, seejärel hoia toitenuppu all, kuni ilmuvad käivitusvalikud, ja vali üks.

### Omarchy Macilt tulemine

Omarchy Mac on nüüd osa Omarchy for Apple Siliconist ja iga Mac, millel see töötas, on toetatud. Sinu praegune install töötab edasi ja selle süsteemipaketid uuenevad endiselt, kuid see ei saa enam Omarchy uuendusi. Tähtaega pole ja kohapealset uuendamist pole: teed varukoopia, eemaldad vana installi, installid puhtalt ja taastad. Sammud 2 kuni 5 toimuvad macOS-is, nii et ava see leht oma telefonis enne taaskäivitamist.

1. **Tee Omarchyst varukoopia, Macist välja.** Vana installi eemaldamine kustutab selle ja macOS ei suuda Omarchy ketast lugeda. Kopeeri oma kodukataloog välisele kettale või teise arvutisse, kaasa arvatud SSH- ja GPG-võtmed, brauseri profiilid ja üles laadimata töö. Salvesta oma pakettide loend käsuga `pacman -Qqe > ~/packages.txt`. Tee varukoopia ka macOS-ist, sest nii eemaldamine kui ka installimine muudavad selle ketta suurust.
2. **Käivita Mac macOS-is.** Lülita arvuti välja, hoia toitenuppu all, kuni ilmuvad käivitusvalikud, ja vali macOS.
3. **Installi Omarchy Installer**, nagu on näidatud jaotises [Installimine](#installing).
4. **Eemalda vana install.** Ava Omarchy Installer ja vali Installation > Remove Omarchy. See näitab, mida see kustutab, ja tagastab ruumi macOS-ile. Kui see sinu installi ära ei tunne, peatub see ketast muutmata. Küsi abi [Discordis](https://discord.gg/tXFUdasqhY), selle asemel et partitsioone käsitsi kustutada, mis võib macOS-i ära kustutada.
5. **Installi Omarchy for Apple Silicon** installeri abil.
6. **Taasta oma failid.** Too oma seaded tagasi tükkhaaval, selle asemel et kopeerida kogu `~/.config` uute vaikeseadete peale, sest vanad seaded võivad need üle kirjutada.

### Hea teada

- M1 ja M2 MacBookidel ärata arvuti unerežiimist kaant avades või toitenuppu vajutades.
- Küsimused või probleemid: küsi meie [Discordis](https://discord.gg/tXFUdasqhY).

[Installeri README](https://github.com/omacom/omarchy-mac-installer#readme) käsitleb väljalaskekanaleid, installeri uuendamist ja Omarchy eemaldamist.

## Inteli Macid

Lihtsas testis õnnestus meil 2019. aasta MacBook Prol saavutada 36% jõudluse kasv pelgalt Omarchy installimisega.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy installimine Macile

Omarchy toetab praegu ainult seda, et see on **ainus** installitud OS. Installimise ajal pühitakse ketas puhtaks ja MacOS ei ole enam käivitatav.

Saad selle soovi korral hiljem Internet Recovery kaudu siiski taastada.

Selle osa puhul eeldame, et oled juba üle vaadanud [Alustamine](02-getting-started.md) ja sul on USB-mäluseade valmis. Kui ei ole, tee seda kohe.

#### Secure Booti keelamine

Apple'i Secure Boot tuleb keelata, et käivitada käivitatav USB-mäluseade ja ka OS. Selle keelamiseks tee järgmist:

1. Lülita Mac välja
2. Lülita see sisse ja vajuta _kohe_ ning hoia all Command-R, kuni näed laadimisekraani ilmumist
3. Vali oma kasutaja ja sisesta küsimisel parool
4. Kui oled taasteekraanil, vali menüüribalt **Utilities > Startup Security Utility**
5. Sisesta autentimiseks küsimisel parool
6. Vali Secure Booti valikute hulgast "No Security"
7. Vali External Booti valikute hulgast "Allow booting from external or removable media"

#### Installimise alustamine

1. Sisesta USB-mäluseade
2. Taaskäivita Mac ja vajuta _kohe_ ning hoia all Option, kuni näed käivitusseadmete ekraani
3. Vali oranž EFI Boot seade
4. Jätka [tavalise installimisega](02-getting-started.md)

Installer tuvastab Maci riistvara ja rakendab vajalikud parandused automaatselt: Broadcomi Wi-Fi draiverid ja püsivara, SPI klaviatuuridraiveri nendel MacBooki mudelitel, mis seda vajavad, ja NVMe unerežiimi paranduse samadele mudelitele.

### Teadaolevad piirangud

Kogukonna liikmed töötavad pidevalt nende väljakutsete lahenduste kallal, nii et kui need on sinu jaoks problemaatilised, liitu meie [Discordis](https://discord.gg/tXFUdasqhY) kanaliga #omarchy-on-other ja vaata, kas nende lahendamiseks on ajakohaseid meetodeid.

#### T1-kiibiga seadmed

Apple'i T1-kiip toodi turule 2016. aasta lõpus ja seda kasutati eranditult esimese põlvkonna Touch Bariga MacBook Pro mudelites.
- MacBook Pro 13-tolline (2016, kaks Thunderbolt 3 porti) – Mudel: A1706
- MacBook Pro 13-tolline (2016, neli Thunderbolt 3 porti) – Mudel: A1708
- MacBook Pro 15-tolline (2016) – Mudel: A1707

#### Teadaolevad probleemid

- Touch Bar ei tööta
- Heli ei tööta

#### T2-kiibiga seadmed

Apple'i T2 turvakiip toodi turule 2017. aastal. T2-kiibi tootmine lõpetati üleminekuga Apple Siliconile (M-seeria kiibid) alates 2020. aastast.

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

Nendel mudelitel seadistab installer automaatselt paigatud `linux-t2` kerneli, T2 heli konfiguratsiooni, Apple'i Broadcomi Wi-Fi/Bluetoothi püsivara ja ventilaatori juhtimise `t2fanrd` kaudu. Touch Bar töötab kerneli sisseehitatud Boot Campi stiilis toega.

#### iMac Retina 5K (2017)

2017. aasta 27-tollisel iMacil pole T2-kiipi, nii et installer seadistab selle nagu teised Inteli Macid.

- iMac (Retina 5K, 27-tolline, 2017) – Mudel: A1419

#### Teadaolevad probleemid

- Ekraan ei tööta oma loomulikul eraldusvõimel 5120×2880: paneel on kahest plaadist ja tavapärane draiver paneb tööle ainult ühe
- Heli ei tööta
- Heleduse juhtimine ei mõju
- Unerežiim hangutab masina; selle taastab ainult toite väljalülitamine ja uuesti sisselülitamine

Selle mudeli kogukonna paigaja parandab ekraani, heli ja heleduse: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
