# Podpora pre Mac

Omarchy má vstavanú podporu pre **Macy s procesormi Intel**. V tejto chvíli existuje pár známych obmedzení, ale pokiaľ o nich viete a ste s nimi v poriadku, môžete vdýchnuť nový život svojim starým Macom nainštalovaním Omarchy.

Upozorňujeme, že inštalácia na Mac s čipom série M nie je v súčasnosti priamo podporovaná. Viac o stave tejto podpory sa dozviete v kanáli #omarchy-on-other na našom [Discorde](https://discord.gg/tXFUdasqhY).

V jednoduchom teste sme na MacBooku Pro z roku 2019 len nainštalovaním Omarchy dokázali dosiahnuť 36 % nárast výkonu.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Inštalácia Omarchy na Macu

Omarchy v súčasnosti podporuje byť **jediným** nainštalovaným operačným systémom. Počas inštalácie sa disk vymaže a MacOS už nebude možné zaviesť.

Neskôr ho však môžete obnoviť cez Internet Recovery, ak budete chcieť.

Na účely tejto časti budeme predpokladať, že ste si už prečítali [Začíname](02-getting-started.md) a máte pripravený USB kľúč. Ak nie, urobte to hneď teraz.

#### Vypnutie Secure Boot

Na zavedenie zavádzacieho USB aj operačného systému je potrebné vypnúť Secure Boot od Apple. Ak ho chcete vypnúť, postupujte takto:

1. Vypnite Mac
2. Zapnite ho a _okamžite_ stlačte a držte Command-R, kým neuvidíte načítavaciu obrazovku
3. Vyberte svojho používateľa a zadajte heslo, ak sa zobrazí výzva
4. Keď ste na obrazovke obnovy, vyberte z lišty ponuky **Utilities > Startup Security Utility**
5. Po zobrazení výzvy na autentifikáciu zadajte heslo
6. Z možností Secure Boot vyberte „No Security“
7. Z možností External Boot vyberte „Allow booting from external or removable media“

#### Spustenie inštalácie

1. Vložte USB kľúč
2. Reštartujte Mac a _okamžite_ stlačte a držte Option, kým neuvidíte obrazovku so zavádzacími zariadeniami
3. Vyberte oranžové zavádzacie zariadenie EFI
4. Pokračujte [inštaláciou ako zvyčajne](02-getting-started.md)

Inštalačný program rozpozná hardvér Macu a automaticky použije potrebné opravy: ovládače a firmvér pre Broadcom Wi-Fi, ovládač klávesnice SPI na modeloch MacBook, ktoré ho potrebujú, a opravu uspania NVMe pre tie isté modely.

### Známe obmedzenia

Členovia komunity neustále pracujú na riešeniach týchto výziev, takže ak sú pre vás problémom, pripojte sa ku kanálu #omarchy-on-other na našom [Discorde](https://discord.gg/tXFUdasqhY) a pozrite sa, či existujú aktuálne metódy na ich vyriešenie.

#### Zariadenia s čipom T1

Čip Apple T1 bol predstavený koncom roka 2016 a používal sa výhradne v prvej generácii modelov MacBook Pro s Touch Barom.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Známe problémy

- Touch Bar nefunguje
- Zvuk nefunguje

#### Zariadenia s čipom T2

Bezpečnostný čip Apple T2 bol predstavený v roku 2017. Čip T2 bol ukončený s prechodom na Apple silicon (čipy série M) od roku 2020.

- iMac Pro (2017) – Model: A1862
- MacBook Pro 13-inch (2018, four Thunderbolt 3 ports) – Model: A1989
- MacBook Pro 15-inch (2018) – Model: A1990
- MacBook Air (Retina, 13-inch, 2018) – Model: A1932
- Mac mini (2018) – Model: A1998
- MacBook Pro 13-inch (2019, two Thunderbolt 3 ports) – Model: A2159
- MacBook Pro 13-inch (2019, four Thunderbolt 3 ports) – Model: A2178
- MacBook Pro 15-inch (2019) – Model: A1990
- iMac (Retina 5K, 27-inch, 2020) – Model: A2115 (iMac20,1 and iMac20,2)
- MacBook Pro 13-inch (2020, two Thunderbolt 3 ports) – Model: A2265
- MacBook Pro 15-inch (2020) – Model: A1990

Na týchto modeloch inštalačný program automaticky nastaví záplatované jadro `linux-t2`, konfiguráciu zvuku pre T2, firmvér Apple Broadcom pre Wi-Fi/Bluetooth a ovládanie ventilátora cez `t2fanrd`. Touch Bar funguje na vstavanej podpore typu Boot Camp v jadre.
