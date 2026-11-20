# Prechod z Macu alebo Windowsu

Ak ste roky strávili na macOS alebo Windowse, vaše prsty vedia sto vecí, na ktoré vaša hlava už dávno zabudla, že sa ich vôbec naučila. Táto kapitola je prekladová vrstva: kam tie inštinkty v Omarchy patria. Samotné funkcie sú podrobne rozobraté inde — toto je len mapa.

### Super je stredobodom všetkého

Všetka svalová pamäť, ktorú ste si vybudovali okolo Cmd alebo klávesu Windows, sa prenáša na jediný kláves: Super. Je to kláves Windows na PC klávesnici a kotva takmer každej klávesovej skratky v Omarchy.

Váš reflex na Spotlight, Raycast alebo ponuku Start sa stáva `Super + Space`. Tým sa otvorí ponuka Omarchy, ktorá spúšťa aplikácie, mení nastavenia, inštaluje softvér, zachytáva obrazovku — takmer všetko. Začnite písať a filtrujete. `Super + Alt + Space` zobrazí všetky aplikácie na jednej mriežke, tak ako to robí Launchpad. Pozri [navigáciu](04-navigation.md).

### Žiadne ikony na ploche a dok sa ukáže len na plávajúcej pracovnej ploche

Žiadne ikony, ktoré by ste museli usporadúvať na ploche, a žiadny dok na dlaždicovej pracovnej ploche — dok sa zobrazí len na plávajúcej pracovnej ploche (pozri [navigáciu](04-navigation.md)). Aplikácie spúšťate klávesovou skratkou (`Super + Return` pre terminál, `Super + Shift + Return` pre prehliadač a `Super + K` pre zoznam všetkého, čo je namapované) alebo z ponuky. Jediným trvalým prvkom používateľského rozhrania je [horná lišta](05-the-top-bar.md), ktorá pokrýva to, čo pre vás predtým robili panel ponúk, systémová lišta a Notification Center — a takmer každý widget na nej niečo robí pri kliknutí ľavým, pravým aj stredným tlačidlom.

### Okná sa umiestňujú samy

Najväčší posun v myslení: okná neťaháte po obrazovke ani ich neprichytávate k poloviciam obrazovky. Otvoríte okno a zaberie celú obrazovku. Otvoríte druhé a rozdelia si ju. Nikdy nemusíte loviť okno spod iného, pretože okná sa neprekrývajú.

Keď naozaj potrebujete plávajúce okno, `Super + T` prepne aktívne okno von z dlaždíc (a späť). Najprv však dajte dlaždiciam poriadnu šancu — sú srdcom celej veci. [Navigácia](04-navigation.md) vás tým prevedie.

Pracovné plochy vám budú povedomé: sú to Spaces z macOS alebo virtuálne plochy z Windowsu, akurát ich budete naozaj používať, pretože `Super + 1/2/3/4` skočí rovno na jednu z nich a `Super + Shift + 1/2/3/4` tam pošle aktívne okno. Žiadne oneskorenie animácie, len okamžité skoky. To znamená, že možno ani nebudete potrebovať viac monitorov, ak ste na to boli predtým zvyknutí.

### Kopírovanie a vkladanie jednoducho fungujú

Na Macu ste mali Cmd + C všade. Na Windowse ste mali Ctrl + C všade — okrem terminálu, kde vám to zabije program. Omarchy vám dáva `Super + C`, `Super + X` a `Super + V` a fungujú všade, vrátane terminálu. Nemusíte sa učiť samostatný reflex pre shell.

Ľudia z Windowsu: vaša história schránky z Win + V žije na `Super + Ctrl + V` a uchováva obrázky aj text. Pozri [jednotnú schránku & históriu](08-unified-clipboard-history.md).

### Prekladová tabuľka

| Po čom siahate | V Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — ponuka Omarchy |
| AirDrop | LocalSend, cez `Super + Ctrl + S` — pozri [grafické aplikácie](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` alebo `Print Screen` — pozri [snímky obrazovky & nahrávanie](12-screenshots-recording.md) |
| Notification Center | História oznámení na `Super + Shift + Alt + ,` |
| Time Machine (pre systém) | Automatické [systémové snímky](47-system-snapshots.md) pri každej aktualizácii |
| App Store / sťahovanie inštalátora | _Install_ v ponuke, alebo `omarchy pkg add` — pozri [ďalšie balíčky](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ v ponuke, ktoré upravuje obyčajné konfiguračné súbory — pozri [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, na `Super + Shift + F` — pozri [grafické aplikácie](22-guis.md) |
| Safari / Edge | Google Chrome na `Super + Shift + Return`; iný si vyberiete v _Setup > Defaults > Browser_ — pozri [prehliadače](23-browsers.md) |
| Preview / Photos | Omaview na obrázky, video a hudbu, Document Viewer na PDF — pozri [grafické aplikácie](22-guis.md) |
| TextEdit / Notepad | Plain, na `Super + Shift + N`; iný si vyberiete v _Setup > Defaults > Editor_ |

### Niektoré veci sú naozaj iné

Veľa nastavení žije v textových súboroch, ktoré upravujete, nie v paneloch, cez ktoré sa preklikávate. Znie to primitívne, kým si neuvedomíte, že to znamená, že každú úpravu môžete vidieť, skopírovať na ďalší počítač a dať pod správu verzií. Ponuka _Setup_ vás hodí rovno do správneho súboru a po dokončení reštartuje všetko, čo reštart potrebuje.

Aktualizácie prichádzajú cez jeden príkaz — _Update > Omarchy_ — ktorý aktualizuje samotné Omarchy aj každý balíček v systéme a najprv vytvorí snímku. Žiadne aktualizátory jednotlivých aplikácií, ktoré by vás otravovali v náhodných chvíľach. Pozri [aktualizácie](30-updates.md).

Softvér pochádza zo správcu balíčkov, nie zo stiahnutých inštalátorov.

A keď zatvoríte okno, aplikácia sa naozaj ukončí. Neexistuje žiadne limbo z macOS, kde program beží ďalej bez okien. `Super + W` — alebo `Super + Q`, ak ste prišli s touto pamäťou prstov — znamená, že je preč.

### Na hardvéri Mac

Omarchy beží dobre na Macoch s Intelom — pozri [podporu Macov](44-mac-support.md). A klávesnica je k vám láskavá: Omarchy nič nepremapuje a Linux považuje kláves Command za Super, takže Super sedí presne tam, kde vždy bolo Cmd. Váš palec si presun ani nevšimne.

### Dajte tomu dva týždne

Inštinkty sa prenesú rýchlejšie, než by ste si mysleli. Raz si prebehnite kapitolu [klávesové skratky](07-hotkeys.md) a vždy, keď vám vypadne nejaká skratka, stlačte `Super + K` — ukáže vám ich všetky. To je jediná klávesová skratka, ktorú si naozaj musíte zapamätať.
