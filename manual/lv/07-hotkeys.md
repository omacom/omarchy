# Karstie taustiņi

Visas galvenās tastatūras saīsnes varat apskatīt ar `Super + K` (Tmux saīsnes ar `Super + Alt + K` un Herdr saīsnes ar `Super + Ctrl + K`).

## Kā karstie taustiņi ir sakārtoti

Katrs karstais taustiņš atrodas savā plaknē, ko nosaka tā modifikatori, un katrai plaknei ir viens uzdevums. Tas neļauj karstajiem taustiņiem saplūst kopā, un tas nozīmē, ka parasti varat uzminēt, kur kas atrodas.

| Plakne | Kas tur atrodas | Piemēri |
| --- | --- | --- |
| `Super + key` | Sistēma: logi, darbvietas, izkārtojumi un galvenās izvēlnes | `Super + Space` Omarchy izvēlne, `Super + W` aizvērt logu, `Super + F` pilnekrāns |
| `Super + Shift + key` | Lietotnes | `Super + Shift + B` pārlūks, `Super + Shift + E` e-pasts, `Super + Shift + N` redaktors |
| `Super + Ctrl + key` | Paneļi un sistēmas izvēlnes | `Super + Ctrl + A` audio, `Super + Ctrl + N` tīkls, `Super + Ctrl + C` uztveršanas izvēlne |
| `Super + Ctrl + Alt + key` | Ātrās darbības un paziņojumi | `Super + Ctrl + Alt + T` rādīt laiku, `Super + Ctrl + Alt + B` akumulators, `Super + Ctrl + Alt + C` ekrānuzņēmums |

`Alt` pievienošana karstajam taustiņam dod tā paša variāciju, nekad kaut ko nesaistītu:

- `Super + Shift + B` atver pārlūku; `Super + Shift + Alt + B` atver privātu logu
- `Super + Shift + E` atver e-pastu; `Super + Shift + Alt + E` sāk jaunu
- `Super + F` pāriet pilnekrānā; `Super + Alt + F` pāriet pilnā platumā
- `Super + Ctrl + C` atver uztveršanas izvēlni; `Super + Ctrl + Alt + C` izlaiž izvēlni un uzņem ekrānuzņēmumu

Kad pievienojat karsto taustiņu:

1. Izvēlieties plakni pēc tā, ko tas dara, pēc tam izvēlieties taustiņu.
2. Nepārvietojiet esošu karsto taustiņu, lai atbrīvotu vietu. Atrodiet brīvu taustiņu pareizajā plaknē.
3. Izmantojiet `Alt` tikai tā karstā taustiņa variantam, kuram tā nav.

Daži karstie taustiņi pārkāpj šos noteikumus, jo tā ir ērti. `Shift` ar bultiņu vai `Tab` pārvieto vai maina virzienu, nevis atver lietotni, un `Print`, multivides taustiņi, `Alt + Tab` un `Ctrl + Alt + Del` darbojas tāpat kā visur citur. Tie ir izņēmumi, nevis paraugi, ko kopēt.

Ja noklusējums jums neder (piemēram, vēlaties `Super + Shift + S` ekrānuzņēmumiem kā Windows), pārsaistiet to failā `~/.config/hypr/bindings.lua`.

## Navigācija

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy izvēlne (lietotnes un viss pārējais)    |
| `Super + Alt + Space` | Lietotņu režģis |
| `Super + Escape` | Sistēmas izvēlne (miegs, restartēšana u.c.)  |
| `Super + Ctrl + L` | Bloķēt datoru |
| `Super + W` vai `Super + Q` | Aizvērt logu             |
| `Ctrl + Alt + Del` | Aizvērt visus logus |
| `Super + K` | Rādīt visus karstos taustiņus |
| `Super + Alt + K` | Rādīt tmux karstos taustiņus |
| `Super + Ctrl + K` | Rādīt herdr karstos taustiņus |
| `Super + M` | Minimizēt logu uz doku |
| `Super + T`               | Pārslēgt logu starp mozaīkas/peldošo režīmu             |
| `Super + J` | Pārslēgt loga pozīciju (horizontāla/vertikāla) |
| `Super + O`               | Pārslēgt loga izlekšanu lipīgajā un peldošajā režīmā |
| `Super + L`               | Cikliski pārslēgt dwindle, ritināšanas un peldošo izkārtojumu |
| `Super + Alt + L`         | Cikliski pārslēgt izkārtojumus pretējā virzienā |
| `Super + P`               | Pārslēgt pseidologa stilu (dabiskais pret izstiepto) |
| `Super + F`                 | Pāriet pilnekrānā              |
| `Super + Alt + F`                 | Pāriet pilnā platumā              |
| `Super + Ctrl + F`                 | Pāriet pilnekrānā loga iekšpusē              |
| `Super + 1…9/0`         | Pāriet uz konkrētu darbvietu (0 ir 10) fokusētajā monitorā |
| `Super + Tab` | Pāriet uz nākamo darbvietu fokusētajā monitorā |
| `Super + Shift + Tab` | Pāriet uz iepriekšējo darbvietu fokusētajā monitorā |
| `Super + Ctrl + Tab` | Pāriet uz agrāko darbvietu fokusētajā monitorā |
| `Super + Shift + 1…9/0` | Pārvietot logu uz darbvietu fokusētajā monitorā |
| `Super + Shift + Alt + 1…9/0` | Pārvietot logu uz darbvietu fokusētajā monitorā, nesekojot līdzi |
| `Super + S` | Pārslēgt pilno scratchpad |
| `Super + Alt + S` | Pārvietot logu uz pilno scratchpad |
| `Super + Grave` | Pārslēgt Quake konsoli |
| `Super + Shift + Grave` | Pārvietot logu uz Quake konsoli |
| `Super + Shift + Ctrl + Arrows` | Pārvietot logu uz monitoru tajā virzienā |
| `Super + Shift + Alt + Arrows` | Pārvietot darbvietu uz monitoru tajā virzienā |
| `Super + Arrow`  | Pārvietot fokusu uz logu bultiņas virzienā, ekrāna malā pārejot uz monitoru tajā pusē |
| `Super + Shift + Arrow`  | Apmainīt logu ar citu bultiņas virzienā, ieskaitot logu monitorā tajā pusē |
| `Super + Minus` | Izplest logu pa kreisi |
| `Super + Equal` | Sašaurināt logu pa kreisi |
| `Super + Shift + Minus` | Sašaurināt logu uz augšu |
| `Super + Shift + Equal` | Izplest logu uz leju |
| `Super + Alt + Minus/Equal` | Tā pati izmēra maiņa mazākos soļos |
| `Super + Ctrl + Minus/Equal` | Tā pati izmēra maiņa lielākos soļos |
| `Super + Alt + Home` | Saglabāt loga platumu |
| `Super + Home` | Atjaunot saglabāto loga platumu |
| `Super + Left Mouse` | Vilkt logu apkārt |
| `Super + Right Mouse` | Mainīt loga izmēru |
| `Super + Scroll Wheel` | Ritināt cauri darbvietām fokusētajā monitorā |
| `Super + G`               | Pārslēgt logu grupēšanu      |
| `Super + Alt + G`               | Pārvietot logu ārā no grupas      |
| `Super + Alt + Tab`               | Cikliski pārslēgt logus grupā      |
| `Super + Alt + Shift + Tab`               | Cikliski pārslēgt logus grupā atpakaļgaitā      |
| `Super + Alt + Scroll Wheel` | Cikliski pārslēgt logus grupā |
| `Super + Alt + 1/2/3/4/5`               | Pāriet uz konkrētu logu grupā      |
| `Super + Alt + Arrow`  | Pārvietot logu grupā bultiņas virzienā, ieskaitot logu monitorā tajā pusē |
| `Super + Ctrl + Left/Right`  | Pārvietoties starp logiem mozaīkas grupas iekšpusē |
| `Super + Ctrl + Z` | Tuvināt ekrānu (atkārtot, lai tuvinātu vēl) |
| `Super + Ctrl + Alt + Z` | Pilnībā attālināt ekrānu |
| `Super + /` | Iet uz priekšu cauri monitora mērogošanas iespējām |
| `Super + Alt + /` | Iet atpakaļ cauri monitora mērogošanas iespējām |
| `Alt + Tab` | Cikliski iet uz priekšu cauri logiem aktīvajā darbvietā |
| `Alt + Shift + Tab` | Cikliski iet atpakaļ cauri logiem aktīvajā darbvietā |
| `Ctrl + Alt + Tab`| Cikliski pārvietot fokusu uz priekšu cauri monitoriem |
| `Ctrl + Alt + Shift + Tab`| Cikliski pārvietot fokusu atpakaļ cauri monitoriem |
| `Super + I` | Pārslēgt ievades valodu (ar vairāk nekā vienu izkārtojumu vai ievades metodi) |
| `Super + Shift + I` | Pārslēgt ievades valodu atpakaļ |

Uz skārienpaliktņa trīs un četru pirkstu vilcieni pārslēdz darbvietas, pārvieto logus un atver izvēlni un Quake konsoli; skatiet [tastatūra, pele un skārienpaliktnis](34-keyboard-mouse-trackpad.md), lai uzzinātu par žestiem.

Izmēra maiņas saīsnes izmanto fiziskos taustiņus `code:20` un `code:21` (XKB `<AE11>` un `<AE12>`), neatkarīgi no rakstzīmēm, kas uzdrukātas uz tastatūras. Uz ASV tastatūrām šie taustiņi ir `-` un `=`; uz Japānas (JIS) tastatūrām tie ir `-` un `^`; uz Spānijas tastatūrām tie ir `'` un `¡`. Uz JIS `Super + ^` ir `Super + Equal`, savukārt `Super + Shift + -` (kas raksta `=`) ir `Super + Shift + Minus`.

## Sistēmas vadība

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Audio panelis    |
| `Super + Ctrl + B`           | Bluetooth panelis    |
| `Super + Ctrl + N`           | Wi-Fi/tīkla panelis    |
| `Super + Ctrl + D`           | Displeja panelis    |
| `Super + Ctrl + P`           | Barošanas panelis    |
| `Super + Ctrl + X`           | Aģentu panelis    |
| `Super + Ctrl + Alt + X`           | Lokālo modeļu panelis    |
| `Super + Ctrl + Alt + D`           | Kalendāra panelis    |
| `Super + Ctrl + Alt + E`           | Pasaules pulksteņa panelis    |
| `Super + Ctrl + 1-9`           | Pārslēgt joslas paneli pēc pozīcijas    |
| `Super + Ctrl + S` | Kopīgošanas izvēlne (caur LocalSend) |
| `Super + Ctrl + C` | Uztveršanas vadība (ekrānuzņēmums/-ieraksts/atlasītājs) |
| `Super + Ctrl + O` | Pārslēgt izvēlni |
| `Super + Ctrl + H` | Aparatūras izvēlne |
| `Super + Ctrl + E` | Emocijzīmju atlasītājs |
| `Super + Ctrl + .` | Pārkodēt multividi |
| `Super + Shift + Ctrl + A` | Izvēlēties AI aģentu |
| `Power` taustiņš | Sistēmas izvēlne |
| `Super + Shift + Copilot` taustiņš | Omarchy izvēlne |

## Pielāgojumi

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimālais ekrāna spilgtums |
| `Shift + Brightness Down` | Minimālais ekrāna spilgtums |
| `Alt + Brightness Up/Down` | Precīzas 1% spilgtuma izmaiņas |
| `Alt + Volume Up/Down` | Precīzas 1% skaļuma izmaiņas |
| `Keyboard Brightness Up/Down` | Tastatūras izgaismojums spožāks/blāvāks |
| `Keyboard Backlight` | Cikliski pārslēgt tastatūras izgaismojuma līmeņus |
| `Ctrl + Brightness Up/Down` | Tastatūras izgaismojums spožāks/blāvāks tastatūrām bez saviem taustiņiem |
| `Mic Mute` | Apklusināt mikrofonu |
| `Shift + Mute` | Pārslēgt audio izeju |
| `Touchpad Toggle` | Ieslēgt vai izslēgt skārienpaliktni |
| `Display` taustiņš | Cikliski pārslēgt darbvietas izkārtojumu |
| `Alt + Play` | Nākamais skaņdarbs |
| `Alt + Shift + Play` | Iepriekšējais skaņdarbs |

## Lietotņu palaišana

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminālis    |
| `Super + Alt + Return` | Tmux terminālis |
| `Super + Ctrl + Return` | Herdr (aģentu pārvaldnieks) |
| `Super + Shift + Return` vai `Super + Shift + B`  | Pārlūks    |
| `Super + Shift + Alt + B`           | Pārlūks (privāts/inkognito)    |
| `Super + Shift + F`           | Failu pārvaldnieks    |
| `Super + Shift + Alt + F`           | Failu pārvaldnieks termināļa cwd    |
| `Super + Shift + M`           | Mūzika (Spotify)    |
| `Super + Shift + Alt + M`           | Mūzika (cliamp)    |
| `Super + Shift + /`           | Paroļu pārvaldnieks (1password)    |
| `Super + Shift + Q` vai `Calculator` taustiņš  | Kalkulators (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, kad instalēts)    |
| `Super + Shift + T`           | Aktivitāte (btop)    |
| `Super + Shift + N`           | Redaktors (Plain vai jūsu izvēlētais noklusējums)  |
| `Super + Shift + C`           | Kalendārs ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-pasts ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Jauns e-pasts ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Ziņojumapmaiņa (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Ziņojumapmaiņa (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Ziņojumapmaiņa (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Rakstīšana (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (jauns ieraksts) |
| `Super + Shift + Y`           | YouTube |

Mainiet/pievienojiet saistījumus failā `~/.config/hypr/bindings.lua`.

## Universālā starpliktuve

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + A`           | Atlasīt visu lietotnēs, kas atbalsta `Ctrl + A`    |
| `Super + C`           | Kopēt    |
| `Super + X`           | Izgriezt (ne terminālī)    |
| `Super + V`           | Ielīmēt    |
| `Super + Ctrl + V`           | Starpliktuves pārvaldnieks    |

Parasti Linux sistēmā jums vajag `Ctrl + Shift + C/V`, lai kopētu un ielīmētu terminālī, un `Ctrl + C/V`, lai to darītu visur citur. Šie Omarchy vienotie starpliktuves karstie taustiņi darbojas visur.

## Uztveršana

| Karstais taustiņš              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Ekrānuzņēmums                      |
| `Super + Ctrl + Alt + C`            | Ekrānuzņēmums (tas pats uzņēmums tastatūrām bez Print Screen taustiņa) |
| `Super + Ctrl + C` | Uztveršanas izvēlne |
| `Alt + Print Screen`            | Ekrāna ieraksts                     |
| `Super + Shift + Ctrl + Alt + C` | Ekrāna ieraksts bez audio, izlaižot izvēlni (nospiediet vēlreiz, lai apturētu) |
| `Super + Print Screen` | Krāsu atlasītājs |
| `Super + Ctrl + Print Screen` | Teksta izvilkšana uz starpliktuvi |
| `Super + Alt + [` | Ieraksta laikā padarīt tīmekļa kameras pārklājumu mazāku |
| `Super + Alt + ]` | Ieraksta laikā padarīt tīmekļa kameras pārklājumu lielāku |
| `Alt + Shift + L` | Kopēt pašreizējo URL no tīmekļa lietotnes vai pārlūka |
| `Alt + Shift + D` | Lejupielādēt pašreizējās lapas video uz `~/Videos` |
| `Alt + Space` | Sākt/apturēt diktēšanu (nepieciešams _Iestatīšana > Noklusējumi > Diktēšana_) |
| `Right Alt` | Turēt, lai diktētu (nepieciešams _Iestatīšana > Noklusējumi > Diktēšana_) |

Ar ekrāna ierakstiem karstais taustiņš vispirms jautā, kuru audio vēlaties, pēc tam sāk ierakstu. Nospiediet to vēlreiz, lai apturētu. Skatiet [ekrānuzņēmumi un ierakstīšana](12-screenshots-recording.md), lai uzzinātu detaļas.

Visas uztveršanas iespējas ir pieejamas arī sadaļā _Aktivizētājs > Uztveršana_ Omarchy izvēlnē (`Super + Space`).

## Paziņojumi

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + ,` | Rīkoties ar jaunāko paziņojumu: atvērt to vai nospiest tā vienīgo pogu, izvēlēties no tā izvēlēm vai noraidīt to, ja tam nav nevienas  |
| `Super + Shift + ,` | Noraidīt visus paziņojumus |
| `Super + Ctrl + ,` | Vadīt paziņojumus ar tastatūru  |
| `Super + Alt + ,` | Noraidīt jaunāko paziņojumu  |
| `Super + Shift + Alt + ,` | Atvērt paziņojumu vēsturi  |
| `Super + Ctrl + Alt + ,` | Pārslēgt paziņojumu apklusināšanu  |

## Stils

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Izvēlēties jaunu motīvu (arī `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Izvēlēties motīva fonu (arī `Super + Ctrl + Space`) |
| `Super + Backspace` | Pārslēgt loga caurspīdīgumu |
| `Super + Ctrl + Backspace` | Pārslēgt viena loga kvadrātveida malu attiecību |

Papildu fona attēli atrodas `~/.config/omarchy/backgrounds/<theme name>`. Pieejams arī caur _Instalēšana > Stils > Fons_ Omarchy izvēlnē.

Visas stila iespējas ir pieejamas arī sadaļā _Izskats_ Omarchy izvēlnē (`Super + Space`).

## Pārslēgumi

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Pārslēgt bloķēšanu dīkstāvē |
| `Super + Ctrl + Delete` | Pārslēgt klēpjdatora displeja ieslēgšanu/izslēgšanu |
| `Super + Ctrl + Alt + Delete` | Pārslēgt klēpjdatora displeja spoguļošanu |
| `Super + Shift + Space` | Pārslēgt augšējo joslu  |
| `Shift + Mute` | Pārslēgties uz nākamo audio izeju |
| `Shift + Play` | Pārslēgties uz nākamo multivides avotu |
| `Super + Shift + Backspace` | Pārslēgt logu atstarpes |
| `Super + Ctrl + Alt + F` | Pārslēgt pilnekrāna darbvirsmu (augšējā josla + logu atstarpes) |

## Atgādinājumi

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Iestatīt atgādinājumu  |
| `Super + Ctrl + Alt + R` | Skatīt visus atgādinājumus  |
| `Super + Ctrl + Shift + R` | Notīrīt visus atgādinājumus  |

## Informatīvie paziņojumi

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Rādīt laiku kā paziņojumu  |
| `Super + Ctrl + Alt + B` | Rādīt akumulatoru kā paziņojumu  |
| `Super + Ctrl + Alt + W` | Pārslēgt laikapstākļus kā paziņojumu  |

## Tmux

Prefiksa taustiņš ir `Ctrl + Space` (darbojas arī `Ctrl + B`). Šos saistījumus varat mainīt failā `~/.config/tmux/tmux.conf`.

### Rūtis

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + v` | Sadalīt rūti blakus (vertikāli) |
| `Prefix + h` | Sadalīt rūti zemāk (horizontāli) |
| `Prefix + x` | Nogalināt rūti |
| `Prefix + z` | Pārslēgt rūts tālummaiņu (pilnekrāns) |
| `Alt + Enter` | Sadalīt rūti zemāk (bez prefiksa) |
| `Alt + Shift + Enter` | Sadalīt rūti blakus (bez prefiksa) |
| `Alt + Escape` | Nogalināt rūti (bez prefiksa) |
| `Ctrl + Alt + Arrows` | Pārvietoties starp rūtīm |
| `Ctrl + Alt + Shift + Arrows` | Mainīt rūšu izmēru |

### Logi

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + c` | Jauns logs |
| `Prefix + k` | Nogalināt logu |
| `Prefix + r` | Pārdēvēt logu |
| `Alt + 1-9` | Iet uz konkrētu logu |
| `Alt + Arrow Left/Right` | Pārvietoties starp logiem |
| `Alt + Shift + Arrow Left/Right` | Pārvietot logu pa kreisi/pa labi |

### Sesijas

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + C` | Jauna sesija |
| `Prefix + K` | Nogalināt sesiju |
| `Prefix + R` | Pārdēvēt sesiju |
| `Prefix + N` | Nākamā sesija |
| `Prefix + P` | Iepriekšējā sesija |
| `Alt + Arrow Up/Down` | Pārvietoties starp sesijām |
| `Prefix + s` | Uzskaitīt sesijas |
| `Prefix + d` | Atvienoties no sesijas |

### Kopēšanas režīms (vi stilā)

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + [` | Ieiet kopēšanas režīmā |
| `v` | Sākt atlasi (kopēšanas režīmā) |
| `y` | Kopēt atlasi (kopēšanas režīmā) |

### Vispārīgi

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + q` | Pārlādēt konfigurāciju |
| `Prefix + ?` | Rādīt Tmux taustiņsaistījumus |
| `Prefix + :` | Komandu uzvedne |

### Tmux izkārtojuma funkcijas

Šīs funkcijas jāpalaiž Tmux sesijas iekšpusē.

| Komanda | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Izveidot izstrādes izkārtojumu ar redaktoru, AI un termināli |
| `tdlm <ai> [<second_ai>]` | Izveidot izstrādes izkārtojumu katrai apakšdirektorijai |
| `tsl <count> <command>` | Izveidot vairāk rūšu spieta izkārtojumu |

## Ghostty terminālis

Ghostty terminālis tiek instalēts, izmantojot _Instalēšana > Terminālis_ Omarchy izvēlnē.

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Jauna sadale zemāk |
| `Ctrl + Shift + O` | Jauna sadale blakus |
| `Ctrl + Alt + Arrows` | Pārvietoties starp sadalēm |
| `Super + Ctrl + Shift + Arrows` | Mainīt sadales izmēru par 10 rindām |
| `Super + Ctrl + Shift + Alt + Arrows` | Mainīt sadales izmēru par 100 rindām |
| `Ctrl + Shift + T` | Jauna cilne  |
| `Ctrl + Shift + Arrows` | Pārvietoties starp cilnēm |
| `Alt + Numbers` | Iet uz konkrētu cilni |
| `Shift + Pg Up/Down` | Ritināt vēsturi |
| `Ctrl + Left mouse` | Atvērt saiti pārlūkā |

## Failu pārvaldnieks

| Karstais taustiņš              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Iet uz ceļu                     |
| `Space`               | Priekšskatīt failu (bultiņas navigē) |
| `Alt + Up`       | Iet uz augšu uz vecākmapi        |

## Neovim (ar lazyvim)

### Navigācija

| Karstais taustiņš                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Rādīt komandu iespējas            |
| `Space Space`              | Atvērt failu ar izplūdušo meklēšanu      |
| `Space E`                  | Pārslēgt sānjoslu                  |
| `Space G G`                | Rādīt git vadību               |
| `Space S G`                | Meklēt faila saturu             |
| `Ctrl + W W`               | Lēkt starp sānjoslu un redaktoru |
| `Ctrl + Left/right arrow`  | Mainīt sānjoslas izmēru          |
| `Shift + H`                      | Iet uz kreiso faila cilni             |
| `Shift + L`                      | Iet uz labo faila cilni            |
| `Space B D`                | Aizvērt faila cilni                  |

### Kamēr esat sānjoslā

| Karstais taustiņš                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `A`                        | Pievienot jaunu failu vecākdirektorijā      |
| `Shift + A`                | Pievienot jaunu apakšdirektoriju vecākdirektorijā    |
| `D`                        | Dzēst izcelto failu/direktoriju     |
| `M`                        | Pārvietot izcelto failu/direktoriju       |
| `R`                        | Pārdēvēt izcelto failu/direktoriju     |
| `?`                        | Rādīt palīdzību visām komandām      |

[Skatiet visus Neovim karstos taustiņus, ko konfigurē LazyVim](https://www.lazyvim.org/keymaps).

## Ātrās emocijzīmes

Varat izmantot `Super + Ctrl + E`, lai parādītu pilnu emocijzīmju atlasītāju, kas atlasi ievietos starpliktuvē, vai arī varat izmantot šīs ātrās piekļuves iespējas.

| Karstais taustiņš       | EM | Norāde       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | smaids      |
| `Shift + CapsLock M C` | 😂 | raudāšana        |
| `Shift + CapsLock M L` | 😍 | mīlestība       |
| `Shift + CapsLock M V` | ✌️ | uzvara    |
| `Shift + CapsLock M H` | ❤️ | sirds      |
| `Shift + CapsLock M Y` | 👍 | jā        |
| `Shift + CapsLock M N` | 👎 | nē         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | vēlme       |
| `Shift + CapsLock M R` | 🤘 | roks       |
| `Shift + CapsLock M K` | 😘 | skūpsts       |
| `Shift + CapsLock M E` | 🙄 | acu griešana    |
| `Shift + CapsLock M I` | 😉 | piemiegšana       |
| `Shift + CapsLock M P` | 🙏 | lūgšana |
| `Shift + CapsLock M D` | 🤤 | siekalošanās      |
| `Shift + CapsLock M M` | 💰 | nauda      |
| `Shift + CapsLock M X` | 🎉 | xellebrate |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | tosts      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | sveiciens |
| `Shift + CapsLock M A` |💪 | roka |
| `Shift + CapsLock M B` |🤯 | pūšana |

## Ātrās pabeigšanas

| Karstais taustiņš       | Pabeigšana       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (garā domuzīme)   |
| `Shift + CapsLock Space N` | Jūsu vārds (kā ievadīts iestatīšanas laikā)  |
| `Shift + CapsLock Space E` | Jūsu e-pasts (kā ievadīts iestatīšanas laikā)  |

Varat pievienot vēl savas, rediģējot `~/.XCompose`, pēc tam terminālī palaižot `omarchy restart xcompose`, lai izmaiņas tiktu uztvertas.
