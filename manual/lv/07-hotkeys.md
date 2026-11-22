# Karstie taustiņi

Visas galvenās tastatūras saistības var redzēt ar `Super + K` (Tmux saistības ar `Super + Alt + K` un Herdr saistības ar `Super + Ctrl + K`).

## Kā karstie taustiņi ir sakārtoti

Katrs karstais taustiņš atrodas uz vienas plaknes, ko nosaka tā modifikatori, un katrai plaknei ir viens uzdevums. Tas neļauj karstajiem taustiņiem saplūst kopā, un tas nozīmē, ka parasti var uzminēt, kur kas atrodas.

| Plakne | Kas tur atrodas | Piemēri |
| --- | --- | --- |
| `Super + key` | Sistēma: logi, darbvietas, izkārtojumi un galvenās izvēlnes | `Super + Space` Omarchy izvēlne, `Super + W` aizvērt logu, `Super + F` pilnekrāns |
| `Super + Shift + key` | Lietotnes | `Super + Shift + B` pārlūks, `Super + Shift + E` e-pasts, `Super + Shift + N` redaktors |
| `Super + Ctrl + key` | Paneļi un sistēmas izvēlnes | `Super + Ctrl + A` audio, `Super + Ctrl + N` tīkls, `Super + Ctrl + C` uzņemšanas izvēlne |
| `Super + Ctrl + Alt + key` | Ātrās darbības un paziņojumi | `Super + Ctrl + Alt + T` rādīt laiku, `Super + Ctrl + Alt + B` akumulators, `Super + Ctrl + Alt + C` ekrānuzņēmums |

`Alt` pievienošana karstajam taustiņam dod tā paša varianta, nekad kaut ko nesaistītu:

- `Super + Shift + B` atver pārlūku; `Super + Shift + Alt + B` atver privātu logu
- `Super + Shift + E` atver e-pastu; `Super + Shift + Alt + E` sāk jaunu
- `Super + F` pāriet pilnekrāna režīmā; `Super + Alt + F` pāriet pilnā platumā
- `Super + Ctrl + C` atver uzņemšanas izvēlni; `Super + Ctrl + Alt + C` izlaiž izvēlni un uzņem ekrānuzņēmumu

Pievienojot karsto taustiņu:

1. Izvēlies plakni pēc tā, ko tas dara, tad izvēlies taustiņu.
2. Nepārvieto esošu karsto taustiņu, lai atbrīvotu vietu. Atrodi brīvu taustiņu uz pareizās plaknes.
3. Lieto `Alt` tikai tā paša karstā taustiņa variantam bez tā.

Daži karstie taustiņi pārkāpj šos noteikumus, jo tā ir ērtāk. `Shift` ar bultiņu vai `Tab` pārvieto vai apgriež, nevis atver lietotni, un `Print`, multivides taustiņi, `Alt + Tab` un `Ctrl + Alt + Del` darbojas tāpat kā visur citur. Tie ir izņēmumi, nevis paraugi, ko kopēt.

Ja noklusējums tev neder (teiksim, vēlies `Super + Shift + S` ekrānuzņēmumiem kā Windows), pārsaisti to failā `~/.config/hypr/bindings.lua`.

## Navigācija

| Karstais taustiņš | Funkcija |
| ----------------------- | --------------------- |
| `Super + Space` | Omarchy izvēlne (lietotnes un viss pārējais) |
| `Super + Alt + Space` | Lietotņu režģis |
| `Super + Escape` | Sistēmas izvēlne (miega režīms, restartēšana u.c.) |
| `Super + Ctrl + L` | Bloķēt datoru |
| `Super + W` or `Super + Q` | Aizvērt logu |
| `Ctrl + Alt + Del` | Aizvērt visus logus |
| `Super + K` | Rādīt visus karstos taustiņus |
| `Super + Alt + K` | Rādīt tmux karstos taustiņus |
| `Super + Ctrl + K` | Rādīt herdr karstos taustiņus |
| `Super + M` | Minimizēt logu uz doku |
| `Super + T` | Pārslēgt logu starp mozaīkas/peldošo režīmu |
| `Super + J` | Pārslēgt loga pozīciju (horizontāla/vertikāla) |
| `Super + O` | Pārslēgt loga pārveidošanu par lipīgu un peldošu |
| `Super + L` | Cikliski pārslēgt dwindle, ritināšanas un peldošo izkārtojumu |
| `Super + Alt + L` | Cikliski pārslēgt izkārtojumus pretējā virzienā |
| `Super + P` | Pārslēgt pseidologa stilu (dabiskais pret izstiepto) |
| `Super + F` | Pāriet pilnekrāna režīmā |
| `Super + Alt + F` | Pāriet pilnā platumā |
| `Super + Ctrl + F` | Pāriet pilnekrāna režīmā loga iekšpusē |
| `Super + 1…9/0` | Pāriet uz konkrētu darbvietu (0 ir 10) fokusētajā monitorā |
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
| `Super + Arrow` | Pārvietot fokusu uz logu bultiņas virzienā, ekrāna malā šķērsojot uz monitoru tajā pusē |
| `Super + Shift + Arrow` | Apmainīt logu ar citu bultiņas virzienā, ieskaitot logu monitorā tajā pusē |
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
| `Super + G` | Pārslēgt logu grupēšanu |
| `Super + Alt + G` | Izņemt logu no grupēšanas |
| `Super + Alt + Tab` | Cikliski pārslēgt logus grupējumā |
| `Super + Alt + Shift + Tab` | Cikliski pārslēgt logus grupējumā atpakaļ |
| `Super + Alt + Scroll Wheel` | Cikliski pārslēgt logus grupējumā |
| `Super + Alt + 1/2/3/4/5` | Pāriet uz konkrētu logu grupējumā |
| `Super + Alt + Arrow` | Pārvietot logu grupējumā bultiņas virzienā, ieskaitot logu monitorā tajā pusē |
| `Super + Ctrl + Left/Right` | Pārvietoties starp logiem mozaīkas grupas iekšpusē |
| `Super + Ctrl + Z` | Pietuvināt ekrānu (atkārtot lielākai pietuvināšanai) |
| `Super + Ctrl + Alt + Z` | Pilnībā attālināt ekrānu |
| `Super + /` | Virzīties uz priekšu cauri monitora mērogošanas iespējām |
| `Super + Alt + /` | Virzīties atpakaļ cauri monitora mērogošanas iespējām |
| `Alt + Tab` | Cikliski virzīties uz priekšu cauri logiem aktīvajā darbvietā |
| `Alt + Shift + Tab` | Cikliski virzīties atpakaļ cauri logiem aktīvajā darbvietā |
| `Ctrl + Alt + Tab` | Cikliski virzīt fokusu uz priekšu cauri monitoriem |
| `Ctrl + Alt + Shift + Tab` | Cikliski virzīt fokusu atpakaļ cauri monitoriem |
| `Super + I` | Pārslēgt ievades valodu (ar vairāk nekā vienu izkārtojumu vai ievades metodi) |
| `Super + Shift + I` | Pārslēgt ievades valodu atpakaļ |

Skārienpaliktnī trīs un četru pirkstu vilcieni pārslēdz darbvietas, pārvieto logus un atver izvēlni un Quake konsoli; žestus skati [tastatūra, pele un skārienpaliktnis](34-keyboard-mouse-trackpad.md).

Izmēra maiņas īsinājumtaustiņi lieto fiziskos taustiņus `code:20` un `code:21` (XKB `<AE11>` un `<AE12>`), neatkarīgi no uz tastatūras uzdrukātajām rakstzīmēm. ASV tastatūrās šie taustiņi ir `-` un `=`; japāņu (JIS) tastatūrās tie ir `-` un `^`; spāņu tastatūrās tie ir `'` un `¡`. JIS tastatūrā `Super + ^` ir `Super + Equal`, bet `Super + Shift + -` (kas raksta `=`) ir `Super + Shift + Minus`.

## Sistēmas vadīklas

| Karstais taustiņš | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + A` | Audio panelis |
| `Super + Ctrl + B` | Bluetooth panelis |
| `Super + Ctrl + N` | Wi-Fi/tīkla panelis |
| `Super + Ctrl + D` | Displeja panelis |
| `Super + Ctrl + P` | Barošanas panelis |
| `Super + Ctrl + X` | Aģentu panelis |
| `Super + Ctrl + Alt + X` | Lokālo modeļu panelis |
| `Super + Ctrl + Alt + D` | Kalendāra panelis |
| `Super + Ctrl + Alt + E` | Pasaules pulksteņa panelis |
| `Super + Ctrl + 1-9` | Pārslēgt joslas paneli pēc pozīcijas |
| `Super + Ctrl + S` | Kopīgošanas izvēlne (caur LocalSend) |
| `Super + Ctrl + C` | Uzņemšanas vadīklas (ekrānuzņēmums/ieraksts/izvēle) |
| `Super + Ctrl + O` | Pārslēgt izvēlni |
| `Super + Ctrl + H` | Aparatūras izvēlne |
| `Super + Ctrl + E` | Emocijzīmju izvēle |
| `Super + Ctrl + .` | Pārkodēt multividi |
| `Super + Shift + Ctrl + A` | Startēt noklusējuma aģentu |
| `Power` key | Sistēmas izvēlne |
| `Super + Shift + Copilot` key | Omarchy izvēlne |

## Pielāgojumi

| Karstais taustiņš | Funkcija |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimālais ekrāna spilgtums |
| `Shift + Brightness Down` | Minimālais ekrāna spilgtums |
| `Alt + Brightness Up/Down` | Precīzas 1% spilgtuma izmaiņas |
| `Alt + Volume Up/Down` | Precīzas 1% skaļuma izmaiņas |
| `Keyboard Brightness Up/Down` | Tastatūras apgaismojums spilgtāks/blāvāks |
| `Keyboard Backlight` | Cikliski pārslēgt tastatūras apgaismojuma līmeņus |
| `Ctrl + Brightness Up/Down` | Tastatūras apgaismojums spilgtāks/blāvāks tastatūrās bez saviem taustiņiem |
| `Mic Mute` | Izslēgt mikrofona skaņu |
| `Shift + Mute` | Pārslēgt audio izvadi |
| `Touchpad Toggle` | Ieslēgt vai izslēgt skārienpaliktni |
| `Display` key | Cikliski pārslēgt darbvietas izkārtojumu |
| `Alt + Play` | Nākamā dziesma |
| `Alt + Shift + Play` | Iepriekšējā dziesma |

## Lietotņu palaišana

| Karstais taustiņš | Funkcija |
| ----------------------- | --------------------- |
| `Super + Return` | Terminālis |
| `Super + Alt + Return` | Tmux terminālis |
| `Super + Ctrl + Return` | Herdr (aģentu pārvaldnieks) |
| `Super + Shift + Return` or `Super + Shift + B` | Pārlūks |
| `Super + Shift + Alt + B` | Pārlūks (privāts/inkognito) |
| `Super + Shift + F` | Failu pārvaldnieks |
| `Super + Shift + Alt + F` | Failu pārvaldnieks termināļa cwd mapē |
| `Super + Shift + M` | Mūzika (Spotify) |
| `Super + Shift + Alt + M` | Mūzika (cliamp) |
| `Super + Shift + /` | Paroļu pārvaldnieks (1password) |
| `Super + Shift + Q` or `Calculator` key | Kalkulators (Omacalc) |
| `Super + Shift + D` | Docker (lazydocker, kad instalēts) |
| `Super + Shift + T` | Aktivitāte (btop) |
| `Super + Shift + N` | Redaktors (Plain vai tavs izvēlētais noklusējums) |
| `Super + Shift + C` | Kalendārs ([HEY](https://hey.com/)) |
| `Super + Shift + E` | E-pasts ([HEY](https://hey.com/)) |
| `Super + Shift + Alt + E` | Jauns e-pasts ([HEY](https://hey.com/)) |
| `Super + Shift + A` | Tavs noklusējuma aģents vai ChatGPT, līdz izvēlies kādu |
| `Super + Shift + Alt + A` | AI (Grok) |
| `Super + Shift + G` | Saziņa (Signal) |
| `Super + Shift + P` | Google Photos |
| `Super + Shift + S` | Google Maps |
| `Super + Shift + Alt + G` | Saziņa (WhatsApp) |
| `Super + Shift + Ctrl + G` | Saziņa (Google) |
| `Super + Shift + O` | Obsidian |
| `Super + Shift + W` | Rakstīšana (Omawrite) |
| `Super + Shift + X` | X |
| `Super + Shift + Alt + X` | X (jauns ieraksts) |
| `Super + Shift + Y` | YouTube |

Maini/pievieno saistības failā `~/.config/hypr/bindings.lua`.

## Universālā starpliktuve

| Karstais taustiņš | Funkcija |
| ----------------------- | --------------------- |
| `Super + A` | Atlasīt visu lietotnēs, kas atbalsta `Ctrl + A` |
| `Super + C` | Kopēt |
| `Super + X` | Izgriezt (ne terminālī) |
| `Super + V` | Ielīmēt |
| `Super + Ctrl + V` | Starpliktuves pārvaldnieks |

Parasti Linux sistēmā terminālī kopēšanai un ielīmēšanai vajag `Ctrl + Shift + C/V`, bet visur citur — `Ctrl + C/V`. Šie Omarchy vienotās starpliktuves karstie taustiņi darbojas visur.

## Uzņemšana

| Karstais taustiņš | Funkcija |
| ------------------- | ------------------------------ |
| `Print Screen` | Ekrānuzņēmums |
| `Super + Ctrl + Alt + C` | Ekrānuzņēmums (tas pats uzņēmums tastatūrām bez Print Screen taustiņa) |
| `Super + Ctrl + C` | Uzņemšanas izvēlne |
| `Alt + Print Screen` | Ekrāna ieraksts |
| `Super + Shift + Ctrl + Alt + C` | Ekrāna ieraksts bez audio, izlaižot izvēlni (nospied vēlreiz, lai apturētu) |
| `Super + Print Screen` | Krāsu izvēle |
| `Super + Ctrl + Print Screen` | Teksta izvilkšana uz starpliktuvi |
| `Super + Alt + [` | Ieraksta laikā samazināt tīmekļa kameras pārklājumu |
| `Super + Alt + ]` | Ieraksta laikā palielināt tīmekļa kameras pārklājumu |
| `Alt + Shift + L` | Kopēt pašreizējo URL no tīmekļa lietotnes vai pārlūka |
| `Alt + Shift + D` | Lejupielādēt pašreizējās lapas video uz `~/Videos` |
| `Alt + Space` | Sākt/apturēt diktēšanu (nepieciešams _Setup > Defaults > Dictation_) |
| `Right Alt` | Turi, lai diktētu (nepieciešams _Setup > Defaults > Dictation_) |

Ekrāna ierakstos karstais taustiņš vispirms jautā, kādu audio vēlies, tad sāk ierakstu. Nospied to vēlreiz, lai apturētu. Sīkāk skati [ekrānuzņēmumi un ierakstīšana](12-screenshots-recording.md).

Visas uzņemšanas iespējas ir pieejamas arī zem _Trigger > Capture_ Omarchy izvēlnē (`Super + Space`).

## Paziņojumi

| Karstais taustiņš | Funkcija |
| ----------------------- | --------------------- |
| `Super + ,` | Darboties ar jaunāko paziņojumu: atvērt to vai nospiest tā vienīgo pogu, izvēlēties no tā izvēlēm vai noraidīt to, kad tam nav nevienas |
| `Super + Shift + ,` | Noraidīt visus paziņojumus |
| `Super + Ctrl + ,` | Vadīt paziņojumus ar tastatūru |
| `Super + Alt + ,` | Noraidīt jaunāko paziņojumu |
| `Super + Shift + Alt + ,` | Atvērt paziņojumu vēsturi |
| `Super + Ctrl + Alt + ,` | Pārslēgt paziņojumu apklusināšanu |

## Stils

| Karstais taustiņš | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Izvēlēties jaunu motīvu (arī `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Izvēlēties motīva fonu (arī `Super + Ctrl + Space`) |
| `Super + Backspace` | Pārslēgt loga caurspīdīgumu |
| `Super + Ctrl + Backspace` | Pārslēgt viena loga kvadrātisko proporciju |

Papildu fona attēli atrodas `~/.config/omarchy/backgrounds/<theme name>`. Pieejami arī caur _Install > Style > Background_ Omarchy izvēlnē.

Visas stila iespējas ir pieejamas arī zem _Appearance_ Omarchy izvēlnē (`Super + Space`).

## Pārslēgumi

| Karstais taustiņš | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Pārslēgt bloķēšanu dīkstāvē |
| `Super + Ctrl + Delete` | Pārslēgt klēpjdatora displeja ieslēgšanu/izslēgšanu |
| `Super + Ctrl + Alt + Delete` | Pārslēgt klēpjdatora displeja spoguļošanu |
| `Super + Shift + Space` | Pārslēgt augšējo joslu |
| `Shift + Mute` | Pārslēgt uz nākamo audio izvadi |
| `Shift + Play` | Pārslēgt uz nākamo multivides avotu |
| `Super + Shift + Backspace` | Pārslēgt logu atstarpes |
| `Super + Ctrl + Alt + F` | Pārslēgt pilnekrāna darbvirsmu (augšējā josla + logu atstarpes) |

## Atgādinājumi

| Karstais taustiņš | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Iestatīt atgādinājumu |
| `Super + Ctrl + Alt + R` | Redzēt visus atgādinājumus |
| `Super + Ctrl + Shift + R` | Notīrīt visus atgādinājumus |

## Īspaziņojumi

| Karstais taustiņš | Funkcija |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Rādīt laiku kā paziņojumu |
| `Super + Ctrl + Alt + B` | Rādīt akumulatoru kā paziņojumu |
| `Super + Ctrl + Alt + W` | Pārslēgt laikapstākļus kā paziņojumu |

## Tmux

Prefiksa taustiņš ir `Ctrl + Space` (`Ctrl + B` arī darbojas). Šīs saistības var mainīt failā `~/.config/tmux/tmux.conf`.

### Rūtis

| Karstais taustiņš | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + v` | Sadalīt rūti blakus (vertikāli) |
| `Prefix + h` | Sadalīt rūti apakšā (horizontāli) |
| `Prefix + x` | Nogalināt rūti |
| `Prefix + z` | Pārslēgt rūts pietuvināšanu (pilnekrāns) |
| `Alt + Enter` | Sadalīt rūti apakšā (bez prefiksa) |
| `Alt + Shift + Enter` | Sadalīt rūti blakus (bez prefiksa) |
| `Alt + Escape` | Nogalināt rūti (bez prefiksa) |
| `Ctrl + Alt + Arrows` | Pārvietoties starp rūtīm |
| `Ctrl + Alt + Shift + Arrows` | Mainīt rūšu izmēru |

### Logi

| Karstais taustiņš | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + c` | Jauns logs |
| `Prefix + k` | Nogalināt logu |
| `Prefix + r` | Pārdēvēt logu |
| `Alt + 1-9` | Iet uz konkrētu logu |
| `Alt + Arrow Left/Right` | Pārvietoties starp logiem |
| `Alt + Shift + Arrow Left/Right` | Pārvietot logu pa kreisi/pa labi |

### Sesijas

| Karstais taustiņš | Funkcija |
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

| Karstais taustiņš | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + [` | Iet kopēšanas režīmā |
| `v` | Sākt atlasi (kopēšanas režīmā) |
| `y` | Kopēt atlasi (kopēšanas režīmā) |

### Vispārīgi

| Karstais taustiņš | Funkcija |
| ----------------------- | --------------------- |
| `Prefix + q` | Pārlādēt konfigurāciju |
| `Prefix + ?` | Rādīt Tmux taustiņu saistības |
| `Prefix + :` | Komanduzvedne |

### Tmux izkārtojuma funkcijas

Šīs funkcijas jāpalaiž Tmux sesijas iekšpusē.

| Komanda | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Izveidot izstrādes izkārtojumu ar redaktoru, AI un termināli |
| `tdlm <ai> [<second_ai>]` | Izveidot izstrādes izkārtojumu katrai apakšmapei |
| `tsl <count> <command>` | Izveidot vairāku rūšu spieta izkārtojumu |

## Ghostty Terminal

Ghostty termināli instalē, lietojot _Install > Terminal_ caur Omarchy izvēlni.

| Karstais taustiņš | Funkcija |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Jauns sadalījums apakšā |
| `Ctrl + Shift + O` | Jauns sadalījums blakus |
| `Ctrl + Alt + Arrows` | Pārvietoties starp sadalījumiem |
| `Super + Ctrl + Shift + Arrows` | Mainīt sadalījuma izmēru par 10 rindām |
| `Super + Ctrl + Shift + Alt + Arrows` | Mainīt sadalījuma izmēru par 100 rindām |
| `Ctrl + Shift + T` | Jauna cilne |
| `Ctrl + Shift + Arrows` | Pārvietoties starp cilnēm |
| `Alt + Numbers` | Iet uz konkrētu cilni |
| `Shift + Pg Up/Down` | Ritināt vēsturi |
| `Ctrl + Left mouse` | Atvērt saiti pārlūkā |

## File Manager

| Karstais taustiņš | Funkcija |
| ------------------- | ------------------------------ |
| `Ctrl + L` | Iet uz ceļu |
| `Space` | Priekšskatīt failu (bultiņas navigē) |
| `Alt + Up` | Iet uz vecākmapi |

## Neovim (w/ lazyvim)

### Navigation

| Karstais taustiņš | Funkcija |
| ------------------------ | ------------------------------- |
| `Space` | Rādīt komandu iespējas |
| `Space Space` | Atvērt failu ar aptuveno meklēšanu |
| `Space E` | Pārslēgt sānjoslu |
| `Space G G` | Rādīt git vadīklas |
| `Space S G` | Meklēt faila saturu |
| `Ctrl + W W` | Lēkt starp sānjoslu un redaktoru |
| `Ctrl + Left/right arrow` | Mainīt sānjoslas izmēru |
| `Shift + H` | Iet uz kreiso faila cilni |
| `Shift + L` | Iet uz labo faila cilni |
| `Space B D` | Aizvērt faila cilni |

### Esot sānjoslā

| Karstais taustiņš | Funkcija |
| ------------------------ | ------------------------------- |
| `A` | Pievienot jaunu failu vecākmapē |
| `Shift + A` | Pievienot jaunu apakšmapi vecākmapē |
| `D` | Dzēst izcelto failu/mapi |
| `M` | Pārvietot izcelto failu/mapi |
| `R` | Pārdēvēt izcelto failu/mapi |
| `?` | Rādīt palīdzību visām komandām |

[Skatīt visus Neovim karstos taustiņus, ko konfigurē LazyVim](https://www.lazyvim.org/keymaps).

## Ātrās emocijzīmes

Var lietot `Super + Ctrl + E`, lai parādītu pilnu emocijzīmju izvēli, kas atlasi ievietos starpliktuvē, vai var lietot šīs ātrās piekļuves iespējas.

| Karstais taustiņš | EM | Norāde |
| ------------ | -- | ---------- |
| `Shift + CapsLock M S` | 😄 | smaids |
| `Shift + CapsLock M C` | 😂 | asaras |
| `Shift + CapsLock M L` | 😍 | mīlestība |
| `Shift + CapsLock M V` | ✌️ | uzvara |
| `Shift + CapsLock M H` | ❤️ | sirds |
| `Shift + CapsLock M Y` | 👍 | jā |
| `Shift + CapsLock M N` | 👎 | nē |
| `Shift + CapsLock M F` | 🖕 | vidējais pirksts |
| `Shift + CapsLock M W` | 🤞 | veiksme |
| `Shift + CapsLock M R` | 🤘 | roks |
| `Shift + CapsLock M K` | 😘 | skūpsts |
| `Shift + CapsLock M E` | 🙄 | acu griešana |
| `Shift + CapsLock M I` | 😉 | mirkšķināšana |
| `Shift + CapsLock M P` | 🙏 | lūgšana |
| `Shift + CapsLock M D` | 🤤 | siekalošanās |
| `Shift + CapsLock M M` | 💰 | nauda |
| `Shift + CapsLock M X` | 🎉 | svinības |
| `Shift + CapsLock M 1` | 💯 | 100% |
| `Shift + CapsLock M T` | 🥂 | tosts |
| `Shift + CapsLock M O` |👌 | labi |
| `Shift + CapsLock M G` |👋 | sveiciens |
| `Shift + CapsLock M A` |💪 | roka |
| `Shift + CapsLock M B` |🤯 | prāta sprādziens |

## Ātrie papildinājumi

| Karstais taustiņš | Papildinājums |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (garā domuzīme) |
| `Shift + CapsLock Space N` | Tavs vārds (kā ievadīts iestatīšanas laikā) |
| `Shift + CapsLock Space E` | Tavs e-pasts (kā ievadīts iestatīšanas laikā) |

Var pievienot vēl savus, rediģējot `~/.XCompose`, tad terminālī palaižot `omarchy restart xcompose`, lai izmaiņas tiktu uztvertas.
