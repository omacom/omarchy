# Prelazak s Maca ili Windowsa

Ako ste godinama proveli na macOS-u ili Windowsima, vaši prsti znaju stotinu stvari za koje je vaš mozak zaboravio da ih je ikada naučio. Ovo poglavlje je sloj za prevođenje: kamo ti instinkti odlaze u Omarchyju. Same značajke detaljno su obrađene drugdje — ovo je samo karta.

### Super je središte svega

Sva mišićna memorija koju ste izgradili oko Cmd-a ili Windows tipke prenosi se na jednu tipku: Super. To je Windows tipka na PC tipkovnici i sidro je za gotovo svaki prečac u Omarchyju.

Vaš refleks za Spotlight ili Raycast ili izbornik Start postaje `Super + Space`. To otvara izbornik Omarchy, koji pokreće aplikacije, mijenja postavke, instalira softver, snima zaslon — gotovo sve. Počnite tipkati za filtriranje. `Super + Alt + Space` prikazuje svaku aplikaciju na jednoj mreži, kao što to radi Launchpad. Pogledajte [navigaciju](04-navigation.md).

### Nema ikona na radnoj površini, a dock se pojavljuje samo na plutajućem radnom prostoru

Nema ikona za raspoređivanje po radnoj površini i nema docka na radnom prostoru s popločavanjem — dock se pojavljuje samo na plutajućem radnom prostoru (pogledajte [navigaciju](04-navigation.md)). Aplikacije se pokreću prečacem (`Super + Return` za terminal, `Super + Shift + Return` za preglednik i `Super + K` za popis svega što je mapirano) ili iz izbornika. Jedini stalni dio sučelja je [gornja traka](05-the-top-bar.md), koja pokriva ono što su za vas prije radili traka izbornika, područje obavijesti sustava i Notification Center — i gotovo svaki widget na njoj radi nešto na lijevi, desni i srednji klik.

### Prozori se sami smještaju

Najveća promjena načina razmišljanja: ne povlačite prozore okolo niti ih pričvršćujete za polovice zaslona. Otvorite prozor i on zauzme cijeli zaslon. Otvorite drugi i oni ga podijele. Nikada ne vadite prozor ispod drugoga, jer se prozori ne preklapaju.

Kada vam zaista treba plutajući prozor, `Super + T` prebacuje aktivni iz popločavanja (i natrag). Ali prvo dajte popločavanju pravu priliku — to je srce cijele stvari. [Navigacija](04-navigation.md) provest će vas kroz to.

Radni prostori djelovat će poznato: to su macOS Spaces ili virtualne radne površine u Windowsima, samo što ćete ih zapravo koristiti, jer `Super + 1/2/3/4` skače ravno na jedan, a `Super + Shift + 1/2/3/4` tamo šalje aktivni prozor. Bez odgode animacije, samo trenutni skokovi. To znači da vam možda neće trebati ni više monitora, ako ste na to bili navikli prije.

### Kopiranje i lijepljenje jednostavno rade

Na Macu ste svugdje imali Cmd + C. Na Windowsima ste svugdje imali Ctrl + C — osim u terminalu, gdje vam ubija program. Omarchy vam daje `Super + C`, `Super + X` i `Super + V` i oni rade svugdje, uključujući terminal. Nema zasebnog refleksa koji treba naučiti za ljusku.

Ljudi s Windowsa: vaša povijest međuspremnika na Win + V živi na `Super + Ctrl + V` i drži slike kao i tekst. Pogledajte [objedinjeni međuspremnik i povijest](08-unified-clipboard-history.md).

### Tablica za prevođenje

| Posežete za | U Omarchyju |
| ------------- | ---------- |
| Spotlight / Raycast / izbornik Start | `Super + Space` — izbornik Omarchy |
| AirDrop | LocalSend, putem `Super + Ctrl + S` — pogledajte [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` ili `Print Screen` — pogledajte [snimke zaslona i snimanje](12-screenshots-recording.md) |
| Notification Center | Povijest obavijesti na `Super + Shift + Alt + ,` |
| Time Machine (za sustav) | Automatske [snimke sustava](47-system-snapshots.md) pri svakom ažuriranju |
| App Store / preuzimanje instalacijskog programa | _Instaliraj_ u izborniku ili `omarchy pkg add` — pogledajte [ostale pakete](29-other-packages.md) |
| System Settings / Control Panel | _Postavke_ u izborniku, koje uređuju obične konfiguracijske datoteke — pogledajte [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, na `Super + Shift + F` — pogledajte [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome na `Super + Shift + Return`; odaberite drugi pod _Postavke > Zadane postavke > Preglednik_ — pogledajte [preglednike](23-browsers.md) |
| Preview / Photos | Omaview za slike, video i glazbu, Document Viewer za PDF-ove — pogledajte [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, na `Super + Shift + N`; odaberite drugi pod _Postavke > Zadane postavke > Uređivač_ |

### Neke su stvari zaista drugačije

Puno postavki živi u tekstualnim datotekama koje uređujete, a ne u panelima kroz koje klikate. To zvuči primitivno dok ne shvatite da to znači da se svaka prilagodba može vidjeti, kopirati na vaše sljedeće računalo i staviti pod kontrolu verzija. Izbornik _Postavke_ baca vas ravno u pravu datoteku i ponovno pokreće sve što treba ponovno pokrenuti kada završite.

Ažuriranja dolaze kroz jednu naredbu — _Ažuriranje > Omarchy_ — koja ažurira sam Omarchy i svaki paket na sustavu, a prvo napravi snimku. Nema zasebnih programa za ažuriranje koji vas gnjave u nasumičnim trenucima. Pogledajte [ažuriranja](30-updates.md).

Softver dolazi iz upravitelja paketa, a ne iz preuzetih instalacijskih programa.

A kada zatvorite prozor, aplikacija se zaista zatvori. Nema macOS limba u kojem program nastavlja raditi bez prozora. `Super + W` — ili `Super + Q`, ako ste s tom mišićnom memorijom došli — znači nestalo.

### Na Mac hardveru

Omarchy dobro radi na Intel Macovima — pogledajte [podršku za Mac](44-mac-support.md). A tipkovnica je prema vama blaga: Omarchy ništa ne preslikava, a Linux tipku Command tretira kao Super, pa Super stoji točno ondje gdje je Cmd uvijek bio. Vaš palac neće primijetiti preseljenje.

### Dajte mu dva tjedna

Instinkti se prenose brže nego što biste mislili. Jednom preletite poglavlje o [prečacima](07-hotkeys.md), a kad god vam mozak zablokira na nekom prečacu, pritisnite `Super + K` — pokazat će vam ih sve. To je jedini prečac koji zapravo morate zapamtiti.
