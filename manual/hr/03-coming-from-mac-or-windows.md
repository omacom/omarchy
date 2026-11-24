# Prelazak s Maca ili Windowsa

Ako ste godinama proveli na macOS-u ili Windowsima, vaši prsti znaju stotinu stvari za koje je vaš mozak zaboravio da ih je ikada naučio. Ovo poglavlje je sloj za prevođenje: kamo ti instinkti idu u Omarchyju. Same značajke detaljno su obrađene drugdje — ovo je samo karta.

### Super je središte svega

Sva mišićna memorija koju ste izgradili oko Cmd-a ili tipke Windows prelazi na jednu tipku: Super. To je tipka Windows na PC tipkovnici i sidro je za gotovo svaki tipkovnički prečac u Omarchyju.

Vaš refleks za Spotlight, Raycast ili izbornik Start postaje `Super + Space`. Time se otvara izbornik Omarchyja, koji pokreće aplikacije, mijenja postavke, instalira softver, snima zaslon — gotovo sve. Počnite tipkati za filtriranje. `Super + Alt + Space` prikazuje sve aplikacije na jednoj mreži, onako kako to radi Launchpad. Pogledajte [navigaciju](04-navigation.md).

### Nema ikona na radnoj površini, a dock se pojavljuje samo kad plutate

Nema ikona za raspoređivanje na radnoj površini i nema docka na radnom prostoru s popločavanjem — dock se pojavljuje samo na plutajućem radnom prostoru (pogledajte [navigaciju](04-navigation.md)). Aplikacije se pokreću tipkovničkim prečacem (`Super + Return` za terminal, `Super + Shift + Return` za preglednik i `Super + K` za popis svega što je mapirano) ili iz izbornika. Jedini stalni dio sučelja je [gornja traka](05-the-top-bar.md), koja pokriva ono što su za vas prije radili traka izbornika, sistemska ladica i Notification Center — a gotovo svaki widget na njoj nešto radi na lijevi, desni i srednji klik.

### Prozori se sami smještaju

Najveća promjena u načinu razmišljanja: ne povlačite prozore uokolo niti ih pričvršćujete na polovice zaslona. Otvorite prozor i on zauzme cijeli zaslon. Otvorite drugi i oni ga podijele. Nikada ne lovite prozor ispod drugoga, jer se prozori ne preklapaju.

Kad vam zaista treba plutajući prozor, `Super + T` aktivni prozor izbacuje iz popločavanja (i vraća ga natrag). Ali prvo dajte popločavanju pravu priliku — to je srce cijele stvari. [Navigacija](04-navigation.md) vodi vas kroz to.

Radni prostori djelovat će poznato: to su macOS Spaces ili virtualne radne površine u Windowsima, samo što ćete ih zapravo koristiti, jer `Super + 1/2/3/4` skače ravno na jedan, a `Super + Shift + 1/2/3/4` onamo šalje aktivni prozor. Bez kašnjenja animacije, samo trenutni skokovi. To znači da vam možda neće trebati ni više monitora, ako ste na to bili navikli.

### Kopiranje i lijepljenje jednostavno rade

Na Macu ste svugdje imali Cmd + C. Na Windowsima ste svugdje imali Ctrl + C — osim u terminalu, gdje ubija vaš program. Omarchy vam daje `Super + C`, `Super + X` i `Super + V`, i oni rade svugdje, uključujući terminal. Nema zasebnog refleksa koji morate naučiti za ljusku.

Ljudi s Windowsa: vaša povijest međuspremnika za Win + V živi na `Super + Ctrl + V` i sadrži slike kao i tekst. Pogledajte [ujedinjeni međuspremnik i povijest](08-unified-clipboard-history.md).

### Tablica prijevoda

| Posežete za | U Omarchyju |
| ------------- | ---------- |
| Spotlight / Raycast / izbornik Start | `Super + Space` — izbornik Omarchyja |
| AirDrop | LocalSend, putem `Super + Ctrl + S` — pogledajte [GUI-je](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` ili `Print Screen` — pogledajte [snimke zaslona i snimanje](12-screenshots-recording.md) |
| Notification Center | Povijest obavijesti na `Super + Shift + Alt + ,` |
| Time Machine (za sustav) | Automatske [snimke sustava](47-system-snapshots.md) pri svakom ažuriranju |
| App Store / preuzimanje instalacijskog programa | _Instaliraj_ u izborniku ili `omarchy pkg add` — pogledajte [ostale pakete](29-other-packages.md) |
| System Settings / Control Panel | _Postavke_ u izborniku, koje uređuju obične konfiguracijske datoteke — pogledajte [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, na `Super + Shift + F` — pogledajte [GUI-je](22-guis.md) |
| Safari / Edge | Google Chrome na `Super + Shift + Return`; odaberite drugi pod _Postavke > Zadano > Preglednik_ — pogledajte [preglednike](23-browsers.md) |
| Preview / Photos | Omaview za slike, video i glazbu, Document Viewer za PDF-ove — pogledajte [GUI-je](22-guis.md) |
| TextEdit / Notepad | Plain, na `Super + Shift + N`; odaberite drugi pod _Postavke > Zadano > Uređivač_ |

### Neke stvari zaista jesu drukčije

Mnogo postavki živi u tekstnim datotekama koje uređujete, a ne u panelima kroz koje klikate. To zvuči primitivno dok ne shvatite da to znači da se svaka prilagodba može vidjeti, kopirati na vaše sljedeće računalo i staviti pod kontrolu verzija. Izbornik _Postavke_ baca vas ravno u pravu datoteku i ponovno pokreće sve što treba ponovno pokrenuti kad završite.

Ažuriranja dolaze kroz jednu naredbu — _Ažuriraj > Omarchy_ — koja ažurira sam Omarchy i svaki paket na sustavu, a prije toga napravi snimku. Nema zasebnih programa za ažuriranje koji vas gnjave nasumce. Pogledajte [ažuriranja](30-updates.md).

Softver dolazi iz upravitelja paketa, a ne iz preuzetih instalacijskih programa.

A kad zatvorite prozor, aplikacija se zaista zatvara. Nema macOS limba u kojem program nastavlja raditi bez ikakvih prozora. `Super + W` — ili `Super + Q`, ako ste došli s tom memorijom prstiju — znači nestalo.

### Na Mac hardveru

Omarchy dobro radi na Intel Macovima te na M1, M2 i M3 Macovima s Omarchyjem za Apple Silicon. Pogledajte [podršku za Mac](44-mac-support.md). A tipkovnica je ljubazna prema vama: Omarchy ništa ne preslikava, a Linux tipku Command tretira kao Super, pa Super sjedi točno ondje gdje je Cmd oduvijek bio. Vaš palac neće primijetiti selidbu.

### Dajte mu dva tjedna

Instinkti se prenose brže nego što biste mislili. Jednom letimično prođite poglavlje [tipkovnički prečaci](07-hotkeys.md), a kad god vam izmakne neka kombinacija, pritisnite `Super + K` — pokazuje vam sve. To je jedini tipkovnički prečac koji zapravo morate zapamtiti.
