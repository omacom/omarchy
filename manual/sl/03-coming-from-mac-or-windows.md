# Prihajate z Maca ali Windowsa

Če ste leta preživeli na macOS ali Windows, vaši prsti poznajo sto stvari, za katere so vaši možgani pozabili, da so se jih sploh kdaj naučili. To poglavje je prevajalska plast: kam gredo ti instinkti v Omarchy. Same funkcije so podrobno obravnavane drugje — to je le zemljevid.

### Super je središče vsega

Ves mišični spomin, ki ste ga zgradili okoli Cmd ali tipke Windows, se prenese na eno tipko: Super. To je tipka Windows na tipkovnici PC in je sidro za skoraj vsako bližnjico v Omarchy.

Vaš refleks za Spotlight ali Raycast ali meni Start postane `Super + Space`. To odpre meni Omarchy, ki zaganja aplikacije, spreminja nastavitve, namešča programsko opremo, zajema zaslon — skoraj vse. Začnite tipkati za filtriranje. `Super + Alt + Space` prikaže vse aplikacije na eni mreži, tako kot to počne Launchpad. Glejte [navigacija](04-navigation.md).

### Nobenih ikon na namizju, dok pa se umakne s poti

Nobenih ikon za razporejanje po namizju, dok pa se skrije, takoj ko ima delovni prostor okno, dokler kazalca ne potisnete do njegovega roba zaslona, desnega, razen če ga premaknete (glejte [navigacija](04-navigation.md)). Aplikacije zaženete z bližnjico (`Super + Return` za terminal, `Super + Shift + Return` za brskalnik in `Super + K` za seznam vsega, kar je preslikano) ali iz menija. Edini stalni del uporabniškega vmesnika je [zgornja vrstica](05-the-top-bar.md), ki pokriva to, kar so prej za vas počeli menijska vrstica, sistemska vrstica in Notification Center — in skoraj vsak gradnik na njej nekaj naredi ob levem, desnem in srednjem kliku.

### Okna se postavijo sama

Največji miselni preobrat: oken ne vlečete naokrog in jih ne pripenjate na polovice zaslona. Odprete okno in zavzame cel zaslon. Odprete drugo in si ga razdelita. Nikoli ne ribarite okna izpod drugega, ker se okna ne prekrivajo.

Ko zares potrebujete plavajoče okno, `Super + T` aktivno okno preklopi iz ploščic (in nazaj). Ampak ploščicam najprej dajte pravo priložnost — so srce celotne stvari. [Navigacija](04-navigation.md) vas vodi skozi to.

Delovni prostori se bodo zdeli znani: so macOS Spaces ali navidezna namizja v Windows, le da jih boste dejansko uporabljali, ker `Super + 1/2/3/4` skoči naravnost na enega, `Super + Shift + 1/2/3/4` pa tja pošlje aktivno okno. Brez zamika animacije, samo takojšnji skoki. To pomeni, da morda sploh ne boste potrebovali več monitorjev, če ste bili tega vajeni prej.

### Kopiranje in lepljenje preprosto delujeta

Na Macu ste povsod imeli Cmd + C. Na Windows ste povsod imeli Ctrl + C — razen v terminalu, kjer ubije vaš program. Omarchy vam da `Super + C`, `Super + X` in `Super + V` in delujejo povsod, vključno s terminalom. Nobenega ločenega refleksa se ni treba učiti za lupino.

Ljudje z Windows: vaša zgodovina odložišča z Win + V živi na `Super + Ctrl + V` in hrani slike tako kot besedilo. Glejte [poenoteno odložišče in zgodovina](08-unified-clipboard-history.md).

### Prevajalska tabela

| Sežete po | V Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — meni Omarchy |
| AirDrop | LocalSend, prek `Super + Ctrl + S` — glejte [grafični vmesniki](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` ali `Print Screen` — glejte [posnetki zaslona in snemanje](12-screenshots-recording.md) |
| Notification Center | Zgodovina obvestil na `Super + Shift + Alt + ,` |
| Time Machine (za sistem) | Samodejni [sistemski posnetki](47-system-snapshots.md) ob vsaki posodobitvi |
| App Store / downloading an installer | _Install_ v meniju ali `omarchy pkg add` — glejte [drugi paketi](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ v meniju, ki ureja navadne konfiguracijske datoteke — glejte [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, na `Super + Shift + F` — glejte [grafični vmesniki](22-guis.md) |
| Safari / Edge | Google Chrome na `Super + Shift + Return`; izberite drugega pod _Setup > Defaults > Browser_ — glejte [brskalniki](23-browsers.md) |
| Preview / Photos | Omaview za slike, video in glasbo, Document Viewer za PDF-je — glejte [grafični vmesniki](22-guis.md) |
| TextEdit / Notepad | Plain, na `Super + Shift + N`; izberite drugega pod _Setup > Defaults > Editor_ |

### Nekatere stvari so res drugačne

Veliko nastavitev živi v besedilnih datotekah, ki jih urejate, ne v ploščah, skozi katere klikate. To se sliši primitivno, dokler ne spoznate, da pomeni, da je vsako prilagoditev mogoče videti, kopirati na vaš naslednji računalnik in dati pod nadzor različic. Meni _Setup_ vas spusti naravnost v pravo datoteko in znova zažene, kar je treba znova zagnati, ko končate.

Posodobitve pridejo z enim ukazom — _Update > Omarchy_ — ki posodobi sam Omarchy in vsak paket v sistemu, pri čemer najprej naredi posnetek. Nobenih posodobljevalnikov za posamezne aplikacije, ki bi vas nadlegovali naključno. Glejte [posodobitve](30-updates.md).

Programska oprema prihaja iz upravitelja paketov, ne iz prenesenih namestitvenih programov.

In ko zaprete okno, se aplikacija dejansko zapre. Ni tistega vmesnega stanja v macOS, kjer program še naprej teče brez oken. `Super + W` — ali `Super + Q`, če je to spomin prstov, s katerim ste prišli — pomeni, da je ni več.

### Na strojni opremi Mac

Omarchy dobro teče na Intel Macih ter na M1, M2 in M3 Macih z Omarchy for Apple Silicon. Glejte [podpora za Mac](44-mac-support.md). In tipkovnica je prijazna do vas: Omarchy ničesar ne preslika na novo, Linux pa tipko Command obravnava kot Super, zato je Super točno tam, kjer je bil vedno Cmd. Vaš palec selitve ne bo opazil.

### Dajte temu dva tedna

Instinkti se prenesejo hitreje, kot bi si mislili. Enkrat preletite poglavje [bližnjice](07-hotkeys.md) in kadar koli vam zmanjka spomina za vezavo, pritisnite `Super + K` — pokaže vam vse. To je edina bližnjica, ki si jo morate dejansko zapomniti.
