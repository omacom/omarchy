# BUJ

### Kā pārslēgties starp tastatūras izkārtojumiem?

Rediģējiet savu `~/.config/hypr/input.lua` failu un pievienojiet šo, lai pārslēgtos starp izkārtojumiem ar `Left Alt + Right Alt`:

```
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,fr",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",
  },
})
```

Josla automātiski rādīs jūsu pašreizējo tastatūras izkārtojumu, tiklīdz būsiet konfigurējis vairākus izkārtojumus (un varat arī noklikšķināt uz tā, lai pārslēgtos).

### Kā mainīt pulksteņa formātu uz 12 stundu?

Ar labo pogu noklikšķiniet uz pulksteņa joslā, lai pārslēgtos starp izplatītākajiem formātiem, tostarp 12 stundu formātiem. Formātu varat iestatīt arī tieši:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Tiks rādīts Svētdiena 10:55 AM.

### Kā mainīt laika joslu?

Palaidiet _Setup > Region > Timezone_ Omarchy izvēlnē un izvēlieties no saraksta. Ja laika josla ir pareiza, bet pats pulkstenis ir novirzījies, _Update > Time_ jūsu vietā restartēs laika sinhronizāciju.

### Kā mainīt DNS, kopīgot Wi-Fi vai pārbaudīt savienojuma ātrumu?

Tie visi atrodas sadaļā [tīklošana](35-networking.md).

### Kā pārbaudīt, cik ātrs ir mans disks?

_Trigger > Speed Test > Disk Speed Test_ mēra jūsu diska reāllaika lasīšanas un rakstīšanas ātrumu, vai arī `omarchy disk speedtest` no termināļa.

### Kā pievienot printeri?

Drukāšana ir iestatīta un darbojas uzreiz, un katru printeri pievienojat pats no _Print Settings_ lietotņu palaidējā (`Super + Alt + Space`).

Izvēlieties _Add_ un uzgaidiet brīdi, kamēr tiek meklēts: caur USB pievienots printeris un lielākā daļa tīkla printeru tiks atrasti jūsu vietā. Ja jūsējais nav sarakstā, izvēlieties _Network Printer > Internet Printing Protocol (ipp)_ un ievadiet tā adresi — printera paša displejs vai tā tīmekļa lapa pateiks, kāda tā ir, parasti kaut kas līdzīgs `192.168.1.50` ar rindu `ipp/print`. _Forward_ pēc tam piedāvā draiveri, kur moderns printeris vislabāk darbojas ar bezdraivera _IPP Everywhere_ profilu, bet vecākam vajadzīgs modeļa paša draiveris.

Ar labo pogu noklikšķiniet uz printera un izvēlieties _Set as Default_, lai izvēlētos, kuru jūsu lietotnes sasniedz pirmo, un _Properties_, lai iestatītu papīra izmēru, abpusēju drukāšanu un kvalitāti.

Automātiskā atklāšana, kad tīklā esošie printeri parādās bez pievienošanas, pagaidām ir izslēgta, kamēr tā tiek pārstrādāta, tāpēc pirmais solis iepriekš ir jūsu, nevis automātisks. Drukāšana PDF failā darbojas arī bez jebkāda printera.

### Kā mainīt, kur tiek saglabāti ekrānuzņēmumi vai ekrāna ieraksti?

Saglabātie ekrānuzņēmumi pēc noklusējuma nonāk `~/Pictures/Screenshots`. Lai izmantotu citu direktoriju, pievienojiet šo failam mapē `~/.config/uwsm/env.d/` (piemēram, `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

To pašu varat izdarīt ekrāna ierakstiem, izmantojot `OMARCHY_SCREENRECORD_DIR`.

Omasnap automātiski izveido savu ekrānuzņēmumu direktoriju. Ekrāna ierakstu direktoriju izveidojiet pats, pēc tam restartējiet Omarchy, lai jebkuras no vides izmaiņām stātos spēkā.

### Kā panākt, lai Apple Studio Display darbotos skaļruņi + tīmekļa kamera?

Varētu domāt, ka visam vajadzētu darboties, vienkārši pievienojot USB C, bet diemžēl tā nav. Risinājums, ko esmu atradis, lai tas darbotos uzticami, ir izmantot [WJESOG DisplayPort + USB-A => USB-C kabeli](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Tad skaļruņi un tīmekļa kamera darbojas kā pa sviestu.

Atcerieties, ka Omarchy jums ir iebūvēta spilgtuma vadība Apple displejiem (gan Studio, gan XDR), izmantojot parastās tastatūras spilgtuma pogas.

### Kā atbrīvoties no visas liekās programmatūras?

Ja nevēlaties tādas programmas kā Obsidian vai LibreOffice vai jebkuru citu iepriekš instalēto lietu, varat tās ļoti viegli noņemt.

Palaidiet _Remove > Package_, lai redzētu katru instalēto pakotni. Pēc tam ar tab varat atlasīt jebkuru pakotni, kuru vēlaties noņemt, un ar return sākt noņemt visu atlasīto.

Un varat izmantot _Remove > Web App_ no Omarchy izvēlnes, lai noņemtu jebkuru no iepriekš instalētajām tīmekļa lietotnēm, kuru nevēlaties.

Vai palaidiet _Remove > Preinstalls_, lai vienā piegājienā izslaucītu visus iepriekš instalētos papildinājumus — tīmekļa lietotnes, TUI un izvēles lietojumprogrammas. Karstie taustiņi, kas tās palaida, pazūd kopā ar tām, tāpēc jums paliek tīrs sākums ar saistījumiem, ko aizpildīt ar savējiem failā `~/.config/hypr/bindings.lua`.

---

Kļūdām un salauztām lietām skatiet [problēmu novēršanas sadaļu](45-troubleshooting.md).
