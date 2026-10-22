# Dolazak s Maca ili Windowsa

Ako ste godinama bili na macOS-u ili Windowsu, vaši prsti znaju stotinu stvari koje je vaš mozak zaboravio da ih je ikada naučio. Ovo poglavlje je prevoditeljski sloj: kuda ti nagoni vode u Omarchyju. Same značajke detaljno su obrađene drugdje — ovo je samo karta.

### Super je središte svega

Sva mišićna memorija koju ste izgradili oko tipke Cmd ili tipke Windows prenosi se na jednu tipku: Super. To je tipka Windows na PC tipkovnici i sidro je za gotovo svaki prečac u Omarchyju.

Vaš refleks za Spotlight, Raycast ili izbornik Start postaje `Super + Space`. To otvara Omarchy izbornik, koji pokreće aplikacije, mijenja postavke, instalira softver, snima zaslon — gotovo sve. Počnite tipkati za filtriranje. `Super + Alt + Space` prikazuje svaku aplikaciju na jednoj mreži, onako kako to radi Launchpad. Pogledajte [navigaciju](04-navigation.md).

### Nema docka ni ikona na radnoj površini

Nema ničega što biste kliknuli za pokretanje stvari, nema ikona za raspoređivanje po radnoj površini. Aplikacije se pokreću prečacom (`Super + Return` za terminal, `Super + Shift + Return` za preglednik i `Super + K` za popis svega što je mapirano) ili iz izbornika. Jedini stalni dio korisničkoga sučelja je [gornja traka](05-the-top-bar.md), koja pokriva ono što su za vas prije radile traka izbornika, paleta sustava i Centar za obavijesti — a gotovo svaki widget na njoj radi nešto na lijevi, desni i srednji klik.

### Prozori se sami smještaju

Najveća promjena načina razmišljanja: ne povlačite prozore okolo niti ih pristajete na polovice zaslona. Otvorite prozor i on zauzme cijeli zaslon. Otvorite drugi i oni ga podijele. Nikada ne izvlačite prozor ispod drugoga, jer se prozori ne preklapaju.

Kada vam doista treba plutajući prozor, `Super + T` prebacuje aktivni iz popločavanja (i natrag). Ali prvo dajte popločavanju pravu priliku — to je srce cijele stvari. [Navigacija](04-navigation.md) vodi vas kroz to.

Radni prostori djelovat će vam poznato: oni su macOS Spaces ili virtualne radne površine u Windowsu, samo što ćete ih ovdje doista koristiti, jer `Super + 1/2/3/4` skače ravno na jedan, a `Super + Shift + 1/2/3/4` tamo šalje aktivni prozor. Nema odgode animacije, samo trenutačni skokovi. To znači da vam možda neće ni trebati više monitora, ako ste na to prije bili navikli.

### Kopiranje i lijepljenje jednostavno rade

Na Macu ste posvuda imali Cmd + C. Na Windowsu ste posvuda imali Ctrl + C — osim u terminalu, gdje to ubija vaš program. Omarchy vam daje `Super + C`, `Super + X` i `Super + V`, i oni rade posvuda, uključujući terminal. Nema zasebnoga refleksa koji treba naučiti za ljusku.

Ljudi s Windowsa: vaša povijest međuspremnika s Win + V živi na `Super + Ctrl + V` i drži slike jednako kao i tekst. Pogledajte [jedinstveni međuspremnik i povijest](08-unified-clipboard-history.md).

### Prevoditeljska tablica

| Posežete za | U Omarchyju |
| ------------- | ---------- |
| Spotlight / Raycast / izbornik Start | `Super + Space` — Omarchy izbornik |
| AirDrop | LocalSend, putem `Super + Ctrl + S` — pogledajte [GUI-je](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — pogledajte [snimke zaslona i snimanje](12-screenshots-recording.md) |
| Centar za obavijesti | Povijest obavijesti na `Super + Shift + Alt + ,` |
| Time Machine (za sustav) | Automatski [sistemski snimci](47-system-snapshots.md) pri svakom ažuriranju |
| App Store / preuzimanje instalacijskoga programa | _Instaliraj_ u izborniku ili `omarchy pkg add` — pogledajte [ostale pakete](29-other-packages.md) |
| Postavke sustava / Upravljačka ploča | _Postavke_ u izborniku, koje uređuju obične konfiguracijske datoteke — pogledajte [dotfiles](31-dotfiles.md) |

### Neke su stvari doista drukčije

Mnoge postavke žive u tekstualnim datotekama koje uređujete, a ne u pločama kroz koje klikate. To zvuči primitivno dok ne shvatite da to znači da se svaka prilagodba može vidjeti, kopirati na vaš sljedeći stroj i staviti u kontrolu verzija. Izbornik _Postavke_ spušta vas ravno u pravu datoteku i ponovno pokreće što god treba ponovno pokrenuti kada završite.

Ažuriranja dolaze kroz jednu naredbu — _Ažuriraj > Omarchy_ — koja ažurira sam Omarchy i svaki paket u sustavu, prethodno napravivši snimak. Nema pojedinačnih ažuriratelja aplikacija koji bi vas gnjavili nasumično. Pogledajte [ažuriranja](30-updates.md).

Softver dolazi od upravitelja paketa, a ne od preuzetih instalacijskih programa.

A kada zatvorite prozor, aplikacija doista prestaje s radom. Nema macOS limbe u kojoj program nastavlja raditi bez prozora. `Super + W` — ili `Super + Q`, ako ste s tom memorijom prstiju stigli — znači nestalo.

### Na Mac hardveru

Omarchy dobro radi na Intel Macovima — pogledajte [podršku za Mac](44-mac-support.md). A tipkovnica je ljubazna prema vama: Omarchy ništa ne premješta, a Linux tipku Command tretira kao Super, pa Super sjedi točno ondje gdje je Cmd oduvijek bio. Vaš palac neće primijetiti selidbu.

### Dajte tome dva tjedna

Nagoni se prenose brže nego što mislite. Jednom prolistajte poglavlje o [prečacima](07-hotkeys.md), a kad god vam ne pada na pamet neka poveznica, pritisnite `Super + K` — prikazuje vam sve. To je jedini prečac koji doista morate zapamtiti.
