# Česta pitanja

### Kako prebacivati između rasporeda tipkovnice?

Uredite datoteku `~/.config/hypr/input.lua` i dodajte ovo za prebacivanje između rasporeda pomoću `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Traka će automatski prikazati vaš trenutni raspored tipkovnice nakon što konfigurirate više rasporeda (a možete i kliknuti na nju za prebacivanje).

### Kako promijeniti format sata na 12-satni?

Desnim klikom na sat u traci kružite kroz uobičajene formate, uključujući 12-satne. Format možete postaviti i izravno:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

To će prikazati Nedjelja 10:55 AM.

### Kako promijeniti vremensku zonu?

Pokrenite _Update > Timezone_ u izborniku Omarchy i odaberite s popisa. Ako je vremenska zona točna, ali je sam sat odlutao, _Update > Time_ ponovno pokreće sinkronizaciju vremena umjesto vas.

### Kako promijeniti DNS, dijeliti Wi-Fi ili provjeriti brzinu veze?

Sve to nalazi se u [umrežavanju](35-networking.md).

### Kako provjeriti koliko je brz moj disk?

_Trigger > Speed Test > Disk Speed Test_ mjeri trenutnu brzinu čitanja i pisanja na vašem disku, ili `omarchy disk speedtest` iz terminala.

### Kako dodati pisač?

Ispis je postavljen i radi odmah po instalaciji, a svaki pisač dodajete sami iz _Print Settings_ u pokretaču aplikacija (`Super + Space`).

Odaberite _Add_ i pričekajte trenutak dok pretražuje: pisač priključen putem USB-a i većina mrežnih pisača pronađu se automatski. Ako vaš nije na popisu, odaberite _Network Printer > Internet Printing Protocol (ipp)_ i unesite njegovu adresu — zaslon samog pisača ili njegova web-stranica reći će vam koja je to adresa, obično nešto poput `192.168.1.50` s redom `ipp/print`. _Forward_ zatim nudi upravljački program, pri čemu moderni pisač najbolje radi na profilu _IPP Everywhere_ bez upravljačkog programa, a stariji želi vlastiti upravljački program modela.

Desnim klikom na pisač odaberite _Set as Default_ kako biste odredili koji će vaše aplikacije prvo koristiti, te _Properties_ za postavljanje veličine papira, obostranog ispisa i kvalitete.

Automatsko otkrivanje, pri kojem se pisači na mreži pojavljuju bez dodavanja, privremeno je isključeno dok se prerađuje, zbog čega je prvi korak gore vaš, a ne automatski. Ispis u PDF datoteku radi i bez ikakvog pisača.

### Kako promijeniti gdje se spremaju snimke zaslona ili snimanja zaslona?

Spremljene snimke zaslona prema zadanim postavkama idu u `~/Pictures/Screenshots`. Za korištenje drugog direktorija dodajte ovo u datoteku pod `~/.config/uwsm/env.d/` (poput `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Isto možete učiniti za snimanja zaslona koristeći `OMARCHY_SCREENRECORD_DIR`.

Omasnap automatski stvara svoj direktorij za snimke zaslona. Direktorij za snimanja zaslona stvorite sami, zatim ponovno pokrenite Omarchy kako bi bilo koja od promjena okruženja stupila na snagu.

### Kako natjerati zvučnike + web-kameru da rade na mom Apple Studio Displayu?

Pomislili biste da bi sve trebalo raditi samo priključivanjem USB C, ali nažalost to nije slučaj. Rješenje za koje sam utvrdio da pouzdano radi je korištenje [WJESOG DisplayPort + USB-A => USB-C kabela](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Tada zvučnici i web-kamera rade kao podmazano.

Imajte na umu da u Omarchyju imate ugrađenu kontrolu svjetline za Apple zaslone (i Studio i XDR) pomoću uobičajenih tipki za svjetlinu na tipkovnici.

### Kako se riješiti svog dodatnog softvera?

Ako ne želite programe poput Obsidiana ili LibreOfficea ili bilo koji drugi predinstalirani materijal, možete ga vrlo jednostavno ukloniti.

Pokrenite _Remove > Package_ kako biste vidjeli svaki instalirani paket. Zatim tipkom tab možete odabrati bilo koji paket koji želite ukloniti, a tipkom return započeti uklanjanje svega što ste odabrali.

A iz izbornika Omarchy možete koristiti _Remove > Web App_ za uklanjanje bilo koje predinstalirane web-aplikacije koju ne želite.

Ili pokrenite _Remove > Preinstalls_ kako biste odjednom počistili sve predinstalirane dodatke — web-aplikacije, TUI-je i opcionalne aplikacije. Prečaci koji su ih pokretali nestaju zajedno s njima, pa vam ostaje čista ploča poveznica koje možete ispuniti vlastitima u `~/.config/hypr/bindings.lua`.

---

Za pogreške i pokvarene dijelove pogledajte [odjeljak za rješavanje problema](45-troubleshooting.md).
