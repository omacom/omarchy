# Karstie taustiņi

Visus galvenos tastatūras īsinājumtaustiņus varat apskatīt ar `Super + K` (Tmux piesaistes ar `Super + Alt + K` un Herdr piesaistes ar `Super + Ctrl + K`).

## Kā karstie taustiņi ir izkārtoti

Katrs karstais taustiņš atrodas uz plaknes, ko nosaka tā modificētāji, un katrai plaknei ir viens uzdevums. Tas neļauj karstajiem taustiņiem saplūst kopā, un tas nozīmē, ka parasti varat uzminēt, kur kas atrodas.

| Plakne | Kas tur atrodas | Piemēri |
| --- | --- | --- |
| `Super + key` | Sistēma: logi, darbvietas, izkārtojumi un galvenās izvēlnes | `Super + Space` Omarchy izvēlne, `Super + W` aizvērt logu, `Super + F` pilnekrāns |
| `Super + Shift + key` | Lietotnes | `Super + Shift + B` pārlūks, `Super + Shift + E` e-pasts, `Super + Shift + N` redaktors |
| `Super + Ctrl + key` | Paneļi un sistēmas izvēlnes | `Super + Ctrl + A` audio, `Super + Ctrl + N` tīkls, `Super + Ctrl + C` tveršanas izvēlne |
| `Super + Ctrl + Alt + key` | Ātrās darbības un paziņojumi | `Super + Ctrl + Alt + T` rādīt laiku, `Super + Ctrl + Alt + B` akumulators, `Super + Ctrl + Alt + C` ekrānuzņēmums |

Pievienojot karstajam taustiņam `Alt`, jūs iegūstat tā paša varianta, nekad kaut ko nesaistītu:

- `Super + Shift + B` atver pārlūku; `Super + Shift + Alt + B` atver privātu logu
- `Super + Shift + E` atver e-pastu; `Super + Shift + Alt + E` sāk jaunu
- `Super + F` pāriet pilnekrānā; `Super + Alt + F` pāriet pilnā platumā
- `Super + Ctrl + C` atver tveršanas izvēlni; `Super + Ctrl + Alt + C` izlaiž izvēlni un uzņem ekrānuzņēmumu

Pievienojot karsto taustiņu:

1. Izvēlieties plakni pēc tā, ko tas dara, pēc tam izvēlieties taustiņu.
2. Nepārvietojiet esošu karsto taustiņu, lai atbrīvotu vietu. Atrodiet brīvu taustiņu uz pareizās plaknes.
3. Lietojiet `Alt` tikai tā karstā taustiņa variantam, kuram tā nav.

Daži karstie taustiņi pārkāpj šos noteikumus, jo tā ir ērtāk. `Shift` ar bultiņu vai `Tab` pārvieto vai apgriež virzienu, nevis atver lietotni, un `Print`, multivides taustiņi, `Alt + Tab` un `Ctrl + Alt + Del` darbojas tāpat kā visur citur. Tie ir izņēmumi, nevis paraugi, ko kopēt.

Ja noklusējums jums neder (teiksim, vēlaties `Super + Shift + S` ekrānuzņēmumiem kā Windows), pārpiesaitiet to failā `~/.config/hypr/bindings.lua`.

## Navigācija

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy izvēlne (lietotnes un viss pārējais)    |
| `Super + Alt + Space` | Lietotņu režģis |
| `Super + Escape` | Sistēmas izvēlne (miera režīms, restartēšana u.c.)  |
| `Super + Ctrl + L` | Bloķēt datoru |
| `Super + W` or `Super + Q` | Aizvērt logu             |
| `Ctrl + Alt + Del` | Aizvērt visus logus |
| `Super + K` | Rādīt visus karstos taustiņus |
| `Super + Alt + K` | Rādīt tmux karstos taustiņus |
| `Super + Ctrl + K` | Rādīt herdr karstos taustiņus |
| `Super + M` | Minimizēt logu uz doku |
| `Super + T`               | Pārslēgt logu starp flīzēšanu/peldošo             |
| `Super + J` | Pārslēgt loga novietojumu (horizontāls/vertikāls) |
| `Super + O`               | Pārslēgt loga pārvēršanu par lipīgu un peldošu |
| `Super + L`               | Cikliski pārslēgties starp dwindle, ritināšanas un peldošo izkārtojumu |
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
| `Super + the key above Tab` (grave on US layouts) | Pārslēgt Quake konsoli |
| `Super + Shift + the key above Tab` (grave on US layouts) | Pārvietot logu uz Quake konsoli |
| `Super + Shift + Ctrl + Arrows` | Pārvietot logu uz monitoru tajā virzienā |
| `Super + Shift + Alt + Arrows` | Pārvietot darbvietu uz monitoru tajā virzienā |
| `Super + Arrow`  | Pārvietot fokusu uz logu bultiņas virzienā, ekrāna malā pārejot uz monitoru tajā pusē |
| `Super + Shift + Arrow`  | Apmainīt logu ar citu bultiņas virzienā, ieskaitot logu monitorā tajā pusē |
| `Super + Minus` | Paplašināt logu pa kreisi |
| `Super + Equal` | Samazināt logu pa kreisi |
| `Super + Shift + Minus` | Samazināt logu uz augšu |
| `Super + Shift + Equal` | Paplašināt logu uz leju |
| `Super + Alt + Minus/Equal` | Tā pati izmēra maiņa mazākos soļos |
| `Super + Ctrl + Minus/Equal` | Tā pati izmēra maiņa lielākos soļos |
| `Super + Alt + Home` | Saglabāt loga platumu |
| `Super + Home` | Atjaunot saglabāto loga platumu |
| `Super + Left Mouse` | Vilkt logu apkārt |
| `Super + Right Mouse` | Mainīt loga izmēru |
| `Super + Scroll Wheel` | Ritināt cauri darbvietām fokusētajā monitorā |
| `Super + G`               | Pārslēgt logu grupēšanu      |
| `Super + Alt + G`               | Izņemt logu no grupēšanas      |
| `Super + Alt + Tab`               | Cikliski pārslēgties starp logiem grupējumā      |
| `Super + Alt + Shift + Tab`               | Cikliski pārslēgties atpakaļ starp logiem grupējumā      |
| `Super + Alt + Scroll Wheel` | Cikliski pārslēgties starp logiem grupējumā |
| `Super + Alt + 1/2/3/4/5`               | Pāriet uz konkrētu logu grupējumā      |
| `Super + Alt + Arrow`  | Ievietot logu grupējumā bultiņas virzienā, ieskaitot logu monitorā tajā pusē |
| `Super + Ctrl + Left/Right`  | Pārvietoties starp logiem flīzēšanas grupas iekšpusē |
| `Super + Ctrl + Z` | Tuvināt ekrānu (atkārtot lielākai tuvināšanai) |
| `Super + Ctrl + Alt + Z` | Pilnībā attālināt ekrānu |
| `Super + /` | Virzīties uz priekšu cauri monitora mērogošanas iespējām |
| `Super + Alt + /` | Virzīties atpakaļ cauri monitora mērogošanas iespējām |
| `Alt + Tab` | Cikliski virzīties uz priekšu cauri logiem aktīvajā darbvietā |
| `Alt + Shift + Tab` | Cikliski virzīties atpakaļ cauri logiem aktīvajā darbvietā |
| `Ctrl + Alt + Tab`| Cikliski virzīt fokusu uz priekšu cauri monitoriem |
| `Ctrl + Alt + Shift + Tab`| Cikliski virzīt fokusu atpakaļ cauri monitoriem |
| `Super + I` | Pārslēgt ievades valodu (ar vairāk nekā vienu izkārtojumu vai ievades metodi) |
| `Super + Shift + I` | Pārslēgt ievades valodu atpakaļ |

Uz skārienpaliktņa trīs un četru pirkstu vilcieni pārslēdz darbvietas, pārvieto logus un atver izvēlni un Quake konsoli; žestus skatiet [tastatūra, pele un skārienpaliktnis](34-keyboard-mouse-trackpad.md).

Izmēra maiņas īsinājumtaustiņi izmanto fiziskos taustiņus `code:20` un `code:21` (XKB `<AE11>` un `<AE12>`), neatkarīgi no tastatūrā uzdrukātajām rakstzīmēm. ASV tastatūrās šie taustiņi ir `-` un `=`; japāņu (JIS) tastatūrās tie ir `-` un `^`; spāņu tastatūrās tie ir `'` un `¡`. JIS tastatūrā `Super + ^` ir `Super + Equal`, savukārt `Super + Shift + -` (kas raksta `=`) ir `Super + Shift + Minus`.

## Sistēmas vadība

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Audio panelis    |
| `Super + Ctrl + B`           | Bluetooth panelis    |
| `Super + Ctrl + N`           | Wifi/tīkla panelis    |
| `Super + Ctrl + D`           | Displeja panelis    |
| `Super + Ctrl + P`           | Barošanas panelis    |
| `Super + Ctrl + X`           | Aģentu panelis    |
| `Super + Ctrl + Alt + X`           | Lokālo modeļu panelis    |
| `Super + Ctrl + Alt + D`           | Kalendāra panelis    |
| `Super + Ctrl + Alt + E`           | Pasaules pulksteņa panelis    |
| `Super + Ctrl + 1-9`           | Pārslēgt joslas paneli pēc pozīcijas    |
| `Super + Ctrl + S` | Kopīgošanas izvēlne (caur LocalSend) |
| `Super + Ctrl + C` | Tveršanas vadība (ekrānuzņēmums/-ieraksts/izvēlētājs) |
| `Super + Ctrl + O` | Pārslēgt izvēlni |
| `Super + Ctrl + H` | Aparatūras izvēlne |
| `Super + Ctrl + E` | Emocijzīmju izvēlētājs |
| `Super + Ctrl + .` | Pārkodēt multividi |
| `Super + Shift + Ctrl + A` | Startēt jūsu noklusējuma aģentu |
| `Power` key | Sistēmas izvēlne |
| `Super + Shift + Copilot` key | Omarchy izvēlne |

## Pielāgojumi

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimālais ekrāna spilgtums |
| `Shift + Brightness Down` | Minimālais ekrāna spilgtums |
| `Alt + Brightness Up/Down` | Precīzas 1% spilgtuma izmaiņas |
| `Alt + Volume Up/Down` | Precīzas 1% skaļuma izmaiņas |
| `Keyboard Brightness Up/Down` | Tastatūras izgaismojums spilgtāks/blāvāks |
| `Keyboard Backlight` | Cikliski pārslēgt tastatūras izgaismojuma līmeņus |
| `Ctrl + Brightness Up/Down` | Tastatūras izgaismojums spilgtāks/blāvāks tastatūrās bez saviem taustiņiem |
| `Mic Mute` | Izslēgt mikrofonu |
| `Shift + Mute` | Pārslēgt audio izvadi |
| `Touchpad Toggle` | Ieslēgt vai izslēgt skārienpaliktni |
| `Display` key | Cikliski pārslēgt darbvietas izkārtojumu |
| `Alt + Play` | Nākamais skaņdarbs |
| `Alt + Shift + Play` | Iepriekšējais skaņdarbs |

## Lietotņu palaišana

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminālis    |
| `Super + Alt + Return` | Tmux terminālis |
| `Super + Ctrl + Return` | Herdr (aģentu pārvaldnieks) |
| `Super + Shift + Return` or `Super + Shift + B`  | Pārlūks    |
| `Super + Shift + Alt + B`           | Pārlūks (privāts/inkognito)    |
| `Super + Shift + F`           | Failu pārvaldnieks    |
| `Super + Shift + Alt + F`           | Failu pārvaldnieks termināļa cwd    |
| `Super + Shift + M`           | Mūzika (Spotify)    |
| `Super + Shift + Alt + M`           | Mūzika (cliamp)    |
| `Super + Shift + /`           | Paroļu pārvaldnieks (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Kalkulators (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, tiklīdz instalēts)    |
| `Super + Shift + T`           | Aktivitāte (btop)    |
| `Super + Shift + N`           | Redaktors (Plain vai jūsu izvēlētais noklusējums)  |
| `Super + Shift + C`           | Kalendārs ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-pasts ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Jauns e-pasts ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Jūsu noklusējuma aģents vai ChatGPT, līdz izvēlaties kādu |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Saziņa (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Saziņa (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Saziņa (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Rakstīšana (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X (jauns ieraksts) |
| `Super + Shift + Y`           | YouTube |

Mainiet/pievienojiet piesaistes failā `~/.config/hypr/bindings.lua`.

## Universālā starpliktuve

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + A`           | Atlasīt visu lietotnēs, kas atbalsta `Ctrl + A`    |
| `Super + C`           | Kopēt    |
| `Super + X`           | Izgriezt (ne terminālī)    |
| `Super + V`           | Ielīmēt    |
| `Super + Ctrl + V`           | Starpliktuves pārvaldnieks    |

Parasti Linux vidē terminālī kopēšanai un ielīmēšanai nepieciešams `Ctrl + Shift + C/V`, bet visur citur — `Ctrl + C/V`. Šie Omarchy vienotie starpliktuves karstie taustiņi darbojas visur.

## Tveršana

| Hotkey              | Function                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Ekrānuzņēmums                      |
| `Super + Ctrl + Alt + C`            | Ekrānuzņēmums (tas pats uzņēmums tastatūrām bez Print Screen taustiņa) |
| `Super + Ctrl + C` | Tveršanas izvēlne |
| `Alt + Print Screen`            | Ekrāna ieraksts                     |
| `Super + Shift + Ctrl + Alt + C` | Ekrāna ieraksts bez audio, izlaižot izvēlni (nospiediet vēlreiz, lai apturētu) |
| `Super + Print Screen` | Krāsu izvēlētājs |
| `Super + Ctrl + Print Screen` | Teksta izvilkšana uz starpliktuvi |
| `Super + Alt + [` | Ieraksta laikā samazināt tīmekļa kameras pārklājumu |
| `Super + Alt + ]` | Ieraksta laikā palielināt tīmekļa kameras pārklājumu |
| `Alt + Shift + L` | Kopēt pašreizējo URL no tīmekļa lietotnes vai pārlūka |
| `Alt + Shift + D` | Lejupielādēt pašreizējās lapas video uz `~/Videos` |
| `Alt + Space` | Sākt/apturēt diktēšanu (nepieciešams _Setup > Defaults > Dictation_) |
| `Right Alt` | Turēt, lai diktētu (nepieciešams _Setup > Defaults > Dictation_) |

Ar ekrāna ierakstiem karstais taustiņš vispirms jautā, kuru audio vēlaties, pēc tam sāk ierakstu. Nospiediet to vēlreiz, lai apturētu. Sīkāk skatiet [ekrānuzņēmumi un ierakstīšana](12-screenshots-recording.md).

Visas tveršanas iespējas ir pieejamas arī sadaļā _Trigger > Capture_ Omarchy izvēlnē (`Super + Space`).

## Paziņojumi

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + ,` | Rīkoties ar jaunāko paziņojumu: atvērt to vai nospiest tā vienīgo pogu, izvēlēties no tā iespējām vai noraidīt to, ja tādu nav  |
| `Super + Shift + ,` | Noraidīt visus paziņojumus |
| `Super + Ctrl + ,` | Vadīt paziņojumus ar tastatūru  |
| `Super + Alt + ,` | Noraidīt jaunāko paziņojumu  |
| `Super + Shift + Alt + ,` | Atvērt paziņojumu vēsturi  |
| `Super + Ctrl + Alt + ,` | Pārslēgt paziņojumu apklusināšanu  |

## Stils

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Izvēlēties jaunu motīvu (arī `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Izvēlēties motīva fonu (arī `Super + Ctrl + Space`) |
| `Super + Backspace` | Pārslēgt loga caurspīdīgumu |
| `Super + Ctrl + Backspace` | Pārslēgt viena loga kvadrātisko proporciju |

Papildu fona attēli atrodas `~/.config/omarchy/backgrounds/<theme name>`. Pieejams arī caur _Install > Style > Background_ Omarchy izvēlnē.

Visas stila iespējas ir pieejamas arī sadaļā _Appearance_ Omarchy izvēlnē (`Super + Space`).

## Pārslēgi

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Pārslēgt bloķēšanu dīkstāvē |
| `Super + Ctrl + Delete` | Pārslēgt klēpjdatora displeja ieslēgšanu/izslēgšanu |
| `Super + Ctrl + Alt + Delete` | Pārslēgt klēpjdatora displeja spoguļošanu |
| `Super + Shift + Space` | Pārslēgt augšējo joslu  |
| `Shift + Mute` | Pārslēgties uz nākamo audio izvadi |
| `Shift + Play` | Pārslēgties uz nākamo multivides avotu |
| `Super + Shift + Backspace` | Pārslēgt logu atstarpes |
| `Super + Ctrl + Alt + F` | Pārslēgt pilnekrāna darbvirsmu (augšējā josla + logu atstarpes) |

## Atgādinājumi

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Iestatīt atgādinājumu  |
| `Super + Ctrl + Alt + R` | Skatīt visus atgādinājumus  |
| `Super + Ctrl + Shift + R` | Notīrīt visus atgādinājumus  |

## Īsie paziņojumi

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Rādīt laiku kā paziņojumu  |
| `Super + Ctrl + Alt + B` | Rādīt akumulatoru kā paziņojumu  |
| `Super + Ctrl + Alt + W` | Pārslēgt laikapstākļus kā paziņojumu  |

## Tmux

Prefiksa taustiņš ir `Ctrl + Space` (darbojas arī `Ctrl + B`). Šīs piesaistes varat mainīt failā `~/.config/tmux/tmux.conf`.

### Rūtis

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Prefix + v` | Sadalīt rūti blakus (vertikāli) |
| `Prefix + h` | Sadalīt rūti zem (horizontāli) |
| `Prefix + x` | Izbeigt rūti |
| `Prefix + z` | Pārslēgt rūts tuvinājumu (pilnekrāns) |
| `Alt + Enter` | Sadalīt rūti zem (bez prefiksa) |
| `Alt + Shift + Enter` | Sadalīt rūti blakus (bez prefiksa) |
| `Alt + Escape` | Izbeigt rūti (bez prefiksa) |
| `Ctrl + Alt + Arrows` | Pārvietoties starp rūtīm |
| `Ctrl + Alt + Shift + Arrows` | Mainīt rūšu izmēru |

### Logi

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Prefix + c` | Jauns logs |
| `Prefix + k` | Izbeigt logu |
| `Prefix + r` | Pārdēvēt logu |
| `Alt + 1-9` | Pāriet uz konkrētu logu |
| `Alt + Arrow Left/Right` | Pārvietoties starp logiem |
| `Alt + Shift + Arrow Left/Right` | Pārvietot logu pa kreisi/pa labi |

### Sesijas

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Prefix + C` | Jauna sesija |
| `Prefix + K` | Izbeigt sesiju |
| `Prefix + R` | Pārdēvēt sesiju |
| `Prefix + N` | Nākamā sesija |
| `Prefix + P` | Iepriekšējā sesija |
| `Alt + Arrow Up/Down` | Pārvietoties starp sesijām |
| `Prefix + s` | Uzskaitīt sesijas |
| `Prefix + d` | Atvienoties no sesijas |

### Kopēšanas režīms (vi stilā)

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Prefix + [` | Ieiet kopēšanas režīmā |
| `v` | Sākt atlasi (kopēšanas režīmā) |
| `y` | Kopēt atlasi (kopēšanas režīmā) |

### Vispārīgi

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Prefix + q` | Pārlādēt konfigurāciju |
| `Prefix + ?` | Rādīt Tmux taustiņu piesaistes |
| `Prefix + :` | Komandu uzvedne |

### Tmux izkārtojuma funkcijas

Šīs funkcijas jāpalaiž Tmux sesijas iekšpusē.

| Command | Function |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Izveidot izstrādes izkārtojumu ar redaktoru, AI un termināli |
| `tdlm <ai> [<second_ai>]` | Izveidot izstrādes izkārtojumu katrai apakšmapei |
| `tsl <count> <command>` | Izveidot vairāku rūšu spieta izkārtojumu |

## Ghostty terminālis

Ghostty termināli instalē, izmantojot _Install > Terminal_ Omarchy izvēlnē.

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Jauns sadalījums zem |
| `Ctrl + Shift + O` | Jauns sadalījums blakus |
| `Ctrl + Alt + Arrows` | Pārvietoties starp sadalījumiem |
| `Super + Ctrl + Shift + Arrows` | Mainīt sadalījuma izmēru par 10 rindām |
| `Super + Ctrl + Shift + Alt + Arrows` | Mainīt sadalījuma izmēru par 100 rindām |
| `Ctrl + Shift + T` | Jauna cilne  |
| `Ctrl + Shift + Arrows` | Pārvietoties starp cilnēm |
| `Alt + Numbers` | Pāriet uz konkrētu cilni |
| `Shift + Pg Up/Down` | Ritināt vēsturi |
| `Ctrl + Left mouse` | Atvērt saiti pārlūkā |

## Failu pārvaldnieks

| Hotkey              | Function                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Pāriet uz ceļu                     |
| `Space`               | Priekšskatīt failu (bultiņas navigē) |
| `Alt + Up`       | Pāriet uz augšu uz vecākmapi        |

## Neovim (ar lazyvim)

### Navigācija

| Hotkey                   | Function                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Rādīt komandu iespējas            |
| `Space Space`              | Atvērt failu ar izplūdušo meklēšanu      |
| `Space E`                  | Pārslēgt sānjoslu                  |
| `Space G G`                | Rādīt git vadību               |
| `Space S G`                | Meklēt faila saturā             |
| `Ctrl + W W`               | Lēkt starp sānjoslu un redaktoru |
| `Ctrl + Left/right arrow`  | Mainīt sānjoslas izmēru          |
| `Shift + H`                      | Pāriet uz kreiso failu cilni             |
| `Shift + L`                      | Pāriet uz labo failu cilni            |
| `Space B D`                | Aizvērt failu cilni                  |

### Esot sānjoslā

| Hotkey                   | Function                        |
| ------------------------ | ------------------------------- |
| `A`                        | Pievienot jaunu failu vecākmapē      |
| `Shift + A`                | Pievienot jaunu apakšmapi vecākmapē    |
| `D`                        | Dzēst iezīmēto failu/mapi     |
| `M`                        | Pārvietot iezīmēto failu/mapi       |
| `R`                        | Pārdēvēt iezīmēto failu/mapi     |
| `?`                        | Rādīt palīdzību visām komandām      |

[Skatīt visus Neovim karstos taustiņus, ko konfigurē LazyVim](https://www.lazyvim.org/keymaps).

## Ātrās emocijzīmes

Varat izmantot `Super + Ctrl + E`, lai parādītu pilnu emocijzīmju izvēlētāju, kas atlasi ievietos starpliktuvē, vai varat izmantot šīs ātrās piekļuves iespējas.

| Hotkey       | EM | Clue       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | smaids      |
| `Shift + CapsLock M C` | 😂 | raudāšana        |
| `Shift + CapsLock M L` | 😍 | mīlestība       |
| `Shift + CapsLock M V` | ✌️ | uzvara    |
| `Shift + CapsLock M H` | ❤️ | sirds      |
| `Shift + CapsLock M Y` | 👍 | jā        |
| `Shift + CapsLock M N` | 👎 | nē         |
| `Shift + CapsLock M F` | 🖕 | rupjš žests       |
| `Shift + CapsLock M W` | 🤞 | vēlēšanās       |
| `Shift + CapsLock M R` | 🤘 | roks       |
| `Shift + CapsLock M K` | 😘 | skūpsts       |
| `Shift + CapsLock M E` | 🙄 | acu bolīšana    |
| `Shift + CapsLock M I` | 😉 | piemiegšana       |
| `Shift + CapsLock M P` | 🙏 | lūgšana |
| `Shift + CapsLock M D` | 🤤 | siekalošanās      |
| `Shift + CapsLock M M` | 💰 | nauda      |
| `Shift + CapsLock M X` | 🎉 | svinības |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | tosts      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | sveiciens |
| `Shift + CapsLock M A` |💪 | roka |
| `Shift + CapsLock M B` |🤯 | spridzināšana |

## Ātrās pabeigšanas

| Hotkey       | Completion       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (garā domuzīme)   |
| `Shift + CapsLock Space N` | Jūsu vārds (kā ievadīts iestatīšanā)  |
| `Shift + CapsLock Space E` | Jūsu e-pasts (kā ievadīts iestatīšanā)  |

Varat pievienot vēl savus, rediģējot `~/.XCompose`, pēc tam terminālī palaižot `omarchy restart xcompose`, lai izmaiņas tiktu uztvertas.
