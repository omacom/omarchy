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

Josla automātiski rādīs pašreizējo tastatūras izkārtojumu, tiklīdz būs konfigurēti vairāki izkārtojumi (un varēsi arī noklikšķināt uz tās, lai pārslēgtos).

### Kā mainīt pulksteņa formātu uz 12 stundu?

Ar peles labo pogu noklikšķini uz pulksteņa joslā, lai pārslēgtos starp izplatītākajiem formātiem, tostarp 12 stundu formātiem. Formātu var iestatīt arī tieši:

```
omarchy bar set omarchy.clock format "dddd h:mm AP"
```

Šādi tiks rādīts Svētdiena 10:55 AM.

### Kā mainīt laika joslu?

Omarchy izvēlnē palaid _Iestatīšana > Reģions > Laika josla_ un sarakstā izvēlies vajadzīgo. Ja laika josla ir pareiza, bet pats pulkstenis ir novirzījies, _Atjaunināšana > Laiks_ tavā vietā restartēs laika sinhronizāciju.

### Kā mainīt DNS, kopīgot Wi-Fi vai pārbaudīt savienojuma ātrumu?

Tie visi atrodami [tīklošanā](35-networking.md).

### Kā pārbaudīt, cik ātrs ir mans disks?

_Palaidējs > Ātruma tests > Diska ātruma tests_ mēra tava diska reālo lasīšanas un rakstīšanas ātrumu, vai arī `omarchy disk speedtest` no termināļa.

### Kā pievienot printeri?

Drukāšana ir iestatīta un darbojas jau no kastes, un katru printeri pievieno pats no _Drukas iestatījumi_ lietotņu palaidējā (`Super + Space`).

Izvēlies _Pievienot_ un dod tam brīdi meklēt: pa USB pievienots printeris un lielākā daļa tīkla printeru tiks atrasti tavā vietā. Ja tavējais sarakstā nav, izvēlies _Tīkla printeris > Internet Printing Protocol (ipp)_ un ievadi tā adresi — printera paša displejs vai tā tīmekļa lapa pateiks, kāda tā ir, parasti kaut kas līdzīgs `192.168.1.50` ar rindu `ipp/print`. Tad _Tālāk_ piedāvās draiveri, kur modernam printerim vislabāk der bezdraivera _IPP Everywhere_ profils, bet vecākam vajag modeļa paša draiveri.

Ar peles labo pogu noklikšķini uz printera un izvēlies _Iestatīt kā noklusējumu_, lai izvēlētos, kuru tavas lietotnes izmanto pirmo, un _Īpašības_, lai iestatītu papīra izmēru, abpusējo druku un kvalitāti.

Automātiskā atklāšana, kad tīklā esošie printeri parādās bez pievienošanas, pagaidām ir izslēgta, kamēr to pārstrādā, tāpēc augstāk minētais pirmais solis ir jādara tev, nevis automātiski. Drukāšana PDF failā darbojas arī vispār bez printera.

### Kā mainīt, kur tiek saglabāti ekrānuzņēmumi vai ekrāna ieraksti?

Saglabātie ekrānuzņēmumi pēc noklusējuma nonāk `~/Pictures/Screenshots`. Lai izmantotu citu direktoriju, pievieno šo failam mapē `~/.config/uwsm/env.d/` (piemēram, `~/.config/uwsm/env.d/capture`):

```
export OMASNAP_SCREENSHOT_DIR="$HOME/Pictures/Captures"
```

To pašu ekrāna ierakstiem var izdarīt, izmantojot `OMARCHY_SCREENRECORD_DIR`.

Omasnap savu ekrānuzņēmumu direktoriju izveido automātiski. Ekrāna ierakstu direktoriju izveido pats, pēc tam restartē Omarchy, lai jebkuras no šīm vides izmaiņām stātos spēkā.

### Kā panākt, lai manā Apple Studio Display darbotos skaļruņi un tīmekļa kamera?

Varētu domāt, ka visam vajadzētu darboties, vienkārši pievienojot USB C, bet diemžēl tā nav. Risinājums, ko esmu atradis, lai tas darbotos uzticami, ir izmantot [WJESOG DisplayPort + USB-A => USB-C kabeli](https://www.amazon.com/WJESOG-DisplayPort-Adapter-Converter-Thunderbolt/dp/B0BNX7MS6N/). Tad skaļruņi un tīmekļa kamera darbojas nevainojami.

Atceries, ka Omarchy ir iebūvēta spilgtuma regulēšana Apple displejiem (gan Studio, gan XDR), izmantojot parastās tastatūras spilgtuma pogas.

### Kā atbrīvoties no visas papildu programmatūras?

Ja nevēlies tādas programmas kā Obsidian vai LibreOffice vai jebkuru citu iepriekš instalēto krāmu, vari to ļoti viegli noņemt.

Palaid _Noņemšana > Pakotne_, lai redzētu katru instalēto pakotni. Pēc tam ar tab vari atlasīt jebkuru pakotni, ko vēlies noņemt, un ar return sākt noņemt visu atlasīto.

Un no Omarchy izvēlnes vari izmantot _Noņemšana > Tīmekļa lietotne_, lai noņemtu jebkuru iepriekš instalēto tīmekļa lietotni, ko nevēlies.

Vai palaid _Noņemšana > Iepriekš instalētais_, lai vienā piegājienā izslaucītu visus iepriekš instalētos papildinājumus — tīmekļa lietotnes, TUIs un izvēles lietojumprogrammas. Karstie taustiņi, kas tās palaida, pazudīs kopā ar tām, tāpēc tev paliks tīrs saistījumu saraksts, ko aizpildīt ar savējiem failā `~/.config/hypr/bindings.lua`.

---

Kļūdu un salūzušu lietu gadījumā skati [problēmu novēršanas sadaļu](45-troubleshooting.md).
