# Karstie taustiņi

Visas galvenās taustiņu sasaistes vari redzēt ar `Super + K` (Tmux sasaistes ar `Super + Alt + K` un Herdr sasaistes ar `Super + Ctrl + K`).

## Kā karstie taustiņi ir izkārtoti

Katrs karstais taustiņš atrodas plaknē, ko nosaka tā modifikatori, un katrai plaknei ir viens uzdevums. Tieši tas neļauj karstajiem taustiņiem saplūst kopā, un tas nozīmē, ka parasti vari uzminēt, kur kas atrodas.

| Plakne | Kas tur atrodas | Piemēri |
| --- | --- | --- |
| `Super + key` | Sistēma: logi, darbvietas, izkārtojumi un galvenās izvēlnes | `Super + Space` Omarchy izvēlne, `Super + W` aizvērt logu, `Super + F` pilnekrāns |
| `Super + Shift + key` | Lietotnes | `Super + Shift + B` pārlūks, `Super + Shift + E` e-pasts, `Super + Shift + N` redaktors |
| `Super + Ctrl + key` | Paneļi un sistēmas izvēlnes | `Super + Ctrl + A` audio, `Super + Ctrl + N` tīkls, `Super + Ctrl + C` uzņemšanas izvēlne |
| `Super + Ctrl + Alt + key` | Ātrās darbības un informatīvie paziņojumi | `Super + Ctrl + Alt + T` rādīt laiku, `Super + Ctrl + Alt + B` akumulators, `Super + Ctrl + Alt + C` ekrānuzņēmums |

`Alt` pievienošana karstajam taustiņam dod tā paša varianta versiju, nekad neko nesaistītu:

- `Super + Shift + B` atver pārlūku; `Super + Shift + Alt + B` atver privātu logu
- `Super + Shift + E` atver e-pastu; `Super + Shift + Alt + E` sāk jaunu
- `Super + F` pāriet pilnekrānā; `Super + Alt + F` pāriet pilnā platumā
- `Super + Ctrl + C` atver uzņemšanas izvēlni; `Super + Ctrl + Alt + C` izlaiž izvēlni un uzņem ekrānuzņēmumu

Pievienojot karsto taustiņu:

1. Atkarībā no tā, ko tas dara, izvēlies plakni, pēc tam izvēlies taustiņu.
2. Nepārvieto esošu karsto taustiņu, lai atbrīvotu vietu. Atrodi brīvu taustiņu pareizajā plaknē.
3. Izmanto `Alt` tikai tā paša karstā taustiņa variantam bez tā.

Daži karstie taustiņi pārkāpj šos noteikumus, jo tā ir ērtāk. `Shift` ar bultiņu vai `Tab` pārvieto vai apgriež virzienu, nevis atver lietotni, un `Print`, multivides taustiņi, `Alt + Tab` un `Ctrl + Alt + Del` darbojas tāpat kā visur citur. Tie ir izņēmumi, nevis paraugi, ko kopēt.

Ja noklusējums tev neder (teiksim, vēlies `Super + Shift + S` ekrānuzņēmumiem kā Windows), piesaisti to no jauna failā `~/.config/hypr/bindings.lua`.

## Navigācija

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy izvēlne (lietotnes un viss pārējais)    |
| `Super + Alt + Space` | Lietotņu režģis |
| `Super + Escape` | Sistēmas izvēlne (apturēt, restartēt utt.)  |
| `Super + Ctrl + L` | Bloķēt datoru |
| `Super + W` or `Super + Q` | Aizvērt logu             |
| `Ctrl + Alt + Del` | Aizvērt visus logus |
| `Super + T`               | Pārslēgt logu starp mozaīkas un peldošo režīmu             |
| `Super + J` | Pārslēgt loga novietojumu (horizontāli/vertikāli) |
| `Super + O`               | Pārslēgt logu lipīgā un peldošā režīmā |
| `Super + L`               | Cikliski pārslēgt dwindle, ritināšanas un peldošos izkārtojumus |
| `Super + Alt + L`         | Cikliski pārslēgt izkārtojumus pretējā virzienā |
| `Super + P`               | Pārslēgt pseidologa stilu (dabiskais pret izstiepto) |
| `Super + F`                 | Pāriet pilnekrānā              |
| `Super + Alt + F`                 | Pāriet pilnā platumā              |
| `Super + Ctrl + F`                 | Pāriet pilnekrānā loga iekšpusē              |
| `Super + 1/2/3/4`         | Pāriet uz konkrētu darbvietu fokusētajā monitorā |
| `Super + Tab` | Pāriet uz nākamo darbvietu fokusētajā monitorā |
| `Super + Shift + Tab` | Pāriet uz iepriekšējo darbvietu fokusētajā monitorā |
| `Super + Ctrl + Tab` | Pāriet uz agrāko darbvietu fokusētajā monitorā |
| `Super + Shift + 1/2/3/4` | Pārvietot logu uz darbvietu fokusētajā monitorā |
| `Super + Shift + Alt + 1/2/3/4` | Pārvietot logu uz darbvietu fokusētajā monitorā, nesekojot līdzi |
| `Super + S` | Pārslēgt pilno scratchpad |
| `Super + Alt + S` | Pārvietot logu uz pilno scratchpad |
| `Super + Grave` | Pārslēgt Quake konsoli |
| `Super + Shift + Grave` | Pārvietot logu uz Quake konsoli |
| `Super + Shift + Ctrl + Arrows` | Pārvietot logu uz monitoru tajā virzienā |
| `Super + Shift + Alt + Arrows` | Pārvietot darbvietu uz monitoru tajā virzienā |
| `Super + Arrow`  | Pārvietot fokusu uz logu bultiņas virzienā, ekrāna malā šķērsojot uz monitoru tajā pusē |
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
| `Super + Ctrl + Z` | Tuvināt ekrānu (atkārtot, lai tuvinātu vēl vairāk) |
| `Super + Ctrl + Alt + Z` | Pilnībā attālināt ekrānu |
| `Super + /` | Virzīties uz priekšu cauri monitora mērogošanas iespējām |
| `Super + Alt + /` | Virzīties atpakaļ cauri monitora mērogošanas iespējām |
| `Alt + Tab` | Cikliski virzīties uz priekšu cauri logiem aktīvajā darbvietā |
| `Alt + Shift + Tab` | Cikliski virzīties atpakaļ cauri logiem aktīvajā darbvietā |
| `Ctrl + Alt + Tab`| Cikliski virzīt fokusu uz priekšu cauri monitoriem |
| `Ctrl + Alt + Shift + Tab`| Cikliski virzīt fokusu atpakaļ cauri monitoriem |

Izmēra maiņas saīsnes izmanto fiziskos taustiņus `code:20` un `code:21` (XKB `<AE11>` un `<AE12>`), neatkarīgi no rakstzīmēm, kas uzdrukātas uz tastatūras. Uz ASV tastatūrām šie taustiņi ir `-` un `=`; uz japāņu (JIS) tastatūrām tie ir `-` un `^`; uz spāņu tastatūrām tie ir `'` un `¡`. Uz JIS `Super + ^` ir `Super + Equal`, savukārt `Super + Shift + -` (kas ievada `=`) ir `Super + Shift + Minus`.

## Sistēmas vadība

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Audio panelis    |
| `Super + Ctrl + B`           | Bluetooth panelis    |
| `Super + Ctrl + N`           | Wi-Fi/tīkla panelis    |
| `Super + Ctrl + D`           | Displeja panelis    |
| `Super + Ctrl + P`           | Barošanas panelis    |
| `Super + Ctrl + X`           | Aģentu panelis    |
| `Super + Ctrl + Alt + D`           | Kalendāra panelis    |
| `Super + Ctrl + Alt + E`           | Pasaules pulksteņa panelis    |
| `Super + Ctrl + 1-9`           | Pārslēgt joslas paneli pēc pozīcijas    |
| `Super + Ctrl + S` | Koplietošanas izvēlne (caur LocalSend) |
| `Super + Ctrl + C` | Uzņemšanas vadīklas (ekrānuzņēmums/-ieraksts/atlasītājs) |
| `Super + Ctrl + O` | Pārslēgt izvēlni |
| `Super + Ctrl + H` | Aparatūras izvēlne |
| `Super + Ctrl + E` | Emocijzīmju atlasītājs |
| `Super + Ctrl + .` | Pārkodēt multividi |
| `Super + Shift + Ctrl + A` | Izvēlēties AI aģentu |

## Pielāgojumi

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimālais ekrāna spilgtums |
| `Shift + Brightness Down` | Minimālais ekrāna spilgtums |
| `Alt + Brightness Up/Down` | Precīzas 1% spilgtuma izmaiņas |
| `Alt + Volume Up/Down` | Precīzas 1% skaļuma izmaiņas |
| `Keyboard Brightness Up/Down` | Tastatūras izgaismojums spilgtāks/blāvāks |
| `Keyboard Backlight` | Cikliski pārslēgt tastatūras izgaismojuma līmeņus |
| `Alt + Play` | Nākamais skaņdarbs |
| `Alt + Shift + Play` | Iepriekšējais skaņdarbs |

## Lietotņu palaišana

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminālis    |
| `Super + Alt + Return` | Tmux terminālis |
| `Super + Ctrl + Return` | Herdr (aģentu pārvaldnieks) |
| `Super + Shift + Return`           | Pārlūks    |
| `Super + Shift + Alt + B`           | Pārlūks (privāts/inkognito)    |
| `Super + Shift + F`           | Failu pārvaldnieks    |
| `Super + Shift + Alt + F`           | Failu pārvaldnieks termināļa cwd    |
| `Super + Shift + M`           | Mūzika (Spotify)    |
| `Super + Shift + Alt + M`           | Mūzika (cliamp)    |
| `Super + Shift + /`           | Paroļu pārvaldnieks (1password)    |
| `Super + Shift + Q`           | Kalkulators (Omacalc)    |
| `Super + Shift + T`           | Aktivitāte (btop)    |
| `Super + Shift + N`           | Redaktors (Neovim)  |
| `Super + Shift + C`           | Kalendārs ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-pasts ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Jauns e-pasts ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
| `Super + Shift + Alt + A`           | AI (Grok)  |
| `Super + Shift + G`           | Ziņapmaiņa (Signal)  |
| `Super + Shift + P`           | Google Photos  |
| `Super + Shift + S`           | Google Maps  |
| `Super + Shift + Alt + G`           | Ziņapmaiņa (WhatsApp)  |
| `Super + Shift + Ctrl + G`           | Ziņapmaiņa (Google)  |
| `Super + Shift + O`           | Obsidian  |
| `Super + Shift + W`           | Rakstīšana (Omawrite)  |
| `Super + Shift + X`           | X |
| `Super + Shift + Alt + X`           | X Compose |
| `Super + Shift + Y`           | YouTube |

Maini/pievieno sasaistes failā `~/.config/hypr/bindings.lua`.

## Universālā starpliktuve

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + A`           | Atlasīt visu lietotnēs, kas atbalsta `Ctrl + A`    |
| `Super + C`           | Kopēt    |
| `Super + X`           | Izgriezt (ne terminālī)    |
| `Super + V`           | Ielīmēt    |
| `Super + Ctrl + V`           | Starpliktuves pārvaldnieks    |

Parasti Linux sistēmā terminālī kopēšanai un ielīmēšanai vajag `Ctrl + Shift + C/V`, bet visur citur — `Ctrl + C/V`. Šie Omarchy vienotie starpliktuves karstie taustiņi darbojas visur.

## Uzņemšana

| Hotkey              | Function                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Ekrānuzņēmums                      |
| `Super + Ctrl + Alt + C`            | Ekrānuzņēmums (tas pats uzņēmums tastatūrām bez Print Screen taustiņa) |
| `Super + Ctrl + C` | Uzņemšanas izvēlne |
| `Alt + Print Screen`            | Ekrāna ieraksts                     |
| `Super + Shift + Ctrl + Alt + C` | Ekrāna ieraksts bez audio, izlaižot izvēlni (nospied vēlreiz, lai apturētu) |
| `Super + Print Screen` | Krāsu atlasītājs |
| `Super + Ctrl + Print Screen` | Teksta izvilkšana uz starpliktuvi |
| `Super + Alt + [` | Ieraksta laikā padarīt tīmekļa kameras pārklājumu mazāku |
| `Super + Alt + ]` | Ieraksta laikā padarīt tīmekļa kameras pārklājumu lielāku |
| `Alt + Shift + L` | Kopēt pašreizējo URL no tīmekļa lietotnes vai pārlūka |
| `Alt + Shift + D` | Lejupielādēt pašreizējās lapas video uz `~/Videos` |
| `Alt + Space` | Sākt/apturēt diktēšanu (nepieciešams _Setup > Defaults > Dictation_) |
| `Right Alt` | Turi nospiestu, lai diktētu (nepieciešams _Setup > Defaults > Dictation_) |

Ar ekrāna ierakstiem karstais taustiņš vispirms jautā, kādu audio vēlies, pēc tam sāk ierakstīt. Nospied to vēlreiz, lai apturētu. Skati [ekrānuzņēmumi un ierakstīšana](12-screenshots-recording.md), lai uzzinātu detaļas.

Visas uzņemšanas iespējas ir pieejamas arī zem _Trigger > Capture_ Omarchy izvēlnē (`Super + Space`).

## Paziņojumi

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + ,` | Rīkoties ar jaunāko paziņojumu: atvērt to vai nospiest tā vienīgo pogu, izvēlēties no tā izvēlēm vai noraidīt to, ja izvēļu nav  |
| `Super + Shift + ,` | Noraidīt visus paziņojumus |
| `Super + Ctrl + ,` | Vadīt paziņojumus ar tastatūru  |
| `Super + Alt + ,` | Noraidīt jaunāko paziņojumu  |
| `Super + Shift + Alt + ,` | Atvērt paziņojumu vēsturi  |
| `Super + Ctrl + Alt + ,` | Pārslēgt paziņojumu apklusināšanu  |

## Stils

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Izvēlēties jaunu tēmu (arī `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Izvēlēties tēmas fonu (arī `Super + Ctrl + Space`) |
| `Super + Backspace` | Pārslēgt loga caurspīdīgumu |
| `Super + Ctrl + Backspace` | Pārslēgt viena loga kvadrātisko malu attiecību |

Papildu fona attēli atrodas `~/.config/omarchy/backgrounds/<theme name>`. Pieejams arī caur _Install > Style > Background_ Omarchy izvēlnē.

Visas stila iespējas ir pieejamas arī zem _Style_ Omarchy izvēlnē (`Super + Space`).

## Pārslēgi

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Pārslēgt bloķēšanu dīkstāvē |
| `Super + Ctrl + Delete` | Pārslēgt klēpjdatora displeju ieslēgtu/izslēgtu |
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

## Informatīvie paziņojumi

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Rādīt laiku kā paziņojumu  |
| `Super + Ctrl + Alt + B` | Rādīt akumulatoru kā paziņojumu  |
| `Super + Ctrl + Alt + W` | Pārslēgt laikapstākļus kā paziņojumu  |

## Tmux

Prefiksa taustiņš ir `Ctrl + Space` (darbojas arī `Ctrl + B`). Šīs sasaistes vari mainīt failā `~/.config/tmux/tmux.conf`.

### Rūtis

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Prefix + v` | Sadalīt rūti blakus (vertikāli) |
| `Prefix + h` | Sadalīt rūti zem (horizontāli) |
| `Prefix + x` | Nogalināt rūti |
| `Prefix + z` | Pārslēgt rūts tālummaiņu (pilnekrāns) |
| `Alt + Enter` | Sadalīt rūti zem (bez prefiksa) |
| `Alt + Shift + Enter` | Sadalīt rūti blakus (bez prefiksa) |
| `Alt + Escape` | Nogalināt rūti (bez prefiksa) |
| `Ctrl + Alt + Arrows` | Pārvietoties starp rūtīm |
| `Ctrl + Alt + Shift + Arrows` | Mainīt rūšu izmēru |

### Logi

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Prefix + c` | Jauns logs |
| `Prefix + k` | Nogalināt logu |
| `Prefix + r` | Pārdēvēt logu |
| `Alt + 1-9` | Iet uz konkrētu logu |
| `Alt + Arrow Left/Right` | Pārvietoties starp logiem |
| `Alt + Shift + Arrow Left/Right` | Pārvietot logu pa kreisi/pa labi |

### Sesijas

| Hotkey                  | Function              |
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

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Prefix + [` | Ieeja kopēšanas režīmā |
| `v` | Sākt atlasi (kopēšanas režīmā) |
| `y` | Kopēt atlasi (kopēšanas režīmā) |

### Vispārīgi

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Prefix + q` | Pārlādēt konfigurāciju |
| `Prefix + ?` | Rādīt Tmux taustiņu sasaistes |
| `Prefix + :` | Komandu uzvedne |

### Tmux izkārtojuma funkcijas

Šīs funkcijas jāpalaiž Tmux sesijas iekšpusē.

| Komanda | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Izveidot izstrādes izkārtojumu ar redaktoru, AI un termināli |
| `tdlm <ai> [<second_ai>]` | Izveidot izstrādes izkārtojumu katrai apakšmapei |
| `tsl <count> <command>` | Izveidot vairāku rūšu spieta izkārtojumu |

## Ghostty terminālis

Ghostty terminālis tiek instalēts, izmantojot _Install > Terminal_ caur Omarchy izvēlni.

| Hotkey                  | Function              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Jauns sadalījums zem |
| `Ctrl + Shift + O` | Jauns sadalījums blakus |
| `Ctrl + Alt + Arrows` | Pārvietoties starp sadalījumiem |
| `Super + Ctrl + Shift + Arrows` | Mainīt sadalījuma izmēru par 10 rindām |
| `Super + Ctrl + Shift + Alt + Arrows` | Mainīt sadalījuma izmēru par 100 rindām |
| `Ctrl + Shift + T` | Jauna cilne  |
| `Ctrl + Shift + Arrows` | Pārvietoties starp cilnēm |
| `Alt + Numbers` | Iet uz konkrētu cilni |
| `Shift + Pg Up/Down` | Ritināt vēsturi |
| `Ctrl + Left mouse` | Atvērt saiti pārlūkā |

## Failu pārvaldnieks

| Hotkey              | Function                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Iet uz ceļu                     |
| `Space`               | Priekšskatīt failu (bultiņas navigē) |
| `Alt + Up`       | Iet uz augšu uz vecākmapi        |

## Neovim (ar LazyVim)

### Navigācija

| Hotkey                   | Function                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Rādīt komandu iespējas            |
| `Space Space`              | Atvērt failu ar izplūdušo meklēšanu      |
| `Space E`                  | Pārslēgt sānjoslu                  |
| `Space G G`                | Rādīt git vadīklas               |
| `Space S G`                | Meklēt faila saturā             |
| `Ctrl + W W`               | Lēkt starp sānjoslu un redaktoru |
| `Ctrl + Left/right arrow`  | Mainīt sānjoslas izmēru          |
| `Shift + H`                      | Iet uz kreiso faila cilni             |
| `Shift + L`                      | Iet uz labo faila cilni            |
| `Space B D`                | Aizvērt faila cilni                  |

### Kamēr esi sānjoslā

| Hotkey                   | Function                        |
| ------------------------ | ------------------------------- |
| `A`                        | Pievienot jaunu failu vecākmapē      |
| `Shift + A`                | Pievienot jaunu apakšmapi vecākmapē    |
| `D`                        | Dzēst izcelto failu/mapi     |
| `M`                        | Pārvietot izcelto failu/mapi       |
| `R`                        | Pārdēvēt izcelto failu/mapi     |
| `?`                        | Rādīt palīdzību visām komandām      |

[Skatīt visus Neovim karstos taustiņus, ko konfigurējis LazyVim](https://www.lazyvim.org/keymaps).

## Ātrās emocijzīmes

Vari izmantot `Super + Ctrl + E`, lai parādītu pilnu emocijzīmju atlasītāju, kas atlasi ievietos starpliktuvē, vai arī vari izmantot šīs ātrās piekļuves iespējas.

| Karstais taustiņš       | EM | Mājiens       |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | smaids      |
| `Shift + CapsLock M C` | 😂 | raud        |
| `Shift + CapsLock M L` | 😍 | mīlestība       |
| `Shift + CapsLock M V` | ✌️ | uzvara    |
| `Shift + CapsLock M H` | ❤️ | sirds      |
| `Shift + CapsLock M Y` | 👍 | jā        |
| `Shift + CapsLock M N` | 👎 | nē         |
| `Shift + CapsLock M F` | 🖕 | fuck       |
| `Shift + CapsLock M W` | 🤞 | vēlēšanās       |
| `Shift + CapsLock M R` | 🤘 | roks       |
| `Shift + CapsLock M K` | 😘 | skūpsts       |
| `Shift + CapsLock M E` | 🙄 | acu grozīšana    |
| `Shift + CapsLock M I` | 😉 | piemiegšana       |
| `Shift + CapsLock M P` | 🙏 | lūgšana |
| `Shift + CapsLock M D` | 🤤 | siekalošanās      |
| `Shift + CapsLock M M` | 💰 | nauda      |
| `Shift + CapsLock M X` | 🎉 | svinēšana |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | tosts      |
| `Shift + CapsLock M O` |👌 | labi |
| `Shift + CapsLock M G` |👋 | sveiciens |
| `Shift + CapsLock M A` |💪 | roka |
| `Shift + CapsLock M B` |🤯 | sprādziens |

## Ātrie papildinājumi

| Karstais taustiņš       | Papildinājums       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (garā domuzīme)   |
| `Shift + CapsLock Space N` | Tavs vārds (kā ievadīts iestatīšanas laikā)  |
| `Shift + CapsLock Space E` | Tavs e-pasts (kā ievadīts iestatīšanas laikā)  |

Vari pievienot vēl savus, rediģējot `~/.XCompose`, pēc tam terminālī palaižot `omarchy-restart-xcompose`, lai izmaiņas tiktu uztvertas.
