# Prichádzate z Macu alebo Windowsu

Ak ste strávili roky na macOS alebo Windowse, vaše prsty ovládajú stovku vecí, na ktoré váš mozog už zabudol, že sa ich kedy naučil. Táto kapitola je prekladovou vrstvou: kam tie inštinkty v Omarchy patria. Samotné funkcie sú podrobne rozobraté inde — toto je len mapa.

### Super je stredom všetkého

Všetka svalová pamäť, ktorú ste si vybudovali okolo Cmd alebo klávesu Windows, sa prenáša na jeden kláves: Super. Je to kláves Windows na PC klávesnici a je kotvou pre takmer každú klávesovú skratku v Omarchy.

Váš reflex na Spotlight, Raycast alebo ponuku Štart sa stáva `Super + Space`. Tým sa otvára ponuka Omarchy, ktorá spúšťa aplikácie, mení nastavenia, inštaluje softvér, zachytáva obrazovku — proste takmer všetko. Začnite písať a filtrujete. `Super + Alt + Space` zobrazí všetky aplikácie v jednej mriežke, tak ako to robí Launchpad. Pozrite si [navigáciu](04-navigation.md).

### Žiadne ikony na ploche a dock sa ukáže len vtedy, keď plávate

Žiadne ikony na rozmiestňovanie po ploche a žiadny dock na dlaždicovom pracovnom priestore — dock sa objaví len na plávajúcom pracovnom priestore (pozrite si [navigáciu](04-navigation.md)). Aplikácie sa spúšťajú klávesovou skratkou (`Super + Return` pre terminál, `Super + Shift + Return` pre prehliadač a `Super + K` pre zoznam všetkého namapovaného) alebo z ponuky. Jediným trvalým prvkom rozhrania je [horný panel](05-the-top-bar.md), ktorý preberá to, čo pre vás predtým robili panel ponúk, systémová lišta a Notification Center — a takmer každý widget na ňom niečo robí pri kliknutí ľavým, pravým aj stredným tlačidlom.

### Okná sa umiestňujú samy

Najväčšia zmena v myslení: okná neťaháte po obrazovke ani ich neprichytávate na polovice obrazovky. Otvoríte okno a zaberie celú obrazovku. Otvoríte druhé a rozdelia si ju. Nikdy nelovíte okno spod iného, pretože okná sa neprekrývajú.

Keď plávajúce okno skutočne potrebujete, `Super + T` prepne aktívne okno von z dlaždíc (a späť). Najprv však dajte dlaždiciam skutočnú šancu — je to srdce celej veci. [Navigácia](04-navigation.md) vás tým prevedie.

Pracovné priestory vám budú povedomé: sú to Spaces z macOS alebo virtuálne plochy z Windowsu, akurát ich budete naozaj používať, pretože `Super + 1/2/3/4` skočí rovno na vybraný a `Super + Shift + 1/2/3/4` tam pošle aktívne okno. Žiadne oneskorenie animácie, len okamžité skoky. Znamená to, že možno ani nebudete potrebovať viac monitorov, ak ste na to boli predtým zvyknutí.

### Kopírovanie a vkladanie proste funguje

Na Macu ste mali všade Cmd + C. Na Windowse ste mali všade Ctrl + C — okrem terminálu, kde vám to zabije program. Omarchy vám dáva `Super + C`, `Super + X` a `Super + V` a fungujú všade, vrátane terminálu. Žiadny samostatný reflex pre shell sa učiť nemusíte.

Ľudia z Windowsu: vaša história schránky z Win + V žije na `Super + Ctrl + V` a drží obrázky aj text. Pozrite si [zjednotenú schránku a históriu](08-unified-clipboard-history.md).

### Prekladová tabuľka

| Siahate po | V Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / ponuka Štart | `Super + Space` — ponuka Omarchy |
| AirDrop | LocalSend, cez `Super + Ctrl + S` — pozrite si [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` alebo `Print Screen` — pozrite si [snímky obrazovky a nahrávanie](12-screenshots-recording.md) |
| Notification Center | História upozornení na `Super + Shift + Alt + ,` |
| Time Machine (pre systém) | Automatické [snímky systému](47-system-snapshots.md) pri každej aktualizácii |
| App Store / sťahovanie inštalátora | _Install_ v ponuke alebo `omarchy pkg add` — pozrite si [ďalšie balíčky](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ v ponuke, ktoré upravuje obyčajné konfiguračné súbory — pozrite si [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, na `Super + Shift + F` — pozrite si [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome na `Super + Shift + Return`; iný si vyberiete v _Setup > Defaults > Browser_ — pozrite si [prehliadače](23-browsers.md) |
| Preview / Photos | Omaview na obrázky, video a hudbu, Document Viewer na PDF — pozrite si [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, na `Super + Shift + N`; iný si vyberiete v _Setup > Defaults > Editor_ |

### Niektoré veci sú naozaj iné

Veľa nastavení žije v textových súboroch, ktoré upravujete, nie v paneloch, cez ktoré sa preklikávate. Znie to primitívne, kým si neuvedomíte, že to znamená, že každú úpravu môžete vidieť, skopírovať na ďalší počítač a dať pod správu verzií. Ponuka _Setup_ vás hodí rovno do správneho súboru a keď skončíte, reštartuje všetko, čo reštart potrebuje.

Aktualizácie prichádzajú cez jeden príkaz — _Update > Omarchy_ — ktorý aktualizuje samotné Omarchy aj každý balíček v systéme a najprv urobí snímku. Žiadne aktualizátory jednotlivých aplikácií, ktoré by vás otravovali náhodne. Pozrite si [aktualizácie](30-updates.md).

Softvér pochádza zo správcu balíčkov, nie zo stiahnutých inštalátorov.

A keď zatvoríte okno, aplikácia sa naozaj ukončí. Neexistuje žiadne limbo z macOS, kde program beží ďalej bez okien. `Super + W` — alebo `Super + Q`, ak ste prišli s touto prstovou pamäťou — znamená preč.

### Na hardvéri Mac

Omarchy beží dobre na Macoch s Intelom a na Macoch M1, M2 a M3 s Omarchy for Apple Silicon. Pozrite si [podporu Macov](44-mac-support.md). A klávesnica je k vám milá: Omarchy nič nepremapováva a Linux berie kláves Command ako Super, takže Super sedí presne tam, kde vždy bolo Cmd. Váš palec si presun ani nevšimne.

### Dajte tomu dva týždne

Inštinkty sa prenesú rýchlejšie, než by ste čakali. Kapitolu [klávesové skratky](07-hotkeys.md) si raz prebehnite a vždy, keď vám vypadne nejaká väzba, stlačte `Super + K` — ukáže vám ich všetky. To je jediná klávesová skratka, ktorú si naozaj musíte zapamätať.
