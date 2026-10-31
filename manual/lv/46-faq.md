# Biežāk uzdotie jautājumi

### Kā pārslēgties starp tastatūras izkārtojumiem?

Rediģējiet savu failu `~/.config/hypr/input.lua` un pievienojiet šo, lai pārslēgtos starp izkārtojumiem ar `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Josla automātiski rādīs jūsu pašreizējo tastatūras izkārtojumu, tiklīdz jums būs konfigurēti vairāki izkārtojumi (un varat arī uz tā noklikšķināt, lai pārslēgtu).

### Kā mainīt pulksteņa formātu uz 12 stundu?

Ar labo pogu noklikšķiniet pulksteni joslā, lai cikliski izietu biežākos formātus, ieskaitot 12 stundu formātus. Formātu varat iestatīt arī tieši:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Tas parādīs Sunday 10:55 AM.

### Kā mainīt laika joslu?

Omarchy izvēlnē palaidiet _Atjaunināt > Laika josla_ un izvēlieties no saraksta. Ja laika josla ir pareiza, bet pats pulkstenis ir novirzījies, _Atjaunināt > Laiks_ jums pārstartē laika sinhronizāciju.

### Kā mainīt DNS, kopīgot Wi-Fi vai pārbaudīt savienojuma ātrumu?

Tas viss ir sadaļā [tīklošana](35-networking.md).

### Kā pārbaudīt, cik ātrs ir mans disks?

_Palaist > Ātruma tests > Diska ātruma tests_ mēra jūsu diska lasīšanas un rakstīšanas ātrumu reālā laikā, vai `omarchy disk speedtest` terminālī.

### Kāpēc nevaru pierakstīties savā Google kontā Chromium?

Parastajā atvērtā pirmkoda Chromium būvējumā nav OAuth akreditācijas datu, ko Google prasa konta pierakstīšanai. Omarchy izvēlnē palaidiet _Instalēt > Pakalpojums > Chromium konts_, lai tos pievienotu, pārstartējiet pārlūku, un pierakstīšanās izdosies.

### Kā pievienot printeri?

Drukāšana ir iestatīta un darbojas uzreiz pēc uzstādīšanas, un katru printeri pievienojat pats sadaļā _Print Settings_ lietotņu palaidējā (`Super + Space`).

Izvēlieties _Add_ un dodiet tam brīdi paskatīties: ar USB pievienots printeris un lielākā daļa tīkla printeru tiek atrasti jūsu vietā. Ja jūsējā sarakstā nav, izvēlieties _Network Printer > Internet Printing Protocol (ipp)_ un ievadiet tā adresi — paša printera displejs vai tā tīmekļa lapa pateiks, kas tā ir, parasti kaut kas līdzīgs `192.168.1.50` ar rindu `ipp/print`. _Forward_ pēc tam piedāvā draiveri, kur moderns printeris vislabāk darbojas ar bezdraivera _IPP Everywhere_ profilu, bet vecākam vajadzīgs modeļa paša draiveris.

Ar labo pogu noklikšķiniet printeri un izvēlieties _Set as Default_, lai noteiktu, kuru jūsu lietotnes sasniedz pirmo, un _Properties_, lai iestatītu papīra izmēru, divpusējo druku un kvalitāti.

Automātiskā atklāšana, kad tīkla printeri parādās, nepievienojot, īslaicīgi ir izslēgta, kamēr tā tiek pārstrādāta, tāpēc pirmais solis iepriekš ir jūsu, nevis automātisks. Drukāšana PDF failā darbojas bez nekāda printera.

### Kā mainīt, kur tiek saglabāti ekrānuzņēmumi vai ekrāna ieraksti?

Saglabātie ekrānuzņēmumi pēc noklusējuma nonāk mapē `~/Pictures/Screenshots`. Lai izmantotu citu direktoriju, pievienojiet šo failam mapē `~/.config/uwsm/env.d/` (piemēram, `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

To pašu ekrāna ierakstiem varat izdarīt, izmantojot `OMARCHY_SCREENRECORD_DIR`.

Omasnap savu ekrānuzņēmumu direktoriju izveido automātiski. Ekrāna ierakstu direktoriju izveidojiet pats, pēc tam pārstartējiet Omarchy, lai jebkuras vides izmaiņas stātos spēkā.

### Kā panākt, lai manā Apple Studio Display darbotos skaļruņi un tīmekļa kamera?

Domātu, ka visam vajadzētu darboties, vienkārši pievienojot USB C, bet diemžēl tā nav. Risinājums, ko esmu atradis, lai tas darbotos uzticami, ir [WJESOG DisplayPort + USB-A => USB-C kabeļa](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/) izmantošana. Tad skaļruņi un tīmekļa kamera darbojas kā no pasakas.

Atcerieties, ka Omarchy jums ir iebūvēta spilgtuma vadība Apple displejiem (gan Studio, gan XDR), izmantojot parastās tastatūras spilgtuma pogas.

### Kā atbrīvoties no visas papildu programmatūras?

Ja nevēlaties tādas programmas kā Obsidian vai LibreOffice vai jebko citu iepriekš instalētu, to varat ļoti viegli noņemt.

Palaidiet _Noņemt > Pakotne_, lai redzētu katru instalēto pakotni. Pēc tam ar tab varat atlasīt jebkuru pakotni, ko vēlaties noņemt, un ar return sākt noņemt visu atlasīto.

Un no Omarchy izvēlnes varat izmantot _Noņemt > Tīmekļa lietotne_, lai noņemtu jebkuru iepriekš instalētu tīmekļa lietotni, ko nevēlaties.

Vai palaidiet _Noņemt > Iepriekš instalētie_, lai vienā piegājienā iztīrītu visas iepriekš instalētās piedevas — tīmekļa lietotnes, TUI un izvēles lietojumprogrammas. Ātrie taustiņi, kas tās palaida, pazūd līdz ar tām, tāpēc jums paliek tīra saistījumu lapa, ko aizpildīt ar savējiem failā `~/.config/hypr/bindings.lua`.

---

Par kļūdām un salauztām daļām skatiet [Problēmu novēršanas sadaļu](45-troubleshooting.md).
