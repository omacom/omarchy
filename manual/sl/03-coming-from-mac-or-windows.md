# Prihajate z Maca ali Windowsov

Če ste leta preživeli na macOS ali Windowsih, vaši prsti vedo sto stvari, za katere so vaši možgani pozabili, da so se jih sploh kdaj naučili. To poglavje je prevodna plast: kam gredo ti nagoni v Omarchyju. Same funkcije so podrobno obravnavane drugje — to je samo zemljevid.

### Super je središče vsega

Ves mišični spomin, ki ste ga zgradili okoli Cmd ali tipke Windows, se prenese na eno tipko: Super. To je tipka Windows na tipkovnici za PC in je sidro za skoraj vsako bližnjico v Omarchyju.

Vaš refleks za Spotlight, Raycast ali meni Start postane `Super + Space`. To odpre meni Omarchy, ki zaganja aplikacije, spreminja nastavitve, namešča programsko opremo, zajema zaslon — praktično vse. Začnite tipkati za filtriranje. `Super + Alt + Space` prikaže vsako aplikacijo na eni mreži, tako kot Launchpad. Glejte [navigacija](04-navigation.md).

### Ni ikon na namizju, dock pa ostane umaknjen

Ni ikon, ki bi jih razporejali po namizju, dock pa se skrije, ko ima delovni prostor okno, dokler kazalca ne potisnete do njegovega roba zaslona, spodnjega, razen če ga premaknete (glejte [navigacija](04-navigation.md)). Aplikacije se zaganja z bližnjico (`Super + Return` za terminal, `Super + Shift + Return` za brskalnik in `Super + K` za seznam vsega, kar je preslikano) ali iz menija. Edini stalni del uporabniškega vmesnika je [zgornja vrstica](05-the-top-bar.md), ki pokriva to, kar so prej za vas počeli menijska vrstica, sistemska vrstica in Notification Center — in skoraj vsak gradnik na njej nekaj naredi ob levem, desnem in srednjem kliku.

### Okna se postavijo sama

Največji miselni premik: oken ne vlečete naokrog in jih ne pritrjujete na polovici zaslona. Odprete okno in zavzame celoten zaslon. Odprete še drugo in si ga razdelita. Nikoli ne lovite okna izpod drugega, ker se okna ne prekrivajo.

Kadar res potrebujete plavajoče okno, `Super + T` aktivno okno prestavi iz ploščične razporeditve (in nazaj). A najprej dajte ploščični razporeditvi pravo priložnost — je srce vsega skupaj. [Navigacija](04-navigation.md) vas vodi skozi to.

Delovni prostori se vam bodo zdeli domači: so kot Spaces v macOS ali navidezna namizja v Windowsih, le da jih boste zares uporabljali, ker `Super + 1/2/3/4` skoči naravnost na enega, `Super + Shift + 1/2/3/4` pa tja pošlje aktivno okno. Brez zakasnitve animacije, samo takojšnji skoki. To pomeni, da morda sploh ne boste potrebovali več monitorjev, če ste bili tega prej navajeni.

### Kopiranje in lepljenje preprosto delujeta

Na Macu ste povsod imeli Cmd + C. Na Windowsih ste povsod imeli Ctrl + C — razen v terminalu, kjer vam ubije program. Omarchy vam da `Super + C`, `Super + X` in `Super + V`, ki delujejo povsod, tudi v terminalu. Za lupino se ni treba učiti ločenega refleksa.

Uporabniki Windowsov: vaša zgodovina odložišča z Win + V živi na `Super + Ctrl + V` in poleg besedila hrani tudi slike. Glejte [poenoteno odložišče in zgodovina](08-unified-clipboard-history.md).

### Prevajalna tabela

| Posežete po | V Omarchyju |
| ------------- | ---------- |
| Spotlight / Raycast / meni Start | `Super + Space` — meni Omarchy |
| AirDrop | LocalSend, prek `Super + Ctrl + S` — glejte [grafični vmesniki](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` ali `Print Screen` — glejte [posnetki zaslona in snemanje](12-screenshots-recording.md) |
| Notification Center | Zgodovina obvestil na `Super + Shift + Alt + ,` |
| Time Machine (za sistem) | Samodejni [sistemski posnetki](47-system-snapshots.md) ob vsaki posodobitvi |
| App Store / prenos namestitvenega programa | _Install_ v meniju ali `omarchy pkg add` — glejte [drugi paketi](29-other-packages.md) |
| System Settings / Nadzorna plošča | _Setup_ v meniju, ki ureja navadne konfiguracijske datoteke — glejte [dotfiles](31-dotfiles.md) |
| Finder / Raziskovalec | Files, na `Super + Shift + F` — glejte [grafični vmesniki](22-guis.md) |
| Safari / Edge | Google Chrome na `Super + Shift + Return`; drugega izberite pod _Setup > Defaults > Browser_ — glejte [brskalniki](23-browsers.md) |
| Preview / Photos | Omaview za slike, video in glasbo, Document Viewer za PDF-je — glejte [grafični vmesniki](22-guis.md) |
| TextEdit / Beležnica | Plain, na `Super + Shift + N`; drugega izberite pod _Setup > Defaults > Editor_ |

### Nekatere stvari so res drugačne

Veliko nastavitev živi v besedilnih datotekah, ki jih urejate, ne v ploščah, po katerih klikate. To zveni primitivno, dokler ne ugotovite, da to pomeni, da je vsako prilagoditev mogoče videti, kopirati na vaš naslednji računalnik in dati pod nadzor različic. Meni _Setup_ vas spusti naravnost v pravo datoteko in ob koncu znova zažene vse, kar je treba znova zagnati.

Posodobitve pridejo z enim ukazom — _Update > Omarchy_ — ki posodobi sam Omarchy in vsak paket v sistemu, pri čemer najprej naredi posnetek. Brez posodobljevalnikov za posamezne aplikacije, ki bi vas nadlegovali ob naključnih trenutkih. Glejte [posodobitve](30-updates.md).

Programska oprema prihaja iz upravitelja paketov, ne iz prenesenih namestitvenih programov.

In ko zaprete okno, se aplikacija dejansko zapre. Ni onega vmesnega stanja iz macOS, kjer program še naprej teče brez oken. `Super + W` — ali `Super + Q`, če ste prišli s takšnim spominom v prstih — pomeni, da je ni več.

### Na strojni opremi Mac

Omarchy dobro teče na Macih z Intelom ter na Macih z M1, M2 in M3 z Omarchy for Apple Silicon. Glejte [podpora za Mac](44-mac-support.md). In tipkovnica je prijazna do vas: Omarchy ničesar ne preslika na novo, Linux pa tipko Command obravnava kot Super, tako da je Super točno tam, kjer je bil vedno Cmd. Vaš palec selitve sploh ne bo opazil.

### Dajte mu dva tedna

Nagoni se prenesejo hitreje, kot bi si mislili. Enkrat preletite poglavje [bližnjice](07-hotkeys.md) in kadar koli vam zmanjka spomina za vezavo, pritisnite `Super + K` — pokaže vam vse. To je edina bližnjica, ki si jo morate zares zapomniti.
