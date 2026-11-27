# KKK

### Kuidas vahetada klaviatuuripaigutusi?

Muuda faili `~/.config/hypr/input.lua` ja lisa see, et vahetada paigutusi klahvidega `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Riba näitab automaatselt sinu praegust klaviatuuripaigutust, kui sul on seadistatud mitu paigutust (ja vahetamiseks saad sellel ka klõpsata).

### Kuidas muuta kella vorming 12-tunniseks?

Tee ribal kellal paremklõps, et liikuda läbi levinud vormingute, sealhulgas 12-tunniste. Vormingu saad määrata ka otse:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

See kuvab pühapäev 10:55 AM.

### Kuidas muuta ajavööndit?

Käivita Omarchy menüüs _Setup > Region > Timezone_ ja vali loendist. Kui ajavöönd on õige, aga kell ise on paigast ära, taaskäivitab _Update > Time_ sinu eest aja sünkroonimise.

### Kuidas muuta oma DNS-i, jagada Wi-Fi-t või kontrollida ühenduse kiirust?

Need kõik asuvad [võrgunduses](35-networking.md).

### Kuidas kontrollida, kui kiire on minu ketas?

_Trigger > Speed Test > Disk Speed Test_ mõõdab sinu ketta reaalajas lugemis- ja kirjutamiskiirust või terminalist `omarchy disk speedtest`.

### Kuidas lisada printerit?

Printimine on seadistatud ja töötab kohe karbist võttes ning iga printeri lisad sa ise rakenduste käivitaja _Print Settings_ kaudu (`Super + Alt + Space`).

Vali _Add_ ja anna sellele hetk otsimiseks: USB kaudu ühendatud printer ja enamik võrguprintereid leitakse sinu eest. Kui sinu oma loendis ei ole, vali _Network Printer > Internet Printing Protocol (ipp)_ ja sisesta selle aadress — printeri enda ekraan või selle veebileht ütleb sulle, mis see on, tavaliselt midagi sellist nagu `192.168.1.50` koos järjekorraga `ipp/print`. _Forward_ pakub seejärel draiverit, kus kaasaegne printer töötab kõige paremini draiverivaba profiiliga _IPP Everywhere_ ja vanem tahab mudeli enda draiverit.

Tee printeril paremklõps ja vali _Set as Default_, et määrata, kumma poole sinu rakendused esimesena pöörduvad, ja _Properties_, et määrata paberi suurus, kahepoolne printimine ja kvaliteet.

Automaatne avastamine, kus võrgus olevad printerid ilmuvad ilma lisamata, on ajutiselt välja lülitatud, kuni seda ümber tehakse, mistõttu on ülalolev esimene samm sinu teha, mitte automaatne. PDF-faili printimine töötab ilma ühegi printerita.

### Kuidas muuta, kuhu ekraanipildid või ekraanisalvestused salvestatakse?

Salvestatud ekraanipildid lähevad vaikimisi kausta `~/Pictures/Screenshots`. Teise kataloogi kasutamiseks lisa see faili kaustas `~/.config/uwsm/env.d/` (näiteks `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Samamoodi saad teha ekraanisalvestustega, kasutades muutujat `OMARCHY_SCREENRECORD_DIR`.

Omasnap loob oma ekraanipiltide kataloogi automaatselt. Ekraanisalvestuste kataloog loo ise, seejärel taaskäivita Omarchy, et kumbki keskkonnamuudatus jõustuks.

### Kuidas panna Apple Studio Display kõlarid + veebikaamera tööle?

Arvaks, et kõik peaks töötama lihtsalt USB C ühendamisega, aga kahjuks nii ei ole. Lahendus, mille olen leidnud, et see töötaks usaldusväärselt, on kasutada [WJESOG DisplayPort + USB-A => USB-C kaablit](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Siis töötavad kõlarid ja veebikaamera nagu võluväel.

Pea meeles, et Omarchy's on Apple'i ekraanidele (nii Studio kui ka XDR) sisseehitatud heleduse juhtimine tavaliste klaviatuuri heledusnuppudega.

### Kuidas vabaneda kogu lisatarkvarast?

Kui sa ei taha programme nagu Obsidian või LibreOffice või muud eelinstallitud kraami, saad selle väga lihtsalt eemaldada.

Käivita _Remove > Package_, et näha kõiki installitud pakette. Seejärel saad tab-klahviga valida iga paketi, mille soovid eemaldada, ja alustada kõige valitu eemaldamist return-klahviga.

Ja Omarchy menüüst saad kasutada valikut _Remove > Web App_, et eemaldada kõik eelinstallitud veebirakendused, mida sa ei taha.

Või käivita _Remove > Preinstalls_, et pühkida kõik eelinstallitud lisad — veebirakendused, TUI-d ja valikulised rakendused — ühe korraga minema. Kiirklahvid, mis neid käivitasid, kaovad koos nendega, nii et sulle jääb puhas leht seoseid, mille saad täita enda omadega failis `~/.config/hypr/bindings.lua`.

---

Vigade ja katki läinud asjade kohta vaata [tõrkeotsingu jaotist](45-troubleshooting.md).
