# Prechod z Macu alebo Windowsu

Ak ste strávili roky na macOS alebo Windowse, vaše prsty poznajú sto vecí, o ktorých váš mozog už zabudol, že sa ich kedy naučil. Táto kapitola je prekladovou vrstvou: kam tieto inštinkty v Omarchy patria. Samotné funkcie sú podrobne rozobraté inde — toto je len mapa.

### Super je stredom všetkého

Všetka svalová pamäť, ktorú ste si vybudovali okolo Cmd alebo klávesu Windows, sa prenesie na jeden kláves: Super. To je kláves Windows na klávesnici PC a je kotvou takmer každej klávesovej skratky v Omarchy.

Váš reflex na Spotlight, Raycast alebo ponuku Štart sa stane `Super + Space`. Tým sa otvorí ponuka Omarchy, ktorá spúšťa aplikácie, mení nastavenia, inštaluje softvér, zachytáva obrazovku — takmer všetko. Začnite písať a filtrujete. `Super + Alt + Space` zobrazí všetky aplikácie v jednej mriežke, tak ako to robí Launchpad. Pozri [navigáciu](04-navigation.md).

### Žiadny dock ani ikony na ploche

Nič, na čo by sa klikalo pri spúšťaní vecí, žiadne ikony na usporiadanie na ploche. Aplikácie sa spúšťajú klávesovou skratkou (`Super + Return` pre terminál, `Super + Shift + Return` pre prehliadač a `Super + K` pre zoznam všetkého, čo je namapované) alebo z ponuky. Jediný trvalý prvok používateľského rozhrania je [horný panel](05-the-top-bar.md), ktorý zastrešuje to, čo pre vás predtým robili panel ponúk, systémová lišta a Notification Center — a takmer každý widget na ňom niečo robí pri kliknutí ľavým, pravým aj stredným tlačidlom.

### Okná sa umiestňujú samy

Najväčšia zmena v myslení: okná neťaháte a nepripínate ich k poloviciam obrazovky. Otvoríte okno a zaberie celú obrazovku. Otvoríte druhé a rozdelia si ju. Nikdy nelovíte okno spod iného, pretože okná sa neprekrývajú.

Keď naozaj potrebujete plávajúce okno, `Super + T` prepne aktívne okno z dlaždicového režimu von (a späť). Najprv však dajte dlaždiciam poriadnu šancu — sú srdcom celej veci. [Navigácia](04-navigation.md) vás tým prevedie.

Pracovné plochy vám budú povedomé: sú to macOS Spaces alebo virtuálne plochy Windowsu, až na to, že ich budete naozaj používať, pretože `Super + 1/2/3/4` skočí priamo na jednu a `Super + Shift + 1/2/3/4` tam pošle aktívne okno. Žiadne oneskorenie animácie, len okamžité skoky. To znamená, že možno nebudete potrebovať ani viac monitorov, ak ste na to boli predtým zvyknutí.

### Kopírovanie a vkladanie proste funguje

Na Macu ste mali Cmd + C všade. Na Windowse ste mali Ctrl + C všade — okrem terminálu, kde vám to zabije program. Omarchy vám dá `Super + C`, `Super + X` a `Super + V` a fungujú všade, vrátane terminálu. Žiadny samostatný reflex pre shell sa učiť nemusíte.

Ľudia z Windowsu: vaša história schránky Win + V žije na `Super + Ctrl + V` a uchováva obrázky aj text. Pozri [jednotnú schránku a históriu](08-unified-clipboard-history.md).

### Prekladová tabuľka

| Siahate po | V Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / ponuka Štart | `Super + Space` — ponuka Omarchy |
| AirDrop | LocalSend, cez `Super + Ctrl + S` — pozri [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` alebo `Print Screen` — pozri [snímky obrazovky a nahrávanie](12-screenshots-recording.md) |
| Notification Center | História upozornení na `Super + Shift + Alt + ,` |
| Time Machine (pre systém) | Automatické [snímky systému](47-system-snapshots.md) pri každej aktualizácii |
| App Store / sťahovanie inštalátora | _Inštalovať_ v ponuke alebo `omarchy pkg add` — pozri [ďalšie balíčky](29-other-packages.md) |
| Nastavenia systému / Ovládací panel | _Nastavenie_ v ponuke, ktoré upravuje obyčajné konfiguračné súbory — pozri [dotfiles](31-dotfiles.md) |

### Niektoré veci sú naozaj iné

Veľa nastavení žije v textových súboroch, ktoré upravujete, nie v paneloch, cez ktoré sa preklikávate. Znie to primitívne, kým si neuvedomíte, že to znamená, že každú úpravu možno vidieť, skopírovať na ďalší stroj a dať pod správu verzií. Ponuka _Nastavenie_ vás hodí priamo do správneho súboru a po dokončení reštartuje všetko, čo reštartovať treba.

Aktualizácie prichádzajú cez jeden príkaz — _Aktualizácia > Omarchy_ — ktorý aktualizuje samotné Omarchy aj každý balíček v systéme a najprv vytvorí snímku. Žiadne aktualizátory jednotlivých aplikácií, ktoré by vás otravovali v náhodných chvíľach. Pozri [aktualizácie](30-updates.md).

Softvér pochádza zo správcu balíčkov, nie zo stiahnutých inštalátorov.

A keď zatvoríte okno, aplikácia sa naozaj ukončí. Neexistuje žiadne macOS limbo, kde program beží ďalej bez okien. `Super + W` — alebo `Super + Q`, ak je to svalová pamäť, s ktorou ste prišli — znamená preč.

### Na hardvéri Mac

Omarchy beží dobre na Intel Macoch — pozri [podporu Macov](44-mac-support.md). A klávesnica je k vám milá: Omarchy nič nepremapováva a Linux považuje kláves Command za Super, takže Super sedí presne tam, kde vždy bolo Cmd. Váš palec si presun ani nevšimne.

### Dajte tomu dva týždne

Inštinkty sa prenesú rýchlejšie, než by ste si mysleli. Raz si preletieť kapitolu o [klávesových skratkách](07-hotkeys.md) a kedykoľvek vám vypadne nejaká väzba, stlačte `Super + K` — ukáže vám ich všetky. To je jediná skratka, ktorú si naozaj musíte zapamätať.
