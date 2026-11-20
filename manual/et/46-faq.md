# KKK

### Kuidas vahetada klaviatuuripaigutusi?

Muuda oma `~/.config/hypr/input.lua` faili ja lisa see, et vahetada paigutusi klahvidega `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Riba näitab automaatselt sinu praegust klaviatuuripaigutust, kui sul on seadistatud mitu paigutust (ja sa saad selle vahetamiseks ka sellel klõpsata).

### Kuidas muuta kella vorming 12-tunniseks?

Paremklõpsa ribal oleval kellal, et liikuda läbi levinumate vormingute, sealhulgas 12-tunniste vormingute. Vormingu saad määrata ka otse:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

See kuvab pühapäev 10:55 AM.

### Kuidas muuta oma ajavööndit?

Käivita Omarchy menüüs _Setup > Region > Timezone_ ja vali loendist sobiv. Kui ajavöönd on õige, aga kell ise on paigast ära läinud, käivitab _Update > Time_ sinu eest ajasünkroonimise uuesti.

### Kuidas muuta oma DNS-i, jagada oma Wi-Fi-t või kontrollida oma ühenduse kiirust?

Need kõik asuvad [võrgunduse](35-networking.md) all.

### Kuidas kontrollida, kui kiire mu ketas on?

_Trigger > Speed Test > Disk Speed Test_ mõõdab sinu ketta reaalajas lugemis- ja kirjutamiskiirust või kasuta terminalist käsku `omarchy disk speedtest`.

### Kuidas lisada printerit?

Printimine on seadistatud ja töötab kohe karbist võttes ning iga printeri lisad sa ise rakenduste käivitajast (`Super + Space`) valiku _Print Settings_ kaudu.

Vali _Add_ ja anna sellele hetk otsimiseks: USB kaudu ühendatud printer ja enamik võrguprintereid leitakse sinu eest üles. Kui sinu oma loendis pole, vali _Network Printer > Internet Printing Protocol (ipp)_ ja sisesta selle aadress — printeri enda ekraan või selle veebileht ütleb sulle, mis see on, tavaliselt midagi sellist nagu `192.168.1.50`, mille järjekord on `ipp/print`. Seejärel pakub _Forward_ draiverit, kus tänapäevane printer töötab kõige paremini draiverita profiiliga _IPP Everywhere_ ja vanem tahab mudeli enda draiverit.

Paremklõpsa printeril ja vali _Set as Default_, et määrata, kumba sinu rakendused esimesena kasutavad, ning _Properties_, et määrata paberiformaat, kahepoolne printimine ja kvaliteet.

Automaatne tuvastamine, kus võrgus olevad printerid ilmuvad ilma lisamata, on ajutiselt välja lülitatud, kuni seda ümber tehakse, mistõttu on ülalolev esimene samm sinu teha, mitte automaatne. PDF-faili printimine töötab ka ilma igasuguse printerita.

### Kuidas muuta kohta, kuhu ekraanipildid või ekraanisalvestused salvestatakse?

Salvestatud ekraanipildid lähevad vaikimisi kausta `~/Pictures/Screenshots`. Teise kataloogi kasutamiseks lisa see faili kaustas `~/.config/uwsm/env.d/` (näiteks `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Sama saad teha ka ekraanisalvestustega, kasutades muutujat `OMARCHY_SCREENRECORD_DIR`.

Omasnap loob oma ekraanipiltide kataloogi automaatselt. Loo ekraanisalvestuste kataloog ise, seejärel taaskäivita Omarchy, et kumbki keskkonnamuudatus jõustuks.

### Kuidas panna Apple Studio Display kõlarid ja veebikaamera tööle?

Arvaksid, et kõik peaks töötama lihtsalt USB C ühendamisega, aga kahjuks see nii ei ole. Lahendus, mille olen leidnud selle usaldusväärseks tööle saamiseks, on kasutada [WJESOG DisplayPort + USB-A => USB-C kaablit](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Siis töötavad kõlarid ja veebikaamera nagu võluväel.

Pea meeles, et sul on Omarchy's Apple ekraanide (nii Studio kui ka XDR) jaoks sisseehitatud heleduse juhtimine tavaliste klaviatuuri heledusnuppude abil.

### Kuidas vabaneda kogu lisatarkvarast?

Kui sa ei taha selliseid programme nagu Obsidian või LibreOffice või muud eelinstallitud kraami, saad selle väga lihtsalt eemaldada.

Käivita _Remove > Package_, et näha kõiki installitud pakette. Seejärel saad klahviga tab valida iga paketi, mille soovid eemaldada, ja alustada kõigi valitud pakettide eemaldamist klahviga return.

Ja sa saad kasutada Omarchy menüüst valikut _Remove > Web App_, et eemaldada eelinstallitud veebirakendused, mida sa ei taha.

Või käivita _Remove > Preinstalls_, et pühkida ühe korraga välja kõik eelinstallitud lisad — veebirakendused, TUI-d ja valikulised rakendused. Kiirklahvid, mis neid käivitasid, kaovad koos nendega, nii et sulle jääb puhas leht sidumisi, mille saad täita enda omadega failis `~/.config/hypr/bindings.lua`.

---

Vigade ja katkiste kohtade kohta vaata [tõrkeotsingu jaotust](45-troubleshooting.md).
