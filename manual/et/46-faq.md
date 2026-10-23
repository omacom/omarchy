# KKK

### Kuidas ma klaviatuuripaigutuste vahel lülitun?

Muuda oma faili `~/.config/hypr/input.lua` ja lisa see, et paigutuste vahel lülituda klahvikombinatsiooniga `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Riba näitab automaatselt sinu praegust klaviatuuripaigutust, kui sul on mitu paigutust seadistatud (ja sa saad lülitumiseks ka sellel klõpsata).

### Kuidas ma kellavormingu 12-tunniseks muudan?

Tee ribal kellal paremklõps, et levinud vormingute, sealhulgas 12-tunniste vahel liikuda. Vormingu saad seada ka otse:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

See kuvab Pühapäev 10:55 AM.

### Kuidas ma oma ajavööndit muudan?

Käivita Omarchy menüüs _Uuenda > Ajavöönd_ ja vali loendist. Kui ajavöönd on õige, aga kell ise on triivinud, taaskäivitab _Uuenda > Aeg_ sinu eest aja sünkroonimise.

### Kuidas ma muudan oma DNS-i, jagan oma Wi-Fit või kontrollin ühenduse kiirust?

Need kõik elavad jaotises [võrk](35-networking.md).

### Kuidas ma kontrollin, kui kiire mu ketas on?

_Käivita > Kiirustest > Kettakiiruse test_ mõõdab sinu ketta reaalajas lugemis- ja kirjutamiskiirust või terminalist `omarchy disk speedtest`.

### Miks ma ei saa Chromiumis oma Google'i kontole sisse logida?

Lihtne avatud lähtekoodiga Chromiumi järk ei sisalda OAuth mandaate, mida Google kontole sisselogimiseks nõuab. Käivita Omarchy menüüs _Paigalda > Teenus > Chromiumi konto_, et need lisada, taaskäivita brauser ja sisselogimine õnnestub.

### Kuidas ma printerit lisan?

Printimine on karbist võttes seadistatud ja töötab ning iga printeri lisad ise rakenduste käivitajast (`Super + Space`) jaotise _Prindiseaded_ kaudu.

Vali _Lisa_ ja anna sellele hetk otsida: USB kaudu ühendatud printer ja enamik võrguprintereid leitakse sinu eest. Kui sinu oma loendis pole, vali _Network Printer > Internet Printing Protocol (ipp)_ ja sisesta selle aadress — printeri oma ekraan või veebileht ütleb sulle, mis see on, tavaliselt midagi sellist nagu `192.168.1.50` järjekorraga `ipp/print`. _Edasi_ pakub seejärel draiverit, kus nüüdisaegne printer töötab kõige paremini draiverivaba _IPP Everywhere_ profiiliga ja vanem soovib mudeli oma draiverit.

Tee printeril paremklõps ja vali _Sea vaikimisi_, et valida, kumma poole sinu rakendused esimesena pöörduvad, ja _Atribuudid_, et seada paberisuurus, kahepoolne printimine ja kvaliteet.

Automaatne avastamine, kus võrguprinterid ilmuvad ilma lisamata, on selle ümbertöötamise ajaks ajutiselt välja lülitatud ja seepärast on esimene samm ülal sinu teha, mitte automaatne. PDF-faili printimine töötab ilma ühegi printerita.

### Kuidas ma muudan, kuhu ekraanitõmmised või ekraanisalvestused salvestatakse?

Salvestatud ekraanitõmmised lähevad vaikimisi kausta `~/Pictures/Screenshots`. Teise kausta kasutamiseks lisa see faili kausta `~/.config/uwsm/env.d/` all (nagu `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Sama saad teha ekraanisalvestuste puhul, kasutades muutujat `OMARCHY_SCREENRECORD_DIR`.

Omasnap loob oma ekraanitõmmiste kausta automaatselt. Loo ekraanisalvestuste kaust ise ja taaskäivita seejärel Omarchy, et kumbki keskkonnamuudatus jõustuks.

### Kuidas ma saan oma Apple Studio Displayl kõlarid + veebikaamera tööle?

Arvaks, et kõik peaks töötama lihtsalt USB C ühendamisega, aga kahjuks pole see nii. Lahendus, mille olen leidnud, et see usaldusväärselt töötaks, on [WJESOG DisplayPort + USB-A => USB-C kaabli](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/) kasutamine. Siis töötavad kõlarid ja veebikaamera nagu võluväel.

Pea meeles, et sul on Omarchys sisseehitatud heleduse juhtimine Apple'i ekraanidele (nii Studio kui ka XDR), kasutades tavalisi klaviatuuri heleduse nuppe.

### Kuidas ma kõigest lisatarkvarast lahti saan?

Kui sa ei taha programme nagu Obsidian või LibreOffice või muud eelpaigaldatud kraami, saad selle väga lihtsalt eemaldada.

Käivita _Eemalda > Pakett_, et näha iga paigaldatud paketti. Seejärel saad tab-klahviga valida iga paketi, mida tahad eemaldada, ja alustada kõige valitu eemaldamist sisestusklahviga.

Ja sa saad kasutada Omarchy menüüs jaotist _Eemalda > Veebirakendus_, et eemaldada kõik eelpaigaldatud veebirakendused, mida sa ei taha.

Või käivita _Eemalda > Eelpaigaldused_, et kõik eelpaigaldatud lisad — veebirakendused, TUI-d ja valikulised rakendused — ühe korraga välja pühkida. Kiirklahvid, mis neid käivitasid, kaovad koos nendega, nii et sulle jääb puhas leht klahviseoseid, mida failis `~/.config/hypr/bindings.lua` omadega täita.

---

Vigade ja katkiste tükkide kohta vaata [tõrkeotsingu jaotist](45-troubleshooting.md).
