# KKK

### Kuidas vahetada klaviatuuripaigutusi?

Muuda oma faili `~/.config/hypr/input.lua` ja lisa see, et vahetada paigutusi klahvidega `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Riba näitab automaatselt sinu praegust klaviatuuripaigutust, kui sul on seadistatud mitu paigutust (ja saad sellele ka klõpsata, et vahetada).

### Kuidas muuta kella vorming 12-tunniseks?

Paremklõpsa ribal kellal, et liikuda läbi levinud vormingute, sealhulgas 12-tunniste vormingute. Vormingu saab määrata ka otse:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

See kuvab pühapäev 10:55 AM.

### Kuidas muuta oma ajavööndit?

Käivita Omarchy menüüs _Uuenda > Ajavöönd_ ja vali loendist. Kui ajavöönd on õige, kuid kell ise on paigast nihkunud, käivitab _Uuenda > Kellaaeg_ sinu eest aja sünkroonimise uuesti.

### Kuidas muuta oma DNS-i, jagada oma Wi-Fi-t või kontrollida ühenduse kiirust?

Need kõik asuvad jaotises [võrgundus](35-networking.md).

### Kuidas kontrollida, kui kiire mu ketas on?

_Käivita > Kiirustest > Ketta kiirustest_ mõõdab sinu ketta reaalajas lugemis- ja kirjutamiskiirust, või terminalist `omarchy disk speedtest`.

### Kuidas lisada printerit?

Printimine on seadistatud ja töötab kohe karbist võttes ning iga printeri lisad ise rakenduste käivitajas (`Super + Space`) asuvast jaotisest _Prindiseaded_.

Vali _Lisa_ ja anna sellele otsimiseks hetk aega: USB kaudu ühendatud printer ja enamik võrguprintereid leitakse sinu eest üles. Kui sinu oma loendis pole, vali _Võrguprinter > Internet Printing Protocol (ipp)_ ja sisesta selle aadress — printeri enda ekraan või selle veebileht ütleb sulle, mis see on, tavaliselt midagi sellist nagu `192.168.1.50` koos järjekorraga `ipp/print`. Seejärel pakub _Edasi_ draiverit, kus tänapäevane printer töötab kõige paremini draiverivaba profiiliga _IPP Everywhere_ ja vanem tahab mudeli enda draiverit.

Paremklõpsa printeril ja vali _Määra vaikeprinteriks_, et määrata, kumba sinu rakendused esimesena kasutavad, ning _Omadused_, et määrata paberi suurus, kahepoolne printimine ja kvaliteet.

Automaatne tuvastamine, kus võrgus olevad printerid ilmuvad ilma neid lisamata, on ajutiselt välja lülitatud, kuni seda ümber tehakse, mistõttu on ülaltoodud esimene samm sinu teha, mitte automaatne. PDF-faili printimine töötab üldse ilma ühegi printerita.

### Kuidas muuta kohta, kuhu ekraanipildid või ekraanisalvestused salvestatakse?

Salvestatud ekraanipildid lähevad vaikimisi kausta `~/Pictures/Screenshots`. Teise kausta kasutamiseks lisa see faili kaustas `~/.config/uwsm/env.d/` (näiteks `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Sama saad teha ekraanisalvestuste jaoks, kasutades muutujat `OMARCHY_SCREENRECORD_DIR`.

Omasnap loob oma ekraanipiltide kausta automaatselt. Loo ekraanisalvestuste kaust ise ja seejärel taaskäivita Omarchy, et kumbki keskkonnamuudatus jõustuks.

### Kuidas panna Apple Studio Display kõlarid ja veebikaamera tööle?

Võiks arvata, et kõik peaks töötama lihtsalt USB C ühendamisega, kuid kahjuks see nii ei ole. Lahendus, mille leidsin selle usaldusväärseks toimimiseks, on kasutada [WJESOG DisplayPort + USB-A => USB-C kaablit](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Seejärel töötavad kõlarid ja veebikaamera nagu õlitatult.

Pea meeles, et Omarchys on Apple'i ekraanide (nii Studio kui ka XDR) jaoks sisseehitatud heleduse juhtimine tavaliste klaviatuuri heledusklahvide abil.

### Kuidas vabaneda kogu lisatarkvarast?

Kui sa ei taha selliseid programme nagu Obsidian või LibreOffice ega muud eelinstallitud kraami, saad selle väga lihtsalt eemaldada.

Käivita _Eemalda > Pakett_, et näha iga installitud paketti. Seejärel saad klahviga tab valida iga paketi, mille soovid eemaldada, ja alustada kõige valitu eemaldamist klahviga return.

Ja saad kasutada Omarchy menüüs valikut _Eemalda > Veebirakendus_, et eemaldada kõik eelinstallitud veebirakendused, mida sa ei taha.

Või käivita _Eemalda > Eelinstallitud_, et pühkida kõik eelinstallitud lisad — veebirakendused, TUI-d ja valikulised rakendused — ühe korraga välja. Neid käivitanud kiirklahvid kaovad koos nendega, nii et sulle jääb puhas leht sidumisi, mille saad täita enda omadega failis `~/.config/hypr/bindings.lua`.

---

Vigade ja katkiste asjade kohta vaata [tõrkeotsingu jaotist](45-troubleshooting.md).
