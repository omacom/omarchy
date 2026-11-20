# Česta pitanja

### Kako se prebacivati između rasporeda tipkovnice?

Uredite datoteku `~/.config/hypr/input.lua` i dodajte ovo za prebacivanje između rasporeda tipkama `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Traka će automatski prikazati vaš trenutni raspored tipkovnice nakon što konfigurirate više rasporeda (a možete ga i kliknuti za prebacivanje).

### Kako promijeniti format sata u 12-satni?

Kliknite desnom tipkom miša sat u traci da biste se kretali kroz uobičajene formate, uključujući 12-satne. Format možete postaviti i izravno:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Time će se prikazati nedjelja 10:55 AM.

### Kako promijeniti vremensku zonu?

Pokrenite _Postavljanje > Regija > Vremenska zona_ u izborniku Omarchy i odaberite s popisa. Ako je vremenska zona točna, ali je sam sat odlutao, _Ažuriranje > Vrijeme_ ponovno pokreće sinkronizaciju vremena umjesto vas.

### Kako promijeniti DNS, dijeliti Wi-Fi ili provjeriti brzinu veze?

Sve to nalazi se u [umrežavanju](35-networking.md).

### Kako provjeriti koliko je brz moj disk?

_Pokretanje > Test brzine > Test brzine diska_ mjeri stvarnu brzinu čitanja i pisanja na vašem pogonu, ili `omarchy disk speedtest` iz terminala.

### Kako dodati pisač?

Ispis je postavljen i radi odmah po instalaciji, a svaki pisač dodajete sami iz _Postavki ispisa_ u pokretaču aplikacija (`Super + Space`).

Odaberite _Dodaj_ i pričekajte trenutak da potraži: pisač priključen putem USB-a i većina mrežnih pisača pronaći će se za vas. Ako vaš nije na popisu, odaberite _Mrežni pisač > Internet Printing Protocol (ipp)_ i unesite njegovu adresu — zaslon samog pisača ili njegova web-stranica reći će vam koja je to adresa, obično nešto poput `192.168.1.50` s redom čekanja `ipp/print`. _Naprijed_ zatim nudi upravljački program, pri čemu moderni pisač najbolje radi na profilu _IPP Everywhere_ bez upravljačkog programa, a stariji želi vlastiti upravljački program modela.

Kliknite pisač desnom tipkom miša i odaberite _Postavi kao zadano_ da biste odabrali kojem će se vaše aplikacije prvo obratiti, a _Svojstva_ za postavljanje veličine papira, obostranog ispisa i kvalitete.

Automatsko otkrivanje, pri kojem se pisači na mreži pojavljuju bez dodavanja, privremeno je isključeno dok se prerađuje, zbog čega je prvi korak gore vaš, a ne automatski. Ispis u PDF datoteku radi i bez ikakvog pisača.

### Kako promijeniti gdje se spremaju snimke zaslona ili snimanja zaslona?

Spremljene snimke zaslona prema zadanim postavkama idu u `~/Pictures/Screenshots`. Za korištenje drugog direktorija dodajte ovo u datoteku pod `~/.config/uwsm/env.d/` (poput `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Isto možete učiniti i za snimanja zaslona pomoću `OMARCHY_SCREENRECORD_DIR`.

Omasnap automatski stvara svoj direktorij za snimke zaslona. Direktorij za snimanja zaslona stvorite sami, zatim ponovno pokrenite Omarchy da bi bilo koja od promjena okruženja stupila na snagu.

### Kako natjerati zvučnike + web-kameru da rade na mom Apple Studio Displayju?

Pomislili biste da bi sve trebalo raditi samo priključivanjem USB C-a, ali nažalost nije tako. Rješenje za koje sam utvrdio da pouzdano radi jest korištenje [kabla WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Tada zvučnici i web-kamera rade kao podmazani.

Ne zaboravite da u Omarchyju imate ugrađenu kontrolu svjetline za Apple zaslone (i Studio i XDR) pomoću uobičajenih tipki tipkovnice za svjetlinu.

### Kako se riješiti svega dodatnog softvera?

Ako ne želite programe poput Obsidian ili LibreOffice ili bilo koju drugu predinstaliranu stvar, možete je vrlo lako ukloniti.

Pokrenite _Uklanjanje > Paket_ da biste vidjeli svaki instalirani paket. Zatim tipkom tab možete odabrati bilo koji paket koji želite ukloniti i tipkom return započeti uklanjanje svega što ste odabrali.

A iz izbornika Omarchy možete upotrijebiti _Uklanjanje > Web aplikacija_ za uklanjanje bilo koje predinstalirane web aplikacije koju ne želite.

Ili pokrenite _Uklanjanje > Predinstalacije_ da biste odjednom izbacili sve predinstalirane dodatke — web aplikacije, TUIs i neobavezne aplikacije. Prečaci koji su ih pokretali nestaju s njima, pa vam ostaje prazna ploča veza koju možete ispuniti vlastitima u `~/.config/hypr/bindings.lua`.

---

Za pogreške i pokvarene dijelove pogledajte [odjeljak za rješavanje problema](45-troubleshooting.md).
