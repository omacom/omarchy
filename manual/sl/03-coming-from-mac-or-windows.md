# Prihod z Maca ali Windowsa

Če ste leta preživeli na macOS ali Windows, vaši prsti vedo sto stvari, za katere so vaši možgani pozabili, da so se jih sploh kdaj naučili. To poglavje je prevajalna plast: kam gredo ti instinkti v Omarchy. Same funkcije so podrobno obravnavane drugje — to je samo zemljevid.

### Super je središče vsega

Ves mišični spomin, ki ste ga zgradili okoli Cmd ali tipke Windows, se prenese na eno tipko: Super. To je tipka Windows na tipkovnici PC in je sidro za skoraj vsako bližnjico v Omarchy.

Vaš refleks za Spotlight, Raycast ali meni Start postane `Super + Space`. To odpre meni Omarchy, ki zaganja aplikacije, spreminja nastavitve, namešča programsko opremo, zajema zaslon — praktično vse. Začnite tipkati za filtriranje. `Super + Alt + Space` prikaže vse aplikacije na eni mreži, tako kot Launchpad. Glejte [navigacija](04-navigation.md).

### Brez ikon na namizju, dok pa se prikaže samo, ko lebdite

Nobenih ikon za razporejanje po namizju in nobenega doka na delovnem prostoru s ploščicami — dok se prikaže samo na lebdečem delovnem prostoru (glejte [navigacija](04-navigation.md)). Aplikacije zaženete z bližnjico (`Super + Return` za terminal, `Super + Shift + Return` za brskalnik in `Super + K` za seznam vsega, kar je preslikano) ali iz menija. Edini stalni del uporabniškega vmesnika je [zgornja vrstica](05-the-top-bar.md), ki pokriva to, kar so prej za vas počeli menijska vrstica, sistemska vrstica in Notification Center — in skoraj vsak gradnik na njej nekaj naredi ob levem, desnem in srednjem kliku.

### Okna se postavijo sama

Največji miselni premik: oken ne vlečete naokoli in jih ne pripenjate na polovice zaslona. Odprete okno in zavzame cel zaslon. Odprete drugo in si ga razdelita. Nikoli ne lovite okna izpod drugega, ker se okna ne prekrivajo.

Ko res potrebujete lebdeče okno, `Super + T` aktivno okno preklopi iz ploščic (in nazaj). Ampak najprej dajte ploščicam pravo priložnost — so srce celotne stvari. [Navigacija](04-navigation.md) vas popelje skozi to.

Delovni prostori se bodo zdeli znani: so kot macOS Spaces ali navidezna namizja v Windows, le da jih boste dejansko uporabljali, ker `Super + 1/2/3/4` skoči naravnost na enega, `Super + Shift + 1/2/3/4` pa tja pošlje aktivno okno. Brez zakasnitve animacije, samo takojšnji skoki. To pomeni, da morda sploh ne boste potrebovali več monitorjev, če ste bili tega navajeni prej.

### Kopiranje in lepljenje preprosto delujeta

Na Macu ste imeli Cmd + C povsod. Na Windows ste imeli Ctrl + C povsod — razen v terminalu, kjer ubije vaš program. Omarchy vam da `Super + C`, `Super + X` in `Super + V`, in delujejo povsod, tudi v terminalu. Ni ločenega refleksa, ki bi se ga morali naučiti za lupino.

Uporabniki Windows: vaša zgodovina odložišča Win + V živi na `Super + Ctrl + V` in hrani slike ter besedilo. Glejte [poenoteno odložišče in zgodovina](08-unified-clipboard-history.md).

### Prevajalna tabela

| Po čem sežete | V Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / meni Start | `Super + Space` — meni Omarchy |
| AirDrop | LocalSend, prek `Super + Ctrl + S` — glejte [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` ali `Print Screen` — glejte [posnetki zaslona in snemanje](12-screenshots-recording.md) |
| Notification Center | Zgodovina obvestil na `Super + Shift + Alt + ,` |
| Time Machine (za sistem) | Samodejni [posnetki sistema](47-system-snapshots.md) ob vsaki posodobitvi |
| App Store / prenos namestitvenega programa | _Install_ v meniju ali `omarchy pkg add` — glejte [drugi paketi](29-other-packages.md) |
| Sistemske nastavitve / Nadzorna plošča | _Setup_ v meniju, ki ureja navadne konfiguracijske datoteke — glejte [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, na `Super + Shift + F` — glejte [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome na `Super + Shift + Return`; drugega izberite pod _Setup > Defaults > Browser_ — glejte [brskalniki](23-browsers.md) |
| Preview / Photos | Omaview za slike, video in glasbo, Document Viewer za PDF-je — glejte [GUIs](22-guis.md) |
| TextEdit / Beležnica | Plain, na `Super + Shift + N`; drugega izberite pod _Setup > Defaults > Editor_ |

### Nekatere stvari so res drugačne

Veliko nastavitev živi v besedilnih datotekah, ki jih urejate, ne v panelih, skozi katere klikate. To zveni primitivno, dokler ne spoznate, da to pomeni, da je vsako prilagoditev mogoče videti, kopirati na vaš naslednji računalnik in dati v nadzor različic. Meni _Setup_ vas spusti naravnost v pravo datoteko in znova zažene, kar je treba znova zagnati, ko končate.

Posodobitve pridejo prek enega ukaza — _Update > Omarchy_ — ki posodobi sam Omarchy in vsak paket v sistemu, pri čemer najprej naredi posnetek. Nobenih posodobljevalnikov za posamezne aplikacije, ki bi vas težili ob naključnih trenutkih. Glejte [posodobitve](30-updates.md).

Programska oprema prihaja iz upravitelja paketov, ne iz prenesenih namestitvenih programov.

In ko zaprete okno, se aplikacija dejansko zapre. Ni macOS limba, kjer program teče naprej brez oken. `Super + W` — ali `Super + Q`, če je to spomin prstov, s katerim ste prišli — pomeni konec.

### Na strojni opremi Mac

Omarchy dobro deluje na Intel Macih — glejte [podpora za Mac](44-mac-support.md). In tipkovnica je prijazna do vas: Omarchy ničesar ne preslika, Linux pa tipko Command obravnava kot Super, tako da je Super točno tam, kjer je bil vedno Cmd. Vaš palec premika ne bo opazil.

### Dajte mu dva tedna

Instinkti se prenesejo hitreje, kot bi si mislili. Enkrat preletite poglavje [bližnjice](07-hotkeys.md) in vedno, ko vam zmanjka spomina za vezavo, pritisnite `Super + K` — pokaže vam vse. To je edina bližnjica, ki si jo dejansko morate zapomniti.
