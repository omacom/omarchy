# Prehod z Maca ali Windows

Če si leta preživel na macOS ali Windows, tvoji prsti poznajo sto stvari, za katere so tvoji možgani pozabili, da so se jih sploh kdaj naučili. To poglavje je prevajalska plast: kam gredo ti nagoni v Omarchyju. Same funkcije so podrobno obravnavane drugje — to je samo zemljevid.

### Super je središče vsega

Ves mišični spomin, ki si ga zgradil okoli tipke Cmd ali tipke Windows, se prenese na eno tipko: Super. To je tipka Windows na tipkovnici za PC in je sidro za skoraj vsako bližnjico v Omarchyju.

Tvoj refleks za Spotlight, Raycast ali meni Start postane `Super + Space`. S tem se odpre meni Omarchy, ki zaganja aplikacije, spreminja nastavitve, namešča programsko opremo, zajema zaslon — skoraj vse. Začni tipkati, da filtriraš. `Super + Alt + Space` prikaže vse aplikacije na eni mreži, tako kot Launchpad. Glej [navigacija](04-navigation.md).

### Brez ikon na namizju, dok pa se pokaže le, ko lebdiš

Na namizju ni ikon za urejanje in na delovnem prostoru s ploščičnim razporejanjem ni doka — dok se pojavi samo na lebdečem delovnem prostoru (glej [navigacija](04-navigation.md)). Aplikacije zaženeš z bližnjico (`Super + Return` za terminal, `Super + Shift + Return` za brskalnik in `Super + K` za seznam vsega, kar je preslikano) ali iz menija. Edini stalni del uporabniškega vmesnika je [zgornja vrstica](05-the-top-bar.md), ki pokriva to, kar sta zate prej počeli menijska vrstica, sistemska vrstica in Notification Center — in skoraj vsak gradnik na njej nekaj naredi ob levem, desnem in srednjem kliku.

### Okna se postavijo sama

Največji miselni premik: oken ne vlečeš naokrog in jih ne pripenjaš na polovice zaslona. Odpri okno in zavzame cel zaslon. Odpri drugo in si ga razdelita. Nikoli ne loviš okna izpod drugega, ker se okna ne prekrivajo.

Ko res potrebuješ lebdeče okno, `Super + T` aktivno okno prestavi iz ploščičnega razporejanja (in nazaj). Ampak najprej daj ploščičnemu razporejanju pravo priložnost — to je srce vsega. [Navigacija](04-navigation.md) te popelje skozenj.

Delovni prostori se bodo zdeli znani: so kot macOS Spaces ali navidezna namizja v Windows, le da jih boš dejansko uporabljal, ker `Super + 1/2/3/4` skoči naravnost na enega, `Super + Shift + 1/2/3/4` pa tja pošlje aktivno okno. Brez zakasnitve animacije, samo takojšnji skoki. To pomeni, da morda sploh ne potrebuješ več monitorjev, če si bil tega vajen prej.

### Kopiranje in lepljenje preprosto delujeta

Na Macu si imel Cmd + C povsod. V Windows si imel Ctrl + C povsod — razen v terminalu, kjer ubije tvoj program. Omarchy ti da `Super + C`, `Super + X` in `Super + V` in delujejo povsod, tudi v terminalu. Za lupino se ni treba učiti ločenega refleksa.

Ljubitelji Windows: tvoja zgodovina odložišča z Win + V živi na `Super + Ctrl + V` in hrani tako slike kot besedilo. Glej [poenoteno odložišče in zgodovina](08-unified-clipboard-history.md).

### Prevajalska tabela

| Posežeš po | V Omarchyju |
| ------------- | ---------- |
| Spotlight / Raycast / meni Start | `Super + Space` — meni Omarchy |
| AirDrop | LocalSend, prek `Super + Ctrl + S` — glej [grafični vmesniki](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` ali `Print Screen` — glej [posnetki zaslona in snemanje](12-screenshots-recording.md) |
| Notification Center | Zgodovina obvestil na `Super + Shift + Alt + ,` |
| Time Machine (za sistem) | Samodejni [sistemski posnetki](47-system-snapshots.md) ob vsaki posodobitvi |
| App Store / prenos namestitvenega programa | _Namesti_ v meniju ali `omarchy pkg add` — glej [drugi paketi](29-other-packages.md) |
| System Settings / Control Panel | _Nastavitve_ v meniju, ki ureja preproste konfiguracijske datoteke — glej [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, na `Super + Shift + F` — glej [grafični vmesniki](22-guis.md) |
| Safari / Edge | Google Chrome na `Super + Shift + Return`; drugega izberi pod _Nastavitve > Privzete nastavitve > Brskalnik_ — glej [brskalniki](23-browsers.md) |
| Preview / Photos | Omaview za slike, videoposnetke in glasbo, Document Viewer za PDF-je — glej [grafični vmesniki](22-guis.md) |
| TextEdit / Notepad | Plain, na `Super + Shift + N`; drugega izberi pod _Nastavitve > Privzete nastavitve > Urejevalnik_ |

### Nekatere stvari so res drugačne

Veliko nastavitev živi v besedilnih datotekah, ki jih urejaš, ne v ploščah, po katerih klikaš. To se sliši primitivno, dokler ne ugotoviš, da to pomeni, da je vsako prilagoditev mogoče videti, kopirati na naslednji računalnik in dati pod nadzor različic. Meni _Nastavitve_ te odloži naravnost v pravo datoteko in znova zažene vse, kar je treba znova zagnati, ko končaš.

Posodobitve pridejo prek enega ukaza — _Posodobi > Omarchy_ — ki posodobi sam Omarchy in vsak paket v sistemu, pri čemer najprej naredi posnetek. Brez posodobljevalnikov posameznih aplikacij, ki te nadlegujejo ob naključnih trenutkih. Glej [posodobitve](30-updates.md).

Programska oprema prihaja iz upravljalnika paketov, ne iz prenesenih namestitvenih programov.

In ko zapreš okno, se aplikacija dejansko konča. Ni macOS limba, v katerem program še naprej teče brez oken. `Super + W` — ali `Super + Q`, če si prišel s tem prstnim spominom — pomeni, da je ni več.

### Na strojni opremi Mac

Omarchy dobro teče na Intel Macih ter na Macih z M1, M2 in M3 z Omarchy for Apple Silicon. Glej [podpora za Mac](44-mac-support.md). In tipkovnica je prijazna do tebe: Omarchy ničesar ne preslika na novo, Linux pa tipko Command obravnava kot Super, zato Super sedi natanko tam, kjer je bil vedno Cmd. Tvoj palec selitve ne bo opazil.

### Daj temu dva tedna

Nagoni se prenesejo hitreje, kot bi si mislil. Enkrat preleti poglavje [bližnjice](07-hotkeys.md) in kadarkoli ti zmanjka vezave, pritisni `Super + K` — pokaže ti jih vse. To je edina bližnjica, ki si jo dejansko moraš zapomniti.
