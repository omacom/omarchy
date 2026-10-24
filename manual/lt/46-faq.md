# DUK

### Kaip persijungti tarp klaviatūros išdėstymų?

Redaguok savo `~/.config/hypr/input.lua` failą ir pridėk tai, kad persijungtum tarp išdėstymų su `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Juosta automatiškai rodys tavo dabartinį klaviatūros išdėstymą, kai turėsi sukonfigūruotų kelis išdėstymus (ir gali ją spustelėti, kad persijungtum).

### Kaip pakeisti laikrodžio formatą į 12 valandų?

Dešiniuoju pelės klavišu spustelėk laikrodį juostoje, kad pereitum per įprastus formatus, įskaitant 12 valandų. Formatą taip pat gali nustatyti tiesiogiai:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Tai rodys Sunday 10:55 AM.

### Kaip pakeisti laiko juostą?

Omarchy meniu paleisk _Atnaujinti > Laiko juosta_ ir pasirink iš sąrašo. Jei laiko juosta teisinga, bet pats laikrodis nukrypo, _Atnaujinti > Laikas_ tau iš naujo paleidžia laiko sinchronizaciją.

### Kaip pakeisti DNS, pasidalyti Wi-Fi ar patikrinti ryšio greitį?

Visa tai gyvena [tinkle](35-networking.md).

### Kaip patikrinti, kaip greitas mano diskas?

_Veiksmai > Greitis > Disko greičio testas_ pamatuoja gyvą skaitymo ir rašymo greitį tavo diske, arba `omarchy disk speedtest` terminale.

### Kodėl Chromium negaliu prisijungti prie Google paskyros?

Paprastas atvirojo kodo Chromium build nepateikiamas su OAuth kredencialais, kurių Google reikalauja paskyros prisijungimui. Omarchy meniu paleisk _Įdiegti > Paslauga > Chromium paskyra_, kad juos pridėtum, perkrauk naršyklę ir prisijungimas pavyks.

### Kaip pridėti spausdintuvą?

Spausdinimas nustatytas ir veikia iš karto, o kiekvieną spausdintuvą pats pridedi iš _Print Settings_ programų paleidyklėje (`Super + Space`).

Pasirink _Add_ ir duok jam akimirką paieškoti: per USB prijungtas spausdintuvas ir dauguma tinklo spausdintuvų randami už tave. Jei tavo sąraše nėra, pasirink _Network Printer > Internet Printing Protocol (ipp)_ ir įvesk jo adresą — paties spausdintuvo ekranas ar jo tinklalapis pasakys, koks jis, paprastai kažkas panašaus į `192.168.1.50` su eile `ipp/print`. _Forward_ tada pasiūlo tvarkyklę, kur šiuolaikinis spausdintuvas geriausiai veikia su be tvarkyklės profiliu _IPP Everywhere_, o senesnis nori modelio nuosavos tvarkyklės.

Dešiniuoju pelės klavišu spustelėk spausdintuvą ir pasirink _Set as Default_, kad parinktum, kurio tavo programos sieks pirmiausia, ir _Properties_, kad nustatytum popieriaus dydį, dvipusį spausdinimą ir kokybę.

Automatinis aptikimas, kai tinklo spausdintuvai atsiranda jų nepridėjus, laikinai išjungtas, kol jis perdaromas, todėl pirmasis žingsnis aukščiau yra tavo, o ne automatinis. Spausdinimas į PDF failą veikia visiškai be spausdintuvo.

### Kaip pakeisti, kur išsaugomos ekrano nuotraukos ar ekrano įrašai?

Išsaugotos ekrano nuotraukos pagal numatytuosius eina į `~/Pictures/Screenshots`. Kad naudotum kitą katalogą, pridėk tai į failą po `~/.config/uwsm/env.d/` (pavyzdžiui, `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Tą patį ekrano įrašams gali padaryti naudodamas `OMARCHY_SCREENRECORD_DIR`.

Omasnap savo ekrano nuotraukų katalogą sukuria automatiškai. Ekrano įrašų katalogą sukurk pats, tada perkrauk Omarchy, kad bet kuris aplinkos pakeitimas įsigaliotų.

### Kaip priversti veikti garsiakalbius + kamerą mano Apple Studio Display?

Manytum, kad viskas turėtų veikti tiesiog prijungus USB C, bet, deja, taip nėra. Sprendimas, kurį radau, kad veiktų patikimai, yra [WJESOG DisplayPort + USB-A => USB-C kabelis](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Tada garsiakalbiai ir kamera veikia kaip iš pypkės.

Atmink, kad Omarchy turi įmontuotą Apple ekranų (tiek Studio, tiek XDR) ryškumo valdymą įprastais klaviatūros ryškumo mygtukais.

### Kaip atsikratyti visos papildomos programinės įrangos?

Jei nenori programų, tokių kaip Obsidian ar LibreOffice, ar bet kurio kito iš anksto įdiegto dalyko, gali jas labai lengvai pašalinti.

Paleisk _Pašalinti > Paketas_, kad pamatytum kiekvieną įdiegtą paketą. Tada su tab gali pasirinkti bet kurį paketą, kurį norėtum pašalinti, ir su return pradėti šalinti viską, ką pasirinkai.

O iš Omarchy meniu gali naudoti _Pašalinti > Žiniatinklio programa_, kad pašalintum bet kurią iš iš anksto įdiegtų žiniatinklio programų, kurių nenori.

Arba paleisk _Pašalinti > Išankstiniai_, kad vienu kartu iššluotum visas iš anksto įdiegtas papildomas — žiniatinklio programas, TUI ir pasirinktines programas. Spartieji klavišai, kurie jas paleisdavo, išnyksta kartu su jomis, todėl tau lieka švarus surišimų lapas, kurį gali užpildyti savais `~/.config/hypr/bindings.lua`.

---

Dėl klaidų ir sugedusių dalių žr. [Trikčių šalinimo skyrių](45-troubleshooting.md).
