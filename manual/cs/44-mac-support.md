# Podpora Maců

## Omarchy pro Apple Silicon

Omarchy pro Apple Silicon je oficiální řešení Omacom, poprvé vydané s Omarchy 4.5. Instaluje se vedle macOS a při spuštění Macu si vybíráte mezi těmito dvěma systémy.

Objevilo se vám upozornění na Omarchy Mac? Přejděte na [Přecházíte z Omarchy Mac](#coming-from-omarchy-mac).

Běží na těchto Macích:

| Mac | Čipy |
| --- | --- |
| MacBook Air | M1, M2, M3 |
| MacBook Pro | M1, M1 Pro, M1 Max, M2, M2 Pro, M2 Max, M3, M3 Pro, M3 Max |
| MacBook Neo | A18 Pro |
| Mac mini | M1, M2, M2 Pro |
| Mac Studio | M1 Max, M1 Ultra, M2 Max, M2 Ultra |
| iMac | M1, M3 |
| Mac Pro | M2 Ultra |

Macy s M4 a novější zatím nejsou podporované. Podpora M4 se testuje na kanálu edge a přijde jako další. Instalátor váš Mac zkontroluje, než cokoli změní.

Na libovolném Macu s Apple Silicon, včetně M4 a novějších, můžete Omarchy spustit ve virtuálním stroji pomocí [Try Omarchy](https://github.com/omacom/try-omarchy).

### Co potřebujete

- macOS 15 Sequoia nebo novější a účet správce
- Volné místo na disku pro Omarchy. Instalátor navrhne velikost a nechá vás ji změnit.
- Zálohu Macu, napájení a připojení k internetu. Instalace stahuje několik gigabajtů.

### Instalace

Instalujete z macOS. Nainstalujte Omarchy Installer pomocí [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Nebo si stáhněte nejnovější Omarchy Installer z jeho [stránky vydání](https://github.com/omacom/omarchy-mac-installer/releases) a otevřete ho.

Instalátor zkontroluje váš Mac, ukáže vám plán a uvolní místo pro Omarchy zmenšením oddílu macOS. macOS na disku zůstává a žádný USB disk není potřeba. Po dokončení první fáze vás provede dokončením nastavení v macOS Recovery: vypněte počítač, podržte tlačítko napájení, dokud se neobjeví "Loading startup options", zvolte Omarchy a postupujte podle kroků.

Při prvním spuštění si Omarchy vyžádá heslo, které šifruje její disk. Žádný obnovovací klíč neexistuje: pokud heslo zapomenete, vaše soubory v Omarchy nepůjde obnovit.

Později mezi Omarchy a macOS přepnete tak, že počítač vypnete, podržíte tlačítko napájení, dokud se neobjeví možnosti spuštění, a jednu z nich zvolíte.

### Přecházíte z Omarchy Mac

Omarchy Mac je nyní součástí Omarchy pro Apple Silicon a podporovaný je každý Mac, na kterém běžela. Vaše stávající instalace poběží dál a její systémové balíčky se stále aktualizují, ale aktualizace Omarchy už nedostane. Není žádný termín ani upgrade přímo na místě: zazálohujete, starou instalaci odstraníte, nainstalujete čistou a obnovíte. Kroky 2 až 5 probíhají v macOS, takže si tuto stránku před restartem otevřete v telefonu.

1. **Zálohujte z Omarchy, mimo Mac.** Odstranění staré instalace ji smaže a macOS disk Omarchy nepřečte. Zkopírujte svůj domovský adresář na externí disk nebo jiný počítač, včetně klíčů SSH a GPG, profilů prohlížeče a práce, kterou jste ještě neodeslali. Uložte si seznam balíčků pomocí `pacman -Qqe > ~/packages.txt`. Zálohujte i macOS, protože odstranění i instalace mění velikost jeho disku.
2. **Spusťte Mac v macOS.** Vypněte ho, podržte tlačítko napájení, dokud se neobjeví možnosti spuštění, a zvolte macOS.
3. **Nainstalujte Omarchy Installer** podle části [Instalace](#installing).
4. **Odstraňte starou instalaci.** Otevřete Omarchy Installer a zvolte Installation > Remove Omarchy. Ukáže vám, co smaže, a vrátí místo macOS. Pokud vaši instalaci nerozpozná, zastaví se, aniž by disk změnil. Požádejte o pomoc na [Discord](https://discord.gg/tXFUdasqhY), místo abyste oddíly mazali ručně, což může smazat i macOS.
5. **Nainstalujte Omarchy pro Apple Silicon** pomocí instalátoru.
6. **Obnovte své soubory.** Nastavení vracejte po částech, místo abyste celé `~/.config` zkopírovali přes nová výchozí nastavení, protože stará nastavení je mohou přepsat.

### Dobré vědět

- U MacBooků s M1 a M2 probudíte počítač ze spánku otevřením víka nebo stisknutím tlačítka napájení.
- Dotazy nebo problémy: ptejte se na našem [Discord](https://discord.gg/tXFUdasqhY).

[README instalátoru](https://github.com/omacom/omarchy-mac-installer#readme) popisuje kanály vydání, aktualizaci instalátoru a odstranění Omarchy.

## Macy s Intelem

V jednoduchém testu se nám na MacBooku Pro z roku 2019 podařilo dosáhnout 36% nárůstu výkonu jen instalací Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instalace Omarchy na Mac

Omarchy v tuto chvíli podporuje pouze instalaci jako **jediný** OS. Během instalace bude disk vymazán a MacOS už nepůjde spustit.

Pokud budete chtít, můžete ho později stále obnovit přes Internet Recovery.

V této části budeme předpokládat, že jste si už prošli [Začínáme](02-getting-started.md) a máte připravený USB disk. Pokud ne, udělejte to teď.

#### Vypnutí Secure Boot

Aby bylo možné spustit bootovatelné USB i samotný OS, je nutné vypnout Secure Boot od Applu. Vypnete ho takto:

1. Vypněte Mac
2. Zapněte ho a _okamžitě_ stiskněte a podržte Command-R, dokud se neobjeví načítací obrazovka
3. Vyberte svého uživatele a na výzvu zadejte heslo
4. Na obrazovce zotavení zvolte z panelu nabídek **Utilities > Startup Security Utility**
5. Na výzvu k ověření zadejte heslo
6. V možnostech Secure Boot zvolte "No Security"
7. V možnostech External Boot zvolte "Allow booting from external or removable media"

#### Zahájení instalace

1. Vložte USB disk
2. Restartujte Mac a _okamžitě_ stiskněte a podržte Option, dokud se neobjeví obrazovka se spouštěcími zařízeními
3. Vyberte oranžové zařízení EFI Boot
4. Pokračujte [instalací jako obvykle](02-getting-started.md)

Instalátor rozpozná hardware Macu a potřebné opravy použije automaticky: ovladače a firmware pro Broadcom Wi-Fi, ovladač SPI klávesnice u modelů MacBooků, které ho potřebují, a opravu uspávání NVMe u týchž modelů.

### Známá omezení

Členové komunity na řešeních těchto potíží neustále pracují, takže pokud vám vadí, přidejte se do #omarchy-on-other na našem [Discord](https://discord.gg/tXFUdasqhY) a podívejte se, jestli neexistují nějaké aktuální způsoby, jak je vyřešit.

#### Zařízení s čipem T1

Čip Apple T1 byl uveden na konci roku 2016 a používal se výhradně v modelech MacBook Pro první generace s Touch Barem.
- MacBook Pro 13-inch (2016, two Thunderbolt 3 ports) – Model: A1706
- MacBook Pro 13-inch (2016, four Thunderbolt 3 ports) – Model: A1708
- MacBook Pro 15-inch (2016) – Model: A1707

#### Známé problémy

- Touch Bar nefunguje
- Zvuk nefunguje

#### Zařízení s čipem T2

Bezpečnostní čip Apple T2 byl uveden v roce 2017. Čip T2 byl ukončen s přechodem na Apple silicon (čipy řady M) počínaje rokem 2020.

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

U těchto modelů instalátor automaticky nastaví opravené jádro `linux-t2`, konfiguraci zvuku pro T2, firmware Broadcom Wi-Fi/Bluetooth od Applu a ovládání ventilátorů přes `t2fanrd`. Touch Bar běží na vestavěné podpoře ve stylu Boot Camp v jádru.

#### iMac Retina 5K (2017)

27palcový iMac z roku 2017 nemá čip T2, takže ho instalátor nastaví stejně jako ostatní Macy s Intelem.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Známé problémy

- Displej neběží v nativním rozlišení 5120×2880: panel tvoří dvě dlaždice a standardní ovladač rozsvítí jen jednu
- Zvuk nefunguje
- Ovládání jasu nemá žádný účinek
- Uspání počítač zasekne; obnoví ho jen vypnutí a opětovné zapnutí

Komunitní patcher pro tento model opravuje displej, zvuk a jas: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
