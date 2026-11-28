# Pārlūki

Omarchy komplektā ir [Google Chrome](https://www.google.com/chrome/) kā noklusējuma pārlūks. Tas ir noformēts atbilstoši pārējai jūsu sistēmai, un tieši to atver `Super + Shift + Return` (vai `Super + Shift + B`), ar `Super + Shift + Alt + B` privātam logam, un tajā darbojas katra [tīmekļa lietotne](25-web-apps.md). Tas atveras uzreiz pārlūka logā: nav nekāda sagaidīšanas ekrāna vai pierakstīšanās aicinājuma, lietošanas statistika un avāriju ziņojumi netiek sūtīti Google, un reklāmu privātuma aicinājumi ir izslēgti. Jūs joprojām varat pierakstīties savā Google kontā no profila pogas jebkurā laikā, kad vēlaties sinhronizāciju.

Ja Chrome nav jūsu gaumē, jūs neesat pie tā piesaistīts. Omarchy izvēlnē sadaļā _Install > Browser_ atradīsiet [Chromium](https://www.chromium.org/) (vienkāršo atvērtā koda versiju, no kuras ir izveidots Chrome), Edge, Brave, Brave Origin, Firefox un [Zen](https://zen-browser.app/) (Edge tikai x86 datoros). Izvēlieties vienu, un Omarchy to instalēs, iestatīs tā politikas direktoriju un piemēros tam jūsu pašreizējo tēmu.

## Kā iestatīt noklusējumu

Pārlūka instalēšana to nepadara par noklusējumu. Lai pārslēgtos, dodieties uz _Setup > Defaults > Browser_ un izvēlieties vienu. Pašreizējais noklusējums ir atzīmēts ar ķeksīti, un, izvēloties pārlūku, kura jums vēl nav, tas vispirms tiek instalēts.

No termināļa tas ir:

```bash
omarchy default browser firefox
```

Palaidiet to bez argumenta, un tas parādīs pašreizējo noklusējumu. Tas iestata XDG apstrādātāju, tāpēc ne tikai Omarchy karstie taustiņi seko līdzi — viss, kas atver saiti, no tērzēšanas lietotnes līdz termināļa komandai, dodas uz jūsu izvēlēto pārlūku.

## URL kopēšana un video lejupielāde

Chromium saimes pārlūkiem (pašam Chromium, Chrome, Edge, Brave un Brave Origin) ir trīs Omarchy paplašinājumi: divi, kas sniedzas ārpus pārlūka un pārējā jūsu sistēmā, un viens, kas sakārto WhatsApp.

**Copy URL** ievieto pašreizējās cilnes adresi jūsu starpliktuvē ar `Alt + Shift + L`. Tas ir ātrāk nekā noklikšķināt adreses joslā un kopēt, un, tā kā tas iet caur sistēmas starpliktuvi, nevis pārlūka starpliktuvi, jūs saņemat Omarchy paziņojumu, kas to apstiprina, un URL ir nekavējoties pieejams [starpliktuves vēsturē](08-unified-clipboard-history.md) un katrā citā lietotnē. Ir arī rīkjoslas poga, ja dodat priekšroku klikšķināšanai.

**Download Video** satver video, kas tiek atskaņots lapā, kuru skatāties, ar `Alt + Shift + D`. Tas nodod URL [yt-dlp](https://github.com/yt-dlp/yt-dlp), tāpēc tas darbojas daudz vairāk nekā tikai YouTube, un lejupielāde nonāk `~/Videos`. Progress tiek parādīts tajā pašā ekrāna displejā, ko izmanto skaļums un spilgtums, atjauninoties uz vietas, nevis krājot paziņojumus. Iestatiet `OMARCHY_YTDLP_DIR`, ja vēlaties, lai faili nonāktu citur — skatiet [BUJ](46-faq.md), kur ievietot vides mainīgos.

Abi paplašinājumi sazinās ar Omarchy, izmantojot nelielu vietējās ziņojumapmaiņas resursdatoru, kas jums tiek instalēts kopā ar pārlūku. Tā ir daļa, kas ļauj tīmekļa lapas video nonākt jūsu mājas direktorijā un URL nonākt jūsu starpliktuves pārvaldniekā, ko parasts paplašinājums pats nevar izdarīt.

**WhatsApp Slim** liek WhatsApp Web sekot jūsu sistēmas tēmai un sakļauj tā tērzēšanas sarakstu, kad logs ir šaurs.

Tie ir pieejami tikai Chromium saimei. Firefox un Zen tos nesaņem.

## Firefox un Zen

Firefox un Zen ir cita saime, tāpēc tiem ir cita pieeja: Omarchy instalē politiku failu saprātīgiem noklusējumiem un pārslēdz tos vietējā Wayland režīmā, ko vēlaties daļējai mērogošanai un vienmērīgai skārienpaliktņa ritināšanai.

Tie nesaņem iepriekš minētos Chromium paplašinājumus, un Omarchy tos nenoformē, tāpēc šīs pieredzes daļas jums jāiestata pašam.

## Pārlūka noņemšana

Jebkuru no šiem pārlūkiem, ieskaitot Chrome, var atkal noņemt sadaļā _Remove > Browser_. Saites tad dodas uz Chrome vai Chromium, ja otrs joprojām ir instalēts.
