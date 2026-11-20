# Podpora Maců

Omarchy má vestavěnou podporu pro **Macy s procesorem Intel**. Momentálně existuje pár známých omezení, ale pokud o nich víte a nevadí vám, můžete instalací Omarchy vdechnout svým starým Macům nový život.

Upozorňujeme, že instalace na Macu s čipem řady M momentálně není přímo podporovaná. Více o aktuálním stavu se dozvíte v kanálu #omarchy-on-other na našem [Discordu](https://discord.gg/tXFUdasqhY).

V jednoduchém testu jsme na MacBooku Pro z roku 2019 dosáhli jen instalací Omarchy zvýšení výkonu o 36 %.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instalace Omarchy na Macu

Omarchy momentálně podporuje pouze instalaci jako **jediný** operační systém. Během instalace bude disk vymazán a macOS už nepůjde spustit.

Později ho případně můžete obnovit přes Internet Recovery.

Pro účely této části budeme předpokládat, že jste si už prošli [Začínáme](02-getting-started.md) a máte připravený USB disk. Pokud ne, udělejte to teď.

#### Vypnutí Secure Boot

Secure Boot od Applu je nutné vypnout, abyste mohli spustit bootovatelné USB i samotný operační systém. Vypnete ho takto:

1. Vypněte Mac
2. Zapněte ho a _okamžitě_ stiskněte a podržte Command-R, dokud se neobjeví načítací obrazovka
3. Vyberte svého uživatele a na výzvu zadejte heslo
4. Na obrazovce obnovy vyberte v řádku nabídek **Utilities > Startup Security Utility**
5. Na výzvu k ověření zadejte heslo
6. V možnostech Secure Boot vyberte „No Security“
7. V možnostech External Boot vyberte „Allow booting from external or removable media“

#### Spuštění instalace

1. Vložte USB disk
2. Restartujte Mac a _okamžitě_ stiskněte a podržte Option, dokud se neobjeví obrazovka se spouštěcími zařízeními
3. Vyberte oranžové zařízení EFI Boot
4. Pokračujte [běžnou instalací](02-getting-started.md)

Instalační program rozpozná hardware Macu a automaticky použije potřebné opravy: ovladače a firmware pro Broadcom Wi-Fi, ovladač klávesnice SPI u modelů MacBooku, které ho potřebují, a opravu uspávání NVMe u týchž modelů.

### Známá omezení

Členové komunity na řešeních těchto problémů neustále pracují, takže pokud jsou pro vás problematické, připojte se do kanálu #omarchy-on-other na našem [Discordu](https://discord.gg/tXFUdasqhY) a zjistěte, zda existují nějaké aktuální způsoby, jak je vyřešit.

#### Zařízení s čipem T1

Čip Apple T1 byl představen koncem roku 2016 a používal se výhradně v první generaci modelů MacBook Pro s Touch Barem.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Známé problémy

- Touch Bar nefunguje
- Zvuk nefunguje

#### Zařízení s čipem T2

Bezpečnostní čip Apple T2 byl představen v roce 2017. Čip T2 byl ukončen s přechodem na Apple silicon (čipy řady M) počínaje rokem 2020.

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

U těchto modelů instalační program automaticky nastaví opravené jádro `linux-t2`, konfiguraci zvuku pro T2, firmware Applu pro Broadcom Wi-Fi/Bluetooth a ovládání ventilátorů přes `t2fanrd`. Touch Bar běží na vestavěné podpoře ve stylu Boot Camp v jádře.

#### iMac Retina 5K (2017)

27palcový iMac z roku 2017 nemá čip T2, takže ho instalační program nastaví stejně jako ostatní Macy s procesorem Intel.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Známé problémy

- Displej neběží v nativním rozlišení 5120×2880: panel tvoří dvě dlaždice a standardní ovladač rozsvítí jen jednu
- Zvuk nefunguje
- Ovládání jasu nemá žádný účinek
- Uspání stroj zasekne; pomůže jen vypnutí a opětovné zapnutí

Komunitní nástroj pro tento model opravuje displej, zvuk i jas: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
