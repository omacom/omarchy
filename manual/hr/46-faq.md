# Česta pitanja

### Kako mogu mijenjati rasporede tipkovnice?

Uredite datoteku `~/.config/hypr/input.lua` i dodajte ovo za mijenjanje rasporeda kombinacijom `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Traka će automatski prikazati vaš trenutačni raspored tipkovnice čim konfigurirate više rasporeda (a možete i kliknuti na njega za promjenu).

### Kako mogu promijeniti format sata na 12-satni?

Desnom tipkom miša kliknite sat na traci za kruženje kroz uobičajene formate, uključujući 12-satne. Format možete postaviti i izravno:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

To će prikazati nedjelja 10:55 AM.

### Kako mogu promijeniti vremensku zonu?

Pokrenite _Postavke > Regija > Vremenska zona_ u izborniku Omarchy i odaberite s popisa. Ako je vremenska zona ispravna, ali je sam sat odlutao, _Ažuriranje > Vrijeme_ ponovno pokreće sinkronizaciju vremena umjesto vas.

### Kako mogu promijeniti DNS, podijeliti Wi-Fi ili provjeriti brzinu veze?

Sve to nalazi se u [umrežavanju](35-networking.md).

### Kako mogu provjeriti koliko je brz moj disk?

_Okidač > Test brzine > Test brzine diska_ mjeri brzinu čitanja i pisanja na vašem pogonu uživo ili `omarchy disk speedtest` iz terminala.

### Kako mogu dodati pisač?

Ispis je postavljen i radi odmah po instalaciji, a svaki pisač dodajete sami iz _Print Settings_ u pokretaču aplikacija (`Super + Alt + Space`).

Odaberite _Dodaj_ i pričekajte trenutak dok traži: pisač priključen putem USB-a i većina mrežnih pisača pronaći će se za vas. Ako vaš nije na popisu, odaberite _Mrežni pisač > Internet Printing Protocol (ipp)_ i unesite njegovu adresu — zaslon samog pisača ili njegova web-stranica reći će vam koja je to adresa, obično nešto poput `192.168.1.50` s redom čekanja `ipp/print`. _Naprijed_ zatim nudi upravljački program, pri čemu moderni pisač najbolje radi na profilu _IPP Everywhere_ bez upravljačkog programa, a stariji želi vlastiti upravljački program modela.

Desnom tipkom miša kliknite pisač i odaberite _Postavi kao zadano_ kako biste odabrali koji će vaše aplikacije prvo koristiti, a _Svojstva_ za postavljanje veličine papira, obostranog ispisa i kvalitete.

Automatsko otkrivanje, kod kojeg se pisači na mreži pojavljuju bez dodavanja, privremeno je isključeno dok se prerađuje, zbog čega je prvi korak gore na vama, a ne automatski. Ispis u PDF datoteku radi uopće bez pisača.

### Kako mogu promijeniti gdje se spremaju snimke zaslona ili snimanja zaslona?

Spremljene snimke zaslona prema zadanome idu u `~/Pictures/Screenshots`. Za korištenje drugog direktorija dodajte ovo u datoteku pod `~/.config/uwsm/env.d/` (poput `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Isto možete učiniti i za snimanja zaslona koristeći `OMARCHY_SCREENRECORD_DIR`.

Omasnap automatski stvara svoj direktorij za snimke zaslona. Direktorij za snimanja zaslona stvorite sami, zatim ponovno pokrenite Omarchy kako bi bilo koja promjena okruženja stupila na snagu.

### Kako mogu osposobiti zvučnike + web-kameru na svom Apple Studio Displayu?

Mislili biste da bi sve trebalo raditi samo priključivanjem USB C-a, ali nažalost nije tako. Rješenje za koje sam utvrdio da pouzdano radi jest korištenje [kabela WJESOG DisplayPort + USB-A => USB-C](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Tada zvučnici i web-kamera rade bez greške.

Imajte na umu da u Omarchyju imate ugrađenu kontrolu svjetline za Apple zaslone (i Studio i XDR) pomoću uobičajenih tipki za svjetlinu na tipkovnici.

### Kako mogu ukloniti sav dodatni softver?

Ako ne želite programe poput Obsidiana ili LibreOfficea ili bilo što drugo od unaprijed instaliranih stvari, možete ih vrlo lako ukloniti.

Pokrenite _Ukloni > Paket_ kako biste vidjeli svaki instalirani paket. Zatim tipkom tab možete odabrati bilo koji paket koji želite ukloniti, a tipkom return započeti uklanjanje svega što ste odabrali.

A iz izbornika Omarchy možete koristiti _Ukloni > Web-aplikacija_ za uklanjanje bilo koje unaprijed instalirane web-aplikacije koju ne želite.

Ili pokrenite _Ukloni > Unaprijed instalirano_ kako biste odjednom počistili sve unaprijed instalirane dodatke — web-aplikacije, TUI-je i neobvezne aplikacije. Prečaci koji su ih pokretali nestaju zajedno s njima, pa vam ostaje čista ploča prečaca koju možete popuniti svojima u `~/.config/hypr/bindings.lua`.

---

Za pogreške i pokvarene dijelove pogledajte [odjeljak za rješavanje problema](45-troubleshooting.md).
