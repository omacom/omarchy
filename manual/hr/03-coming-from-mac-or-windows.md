# Dolazak s Maca ili Windowsa

Ako ste godinama bili na macOS-u ili Windowsima, vaši prsti znaju stotinu stvari za koje je vaš mozak zaboravio da ih je ikada naučio. Ovo poglavlje je sloj za prevođenje: kamo ti instinkti odlaze u Omarchyju. Same značajke detaljno su obrađene drugdje — ovo je samo karta.

### Super je središte svega

Sva mišićna memorija koju ste izgradili oko tipke Cmd ili Windows tipke prenosi se na jednu tipku: Super. To je Windows tipka na PC tipkovnici i sidro je za gotovo svaki tipkovnički prečac u Omarchyju.

Vaš refleks za Spotlight, Raycast ili izbornik Start postaje `Super + Space`. Time se otvara izbornik Omarchy, koji pokreće aplikacije, mijenja postavke, instalira softver, snima zaslon — gotovo sve. Počnite tipkati za filtriranje. `Super + Alt + Space` prikazuje sve aplikacije na jednoj mreži, kao što to radi Launchpad. Pogledajte [navigaciju](04-navigation.md).

### Nema ikona na radnoj površini, a dock se drži podalje

Nema ikona za raspoređivanje na radnoj površini, a dock se skriva čim radni prostor ima prozor, sve dok pokazivač ne gurnete do njegova ruba zaslona, donjega osim ako ga ne premjestite (pogledajte [navigaciju](04-navigation.md)). Aplikacije se pokreću tipkovničkim prečacom (`Super + Return` za terminal, `Super + Shift + Return` za preglednik i `Super + K` za popis svega što je mapirano) ili iz izbornika. Jedini stalni dio sučelja je [gornja traka](05-the-top-bar.md), koja pokriva ono što su za vas prije radili traka izbornika, sistemska traka i Notification Center — a gotovo svaki widget na njoj radi nešto na lijevi, desni i srednji klik.

### Prozori se sami smještaju

Najveća promjena načina razmišljanja: ne povlačite prozore okolo niti ih ne pričvršćujete za polovice zaslona. Otvorite prozor i on zauzme cijeli zaslon. Otvorite drugi i oni ga podijele. Nikada ne izvlačite prozor ispod drugoga, jer se prozori ne preklapaju.

Kad vam doista treba plutajući prozor, `Super + T` prebacuje aktivni prozor iz popločavanja (i natrag). Ali prvo dajte popločavanju pravu priliku — ono je srce cijele stvari. [Navigacija](04-navigation.md) vodi vas kroz to.

Radni prostori djelovat će poznato: to su macOS Spaces ili virtualne radne površine u Windowsima, samo što ćete ih zapravo koristiti, jer `Super + 1/2/3/4` skače izravno na jedan, a `Super + Shift + 1/2/3/4` tamo šalje aktivni prozor. Nema odgode animacije, samo trenutni skokovi. To znači da vam možda neće trebati ni više monitora, ako ste na to bili naviknuti.

### Kopiranje i lijepljenje jednostavno rade

Na Macu ste svugdje imali Cmd + C. Na Windowsima ste svugdje imali Ctrl + C — osim u terminalu, gdje to ubija vaš program. Omarchy vam daje `Super + C`, `Super + X` i `Super + V`, i oni rade svugdje, uključujući terminal. Nema zasebnog refleksa koji treba učiti za ljusku.

Ljudi s Windowsa: vaša povijest međuspremnika s Win + V živi na `Super + Ctrl + V` i drži slike kao i tekst. Pogledajte [jedinstveni međuspremnik i povijest](08-unified-clipboard-history.md).

### Tablica prevođenja

| Za čime posežete | U Omarchyju |
| ------------- | ---------- |
| Spotlight / Raycast / izbornik Start | `Super + Space` — izbornik Omarchy |
| AirDrop | LocalSend, putem `Super + Ctrl + S` — pogledajte [GUI-ji](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` ili `Print Screen` — pogledajte [snimke zaslona i snimanje](12-screenshots-recording.md) |
| Notification Center | Povijest obavijesti na `Super + Shift + Alt + ,` |
| Time Machine (za sustav) | Automatske [snimke sustava](47-system-snapshots.md) pri svakom ažuriranju |
| App Store / preuzimanje instalacijskog programa | _Install_ u izborniku ili `omarchy pkg add` — pogledajte [ostali paketi](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ u izborniku, koji uređuje obične konfiguracijske datoteke — pogledajte [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, na `Super + Shift + F` — pogledajte [GUI-ji](22-guis.md) |
| Safari / Edge | Google Chrome na `Super + Shift + Return`; odaberite drugi pod _Setup > Defaults > Browser_ — pogledajte [preglednici](23-browsers.md) |
| Preview / Photos | Omaview za slike, video i glazbu, Document Viewer za PDF-ove — pogledajte [GUI-ji](22-guis.md) |
| TextEdit / Notepad | Plain, na `Super + Shift + N`; odaberite drugi pod _Setup > Defaults > Editor_ |

### Neke su stvari doista drukčije

Mnogo postavki živi u tekstualnim datotekama koje uređujete, a ne u panelima kroz koje klikate. To zvuči primitivno dok ne shvatite da to znači da se svaka prilagodba može vidjeti, kopirati na vaše sljedeće računalo i staviti pod kontrolu verzija. Izbornik _Setup_ ubacuje vas izravno u pravu datoteku i ponovno pokreće sve što treba ponovno pokrenuti kad završite.

Ažuriranja dolaze kroz jednu naredbu — _Update > Omarchy_ — koja ažurira sam Omarchy i svaki paket na sustavu, a prvo napravi snimku. Nema zasebnih programa za ažuriranje po aplikaciji koji vas gnjave nasumce. Pogledajte [ažuriranja](30-updates.md).

Softver dolazi iz upravitelja paketa, a ne iz preuzetih instalacijskih programa.

A kad zatvorite prozor, aplikacija se doista zatvori. Nema macOS limba u kojem program nastavlja raditi bez prozora. `Super + W` — ili `Super + Q`, ako ste s tom memorijom prstiju došli — znači nestalo.

### Na Mac hardveru

Omarchy dobro radi na Intel Macovima te na M1, M2 i M3 Macovima s Omarchyjem za Apple Silicon. Pogledajte [podršku za Mac](44-mac-support.md). A tipkovnica je ljubazna prema vama: Omarchy ništa ne remapira, a Linux tipku Command tretira kao Super, pa Super sjedi točno ondje gdje je Cmd uvijek bio. Vaš palac neće primijetiti selidbu.

### Dajte tome dva tjedna

Instinkti se prenesu brže nego što mislite. Jednom letimice prođite poglavlje o [tipkovničkim prečacima](07-hotkeys.md), a kad god vam ponestane poveznice, pritisnite `Super + K` — pokazuje vam ih sve. To je jedini tipkovnički prečac koji doista morate zapamtiti.
