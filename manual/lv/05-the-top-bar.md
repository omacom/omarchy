# Augšējā josla

Josla gar ekrāna augšmalu ir Omarchy josla. Tā nav pieboltēta statusa josla, bet gan daļa no Omarchy čaulas, viena ilgstoši darbojošos Quickshell procesa, kas zīmē arī izvēlni, paziņojumus, OSD uznirstošos logus un bloķēšanas ekrānu. Tāpēc tā lieliski saskan ar visu pārējo un panelis atveras acumirklī, nevis palaiž jaunu lietotni.

Tā ir arī vienīgā darbvirsmas daļa, kas vienmēr ir redzama ekrānā, tāpēc ir vērts zināt, ko dara visas tās mazās zīmes.

## Kas tajā ir pēc noklusējuma

Joslai ir trīs sadaļas. Kreisajā pusē atrodas Omarchy logotips (izvēlnes palaidējs) un darbvietu indikatori. Centrā ir statusa indikatori, pulkstenis, Elsewhen (pasaules pulkstenis), laikapstākļi un Omarchy atjauninājuma nozīmīte. Labajā pusē: sistēmas tekne, tastatūras izkārtojums (kad ir konfigurēts vairāk nekā viens), aģenti, bluetooth, tīkls, audio, displejs un barošana.

Daži no tiem parādās tikai tad, kad tiem ir ko teikt. Tastatūras izkārtojums parādās tikai tad, ja esi konfigurējis vairāk nekā vienu izkārtojumu. Atjauninājuma nozīmīte parādās tikai tad, kad gaida Omarchy atjauninājums. Un aģentu ikona parādās pirmo reizi, kad Omarchy datorā atrod AI kodēšanas lietojumu (skatiet [AI](17-ai.md)).

## Klikšķināšana

Gandrīz katrs logrīks kaut ko dara ar kreiso, labo un vidējo klikšķi, un vairāki reaģē uz ritināšanu. Šī ir daļa, ko cilvēki palaiž garām — labajā un vidējā pogā slēpjas daudz kā laba.

| Logrīks | Kreisais klikšķis | Labais klikšķis | Vidējais / ritināšana |
| --- | --- | --- | --- |
| Izvēlne | Omarchy izvēlne | Jauns terminālis | — |
| Darbvietas | Fokusēt šo darbvietu šajā monitorā | — | Ritināšana: nākamā/iepriekšējā darbvieta |
| Pulkstenis | Kalendāra uznirstošais logs | Pārslēgt etiķetes formātu | Vidējais: laika joslu atlasītājs |
| Laikapstākļi | Prognozes uznirstošais logs | Pilni laikapstākļi kā paziņojums | Vidējais: atsvaidzināt |
| Audio | Audio panelis | Izslēgt skaņu | Vidējais: panelis · ritināšana: skaļums |
| Mikrofons | Izslēgt mikrofonu | — | Vidējais: audio panelis · ritināšana: ievades skaļums |
| Tīkls | Tīkla panelis | — | — |
| Bluetooth | Bluetooth panelis | Pārslēgt radio | — |
| Displejs | Displeja panelis | — | Ritināšana: spilgtums |
| Barošana | Barošanas panelis | Pārslēgt akumulatora procentus | — |
| Multivide | Atskaņot/pauzēt | Vāka attēla uznirstošais logs | Vidējais: nākamais · ritināšana: iepriekšējais/nākamais |
| Aģenti | Aģentu panelis | Palaist savu aģentu | Vidējais: nākamais abonements |
| Tekne | Novietot kursoru, lai atklātu atvilktni | Ar labo pogu uz bultiņas, lai pārvaldītu | — |
| Omarchy atjauninājums | Palaist atjaunināšanu | — | — |

Ne viss šajā tabulā uzreiz ir tavā joslā. Multivides logrīks (MPRIS pašlaik atskaņotais, ar ritinošu dziesmu un izpildītāju) un mikrofona logrīks abi ir iebūvēti, bet pēc noklusējuma izslēgti — pievieno tos, ja vēlies, kā aprakstīts tālāk.

## Paneļi

Noklikšķinot uz joslas ikonas, atveras panelis, kas ir kārtīgs uznirstošais logs ar slīdņiem, sarakstiem un tastatūras navigāciju, nevis rīka padoms. Katram ir arī karstais taustiņš, tāpēc nekad nav jātēmē uz 16 pikseļu zīmi:

| Karstais taustiņš | Panelis |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Tīkls |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Displejs |
| `Super + Ctrl + P` | Barošana |
| `Super + Ctrl + Alt + D` | Kalendārs |
| `Super + Ctrl + Alt + E` | Pasaules pulkstenis |
| `Super + Ctrl + 1-9` | Pārslēgt n-to paneli labajā sadaļā |

Paneļi nav tikai rādījumi. Tajos tu patiešām izdari vajadzīgo:

- **Audio** ir galvenā skaļuma slīdnis, izvades ierīces atlasītājs un mikseris katrai lietotnei, lai vari pieklusināt to vienu pārlūka cilni, neaiztiekot visu pārējo.
- **Tīkls** meklē Wi-Fi, rāda signāla stiprumu, izveido savienojumu un ļauj izvēlēties DNS pakalpojumu sniedzēju.
- **Bluetooth** uzskaita tavas ierīces ar pievienošanu/atvienošanu un akumulatora līmeņiem.
- **Barošana** rāda akumulatora statistiku, pārslēdz barošanas profilus (tā atceras atsevišķu izvēli akumulatoram un AC) un parāda daļu sistēmas informācijas.
- **Displejs** ietver spilgtuma slīdni, teksta lielumu, monitora mērogošanas priekšiestatījumus un — kad tev ir vairāk nekā viens ekrāns — vadīklas katram monitoram. Padziļinātu aprakstu skaties [monitoros](33-monitors.md).
- **Pulkstenis** atver mēneša režģi ar ISO nedēļu numuriem un pārslēgšanos starp mēnešiem.
- **Pasaules pulkstenis** katrai pilsētai saglabā rindu ar tās laikapstākļiem un to, kā sokas tās dienai. Meklēšana atrod gan pilsētas, gan laika joslas, tāpēc Fort Lauderdale ir Fort Lauderdale, nevis New York. Ja augšējā rindā ir nosaukta nepareizā pilsēta, noklikšķini uz tās un pasaki, kur atrodies; izvēlies vietu citā laika joslā, un arī sistēmas pulkstenis pārcelsies turp, kas ir noderīgi ceļojot. Novieto kursoru uz pilsētas un noklikšķini uz personas pogas, lai pateiktu, kurš tur dzīvo — vienkārši vārdi vai `@` GitHub lietotājvārdi, lai viņu sejas nāktu līdzi.

Katrs panelis pieņem gan tastatūru, gan peli: bultiņas pārvieto, Return aktivizē, Tab pāriet uz blakus esošo paneli un Escape aizver.

`Super + Ctrl + 1-9` skaita paneļus no kreisās uz labo pusi labajā sadaļā, izlaižot tekni, jo tai nav sava paneļa. Tāpēc numurs atbilst ikonai, uz kuru tu rādītu.

### Tailscale un Dropbox

Vēl divi logrīki joslā parādās tikai tad, kad no **Instalēt → Pakalpojums** instalē atbilstošo pakalpojumu, un abus ir vērts zināt, jo tie dara vairāk nekā tikai ziņo statusu.

**Tailscale** panelis pievieno un atvieno tailnet, pārslēdzas starp kontiem un izvēlas izejas mezglu (šajā sarakstā parādās gan tavas ierīces, gan Mullvad reģioni). Tas arī pārlūko tavas ierīces — un, kad viena ir atlasīta, `s` tai pa Taildrop nosūta failus, kas ir ātrākais veids, kā pārvietot failu uz tālruni vai citu klēpjdatoru. `c` kopē ierīces IP, `n` tās nosaukumu un `d` tās pilno DNS nosaukumu. Katrā ierīces rindā ir arī sūtīšanas poga, ja labprātāk klikšķini. Tas pats no termināļa ir `omarchy tailscale send <machine> [file...]`.

**Dropbox** panelis veic pieteikšanos, rāda, cik daudz krātuves esi izmantojis, un uzskaita nesen sinhronizētos failus.

Jebkurš no pakalpojumiem noņemot, tā logrīks no joslas pazūd.

## Indikatori

Mazais kopums centrā ir indikatoru logrīks. Tās ir statusa zīmes režīmiem, kurus esi ieslēdzis: netraucēt, nakts gaisma, rindā esošs [atgādinājums](09-reminders.md), aktīva ekrāna ierakstīšana, palikt nomodā un [diktēšana](11-text-extraction-dictation.md). Tie iedegas, kad režīms ir aktīvs, un citādi netraucē — novieto kursoru tieši blakus tiem, kur atrastos neaktīvie, lai ielūkotos tajos. Noklikšķinot uz indikatora, šis režīms tiek pārslēgts. Vēl viens ir tikai statusam: attālinātā sesija deg sarkanā krāsā, kamēr kāds caur gliff ir pievienojies šai ierīcei.

Ja vēlies, lai tie vienmēr būtu redzami, logrīkā iestati `alwaysShow` uz `true`. Un, ja tev rūp tikai daži no tiem, uzskaiti vēlamos `items`: `["Dnd", "Reminder", "NightLight"]`. Tev var būt vairāk nekā viens indikatoru logrīks, tāpēc dažādas sadaļas var rādīt dažādas apakškopas.

## Joslas pārkārtošana

Josla konfigurējas pati. Lai pārvietotu lietas, nav jāatver konfigurācijas fails.

Satver tukšu joslas laukumu ap centru un velc to uz citu ekrāna malu, un josla pārcelsies turp — kreisā, labā, augšējā vai apakšējā mala der visas, un katrs logrīks pielāgojas (vertikālās joslas atgriežas pie kompaktām, tikai ar ikonām formām). Noklikšķināšana un turēšana sāk to pašu vilkšanu. Veic dubultklikšķi ar kreiso pogu uz tās pašas tukšās vietas, lai pārslēgtu joslas fonu no caurspīdīga uz stiklotu uz necaurspīdīgu. Un velc jebkuru logrīku, lai to pārkārtotu vai iemestu citā sadaļā; pārējie logrīki pašķirsies, lai atbrīvotu vietu tur, kur tas nolīdīs.

Joslas vidus ir kaste: viss, kas tajā atrodas, kā viena grupa paliek centrēts, un logrīki abās tās pusēs karājas pie tās malām. Kamēr velc logrīku, kaste redzama kā kontūra vai, kad tā ir tukša, kā līnija pāri joslai, un tu vari nomest tajā vai blakus tai. Kad nomešana nolīdītu kastē, kaste izaug, lai uzņemtu logrīku.

Logrīku, kuru vēlies tuvumā, bet ne vienmēr redzeslokā, var ievietot teknes atvilktnē: velc to uz tekni, un atvilktne atvērsies, lai to uzņemtu. Tas tur atrodas aiz lietotņu ikonām, parādās ikreiz, kad parādās atvilktne, un, kamēr tā panelis ir atvērts, saglabā atvilktni atvērtu. Velc to atpakaļ uz joslu, lai to atgrieztu.

Ja labprātāk izvēlies no izvēlnes, **Izskats → Izvēlņu josla** ir novietojums, un **Joslas fons** izvēlas, kā josla tiek zīmēta: **Necaurspīdīga josla**, **Stiklotā josla** (caurredzama, ar izpludinātu to, kas atrodas aiz tās) vai **Caurspīdīga josla**.

Tām pašām lietām ir komandas, kas ir tas, ko vēlies [dotfiles](31-dotfiles.md) iestatījumam:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Lai pilnībā pievienotu vai noņemtu logrīku, izmanto spraudņu komandas. `omarchy plugin list` izdrukā katru logrīku, ko čaula pazīst, ar tā id, un pēc tam:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Joslas paslēpšana

`Super + Shift + Space` izslēdz joslu un ieslēdz to atpakaļ, nenogalinot čaulu — paneļi un karstie taustiņi turpina darboties, tu vienkārši iegūsti atpakaļ pikseļus. Tas ir arī izvēlnē sadaļā **Izskats → Izvēlņu josla → Paslēpt joslu**.

## Konfigurācijas fails

Viss tas glabājas `~/.config/omarchy/shell.json` ar atslēgu `bar`. Šeit ir saīsinātā versija:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "centerBegin": [{ "id": "omarchy.indicators" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "centerEnd": [{ "id": "omarchy.weather" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Katrs logrīks ir viens ieraksts vienā no pieciem izkārtojuma masīviem, un tā iestatījumi atrodas tieši šajā ierakstā — nav atsevišķa iestatījumu faila un nav `config` apakšobjekta. Pulksteņa `format`, `formatAlt` (uz ko pārslēdzas ar labo klikšķi) un `verticalFormat` visi atrodas tieši turpat uz `{ "id": "omarchy.clock" }`.

`center` ir kaste joslas vidū: viss tajā kā viena grupa ir centrēts uz ekrāna. `centerBegin` un `centerEnd` karājas abās kastes pusēs, un tā pulkstenis paliek pavisam centrā pat tad, kad laikapstākļi un atjauninājuma nozīmīte nāk un iet. Ieliec `center` vairāk nekā vienu logrīku, un tie tiks centrēti kopā; atstāj to tukšu, un `centerBegin` un `centerEnd` satiksies joslas vidū.

Viens noteikums, ko vērts iegaumēt: **tiklīdz tev ir savs `shell.json`, tas ir kanoniskais**. Kamēr neko nepielāgo, čaula lasa Omarchy noklusējuma failu. Tiklīdz tu pārvilksi logrīku, palaidīsi `omarchy bar` vai pats rediģēsi failu, tas pieder tev — nav dziļas sapludināšanas, tāpēc jauni noklusējuma logrīki turpmākajos Omarchy izlaidumos tavā joslā automātiski neparādīsies. `omarchy bar defaults` atjauno piegādāto izkārtojumu ikreiz, kad vēlies tīru lapu.

Tajā pašā failā augšējā līmenī, ārpus atslēgas `bar`, glabājas arī tavi dīkstāves laiki: `idle.screensaver` un `idle.lock`, abi sekundēs kopš brīža, kad pārgāji dīkstāvē. Tāpēc noklusējuma ekrānsaudzētājs ieslēdzas pēc 150 sekundēm un bloķēšana pēc 300.
