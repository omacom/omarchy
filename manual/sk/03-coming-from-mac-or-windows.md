# Príchod z Macu alebo Windowsu

Ak ste roky používali macOS alebo Windows, vaše prsty poznajú sto vecí, ktoré váš mozog zabudol, že sa ich kedy naučil. Táto kapitola je prekladovou vrstvou: kam tie inštinkty v Omarchy smerujú. Samotné funkcie sú podrobne opísané inde — toto je len mapa.

### Super je centrom všetkého

Všetka svalová pamäť, ktorú ste si vybudovali okolo Cmd alebo klávesu Windows, sa prenáša na jeden kláves: Super. To je kláves Windows na PC klávesnici a je kotvou takmer každej klávesovej skratky v Omarchy.

Váš reflex na Spotlight alebo Raycast alebo ponuku Štart sa stáva `Super + Space`. To otvára menu Omarchy, ktoré spúšťa aplikácie, mení nastavenia, inštaluje softvér, zachytáva obrazovku — takmer všetko. Začnite písať na filtrovanie. `Super + Alt + Space` zobrazí každú aplikáciu na jednej mriežke, ako to robí Launchpad. Pozrite si [navigáciu](04-navigation.md).

### Neexistuje žiadny dock a žiadne ikony na pracovnej ploche

Nič, na čo by ste mohli kliknúť na spúšťanie vecí, žiadne ikony na usporadúvanie na pracovnej ploche. Aplikácie sa spúšťajú z klávesovej skratky (`Super + Return` pre terminál, `Super + Shift + Return` pre prehliadač a `Super + K` pre zoznam všetkého, čo je namapované) alebo z menu. Jediným stálym kusom používateľského rozhrania je [horná lišta](05-the-top-bar.md), ktorá pokrýva to, čo pre vás predtým robili lišta menu, systémová lišta a Centrum upozornení — a takmer každý widget na nej niečo robí na ľavé, pravé a stredné kliknutie.

### Okná sa umiestňujú samy

Najväčší posun v myslení: okná neťaháte okolo ani ich neprichytávate k poloviciam obrazovky. Otvoríte okno a zaberie celú obrazovku. Otvoríte druhé a rozdelia si ju. Nikdy nelovíte okno spod iného, pretože okná sa neprekrývajú.

Keď skutočne potrebujete plávajúce okno, `Super + T` prepne aktívne okno z dlaždíc (a späť). Ale najskôr dajte dlaždiciam skutočnú šancu — sú srdcom celej veci. [Navigácia](04-navigation.md) vás ňou prevedie.

Pracovné plochy vám budú pripadať známe: sú to macOS Spaces alebo virtuálne pracovné plochy Windowsu, až na to, že ich budete skutočne používať, pretože `Super + 1/2/3/4` skočí priamo na jednu a `Super + Shift + 1/2/3/4` tam odošle aktívne okno. Žiadne oneskorenie animácie, len okamžité skoky. To znamená, že možno ani nebudete potrebovať viacero monitorov, ak ste na to boli zvyknutí predtým.

### Kopírovanie a vkladanie skrátka funguje

Na Macu ste mali Cmd + C všade. Vo Windowse ste mali Ctrl + C všade — okrem terminálu, kde to zabíja váš program. Omarchy vám dáva `Super + C`, `Super + X` a `Super + V` a fungujú všade vrátane terminálu. Žiadny samostatný reflex, ktorý by ste sa museli učiť pre shell.

Ľudia z Windowsu: vaša história schránky Win + V žije na `Super + Ctrl + V` a uchováva obrázky aj text. Pozrite si [jednotnú schránku a históriu](08-unified-clipboard-history.md).

### Prekladová tabuľka

| Siahate po | V Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / ponuka Štart | `Super + Space` — menu Omarchy |
| AirDrop | LocalSend, cez `Super + Ctrl + S` — pozrite si [GUI](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — pozrite si [snímky obrazovky a nahrávanie](12-screenshots-recording.md) |
| Centrum upozornení | História upozornení na `Super + Shift + Alt + ,` |
| Time Machine (pre systém) | Automatické [snímky systému](47-system-snapshots.md) pri každej aktualizácii |
| App Store / sťahovanie inštalátora | _Inštalovať_ v menu alebo `omarchy pkg add` — pozrite si [ďalšie balíčky](29-other-packages.md) |
| Nastavenia systému / Ovládací panel | _Nastavenie_ v menu, ktoré upravuje obyčajné konfiguračné súbory — pozrite si [dotfiles](31-dotfiles.md) |

### Niektoré veci sú skutočne iné

Mnoho nastavení žije v textových súboroch, ktoré upravujete, nie v paneloch, cez ktoré klikáte. To znie primitívne, kým si neuvedomíte, že to znamená, že každú úpravu vidno, možno ju skopírovať na váš ďalší stroj a dať pod správu verzií. Menu _Nastavenie_ vás zloží priamo do správneho súboru a po dokončení reštartuje všetko, čo potrebuje reštartovať.

Aktualizácie prichádzajú cez jeden príkaz — _Aktualizovať > Omarchy_ — ktorý aktualizuje samotné Omarchy a každý balíček v systéme, pričom najskôr urobí snímku. Žiadne aktualizátory jednotlivých aplikácií vás náhodne neobťažujú. Pozrite si [aktualizácie](30-updates.md).

Softvér pochádza zo správcu balíčkov, nie zo stiahnutých inštalátorov.

A keď zatvoríte okno, aplikácia sa skutočne ukončí. Neexistuje žiadne limbo macOS, kde program beží ďalej bez okien. `Super + W` — alebo `Super + Q`, ak je to pamäť prsta, s ktorou ste prišli — znamená preč.

### Na hardvéri Mac

Omarchy beží dobre na Intel Macoch — pozrite si [podporu Mac](44-mac-support.md). A klávesnica je k vám láskavá: Omarchy nič nepremapúva a Linux považuje kláves Command za Super, takže Super sedí presne tam, kde vždy bolo Cmd. Váš palec si presun nevšimne.

### Dajte tomu dva týždne

Inštinkty sa prenášajú rýchlejšie, než si myslíte. Raz si prezrite kapitolu o [klávesových skratkách](07-hotkeys.md) a vždy, keď vám vypadne nejaká väzba, stlačte `Super + K` — ukáže vám ich všetky. To je jediná klávesová skratka, ktorú si skutočne musíte zapamätať.
