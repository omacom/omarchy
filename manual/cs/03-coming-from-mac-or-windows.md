# Přicházíte z Macu nebo Windows

Pokud jste strávili roky na macOS nebo Windows, vaše prsty znají sto věcí, u kterých váš mozek už zapomněl, že se je kdy naučil. Tato kapitola je překladová vrstva: kam tyhle instinkty v Omarchy patří. Samotné funkce jsou podrobně popsané jinde — tohle je jen mapa.

### Super je středem všeho

Veškerá svalová paměť, kterou jste si vybudovali kolem Cmd nebo klávesy Windows, se přenáší na jedinou klávesu: Super. To je klávesa Windows na PC klávesnici a je kotvou pro téměř každou klávesovou zkratku v Omarchy.

Váš reflex na Spotlight, Raycast nebo nabídku Start se stává `Super + Space`. Tím se otevře nabídka Omarchy, která spouští aplikace, mění nastavení, instaluje software, zachycuje obrazovku — prostě skoro všechno. Začněte psát a filtrujete. `Super + Alt + Space` zobrazí všechny aplikace na jedné mřížce, stejně jako to dělá Launchpad. Viz [navigace](04-navigation.md).

### Žádné ikony na ploše a dock se drží stranou

Žádné ikony k uspořádávání na ploše a dock se schová, jakmile má pracovní plocha okno, dokud nezatlačíte ukazatel k jeho okraji obrazovky, ke spodnímu, pokud ho nepřesunete (viz [navigace](04-navigation.md)). Aplikace se spouštějí klávesovou zkratkou (`Super + Return` pro terminál, `Super + Shift + Return` pro prohlížeč a `Super + K` pro seznam všeho, co je namapované) nebo z nabídky. Jediný trvalý kus UI je [horní lišta](05-the-top-bar.md), která pokrývá to, co pro vás dříve dělaly lišta nabídek, systémová lišta a Centrum oznámení — a téměř každý widget na ní něco udělá při kliknutí levým, pravým i prostředním tlačítkem.

### Okna se umisťují sama

Největší změna v myšlení: okna nepřetahujete ani nepřichytáváte k polovinám obrazovky. Otevřete okno a zabere celou obrazovku. Otevřete druhé a rozdělí si ji. Nikdy nelovíte okno zpod jiného, protože okna se nepřekrývají.

Když plovoucí okno opravdu potřebujete, `Super + T` přepne aktivní okno z dlaždicového uspořádání (a zpět). Ale dejte dlaždicím nejdřív skutečnou šanci — je to srdce celé věci. [Navigace](04-navigation.md) vás tím provede.

Pracovní plochy vám budou povědomé: jsou to macOS Spaces nebo virtuální plochy ve Windows, jen je budete skutečně používat, protože `Super + 1/2/3/4` skočí přímo na jednu a `Super + Shift + 1/2/3/4` tam pošle aktivní okno. Žádné zpoždění animace, jen okamžité skoky. To znamená, že možná ani nebudete potřebovat více monitorů, pokud jste na to byli dříve zvyklí.

### Kopírování a vkládání prostě funguje

Na Macu jste měli všude Cmd + C. Na Windows jste měli všude Ctrl + C — kromě terminálu, kde vám to zabije program. Omarchy vám dává `Super + C`, `Super + X` a `Super + V` a fungují všude, včetně terminálu. Žádný samostatný reflex pro shell, který byste se museli učit.

Lidé z Windows: vaše historie schránky z Win + V žije na `Super + Ctrl + V` a uchovává obrázky i text. Viz [sjednocená schránka a historie](08-unified-clipboard-history.md).

### Překladová tabulka

| Saháte po | V Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — nabídka Omarchy |
| AirDrop | LocalSend, přes `Super + Ctrl + S` — viz [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` nebo `Print Screen` — viz [snímky obrazovky a nahrávání](12-screenshots-recording.md) |
| Notification Center | Historie oznámení na `Super + Shift + Alt + ,` |
| Time Machine (pro systém) | Automatické [snímky systému](47-system-snapshots.md) při každé aktualizaci |
| App Store / stáhnutí instalátoru | _Install_ v nabídce, nebo `omarchy pkg add` — viz [další balíčky](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ v nabídce, které upravuje prosté konfigurační soubory — viz [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, na `Super + Shift + F` — viz [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome na `Super + Shift + Return`; jiný si vyberete v _Setup > Defaults > Browser_ — viz [prohlížeče](23-browsers.md) |
| Preview / Photos | Omaview pro obrázky, video a hudbu, Document Viewer pro PDF — viz [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, na `Super + Shift + N`; jiný si vyberete v _Setup > Defaults > Editor_ |

### Některé věci jsou opravdu jiné

Spousta nastavení žije v textových souborech, které upravujete, ne v panelech, kterými se proklikáváte. Zní to primitivně, dokud si neuvědomíte, že to znamená, že každou úpravu můžete vidět, zkopírovat na svůj další počítač a dát do správy verzí. Nabídka _Setup_ vás hodí rovnou do správného souboru a po dokončení restartuje vše, co restart potřebuje.

Aktualizace přicházejí přes jediný příkaz — _Update > Omarchy_ — který aktualizuje samotné Omarchy i každý balíček v systému a nejdřív pořídí snímek. Žádné aktualizátory jednotlivých aplikací, které by vás otravovaly náhodně. Viz [aktualizace](30-updates.md).

Software pochází ze správce balíčků, ne ze stažených instalátorů.

A když zavřete okno, aplikace se skutečně ukončí. Neexistuje žádné macOS limbo, kde program dál běží bez oken. `Super + W` — nebo `Super + Q`, pokud jste dorazili s touhle prstovou pamětí — znamená pryč.

### Na hardwaru Mac

Omarchy běží dobře na Intel Macích a na Macích s M1, M2 a M3 s Omarchy for Apple Silicon. Viz [podpora Macu](44-mac-support.md). A klávesnice je k vám laskavá: Omarchy nic nepřemapovává a Linux bere klávesu Command jako Super, takže Super sedí přesně tam, kde vždy bylo Cmd. Váš palec si přesunu nevšimne.

### Dejte tomu dva týdny

Instinkty se přenesou rychleji, než byste čekali. Jednou si projděte kapitolu [klávesové zkratky](07-hotkeys.md) a kdykoli vám nějaká vazba vypadne, stiskněte `Super + K` — ukáže vám je všechny. To je jediná zkratka, kterou si skutečně musíte zapamatovat.
