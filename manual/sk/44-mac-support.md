# Podpora Macu

## Omarchy pre Apple Silicon

Omarchy pre Apple Silicon je oficiálne riešenie spoločnosti Omacom, ktoré bolo prvýkrát vydané spolu s Omarchy 4.5. Inštaluje sa vedľa macOS a pri spustení Macu si vyberiete medzi týmito dvoma systémami.

Dostali ste oznámenie o Omarchy Mac? Prejdite na [Prechod z Omarchy Mac](#coming-from-omarchy-mac).

Beží na týchto Macoch:

| Mac | Čipy |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Macy s M4 a novšie zatiaľ nie sú podporované. Podpora M4 sa testuje na edge kanáli a príde ako ďalšia. Inštalátor skontroluje váš Mac skôr, ako čokoľvek zmení.

Na akomkoľvek Macu s Apple Silicon, vrátane M4 a novších, môžete Omarchy spustiť vo virtuálnom počítači pomocou [Try Omarchy](https://github.com/omacom/try-omarchy).

### Čo potrebujete

- macOS 15 Sequoia alebo novší a účet správcu
- Voľné miesto na disku pre Omarchy. Inštalátor navrhne veľkosť a umožní vám ju zmeniť.
- Zálohu svojho Macu, napájanie a internetové pripojenie. Inštalácia sťahuje niekoľko gigabajtov.

### Inštalácia

Inštalujete z macOS. Omarchy Installer nainštalujte pomocou [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Alebo si stiahnite najnovší Omarchy Installer z jeho [stránky vydaní](https://github.com/omacom/omarchy-mac-installer/releases) a otvorte ho.

Inštalátor skontroluje váš Mac, ukáže vám plán a uvoľní miesto pre Omarchy zmenšením oddielu macOS. macOS zostáva na disku a nie je potrebný žiadny USB disk. Po dokončení prvej fázy vás prevedie dokončením nastavenia v macOS Recovery: vypnite počítač, podržte tlačidlo napájania, kým sa nezobrazí „Loading startup options“, vyberte Omarchy a postupujte podľa krokov.

Pri prvom spustení si Omarchy vyžiada heslo, ktoré šifruje jeho disk. Neexistuje žiadny kľúč na obnovu: ak heslo zabudnete, vaše súbory v Omarchy sa nebudú dať obnoviť.

Ak chcete neskôr prepínať medzi Omarchy a macOS, vypnite počítač, potom podržte tlačidlo napájania, kým sa nezobrazia možnosti spustenia, a vyberte jeden zo systémov.

### Prechod z Omarchy Mac

Omarchy Mac je teraz súčasťou Omarchy pre Apple Silicon a každý Mac, na ktorom bežal, je podporovaný. Vaša aktuálna inštalácia zostáva funkčná a jej systémové balíky sa naďalej aktualizujú, ale už nedostáva žiadne aktualizácie Omarchy. Neexistuje žiadny termín ani aktualizácia na mieste: zálohujete, odstránite starú inštaláciu, nainštalujete nanovo a obnovíte. Kroky 2 až 5 prebiehajú v macOS, preto si túto stránku otvorte na telefóne skôr, ako reštartujete počítač.

1. **Zálohujte z Omarchy, mimo Macu.** Odstránenie starej inštalácie ju vymaže a macOS nedokáže prečítať disk Omarchy. Skopírujte svoj domovský priečinok na externý disk alebo do iného počítača, vrátane kľúčov SSH a GPG, profilov prehliadača a neodoslanej práce. Zoznam balíkov uložte pomocou `pacman -Qqe > ~/packages.txt`. Zálohujte aj macOS, pretože odstránenie aj inštalácia menia veľkosť jeho disku.
2. **Spustite svoj Mac v macOS.** Vypnite počítač, podržte tlačidlo napájania, kým sa nezobrazia možnosti spustenia, a vyberte macOS.
3. **Nainštalujte Omarchy Installer** tak, ako je uvedené v časti [Inštalácia](#installing).
4. **Odstráňte starú inštaláciu.** Otvorte Omarchy Installer a vyberte Installation > Remove Omarchy. Ukáže vám, čo vymaže, a vráti miesto systému macOS. Ak vašu inštaláciu nerozpozná, zastaví sa bez zmeny disku. Požiadajte o pomoc na [Discord](https://discord.gg/tXFUdasqhY), namiesto toho, aby ste oddiely mazali ručne, čo môže vymazať macOS.
5. **Nainštalujte Omarchy pre Apple Silicon** pomocou inštalátora.
6. **Obnovte svoje súbory.** Nastavenia vracajte postupne po častiach, namiesto toho, aby ste celé `~/.config` skopírovali cez nové predvolené nastavenia, pretože staré nastavenia ich môžu prepísať.

### Dobré vedieť

- Na MacBookoch s M1 a M2 prebudíte počítač z režimu spánku otvorením veka alebo stlačením tlačidla napájania.
- Otázky alebo problémy: pýtajte sa na našom [Discord](https://discord.gg/tXFUdasqhY).

[README inštalátora](https://github.com/omacom/omarchy-mac-installer#readme) pokrýva kanály vydaní, aktualizáciu inštalátora a odstraňovanie Omarchy.

## Macy s čipom Intel

V jednoduchom teste sa nám podarilo dosiahnuť 36 % nárast výkonu na MacBooku Pro z roku 2019 len nainštalovaním Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Inštalácia Omarchy na Macu

Omarchy momentálne podporuje iba to, že je **jediným** nainštalovaným OS. Počas inštalácie sa disk vymaže a MacOS už nebude možné spustiť.

Neskôr ho stále môžete obnoviť cez Internet Recovery, ak budete chcieť.

V tejto časti budeme predpokladať, že ste si už prečítali [Začíname](02-getting-started.md) a máte pripravený USB disk. Ak nie, urobte to teraz.

#### Vypnutie Secure Boot

Na spustenie bootovateľného USB, ako aj OS, je potrebné vypnúť Apple Secure Boot. Ak ho chcete vypnúť, postupujte takto:

1. Vypnite svoj Mac
2. Zapnite ho a _okamžite_ stlačte a podržte Command-R, kým sa nezobrazí načítavacia obrazovka
3. Vyberte svojho používateľa a po vyzvaní zadajte heslo
4. Keď ste na obrazovke obnovy, zvoľte z panela ponúk **Utilities > Startup Security Utility**
5. Po vyzvaní na overenie zadajte heslo
6. Z možností Secure Boot zvoľte „No Security“
7. Z možností External Boot zvoľte „Allow booting from external or removable media“

#### Spustenie inštalácie

1. Vložte USB disk
2. Reštartujte svoj Mac a _okamžite_ stlačte a podržte Option, kým sa nezobrazí obrazovka so spúšťacími zariadeniami
3. Vyberte oranžové zariadenie EFI Boot
4. Pokračujte v [inštalácii ako zvyčajne](02-getting-started.md)

Inštalátor rozpozná hardvér Macu a automaticky použije potrebné opravy: ovládače a firmvér Broadcom Wi-Fi, ovládač kamery FaceTime HD na počítačoch s Broadcom 1570 (jej firmvér sa stiahne od spoločnosti Apple, keď je Mac online, pretože inštalátor funguje offline), ovládač klávesnice SPI na modeloch MacBook, ktoré ho potrebujú, a opravu pozastavenia NVMe pre tie isté modely.

### Známe obmedzenia

Členovia komunity neustále pracujú na riešeniach týchto problémov, takže ak sú pre vás problematické, pripojte sa k #omarchy-on-other na našom [Discord](https://discord.gg/tXFUdasqhY) a zistite, či existujú nejaké aktuálne spôsoby ich vyriešenia.

#### Kamera FaceTime HD

Ovládač kamery pri načítaní počas hibernácie Macu spôsobí zamrznutie počítača, preto sa najprv odpojí. Nedá sa odpojiť, kým má nejaká aplikácia otvorenú kameru, preto sa hibernácia zruší oznámením s názvom aplikácie: zatvorte ju a hibernujte znova. To platí aj pre automatickú hibernáciu pri kritickej úrovni batérie a pre suspend-then-hibernate, ktorá sa odmietne ešte pred pozastavením. Bežné pozastavenie odmietne samotný ovládač, kým je kamera otvorená, bez oznámenia.

Firmvér kamery sa sťahuje od spoločnosti Apple, takže kamera funguje až vtedy, keď bol Mac online. Sťahovanie sa spustí pri štarte a opakuje sa každých 15 minút, kým je problémom sieť; ak sa súbor spoločnosti Apple zmenil, zastaví sa a čaká na aktualizáciu Omarchy. Ak sa kamera nezobrazí, `journalctl -u facetimehd-firmware-fetcher` povie prečo, `sudo systemctl restart facetimehd-firmware-fetcher` to skúsi znova a reštart načíta ovládač, ak sa sťahovanie dokončilo, ale kamera tam stále nie je.

#### Zariadenia s čipom T1

Čip Apple T1 bol predstavený koncom roka 2016 a používal sa výhradne v modeloch MacBook Pro prvej generácie s Touch Barom.
- MacBook Pro 13-palcový (2016, dva porty Thunderbolt 3) – Model: A1706
- MacBook Pro 13-palcový (2016, štyri porty Thunderbolt 3) – Model: A1708
- MacBook Pro 15-palcový (2016) – Model: A1707

#### Známe problémy

- Touch Bar nefunguje
- Zvuk nefunguje

#### Zariadenia s čipom T2

Bezpečnostný čip Apple T2 bol predstavený v roku 2017. Čip T2 bol ukončený s prechodom na Apple silicon (čipy série M), ktorý sa začal v roku 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-palcový (2018, štyri porty Thunderbolt 3) – Model: A1989
- MacBook Pro 15-palcový (2018) – Model: A1990
- MacBook Air (Retina, 13-palcový, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-palcový (2019, dva porty Thunderbolt 3) – Model: A2159
- MacBook Pro 13-palcový (2019, štyri porty Thunderbolt 3) – Model: A2178
- MacBook Pro 15-palcový (2019) – Model: A1990
- iMac (Retina 5K, 27-palcový, 2020) – Model: A2115 (iMac20,1 a iMac20,2)
- MacBook Pro 13-palcový (2020, dva porty Thunderbolt 3) – Model: A2265
- MacBook Pro 15-palcový (2020) – Model: A1990

Na týchto modeloch inštalátor automaticky nastaví opravené jadro `linux-t2`, konfiguráciu zvuku T2, firmvér Apple Broadcom Wi-Fi/Bluetooth a ovládanie ventilátora cez `t2fanrd`. Touch Bar beží na vstavanej podpore jadra v štýle Boot Camp.

#### iMac Retina 5K (2017)

27-palcový iMac z roku 2017 nemá čip T2, preto ho inštalátor nastaví ako ostatné Macy s čipom Intel.

- iMac (Retina 5K, 27-palcový, 2017) – Model: A1419

#### Známe problémy

- Displej nebeží vo svojom natívnom rozlíšení 5120×2880: panel tvoria dve dlaždice a štandardný ovládač rozsvieti iba jednu
- Zvuk nefunguje
- Ovládanie jasu nemá žiadny účinok
- Režim spánku spôsobí zamrznutie počítača; obnoví ho iba vypnutie a zapnutie napájania

Komunitný patcher pre tento model opravuje displej, zvuk a jas: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
