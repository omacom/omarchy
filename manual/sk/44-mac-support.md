# Podpora Macu

## Omarchy pre Apple Silicon

Omarchy pre Apple Silicon je oficiálne riešenie od Omacomu, prvýkrát vydané s Omarchy 4.5. Inštaluje sa popri macOS a pri spustení Macu si vyberáte medzi týmito dvoma systémami.

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

Macy s M4 a novšie zatiaľ nie sú podporované. Podpora M4 sa testuje na kanáli edge a príde ako ďalšia. Inštalátor skontroluje váš Mac predtým, než čokoľvek zmení.

Na každom Macu s Apple Silicon vrátane M4 a novších môžete Omarchy spustiť vo virtuálnom počítači pomocou [Try Omarchy](https://github.com/omacom/try-omarchy).

### Čo potrebujete

- macOS 15 Sequoia alebo novší a účet správcu
- Voľné miesto na disku pre Omarchy. Inštalátor navrhne veľkosť a umožní vám ju zmeniť.
- Zálohu Macu, napájanie a internetové pripojenie. Inštalácia stiahne niekoľko gigabajtov.

### Inštalácia

Inštalujete z macOS. Nainštalujte Omarchy Installer pomocou [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Alebo si stiahnite najnovší Omarchy Installer z jeho [stránky vydaní](https://github.com/omacom/omarchy-mac-installer/releases) a otvorte ho.

Inštalátor skontroluje váš Mac, ukáže vám plán a uvoľní miesto pre Omarchy zmenšením oddielu macOS. macOS zostane na disku a nie je potrebný žiadny USB disk. Po dokončení prvej fázy vás prevedie dokončením nastavenia v macOS Recovery: vypnite Mac, podržte tlačidlo napájania, kým sa nezobrazí hlásenie "Loading startup options", vyberte Omarchy a postupujte podľa krokov.

Pri prvom spustení si Omarchy vyžiada heslo, ktoré šifruje jeho disk. Neexistuje žiadny obnovovací kľúč: ak heslo zabudnete, vaše súbory v Omarchy sa nebudú dať obnoviť.

Ak chcete neskôr prepínať medzi Omarchy a macOS, vypnite Mac, potom podržte tlačidlo napájania, kým sa nezobrazia možnosti spustenia, a vyberte jeden zo systémov.

### Prechod z Omarchy Mac

Omarchy Mac je teraz súčasťou Omarchy pre Apple Silicon a podporovaný je každý Mac, na ktorom bežalo. Vaša aktuálna inštalácia beží ďalej a jej systémové balíčky sa stále aktualizujú, ale už nedostáva žiadne ďalšie aktualizácie Omarchy. Neexistuje žiadny termín ani aktualizácia na mieste: zálohujete, odstránite starú inštaláciu, nainštalujete nanovo a obnovíte. Kroky 2 až 5 prebiehajú v macOS, takže si túto stránku otvorte v telefóne ešte pred reštartom.

1. **Zálohujte z Omarchy, mimo Macu.** Odstránenie starej inštalácie ju vymaže a macOS nedokáže čítať disk Omarchy. Skopírujte svoj domovský priečinok na externý disk alebo do iného počítača vrátane kľúčov SSH a GPG, profilov prehliadača a práce, ktorú ste ešte neodoslali. Uložte si zoznam balíčkov pomocou `pacman -Qqe > ~/packages.txt`. Zálohujte aj macOS, pretože odstránenie aj inštalácia menia veľkosť jeho disku.
2. **Spustite Mac v macOS.** Vypnite ho, podržte tlačidlo napájania, kým sa nezobrazia možnosti spustenia, a vyberte macOS.
3. **Nainštalujte Omarchy Installer** podľa pokynov v časti [Inštalácia](#installing).
4. **Odstráňte starú inštaláciu.** Otvorte Omarchy Installer a vyberte Installation > Remove Omarchy. Ukáže vám, čo vymaže, a vráti miesto systému macOS. Ak vašu inštaláciu nerozpozná, zastaví sa bez zmeny disku. Požiadajte o pomoc v službe [Discord](https://discord.gg/tXFUdasqhY) namiesto ručného mazania oddielov, ktoré môže vymazať macOS.
5. **Nainštalujte Omarchy pre Apple Silicon** pomocou inštalátora.
6. **Obnovte svoje súbory.** Nastavenia vracajte po častiach, namiesto kopírovania celého `~/.config` cez nové predvolené nastavenia, pretože staré nastavenia ich môžu prepísať.

### Dobré vedieť

- Na MacBookoch s M1 a M2 prebuďte zariadenie zo spánku otvorením veka alebo stlačením tlačidla napájania.
- Otázky alebo problémy: pýtajte sa v našom [Discord](https://discord.gg/tXFUdasqhY).

[README inštalátora](https://github.com/omacom/omarchy-mac-installer#readme) pokrýva kanály vydaní, aktualizáciu inštalátora a odstránenie Omarchy.

## Macy s procesorom Intel

V jednoduchom teste sa nám podarilo dosiahnuť 36% nárast výkonu na MacBooku Pro z roku 2019 len nainštalovaním Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Inštalácia Omarchy na Macu

Omarchy momentálne podporuje iba to, že je **jediným** nainštalovaným OS. Počas inštalácie sa disk vymaže a MacOS už nebude možné spustiť.

Neskôr ho stále môžete obnoviť cez Internet Recovery, ak budete chcieť.

V tejto časti budeme predpokladať, že ste si už prečítali [Začíname](02-getting-started.md) a máte pripravený USB disk. Ak nie, urobte to teraz.

#### Vypnutie Secure Boot

Na spustenie bootovateľného USB aj OS je potrebné vypnúť Secure Boot od Apple. Ak ho chcete vypnúť, postupujte takto:

1. Vypnite Mac
2. Zapnite ho a _okamžite_ stlačte a podržte Command-R, kým sa nezobrazí načítavacia obrazovka
3. Vyberte svojho používateľa a po vyzvaní zadajte heslo
4. Keď sa dostanete na obrazovku obnovy, z panela ponúk vyberte **Utilities > Startup Security Utility**
5. Po vyzvaní zadajte heslo na overenie
6. V možnostiach Secure Boot vyberte "No Security"
7. V možnostiach External Boot vyberte "Allow booting from external or removable media"

#### Spustenie inštalácie

1. Vložte USB disk
2. Reštartujte Mac a _okamžite_ stlačte a podržte Option, kým sa nezobrazí obrazovka so spúšťacími zariadeniami
3. Vyberte oranžové zariadenie EFI Boot
4. Pokračujte [inštaláciou ako obvykle](02-getting-started.md)

Inštalátor rozpozná hardvér Macu a automaticky použije potrebné opravy: ovládače a firmvér Broadcom Wi-Fi, ovládač klávesnice SPI na modeloch MacBooku, ktoré ho potrebujú, a opravu uspávania NVMe pre tie isté modely.

### Známe obmedzenia

Členovia komunity neustále pracujú na riešeniach týchto problémov, takže ak sú pre vás problematické, pripojte sa do #omarchy-on-other v našom [Discord](https://discord.gg/tXFUdasqhY) a zistite, či existujú nejaké aktuálne spôsoby ich riešenia.

#### Zariadenia s čipom T1

Čip Apple T1 bol predstavený koncom roka 2016 a používal sa výhradne v modeloch MacBook Pro prvej generácie s Touch Barom.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Známe problémy

- Touch Bar nefunguje
- Zvuk nefunguje

#### Zariadenia s čipom T2

Čip Apple T2 Security Chip bol predstavený v roku 2017. Výroba čipu T2 sa skončila s prechodom na Apple silicon (čipy série M) od roku 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 a iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

Na týchto modeloch inštalátor automaticky nastaví opravené jadro `linux-t2`, konfiguráciu zvuku T2, firmvér Broadcom Wi-Fi/Bluetooth od Apple a ovládanie ventilátorov cez `t2fanrd`. Touch Bar beží na zabudovanej podpore jadra v štýle Boot Camp.

#### iMac Retina 5K (2017)

27-palcový iMac z roku 2017 nemá čip T2, takže ho inštalátor nastaví ako ostatné Macy s procesorom Intel.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Známe problémy

- Displej nebeží v natívnom rozlíšení 5120×2880: panel tvoria dve dlaždice a štandardný ovládač rozsvieti iba jednu
- Zvuk nefunguje
- Ovládanie jasu nemá žiadny účinok
- Spánok počítač zasekne; obnoví ho iba vypnutie a opätovné zapnutie

Komunitný patcher pre tento model opravuje displej, zvuk a jas: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
