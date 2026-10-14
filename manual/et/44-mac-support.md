# Maci tugi

Omarchyl on sisseehitatud tugi **Inteli Macidele**. Praegu on paar teadaolevat piirangut, aga kui oled neist teadlik ja nendega nõus, saad oma vanadele Macidele Omarchy laadimisega uue elu sisse puhuda.

Pane tähele, et M-seeria Macile paigaldamine pole praegu otse toetatud. Selle seisu kohta saad rohkem teada meie [Discordis](https://discord.gg/tXFUdasqhY) kanalis #omarchy-on-other.

Lihtsas testis saavutasime 2019. aasta MacBook Prol 36% jõudluse kasvu lihtsalt Omarchy paigaldamisega.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Omarchy paigaldamine Macile

Omarchy toetab praegu ainult **ühe** paigaldatud operatsioonisüsteemi olemist. Paigaldamise ajal ketas pühitakse ja MacOS pole enam alglaaditav.

Soovi korral saad selle hiljem Internet Recovery kaudu ikka taastada.

Selle osa jaoks eeldame, et oled [Alustamise](02-getting-started.md) juba läbi vaadanud ja sinu USB-ketas on valmis. Kui ei ole, tee seda kohe.

#### Keela Secure Boot

Alglaaditava USB ja operatsioonisüsteemi alglaadimiseks on vaja keelata Apple'i Secure Boot. Selle keelamiseks tee järgmist:

1. Lülita oma Mac välja
2. Lülita see sisse ja _kohe_ vajuta ja hoia Command-R, kuni näed laadimiskuva ilmumist
3. Vali oma kasutaja ja sisesta parool, kui küsitakse
4. Taastekuval olles vali menüüribalt **Utilities > Startup Security Utility**
5. Sisesta autentimiseks parool, kui küsitakse
6. Vali Secure Boot valikute hulgast „No Security“
7. Vali External Boot valikute hulgast „Allow booting from external or removable media“

#### Alusta paigaldamist

1. Sisesta USB-ketas
2. Taaskäivita oma Mac ja _kohe_ vajuta ja hoia Option, kuni näed alglaadimisseadmete kuva
3. Vali oranž EFI Boot seade
4. Jätka [tavapärase paigaldamisega](02-getting-started.md)

Paigaldaja tuvastab Maci riistvara ja rakendab vajalikud parandused automaatselt: Broadcom Wi-Fi draiverid ja püsivara, SPI klaviatuuri draiveri MacBook mudelitel, mis seda vajavad, ja NVMe uinaku paranduse samadele mudelitele.

### Teadaolevad piirangud

Kogukonna liikmed töötavad pidevalt nende väljakutsete lahenduste kallal, nii et kui need on sinu jaoks probleemsed, liitu meie [Discordis](https://discord.gg/tXFUdasqhY) kanaliga #omarchy-on-other ja vaata, kas nende lahendamiseks on ajakohaseid meetodeid.

#### T1 kiibiga seadmed

Apple T1 kiip võeti kasutusele 2016. aasta lõpus ja seda kasutati ainult esimese põlvkonna Touch Bariga MacBook Pro mudelites.
- MacBook Pro 13-tolline (2016, kaks Thunderbolt 3 porti) – Mudel: A1706
- MacBook Pro 13-tolline (2016, neli Thunderbolt 3 porti) – Mudel: A1708
- MacBook Pro 15-tolline (2016) – Mudel: A1707

#### Teadaolevad probleemid

- Touch Bar ei tööta
- Heli ei tööta

#### T2 kiibiga seadmed

Apple T2 turvakiip võeti kasutusele 2017. aastal. T2 kiip lõpetati koos üleminekuga Apple siliconile (M-seeria kiibid) alates 2020. aastast.

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

Nendel mudelitel seadistab paigaldaja automaatselt paigatud `linux-t2` kerneli, T2 heli seadistuse, Apple'i Broadcom Wi-Fi/Bluetooth püsivara ja ventilaatori juhtimise `t2fanrd` kaudu. Touch Bar töötab kerneli sisseehitatud Boot Campi stiilis toega.
