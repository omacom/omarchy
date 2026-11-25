# Karstie taustiņi

Visus galvenos taustiņu sasaistījumus vari redzēt ar `Super + K` (Tmux sasaistījumus ar `Super + Alt + K` un Herdr sasaistījumus ar `Super + Ctrl + K`).

## Kā karstie taustiņi ir izvietoti

Katrs karstais taustiņš atrodas uz vienas plaknes, ko nosaka tā modificētāji, un katrai plaknei ir viens uzdevums. Tas neļauj karstajiem taustiņiem saplūst kopā, un tas nozīmē, ka parasti vari uzminēt, kur kas dzīvo.

| Plakne | Kas tur dzīvo | Piemēri |
| --- | --- | --- |
| `Super + key` | Sistēma: logi, darbvirsmas, izkārtojumi un galvenās izvēlnes | `Super + Space` Omarchy izvēlne, `Super + W` aizvērt logu, `Super + F` pilnekrāns |
| `Super + Shift + key` | Lietotnes | `Super + Shift + B` pārlūks, `Super + Shift + E` e-pasts, `Super + Shift + N` redaktors |
| `Super + Ctrl + key` | Paneļi un sistēmas izvēlnes | `Super + Ctrl + A` audio, `Super + Ctrl + N` tīkls, `Super + Ctrl + C` tveršanas izvēlne |
| `Super + Ctrl + Alt + key` | Ātrās darbības un paziņojumi | `Super + Ctrl + Alt + T` rādīt laiku, `Super + Ctrl + Alt + B` akumulators, `Super + Ctrl + Alt + C` ekrānuzņēmums |

Pievienojot karstajam taustiņam `Alt`, iegūsi tā paša variantu, nekad neko nesaistītu:

- `Super + Shift + B` atver pārlūku; `Super + Shift + Alt + B` atver privātu logu
- `Super + Shift + E` atver e-pastu; `Super + Shift + Alt + E` sāk jaunu
- `Super + F` pāriet pilnekrānā; `Super + Alt + F` pāriet pilnā platumā
- `Super + Ctrl + C` atver tveršanas izvēlni; `Super + Ctrl + Alt + C` izlaiž izvēlni un uzņem ekrānuzņēmumu

Kad pievieno karsto taustiņu:

1. Izvēlies plakni pēc tā, ko tas dara, tad izvēlies taustiņu.
2. Nepārvieto esošu karsto taustiņu, lai atbrīvotu vietu. Atrodi brīvu taustiņu uz pareizās plaknes.
3. Lieto `Alt` tikai tā karstā taustiņa variantam, kuram tā nav.

Daži karstie taustiņi pārkāpj šos noteikumus, jo tā ir ērtāk. `Shift` ar bultiņu vai `Tab` pārvieto vai apvērš, nevis atver lietotni, un `Print`, multivides taustiņi, `Alt + Tab` un `Ctrl + Alt + Del` darbojas tāpat kā visur citur. Tie ir izņēmumi, nevis paraugi, ko kopēt.

Ja noklusējums tev neder (teiksim, vēlies `Super + Shift + S` ekrānuzņēmumiem kā Windows), pārsaisti to failā `~/.config/hypr/bindings.lua`.

## Navigācija

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy izvēlne (lietotnes un viss pārējais)    |
| `Super + Alt + Space` | Lietotņu režģis |
| `Super + Escape` | Sistēmas izvēlne (apturēt, restartēt u. c.)  |
| `Super + Ctrl + L` | Bloķēt datoru |
| `Super + W` or `Super + Q` | Aizvērt logu             |
| `Ctrl + Alt + Del` | Aizvērt visus logus |
| `Super + K` | Rādīt visus karstos taustiņus |
| `Super + Alt + K` | Rādīt tmux karstos taustiņus |
| `Super + Ctrl + K` | Rādīt herdr karstos taustiņus |
| `Super + M` | Minimizēt logu uz doku |
| `Super + T`               | Pārslēgt logu starp flīzēšanu un peldošo režīmu             |
| `Super + J` | Pārslēgt loga pozīciju (horizontāli/vertikāli) |
| `Super + O`               | Pārslēgt loga pārvēršanu par lipīgu un peldošu |
| `Super + L`               | Cikliski pārslēgties starp dwindle, scrolling un floating izkārtojumiem |
| `Super + Alt + L`         | Cikliski pārslēgties starp izkārtojumiem apgrieztā secībā |
| `Super + P`               | Pārslēgt pseido loga stilu (dabisks pret izstieptu) |
| `Super + F`                 | Pāriet pilnekrānā              |
| `Super + Alt + F`                 | Pāriet pilnā platumā              |
| `Super + Ctrl + F`                 | Pāriet pilnekrānā loga iekšpusē              |
| `Super + 1…9/0`         | Pāriet uz konkrētu darbvirsmu (0 ir 10) fokusētajā monitorā |
| `Super + Tab` | Pāriet uz nākamo darbvirsmu fokusētajā monitorā |
| `Super + Shift + Tab` | Pāriet uz iepriekšējo darbvirsmu fokusētajā monitorā |
| `Super + Ctrl + Tab` | Pāriet uz agrāko darbvirsmu fokusētajā monitorā |
| `Super + Shift + 1…9/0` | Pārvietot logu uz darbvirsmu fokusētajā monitorā |
| `Super + Shift + Alt + 1…9/0` | Pārvietot logu uz darbvirsmu fokusētajā monitorā, nesekojot līdzi |
| `Super + S` | Pārslēgt pilnu scratchpad |
| `Super + Alt + S` | Pārvietot logu uz pilnu scratchpad |
| `Super + the key above Tab` (grave US izkārtojumos) | Pārslēgt Quake konsoli |
| `Super + Shift + the key above Tab` (grave US izkārtojumos) | Pārvietot logu uz Quake konsoli |
| `Super + Shift + Ctrl + Arrows` | Pārvietot logu uz monitoru tajā virzienā |
| `Super + Shift + Alt + Arrows` | Pārvietot darbvirsmu uz monitoru tajā virzienā |
| `Super + Arrow`  | Pārvietot fokusu uz logu bultiņas virzienā, ekrāna malā šķērsojot uz monitoru tajā pusē |
| `Super + Shift + Arrow`  | Apmainīt logu ar citu bultiņas virzienā, ieskaitot logu monitorā tajā pusē |
| `Super + Minus` | Paplašināt logu pa kreisi |
| `Super + Equal` | Samazināt logu pa kreisi |
| `Super + Shift + Minus` | Samazināt logu uz augšu |
| `Super + Shift + Equal` | Paplašināt logu uz leju |
| `Super + Alt + Minus/Equal` | Tā pati izmēru maiņa mazākos soļos |
| `Super + Ctrl + Minus/Equal` | Tā pati izmēru maiņa lielākos soļos |
| `Super + Alt + Home` | Saglabāt loga platumu |
| `Super + Home` | Atjaunot saglabāto loga platumu |
| `Super + Left Mouse` | Vilkt logu apkārt |
| `Super + Right Mouse` | Mainīt loga izmēru |
| `Super + Scroll Wheel` | Ritināt cauri darbvirsmām fokusētajā monitorā |
| `Super + G`               | Pārslēgt logu grupēšanu      |
| `Super + Alt + G`               | Pārvietot logu ārā no grupēšanas      |
| `Super + Alt + Tab`               | Cikliski pārslēgties starp logiem grupēšanā      |
| `Super + Alt + Shift + Tab`               | Cikliski pārslēgties atpakaļ starp logiem grupēšanā      |
| `Super + Alt + Scroll Wheel` | Cikliski pārslēgties starp logiem grupēšanā |
| `Super + Alt + 1/2/3/4/5`               | Pāriet uz konkrētu logu grupēšanā      |
| `Super + Alt + Arrow`  | Pārvietot logu grupēšanā bultiņas virzienā, ieskaitot logu monitorā tajā pusē |
| `Super + Ctrl + Left/Right`  | Pārvietoties starp logiem mozaīkas grupas iekšpusē |
| `Super + Ctrl + Z` | Tuvināt ekrānu (atkārtot, lai tuvinātu vairāk) |
| `Super + Ctrl + Alt + Z` | Pilnībā attālināt ekrānu |
| `Super + /` | Virzīties uz priekšu cauri monitora mērogošanas iespējām |
| `Super + Alt + /` | Virzīties atpakaļ cauri monitora mērogošanas iespējām |
| `Alt + Tab` | Cikliski virzīties uz priekšu cauri logiem aktīvajā darbvirsmā |
| `Alt + Shift + Tab` | Cikliski virzīties atpakaļ cauri logiem aktīvajā darbvirsmā |
| `Ctrl + Alt + Tab`| Cikliski virzīt fokusu uz priekšu cauri monitoriem |
| `Ctrl + Alt + Shift + Tab`| Cikliski virzīt fokusu atpakaļ cauri monitoriem |
| `Super + I` | Pārslēgt ievades valodu (ja ir vairāk nekā viens izkārtojums vai ievades metode) |
| `Super + Shift + I` | Pārslēgt ievades valodu atpakaļ |

Uz skārienpaliktņa trīs un četru pirkstu vilcieni pārslēdz darbvirsmas, pārvieto logus un atver izvēlni un Quake konsoli; žestus skati [tastatūra, pele un skārienpaliktnis](34-keyboard-mouse-trackpad.md).

Izmēru maiņai izmanto divus taustiņus pa labi no 0, neatkarīgi no tā, kas uz tavas tastatūras uz tiem uzdrukāts: `-` un `=` uz US tastatūrām, `+` un `´` uz dāņu un zviedru, `+` un `\` uz norvēģu, `ß` un `´` uz vācu, `'` un `¡` uz spāņu un `-` un `^` uz japāņu (JIS). `Super + K` tos uzrāda tā, kā tos drukā tava tastatūra. Uz JIS `Super + ^` ir `Super + Equal`, bet `Super + Shift + -` (kas raksta `=`) ir `Super + Shift + Minus`. Monitora mērogošana un parolu pārvaldnieks izmanto `/`; izkārtojumos, kas `/` raksta tikai ar Shift, kā vairums Eiropas izkārtojumu, tie tā vietā izmanto taustiņu pa kreisi no labā Shift (`-` uz dāņu un vācu).

## Sistēmas vadība

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Audio panelis    |
| `Super + Ctrl + B`           | Bluetooth panelis    |
| `Super + Ctrl + N`           | Wifi/tīkla panelis    |
| `Super + Ctrl + D`           | Displeja panelis    |
| `Super + Ctrl + P`           | Barošanas panelis    |
| `Super + Ctrl + X`           | Aģentu panelis    |
| `Super + Ctrl + Alt + D`           | Kalendāra panelis    |
| `Super + Ctrl + Alt + E`           | Pasaules pulksteņa panelis    |
| `Super + Ctrl + 1-9`           | Pārslēgt joslas paneli pēc pozīcijas    |
| `Super + Ctrl + S` | Kopīgošanas izvēlne (caur LocalSend) |
| `Super + Ctrl + C` | Tveršanas vadība (ekrānuzņēmums/-ieraksts/izvēle) |
| `Super + Ctrl + O` | Pārslēgt izvēlni |
| `Super + Ctrl + H` | Aparatūras izvēlne |
| `Super + Ctrl + E` | Emocijzīmju izvēle |
| `Super + Ctrl + .` | Pārkodēt multividi |
| `Super + Shift + Ctrl + A` | Startēt noklusējuma aģentu |
| `Power` key | Sistēmas izvēlne |
| `Super + Shift + Copilot` key | Omarchy izvēlne |

## Pielāgojumi

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimālais ekrāna spilgtums |
| `Shift + Brightness Down` | Minimālais ekrāna spilgtums |
| `Alt + Brightness Up/Down` | Precīzas 1% spilgtuma izmaiņas |
| `Alt + Volume Up/Down` | Precīzas 1% skaļuma izmaiņas |
| `Keyboard Brightness Up/Down` | Tastatūras izgaismojums spilgtāks/blāvāks |
| `Keyboard Backlight` | Cikliski pārslēgt tastatūras izgaismojuma līmeņus |
| `Ctrl + Brightness Up/Down` | Tastatūras izgaismojums spilgtāks/blāvāks tastatūrām bez saviem taustiņiem |
| `Mic Mute` | Izslēgt mikrofona skaņu |
| `Shift + Mute` | Pārslēgt audio izvadi |
| `Touchpad Toggle` | Ieslēgt vai izslēgt skārienpaliktni |
| `Display` key | Cikliski pārslēgt darbvirsmas izkārtojumu |
| `Alt + Play` | Nākamais skaņdarbs |
| `Alt + Shift + Play` | Iepriekšējais skaņdarbs |

## Lietotņu palaišana

| Karstais taustiņš                  | Funkcija              |
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
| `Super + Shift + /`           | Parolu pārvaldnieks (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Kalkulators (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, kad instalēts)    |
| `Super + Shift + T`           | Aktivitāte (btop)    |
| `Super + Shift + N`           | Redaktors (Plain vai tavs izvēlētais noklusējums)  |
| `Super + Shift + C`           | Kalendārs ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-pasts ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Jauns e-pasts ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | AI (ChatGPT)  |
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

Maini/pievieno sasaistījumus failā `~/.config/hypr/bindings.lua`.

## Universālā starpliktuve

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + A`           | Atlasīt visu lietotnēs, kas atbalsta `Ctrl + A`    |
| `Super + C`           | Kopēt    |
| `Super + X`           | Izgriezt (ne terminālī)    |
| `Super + V`           | Ielīmēt    |
| `Super + Ctrl + V`           | Starpliktuves pārvaldnieks    |

Parasti Linux tev vajag `Ctrl + Shift + C/V`, lai kopētu un ielīmētu terminālī, un `Ctrl + C/V`, lai darītu to visur citur. Šie Omarchy vienotie starpliktuves karstie taustiņi darbojas visur.

## Tveršana

| Karstais taustiņš              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Ekrānuzņēmums                      |
| `Super + Ctrl + Alt + C`            | Ekrānuzņēmums (tas pats uzņēmums tastatūrām bez Print Screen taustiņa) |
| `Super + Ctrl + C` | Tveršanas izvēlne |
| `Alt + Print Screen`            | Ekrāna ieraksts                     |
| `Super + Shift + Ctrl + Alt + C` | Ekrāna ieraksts bez audio, izlaižot izvēlni (nospied vēlreiz, lai apturētu) |
| `Super + Print Screen` | Krāsu izvēle |
| `Super + Ctrl + Print Screen` | Teksta izgūšana uz starpliktuvi |
| `Super + Alt + [` | Ieraksta laikā padarīt tīmekļa kameras pārklājumu mazāku |
| `Super + Alt + ]` | Ieraksta laikā padarīt tīmekļa kameras pārklājumu lielāku |
| `Alt + Shift + L` | Kopēt pašreizējo URL no tīmekļa lietotnes vai pārlūka |
| `Alt + Shift + D` | Lejupielādēt pašreizējās lapas video uz `~/Videos` |
| `Alt + Space` | Sākt/apturēt diktēšanu (nepieciešams _Setup > Defaults > Dictation_) |
| `Right Alt` | Turēt, lai diktētu (nepieciešams _Setup > Defaults > Dictation_) |

Ar ekrāna ierakstiem karstais taustiņš vispirms jautā, kādu audio vēlies, tad sāk ierakstīt. Nospied to vēlreiz, lai apturētu. Sīkāk skati [ekrānuzņēmumi un ierakstīšana](12-screenshots-recording.md).

Visas tveršanas iespējas ir pieejamas arī zem _Trigger > Capture_ Omarchy izvēlnē (`Super + Space`).

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
| `Super + Ctrl + T` | Izvēlēties jaunu tēmu (arī `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Izvēlēties tēmas fonu (arī `Super + Ctrl + Space`) |
| `Super + Backspace` | Pārslēgt loga caurspīdīgumu |
| `Super + Ctrl + Backspace` | Pārslēgt viena loga kvadrātisko malu attiecību |

Papildu fona attēli dzīvo `~/.config/omarchy/backgrounds/<theme name>`. Pieejams arī caur _Install > Style > Background_ Omarchy izvēlnē.

Visas stila iespējas ir pieejamas arī zem _Appearance_ Omarchy izvēlnē (`Super + Space`).

## Pārslēgi

| Karstais taustiņš                  | Funkcija              |
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

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Iestatīt atgādinājumu  |
| `Super + Ctrl + Alt + R` | Redzēt visus atgādinājumus  |
| `Super + Ctrl + Shift + R` | Notīrīt visus atgādinājumus  |

## Īsie paziņojumi

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Rādīt laiku kā paziņojumu  |
| `Super + Ctrl + Alt + B` | Rādīt akumulatoru kā paziņojumu  |
| `Super + Ctrl + Alt + W` | Pārslēgt laikapstākļus kā paziņojumu  |

## Tmux

Prefiksa taustiņš ir `Ctrl + Space` (`Ctrl + B` arī darbojas). Šos sasaistījumus vari mainīt failā `~/.config/tmux/tmux.conf`.

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
| `Alt + 1-9` | Pāriet uz konkrētu logu |
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
| `Prefix + ?` | Rādīt Tmux taustiņu sasaistījumus |
| `Prefix + :` | Komandu uzvedne |

### Tmux izkārtojuma funkcijas

Šīs funkcijas jāpalaiž Tmux sesijas iekšpusē.

| Komanda | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Izveidot izstrādes izkārtojumu ar redaktoru, AI un termināli |
| `tdlm <ai> [<second_ai>]` | Izveidot izstrādes izkārtojumu katrai apakšdirektorijai |
| `tsl <count> <command>` | Izveidot vairākrūšu spieta izkārtojumu |

## Ghostty terminālis

Ghostty terminālis tiek instalēts, izmantojot _Install > Terminal_ caur Omarchy izvēlni.

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Jauns sadalījums zemāk |
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

| Karstais taustiņš              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Pāriet uz ceļu                     |
| `Space`               | Priekšskatīt failu (bultiņas navigē) |
| `Alt + Up`       | Pāriet uz vecāk mapi        |

## Neovim (ar lazyvim)

### Navigācija

| Karstais taustiņš                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Rādīt komandu iespējas            |
| `Space Space`              | Atvērt failu ar neskaidru meklēšanu      |
| `Space E`                  | Pārslēgt sānjoslu                  |
| `Space G G`                | Rādīt git vadību               |
| `Space S G`                | Meklēt faila saturu             |
| `Ctrl + W W`               | Lēkt starp sānjoslu un redaktoru |
| `Ctrl + Left/right arrow`  | Mainīt sānjoslas izmēru          |
| `Shift + H`                      | Pāriet uz kreiso failu cilni             |
| `Shift + L`                      | Pāriet uz labo failu cilni            |
| `Space B D`                | Aizvērt failu cilni                  |

### Kamēr esi sānjoslā

| Karstais taustiņš                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `A`                        | Pievienot jaunu failu vecāk direktorijā      |
| `Shift + A`                | Pievienot jaunu apakšdirektoriju vecāk direktorijā    |
| `D`                        | Dzēst iezīmēto failu/direktoriju     |
| `M`                        | Pārvietot iezīmēto failu/direktoriju       |
| `R`                        | Pārdēvēt iezīmēto failu/direktoriju     |
| `?`                        | Rādīt palīdzību visām komandām      |

[Skaties visus Neovim karstos taustiņus, ko konfigurē LazyVim](https://www.lazyvim.org/keymaps).

## Ātrās emocijzīmes

Vari izmantot `Super + Ctrl + E`, lai parādītu pilnu emocijzīmju izvēli, kas atlasi novietos starpliktuvē, vai vari izmantot šīs ātrās piekļuves iespējas.

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
| `Shift + CapsLock M W` | 🤞 | vēlēšanās       |
| `Shift + CapsLock M R` | 🤘 | roks       |
| `Shift + CapsLock M K` | 😘 | skūpsts       |
| `Shift + CapsLock M E` | 🙄 | acu bolīšana    |
| `Shift + CapsLock M I` | 😉 | mirkšķināšana       |
| `Shift + CapsLock M P` | 🙏 | lūgt |
| `Shift + CapsLock M D` | 🤤 | siekalošanās      |
| `Shift + CapsLock M M` | 💰 | nauda      |
| `Shift + CapsLock M X` | 🎉 | svinēt |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | tosts      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | sveiciens |
| `Shift + CapsLock M A` |💪 | roka |
| `Shift + CapsLock M B` |🤯 | sprādziens |

## Ātrā papildināšana

| Karstais taustiņš       | Papildinājums       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (garā domuzīme)   |
| `Shift + CapsLock Space N` | Tavs vārds (kā ievadīts iestatīšanā)  |
| `Shift + CapsLock Space E` | Tavs e-pasts (kā ievadīts iestatīšanā)  |

Vari pievienot vēl savus, rediģējot `~/.XCompose`, pēc tam terminālī palaižot `omarchy restart xcompose`, lai izmaiņas tiktu uztvertas.
