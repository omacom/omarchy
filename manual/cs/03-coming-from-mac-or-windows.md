# Přicházíte z Macu nebo z Windows

Pokud jste strávili roky na macOS nebo Windows, vaše prsty znají stovku věcí, na které váš mozek už dávno zapomněl, že se je kdy učil. Tato kapitola je překladová vrstva: kam tyhle instinkty v Omarchy patří. Samotné funkce jsou podrobně popsané jinde — tohle je jen mapa.

### Super je středem všeho

Veškerá svalová paměť, kterou jste si vybudovali kolem Cmd nebo klávesy Windows, přechází na jedinou klávesu: Super. To je klávesa Windows na PC klávesnici a je kotvou pro téměř každou klávesovou zkratku v Omarchy.

Váš reflex na Spotlight, Raycast nebo nabídku Start se stává `Super + Space`. Tím se otevře nabídka Omarchy, která spouští aplikace, mění nastavení, instaluje software, zachycuje obrazovku — prostě skoro všechno. Začněte psát a filtrujete. `Super + Alt + Space` zobrazí všechny aplikace v jedné mřížce, stejně jako to dělá Launchpad. Viz [navigace](04-navigation.md).

### Žádné ikony na ploše a dock se zobrazí jen na plovoucí pracovní ploše

Žádné ikony, které byste rovnali na ploše, a žádný dock na dlaždicové pracovní ploše — dock se objeví jen na plovoucí pracovní ploše (viz [navigace](04-navigation.md)). Aplikace se spouštějí klávesovou zkratkou (`Super + Return` pro terminál, `Super + Shift + Return` pro prohlížeč a `Super + K` pro seznam všeho, co je namapované) nebo z nabídky. Jediným trvalým prvkem UI je [horní lišta](05-the-top-bar.md), která pokrývá to, co pro vás dřív dělaly lišta nabídek, systémová lišta a Centrum oznámení — a téměř každý widget na ní něco dělá při kliknutí levým, pravým i prostředním tlačítkem.

### Okna se umisťují sama

Největší změna v myšlení: okna nepřetahujete ani nepřichytáváte k polovinám obrazovky. Otevřete okno a zabere celou obrazovku. Otevřete druhé a obrazovku si rozdělí. Nikdy nelovíte okno zpod jiného, protože okna se nepřekrývají.

Když opravdu potřebujete plovoucí okno, `Super + T` přepne aktivní okno z dlaždicového režimu ven (a zase zpět). Ale dejte dlaždicím nejdřív pořádnou šanci — je to srdce celé věci. [Navigace](04-navigation.md) vás tím provede.

Pracovní plochy vám budou povědomé: jsou to Spaces z macOS nebo virtuální plochy z Windows, jen je budete skutečně používat, protože `Super + 1/2/3/4` skočí rovnou na jednu z nich a `Super + Shift + 1/2/3/4` tam pošle aktivní okno. Žádné zpoždění animace, jen okamžité skoky. To znamená, že možná ani nebudete potřebovat víc monitorů, pokud jste na to byli dřív zvyklí.

### Kopírování a vkládání prostě funguje

Na Macu jste měli všude Cmd + C. Na Windows jste měli všude Ctrl + C — kromě terminálu, kde vám to zabije program. Omarchy vám dává `Super + C`, `Super + X` a `Super + V` a fungují všude, včetně terminálu. Nemusíte se učit zvláštní reflex pro shell.

Lidé z Windows: vaše historie schránky z Win + V žije na `Super + Ctrl + V` a drží obrázky i text. Viz [sjednocená schránka a historie](08-unified-clipboard-history.md).

### Překladová tabulka

| Saháte po | V Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / nabídka Start | `Super + Space` — nabídka Omarchy |
| AirDrop | LocalSend přes `Super + Ctrl + S` — viz [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` nebo `Print Screen` — viz [snímky obrazovky a nahrávání](12-screenshots-recording.md) |
| Centrum oznámení | Historie oznámení na `Super + Shift + Alt + ,` |
| Time Machine (pro systém) | Automatické [snímky systému](47-system-snapshots.md) při každé aktualizaci |
| App Store / stahování instalátoru | _Install_ v nabídce, nebo `omarchy pkg add` — viz [další balíčky](29-other-packages.md) |
| Nastavení systému / Ovládací panely | _Setup_ v nabídce, které upravuje prosté konfigurační soubory — viz [dotfiles](31-dotfiles.md) |
| Finder / Průzkumník souborů | Files na `Super + Shift + F` — viz [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome na `Super + Shift + Return`; jiný si vyberete v _Setup > Defaults > Browser_ — viz [prohlížeče](23-browsers.md) |
| Náhled / Fotky | Omaview pro obrázky, video a hudbu, Document Viewer pro PDF — viz [GUIs](22-guis.md) |
| TextEdit / Poznámkový blok | Plain na `Super + Shift + N`; jiný si vyberete v _Setup > Defaults > Editor_ |

### Některé věci jsou opravdu jiné

Spousta nastavení žije v textových souborech, které upravujete, ne v panelech, kterými se proklikáváte. Zní to primitivně, dokud si neuvědomíte, že to znamená, že každou úpravu můžete vidět, zkopírovat na svůj další stroj a dát do správy verzí. Nabídka _Setup_ vás hodí rovnou do správného souboru a po dokončení restartuje, co restart potřebuje.

Aktualizace přicházejí jedním příkazem — _Update > Omarchy_ — který aktualizuje samotné Omarchy i každý balíček v systému a nejdřív pořídí snímek. Žádné aktualizátory jednotlivých aplikací, které by vás otravovaly v náhodných chvílích. Viz [aktualizace](30-updates.md).

Software pochází ze správce balíčků, ne ze stažených instalátorů.

A když zavřete okno, aplikace se skutečně ukončí. Neexistuje žádné limbo z macOS, kde program běží dál bez oken. `Super + W` — nebo `Super + Q`, pokud jste s takovou svalovou pamětí prstů přišli — znamená pryč.

### Na hardwaru Mac

Omarchy běží dobře na Macech s Intelem — viz [podpora Macu](44-mac-support.md). A klávesnice je k vám laskavá: Omarchy nic nepřemapovává a Linux zachází s klávesou Command jako se Super, takže Super sedí přesně tam, kde vždycky bylo Cmd. Váš palec si přesunu ani nevšimne.

### Dejte tomu dva týdny

Instinkty se přenesou rychleji, než byste si mysleli. Jednou si prolétněte kapitolu [klávesové zkratky](07-hotkeys.md), a kdykoli vám vypadne nějaká zkratka, stiskněte `Super + K` — ukáže vám je všechny. To je jediná zkratka, kterou si opravdu musíte zapamatovat.
