# Prechod z Macu alebo Windows

Ak ste roky strávili na macOS alebo Windows, vaše prsty ovládajú sto vecí, na ktoré váš mozog už zabudol, že sa ich vôbec naučil. Táto kapitola je prekladovou vrstvou: kam tieto návyky v Omarchy patria. Samotné funkcie sú podrobne popísané inde — toto je len mapa.

### Super je stredom všetkého

Všetka svalová pamäť, ktorú ste si vybudovali okolo Cmd alebo klávesu Windows, sa prenáša na jeden kláves: Super. Je to kláves Windows na klávesnici PC a je kotvou pre takmer každú klávesovú skratku v Omarchy.

Váš reflex na Spotlight, Raycast alebo ponuku Štart sa mení na `Super + Space`. Tým sa otvorí ponuka Omarchy, ktorá spúšťa aplikácie, mení nastavenia, inštaluje softvér, zachytáva obrazovku — skrátka takmer všetko. Začnite písať a môžete filtrovať. `Super + Alt + Space` zobrazí všetky aplikácie v jednej mriežke, tak ako to robí Launchpad. Pozrite si [navigáciu](04-navigation.md).

### Žiadne ikony na ploche a dok zostáva mimo cesty

Žiadne ikony, ktoré by ste museli usporadúvať na ploche, a dok sa skryje, len čo má pracovný priestor okno, až kým neposuniete ukazovateľ k jeho okraju obrazovky, k pravému, pokiaľ ho nepresuniete (pozrite si [navigáciu](04-navigation.md)). Aplikácie sa spúšťajú klávesovou skratkou (`Super + Return` pre terminál, `Super + Shift + Return` pre prehliadač a `Super + K` pre zoznam všetkého, čo je namapované) alebo z ponuky. Jediný trvalý prvok používateľského rozhrania je [horný panel](05-the-top-bar.md), ktorý pokrýva to, čo pre vás predtým robili panel ponúk, systémová lišta a Notification Center — a takmer každý widget na ňom niečo robí pri kliknutí ľavým, pravým a stredným tlačidlom.

### Okná sa umiestňujú samy

Najväčší posun v myslení: okná neťaháte po obrazovke ani ich neprichytávate k poloviciam obrazovky. Otvoríte okno a zaberie celú obrazovku. Otvoríte druhé a rozdelia si ju. Nikdy nemusíte loviť okno spod iného, pretože okná sa neprekrývajú.

Keď naozaj potrebujete plávajúce okno, `Super + T` prepne aktívne okno z dlaždicového usporiadania (a späť). Najprv však dajte dlaždicovému usporiadaniu skutočnú šancu — je srdcom celej veci. [Navigácia](04-navigation.md) vás ním prevedie.

Pracovné priestory vám budú povedomé: sú to Spaces z macOS alebo virtuálne plochy z Windows, až na to, že ich skutočne budete používať, pretože `Super + 1/2/3/4` skočí priamo na jeden z nich a `Super + Shift + 1/2/3/4` tam pošle aktívne okno. Žiadne oneskorenie animácie, len okamžité skoky. To znamená, že možno ani nebudete potrebovať viac monitorov, ak ste na to boli predtým zvyknutí.

### Kopírovanie a vkladanie jednoducho fungujú

Na Macu ste všade mali Cmd + C. Na Windows ste všade mali Ctrl + C — okrem terminálu, kde vám to zabije program. Omarchy vám dáva `Super + C`, `Super + X` a `Super + V` a fungujú všade, vrátane terminálu. Nemusíte sa učiť samostatný reflex pre shell.

Ľudia z Windows: vaša história schránky z Win + V žije na `Super + Ctrl + V` a ukladá obrázky aj text. Pozrite si [jednotnú schránku a históriu](08-unified-clipboard-history.md).

### Prekladová tabuľka

| Siahate po | V Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / ponuka Štart | `Super + Space` — ponuka Omarchy |
| AirDrop | LocalSend, cez `Super + Ctrl + S` — pozrite si [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` alebo `Print Screen` — pozrite si [snímky obrazovky a nahrávanie](12-screenshots-recording.md) |
| Notification Center | História oznámení na `Super + Shift + Alt + ,` |
| Time Machine (pre systém) | Automatické [systémové snímky](47-system-snapshots.md) pri každej aktualizácii |
| App Store / sťahovanie inštalátora | _Install_ v ponuke alebo `omarchy pkg add` — pozrite si [ďalšie balíčky](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ v ponuke, ktoré upravuje jednoduché konfiguračné súbory — pozrite si [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, na `Super + Shift + F` — pozrite si [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome na `Super + Shift + Return`; iný si vyberiete v _Setup > Defaults > Browser_ — pozrite si [prehliadače](23-browsers.md) |
| Preview / Photos | Omaview pre obrázky, video a hudbu, Document Viewer pre PDF — pozrite si [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, na `Super + Shift + N`; iný si vyberiete v _Setup > Defaults > Editor_ |

### Niektoré veci sú naozaj iné

Veľa nastavení žije v textových súboroch, ktoré upravujete, nie v paneloch, cez ktoré sa preklikávate. Znie to primitívne, kým si neuvedomíte, že to znamená, že každú úpravu môžete vidieť, skopírovať na ďalší počítač a dať pod správu verzií. Ponuka _Setup_ vás hodí priamo do správneho súboru a po dokončení reštartuje všetko, čo reštart potrebuje.

Aktualizácie prichádzajú cez jeden príkaz — _Update > Omarchy_ — ktorý aktualizuje samotné Omarchy aj každý balíček v systéme a najprv vytvorí snímku. Žiadne aktualizátory jednotlivých aplikácií, ktoré by vás otravovali v náhodných chvíľach. Pozrite si [aktualizácie](30-updates.md).

Softvér pochádza zo správcu balíčkov, nie zo stiahnutých inštalátorov.

A keď zatvoríte okno, aplikácia sa skutočne ukončí. Neexistuje žiadne limbo z macOS, kde program beží ďalej bez okien. `Super + W` — alebo `Super + Q`, ak ste prišli s touto prstovou pamäťou — znamená koniec.

### Na hardvéri Mac

Omarchy beží dobre na Macoch s Intelom a na Macoch M1, M2 a M3 s Omarchy for Apple Silicon. Pozrite si [podporu Macu](44-mac-support.md). A klávesnica je k vám milá: Omarchy nič nepremapováva a Linux považuje kláves Command za Super, takže Super sedí presne tam, kde vždy bolo Cmd. Váš palec si tento presun ani nevšimne.

### Dajte tomu dva týždne

Návyky sa prenesú rýchlejšie, než by ste si mysleli. Raz si prebehnite kapitolu [klávesové skratky](07-hotkeys.md) a vždy, keď vám vypadne nejaká skratka, stlačte `Super + K` — ukáže vám ich všetky. To je jediná klávesová skratka, ktorú si naozaj musíte zapamätať.
