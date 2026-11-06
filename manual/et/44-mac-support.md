# Maci tugi

Omarchyl on sisseehitatud tugi **Intel Macidele**. Praegu on paar teadaolevat piirangut, kuid kui sa oled neist teadlik ja need sobivad sulle, saad oma vanadele Macidele Omarchy paigaldamisega uue elu sisse puhuda.

Pane tähele, et M-seeria Macile paigaldamine ei ole praegu otseselt toetatud. Selle seisu kohta saad lähemalt teada kanalil #omarchy-on-other meie [Discordis](https://discord.gg/tXFUdasqhY).

Lihtsas testis suutsime 2019. aasta MacBook Prol saavutada 36% jõudluse kasvu ainuüksi Omarchy paigaldamisega.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy paigaldamine Macile

Omarchy toetab praegu ainult paigaldamist **ainsa** operatsioonisüsteemina. Paigalduse käigus kustutatakse ketas ja MacOS ei ole enam käivitatav.

Soovi korral saad selle hiljem Internet Recovery kaudu siiski taastada.

Selle osa puhul eeldame, et oled juba üle vaadanud [Alustamise](02-getting-started.md) ja sul on USB-ketas valmis. Kui ei ole, tee seda kohe.

#### Secure Booti keelamine

Apple'i Secure Booti keelamine on vajalik nii käivitatava USB-ketta kui ka operatsioonisüsteemi käivitamiseks. Selle keelamiseks tee järgmist:

1. Lülita oma Mac välja
2. Lülita see sisse ja vajuta _kohe_ Command-R ning hoia seda all, kuni näed laadimisekraani ilmumist
3. Vali oma kasutaja ja sisesta küsimisel oma parool
4. Kui oled taasteekraanil, vali menüüribalt **Utilities > Startup Security Utility**
5. Sisesta autentimiseks küsimisel oma parool
6. Vali Secure Booti suvanditest "No Security"
7. Vali External Booti suvanditest "Allow booting from external or removable media"

#### Paigalduse käivitamine

1. Sisesta USB-ketas
2. Taaskäivita oma Mac ja vajuta _kohe_ Option ning hoia seda all, kuni näed käivitusseadmete ekraani
3. Vali oranž EFI Boot seade
4. Jätka [tavapärase paigaldusega](02-getting-started.md)

Paigaldaja tuvastab Maci riistvara ja rakendab vajalikud parandused automaatselt: Broadcomi Wi-Fi draiverid ja püsivara, SPI klaviatuuridraiveri MacBooki mudelitel, mis seda vajavad, ja NVMe unerežiimi paranduse samadele mudelitele.

### Teadaolevad piirangud

Kogukonna liikmed töötavad pidevalt nende väljakutsete lahenduste kallal, nii et kui need on sinu jaoks probleemsed, liitu kanaliga #omarchy-on-other meie [Discordis](https://discord.gg/tXFUdasqhY) ja vaata, kas nende lahendamiseks on ajakohaseid meetodeid.

#### T1 kiibiga seadmed

Apple T1 kiip toodi turule 2016. aasta lõpus ja seda kasutati eranditult esimese põlvkonna Touch Bariga MacBook Pro mudelites.
- MacBook Pro 13-tolline (2016, kaks Thunderbolt 3 porti) – Mudel: A1706
- MacBook Pro 13-tolline (2016, neli Thunderbolt 3 porti) – Mudel: A1708
- MacBook Pro 15-tolline (2016) – Mudel: A1707

#### Teadaolevad probleemid

- Touch Bar ei tööta
- Heli ei tööta

#### T2 kiibiga seadmed

Apple T2 turvakiip toodi turule 2017. aastal. T2 kiibi kasutamine lõpetati üleminekuga Apple siliconile (M-seeria kiibid) alates 2020. aastast.

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

Nendel mudelitel seadistab paigaldaja automaatselt paigatud `linux-t2` kerneli, T2 helikonfiguratsiooni, Apple'i Broadcomi Wi-Fi/Bluetoothi püsivara ja ventilaatori juhtimise `t2fanrd` kaudu. Touch Bar töötab kerneli sisseehitatud Boot Campi stiilis toega.

#### iMac Retina 5K (2017)

2017. aasta 27-tollisel iMacil ei ole T2 kiipi, nii et paigaldaja seadistab selle nagu teised Intel Macid.

- iMac (Retina 5K, 27-tolline, 2017) – Mudel: A1419

#### Teadaolevad probleemid

- Ekraan ei tööta oma loomulikul eraldusvõimel 5120×2880: paneel koosneb kahest plaadist ja tavaline draiver lülitab sisse ainult ühe
- Heli ei tööta
- Heleduse reguleerimisel ei ole mingit mõju
- Unerežiim hangutab masina; sellest taastab ainult toite välja- ja sisselülitamine

Selle mudeli kogukonna paigaja parandab ekraani, heli ja heleduse: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
