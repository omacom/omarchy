# Augšējā josla

Josla gar ekrāna augšmalu ir Omarchy josla. Tā nav pieskrūvēta statusa josla, bet gan Omarchy apvalka daļa — viena ilgstoši darbojošās Quickshell procesa daļa, kas zīmē arī izvēlni, paziņojumus, OSD uznirstošos logus un bloķēšanas ekrānu. Tāpēc tā tematiski lieliski sader ar visu pārējo un tāpēc panelis atveras uzreiz, nevis palaiž jaunu lietotni.

Tā ir arī vienīgā darbvirsmas daļa, kas vienmēr ir ekrānā, tāpēc ir vērts zināt, ko dara visi tie mazie simboli.

## Kas tajā ir pēc noklusējuma

Joslai ir trīs sadaļas. Kreisajā pusē atrodas Omarchy logotips (izvēlnes palaidējs) un darbvietu indikatori. Centrā ir statusa indikatori, pulkstenis, Elsewhen (pasaules pulkstenis), laikapstākļi un Omarchy atjauninājumu nozīmīte. Labajā pusē: sistēmas paplāte, tastatūras izkārtojums (kad ir konfigurēts vairāk nekā viens izkārtojums vai ievades metode), aģenti, Bluetooth, tīkls, audio, displejs un barošana.

Daži no tiem parādās tikai tad, kad tiem ir ko teikt. Tastatūras izkārtojums parādās tikai tad, ja esat konfigurējuši vairāk nekā vienu izkārtojumu vai ievades metodi. Atjauninājumu nozīmīte parādās tikai tad, kad gaida Omarchy atjauninājums.

## Klikšķināšana apkārt

Gandrīz katrs logrīks kaut ko dara ar kreiso, labo un vidējo klikšķi, un vairāki reaģē uz ritināšanu. Šī ir daļa, ko cilvēki palaiž garām — labajā un vidējā pogā slēpjas daudz kā laba.

| Logrīks | Kreisais | Labais | Vidējais / ritināšana |
| --- | --- | --- | --- |
| Izvēlne | Omarchy izvēlne | Jauns terminālis | — |
| Darbvietas | Fokusēt šo darbvietu šajā monitorā | — | Ritināt: nākamā/iepriekšējā darbvieta |
| Pulkstenis | Kalendāra uznirstošais logs | Cikliski mainīt etiķetes formātu | Vidējais: laika joslu izvēlne |
| Pasaules pulkstenis | Pasaules pulksteņa panelis | Atsvaidzināt | Vidējais: atsvaidzināt |
| Laikapstākļi | Prognozes uznirstošais logs | Pilni laikapstākļi kā paziņojums | Vidējais: atsvaidzināt |
| Audio | Audio panelis | Izslēgt skaņu | Vidējais: panelis · ritināt: skaļums |
| Mikrofons | Izslēgt mikrofonu | — | Vidējais: audio panelis · ritināt: ievades skaļums |
| Tīkls | Tīkla panelis | — | — |
| Bluetooth | Bluetooth panelis | Pārslēgt radio moduli | — |
| Displejs | Displeja panelis | — | Ritināt: spilgtums |
| Barošana | Barošanas panelis | Pārslēgt baterijas procentus | — |
| Multivide | Atskaņot/pauzēt | Vāka attēla uznirstošais logs | Vidējais: nākamais · ritināt: iepriekšējais/nākamais |
| Aģenti | Aģentu panelis | Palaist savu aģentu | Vidējais: atsvaidzināt lietojumu |
| Paplāte | Uzturēt kursoru virsū, lai parādītu atvilktni | Ar labo pogu noklikšķināt uz ševrona, lai pārvaldītu | — |
| Omarchy atjauninājums | Palaist atjauninājumu | — | — |

Ne viss šajā tabulā uzreiz ir jūsu joslā. Multivides logrīks (MPRIS pašlaik atskaņotais, ar ritinošu dziesmu un izpildītāju) un mikrofona logrīks abi ir iebūvēti, bet pēc noklusējuma izslēgti — pievienojiet tos, ja vēlaties, kā aprakstīts tālāk.

## Paneļi

Noklikšķinot uz joslas ikonas, atveras panelis, kas ir kārtīgs uznirstošais logs ar slīdņiem, sarakstiem un tastatūras navigāciju, nevis rīka padoms. Katram ir arī īsinājumtaustiņš, tāpēc nekad nav jātrāpa 16 pikseļu simbolam:

| Īsinājumtaustiņš | Panelis |
| --- | --- |
| `Super + Ctrl + A` | Audio |
| `Super + Ctrl + N` | Network |
| `Super + Ctrl + B` | Bluetooth |
| `Super + Ctrl + D` | Display |
| `Super + Ctrl + P` | Power |
| `Super + Ctrl + Alt + D` | Calendar |
| `Super + Ctrl + Alt + E` | World clock |
| `Super + Ctrl + X` | Agents |
| `Super + Ctrl + 1-9` | Pārslēgt n-to paneli labajā sadaļā |

Paneļi nav tikai rādījumi. Tajos jūs faktiski izdarāt pašu lietu:

- **Audio** ir galvenais skaļuma slīdnis, izvades ierīces izvēlne un mikseris katrai lietotnei, lai varētu pieklusināt to vienu pārlūka cilni, neaizskarot neko citu.
- **Network** meklē Wi-Fi, rāda signāla stiprumu, izveido savienojumu un ļauj izvēlēties DNS nodrošinātāju.
- **Bluetooth** uzskaita jūsu ierīces ar pievienošanu/atvienošanu un baterijas līmeņiem.
- **Power** rāda baterijas statistiku, pārslēdz barošanas profilus (tas atceras atsevišķu izvēli baterijai un AC) un parāda daļu sistēmas informācijas.
- **Display** ir spilgtuma slīdnis, teksta lielums, monitora mērogošanas priekšiestatījumi un — kad jums ir vairāk nekā viens ekrāns — vadīklas katram monitoram. Skatiet [monitoriem](33-monitors.md), lai uzzinātu dziļāku stāstu.
- **Clock** atver mēneša režģi ar ISO nedēļu numuriem un mēnešu pārslēgšanu.
- **World clock** uztur rindu katrai pilsētai, ar tās laikapstākļiem un to, kā paiet tās diena. Meklēšana atrod gan mazpilsētas, gan laika joslas, tāpēc Fort Lauderdale ir Fort Lauderdale, nevis New York. Ja augšējā rinda nosauc nepareizu pilsētu, noklikšķiniet uz tās un norādiet, kur atrodaties; izvēlieties vietu citā laika joslā, un sistēmas pulkstenis arī pārcelsies tur, kas ir ērti, kad ceļojat. Novietojiet kursoru virs pilsētas un noklikšķiniet uz personas pogas, lai norādītu, kurš tur dzīvo — vienkārši vārdi vai `@` GitHub lietotājvārdi, lai līdz nāktu arī viņu sejas.

Katrs panelis pieņem gan tastatūru, gan peli: bultiņas pārvieto, Return aktivizē, Tab pāriet uz blakus paneli, un Escape aizver.

`Super + Ctrl + 1-9` skaita paneļus no kreisās uz labo labajā sadaļā, izlaižot paplāti, jo tai nav sava paneļa. Tāpēc numurs atbilst ikonai, uz kuru jūs mērķētu.

### Tailscale un Dropbox

Vēl divi logrīki parādās joslā tikai tad, kad no **Install → Service** instalējat atbilstošo pakalpojumu, un abus ir vērts zināt, jo tie dara vairāk nekā tikai ziņo par statusu.

**Tailscale** panelis pievieno un atvieno tailnet, pārslēdzas starp kontiem un izvēlas izejas mezglu (šajā sarakstā parādās gan jūsu pašu mašīnas, gan Mullvad reģioni). Tas arī pārlūko jūsu mašīnas — un, kad viena ir atlasīta, `s` nosūta tai failus caur Taildrop, kas ir ātrākais veids, kā pārvietot failu uz jūsu tālruni vai citu klēpjdatoru. `c` kopē mašīnas IP, `n` tās nosaukumu un `d` tās pilno DNS nosaukumu. Katrā mašīnas rindā ir arī sūtīšanas poga, ja drīzāk klikšķinātu. Tas pats no termināļa ir `omarchy tailscale send <machine> [file...]`.

**Dropbox** panelis apstrādā pieteikšanos, rāda, cik daudz krātuves esat izmantojuši, un uzskaita nesen sinhronizētos failus.

Jebkura pakalpojuma noņemšana noņem arī tā logrīku no joslas.

## Indikatori

Mazais kopums centrā ir indikatoru logrīks. Tie ir statusa simboli režīmiem, kurus esat ieslēguši: netraucēt, nakts apgaismojums, rindā ievietots [atgādinājums](09-reminders.md), aktīvs ekrāna ieraksts un palikšana nomodā, kā arī brīdinājumi, kamēr ir ieslēgts sudo bez paroles vai kāds ir pieslēdzies attālai sesijai. Tie iedegas, kad režīms ir aktīvs, un citādi paliek malā — novietojiet kursoru tieši blakus tiem, kur sēdētu neaktīvie, lai ielūkotos tajos. Noklikšķinot uz indikatora, šis režīms tiek pārslēgts. Vēl viens ir tikai statusam: attāla sesija iedegas sarkanā krāsā, kamēr kāds ir pieslēdzies šai mašīnai caur gliff.

Ja vēlaties, lai tie vienmēr būtu redzami, logrīkā iestatiet `alwaysShow` uz `true`. Un, ja jūs interesē tikai daži no tiem, uzskaitiet vēlamos `items`: `["Dnd", "Reminder", "NightLight"]`. Jums var būt vairāk nekā viens indikatoru logrīks, tāpēc dažādas sadaļas var rādīt dažādas apakškopas.

## Joslas pārkārtošana

Josla konfigurējas pati. Lai pārvietotu lietas, nav jāatver konfigurācijas fails.

Satveriet tukšu joslas laukumu ap centru un velciet to pret citu ekrāna malu, un josla pārvietosies turp — der kreisā, labā, augšējā un apakšējā mala, un katrs logrīks pielāgojas (vertikālās joslas atkāpjas uz kompaktām, tikai ikonu formām). Klikšķis un turēšana sāk to pašu vilkšanu. Veiciet dubultu kreiso klikšķi tajā pašā tukšajā vietā, lai cikliski mainītu joslas fonu no caurspīdīga uz stiklainu uz necaurspīdīgu. Un velciet jebkuru logrīku, lai to pārkārtotu vai iemestu citā sadaļā; pārējie logrīki pabīdās sānis, lai atbrīvotu vietu tur, kur tas nolīdīs.

Joslas vidus ir kaste: viss, kas tajā atrodas, paliek centrēts kā viena grupa, un logrīki tās abās pusēs karājas pie tās malām. Kamēr velkat logrīku, kaste parādās kā kontūra vai, kad tā ir tukša, kā līnija pāri joslai, un jūs varat nomest tajā vai tai blakus. Kad nomešana nonāktu kastē, kaste izaug, lai uzņemtu logrīku.

Logrīku, kuru vēlaties tuvumā, bet ne vienmēr redzeslokā, var ievietot paplātes atvilktnē: uzvelciet to uz paplātes, un atvilktne atvērsies, lai to uzņemtu. Tas tur atrodas aiz lietotņu ikonām, parādās ikreiz, kad parādās atvilktne, un tur savu atvilktni atvērtu, kamēr ir atvērts tā panelis. Velciet to atpakaļ uz joslas, lai to atgrieztu.

Ja vēlaties izvēlēties no izvēlnes, **Appearance → Menu Bar** ir pozīcija, bet **Bar Background** izvēlas, kā josla tiek zīmēta: **Opaque Bar**, **Glassy Bar** (caurspīdīga, ar izpludinātu to, kas atrodas aiz tās) vai **Clear Bar**.

Tām pašām lietām ir komandas, kas ir tas, ko vēlaties [dotfiles](31-dotfiles.md) iestatījumam:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Lai pilnībā pievienotu vai noņemtu logrīku, izmantojiet spraudņu komandas. `omarchy plugin list` izdrukā katru logrīku, ko apvalks zina, ar tā id, un pēc tam:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Joslas paslēpšana

`Super + Shift + Space` pārslēdz joslu izslēgtu un atpakaļ ieslēgtu, nenogalinot apvalku — paneļi un īsinājumtaustiņi turpina darboties, jūs vienkārši iegūstat pikseļus atpakaļ. Tas ir arī izvēlnē sadaļā **Appearance → Menu Bar → Hide Bar**.

## Konfigurācijas fails

Viss tiek glabāts `~/.config/omarchy/shell.json` ar atslēgu `bar`. Šeit ir saīsināta versija:

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

Katrs logrīks ir viens ieraksts vienā no pieciem izkārtojuma masīviem, un tā iestatījumi atrodas tieši šajā ierakstā — nav atsevišķa iestatījumu faila un nav `config` apakšobjekta. Pulksteņa `format`, `formatAlt` (uz ko ciklē labais klikšķis) un `verticalFormat` visi atrodas tieši tur, uz `{ "id": "omarchy.clock" }`.

`center` ir kaste joslas vidū: viss tajā ir centrēts ekrānā kā viena grupa. `centerBegin` un `centerEnd` karājas kastes abās pusēs, un tā pulkstenis paliek precīzi centrā pat tad, kad laikapstākļi un atjauninājumu nozīmīte nāk un iet. Ievietojiet `center` vairāk nekā vienu logrīku, un tie tiek centrēti kopā; atstājiet to tukšu, un `centerBegin` un `centerEnd` satiekas joslas vidū.

Viens noteikums, ko vērts iegaumēt: **kad jums ir savs `shell.json`, tas ir kanonisks**. Kamēr neko nepielāgojat, apvalks nolasa Omarchy noklusējuma failu. Tiklīdz velkat logrīku, palaižat `omarchy bar` vai rediģējat failu paši, tas pieder jums — nav dziļas sapludināšanas, tāpēc jauni noklusējuma logrīki turpmākajos Omarchy izlaidumos jūsu joslā automātiski neparādīsies. `omarchy bar defaults` atgriež piegādāto izkārtojumu ikreiz, kad vēlaties tīru lapu.

Tajā pašā failā augšējā līmenī, ārpus atslēgas `bar`, atrodas arī jūsu dīkstāves laiki: `idle.screensaver` un `idle.lock`, abi sekundēs kopš brīža, kad sākāt būt dīkstāvē. Tātad noklusējuma ekrānsaudzētājs ieslēdzas pēc 150 sekundēm, bet bloķēšana — pēc 300.
