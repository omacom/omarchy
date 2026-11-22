# Podpora Maců

## Omarchy pro Apple Silicon

Omarchy pro Apple Silicon je oficiální řešení od Omacomu, poprvé vydané s Omarchy 4.5. Instaluje se vedle macOS a při spuštění Macu si mezi oběma vybíráte.

Dostali jste upozornění na Omarchy Mac? Přejděte na [Přechod z Omarchy Mac](#coming-from-omarchy-mac).

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

Macy s M4 a novější zatím nejsou podporované. Podpora M4 se testuje na kanálu edge a přijde jako další. Instalační program váš Mac zkontroluje, než cokoli změní.

Na jakémkoli Macu s Apple Silicon, včetně M4 a novějších, můžete Omarchy spustit ve virtuálním počítači pomocí [Try Omarchy](https://github.com/omacom/try-omarchy).

### Co potřebujete

- macOS 15 Sequoia nebo novější a účet správce
- Volné místo na disku pro Omarchy. Instalační program navrhne velikost a umožní vám ji změnit.
- Zálohu svého Macu, napájení a připojení k internetu. Instalace stahuje několik gigabajtů.

### Instalace

Instalujete z macOS. Nainstalujte si Omarchy Installer pomocí [Homebrew](https://brew.sh):

```sh
brew install omacom/mac/omarchy
```

Nebo si stáhněte nejnovější Omarchy Installer z jeho [stránky vydání](https://github.com/omacom/omarchy-mac-installer/releases) a otevřete ho.

Instalační program zkontroluje váš Mac, ukáže vám plán a uvolní místo pro Omarchy zmenšením oddílu macOS. macOS na disku zůstává a není potřeba žádný USB disk. Po dokončení první fáze vás provede dokončením nastavení v macOS Recovery: vypněte počítač, držte tlačítko napájení, dokud se nezobrazí „Loading startup options“, vyberte Omarchy a postupujte podle kroků.

Při prvním spuštění vás Omarchy požádá o heslo, které šifruje jeho disk. Neexistuje žádný obnovovací klíč: pokud heslo zapomenete, vaše soubory v Omarchy nepůjde obnovit.

Pokud chcete později přepínat mezi Omarchy a macOS, vypněte počítač, pak držte tlačítko napájení, dokud se nezobrazí možnosti spuštění, a jednu vyberte.

### Přechod z Omarchy Mac

Omarchy Mac je nyní součástí Omarchy pro Apple Silicon a podporovaný je každý Mac, na kterém běžel. Vaše stávající instalace dál běží a její systémové balíčky se stále aktualizují, ale už nedostává žádné aktualizace Omarchy. Není žádný termín ani upgrade na místě: zálohujete, odstraníte starou instalaci, nainstalujete načisto a obnovíte. Kroky 2 až 5 probíhají v macOS, takže si tuto stránku před restartem otevřete na telefonu.

1. **Zálohujte z Omarchy, mimo Mac.** Odstranění staré instalace ji smaže a macOS disk Omarchy nepřečte. Zkopírujte svou domovskou složku na externí disk nebo do jiného počítače, včetně klíčů SSH a GPG, profilů prohlížeče a neodeslané práce. Uložte si seznam balíčků pomocí `pacman -Qqe > ~/packages.txt`. Zálohujte i macOS, protože odstranění i instalace mění velikost jeho disku.
2. **Spusťte Mac v macOS.** Vypněte počítač, držte tlačítko napájení, dokud se nezobrazí možnosti spuštění, a vyberte macOS.
3. **Nainstalujte Omarchy Installer** podle popisu v části [Instalace](#installing).
4. **Odstraňte starou instalaci.** Otevřete Omarchy Installer a zvolte Installation > Remove Omarchy. Ukáže vám, co smaže, a vrátí místo systému macOS. Pokud vaši instalaci nerozpozná, zastaví se, aniž by disk jakkoli změnil. Požádejte o pomoc na [Discordu](https://discord.gg/tXFUdasqhY), místo abyste oddíly mazali ručně, což může smazat macOS.
5. **Nainstalujte Omarchy pro Apple Silicon** pomocí instalačního programu.
6. **Obnovte své soubory.** Nastavení vracejte po částech, místo abyste přes nová výchozí nastavení zkopírovali celé `~/.config`, protože stará nastavení je mohou přepsat.

### Dobré vědět

- Na MacBoocích s M1 a M2 probudíte počítač z režimu spánku otevřením víka nebo stisknutím tlačítka napájení.
- Otázky nebo problémy: ptejte se na našem [Discordu](https://discord.gg/tXFUdasqhY).

[README instalačního programu](https://github.com/omacom/omarchy-mac-installer#readme) se věnuje kanálům vydání, aktualizaci instalačního programu a odstranění Omarchy.

## Macy s Intelem

V jednoduchém testu se nám na MacBooku Pro z roku 2019 podařilo dosáhnout 36% nárůstu výkonu jen instalací Omarchy.

 ![macbook-omarchy](images/macbook-omarchy.webp)

### Instalace Omarchy na Mac

Omarchy v tuto chvíli podporuje pouze to, že je **jediným** nainstalovaným OS. Během instalace bude disk vymazán a MacOS už nepůjde spustit.

Později ho ale můžete obnovit přes Internet Recovery, pokud budete chtít.

Pro účely této části budeme předpokládat, že jste si už prošli [Začínáme](02-getting-started.md) a máte připravený USB disk. Pokud ne, udělejte to teď.

#### Vypnutí Secure Boot

Aby šel spustit zaváděcí USB disk i samotný OS, je nutné vypnout Secure Boot od Applu. Vypnete ho takto:

1. Vypněte Mac
2. Zapněte ho a _okamžitě_ stiskněte a držte Command-R, dokud se nezobrazí načítací obrazovka
3. Vyberte svého uživatele a na výzvu zadejte heslo
4. Jakmile jste na obrazovce obnovy, zvolte z lišty nabídek **Utilities > Startup Security Utility**
5. Na výzvu k ověření zadejte heslo
6. Z možností Secure Boot zvolte „No Security“
7. Z možností External Boot zvolte „Allow booting from external or removable media“

#### Zahájení instalace

1. Vložte USB disk
2. Restartujte Mac a _okamžitě_ stiskněte a držte Option, dokud se nezobrazí obrazovka zaváděcích zařízení
3. Vyberte oranžové zařízení EFI Boot
4. Pokračujte [běžnou instalací](02-getting-started.md)

Instalační program rozpozná hardware Macu a automaticky použije potřebné opravy: ovladače a firmware pro Broadcom Wi-Fi, ovladač kamery FaceTime HD na počítačích s Broadcom 1570 (její firmware se stahuje od Applu, jakmile je Mac online, protože instalační program funguje offline), ovladač klávesnice SPI na modelech MacBook, které ho potřebují, a opravu uspávání NVMe pro tytéž modely.

### Známá omezení

Členové komunity neustále pracují na řešeních těchto problémů, takže pokud vám vadí, přidejte se do #omarchy-on-other na našem [Discordu](https://discord.gg/tXFUdasqhY) a zjistěte, jestli nejsou nějaké aktuální způsoby, jak je vyřešit.

#### Kamera FaceTime HD

Ovladač kamery zasekne počítač, pokud je načtený, když Mac hibernuje, takže se předtím odpojí. Odpojit ho nelze, dokud má nějaká aplikace kameru otevřenou, takže se hibernace zruší a oznámení pojmenuje danou aplikaci: zavřete ji a hibernujte znovu. To zahrnuje i automatickou hibernaci při kritickém stavu baterie a suspend-then-hibernate, která je odmítnuta ještě před uspáním. Běžné uspání odmítne sám ovladač, dokud je kamera otevřená, a to bez oznámení.

Firmware kamery se stahuje od Applu, takže kamera funguje až poté, co byl Mac online. Stahování začíná při spuštění a každých 15 minut se opakuje, dokud je problémem síť; pokud se soubor od Applu změnil, zastaví se a čeká na aktualizaci Omarchy. Pokud se kamera neobjeví, `journalctl -u facetimehd-firmware-fetcher` řekne proč, `sudo systemctl restart facetimehd-firmware-fetcher` to zkusí znovu a restart načte ovladač, pokud stahování skončilo, ale kamera tam stále není.

#### Zařízení s čipem T1

Čip Apple T1 byl uveden koncem roku 2016 a používal se výhradně v modelech MacBook Pro první generace s Touch Barem.
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

Na těchto modelech instalační program automaticky nastaví opravené jádro `linux-t2`, konfiguraci zvuku T2, firmware Broadcom Wi-Fi/Bluetooth od Applu a ovládání ventilátorů přes `t2fanrd`. Touch Bar běží na vestavěné podpoře ve stylu Boot Camp v jádře.

#### iMac Retina 5K (2017)

27palcový iMac z roku 2017 nemá čip T2, takže ho instalační program nastaví stejně jako ostatní Macy s Intelem.

- iMac (Retina 5K, 27-inch, 2017) – Model: A1419

#### Známé problémy

- Displej neběží v nativním rozlišení 5120×2880: panel tvoří dvě dlaždice a standardní ovladač rozsvítí jen jednu
- Zvuk nefunguje
- Ovládání jasu nemá žádný účinek
- Režim spánku počítač zasekne; obnoví ho jen vypnutí a zapnutí napájení

Komunitní patcher pro tento model opravuje displej, zvuk i jas: [omarchy-imac18-3](https://github.com/ahmadtv/omarchy-imac18-3).
