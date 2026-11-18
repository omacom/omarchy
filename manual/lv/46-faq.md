# Biežāk uzdotie jautājumi

### Kā pārslēgties starp tastatūras izkārtojumiem?

Rediģē savu `~/.config/hypr/input.lua` failu un pievieno šo, lai pārslēgtos starp izkārtojumiem ar `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Josla automātiski parādīs tavu pašreizējo tastatūras izkārtojumu, tiklīdz tev būs konfigurēti vairāki izkārtojumi (un tu vari arī noklikšķināt uz tā, lai pārslēgtos).

### Kā nomainīt pulksteņa formātu uz 12 stundu?

Ar labo pogu noklikšķini uz pulksteņa joslā, lai pārslēgtos starp izplatītākajiem formātiem, tostarp 12 stundu formātiem. Formātu vari iestatīt arī tieši:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Tādējādi tiks parādīts Svētdiena 10:55 AM.

### Kā nomainīt savu laika joslu?

Omarchy izvēlnē palaid _Update > Timezone_ un izvēlies no saraksta. Ja laika josla ir pareiza, bet pats pulkstenis ir novirzījies, _Update > Time_ restartēs laika sinhronizāciju tavā vietā.

### Kā nomainīt savu DNS, kopīgot savu Wi-Fi vai pārbaudīt sava savienojuma ātrumu?

Tas viss atrodams sadaļā [tīklošana](35-networking.md).

### Kā pārbaudīt, cik ātrs ir mans disks?

_Trigger > Speed Test > Disk Speed Test_ mēra reāllaika lasīšanas un rakstīšanas ātrumu tavā diskā, vai arī `omarchy disk speedtest` no termināļa.

### Kā pievienot printeri?

Drukāšana ir iestatīta un darbojas uzreiz pēc instalēšanas, un katru printeri tu pievieno pats no _Print Settings_ lietotņu palaišanas programmā (`Super + Space`).

Izvēlies _Add_ un uzgaidi brīdi, kamēr tas meklē: pa USB pievienots printeris un lielākā daļa tīkla printeru tiek atrasti tavā vietā. Ja tavējā sarakstā nav, izvēlies _Network Printer > Internet Printing Protocol (ipp)_ un ievadi tā adresi — printera paša displejs vai tā tīmekļa lapa pateiks tev, kāda tā ir, parasti kaut kas līdzīgs `192.168.1.50` ar rindu `ipp/print`. Pēc tam _Forward_ piedāvā draiveri, kur modernam printerim vislabāk der bezdraivera _IPP Everywhere_ profils, bet vecākam vajag paša modeļa draiveri.

Ar labo pogu noklikšķini uz printera un izvēlies _Set as Default_, lai norādītu, kuru tavas lietotnes izmanto pirmo, un _Properties_, lai iestatītu papīra izmēru, abpusēju drukāšanu un kvalitāti.

Automātiskā atklāšana, kad tīklā esošie printeri parādās, nebūdami pievienoti, uz laiku ir izslēgta, kamēr tā tiek pārstrādāta, tāpēc pirmais solis augstāk ir jādara tev, nevis automātiski. Drukāšana PDF failā darbojas arī bez jebkāda printera.

### Kā nomainīt, kur tiek saglabāti ekrānuzņēmumi vai ekrāna ieraksti?

Saglabātie ekrānuzņēmumi pēc noklusējuma nonāk `~/Pictures/Screenshots`. Lai izmantotu citu direktoriju, pievieno šo failam mapē `~/.config/uwsm/env.d/` (piemēram, `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

To pašu vari izdarīt ekrāna ierakstiem, izmantojot `OMARCHY_SCREENRECORD_DIR`.

Omasnap automātiski izveido savu ekrānuzņēmumu direktoriju. Ekrāna ierakstu direktoriju izveido pats, pēc tam restartē Omarchy, lai jebkuras no vides izmaiņām stātos spēkā.

### Kā panākt, lai manā Apple Studio Display darbotos skaļruņi un tīmekļa kamera?

Domātu, ka visam vajadzētu darboties, vienkārši pievienojot USB C, bet diemžēl tā nav. Risinājums, ko esmu atradis, lai tas darbotos uzticami, ir izmantot [WJESOG DisplayPort + USB-A => USB-C kabeli](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Tad skaļruņi un tīmekļa kamera darbojas lieliski.

Atceries, ka tev Omarchy ir iebūvēta spilgtuma regulēšana Apple displejiem (gan Studio, gan XDR), izmantojot parastās tastatūras spilgtuma pogas.

### Kā atbrīvoties no visas liekās programmatūras?

Ja negribi tādas programmas kā Obsidian vai LibreOffice vai jebkuru citu iepriekš instalēto lietu, tu vari to ļoti viegli noņemt.

Palaid _Remove > Package_, lai redzētu katru instalēto pakotni. Pēc tam ar tab vari atlasīt jebkuru pakotni, ko vēlies noņemt, un ar return sākt noņemt visu atlasīto.

Un tu vari izmantot _Remove > Web App_ no Omarchy izvēlnes, lai noņemtu jebkuru iepriekš instalēto tīmekļa lietotni, ko negribi.

Vai palaid _Remove > Preinstalls_, lai vienā piegājienā iztīrītu visas iepriekš instalētās ekstras — tīmekļa lietotnes, TUIs un izvēles lietojumprogrammas. Karstie taustiņi, kas tās palaida, pazūd kopā ar tām, tāpēc tev paliek tīrs sākums ar saistījumiem, ko aizpildīt ar saviem failā `~/.config/hypr/bindings.lua`.

---

Kļūdu un salūzušu lietu gadījumā skati [problēmu novēršanas sadaļu](45-troubleshooting.md).
