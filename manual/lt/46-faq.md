# DUK

### Kaip perjungti klaviatūros išdėstymus?

Redaguokite savo `~/.config/hypr/input.lua` failą ir pridėkite tai, kad galėtumėte perjungti išdėstymus paspausdami `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Juosta automatiškai parodys jūsų dabartinį klaviatūros išdėstymą, kai būsite sukonfigūravę kelis išdėstymus (ir jį spustelėję taip pat galėsite perjungti).

### Kaip pakeisti laikrodžio formatą į 12 valandų?

Dešiniuoju pelės mygtuku spustelėkite laikrodį juostoje, kad pereitumėte per įprastus formatus, įskaitant 12 valandų formatus. Formatą taip pat galite nustatyti tiesiogiai:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Tai rodys Sekmadienis 10:55 AM.

### Kaip pakeisti savo laiko juostą?

Omarchy meniu paleiskite _Setup > Region > Timezone_ ir pasirinkite iš sąrašo. Jei laiko juosta teisinga, bet pats laikrodis nukrypo, _Update > Time_ už jus iš naujo paleis laiko sinchronizavimą.

### Kaip pakeisti savo DNS, bendrinti savo Wi-Fi arba patikrinti savo ryšio greitį?

Visa tai rasite [tinklo nustatymuose](35-networking.md).

### Kaip patikrinti, kaip greitas mano diskas?

_Trigger > Speed Test > Disk Speed Test_ matuoja tiesioginį skaitymo ir rašymo greitį jūsų diske, arba terminale naudokite `omarchy disk speedtest`.

### Kaip pridėti spausdintuvą?

Spausdinimas yra nustatytas ir veikia iš karto, o kiekvieną spausdintuvą pridedate patys iš _Print Settings_ programų paleidyklėje (`Super + Alt + Space`).

Pasirinkite _Add_ ir skirkite akimirką paieškai: per USB prijungtas spausdintuvas ir dauguma tinklo spausdintuvų randami už jus. Jei jūsiškio sąraše nėra, pasirinkite _Network Printer > Internet Printing Protocol (ipp)_ ir įveskite jo adresą — jį pasakys paties spausdintuvo ekranas arba jo tinklalapis, paprastai kažkas panašaus į `192.168.1.50` su eile `ipp/print`. Tada _Forward_ pasiūlys tvarkyklę, kur šiuolaikinis spausdintuvas geriausiai veikia su be tvarkyklės veikiančiu _IPP Everywhere_ profiliu, o senesnis nori savo modelio tvarkyklės.

Dešiniuoju pelės mygtuku spustelėkite spausdintuvą ir pasirinkite _Set as Default_, kad pasirinktumėte, kurį jūsų programos naudos pirmiausia, ir _Properties_, kad nustatytumėte popieriaus dydį, dvipusį spausdinimą ir kokybę.

Automatinis aptikimas, kai tinklo spausdintuvai pasirodo jų nepridėjus, laikinai išjungtas, kol jis pertvarkomas, todėl pirmasis veiksmas aukščiau yra jūsų, o ne automatinis. Spausdinti į PDF failą galima ir visai neturint spausdintuvo.

### Kaip pakeisti, kur išsaugomos ekrano kopijos arba ekrano įrašai?

Išsaugotos ekrano kopijos pagal numatytuosius nustatymus keliauja į `~/Pictures/Screenshots`. Norėdami naudoti kitą katalogą, įdėkite tai į failą kataloge `~/.config/uwsm/env.d/` (pvz., `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

Tą patį galite padaryti ekrano įrašams naudodami `OMARCHY_SCREENRECORD_DIR`.

Omasnap automatiškai sukuria savo ekrano kopijų katalogą. Ekrano įrašų katalogą susikurkite patys, tada iš naujo paleiskite Omarchy, kad bet kuris aplinkos pakeitimas įsigaliotų.

### Kaip priversti veikti garsiakalbius ir internetinę kamerą mano Apple Studio Display?

Galėtumėte pagalvoti, kad viskas turėtų veikti tiesiog prijungus USB C, bet, deja, taip nėra. Sprendimas, kurį radau, kad tai veiktų patikimai, yra naudoti [WJESOG DisplayPort + USB-A => USB-C kabelį](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Tada garsiakalbiai ir internetinė kamera veikia puikiai.

Atminkite, kad Omarchy turite integruotą Apple ekranų (tiek Studio, tiek XDR) ryškumo valdymą įprastais klaviatūros ryškumo mygtukais.

### Kaip atsikratyti visos papildomos programinės įrangos?

Jei nenorite tokių programų kaip Obsidian ar LibreOffice ar bet kurios kitos iš anksto įdiegtos įrangos, galite ją labai lengvai pašalinti.

Paleiskite _Remove > Package_, kad pamatytumėte kiekvieną įdiegtą paketą. Tada galite pasirinkti bet kurį paketą, kurį norite pašalinti, paspausdami tab, ir pradėti šalinti viską, ką pasirinkote, paspausdami return.

Be to, galite naudoti _Remove > Web App_ iš Omarchy meniu, kad pašalintumėte bet kurias iš anksto įdiegtas žiniatinklio programas, kurių nenorite.

Arba paleiskite _Remove > Preinstalls_, kad vienu ypu iššluotumėte visus iš anksto įdiegtus priedus — žiniatinklio programas, TUI ir pasirenkamas programas. Jas paleidę spartieji klavišai dingsta kartu su jomis, todėl liekate su tuščia susiejimų lenta, kurią galite užpildyti savaisiais faile `~/.config/hypr/bindings.lua`.

---

Dėl klaidų ir neveikiančių dalykų žr. [Trikčių šalinimo skyrių](45-troubleshooting.md).
