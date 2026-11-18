# Přecházíte z Macu nebo Windows

Pokud jste strávili roky na macOS nebo Windows, vaše prsty znají sto věcí, u kterých váš mozek už zapomněl, že se je vůbec kdy naučil. Tato kapitola je překladová vrstva: kam tyhle instinkty v Omarchy patří. Samotné funkce jsou podrobně popsané jinde — tohle je jen mapa.

### Super je středem všeho

Veškerá svalová paměť, kterou jste si vybudovali kolem Cmd nebo klávesy Windows, se přenáší na jedinou klávesu: Super. To je klávesa Windows na PC klávesnici a je kotvou téměř každé klávesové zkratky v Omarchy.

Váš reflex na Spotlight, Raycast nebo nabídku Start se stává `Super + Space`. To otevře nabídku Omarchy, která spouští aplikace, mění nastavení, instaluje software, zachycuje obrazovku — prostě skoro všechno. Začněte psát a filtrujete. `Super + Alt + Space` zobrazí všechny aplikace v jedné mřížce, stejně jako to dělá Launchpad. Viz [navigace](04-navigation.md).

### Není tu žádný dock ani ikony na ploše

Nic, na co kliknout pro spuštění věcí, žádné ikony k uspořádání na ploše. Aplikace se spouštějí klávesovou zkratkou (`Super + Return` pro terminál, `Super + Shift + Return` pro prohlížeč a `Super + K` pro seznam všeho, co je namapované) nebo z nabídky. Jediným trvalým prvkem uživatelského rozhraní je [horní lišta](05-the-top-bar.md), která pokrývá to, co pro vás dřív dělaly lišta nabídek, systémová lišta a Centrum oznámení — a téměř každý widget na ní něco dělá při kliknutí levým, pravým i prostředním tlačítkem.

### Okna se umisťují sama

Největší změna v myšlení: okna nepřetahujete po obrazovce ani je nepřichytáváte k jejím polovinám. Otevřete okno a zabere celou obrazovku. Otevřete druhé a rozdělí si ji. Nikdy nelovíte okno zpod jiného, protože okna se nepřekrývají.

Když plovoucí okno opravdu potřebujete, `Super + T` přepne aktivní okno ven z dlaždicového uspořádání (a zase zpět). Nejdřív ale dejte dlaždicím skutečnou šanci — jsou srdcem celé věci. [Navigace](04-navigation.md) vás tím provede.

Pracovní plochy vám budou povědomé: jsou to macOS Spaces nebo virtuální plochy ve Windows, jen je budete skutečně používat, protože `Super + 1/2/3/4` skočí rovnou na jednu a `Super + Shift + 1/2/3/4` tam pošle aktivní okno. Žádné zpoždění kvůli animaci, jen okamžité skoky. To znamená, že možná ani nebudete potřebovat více monitorů, pokud jste na to byli dřív zvyklí.

### Kopírování a vkládání prostě funguje

Na Macu jste měli všude Cmd + C. Ve Windows jste měli všude Ctrl + C — kromě terminálu, kde vám to zabije program. Omarchy vám dává `Super + C`, `Super + X` a `Super + V` a fungují všude, včetně terminálu. Nemusíte se učit žádný zvláštní reflex pro shell.

Lidé z Windows: vaše historie schránky z Win + V žije na `Super + Ctrl + V` a uchovává obrázky stejně jako text. Viz [jednotná schránka a historie](08-unified-clipboard-history.md).

### Překladová tabulka

| Po čem saháte | V Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / nabídka Start | `Super + Space` — nabídka Omarchy |
| AirDrop | LocalSend, přes `Super + Ctrl + S` — viz [GUI](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` nebo `Print Screen` — viz [snímky obrazovky a nahrávání](12-screenshots-recording.md) |
| Centrum oznámení | Historie oznámení na `Super + Shift + Alt + ,` |
| Time Machine (pro systém) | Automatické [snímky systému](47-system-snapshots.md) při každé aktualizaci |
| App Store / stažení instalátoru | _Instalovat_ v nabídce, nebo `omarchy pkg add` — viz [další balíčky](29-other-packages.md) |
| Nastavení systému / Ovládací panely | _Nastavení_ v nabídce, které upravuje prosté konfigurační soubory — viz [dotfiles](31-dotfiles.md) |

### Některé věci jsou opravdu jiné

Spousta nastavení žije v textových souborech, které upravujete, ne v panelech, kterými se proklikáváte. Zní to primitivně, dokud si neuvědomíte, že to znamená, že každou úpravu lze vidět, zkopírovat na váš další počítač a dát pod správu verzí. Nabídka _Nastavení_ vás hodí rovnou do správného souboru a po dokončení restartuje vše, co restart potřebuje.

Aktualizace přicházejí jedním příkazem — _Aktualizace > Omarchy_ — který aktualizuje samotné Omarchy i každý balíček v systému a předtím pořídí snímek. Žádné aktualizační programy jednotlivých aplikací, které by vás otravovaly v náhodných chvílích. Viz [aktualizace](30-updates.md).

Software pochází ze správce balíčků, ne ze stažených instalátorů.

A když okno zavřete, aplikace se skutečně ukončí. Neexistuje žádné macOS limbo, kde program běží dál bez oken. `Super + W` — nebo `Super + Q`, pokud jste přišli s touhle svalovou pamětí prstů — znamená pryč.

### Na hardwaru Mac

Omarchy běží dobře na Macech s procesorem Intel — viz [podpora Maců](44-mac-support.md). A klávesnice je k vám laskavá: Omarchy nic nepřemapovává a Linux zachází s klávesou Command jako se Super, takže Super sedí přesně tam, kde vždycky bylo Cmd. Váš palec si přesunu ani nevšimne.

### Dejte tomu dva týdny

Instinkty se přenesou rychleji, než byste čekali. Jednou si prolétněte kapitolu [klávesové zkratky](07-hotkeys.md), a kdykoli vám nějaká zkratka vypadne, stiskněte `Super + K` — ukáže vám je všechny. To je jediná klávesová zkratka, kterou si skutečně musíte zapamatovat.
