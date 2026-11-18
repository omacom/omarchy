# Podpora pre Mac

Omarchy má vstavanú podporu pre **Intel Macs**. Momentálne existuje pár známych obmedzení, ale pokiaľ o nich viete a ste s tým OK, môžete nainštalovaním Omarchy vdýchnuť svojim starým Macom nový život.

Upozorňujeme, že inštalácia na Mac série M momentálne nie je priamo podporovaná. Viac o aktuálnom stave sa dozviete v kanáli #omarchy-on-other na našom [Discorde](https://discord.gg/tXFUdasqhY).

V jednoduchom teste sa nám len nainštalovaním Omarchy podarilo na MacBooku Pro z roku 2019 dosiahnuť 36 % nárast výkonu.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Inštalácia Omarchy na Macu

Omarchy momentálne podporuje len inštaláciu ako **jediný** OS. Počas inštalácie bude disk vymazaný a MacOS už nebude možné spustiť.

Ak budete chcieť, neskôr ho stále môžete obnoviť cez Internet Recovery.

V tejto časti budeme predpokladať, že ste si už prečítali [Začíname](02-getting-started.md) a máte pripravený USB disk. Ak nie, urobte to teraz.

#### Vypnutie Secure Boot

Secure Boot od Apple je potrebné vypnúť, aby bolo možné spustiť bootovateľné USB aj samotný OS. Vypnete ho takto:

1. Vypnite svoj Mac
2. Zapnite ho a _okamžite_ stlačte a podržte Command-R, kým sa nezobrazí obrazovka načítavania
3. Vyberte svojho používateľa a v prípade výzvy zadajte heslo
4. Na obrazovke obnovy vyberte v paneli ponúk **Utilities > Startup Security Utility**
5. Po výzve na overenie zadajte heslo
6. V možnostiach Secure Boot vyberte "No Security"
7. V možnostiach External Boot vyberte "Allow booting from external or removable media"

#### Spustenie inštalácie

1. Vložte USB disk
2. Reštartujte Mac a _okamžite_ stlačte a podržte Option, kým sa nezobrazí obrazovka so spúšťacími zariadeniami
3. Vyberte oranžové zariadenie EFI Boot
4. Pokračujte v [inštalácii ako zvyčajne](02-getting-started.md)

Inštalátor rozpozná hardvér Macu a automaticky použije potrebné opravy: ovládače a firmvér pre Broadcom Wi-Fi, ovládač SPI klávesnice na modeloch MacBook, ktoré ho potrebujú, a opravu uspávania NVMe pre tie isté modely.

### Známe obmedzenia

Členovia komunity neustále pracujú na riešeniach týchto problémov, takže ak sú pre vás problematické, pridajte sa do kanála #omarchy-on-other na našom [Discorde](https://discord.gg/tXFUdasqhY) a zistite, či neexistujú nejaké aktuálne spôsoby ich vyriešenia.

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

Na týchto modeloch inštalátor automaticky nastaví opravené jadro `linux-t2`, konfiguráciu zvuku pre T2, firmvér Apple Broadcom pre Wi-Fi/Bluetooth a ovládanie ventilátorov cez `t2fanrd`. Touch Bar funguje prostredníctvom vstavanej podpory v štýle Boot Camp v jadre.

#### iMac Retina 5K (2017)

27-palcový iMac z roku 2017 nemá čip T2, takže ho inštalátor nastaví ako ostatné Intel Macy.

- iMac (Retina 5K, 27-palcový, 2017) – Model: A1419

#### Známe problémy

- Displej nefunguje v natívnom rozlíšení 5120×2880: panel tvoria dve dlaždice a štandardný ovládač rozsvieti len jednu
- Zvuk nefunguje
- Ovládanie jasu nemá žiadny účinok
- Uspatie zasekne počítač; obnoví ho len vypnutie a opätovné zapnutie

Komunitný nástroj na opravu pre tento model rieši displej, zvuk a jas: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
