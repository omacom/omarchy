# Prelazak s Maca ili Windowsa

Ako ste godinama proveli na macOS-u ili Windowsima, vaši prsti znaju stotinu stvari za koje je vaš mozak zaboravio da ih je ikada naučio. Ovo poglavlje je sloj prijevoda: kamo ti instinkti idu u Omarchyju. Same značajke detaljno su obrađene drugdje — ovo je samo karta.

### Super je središte svega

Sva mišićna memorija koju ste izgradili oko Cmd-a ili tipke Windows prenosi se na jednu tipku: Super. To je tipka Windows na PC tipkovnici i sidro je za gotovo svaki prečac u Omarchyju.

Vaš refleks za Spotlight, Raycast ili izbornik Start postaje `Super + Space`. Time se otvara izbornik Omarchyja, koji pokreće aplikacije, mijenja postavke, instalira softver, snima zaslon — gotovo sve. Počnite tipkati za filtriranje. `Super + Alt + Space` prikazuje svaku aplikaciju na jednoj mreži, kao što to radi Launchpad. Vidi [navigacija](04-navigation.md).

### Nema ikona na radnoj površini, a dock se drži po strani

Nema ikona za raspoređivanje po radnoj površini, a dock se sakriva čim radni prostor ima prozor, sve dok pokazivač ne gurnete do ruba zaslona na kojem se nalazi, desnog ako ga ne premjestite (vidi [navigacija](04-navigation.md)). Aplikacije se pokreću prečacem (`Super + Return` za terminal, `Super + Shift + Return` za preglednik i `Super + K` za popis svega što je mapirano) ili iz izbornika. Jedini stalni dio sučelja je [gornja traka](05-the-top-bar.md), koja pokriva ono što su za vas prije radili traka izbornika, sistemska traka i Centar za obavijesti — i gotovo svaki widget na njoj nešto radi na lijevi, desni i srednji klik.

### Prozori se sami smještaju

Najveća promjena načina razmišljanja: prozore ne vučete okolo niti ih prikvačujete za polovice zaslona. Otvorite prozor i on zauzme cijeli zaslon. Otvorite drugi i oni ga podijele. Nikada ne morate izvlačiti prozor ispod drugoga, jer se prozori ne preklapaju.

Kada vam zaista treba plutajući prozor, `Super + T` aktivni prozor izbacuje iz slaganja u pločice (i vraća ga natrag). Ali prvo dajte slaganju u pločice pravu priliku — to je srce cijele stvari. [Navigacija](04-navigation.md) vodi vas kroz to.

Radni prostori djelovat će poznato: oni su macOS Spaces ili virtualne radne površine u Windowsima, samo što ćete ih zapravo koristiti, jer `Super + 1/2/3/4` skače ravno na jedan, a `Super + Shift + 1/2/3/4` tamo šalje aktivni prozor. Nema kašnjenja animacije, samo trenutni skokovi. To znači da vam možda neće trebati ni više monitora, ako ste na to prije bili navikli.

### Kopiranje i lijepljenje jednostavno rade

Na Macu ste svugdje imali Cmd + C. Na Windowsima ste svugdje imali Ctrl + C — osim u terminalu, gdje vam to ubije program. Omarchy vam daje `Super + C`, `Super + X` i `Super + V`, i oni rade svugdje, uključujući terminal. Nema zasebnog refleksa koji biste morali naučiti za ljusku.

Ljudi s Windowsa: vaša povijest međuspremnika s Win + V živi na `Super + Ctrl + V` i drži slike kao i tekst. Vidi [ujedinjeni međuspremnik i povijest](08-unified-clipboard-history.md).

### Tablica prijevoda

| Posežete za | U Omarchyju |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — izbornik Omarchyja |
| AirDrop | LocalSend, putem `Super + Ctrl + S` — vidi [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` ili `Print Screen` — vidi [snimke zaslona i snimanje](12-screenshots-recording.md) |
| Notification Center | Povijest obavijesti na `Super + Shift + Alt + ,` |
| Time Machine (za sustav) | Automatske [snimke sustava](47-system-snapshots.md) pri svakom ažuriranju |
| App Store / preuzimanje instalacijskog programa | _Instaliraj_ u izborniku, ili `omarchy pkg add` — vidi [ostali paketi](29-other-packages.md) |
| System Settings / Control Panel | _Postavke_ u izborniku, koji uređuje obične konfiguracijske datoteke — vidi [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, na `Super + Shift + F` — vidi [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome na `Super + Shift + Return`; odaberite drugi pod _Postavke > Zadano > Preglednik_ — vidi [preglednici](23-browsers.md) |
| Preview / Photos | Omaview za slike, video i glazbu, Document Viewer za PDF-ove — vidi [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, na `Super + Shift + N`; odaberite drugi pod _Postavke > Zadano > Uređivač_ |

### Neke su stvari zaista drugačije

Mnogo postavki živi u tekstnim datotekama koje uređujete, a ne u panelima kroz koje klikate. To zvuči primitivno dok ne shvatite da to znači da se svaka prilagodba može vidjeti, kopirati na vaše sljedeće računalo i staviti pod kontrolu verzija. Izbornik _Postavke_ baca vas ravno u pravu datoteku i ponovno pokreće sve što treba ponovno pokrenuti kada završite.

Ažuriranja dolaze kroz jednu naredbu — _Ažuriranje > Omarchy_ — koja ažurira sam Omarchy i svaki paket na sustavu, a prvo napravi snimku. Nema zasebnih programa za ažuriranje za svaku aplikaciju koji vas gnjave nasumce. Vidi [ažuriranja](30-updates.md).

Softver dolazi iz upravitelja paketa, a ne iz preuzetih instalacijskih programa.

A kada zatvorite prozor, aplikacija se zaista zatvara. Nema macOS limba u kojem program nastavlja raditi bez prozora. `Super + W` — ili `Super + Q`, ako je to memorija prstiju s kojom ste došli — znači nestalo.

### Na Mac hardveru

Omarchy dobro radi na Intel Macovima te na M1, M2 i M3 Macovima s Omarchyjem za Apple Silicon. Vidi [podrška za Mac](44-mac-support.md). A tipkovnica je ljubazna prema vama: Omarchy ništa ne remapira, a Linux tipku Command tretira kao Super, pa Super sjedi točno tamo gdje je Cmd uvijek bio. Vaš palac neće primijetiti selidbu.

### Dajte tome dva tjedna

Instinkti se prenesu brže nego što mislite. Jednom letimično prođite poglavlje [prečaci](07-hotkeys.md), a kad god vam zablokira neka kombinacija, pritisnite `Super + K` — pokazuje vam ih sve. To je jedini prečac koji zaista morate zapamtiti.
