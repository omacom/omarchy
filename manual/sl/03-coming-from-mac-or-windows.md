# Prihajate z Maca ali Windowsov

Če ste leta preživeli na macOS-u ali Windowsih, vaši prsti poznajo sto stvari, za katere so vaši možgani pozabili, da so se jih sploh naučili. To poglavje je prevajalna plast: kam gredo ti nagoni v Omarchyju. Same funkcije so podrobneje obravnavane drugje — to je zgolj zemljevid.

### Super je središče vsega

Ves mišični spomin, ki ste ga zgradili okoli tipke Cmd ali tipke Windows, se prenese na eno tipko: Super. To je tipka Windows na tipkovnici za PC in sidro za skoraj vse bližnjice v Omarchyju.

Vaš refleks za Spotlight ali Raycast ali meni Start postane `Super + Space`. To odpre meni Omarchy, ki zažene aplikacije, spreminja nastavitve, namešča programsko opremo, zajema zaslon — pravzaprav vse. Začnite tipkati za filtriranje. `Super + Alt + Space` prikaže vse aplikacije na eni mreži, kot to počne Launchpad. Glejte [navigacija](04-navigation.md).

### Ni doka in ni ikon na namizju

Nič, kar bi kliknili za zagon stvari, nobenih ikon za urejanje na namizju. Aplikacije se zaženejo z bližnjico (`Super + Return` za terminal, `Super + Shift + Return` za brskalnik in `Super + K` za seznam vsega, kar je preslikano) ali iz menija. Edini stalni del vmesnika je [menijska vrstica](05-the-top-bar.md), ki pokriva tisto, kar so za vas prej počeli menijska vrstica, sistemski pladenj in Notification Center — in skoraj vsak gradnik na njej naredi nekaj ob levem, desnem in srednjem kliku.

### Okna se postavijo sama

Največji preskok v razmišljanju: oken ne vlečete naokoli in jih ne pripnete na polovice zaslona. Odprete okno in zasede celoten zaslon. Odprete drugo in si ga razdelita. Nikoli ne lovite okna izpod drugega, saj se okna ne prekrivajo.

Kadar res potrebujete lebdeče okno, `Super + T` aktivno okno preklopi iz ploščic (in nazaj). Ampak ploščicam najprej dajte pravo priložnost — to je srce vsega. [Navigacija](04-navigation.md) vas vodi skozenj.

Delovni prostori se bodo zdeli znani: so prostori v macOS-u ali navidezna namizja v Windowsih, le da jih boste dejansko uporabljali, saj `Super + 1/2/3/4` skoči naravnost na enega, `Super + Shift + 1/2/3/4` pa tja pošlje aktivno okno. Brez zakasnitve animacije, samo trenutni skoki. To pomeni, da morda sploh ne potrebujete več zaslonov, če ste bili tega vajeni prej.

### Kopiranje in lepljenje preprosto delujeta

Na Macu ste povsod imeli Cmd + C. Na Windowsih ste povsod imeli Ctrl + C — razen v terminalu, kjer ubije vaš program. Omarchy vam daje `Super + C`, `Super + X` in `Super + V` in delujejo povsod, tudi v terminalu. Za lupino se ni treba učiti ločenega refleksa.

Uporabniki Windowsov: vaša zgodovina odložišča Win + V živi na `Super + Ctrl + V` in poleg besedila hrani tudi slike. Glejte [poenoteno odložišče in zgodovina](08-unified-clipboard-history.md).

### Prevajalna tabela

| Sežete po | V Omarchyju |
| ------------- | ---------- |
| Spotlight / Raycast / meni Start | `Super + Space` — meni Omarchy |
| AirDrop | LocalSend prek `Super + Ctrl + S` — glejte [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — glejte [posnetki zaslona in snemanje](12-screenshots-recording.md) |
| Notification Center | Zgodovina obvestil na `Super + Shift + Alt + ,` |
| Time Machine (za sistem) | Samodejni [posnetki sistema](47-system-snapshots.md) ob vsaki posodobitvi |
| App Store / prenos namestitvenega programa | _Install_ v meniju ali `omarchy pkg add` — glejte [drugi paketi](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ v meniju, ki ureja navadne konfiguracijske datoteke — glejte [dotfiles](31-dotfiles.md) |

### Nekatere stvari so res drugačne

Veliko nastavitev živi v besedilnih datotekah, ki jih urejate, ne v ploščah, skozi katere klikate. To se sliši primitivno, dokler ne spoznate, da to pomeni, da je vsako prilagoditev mogoče videti, kopirati na vaš naslednji računalnik in dati pod nadzor različic. Meni _Setup_ vas spusti naravnost v pravo datoteko in znova zažene, kar je treba znova zagnati, ko končate.

Posodobitve prihajajo prek enega ukaza — _Update > Omarchy_ — ki posodobi sam Omarchy in vsak paket v sistemu ter najprej naredi posnetek. Nobenih posodabljalnikov posameznih aplikacij, ki bi vas naključno nadlegovali. Glejte [posodobitve](30-updates.md).

Programska oprema prihaja iz upravljalnika paketov, ne iz prenesenih namestitvenih programov.

In ko zaprete okno, aplikacija dejansko preneha delovati. Ni macOS-ovega limba, kjer program še naprej teče brez oken. `Super + W` — ali `Super + Q`, če je to prstni spomin, s katerim ste prišli — pomeni, da je ni več.

### Na strojni opremi Mac

Omarchy dobro teče na Macih z Intelom — glejte [podpora za Mac](44-mac-support.md). Tipkovnica pa je prijazna do vas: Omarchy ničesar ne preslika, Linux tipko Command obravnava kot Super, zato Super sedi natanko tam, kjer je bil vedno Cmd. Vaš palec selitve sploh ne bo opazil.

### Dajte si dva tedna

Nagoni se prenesejo hitreje, kot bi si mislili. Enkrat preletite poglavje o [bližnjicah](07-hotkeys.md), in kadar pozabite vezavo, pritisnite `Super + K` — pokaže vam vse. To je edina bližnjica, ki si jo res morate zapomniti.
