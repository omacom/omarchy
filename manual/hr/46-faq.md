# Često postavljana pitanja

### Kako se prebacivati između rasporeda tipkovnice?

Uredite svoju datoteku `~/.config/hypr/input.lua` i dodajte ovo za prebacivanje između rasporeda na `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Traka će automatski prikazati vaš trenutačni raspored tipkovnice kad jednom imate konfigurirano više rasporeda (i možete je kliknuti i za prebacivanje).

### Kako promijeniti format sata na 12-satni?

Desnim gumbom kliknite sat u traci za kruženje kroz uobičajene formate, uključujući 12-satne. Format možete postaviti i izravno:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Time će se prikazati Sunday 10:55 AM.

### Kako promijeniti vremensku zonu?

Pokrenite _Ažuriraj > Timezone_ u Omarchy izborniku i odaberite s popisa. Ako je vremenska zona ispravna, ali je sam sat odlutao, _Ažuriraj > Time_ za vas ponovno pokreće sinkronizaciju vremena.

### Kako promijeniti DNS, podijeliti Wi-Fi ili provjeriti brzinu veze?

Sve to živi u [umrežavanju](35-networking.md).

### Kako provjeriti koliko je brz moj disk?

_Pokreni > Speed Test > Disk Speed Test_ mjeri živu brzinu čitanja i pisanja na vašem pogonu ili `omarchy disk speedtest` iz terminala.

### Zašto se ne mogu prijaviti u svoj Google račun u Chromiumu?

Obična inačica Chromiuma otvorenog koda ne dolazi s OAuth vjerodajnicama koje Google zahtijeva za prijavu u račun. Pokrenite _Instaliraj > Service > Chromium Account_ u Omarchy izborniku da ih dodate, ponovno pokrenite preglednik i prijava će proći.

### Kako dodati pisač?

Ispis je postavljen i radi odmah po instalaciji, a svaki pisač sami dodajete iz _Print Settings_ u pokretaču aplikacija (`Super + Space`).

Odaberite _Add_ i dajte mu trenutak da potraži: pisač priključen putem USB-a i većina mrežnih pisača pronalaze se za vas. Ako vaš nije na popisu, odaberite _Network Printer > Internet Printing Protocol (ipp)_ i unesite njegovu adresu — vlastiti zaslon pisača ili njegova web-stranica reći će vam što je to, obično nešto poput `192.168.1.50` s redom `ipp/print`. _Forward_ zatim nudi upravljački program, pri čemu moderan pisač najbolje radi na profilu _IPP Everywhere_ bez upravljačkog programa, a stariji želi vlastiti upravljački program modela.

Desnim gumbom kliknite pisač i odaberite _Set as Default_ za odabir kojem će se vaše aplikacije prvo obraćati te _Properties_ za postavljanje veličine papira, obostranog ispisa i kvalitete.

Automatsko otkrivanje, pri kojem se pisači na mreži pojavljuju bez dodavanja, privremeno je isključeno dok se prerađuje, zbog čega je prvi korak iznad vaš, a ne automatski. Ispis u PDF datoteku radi bez ikakvog pisača.

### Kako promijeniti gdje se spremaju snimke zaslona ili snimke zaslona u pokretu?

Spremljene snimke zaslona prema zadanim postavkama idu u `~/Pictures/Screenshots`. Za korištenje drugog direktorija dodajte ovo u datoteku pod `~/.config/uwsm/env.d/` (poput `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Isto možete učiniti za snimke zaslona u pokretu koristeći `OMARCHY_SCREENRECORD_DIR`.

Omasnap automatski stvara svoj direktorij za snimke zaslona. Direktorij za snimke zaslona u pokretu stvorite sami, a zatim ponovno pokrenite Omarchy da bilo koja promjena okruženja stupi na snagu.

### Kako natjerati zvučnike i web-kameru na mojem Apple Studio Displayju da rade?

Pomislili biste da bi sve trebalo raditi samim priključivanjem USB C, ali nažalost to nije slučaj. Rješenje za koje sam utvrdio da pouzdano radi jest korištenje [WJESOG DisplayPort + USB-A => USB-C kabela](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Zatim zvučnici i web-kamera rade kao iz šala.

Ne zaboravite da u Omarchyju imate ugrađenu kontrolu svjetline za Appleove zaslone (i Studio i XDR) pomoću uobičajenih tipki tipkovnice za svjetlinu.

### Kako se riješiti svog dodatnog softvera?

Ako ne želite programe poput Obsidiana ili LibreOfficea ili bilo što drugo unaprijed instalirano, možete ih vrlo lako ukloniti.

Pokrenite _Ukloni > Package_ da biste vidjeli svaki paket koji je instaliran. Zatim možete tipkom tab odabrati svaki paket koji želite ukloniti i tipkom return započeti uklanjanje svega što ste odabrali.

A možete koristiti _Ukloni > Web App_ iz Omarchy izbornika za uklanjanje bilo koje unaprijed instalirane web-aplikacije koju ne želite.

Ili pokrenite _Ukloni > Preinstalls_ da u jednom potezu pometete sve unaprijed instalirane dodatke — web-aplikacije, TUI-je i opcionalne aplikacije. Prečaci koji su ih pokretali odlaze s njima, pa vam ostaje čist list povezivanja koji ćete ispuniti svojima u `~/.config/hypr/bindings.lua`.

---

Za pogreške i pokvarene dijelove pogledajte [odjeljak Rješavanje problema](45-troubleshooting.md).
