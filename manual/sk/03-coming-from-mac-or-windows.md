# Prechod z Macu alebo Windowsu

Ak ste roky strávili na macOS alebo Windowse, vaše prsty vedia sto vecí, ktoré váš mozog už dávno zabudol, že sa niekedy naučil. Táto kapitola je prekladová vrstva: kam tie inštinkty v Omarchy patria. Samotné funkcie sú podrobne rozobraté inde — toto je len mapa.

### Super je stredom všetkého

Všetka svalová pamäť, ktorú ste si vybudovali okolo Cmd alebo klávesu Windows, sa prenesie na jeden kláves: Super. To je kláves Windows na PC klávesnici a je kotvou takmer každej klávesovej skratky v Omarchy.

Váš reflex na Spotlight, Raycast alebo ponuku Štart sa stane `Super + Space`. Tým sa otvorí menu Omarchy, ktoré spúšťa aplikácie, mení nastavenia, inštaluje softvér, zachytáva obrazovku — takmer všetko. Začnite písať a filtrujte. `Super + Alt + Space` zobrazí všetky aplikácie na jednej mriežke, tak ako to robí Launchpad. Pozrite si [navigáciu](04-navigation.md).

### Žiadne ikony na ploche a dok zostáva mimo cesty

Žiadne ikony na usporiadanie na ploche a dok sa skryje, len čo má pracovný priestor okno, až kým nezatlačíte ukazovateľ k jej okraju obrazovky, k spodnému, pokiaľ ho nepremiestnite (pozrite si [navigáciu](04-navigation.md)). Aplikácie sa spúšťajú klávesovou skratkou (`Super + Return` pre terminál, `Super + Shift + Return` pre prehliadač a `Super + K` pre zoznam všetkého, čo je namapované) alebo z menu. Jediný trvalý prvok používateľského rozhrania je [horná lišta](05-the-top-bar.md), ktorá pokrýva to, čo pre vás predtým robili panel ponúk, systémová lišta a Centrum hlásení — a takmer každý widget na nej niečo robí pri kliknutí ľavým, pravým aj stredným tlačidlom.

### Okná sa umiestňujú samy

Najväčší posun v myslení: okná neťaháte po obrazovke ani ich neprichytávate k poloviciam obrazovky. Otvorte okno a zaberie celú obrazovku. Otvorte druhé a rozdelia si ju. Nikdy nelovíte okno spod iného, pretože okná sa neprekrývajú.

Keď skutočne potrebujete plávajúce okno, `Super + T` prepne aktívne okno von z dlaždicového usporiadania (a späť). Najprv však dajte dlaždicovému usporiadaniu poriadnu šancu — je srdcom celej veci. [Navigácia](04-navigation.md) vás ním prevedie.

Pracovné priestory vám budú povedomé: sú to macOS Spaces alebo virtuálne plochy vo Windowse, akurát ich budete skutočne používať, pretože `Super + 1/2/3/4` skočí priamo na jeden z nich a `Super + Shift + 1/2/3/4` tam pošle aktívne okno. Žiadne oneskorenie animácie, len okamžité skoky. To znamená, že možno nebudete potrebovať ani viac monitorov, ak ste na to boli predtým zvyknutí.

### Kopírovanie a vkladanie jednoducho funguje

Na Macu ste mali Cmd + C všade. Na Windowse ste mali Ctrl + C všade — okrem terminálu, kde vám zabije program. Omarchy vám dá `Super + C`, `Super + X` a `Super + V` a fungujú všade vrátane terminálu. Nemusíte sa učiť žiadny samostatný reflex pre shell.

Ľudia z Windowsu: vaša história schránky Win + V žije na `Super + Ctrl + V` a uchováva obrázky aj text. Pozrite si [jednotnú schránku a históriu](08-unified-clipboard-history.md).

### Prekladová tabuľka

| Po čom siahate | V Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — menu Omarchy |
| AirDrop | LocalSend, pomocou `Super + Ctrl + S` — pozrite si [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` alebo `Print Screen` — pozrite si [snímky obrazovky a nahrávanie](12-screenshots-recording.md) |
| Notification Center | História hlásení na `Super + Shift + Alt + ,` |
| Time Machine (pre systém) | Automatické [snímky systému](47-system-snapshots.md) pri každej aktualizácii |
| App Store / sťahovanie inštalátora | _Inštalovať_ v menu alebo `omarchy pkg add` — pozrite si [ďalšie balíčky](29-other-packages.md) |
| System Settings / Control Panel | _Nastavenie_ v menu, ktoré upravuje obyčajné konfiguračné súbory — pozrite si [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, na `Super + Shift + F` — pozrite si [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome na `Super + Shift + Return`; iný si vyberte v _Nastavenie > Predvolené > Prehliadač_ — pozrite si [prehliadače](23-browsers.md) |
| Preview / Photos | Omaview na obrázky, video a hudbu, Document Viewer na PDF — pozrite si [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, na `Super + Shift + N`; iný si vyberte v _Nastavenie > Predvolené > Editor_ |

### Niektoré veci sú naozaj iné

Veľa nastavení žije v textových súboroch, ktoré upravujete, nie v paneloch, cez ktoré sa preklikávate. Znie to primitívne, kým si neuvedomíte, že to znamená, že každú úpravu môžete vidieť, skopírovať na svoj ďalší počítač a dať pod správu verzií. Menu _Nastavenie_ vás hodí priamo do správneho súboru a keď skončíte, reštartuje všetko, čo reštart potrebuje.

Aktualizácie prichádzajú cez jeden príkaz — _Aktualizácia > Omarchy_ — ktorý aktualizuje samotné Omarchy aj každý balíček v systéme a najprv vytvorí snímku. Žiadne aktualizátory jednotlivých aplikácií, ktoré by vás otravovali v náhodných chvíľach. Pozrite si [aktualizácie](30-updates.md).

Softvér pochádza zo správcu balíčkov, nie zo stiahnutých inštalátorov.

A keď okno zavriete, aplikácia sa skutočne ukončí. Neexistuje žiadny medzistav ako v macOS, kde program beží ďalej bez okien. `Super + W` — alebo `Super + Q`, ak ste prišli práve s touto prstovou pamäťou — znamená preč.

### Na hardvéri Mac

Omarchy beží dobre na Intel Macoch a na Macoch s M1, M2 a M3 s Omarchy for Apple Silicon. Pozrite si [podporu Macu](44-mac-support.md). A klávesnica je k vám láskavá: Omarchy nič nepremapováva a Linux zaobchádza s klávesom Command ako so Super, takže Super sedí presne tam, kde vždy bolo Cmd. Váš palec si presun ani nevšimne.

### Dajte tomu dva týždne

Inštinkty sa prenesú rýchlejšie, než by ste si mysleli. Raz si prebehnite kapitolu [klávesové skratky](07-hotkeys.md) a kedykoľvek vám vypadne nejaká skratka, stlačte `Super + K` — ukáže vám ich všetky. To je jediná skratka, ktorú si naozaj musíte zapamätať.
