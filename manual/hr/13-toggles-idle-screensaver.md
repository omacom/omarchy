# Prebacivanja, neaktivnost i čuvar zaslona

Mnogo toga što svakodnevno mijenjate zapravo nije postavka. To je način koji uključite na sat vremena i ponovno isključite: noćno svjetlo dok radite kasno, ne ometaj dok prezentirate, ostani budan dok nešto gledate. Omarchy ih naziva prebacivanjima i sva rade na isti način — prečac, unos u izborniku i naredba, svi pogađaju isti prekidač.

### Izbornik prebacivanja

`Super + Ctrl + O` izravno otvara _Pokreni > Prebaci_ ili možete tamo prošetati iz Omarchy izbornika (`Super + Space`). Sve na tome popisu prekidač je koji možete prebaciti bez razmišljanja o tome gdje stanje živi. Prekidači za to kako radna površina izgleda sjede pokraj njega, pod _Pokreni > Izgled_.

Iz terminala isti prekidači su `omarchy toggle <thing>`. Pokrenite samo `omarchy toggle` da vidite cijelu grupu.

| Prebacivanje | Prečac | Naredba |
| ------ | ------ | ------- |
| Noćno svjetlo | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| Utišaj obavijesti | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| Ostani budan (bez zaključavanja pri neaktivnosti) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Snimanje rušenja | — | `omarchy toggle crash-capture` |
| Čuvar zaslona | — | `omarchy toggle screensaver` |
| Sinkronizacija teme [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Traka izbornika | `Super + Shift + Space` | `omarchy toggle bar` |
| Dodirna ploha | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Zaslon na dodir | — | `omarchy toggle touchscreen` |
| Obustavi | — | `omarchy toggle suspend` |
| Hybrid GPU | — | `omarchy toggle hybrid gpu` |

Prekidači za dodirnu plohu, zaslon na dodir i hybrid GPU žive pod _Pokreni > Hardver_ (`Super + Ctrl + H`), a ne pod Prebaci, jer se pojavljuju samo kada doista imate taj hardver. Oni za dodirnu plohu i zaslon na dodir preživljavaju ponovno učitavanje Hyprlanda — naziv onemogućenoga uređaja sprema se u malenu datoteku stanja koju Hyprland čita pri pokretanju da ga ponovno onemogući.

_Pokreni > Izgled_ drži traku izbornika i animacije, plus nekoliko stvari koje nisu naredbe `omarchy toggle`, ali se ponašaju isto: postotak baterije u traci, zadani raspored radnoga prostora, razmaci prozora (`Super + Shift + Backspace`) i kvadratni omjer 1 prozora (`Super + Ctrl + Backspace`).

Većina njih samo je datoteka zastave pod `~/.local/state/omarchy/toggles/`. Ako želite granati na nekome u skripti, `omarchy-toggle-enabled` daje vam izlazni kod umjesto da vas tjera da ga tražite:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Zastave su nazvane po isključenome stanju — `screensaver-off`, `suspend-off`, `bar-off` — pa njihova prisutnost znači da je značajka onemogućena.

### Pokazatelji u traci

Kada je način uključen, dobivate maleni znak u sredini gornje trake pokraj sata. To je widget pokazatelja i nosi diktiranje, snimanje zaslona, podsjetnike na čekanju, noćno svjetlo, ne ometaj i ostani budan.

Neaktivni pokazatelji skriveni su. Lebdite na području oko njih i oni ublijede prigušeno, pa možete kliknuti jednoga da ga uključite bez poznavanja njegova prečaca. Klikom na aktivnoga isključuje se. Ako radije vidite sve njih stalno, postavite `alwaysShow` na `true` na unosu `omarchy.indicators` u `~/.config/omarchy/shell.json` — pogledajte [gornju traku](05-the-top-bar.md) za to kako se widgeti trake konfiguriraju.

### Noćno svjetlo

`Super + Ctrl + N` zagrijava zaslon na 4000 K, a ponovni pritisak vraća ga na 6500 K. Pokreće ga hyprsunset, koji prebacivanje pokreće za vas ako se već ne izvodi.

Prema zadanim postavkama hyprsunset uopće ne radi ništa vašem zaslonu. `~/.config/hypr/hyprsunset.conf` isporučuje se s identitetskim profilom upravo zato da zaslon ostane nedirnut dok ne zatražite toplinu. Ako radije želite da se prebacuje po satu, zamijenite to vremenskim profilom:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Zatim pokrenite hyprsunset pri prijavi dodavanjem `o.launch_on_start("hyprsunset")` u `~/.config/hypr/autostart.lua`. Par 4000 K/6500 K koji koristi prebacivanje fiksan je, pa je konfiguracijska datoteka mjesto kuda idete ako želite drukčiju temperaturu.

### Ne ometaj

`Super + Ctrl + ,` utišava obavijesti. Nikakve poruke ne iskaču dok je uključen, a pokazatelj prekriženoga zvona sjedi u traci da vas podsjeti zašto je radna površina utihnula.

Međutim, ništa nije izgubljeno. Utišana obavijest zapisuje se ravno u vašu povijest obavijesti, što je točno zapis koji želite kada se vratite i zapitate se što ste propustili. Otvorite je prečacom `Super + Shift + Alt + ,`. Pogledajte [obavijesti](10-notices.md) za ostatak priče o obavijestima.

Dvije vrste poruka i dalje prolaze: Omarchyjeve vlastite potvrdne poruke za nešto što ste upravo učinili ("Theme changed", "Screenshot saved") i kritična upozorenja poslana iz naredbenoga retka. Aplikacije za čet koje sve označavaju kritičnim da bi se na silu progurale pred vas ne ispunjavaju uvjete.

### Neaktivnost

Omarchy ljuska vlasnik je ponašanja neaktivnosti, a vremenske odmake predstavlja blok `idle` na najvišoj razini u `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Oba broja su sekunde brojane od trenutka kada ste postali neaktivni — ne jedan od drugoga. Dakle sa zadanim postavkama čuvar zaslona pojavljuje se nakon dvije i pol minute, a zaključani zaslon preuzima u pet minuta, bez obzira na to je li čuvar zaslona radio. Spremite datoteku i ljuska odmah preuzima nove vremenske odmake.

Ako odbacite čuvara zaslona prije roka zaključavanja, to se računa kao aktivnost i zaključavanje na čekanju se otkazuje. Nećete biti zaključani vani jer ste bacili pogled na svoj stroj.

Da potpuno zaustavite zaključavanje pri neaktivnosti, `Super + Ctrl + I` — ili `omarchy toggle idle` — uključuje ostani budan, a pokazatelj šalice kave pojavljuje se u traci. Taj treba pritisnuti prije duge prezentacije ili izgradnje koju želite promatrati. Pritisnite ga ponovno za povratak u normalno. `omarchy toggle idle status` ispisuje trenutačno stanje kao JSON ako vam treba iz skripte.

Ovo se odnosi na zaključavanje i čuvara zaslona, a ne na napajanje. Obustava i hibernacija imaju svoje postavke u [spavanju sustava](36-system-sleep.md).

### Čuvar zaslona

Omarchyjev čuvar zaslona ASCII je umjetnost koja prolazi kroz nasumične tekstualne efekte, jedan primjerak po monitoru. Svaka tipka ili pomak miša izlazi iz njega.

Možete ga pokrenuti na zahtjev iz _Sustav > Čuvar zaslona_ (`Super + Esc`), što ga prisilno podiže čak i ako ste isključili čuvara zaslona pri neaktivnosti. Prema zadanim postavkama za njega nije vezan nijedan prečac.

`omarchy toggle screensaver` ono je što isključuje onoga pri neaktivnosti, ako biste radije išli ravno s posla na zaključano. Treba mu terminal koji zna konfigurirati — Alacritty, Foot, Ghostty ili Kitty — i reći će vam to ako je vaš zadani terminal nešto drugo.

Logotip koji crta vaš je za promijeniti, pod _Stil > Čuvar zaslona_. Prenesite png ili svg i Omarchy ga pretvara u ASCII. Pogledajte [branding](41-branding.md).

### Zaključani zaslon

`Super + Ctrl + L` zaključava stroj. To pokreće zaključani zaslon iz Omarchy ljuske, zatamnjuje zaslon, vraća raspored tipkovnice na prvi da ne tipkate lozinku u krivoj abecedi i — ako ga imate pokrenutoga — usput zaključava 1Password.

Zaključani zaslon prima lozinku, a primit će i otisak prsta jednom kada ga postavite. To i drugi načini autentifikacije obrađeni su u [hardverskoj autentifikaciji](37-hardware-authentication.md).
