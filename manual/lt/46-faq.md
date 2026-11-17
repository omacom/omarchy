# DUK

### Kaip perjungti klaviatūros išdėstymus?

Redaguokite failą `~/.config/hypr/input.lua` ir pridėkite šį kodą, kad išdėstymus perjungtumėte paspaudę `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Juosta automatiškai rodys dabartinį klaviatūros išdėstymą, kai būsite sukonfigūravę kelis išdėstymus (ir jį spustelėję taip pat galėsite juos perjungti).

### Kaip pakeisti laikrodžio formatą į 12 valandų?

Dešiniuoju pelės mygtuku spustelėkite laikrodį juostoje, kad perjungtumėte įprastus formatus, įskaitant 12 valandų. Formatą taip pat galite nustatyti tiesiogiai:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Bus rodoma Sekmadienis 10:55 AM.

### Kaip pakeisti laiko juostą?

Omarchy meniu paleiskite _Update > Timezone_ ir pasirinkite iš sąrašo. Jei laiko juosta teisinga, bet pats laikrodis nukrypo, _Update > Time_ už jus iš naujo paleis laiko sinchronizavimą.

### Kaip pakeisti DNS, bendrinti Wi-Fi arba patikrinti ryšio greitį?

Visa tai rasite skyriuje [tinklas](35-networking.md).

### Kaip patikrinti, koks greitas mano diskas?

_Trigger > Speed Test > Disk Speed Test_ matuoja tiesioginį skaitymo ir rašymo greitį jūsų diske, arba terminale paleiskite `omarchy disk speedtest`.

### Kaip pridėti spausdintuvą?

Spausdinimas paruoštas ir veikia iš karto, o kiekvieną spausdintuvą pridedate patys iš _Print Settings_ programų paleidyklėje (`Super + Space`).

Pasirinkite _Add_ ir skirkite akimirką paieškai: per USB prijungtas spausdintuvas ir dauguma tinklo spausdintuvų randami už jus. Jei jūsų spausdintuvo sąraše nėra, pasirinkite _Network Printer > Internet Printing Protocol (ipp)_ ir įveskite jo adresą — jį nurodys paties spausdintuvo ekranas arba jo tinklalapis, paprastai tai kažkas panašaus į `192.168.1.50` su eile `ipp/print`. Tada _Forward_ pasiūlys tvarkyklę: modernus spausdintuvas geriausiai veikia su profiliu be tvarkyklės _IPP Everywhere_, o senesniam reikia paties modelio tvarkyklės.

Dešiniuoju pelės mygtuku spustelėkite spausdintuvą ir pasirinkite _Set as Default_, kad nurodytumėte, kurį jūsų programos naudos pirmiausia, o _Properties_ — kad nustatytumėte popieriaus dydį, dvipusį spausdinimą ir kokybę.

Automatinis aptikimas, kai tinkle esantys spausdintuvai atsiranda jų nepridėjus, laikinai išjungtas, kol jis pertvarkomas, todėl pirmasis žingsnis aukščiau yra jūsų, o ne automatinis. Spausdinti į PDF failą galima apskritai be jokio spausdintuvo.

### Kaip pakeisti, kur išsaugomos ekrano nuotraukos arba ekrano įrašai?

Išsaugotos ekrano nuotraukos pagal numatytuosius nustatymus keliauja į `~/Pictures/Screenshots`. Norėdami naudoti kitą katalogą, pridėkite tai į failą kataloge `~/.config/uwsm/env.d/` (pavyzdžiui, `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Tą patį ekrano įrašams galite padaryti naudodami `OMARCHY_SCREENRECORD_DIR`.

Omasnap automatiškai sukuria savo ekrano nuotraukų katalogą. Ekrano įrašų katalogą sukurkite patys, tada iš naujo paleiskite Omarchy, kad bet kuris iš šių aplinkos pakeitimų įsigaliotų.

### Kaip priversti veikti garsiakalbius + internetinę kamerą mano Apple Studio Display?

Galvotumėte, kad viskas turėtų veikti tiesiog prijungus USB C, bet, deja, taip nėra. Sprendimas, kurį radau, kad viskas veiktų patikimai, yra naudoti [WJESOG DisplayPort + USB-A => USB-C kabelį](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Tada garsiakalbiai ir internetinė kamera veikia puikiai.

Atminkite, kad Omarchy turi integruotą Apple Displays (tiek Studio, tiek XDR) ryškumo valdymą įprastais klaviatūros ryškumo mygtukais.

### Kaip atsikratyti visos papildomos programinės įrangos?

Jei nenorite programų, tokių kaip Obsidian ar LibreOffice, ar bet kurios kitos iš anksto įdiegtos programinės įrangos, galite ją labai lengvai pašalinti.

Paleiskite _Remove > Package_, kad pamatytumėte kiekvieną įdiegtą paketą. Tada klavišu tab galite pasirinkti bet kurį paketą, kurį norite pašalinti, o klavišu return pradėti šalinti viską, ką pasirinkote.

O iš Omarchy meniu galite naudoti _Remove > Web App_, kad pašalintumėte bet kurias iš anksto įdiegtas žiniatinklio programas, kurių nenorite.

Arba paleiskite _Remove > Preinstalls_, kad vienu ypu iššluotumėte visus iš anksto įdiegtus priedus — žiniatinklio programas, TUI ir pasirenkamas programas. Juos paleidę spartieji klavišai dingsta kartu su jais, todėl liekate su švaria susiejimų lentele, kurią galėsite užpildyti savais susiejimais faile `~/.config/hypr/bindings.lua`.

---

Dėl klaidų ir neveikiančių dalykų žr. [gedimų šalinimo skyrių](45-troubleshooting.md).
