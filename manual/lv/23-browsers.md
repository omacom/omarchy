# Pārlūkprogrammas

Omarchy kā noklusējuma pārlūkprogrammu piegādā [Chromium](https://www.chromium.org/). Tā ir vienkārša atvērtā pirmkoda būve, kas motīva ziņā saskaņota ar pārējo jūsu sistēmu, un tieši to atver `Super + Shift + Return` un tieši tajā darbojas katra [tīmekļa lietotne](25-web-apps.md).

Ja Chromium nav pēc jūsu gaumes, jūs neesat pie tā iesprūdis. Omarchy izvēlnē sadaļā _Instalēt > Browser_ atradīsiet Chrome, Edge, Brave, Brave Origin, Firefox un [Zen](https://zen-browser.app/). Izvēlieties vienu, un Omarchy to instalēs, iestatīs tās politikas direktoriju un piemēros tai jūsu pašreizējo tēmu.

## Vienas padarīšana par noklusējumu

Pārlūkprogrammas instalēšana to nepadara par galveno. Kad tā ir datorā, dodieties uz _Iestatīšana > Defaults > Browser_ un izvēlieties to — izvēlne uzskaita tikai tās pārlūkprogrammas, kuras jums patiesībā ir instalētas, un pašreizējo noklusējumu atzīmē ar ķeksīti.

No termināļa tas ir:

```bash
omarchy default browser firefox
```

Palaidiet to bez argumenta, un tas pateiks pašreizējo noklusējumu. Tas iestata XDG apstrādātāju, tāpēc līdzi seko ne tikai Omarchy karstie taustiņi — viss, kas atver saiti, sākot no tērzēšanas lietotnes un beidzot ar termināļa komandu, nonāk jūsu izvēlētajā pārlūkprogrammā.

## Copy URL un Download Video

Chromium dzimtas pārlūkprogrammām (pats Chromium, Chrome, Edge un Brave) nāk līdzi divi Omarchy paplašinājumi, kas no pārlūkprogrammas sniedzas pārējā jūsu sistēmā.

**Copy URL** pašreizējās cilnes adresi ievieto starpliktuvē ar `Alt + Shift + L`. Tas ir ātrāk nekā klikšķināt adrešu joslā un kopēt, un, tā kā tas notiek caur sistēmas starpliktuvi, nevis pārlūkprogrammas starpliktuvi, jūs saņemat Omarchy paziņojumu, kas to apstiprina, un vietrādis (URL) uzreiz ir pieejams [starpliktuves vēsturē](08-unified-clipboard-history.md) un katrā citā lietotnē. Ja labprāt klikšķināt, ir arī rīkjoslas poga.

**Download Video** ar `Alt + Shift + D` satver video, kas atskaņojas jūsu skatītajā lapā. Tas vietrādi nodod [yt-dlp](https://github.com/yt-dlp/yt-dlp), tāpēc darbojas daudz plašāk nekā tikai vietnē YouTube, un lejupielāde nonāk mapē `~/Videos`. Progress parādās tajā pašā ekrāna rādītājā, ko izmanto skaļums un spilgtums, atjauninoties tajā pašā vietā, nevis kraujot paziņojumus kaudzē. Iestatiet `OMARCHY_YTDLP_DIR`, ja vēlaties, lai faili nonāktu citviet — to, kur likt vides mainīgos, skatiet [BUJ](46-faq.md).

Abi paplašinājumi ar Omarchy sazinās caur nelielu vietējās ziņojumapmaiņas resursdatoru, kas tiek instalēts kopā ar pārlūkprogrammu. Tas ir tas gabaliņš, kas ļauj tīmekļa lapas video nonākt jūsu mājas direktorijā un vietrādim nonākt jūsu starpliktuves pārvaldniekā, ko parasts paplašinājums viens pats nevar izdarīt.

Tie darbojas tikai Chromium dzimtā. Firefox un Zen tos nesaņem.

## Firefox un Zen

Firefox un Zen ir cita dzimta, tāpēc pret tiem izturas citādi: Omarchy instalē politiku failu, lai iegūtu sakarīgus noklusējumus, un pārslēdz tās vietējā Wayland režīmā, ko vēlaties daļveida mērogošanai un plūdenai skārienpaliktņa ritināšanai.

Tie nesaņem iepriekš minētos Chromium paplašinājumus, un Omarchy tiem nepiešķir motīvu, tāpēc šīs pieredzes daļas jums jāiestata pašam.

## Vienas atkal noņemšana

Visu, ko šeit instalējāt, var atkal noņemt sadaļā _Noņemt > Browser_. Chromium šajā sarakstā nav — tas ir daļa no pamata sistēmas.
