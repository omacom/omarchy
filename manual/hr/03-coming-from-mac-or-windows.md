# Dolazak s Maca ili Windowsa

Ako ste godinama na macOS-u ili Windowsima, vaši prsti znaju stotinu stvari za koje je vaš mozak zaboravio da ih je ikada naučio. Ovo poglavlje je sloj za prevođenje: kamo ti instinkti odlaze u Omarchyju. Same značajke detaljno su obrađene drugdje — ovo je samo karta.

### Super je središte svega

Sva mišićna memorija koju ste izgradili oko Cmd ili tipke Windows prenosi se na jednu tipku: Super. To je tipka Windows na PC tipkovnici i sidro je za gotovo svaki prečac u Omarchyju.

Vaš refleks za Spotlight ili Raycast ili izbornik Start postaje `Super + Space`. Time se otvara izbornik Omarchy, koji pokreće aplikacije, mijenja postavke, instalira softver, snima zaslon — gotovo sve. Počnite tipkati za filtriranje. `Super + Alt + Space` prikazuje svaku aplikaciju na jednoj mreži, onako kako to radi Launchpad. Pogledajte [navigaciju](04-navigation.md).

### Nema docka ni ikona na radnoj površini

Nema ničega na što biste kliknuli za pokretanje stvari, nema ikona za raspoređivanje po radnoj površini. Aplikacije se pokreću prečacem (`Super + Return` za terminal, `Super + Shift + Return` za preglednik i `Super + K` za popis svega što je mapirano) ili iz izbornika. Jedini stalni dio korisničkog sučelja je [gornja traka](05-the-top-bar.md), koja pokriva ono što su za vas prije radili traka izbornika, sistemska ladica i Notification Center — i gotovo svaki widget na njoj nešto radi na lijevi, desni i srednji klik.

### Prozori se sami smještaju

Najveća promjena u načinu razmišljanja: ne povlačite prozore okolo niti ih pričvršćujete na polovice zaslona. Otvorite prozor i on zauzme cijeli zaslon. Otvorite drugi i oni ga podijele. Nikada ne izvlačite prozor ispod drugoga, jer se prozori ne preklapaju.

Kada vam zaista treba plutajući prozor, `Super + T` aktivni prozor izbacuje iz popločavanja (i vraća ga natrag). Ali prvo dajte popločavanju pravu priliku — ono je srce cijele stvari. [Navigacija](04-navigation.md) vodi vas kroz to.

Radni prostori djelovat će poznato: to su macOS Spaces ili virtualne radne površine u Windowsima, samo što ćete ih zapravo koristiti, jer `Super + 1/2/3/4` skače ravno na jedan, a `Super + Shift + 1/2/3/4` tamo šalje aktivni prozor. Nema odgode animacije, samo trenutni skokovi. To znači da vam možda neće ni trebati više monitora, ako ste na to bili naviknuti prije.

### Kopiranje i lijepljenje jednostavno rade

Na Macu ste posvuda imali Cmd + C. Na Windowsima ste posvuda imali Ctrl + C — osim u terminalu, gdje to ubija vaš program. Omarchy vam daje `Super + C`, `Super + X` i `Super + V`, i oni rade posvuda, uključujući terminal. Nema zasebnog refleksa koji treba naučiti za ljusku.

Ljudi s Windowsa: vaša povijest međuspremnika s Win + V živi na `Super + Ctrl + V` i drži slike kao i tekst. Pogledajte [ujedinjeni međuspremnik i povijest](08-unified-clipboard-history.md).

### Tablica prevođenja

| Posežete za | U Omarchyju |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — izbornik Omarchy |
| AirDrop | LocalSend, putem `Super + Ctrl + S` — pogledajte [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` ili `Print Screen` — pogledajte [snimke zaslona i snimanje](12-screenshots-recording.md) |
| Notification Center | Povijest obavijesti na `Super + Shift + Alt + ,` |
| Time Machine (za sustav) | Automatske [snimke sustava](47-system-snapshots.md) pri svakom ažuriranju |
| App Store / preuzimanje instalacijskog programa | _Instaliraj_ u izborniku ili `omarchy pkg add` — pogledajte [ostale pakete](29-other-packages.md) |
| System Settings / Control Panel | _Postavljanje_ u izborniku, koje uređuje obične konfiguracijske datoteke — pogledajte [dotfiles](31-dotfiles.md) |

### Neke stvari doista jesu drukčije

Mnogo postavki živi u tekstualnim datotekama koje uređujete, a ne u panelima kroz koje klikate. To zvuči primitivno dok ne shvatite da to znači da se svaka prilagodba može vidjeti, kopirati na vaše sljedeće računalo i staviti pod kontrolu verzija. Izbornik _Postavljanje_ baca vas ravno u pravu datoteku i ponovno pokreće što god treba ponovno pokrenuti kada završite.

Ažuriranja dolaze kroz jednu naredbu — _Ažuriranje > Omarchy_ — koja ažurira sam Omarchy i svaki paket na sustavu, a prvo napravi snimku. Nema programa za ažuriranje pojedinačnih aplikacija koji vas gnjave nasumično. Pogledajte [ažuriranja](30-updates.md).

Softver dolazi iz upravitelja paketa, a ne iz preuzetih instalacijskih programa.

A kada zatvorite prozor, aplikacija se stvarno zatvara. Nema macOS limba u kojem program nastavlja raditi bez prozora. `Super + W` — ili `Super + Q`, ako je to memorija prstiju s kojom ste stigli — znači nestalo.

### Na Mac hardveru

Omarchy dobro radi na Intel Mac računalima — pogledajte [podršku za Mac](44-mac-support.md). A tipkovnica je ljubazna prema vama: Omarchy ništa ne remapira, a Linux tipku Command tretira kao Super, pa Super sjedi točno tamo gdje je Cmd uvijek bio. Vaš palac neće primijetiti selidbu.

### Dajte tome dva tjedna

Instinkti se prenesu brže nego što biste mislili. Jednom preletite poglavlje [prečaci](07-hotkeys.md), a kad god vam ponestane pojma o nekoj poveznici, pritisnite `Super + K` — pokazuje vam ih sve. To je jedini prečac koji zapravo morate zapamtiti.
