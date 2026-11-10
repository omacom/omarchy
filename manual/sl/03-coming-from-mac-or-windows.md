# Prihajate z Maca ali Windowsa

Če ste leta preživeli na macOS ali Windowsu, vaši prsti vedo sto stvari, za katere so vaši možgani pozabili, da so se jih sploh kdaj naučili. To poglavje je prevajalska plast: kam gredo ti instinkti v Omarchy. Same funkcije so podrobno obravnavane drugje — to je le zemljevid.

### Super je središče vsega

Ves mišični spomin, ki ste ga zgradili okoli Cmd ali tipke Windows, se prenese na eno tipko: Super. To je tipka Windows na tipkovnici PC in je sidro za skoraj vsako bližnjico v Omarchy.

Vaš refleks za Spotlight ali Raycast ali meni Start postane `Super + Space`. To odpre meni Omarchy, ki zažene aplikacije, spremeni nastavitve, namesti programsko opremo, zajame zaslon — skoraj vse. Začnite tipkati za filtriranje. `Super + Alt + Space` prikaže vse aplikacije na eni mreži, tako kot Launchpad. Glejte [navigacija](04-navigation.md).

### Ni doka in ni ikon na namizju

Ni ničesar, kar bi kliknili za zagon stvari, nobenih ikon za razporejanje po namizju. Aplikacije se zaženejo z bližnjico (`Super + Return` za terminal, `Super + Shift + Return` za brskalnik in `Super + K` za seznam vsega, kar je preslikano) ali iz menija. Edini stalni del uporabniškega vmesnika je [zgornja vrstica](05-the-top-bar.md), ki pokriva to, kar so prej za vas počeli menijska vrstica, sistemska vrstica in Notification Center — in skoraj vsak gradnik na njej naredi nekaj ob levem, desnem in srednjem kliku.

### Okna se postavijo sama

Največja sprememba miselnosti: oken ne vlečete naokoli in jih ne pripenjate na polovice zaslona. Odprete okno in zavzame cel zaslon. Odprete drugo in si zaslon razdelita. Nikoli ne brskate za oknom pod drugim, ker se okna ne prekrivajo.

Kadar res potrebujete plavajoče okno, `Super + T` aktivno okno preklopi iz razporeditve v ploščice (in nazaj). Ampak najprej dajte razporeditvi v ploščice pravo priložnost — to je srce vsega. [Navigacija](04-navigation.md) vas vodi skozi to.

Delovni prostori se bodo zdeli znani: so kot Spaces v macOS ali navidezna namizja v Windowsu, le da jih boste dejansko uporabljali, ker `Super + 1/2/3/4` skoči naravnost na enega, `Super + Shift + 1/2/3/4` pa tja pošlje aktivno okno. Brez zakasnitve animacije, le takojšnji skoki. To pomeni, da morda sploh ne potrebujete več monitorjev, če ste bili tega vajeni prej.

### Kopiranje in lepljenje preprosto delujeta

Na Macu ste imeli povsod Cmd + C. Na Windowsu ste imeli povsod Ctrl + C — razen v terminalu, kjer ubije vaš program. Omarchy vam da `Super + C`, `Super + X` in `Super + V` in delujejo povsod, vključno s terminalom. Za lupino se ni treba učiti ločenega refleksa.

Uporabniki Windowsa: vaša zgodovina odložišča z Win + V živi na `Super + Ctrl + V` in poleg besedila hrani tudi slike. Glejte [poenoteno odložišče in zgodovina](08-unified-clipboard-history.md).

### Prevajalska tabela

| Dosežete po | V Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / meni Start | `Super + Space` — meni Omarchy |
| AirDrop | LocalSend, prek `Super + Ctrl + S` — glejte [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` ali `Print Screen` — glejte [posnetki zaslona in snemanje](12-screenshots-recording.md) |
| Notification Center | Zgodovina obvestil na `Super + Shift + Alt + ,` |
| Time Machine (za sistem) | Samodejni [posnetki sistema](47-system-snapshots.md) ob vsaki posodobitvi |
| App Store / prenos namestitvenega programa | _Namesti_ v meniju ali `omarchy pkg add` — glejte [drugi paketi](29-other-packages.md) |
| Sistemske nastavitve / Nadzorna plošča | _Nastavitev_ v meniju, ki ureja preproste konfiguracijske datoteke — glejte [dotfiles](31-dotfiles.md) |

### Nekatere stvari so res drugačne

Veliko nastavitev živi v besedilnih datotekah, ki jih urejate, ne v ploščah, skozi katere klikate. To se sliši primitivno, dokler ne ugotovite, da pomeni, da je vsako prilagoditev mogoče videti, kopirati na vaš naslednji računalnik in dati pod nadzor različic. Meni _Nastavitev_ vas spusti naravnost v pravo datoteko in znova zažene vse, kar je treba znova zagnati, ko končate.

Posodobitve pridejo prek enega ukaza — _Posodobi > Omarchy_ — ki posodobi sam Omarchy in vsak paket v sistemu, prej pa naredi posnetek. Brez posodabljalnikov posameznih aplikacij, ki bi vas nadlegovali ob naključnih trenutkih. Glejte [posodobitve](30-updates.md).

Programska oprema pride iz upravitelja paketov, ne iz prenesenih namestitvenih programov.

In ko zaprete okno, se aplikacija dejansko zapre. Ni macOS limba, kjer program teče naprej brez oken. `Super + W` — ali `Super + Q`, če je to spomin prstov, s katerim ste prišli — pomeni, da je ni več.

### Na strojni opremi Mac

Omarchy dobro teče na Macih z Intelom — glejte [podpora za Mac](44-mac-support.md). In tipkovnica je prijazna do vas: Omarchy ničesar ne preslika na novo, Linux pa tipko Command obravnava kot Super, zato Super sedi točno tam, kjer je bil vedno Cmd. Vaš palec premika ne bo opazil.

### Dajte mu dva tedna

Instinkti se prenesejo hitreje, kot mislite. Enkrat preletite poglavje [bližnjice](07-hotkeys.md) in kadar koli vam zmanjka vezave, pritisnite `Super + K` — pokaže vam vse. To je edina bližnjica, ki si jo dejansko morate zapomniti.
