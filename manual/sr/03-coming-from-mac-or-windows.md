# Prelazak sa Mac-a ili Windows-a

Ako ste godinama bili na macOS-u ili Windows-u, vaši prsti znaju stotinu stvari za koje je vaš mozak zaboravio da ih je ikada naučio. Ovo poglavlje je sloj za prevođenje: gde ti instinkti idu u Omarchy-ju. Same funkcije su detaljno obrađene drugde — ovo je samo mapa.

### Super je centar svega

Sva mišićna memorija koju ste izgradili oko Cmd ili Windows tastera prelazi na jedan taster: Super. To je Windows taster na PC tastaturi, i on je sidro za skoro svaku prečicu u Omarchy-ju.

Vaš refleks za Spotlight ili Raycast ili Start meni postaje `Super + Space`. Time se otvara Omarchy meni, koji pokreće aplikacije, menja podešavanja, instalira softver, hvata ekran — skoro sve. Počnite da kucate da biste filtrirali. `Super + Alt + Space` prikazuje sve aplikacije na jednoj mreži, onako kako to radi Launchpad. Pogledajte [navigaciju](04-navigation.md).

### Nema ikona na desktopu, a dock se prikazuje samo kada plutate

Nema ikona koje biste raspoređivali po desktopu, i nema dock-a na tiling radnom prostoru — dock se pojavljuje samo na plutajućem radnom prostoru (pogledajte [navigaciju](04-navigation.md)). Aplikacije se pokreću prečicom (`Super + Return` za terminal, `Super + Shift + Return` za pregledač, i `Super + K` za listu svega što je mapirano) ili iz menija. Jedini stalni deo korisničkog interfejsa je [gornja traka](05-the-top-bar.md), koja pokriva ono što su za vas ranije radili traka sa menijima, sistemska paleta i Notification Center — i skoro svaki vidžet na njoj radi nešto na levi, desni i srednji klik.

### Prozori se sami raspoređuju

Najveća promena u načinu razmišljanja: ne prevlačite prozore unaokolo niti ih prilepljujete za polovine ekrana. Otvorite prozor i on zauzme ceo ekran. Otvorite drugi i oni podele ekran. Nikada ne vadite prozor ispod drugog, jer se prozori ne preklapaju.

Kada vam zaista treba plutajući prozor, `Super + T` prebacuje aktivni prozor iz tiling režima (i nazad). Ali prvo dajte tiling režimu pravu šansu — to je srce cele stvari. [Navigacija](04-navigation.md) vas vodi kroz to.

Radni prostori će vam delovati poznato: to su macOS Spaces ili Windows virtuelni desktopi, samo što ćete ih zapravo koristiti, jer `Super + 1/2/3/4` skače pravo na jedan, a `Super + Shift + 1/2/3/4` tamo šalje aktivni prozor. Nema kašnjenja animacije, samo trenutni skokovi. To znači da vam možda neće ni trebati više monitora, ako ste na to bili navikli ranije.

### Kopiranje i lepljenje jednostavno rade

Na Mac-u ste svuda imali Cmd + C. Na Windows-u ste svuda imali Ctrl + C — osim u terminalu, gde to ubija vaš program. Omarchy vam daje `Super + C`, `Super + X` i `Super + V`, i oni rade svuda, uključujući terminal. Nema posebnog refleksa koji treba da učite za shell.

Korisnici Windows-a: vaša Win + V istorija clipboard-a živi na `Super + Ctrl + V`, i čuva slike kao i tekst. Pogledajte [jedinstveni clipboard i istoriju](08-unified-clipboard-history.md).

### Tabela za prevođenje

| Posežete za | U Omarchy-ju |
| ------------- | ---------- |
| Spotlight / Raycast / Start meni | `Super + Space` — Omarchy meni |
| AirDrop | LocalSend, preko `Super + Ctrl + S` — pogledajte [GUI-je](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` ili `Print Screen` — pogledajte [snimke ekrana i snimanje](12-screenshots-recording.md) |
| Notification Center | Istorija obaveštenja na `Super + Shift + Alt + ,` |
| Time Machine (za sistem) | Automatski [sistemski snimci](47-system-snapshots.md) pri svakom ažuriranju |
| App Store / preuzimanje instalera | _Install_ u meniju, ili `omarchy pkg add` — pogledajte [ostale pakete](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ u meniju, koji uređuje obične konfiguracione fajlove — pogledajte [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, na `Super + Shift + F` — pogledajte [GUI-je](22-guis.md) |
| Safari / Edge | Google Chrome na `Super + Shift + Return`; izaberite drugi pod _Setup > Defaults > Browser_ — pogledajte [pregledače](23-browsers.md) |
| Preview / Photos | Omaview za slike, video i muziku, Document Viewer za PDF-ove — pogledajte [GUI-je](22-guis.md) |
| TextEdit / Notepad | Plain, na `Super + Shift + N`; izaberite drugi pod _Setup > Defaults > Editor_ |

### Neke stvari zaista jesu drugačije

Mnoga podešavanja žive u tekstualnim fajlovima koje uređujete, a ne u panelima kroz koje klikćete. To zvuči primitivno dok ne shvatite da to znači da se svako podešavanje može videti, kopirati na vašu sledeću mašinu i staviti pod kontrolu verzija. Meni _Setup_ vas baca pravo u pravi fajl i restartuje sve što treba da se restartuje kada završite.

Ažuriranja dolaze kroz jednu komandu — _Update > Omarchy_ — koja ažurira sam Omarchy i svaki paket na sistemu, praveći prvo snimak. Nema pojedinačnih programa za ažuriranje koji vas gnjave nasumice. Pogledajte [ažuriranja](30-updates.md).

Softver dolazi iz menadžera paketa, a ne iz preuzetih instalera.

A kada zatvorite prozor, aplikacija se zaista gasi. Nema macOS limba u kom program nastavlja da radi bez prozora. `Super + W` — ili `Super + Q`, ako je to mišićna memorija sa kojom ste došli — znači nestalo.

### Na Mac hardveru

Omarchy dobro radi na Intel Mac-ovima — pogledajte [podršku za Mac](44-mac-support.md). A tastatura je ljubazna prema vama: Omarchy ništa ne remapira, a Linux tretira Command taster kao Super, tako da Super sedi tačno tamo gde je Cmd oduvek bio. Vaš palac neće primetiti prelazak.

### Dajte mu dve nedelje

Instinkti se prenose brže nego što mislite. Preletite jednom poglavlje o [prečicama](07-hotkeys.md), i kad god vam zablokira neka kombinacija, pritisnite `Super + K` — pokazuje vam ih sve. To je jedina prečica koju zapravo morate da zapamtite.
