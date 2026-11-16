# Pārlūkprogrammas

Omarchy nāk ar [Google Chrome](https://www.google.com/chrome/) kā noklusējuma pārlūkprogrammu. Tā ir noformēta tā, lai saskanētu ar pārējo jūsu sistēmu, un tieši to atver `Super + Shift + Return` un tieši tajā darbojas katra [tīmekļa lietotne](25-web-apps.md). Tā atveras uzreiz pārlūkprogrammas logā: nav nekāda sagaidīšanas ekrāna vai aicinājuma pierakstīties, lietojuma statistika un avāriju ziņojumi netiek sūtīti Google, un reklāmu privātuma aicinājumi ir izslēgti. Jūs joprojām varat pierakstīties savā Google kontā no profila pogas, kad vien vēlaties sinhronizāciju.

Ja Chrome nav jūsu gaumē, jūs neesat pie tās piesiets. Omarchy izvēlnē sadaļā _Install > Browser_ atradīsiet [Chromium](https://www.chromium.org/) (vienkāršo atvērtā koda būvējumu, no kura veidots Chrome), Edge, Brave, Brave Origin, Firefox un [Zen](https://zen-browser.app/). Izvēlieties vienu, un Omarchy to instalēs, iestatīs tās politiku direktoriju un piemēros tai jūsu pašreizējo tēmu.

## Kā vienu padarīt par noklusējuma

Pārlūkprogrammas instalēšana to nepadara par noklusējuma. Kad tā ir datorā, dodieties uz _Setup > Defaults > Browser_ un izvēlieties to — izvēlnē ir uzskaitītas tikai tās pārlūkprogrammas, kuras jums patiešām ir instalētas, un pašreizējā noklusējuma pārlūkprogramma ir atzīmēta ar ķeksīti.

No termināļa tas ir:

```bash
omarchy default browser firefox
```

Palaidiet to bez argumenta, un tā pateiks pašreizējo noklusējuma pārlūkprogrammu. Šis iestata XDG apdarinātāju, tāpēc tai seko ne tikai Omarchy karstie taustiņi — viss, kas atver saiti, no tērzēšanas lietotnes līdz termināļa komandai, dodas uz jūsu izvēlēto pārlūkprogrammu.

## Copy URL un Download Video

Chromium saimes pārlūkprogrammas (pats Chromium, Chrome, Edge un Brave) nāk ar diviem Omarchy paplašinājumiem, kas sniedzas ārpus pārlūkprogrammas uz pārējo jūsu sistēmu.

**Copy URL** ievieto pašreizējās cilnes adresi jūsu starpliktuvē ar `Alt + Shift + L`. Tas ir ātrāk nekā klikšķināt adreses joslā un kopēt, un, tā kā tas iet caur sistēmas starpliktuvi, nevis pārlūkprogrammas starpliktuvi, jūs saņemat Omarchy paziņojumu, kas to apstiprina, un URL uzreiz ir pieejams [starpliktuves vēsturē](08-unified-clipboard-history.md) un katrā citā lietotnē. Ir arī rīkjoslas poga, ja dodat priekšroku klikšķināšanai.

**Download Video** satver video, kas tiek atskaņots lapā, kuru skatāties, ar `Alt + Shift + D`. Tas nodod URL [yt-dlp](https://github.com/yt-dlp/yt-dlp), tāpēc tas darbojas daudz vairāk vietnēs nekā tikai YouTube, un lejupielāde nonāk `~/Videos`. Progress parādās tajā pašā ekrāna displejā, ko izmanto skaļums un spilgtums, atjauninoties uz vietas, nevis krājot paziņojumus. Iestatiet `OMARCHY_YTDLP_DIR`, ja vēlaties, lai faili nonāktu citur — skatiet [FAQ](46-faq.md), kur norādīts, kur likt vides mainīgos.

Abi paplašinājumi sazinās ar Omarchy caur nelielu vietējās ziņojumapmaiņas resursdatoru, kas tiek instalēts kopā ar pārlūkprogrammu. Tā ir daļa, kas ļauj tīmekļa lapas video nonākt jūsu mājas direktorijā, bet URL — jūsu starpliktuves pārvaldniekā, ko parasts paplašinājums pats par sevi nevar izdarīt.

Tie ir pieejami tikai Chromium saimei. Firefox un Zen tos nesaņem.

## Firefox un Zen

Firefox un Zen ir cita saime, tāpēc attieksme pret tām ir cita: Omarchy instalē politiku failu saprātīgiem noklusējumiem un pārslēdz tās vietējā Wayland režīmā, ko vēlaties daļējai mērogošanai un vienmērīgai skārienpaliktņa ritināšanai.

Tās nesaņem iepriekš minētos Chromium paplašinājumus, un Omarchy tās nenoformē, tāpēc tās pieredzes daļas ir jāiestata jums pašiem.

## Pārlūkprogrammas atkārtota noņemšana

Jebkuru no šīm pārlūkprogrammām, ieskaitot Chrome, var atkal noņemt sadaļā _Remove > Browser_. Pēc tam saites atvērsies Chrome vai Chromium, ja otra pārlūkprogramma joprojām ir instalēta.
