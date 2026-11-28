# Pārlūki

Omarchy pēc noklusējuma izmanto [Google Chrome](https://www.google.com/chrome/) kā pārlūku. Tas ir noformēts atbilstoši pārējai jūsu sistēmai, un tieši to atver `Super + Shift + Return` (vai `Super + Shift + B`), ar `Super + Shift + Alt + B` — privātu logu, un tajā darbojas arī katra [tīmekļa lietotne](25-web-apps.md). Tas atveras uzreiz pārlūka logā: nav nekāda sagaidīšanas ekrāna vai pierakstīšanās aicinājuma, lietojuma statistika un avāriju ziņojumi netiek sūtīti Google, un reklāmu privātuma aicinājumi ir izslēgti. Jūs joprojām varat pierakstīties savā Google kontā ar profila pogu jebkurā brīdī, kad vēlaties sinhronizāciju.

Ja Chrome nav jūsu gaumē, jūs neesat ar to iesprostots. Omarchy izvēlnes sadaļā _Install > Browser_ atradīsiet [Chromium](https://www.chromium.org/) (vienkāršo atvērtā pirmkoda būvējumu, no kura veidots Chrome), Edge, Brave, Brave Origin, Firefox, [Zen](https://zen-browser.app/) un [Ladybird](https://ladybird.org/) (Edge tikai x86 datoros). Izvēlieties vienu, un Omarchy to instalēs, iestatīs tā politiku direktoriju un piemēros tam jūsu pašreizējo tēmu.

## Kā padarīt vienu par noklusējumu

Pārlūka instalēšana to nepaaugstina par noklusējumu. Lai pārslēgtos, dodieties uz _Setup > Defaults > Browser_ un izvēlieties vienu. Pašreizējais noklusējums ir atzīmēts ar ķeksīti, un, izvēloties pārlūku, kura jums vēl nav, tas vispirms tiks instalēts.

No termināļa tas ir šādi:

```bash
omarchy default browser firefox
```

Palaidiet to bez argumenta, un tas parādīs pašreizējo noklusējumu. Tas iestata XDG apdarinātāju, tāpēc ne tikai Omarchy karstie taustiņi seko līdzi — viss, kas atver saiti, no tērzēšanas lietotnes līdz termināļa komandai, dodas uz jūsu izvēlēto pārlūku.

## Copy URL un Download Video

Chromium saimes pārlūkiem (pašam Chromium, Chrome, Edge, Brave un Brave Origin) ir trīs Omarchy paplašinājumi: divi, kas sniedzas ārpus pārlūka un pārējā sistēmā, un viens, kas sakārto WhatsApp.

**Copy URL** ievieto pašreizējās cilnes adresi starpliktuvē ar `Alt + Shift + L`. Tas ir ātrāk nekā klikšķināt adreses joslā un kopēt, un, tā kā tas notiek caur sistēmas starpliktuvi, nevis pārlūka starpliktuvi, jūs saņemat Omarchy paziņojumu, kas to apstiprina, un URL uzreiz ir pieejams [starpliktuves vēsturē](08-unified-clipboard-history.md) un katrā citā lietotnē. Ir arī rīkjoslas poga, ja dodat priekšroku klikšķināšanai.

**Download Video** ar `Alt + Shift + D` paņem video, kas tiek atskaņots jūsu apskatītajā lapā. Tas nodod URL [yt-dlp](https://github.com/yt-dlp/yt-dlp), tāpēc darbojas daudz vairāk nekā tikai YouTube, un lejupielāde nonāk `~/Videos`. Progress tiek rādīts tajā pašā ekrāna displejā, ko izmanto skaļums un spilgtums, un tiek atjaunināts uz vietas, nevis krājas paziņojumos. Iestatiet `OMARCHY_YTDLP_DIR`, ja vēlaties, lai faili nonāktu citur — skatiet [FAQ](46-faq.md), lai uzzinātu, kur likt vides mainīgos.

Abi paplašinājumi sazinās ar Omarchy, izmantojot nelielu vietējās ziņojumapmaiņas resursdatoru, kas tiek instalēts kopā ar pārlūku. Tieši šī daļa ļauj tīmekļa lapas video nonākt jūsu mājas direktorijā un URL — jūsu starpliktuves pārvaldniekā, ko parasts paplašinājums viens pats nevar izdarīt.

**WhatsApp Slim** liek WhatsApp Web sekot jūsu sistēmas tēmai un sakļauj tā tērzēšanas sarakstu, kad logs ir šaurs.

Tie ir pieejami tikai Chromium saimei. Firefox un Zen tos nesaņem.

## Firefox un Zen

Firefox un Zen ir no citas saimes, tāpēc tiem ir cita pieeja: Omarchy instalē politiku failu ar saprātīgiem noklusējumiem un pārslēdz tos vietējā Wayland režīmā, ko jūs vēlaties daļējas mērogošanas un vienmērīgas skārienpaliktņa ritināšanas dēļ.

Tie nesaņem iepriekš minētos Chromium paplašinājumus, un Omarchy tos nenoformē, tāpēc šīs pieredzes daļas jums jāiestata pašam.

## Ladybird

Ladybird ir pārlūks, kas uzrakstīts no nulles, ar savu dzinēju, nevis Chromium vai Firefox dzinēju. Tas joprojām ir alfa versijā, tāpēc sagaidiet vietnes, kas vēl nedarbojas, un Omarchy to instalē tādu, kāds tas ir: bez paplašinājumiem, bez tēmas, bez politikām. Tam nav arī privātā loga, tāpēc `Super + Shift + Alt + B` to atver ar pagaidu profilu, kas tiek izdzēsts, kad to aizverat. [Tīmekļa lietotnes](25-web-apps.md) turpina darboties Chrome vai Chromium.

## Kā to atkal noņemt

Jebkuru no šiem pārlūkiem, ieskaitot Chrome, var atkal noņemt sadaļā _Remove > Browser_. Saites tad dodas uz Chrome vai Chromium, ja otrs joprojām ir instalēts.
