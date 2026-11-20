# DUK

### Kaip perjungti klaviatūros išdėstymus?

Redaguokite failą `~/.config/hypr/input.lua` ir pridėkite tai, kad išdėstymus perjungtumėte su `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Juosta automatiškai rodys jūsų dabartinį klaviatūros išdėstymą, kai būsite sukonfigūravę kelis išdėstymus (ir taip pat galėsite ją spustelėti, kad perjungtumėte).

### Kaip pakeisti laikrodžio formatą į 12 valandų?

Dešiniuoju pelės mygtuku spustelėkite laikrodį juostoje, kad pereitumėte per įprastus formatus, įskaitant 12 valandų formatus. Formatą taip pat galite nustatyti tiesiogiai:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Bus rodoma Sekmadienis 10:55 AM.

### Kaip pakeisti laiko juostą?

Omarchy meniu paleiskite _Setup > Region > Timezone_ ir pasirinkite iš sąrašo. Jei laiko juosta teisinga, bet pats laikrodis paslydo, _Update > Time_ už jus iš naujo paleis laiko sinchronizavimą.

### Kaip pakeisti DNS, bendrinti Wi-Fi arba patikrinti ryšio greitį?

Visa tai rasite [tinklo nustatymuose](35-networking.md).

### Kaip patikrinti, koks greitas mano diskas?

_Trigger > Speed Test > Disk Speed Test_ matuoja tiesioginį skaitymo ir rašymo greitį jūsų diske, arba `omarchy disk speedtest` iš terminalo.

### Kaip pridėti spausdintuvą?

Spausdinimas nustatytas ir veikia iš karto, o kiekvieną spausdintuvą pridedate patys iš _Print Settings_ programų paleidyklėje (`Super + Space`).

Pasirinkite _Add_ ir skirkite akimirką paieškai: per USB prijungtas spausdintuvas ir dauguma tinklo spausdintuvų randami už jus. Jei jūsų spausdintuvo sąraše nėra, pasirinkite _Network Printer > Internet Printing Protocol (ipp)_ ir įveskite jo adresą — spausdintuvo ekranas arba jo tinklalapis pasakys, koks jis yra, paprastai kažkas panašaus į `192.168.1.50` su eile `ipp/print`. Tada _Forward_ pasiūlys tvarkyklę, kur šiuolaikiniam spausdintuvui geriausiai tinka be tvarkyklės veikiantis _IPP Everywhere_ profilis, o senesniam reikia paties modelio tvarkyklės.

Dešiniuoju pelės mygtuku spustelėkite spausdintuvą ir pasirinkite _Set as Default_, kad nustatytumėte, kurį jūsų programos pasiekia pirmiausia, bei _Properties_, kad nustatytumėte popieriaus dydį, dvipusį spausdinimą ir kokybę.

Automatinis aptikimas, kai tinkle esantys spausdintuvai pasirodo nepridėti, laikinai išjungtas, kol yra perdaromas, todėl pirmasis veiksmas aukščiau yra jūsų, o ne automatinis. Spausdinti į PDF failą galima be jokio spausdintuvo.

### Kaip pakeisti, kur išsaugomos ekrano nuotraukos ar ekrano įrašai?

Išsaugotos ekrano nuotraukos pagal numatytuosius nustatymus keliauja į `~/Pictures/Screenshots`. Norėdami naudoti kitą katalogą, pridėkite tai į failą kataloge `~/.config/uwsm/env.d/` (pavyzdžiui, `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Tą patį galite padaryti ekrano įrašams naudodami `OMARCHY_SCREENRECORD_DIR`.

Omasnap savo ekrano nuotraukų katalogą sukuria automatiškai. Ekrano įrašų katalogą susikurkite patys, tada iš naujo paleiskite Omarchy, kad įsigaliotų bet kuris aplinkos pakeitimas.

### Kaip priversti veikti garsiakalbius + internetinę kamerą mano Apple Studio Display?

Galvotumėte, kad viskas turėtų veikti tiesiog prijungus USB C, bet, deja, taip nėra. Sprendimas, kurį radau, kad veiktų patikimai, yra naudoti [WJESOG DisplayPort + USB-A => USB-C kabelį](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Tuomet garsiakalbiai ir internetinė kamera veikia puikiai.

Atminkite, kad Omarchy turi įtaisytą Apple Displays (tiek Studio, tiek XDR) ryškumo valdymą įprastais klaviatūros ryškumo mygtukais.

### Kaip atsikratyti visos papildomos programinės įrangos?

Jei nenorite programų, tokių kaip Obsidian ar LibreOffice, ar bet kurios kitos iš anksto įdiegtos įrangos, galite ją labai lengvai pašalinti.

Paleiskite _Remove > Package_, kad pamatytumėte kiekvieną įdiegtą paketą. Tada galite pasirinkti bet kurį norimą pašalinti paketą naudodami tab ir pradėti šalinti viską, ką pasirinkote, naudodami return.

Taip pat galite naudoti _Remove > Web App_ iš Omarchy meniu, kad pašalintumėte bet kurias iš anksto įdiegtas žiniatinklio programas, kurių nenorite.

Arba paleiskite _Remove > Preinstalls_, kad vienu ypu iššluotumėte visus iš anksto įdiegtus priedus — žiniatinklio programas, TUI ir pasirenkamas programas. Jas paleisdavę spartieji klavišai dingsta kartu su jomis, todėl liekate su švaria susiejimų lentele, kurią galite užpildyti savaisiais `~/.config/hypr/bindings.lua`.

---

Dėl klaidų ir neveikiančių dalykų žr. [gedimų šalinimo skyrių](45-troubleshooting.md).
