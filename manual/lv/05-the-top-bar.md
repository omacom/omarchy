# Augšējā josla

Josla gar ekrāna augšpusi ir Omarchy josla. Tā nav pieskrūvēta statusa josla, bet gan daļa no Omarchy čaulas — viena ilgstoši darbojoša Quickshell procesa, kas arī uzzīmē izvēlni, paziņojumus, OSD uznirstošos logus un bloķēšanas ekrānu. Tāpēc tā tematiski perfekti sader ar visu pārējo un tāpēc panelis atveras acumirklī, nevis palaiž jaunu lietotni.

Tā ir arī vienīgā darbvirsmas daļa, kas vienmēr atrodas uz ekrāna, tāpēc ir vērts zināt, ko dara visas tās mazās zīmes.

## Kas tajā ir pēc noklusējuma

Joslai ir trīs sadaļas. Kreisajā pusē atrodas Omarchy logotips (izvēlnes palaidējs) un darbvietu indikatori. Centrā jūs iegūstat statusa indikatorus, pulksteni, Elsewhen (pasaules pulksteni), laikapstākļus un Omarchy atjauninājuma nozīmīti. Labajā pusē: sistēmas paplāte, tastatūras izkārtojums (kad ir konfigurēts vairāk nekā viens), aģenti, Bluetooth, tīkls, audio, displejs un barošana.

Daži no tiem parādās tikai tad, kad tiem ir ko teikt. Tastatūras izkārtojums parādās tikai tad, ja esat konfigurējis vairāk nekā vienu izkārtojumu. Atjauninājuma nozīmīte parādās tikai tad, kad gaida kāds Omarchy atjauninājums. Un aģentu ikona parādās pirmo reizi, kad Omarchy atrod datorā AI kodēšanas lietojumu (skatiet [AI](17-ai.md)).

## Klikšķināšana

Gandrīz katrs logrīks kaut ko dara ar kreiso, labo un vidējo klikšķi, un vairāki reaģē uz ritināšanu. Šī ir daļa, ko cilvēki palaiž garām — labajā un vidējā pogā slēpjas daudz labumu.

| Logrīks | Kreisais klikšķis | Labais klikšķis | Vidējais klikšķis / ritināšana |
| --- | --- | --- | --- |
| Izvēlne | Omarchy izvēlne | Jauns terminālis | — |
| Darbvietas | Fokusēt šo darbvietu šajā monitorā | — | Ritināt: nākamā/iepriekšējā darbvieta |
| Pulkstenis | Kalendāra uznirstošais logs | Cikliski mainīt etiķetes formātu | Vidējais klikšķis: laika joslu izvēle |
| Laikapstākļi | Prognozes uznirstošais logs | Pilni laikapstākļi kā paziņojums | Vidējais klikšķis: atsvaidzināt |
| Audio | Audio panelis | Izslēgt skaņu | Vidējais klikšķis: panelis · ritināt: skaļums |
| Mikrofons | Izslēgt mikrofonu | — | Vidējais klikšķis: audio panelis · ritināt: ievades skaļums |
| Tīkls | Tīkla panelis | — | — |
| Bluetooth | Bluetooth panelis | Pārslēgt radio | — |
| Displejs | Displeja panelis | — | Ritināt: spilgtums |
| Barošana | Barošanas panelis | Pārslēgt akumulatora procentus | — |
| Multivide | Atskaņot/pauzēt | Vāka noformējuma uznirstošais logs | Vidējais klikšķis: nākamais · ritināt: iepriekšējais/nākamais |
| Aģenti | Aģentu panelis | Palaist jūsu aģentu | Vidējais klikšķis: nākamais abonements |
| Paplāte | Uzturēt kursoru virs tās, lai atklātu atvilktni | Labais klikšķis uz bultiņas, lai pārvaldītu | — |
| Omarchy atjauninājums | Palaist atjauninājumu | — | — |

Ne viss šajā tabulā sākotnēji ir jūsu joslā. Gan multivides logrīks (MPRIS pašlaik atskaņotais ieraksts ar ritinošu ieraksta nosaukumu un izpildītāju), gan mikrofona logrīks ir iebūvēti, bet pēc noklusējuma izslēgti — pievienojiet tos, ja vēlaties, kā aprakstīts tālāk.

## Paneļi

Noklikšķinot uz joslas ikonas, tiek atvērts panelis, kas ir īsts uznirstošais logs ar slīdņiem, sarakstiem un tastatūras navigāciju, nevis rīka padoms. Katram ir arī karstais taustiņš, tāpēc jums nekad nav jāmērķē uz 16 pikseļu zīmi:

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

Paneļi nav tikai rādījumi. Tajos jūs faktiski paveicat attiecīgo darbu:

- **Audio** piedāvā galvenā skaļuma slīdni, izvades ierīces izvēli un mikseri katrai lietotnei, lai jūs varētu pieklusināt vienu pārlūka cilni, neaizskarot visu pārējo.
- **Tīkls** meklē Wi-Fi, rāda signāla stiprumu, izveido savienojumus un ļauj izvēlēties DNS pakalpojumu sniedzēju.
- **Bluetooth** uzskaita jūsu ierīces ar savienošanu/atvienošanu un akumulatora līmeņiem.
- **Barošana** rāda akumulatora statistiku, pārslēdz barošanas profilus (tas atceras atsevišķu izvēli akumulatoram un AC) un izdrukā daļu sistēmas informācijas.
- **Displejs** piedāvā spilgtuma slīdni, teksta izmēru, monitora mērogošanas priekšiestatījumus un — ja jums ir vairāk nekā viens ekrāns — vadīklas katram monitoram. Padziļinātu stāstu skatiet sadaļā [monitoriem](33-monitors.md).
- **Pulkstenis** atver mēneša režģi ar ISO nedēļu numuriem un mēnešu pārslēgšanu.
- **Pasaules pulkstenis** katrai pilsētai uztur vienu rindu ar tās laikapstākļiem un to, kā rit tās diena. Meklēšana atrod gan mazpilsētas, gan laika joslas, tāpēc Fort Lauderdale ir Fort Lauderdale, nevis Ņujorka. Ja augšējā rindā ir nosaukta nepareizā pilsēta, noklikšķiniet uz tās un norādiet, kur atrodaties; izvēlieties vietu citā laika joslā, un sistēmas pulkstenis arī pārcelsies tur, kas ir noderīgi ceļojot. Novietojiet kursoru virs pilsētas un noklikšķiniet uz personas pogas, lai norādītu, kas tur dzīvo — vienkāršus vārdus vai `@` GitHub lietotājvārdus, lai līdzi paņemtu arī viņu sejas.

Katrs panelis izmanto gan tastatūru, gan peli: bulttaustiņi pārvieto, Return aktivizē, Tab pāriet uz blakus esošo paneli, bet Escape aizver.

`Super + Ctrl + 1-9` skaita paneļus no kreisās uz labo pusi labajā sadaļā, izlaižot paplāti, jo tai nav sava paneļa. Tāpēc numurs atbilst ikonai, uz kuru jūs mērķētu.

### Tailscale un Dropbox

Vēl divi logrīki parādās joslā tikai tad, kad instalējat attiecīgo pakalpojumu no **Instalēt → Pakalpojums**, un abus ir vērts zināt, jo tie dara vairāk nekā tikai ziņo par statusu.

**Tailscale** panelis savieno un atvieno tailnet, pārslēdzas starp kontiem un izvēlas izejas mezglu (šajā sarakstā parādās gan jūsu pašu datori, gan Mullvad reģioni). Tas arī pārlūko jūsu datorus, un, kad viens ir atlasīts, `s` nosūta tam failus, izmantojot Taildrop, kas ir ātrākais veids, kā pārvietot failu uz tālruni vai citu klēpjdatoru. `c` kopē datora IP, `n` — tā nosaukumu, bet `d` — tā pilno DNS nosaukumu. Katrā datora rindā ir arī nosūtīšanas poga, ja labprātāk klikšķināt. No termināļa tas pats ir `omarchy tailscale send <machine> [file...]`.

**Dropbox** panelis apstrādā pieteikšanos, parāda, cik daudz krātuves esat izmantojis, un uzskaita nesen sinhronizētos failus.

Jebkura šī pakalpojuma noņemšana noņem arī tā logrīku no joslas.

## Indikatori

Mazā kopa centrā ir indikatoru logrīks. Tās ir statusa zīmes jūsu ieslēgtajiem režīmiem: netraucēt, nakts gaisma, rindā ievietots [atgādinājums](09-reminders.md), aktīva ekrāna ierakstīšana, palikšana nomodā un [diktēšana](11-text-extraction-dictation.md). Tās iedegas, kad režīms ir aktīvs, un citādi paliek malā — novietojiet kursoru jebkurā vietā uz joslas, lai ielūkotos neaktīvajās. Noklikšķinot uz indikatora, tiek pārslēgts attiecīgais režīms. Vēl viens ir tikai statusam: attālinātā sesija iedegas sarkanā krāsā, kamēr kāds ir savienots ar šo datoru, izmantojot gliff.

Ja vēlaties, lai tie vienmēr būtu redzami, logrīkā iestatiet `alwaysShow` uz `true`. Un, ja jums rūp tikai daži no tiem, parametrā `items` norādiet vēlamos: `["Dnd", "Reminder", "NightLight"]`. Jums var būt vairāk nekā viens indikatoru logrīks, tāpēc dažādas sadaļas var rādīt dažādas apakškopas.

## Joslas pārkārtošana

Josla konfigurējas pati. Jums nav jāatver konfigurācijas fails, lai pārvietotu lietas.

Satveriet tukšu joslas vietu ap centru un velciet to uz citu ekrāna malu, un josla pārvietosies tur — der kreisā, labā, augšējā vai apakšējā mala, un katrs logrīks pielāgojas (vertikālās joslas atgriežas pie kompaktām, tikai ar ikonām, formām). Klikšķis un pieturēšana sāk to pašu vilkšanu. Veiciet dubultklikšķi ar kreiso pogu uz tās pašas tukšās vietas, lai cikliski mainītu joslas fonu no caurspīdīga uz stiklainu un necaurspīdīgu. Velciet jebkuru logrīku, lai to pārkārtotu vai iemestu citā sadaļā; pārējie logrīki pašķiras, lai atbrīvotu vietu tur, kur tas nolaidīsies.

Joslas vidus ir kaste: viss, kas tajā atrodas, paliek centrēts kā viena grupa, un logrīki abās tās pusēs karājas pie tās malām. Kamēr velkat logrīku, kaste parādās kā kontūra vai, kad tā ir tukša, kā līnija pāri joslai, un jūs varat nomest logrīku tajā vai tai blakus. Kad nomešana notiktu kastē, kaste paplašinās, lai uzņemtu logrīku.

Logrīks, ko vēlaties turēt tuvumā, bet ne vienmēr redzeslokā, var nonākt paplātes atvilktnē: velciet to uz paplāti, un atvilktne atvērsies, lai to uzņemtu. Tur tas atrodas aiz lietotņu ikonām, parādās ikreiz, kad parādās atvilktne, un, kamēr tā panelis ir atvērts, tur savu atvilktni atvērtu. Velciet to atpakaļ uz joslu, lai to atgrieztu.

Ja labprātāk izvēlaties no izvēlnes, sadaļā **Izskats → Izvēlņu josla** ir pieejams novietojums, bet **Joslas fons** izvēlas, kā josla tiek zīmēta: **Necaurspīdīga josla**, **Stiklaina josla** (caurredzama, ar izpludinātu fonu aiz tās) vai **Caurspīdīga josla**.

Tām pašām lietām ir arī komandas, kas ir vajadzīgas [dotfiles](31-dotfiles.md) iestatījumam:

```bash
omarchy bar position bottom
omarchy bar background glassy  # opaque, glassy, none, or cycle
omarchy bar move omarchy.weather --section centerBegin --index 0
omarchy bar move omarchy.bluetooth --section tray  # into the tray's drawer
omarchy bar set omarchy.clock format "HH:mm"
omarchy bar defaults          # back to the shipped layout
```

Lai pievienotu vai pilnībā noņemtu logrīku, izmantojiet spraudņu komandas. `omarchy plugin list` izdrukā katru čaulai zināmo logrīku kopā ar tā id, un pēc tam:

```bash
omarchy plugin enable omarchy.media --section centerEnd
omarchy plugin disable omarchy.weather
```

## Joslas slēpšana

`Super + Shift + Space` izslēdz joslu un ieslēdz to atpakaļ, nenogalinot čaulu — paneļi un karstie taustiņi turpina darboties, jūs vienkārši atgūstat pikseļus. Tas ir pieejams arī izvēlnē sadaļā **Izskats → Izvēlņu josla → Paslēpt joslu**.

## Konfigurācijas fails

Viss tiek glabāts failā `~/.config/omarchy/shell.json` zem atslēgas `bar`. Šeit ir saīsināta versija:

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

Katrs logrīks ir viens ieraksts vienā no pieciem izkārtojuma masīviem, un tā iestatījumi atrodas tieši šajā ierakstā — nav atsevišķa iestatījumu faila un nav `config` apakšobjekta. Pulksteņa `format`, `formatAlt` (tas, uz ko cikliski pārslēdz labais klikšķis) un `verticalFormat` visi atrodas tieši tur — uz `{ "id": "omarchy.clock" }`.

`center` ir kaste joslas vidū: viss tajā tiek centrēts uz ekrāna kā viena grupa. `centerBegin` un `centerEnd` karājas abās kastes pusēs, un tāpēc pulkstenis paliek precīzi centrā pat tad, kad laikapstākļi un atjauninājuma nozīmīte parādās un pazūd. Ievietojiet `center` vairāk nekā vienu logrīku, un tie tiks centrēti kopā; atstājiet to tukšu, un `centerBegin` un `centerEnd` satiksies joslas vidū.

Viens noteikums, ko ir vērts iegaumēt: **kad jums ir savs `shell.json`, tas ir kanonisks**. Kamēr neko nepielāgojat, čaula lasa Omarchy noklusējuma failu. Brīdī, kad pavelkat logrīku, palaižat `omarchy bar` vai pats rediģējat failu, tas pieder jums — dziļas sapludināšanas nav, tāpēc jauni noklusējuma logrīki turpmākajos Omarchy laidienos jūsu joslā automātiski neparādīsies. `omarchy bar defaults` atjauno komplektā iekļauto izkārtojumu ikreiz, kad vēlaties sākt no tīras lapas.

Tas pats fails augšējā līmenī, ārpus atslēgas `bar`, glabā arī jūsu dīkstāves laikus: `idle.screensaver` un `idle.lock`, abus sekundēs kopš brīža, kad kļuvāt neaktīvs. Tāpēc noklusējuma ekrānsaudzētājs iedarbojas pēc 150 sekundēm, bet bloķēšana — pēc 300.
