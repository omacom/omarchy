# Přechod z Macu nebo Windows

Pokud jste strávili roky na macOS nebo Windows, vaše prsty znají stovku věcí, které váš mozek už dávno zapomněl, že se je kdy naučil. Tato kapitola je překladovou vrstvou: kam tyto instinkty v Omarchy patří. Samotné funkce jsou podrobně popsány jinde — tady je jen mapa.

### Super je středem všeho

Veškerá svalová paměť, kterou jste si vybudovali kolem Cmd nebo klávesy Windows, se přenáší na jedinou klávesu: Super. To je klávesa Windows na klávesnici PC a je kotvou pro téměř každou klávesovou zkratku v Omarchy.

Váš reflex na Spotlight, Raycast nebo nabídku Start se stává `Super + Space`. Tím se otevře nabídka Omarchy, která spouští aplikace, mění nastavení, instaluje software, zachycuje obrazovku — prostě téměř všechno. Začněte psát pro filtrování. `Super + Alt + Space` zobrazí všechny aplikace v jedné mřížce, tak jako Launchpad. Viz [navigace](04-navigation.md).

### Není tu žádný dock ani ikony na ploše

Není na co klikat pro spouštění věcí, žádné ikony k uspořádání na ploše. Aplikace se spouštějí klávesovou zkratkou (`Super + Return` pro terminál, `Super + Shift + Return` pro prohlížeč a `Super + K` pro seznam všeho, co je namapováno) nebo z nabídky. Jediným trvalým prvkem uživatelského rozhraní je [horní panel](05-the-top-bar.md), který pokrývá to, co pro vás dříve dělaly lišta nabídek, systémová lišta a Centrum oznámení — a téměř každý widget na něm dělá něco při levém, pravém a prostředním kliknutí.

### Okna se umisťují sama

Největší změna myšlení: netaháte okna sem a tam ani je nepřichytáváte k polovinám obrazovky. Otevřete okno a zabere celou obrazovku. Otevřete druhé a rozdělí si ji. Nikdy nelovíte okno spod jiného, protože okna se nepřekrývají.

Když skutečně potřebujete plovoucí okno, `Super + T` přepne aktivní okno ven z dlaždicového uspořádání (a zpět). Ale dejte dlaždicím nejdřív skutečnou šanci — je to srdce celé věci. [Navigace](04-navigation.md) vás tím provede.

Pracovní plochy vám budou připadat povědomé: jsou to macOS Spaces nebo virtuální plochy Windows, až na to, že je skutečně budete používat, protože `Super + 1/2/3/4` skočí přímo na jednu z nich a `Super + Shift + 1/2/3/4` tam pošle aktivní okno. Žádné zpoždění animace, jen okamžité skoky. To znamená, že možná ani nebudete potřebovat více monitorů, pokud jste na to byli zvyklí dříve.

### Kopírování a vkládání prostě funguje

Na Macu jste měli všude Cmd + C. Na Windows jste měli všude Ctrl + C — kromě terminálu, kde to zabije váš program. Omarchy vám dává `Super + C`, `Super + X` a `Super + V` a fungují všude, včetně terminálu. Žádný zvláštní reflex pro shell se učit nemusíte.

Lidé z Windows: vaše historie schránky Win + V žije na `Super + Ctrl + V` a uchovává obrázky i text. Viz [jednotná schránka a historie](08-unified-clipboard-history.md).

### Překladová tabulka

| Saháte po | V Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / nabídka Start | `Super + Space` — nabídka Omarchy |
| AirDrop | LocalSend, přes `Super + Ctrl + S` — viz [GUI](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — viz [snímky obrazovky a nahrávání](12-screenshots-recording.md) |
| Centrum oznámení | Historie oznámení na `Super + Shift + Alt + ,` |
| Time Machine (pro systém) | Automatické [snímky systému](47-system-snapshots.md) při každé aktualizaci |
| App Store / stahování instalátoru | _Instalovat_ v nabídce, nebo `omarchy pkg add` — viz [další balíčky](29-other-packages.md) |
| Nastavení systému / Ovládací panely | _Nastavení_ v nabídce, které upravuje obyčejné konfigurační soubory — viz [dotfiles](31-dotfiles.md) |

### Některé věci jsou opravdu jiné

Mnoho nastavení žije v textových souborech, které upravujete, ne v panelech, kterými proklikáváte. Zní to primitivně, dokud si neuvědomíte, že to znamená, že každou úpravu lze vidět, zkopírovat na další počítač a uložit do správy verzí. Nabídka _Nastavení_ vás hodí přímo do správného souboru a po dokončení restartuje, co je potřeba restartovat.

Aktualizace přicházejí prostřednictvím jediného příkazu — _Aktualizovat > Omarchy_ — který aktualizuje samotné Omarchy i každý balíček v systému, přičemž nejprve pořídí snímek. Žádné aktualizační nástroje jednotlivých aplikací, které by vás náhodně obtěžovaly. Viz [aktualizace](30-updates.md).

Software pochází ze správce balíčků, ne ze stažených instalátorů.

A když zavřete okno, aplikace se skutečně ukončí. Neexistuje žádné limbo jako v macOS, kde program dál běží bez oken. `Super + W` — nebo `Super + Q`, pokud je to svalová paměť, se kterou jste přišli — znamená pryč.

### Na hardwaru Mac

Omarchy běží dobře na Macích s Intelem — viz [podpora Maců](44-mac-support.md). A klávesnice je k vám laskavá: Omarchy nic nepřemapovává a Linux zachází s klávesou Command jako se Super, takže Super sedí přesně tam, kde vždycky bylo Cmd. Váš palec si přesunu ani nevšimne.

### Dejte tomu dva týdny

Instinkty se přenášejí rychleji, než byste čekali. Prolétněte jednou kapitolu [klávesové zkratky](07-hotkeys.md) a kdykoli si nevzpomenete na zkratku, stiskněte `Super + K` — zobrazí vám je všechny. To je jediná klávesová zkratka, kterou si skutečně musíte zapamatovat.
