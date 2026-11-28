# Přecházíte z Macu nebo Windows

Pokud jste strávili roky na macOS nebo Windows, vaše prsty znají stovku věcí, o kterých váš mozek už zapomněl, že se je kdy naučil. Tato kapitola je překladová vrstva: kam tyhle návyky v Omarchy patří. Samotné funkce jsou podrobně popsané jinde — tohle je jen mapa.

### Super je středem všeho

Veškerá svalová paměť, kterou jste si vybudovali kolem Cmd nebo klávesy Windows, přechází na jedinou klávesu: Super. Je to klávesa Windows na PC klávesnici a je kotvou téměř každé klávesové zkratky v Omarchy.

Váš reflex na Spotlight, Raycast nebo nabídku Start se stává `Super + Space`. Tím se otevře menu Omarchy, které spouští aplikace, mění nastavení, instaluje software, zachytává obrazovku — prostě skoro všechno. Začněte psát a filtrujete. `Super + Alt + Space` zobrazí všechny aplikace v jedné mřížce, tak jako to dělá Launchpad. Viz [navigace](04-navigation.md).

### Žádné ikony na ploše a dock se drží stranou

Žádné ikony k rovnaní na ploše a dock se schová, jakmile má pracovní prostor okno, dokud netlačíte ukazatel k jeho okraji obrazovky, k pravému, pokud ho nepřesunete (viz [navigace](04-navigation.md)). Aplikace se spouštějí klávesovou zkratkou (`Super + Return` pro terminál, `Super + Shift + Return` pro prohlížeč a `Super + K` pro seznam všeho, co je namapované) nebo z menu. Jediný trvalý kus uživatelského rozhraní je [horní lišta](05-the-top-bar.md), která pokrývá to, co pro vás dříve dělaly lišta menu, systémová lišta a Notification Center — a téměř každý widget na ní něco dělá při kliknutí levým, pravým i prostředním tlačítkem.

### Okna se umisťují sama

Největší změna v uvažování: okna netaháte po obrazovce ani je nepřichytáváte k polovinám obrazovky. Otevřete okno a zabere celou obrazovku. Otevřete druhé a obrazovku si rozdělí. Nikdy nelovíte okno zpod jiného, protože okna se nepřekrývají.

Když opravdu potřebujete plovoucí okno, `Super + T` přepne aktivní okno ven z dlaždicového uspořádání (a zpět). Ale dejte dlaždicím nejdřív pořádnou šanci — je to srdce celé věci. [Navigace](04-navigation.md) vás tím provede.

Pracovní prostory vám budou povědomé: jsou to Spaces z macOS nebo virtuální plochy z Windows, jen je budete skutečně používat, protože `Super + 1/2/3/4` skočí rovnou na jeden z nich a `Super + Shift + 1/2/3/4` tam pošle aktivní okno. Žádné zpoždění kvůli animaci, jen okamžité skoky. Znamená to, že možná ani nebudete potřebovat víc monitorů, pokud jste na to byli dřív zvyklí.

### Kopírování a vkládání prostě funguje

Na Macu jste měli Cmd + C všude. Na Windows jste měli Ctrl + C všude — kromě terminálu, kde vám to zabije program. Omarchy vám dává `Super + C`, `Super + X` a `Super + V` a fungují všude, včetně terminálu. Žádný samostatný reflex pro shell se učit nemusíte.

Lidi z Windows: vaše historie schránky z Win + V žije na `Super + Ctrl + V` a uchovává obrázky stejně jako text. Viz [jednotná schránka a historie](08-unified-clipboard-history.md).

### Překladová tabulka

| Po čem saháte | V Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / nabídka Start | `Super + Space` — menu Omarchy |
| AirDrop | LocalSend, přes `Super + Ctrl + S` — viz [grafické aplikace](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` nebo `Print Screen` — viz [snímky obrazovky a nahrávání](12-screenshots-recording.md) |
| Notification Center | Historie oznámení na `Super + Shift + Alt + ,` |
| Time Machine (pro systém) | Automatické [systémové snímky](47-system-snapshots.md) při každé aktualizaci |
| App Store / stažení instalátoru | _Instalovat_ v menu, nebo `omarchy pkg add` — viz [další balíčky](29-other-packages.md) |
| Nastavení systému / Ovládací panely | _Nastavení_ v menu, které upravuje prosté konfigurační soubory — viz [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, na `Super + Shift + F` — viz [grafické aplikace](22-guis.md) |
| Safari / Edge | Google Chrome na `Super + Shift + Return`; další si vyberete v _Nastavení > Výchozí > Prohlížeč_ — viz [prohlížeče](23-browsers.md) |
| Preview / Photos | Omaview pro obrázky, video a hudbu, Document Viewer pro PDF — viz [grafické aplikace](22-guis.md) |
| TextEdit / Notepad | Plain, na `Super + Shift + N`; další si vyberete v _Nastavení > Výchozí > Editor_ |

### Některé věci jsou opravdu jiné

Spousta nastavení žije v textových souborech, které upravujete, ne v panelech, kterými se proklikáváte. Zní to primitivně, dokud si neuvědomíte, že to znamená, že každou úpravu můžete vidět, zkopírovat na svůj další stroj a dát do správy verzí. Menu _Nastavení_ vás hodí rovnou do správného souboru a po dokončení restartuje vše, co restart potřebuje.

Aktualizace chodí jedním příkazem — _Aktualizovat > Omarchy_ — který aktualizuje samotné Omarchy i každý balíček v systému a nejdřív udělá snímek. Žádné samostatné aktualizátory jednotlivých aplikací, které by vás otravovaly v náhodnou chvíli. Viz [aktualizace](30-updates.md).

Software pochází ze správce balíčků, ne ze stažených instalátorů.

A když zavřete okno, aplikace se skutečně ukončí. Neexistuje žádné limbo z macOS, kde program běží dál bez oken. `Super + W` — nebo `Super + Q`, pokud jste s touhle pamětí prstů přišli — znamená pryč.

### Na hardwaru Mac

Omarchy běží dobře na Macích s Intelem a na Macích s M1, M2 a M3 s Omarchy for Apple Silicon. Viz [podpora Maců](44-mac-support.md). A klávesnice je na vás hodná: Omarchy nic nepřemapovává a Linux zachází s klávesou Command jako se Super, takže Super sedí přesně tam, kde vždycky bylo Cmd. Váš palec si přesunu ani nevšimne.

### Dejte tomu dva týdny

Ty návyky se přenesou rychleji, než byste si mysleli. Jednou si prolétněte kapitolu [klávesové zkratky](07-hotkeys.md) a kdykoli vám nějaká vazba vypadne, stiskněte `Super + K` — ukáže vám je všechny. To je jediná klávesová zkratka, kterou si skutečně musíte zapamatovat.
