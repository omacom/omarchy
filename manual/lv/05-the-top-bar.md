# Augšējā josla

Josla gar tava ekrāna augšpusi ir Omarchy josla. Tā nav pieskrūvēta statusa josla, bet Omarchy čaulas daļa — viens ilgstoši strādājošs Quickshell process, kas zīmē arī izvēlni, paziņojumus, OSD uznirstošos logus un bloķēšanas ekrānu. Tāpēc tā lieliski saskan ar visu pārējo un tāpēc panelis atveras uzreiz, nevis palaiž jaunu lietotni.

Tā ir arī vienīgā darbvirsmas daļa, kas vienmēr ir ekrānā, tāpēc ir vērts zināt, ko dara visas tās mazās zīmes.

## Kas tajā ir pēc noklusējuma

Joslai ir trīs sadaļas. Kreisajā pusē sēž Omarchy logo (izvēlnes palaidējs) un darbvietu rādītāji. Centrā tu iegūsti statusa rādītājus, pulksteni, Elsewhen (pasaules pulksteni), laikapstākļus un Omarchy atjauninājuma nozīmīti. Labajā pusē: tastatūras izkārtojums (kad konfigurēts vairāk nekā viens), sistēmas tekne, aģenti, bluetooth, tīkls, audio, displejs un barošana.

Daži no tiem parādās tikai tad, kad tiem ir ko teikt. Tastatūras izkārtojums parādās tikai tad, ja esi konfigurējis vairāk nekā vienu izkārtojumu. Atjauninājuma nozīmīte parādās tikai tad, kad gaida Omarchy atjauninājums. Un aģentu ikona parādās pirmo reizi, kad Omarchy iekārtā atrod AI kodēšanas lietojumu (skat. [AI](17-ai.md)).

## Klikšķināšana apkārt

Gandrīz katrs logrīks kaut ko dara ar kreiso, labo un vidējo klikšķi, un vairāki reaģē uz ritināšanu. Šī ir daļa, ko cilvēki palaiž garām — labā un vidējā poga ir vieta, kur slēpjas daudz labu lietu.

| Logrīks | Kreisi | Labi | Vidus / ritināšana |
| --- | --- | --- | --- |
| Izvēlne | Omarchy izvēlne | Jauns terminālis | — |
| Darbvietas | Fokusēt šo darbvietu | — | Ritināšana: nākamā/iepriekšējā darbvieta |
| Pulkstenis | Kalendāra uznirstošais logs | Ciklēt etiķetes formātu | Vidus: laika joslas atlasītājs |
| Laikapstākļi | Prognozes uznirstošais logs | Pilni laikapstākļi kā paziņojums | Vidus: atsvaidzināt |
| Audio | Audio panelis | Izslēgt skaņu | Vidus: panelis · ritināšana: skaļums |
| Mikrofons | Izslēgt mikrofonu | — | Vidus: audio panelis · ritināšana: ievades skaļums |
| Tīkls | Tīkla panelis | — | — |
| Bluetooth | Bluetooth panelis | Pārslēgt radio | — |
| Displejs | Displeja panelis | — | Ritināšana: spilgtums |
| Barošana | Barošanas panelis | Pārslēgt baterijas procentus | — |
| Multivide | Atskaņot/pauzēt | Vāka noformējuma uznirstošais logs | Vidus: nākamais · ritināšana: iepriekšējais/nākamais |
| Aģenti | Aģentu panelis | Palaist savu aģentu | Vidus: nākamais abonements |
| Tekne | Novieto kursoru, lai atklātu atvilktni | Labais klikšķis uz ševrona, lai pārvaldītu | — |
| Omarchy atjauninājums | Palaist atjauninājumu | — | — |

Ne viss šajā tabulā pēc noklusējuma ir tavā joslā. Multivides logrīks (MPRIS pašlaik atskaņotais ar ritinošu ierakstu un izpildītāju) un mikrofona logrīks abi ir iebūvēti, bet pēc noklusējuma izslēgti — pievieno tos, ja vēlies, kā aprakstīts zemāk.

## Paneļi

Noklikšķinot uz joslas ikonas, atveras panelis, kas ir īsts uznirstošais logs ar slīdņiem, sarakstiem un tastatūras navigāciju, nevis rīka padoms. Katram ir arī karstā taustiņa kombinācija, tāpēc tev nekad nav jātēmē uz 16 pikseļu zīmi:

| Karstā taustiņa kombinācija | Panelis |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + W` | Tīkls |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Displejs |
| `Super + Ctrl + P` | Barošana |
| `Super + Ctrl + Alt + D` | Kalendārs |
| `Super + Ctrl + Alt + E` | Pasaules pulkstenis |
| `Super + Ctrl + 1-9` | Pārslēgt n-to paneli labajā sadaļā |

Paneļi nav rādījumi. Tajos tu patiešām dari lietu:

- **Audio** ir galvenā skaļuma slīdnis, izvades ierīces atlasītājs un katras lietotnes mikseris, tāpēc tu vari pieklusināt vienu pārlūka cilni, neaizskarot visu pārējo.
- **Tīkls** skenē Wi-Fi, rāda signāla stiprumu, savienojas un ļauj tev izvēlēties DNS nodrošinātāju.
- **Bluetooth** uzskaita tavas ierīces ar savienošanu/atvienošanu un baterijas līmeņiem.
- **Barošana** rāda baterijas statistiku, pārslēdz barošanas profilus (tā atceras atsevišķu izvēli baterijai un maiņstrāvai) un izdrukā kādu sistēmas informāciju.
- **Displejs** satur spilgtuma slīdni, teksta izmēru, monitora mērogošanas priekšiestatījumus un —, kad tev ir vairāk nekā viens ekrāns —, katra monitora vadīklas. Skat. [monitori](33-monitors.md) dziļākam stāstam.
- **Pulkstenis** atver mēneša režģi ar ISO nedēļu numuriem un mēneša soļošanu.

Katrs panelis pieņem gan tastatūru, gan peli: bultiņas pārvieto, Return aktivizē, Tab soļo uz kaimiņu paneli, un Escape aizver.

`Super + Ctrl + 1-9` skaita paneļus no kreisās uz labo labajā sadaļā, izlaižot tekni, jo tai nav sava paneļa. Tāpēc numurs atbilst ikonai, uz kuru tu norādītu.

### Tailscale un Dropbox

Divus papildu logrīkus joslā parādās tikai tad, kad instalē atbilstošo pakalpojumu no **Instalēt → Pakalpojums**, un abus ir vērts zināt, jo tie dara vairāk nekā ziņo statusu.

**Tailscale** panelis savieno un atvieno tailnet, pārslēdzas starp kontiem un izvēlas izejas mezglu (tavas ierīces un Mullvad reģioni abi parādās šajā sarakstā). Tas arī pārlūko tavas ierīces — un ar vienu atlasītu `s` nosūta tai failus, izmantojot Taildrop, kas ir ātrākais veids, kā pārvietot failu uz tavu tālruni vai citu klēpjdatoru. `c` kopē ierīces IP, `n` tās nosaukumu un `d` tās pilnu DNS nosaukumu. Katrā ierīces rindā ir arī sūtīšanas poga, ja tev labāk patīk klikšķināt. Tas pats no termināla ir `omarchy tailscale send <machine> [file...]`.

**Dropbox** panelis apstrādā pieteikšanos, rāda, cik daudz krātuves esi izmantojis, un uzskaita nesen sinhronizētos failus.

Noņemot jebkuru pakalpojumu, tā logrīks tiek noņemts no joslas.

## Rādītāji

Mazā kopa centrā ir rādītāju logrīks. Tās ir statusa zīmes režīmiem, ko esi ieslēdzis: netraucēt, nakts apgaismojums, rindā esošs [atgādinājums](09-reminders.md), aktīvs ekrāna ieraksts, palikt nomodā un [diktēšana](11-text-extraction-dictation.md). Tie iedegas, kad režīms ir aktīvs, un citādi netraucē — novieto kursoru pa kreisi no pulksteņa (virs tā vertikālā joslā), lai palūrētu uz neaktīvajiem. Noklikšķinot uz rādītāja, šis režīms tiek pārslēgts. Vēl viens ir tikai statusam: attālā sesija iedegas sarkana, kamēr kāds ir savienots ar šo iekārtu caur gliff.

Ja tu labāk vēlētos, lai tie vienmēr būtu redzami, iestati `alwaysShow` uz `true` logrīkā. Un, ja tev rūp tikai daži no tiem, uzskaiti tos, kurus vēlies, sarakstā `items`: `["Dnd", "Reminder", "NightLight"]`. Tev var būt vairāk nekā viens rādītāju logrīks, tāpēc dažādas sadaļas var rādīt dažādas apakškopas.

## Joslas pārkārtošana

Josla konfigurējas pati. Tev nav jāatver konfigurācijas fails, lai pārvietotu lietas.

Satver tukšu joslas daļu ap centru un velc to uz citu ekrāna malu, un josla pārvietojas turp — kreisi, labi, augšā vai apakšā viss darbojas, un katrs logrīks pielāgojas (vertikālās joslas atkāpjas uz kompaktām tikai ikonu formām). Klikšķis un turēšana sāk to pašu vilkšanu. Veic dubultu kreiso klikšķi tajā pašā tukšajā vietā, lai ciklētu joslas fonu no caurspīdīga uz stikla uz necaurspīdīgu. Un velc jebkuru logrīku, lai to pārkārtotu vai iemestu citā sadaļā.

Logrīku, kuru vēlies turēt pa rokai, bet ne vienmēr acu priekšā, vari likt teknes atvilktnē: velc to uz tekni, un atvilktne atvērsies, lai to uzņemtu. Tur tas sēž aiz lietotņu ikonām, parādās katru reizi, kad parādās atvilktne, un tur atvilktni vaļā, kamēr ir atvērts tā panelis. Velc to atpakaļ ārā uz joslu, lai noliktu to atpakaļ.

Ja tu labāk izvēlētos no izvēlnes, **Palaist → Izskats → Izvēlņu josla** ir pozīcija, un **Joslas fons** izvēlas, kā josla tiek zīmēta: **Necaurspīdīga josla**, **Stikla josla** (caurspīdīga, ar to, kas aiz tās, izplūdušu) vai **Caurspīdīga josla**.

Tām pašām lietām ir komandas, kas ir tas, ko tu vēlies [dotfailu](31-dotfiles.md) iestatīšanai:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.clock --section center --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Lai logrīku pievienotu vai noņemtu pilnībā, izmanto spraudņu komandas. `omarchy plugin list` izdrukā katru logrīku, ko čaula zina, ar tā id, un pēc tam:

```bash
omarchy plugin enable omarchy.media --section center
omarchy plugin disable omarchy.weather
```

## Joslas paslēpšana

`Super + Shift + Space` pārslēdz joslu izslēgtu un atkal ieslēgtu, nenogalinot čaulu — paneļi un karstās taustiņu kombinācijas turpina darboties, tu vienkārši iegūsti pikseļus atpakaļ. Tas ir arī izvēlnē zem **Palaist → Izskats → Izvēlņu josla → Paslēpt joslu**.

## Konfigurācijas fails

Viss tas tiek glabāts `~/.config/omarchy/shell.json` zem atslēgas `bar`. Šeit ir saīsināta versija:

```json
{
  "version": 1,
  "bar": {
    "position": "top",
    "background": "opaque",
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left": [{ "id": "omarchy.menu" }, { "id": "omarchy.workspaces" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "right": [{ "id": "omarchy.audio" }, { "id": "omarchy.power" }]
    }
  }
}
```

Katrs logrīks ir viens ieraksts vienā no trim izkārtojuma masīviem, un tā iestatījumi atrodas tieši šajā ierakstā — nav atsevišķa iestatījumu faila un nav `config` apakšobjekta. Pulksteņa `format`, `formatAlt` (uz ko ciklē labais klikšķis) un `verticalFormat` visi dzīvo tieši tur uz `{ "id": "omarchy.clock" }`.

`centerAnchor` nosauc vienu centra logrīku, kas tiek piesprausts precīzā ekrāna centrā, ar pārējiem tam blakus. Tā pulkstenis paliek pašā centrā pat tad, kad laikapstākļi un atjauninājuma nozīmīte nāk un iet. Iestati to uz tukšu virkni, un centra saraksts tā vietā vienkārši tiek centrēts kā grupa.

Viens noteikums, ko ir vērts internalizēt: **kad tev ir savs `shell.json`, tas ir kanonisks**. Kamēr tu neko nepielāgo, čaula lasa Omarchy noklusējuma failu. Tiklīdz tu velc logrīku, palaiž `omarchy bar` vai rediģē failu pats, tas pieder tev — nav dziļas sapludināšanas, tāpēc jauni noklusējuma logrīki nākotnes Omarchy laidienos tavā joslā automātiski neparādīsies. `omarchy bar defaults` atjauno piegādāto izkārtojumu, kad vien vēlies tīru lapu.

Tajā pašā failā augstākajā līmenī, ārpus atslēgas `bar`, atrodas arī tavi dīkstāves laiki: `idle.screensaver` un `idle.lock`, abi sekundēs kopš tu kļuvi dīkstāvē. Tāpēc noklusējuma ekrānsaudzētājs ieslēdzas pēc 150 sekundēm un bloķēšana pēc 300.
