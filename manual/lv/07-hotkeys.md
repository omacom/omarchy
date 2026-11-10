# Īsinājumtaustiņi

Visus galvenos tastatūras īsinājumtaustiņus varat redzēt ar `Super + K` (Tmux īsinājumtaustiņus ar `Super + Alt + K` un Herdr īsinājumtaustiņus ar `Super + Ctrl + K`).

## Kā īsinājumtaustiņi ir izkārtoti

Katrs īsinājumtaustiņš atrodas uz plaknes, ko nosaka tā modificētāji, un katrai plaknei ir viens uzdevums. Tas neļauj īsinājumtaustiņiem sajaukties kopā, un tas nozīmē, ka parasti varat uzminēt, kur kas atrodas.

| Plakne | Kas tur atrodas | Piemēri |
| --- | --- | --- |
| `Super + key` | Sistēma: logi, darbvietas, izkārtojumi un galvenās izvēlnes | `Super + Space` Omarchy izvēlne, `Super + W` aizvērt logu, `Super + F` pilnekrāna režīms |
| `Super + Shift + key` | Lietotnes | `Super + Shift + B` pārlūks, `Super + Shift + E` e-pasts, `Super + Shift + N` redaktors |
| `Super + Ctrl + key` | Paneļi un sistēmas izvēlnes | `Super + Ctrl + A` audio, `Super + Ctrl + N` tīkls, `Super + Ctrl + C` uzņemšanas izvēlne |
| `Super + Ctrl + Alt + key` | Ātrās darbības un paziņojumi | `Super + Ctrl + Alt + T` rādīt laiku, `Super + Ctrl + Alt + B` baterija, `Super + Ctrl + Alt + C` ekrānuzņēmums |

`Alt` pievienošana īsinājumtaustiņam dod jums tā paša varianta versiju, nekad kaut ko nesaistītu:

- `Super + Shift + B` atver pārlūku; `Super + Shift + Alt + B` atver privātu logu
- `Super + Shift + E` atver e-pastu; `Super + Shift + Alt + E` sāk jaunu
- `Super + F` pāriet pilnekrāna režīmā; `Super + Alt + F` pāriet pilna platuma režīmā
- `Super + Ctrl + C` atver uzņemšanas izvēlni; `Super + Ctrl + Alt + C` izlaiž izvēlni un uzņem ekrānuzņēmumu

Pievienojot īsinājumtaustiņu:

1. Izvēlieties plakni pēc tā, ko tas dara, pēc tam izvēlieties taustiņu.
2. Nepārvietojiet esošu īsinājumtaustiņu, lai atbrīvotu vietu. Atrodiet brīvu taustiņu uz pareizās plaknes.
3. Izmantojiet `Alt` tikai tā paša īsinājumtaustiņa variantam bez tā.

Daži īsinājumtaustiņi pārkāpj šos noteikumus, jo tā ir ērtāk. `Shift` ar bultiņu vai `Tab` pārvieto vai apgriež, nevis atver lietotni, un `Print`, multivides taustiņi, `Alt + Tab` un `Ctrl + Alt + Del` darbojas tāpat kā visur citur. Tie ir izņēmumi, nevis modeļi, ko kopēt.

Ja noklusējums jums neder (teiksim, vēlaties `Super + Shift + S` ekrānuzņēmumiem kā Windows), pārsaistiet to failā `~/.config/hypr/bindings.lua`.

## Navigācija

| Īsinājumtaustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy izvēlne (lietotnes un viss pārējais)    |
| `Super + Alt + Space` | Lietotņu režģis |
| `Super + Escape` | Sistēmas izvēlne (apturēt, restartēt utt.)  |
| `Super + Ctrl + L` | Bloķēt datoru |
| `Super + W` vai `Super + Q` | Aizvērt logu             |
| `Ctrl + Alt + Del` | Aizvērt visus logus |
| `Super + T`               | Pārslēgt logu starp mozaīkas/pludināšanas režīmu             |
| `Super + J` | Pārslēgt loga pozīciju (horizontāli/vertikāli) |
| `Super + O`               | Pārslēgt loga pārveidošanu par lipīgu un peldošu |
| `Super + L`               | Ciklēt cauri dwindle, scrolling un floating izkārtojumiem |
| `Super + Alt + L`         | Ciklēt cauri izkārtojumiem apgrieztā secībā |
| `Super + P`               | Pārslēgt pseidologa stilu (dabisks pret izstieptu) |
| `Super + F`                 | Pāriet pilnekrāna režīmā              |
| `Super + Alt + F`                 | Pāriet pilna platuma režīmā              |
| `Super + Ctrl + F`                 | Pāriet pilnekrāna režīmā loga iekšpusē              |
| `Super + 1/2/3/4`         | Pāriet uz konkrētu darbvietu fokusētajā monitorā |
| `Super + Tab` | Pāriet uz nākamo darbvietu fokusētajā monitorā |
| `Super + Shift + Tab` | Pāriet uz iepriekšējo darbvietu fokusētajā monitorā |
| `Super + Ctrl + Tab` | Pāriet uz agrāko darbvietu fokusētajā monitorā |
| `Super + Shift + 1/2/3/4` | Pārvietot logu uz darbvietu fokusētajā monitorā |
| `Super + Shift + Alt + 1/2/3/4` | Pārvietot logu uz darbvietu fokusētajā monitorā, nepārejot līdzi |
| `Super + S` | Pārslēgt pilnu scratchpad |
| `Super + Alt + S` | Pārvietot logu uz pilnu scratchpad |
| `Super + Grave` | Pārslēgt Quake konsoli |
| `Super + Shift + Grave` | Pārvietot logu uz Quake konsoli |
| `Super + Shift + Ctrl + Arrows` | Pārvietot logu uz monitoru tajā virzienā |
| `Super + Shift + Alt + Arrows` | Pārvietot darbvietu uz monitoru tajā virzienā |
| `Super + Arrow`  | Pārvietot fokusu uz logu bultiņas virzienā, ekrāna malā pārejot uz monitoru tajā pusē |
| `Super + Shift + Arrow`  | Apmainīt logu ar citu bultiņas virzienā, ieskaitot logu monitorā tajā pusē |
| `Super + Minus` | Izplest logu pa kreisi |
| `Super + Equal` | Samazināt logu pa kreisi |
| `Super + Shift + Minus` | Samazināt logu uz augšu |
| `Super + Shift + Equal` | Izplest logu uz leju |
| `Super + Alt + Minus/Equal` | Tā pati izmēra maiņa mazākos soļos |
| `Super + Ctrl + Minus/Equal` | Tā pati izmēra maiņa lielākos soļos |
| `Super + Alt + Home` | Saglabāt loga platumu |
| `Super + Home` | Atjaunot saglabāto loga platumu |
| `Super + Left Mouse` | Vilkt logu apkārt |
| `Super + Right Mouse` | Mainīt loga izmēru |
| `Super + Scroll Wheel` | Ritināt cauri darbvietām fokusētajā monitorā |
| `Super + G`               | Pārslēgt logu grupēšanu      |
| `Super + Alt + G`               | Pārvietot logu ārā no grupēšanas      |
| `Super + Alt + Tab`               | Ciklēt starp logiem grupējumā      |
| `Super + Alt + Shift + Tab`               | Ciklēt atpakaļ starp logiem grupējumā      |
| `Super + Alt + Scroll Wheel` | Ciklēt starp logiem grupējumā |
| `Super + Alt + 1/2/3/4/5`               | Pāriet uz konkrētu logu grupējumā      |
| `Super + Alt + Arrow`  | Pārvietot logu grupējumā bultiņas virzienā, ieskaitot logu monitorā tajā pusē |
| `Super + Ctrl + Left/Right`  | Pārvietoties starp logiem mozaīkas grupas iekšpusē |
| `Super + Ctrl + Z` | Tuvināt ekrānu (atkārtot lielākai tālummaiņai) |
| `Super + Ctrl + Alt + Z` | Pilnībā tālināt ekrānu |
| `Super + /` | Soli uz priekšu cauri monitora mērogošanas opcijām |
| `Super + Alt + /` | Soli atpakaļ cauri monitora mērogošanas opcijām |
| `Alt + Tab` | Ciklēt uz priekšu cauri logiem aktīvajā darbvietā |
| `Alt + Shift + Tab` | Ciklēt atpakaļ cauri logiem aktīvajā darbvietā |
| `Ctrl + Alt + Tab`| Ciklēt fokusu uz priekšu cauri monitoriem |
| `Ctrl + Alt + Shift + Tab`| Ciklēt fokusu atpakaļ cauri monitoriem |

Izmēra maiņas īsinājumtaustiņi izmanto fiziskos taustiņus `code:20` un `code:21` (XKB `<AE11>` un `<AE12>`), neatkarīgi no rakstzīmēm, kas uzdrukātas uz tastatūras. Uz US tastatūrām šie taustiņi ir `-` un `=`; uz Japānas (JIS) tastatūrām tie ir `-` un `^`; uz Spānijas tastatūrām tie ir `'` un `¡`. Uz JIS `Super + ^` ir `Super + Equal`, savukārt `Super + Shift + -` (kas ievada `=`) ir `Super + Shift + Minus`.

## Sistēmas vadīklas

| Īsinājumtaustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + A`           | Audio panelis    |
| `Super + Ctrl + B`           | Bluetooth panelis    |
| `Super + Ctrl + N`           | Wi-Fi/tīkla panelis    |
| `Super + Ctrl + D`           | Displeja panelis    |
| `Super + Ctrl + P`           | Barošanas panelis    |
| `Super + Ctrl + Alt + D`           | Kalendāra panelis    |
| `Super + Ctrl + Alt + E`           | Pasaules pulksteņa panelis    |
| `Super + Ctrl + 1-9`           | Pārslēgt joslas paneli pēc pozīcijas    |
| `Super + Ctrl + S` | Koplietošanas izvēlne (caur LocalSend) |
| `Super + Ctrl + C` | Uzņemšanas vadīklas (ekrānuzņēmums/-ieraksts/izvēle) |
| `Super + Ctrl + O` | Pārslēgšanas izvēlne |
| `Super + Ctrl + H` | Aparatūras izvēlne |
| `Super + Ctrl + E` | Emocijzīmju izvēle |
| `Super + Ctrl + .` | Transkodēt multividi |
| `Super + Shift + Ctrl + A` | Izvēlēties AI aģentu |

## Pielāgojumi

| Īsinājumtaustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimālais ekrāna spilgtums |
| `Shift + Brightness Down` | Minimālais ekrāna spilgtums |
| `Alt + Brightness Up/Down` | Precīzas 1% spilgtuma izmaiņas |
| `Alt + Volume Up/Down` | Precīzas 1% skaļuma izmaiņas |
| `Keyboard Brightness Up/Down` | Tastatūras apgaismojums spilgtāks/blāvāks |
| `Keyboard Backlight` | Ciklēt tastatūras apgaismojuma līmeņus |
| `Alt + Play` | Nākamais ieraksts |
| `Alt + Shift + Play` | Iepriekšējais ieraksts |

## Lietotņu palaišana

| Īsinājumtaustiņš                  | Funkcija              |
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

Mainiet/pievienojiet īsinājumtaustiņus failā `~/.config/hypr/bindings.lua`.

## Universālā starpliktuve

| Īsinājumtaustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + A`           | Atlasīt visu lietotnēs, kas atbalsta `Ctrl + A`    |
| `Super + C`           | Kopēt    |
| `Super + X`           | Izgriezt (ne terminālī)    |
| `Super + V`           | Ielīmēt    |
| `Super + Ctrl + V`           | Starpliktuves pārvaldnieks    |

Parasti Linux sistēmā, lai kopētu un ielīmētu terminālī, vajag `Ctrl + Shift + C/V`, un `Ctrl + C/V`, lai to darītu visur citur. Šie Omarchy vienotie starpliktuves īsinājumtaustiņi darbojas visur.

## Uzņemšana

| Īsinājumtaustiņš              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Ekrānuzņēmums                      |
| `Super + Ctrl + Alt + C`            | Ekrānuzņēmums (tas pats uzņēmums tastatūrām bez Print Screen taustiņa) |
| `Super + Ctrl + C` | Uzņemšanas izvēlne |
| `Alt + Print Screen`            | Ekrāna ieraksts                     |
| `Super + Print Screen` | Krāsu izvēle |
| `Super + Ctrl + Print Screen` | Teksta izvilkšana starpliktuvē |
| `Super + Alt + [` | Ieraksta laikā padarīt tīmekļa kameras pārklājumu mazāku |
| `Super + Alt + ]` | Ieraksta laikā padarīt tīmekļa kameras pārklājumu lielāku |
| `Alt + Shift + L` | Kopēt pašreizējo URL no tīmekļa lietotnes vai Chromium |
| `Alt + Shift + D` | Lejupielādēt pašreizējās lapas video uz `~/Videos` |
| `Alt + Space` | Sākt/apturēt diktēšanu (nepieciešams _Setup > Defaults > Dictation_) |
| `Right Alt` | Turēt, lai diktētu (nepieciešams _Setup > Defaults > Dictation_) |

Ar ekrāna ierakstiem īsinājumtaustiņš vispirms jautā, kuru audio vēlaties, pēc tam sāk ierakstu. Nospiediet to vēlreiz, lai apturētu. Sīkāk skatiet [ekrānuzņēmumi un ierakstīšana](12-screenshots-recording.md).

Visas uzņemšanas opcijas ir pieejamas arī zem _Trigger > Capture_ Omarchy izvēlnē (`Super + Space`).

## Paziņojumi

| Īsinājumtaustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + ,` | Darboties ar jaunāko paziņojumu: atvērt to vai nospiest tā vienīgo pogu, izvēlēties no tā izvēlēm vai noraidīt to, kad tam nav nevienas  |
| `Super + Shift + ,` | Noraidīt visus paziņojumus |
| `Super + Ctrl + ,` | Vadīt paziņojumus ar tastatūru  |
| `Super + Alt + ,` | Noraidīt jaunāko paziņojumu  |
| `Super + Shift + Alt + ,` | Atvērt paziņojumu vēsturi  |
| `Super + Ctrl + Alt + ,` | Pārslēgt paziņojumu apklusināšanu  |

## Stils

| Īsinājumtaustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + T` | Izvēlēties jaunu motīvu (arī `Super + Ctrl + Shift + Space`) |
| `Super + Ctrl + W` | Izvēlēties motīva fonu (arī `Super + Ctrl + Space`) |
| `Super + Backspace` | Pārslēgt loga caurspīdīgumu |
| `Super + Ctrl + Backspace` | Pārslēgt viena loga kvadrātisku malu attiecību |

Papildu fona attēli atrodas `~/.config/omarchy/backgrounds/<theme name>`. Pieejams arī caur _Install > Style > Background_ Omarchy izvēlnē.

Visas stila opcijas ir pieejamas arī zem _Style_ Omarchy izvēlnē (`Super + Space`).

## Pārslēgšanas

| Īsinājumtaustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + I` | Pārslēgt bloķēšanu dīkstāvē |
| `Super + Ctrl + Delete` | Pārslēgt klēpjdatora displeju ieslēgtu/izslēgtu |
| `Super + Ctrl + Alt + Delete` | Pārslēgt klēpjdatora displeja spoguļošanu |
| `Super + Shift + Space` | Pārslēgt augšējo joslu  |
| `Shift + Mute` | Pārslēgties uz nākamo audio izeju |
| `Shift + Play` | Pārslēgties uz nākamo multivides avotu |
| `Super + Shift + Backspace` | Pārslēgt logu atstarpes |
| `Super + Ctrl + Alt + F` | Pārslēgt pilnekrāna darbvirsmu (augšējā josla + logu atstarpes) |

## Atgādinājumi

| Īsinājumtaustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Iestatīt atgādinājumu  |
| `Super + Ctrl + Alt + R` | Skatīt visus atgādinājumus  |
| `Super + Ctrl + Shift + R` | Notīrīt visus atgādinājumus  |

## Īspaziņojumi

| Īsinājumtaustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Rādīt laiku kā paziņojumu  |
| `Super + Ctrl + Alt + B` | Rādīt bateriju kā paziņojumu  |
| `Super + Ctrl + Alt + W` | Pārslēgt laikapstākļus kā paziņojumu  |

## Tmux

Prefiksa taustiņš ir `Ctrl + Space` (`Ctrl + B` arī darbojas). Šos īsinājumtaustiņus varat mainīt failā `~/.config/tmux/tmux.conf`.

### Rūtis

| Īsinājumtaustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + v` | Sadalīt rūti blakus (vertikāli) |
| `Prefix + h` | Sadalīt rūti zem (horizontāli) |
| `Prefix + x` | Nogalināt rūti |
| `Prefix + z` | Pārslēgt rūts tālummaiņu (pilnekrāna) |
| `Alt + Enter` | Sadalīt rūti zem (bez prefiksa) |
| `Alt + Shift + Enter` | Sadalīt rūti blakus (bez prefiksa) |
| `Alt + Escape` | Nogalināt rūti (bez prefiksa) |
| `Ctrl + Alt + Arrows` | Pārvietoties starp rūtīm |
| `Ctrl + Alt + Shift + Arrows` | Mainīt rūšu izmēru |

### Logi

| Īsinājumtaustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + c` | Jauns logs |
| `Prefix + k` | Nogalināt logu |
| `Prefix + r` | Pārdēvēt logu |
| `Alt + 1-9` | Doties uz konkrētu logu |
| `Alt + Arrow Left/Right` | Pārvietoties starp logiem |
| `Alt + Shift + Arrow Left/Right` | Pārvietot logu pa kreisi/pa labi |

### Sesijas

| Īsinājumtaustiņš                  | Funkcija              |
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

| Īsinājumtaustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + [` | Ienākt kopēšanas režīmā |
| `v` | Sākt atlasi (kopēšanas režīmā) |
| `y` | Kopēt atlasi (kopēšanas režīmā) |

### Vispārīgi

| Īsinājumtaustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + q` | Pārlādēt konfigurāciju |
| `Prefix + ?` | Rādīt Tmux īsinājumtaustiņus |
| `Prefix + :` | Komandu uzvedne |

### Tmux izkārtojuma funkcijas

Šīs funkcijas jāpalaiž Tmux sesijas iekšpusē.

| Komanda | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Izveidot izstrādes izkārtojumu ar redaktoru, AI un termināli |
| `tdlm <ai> [<second_ai>]` | Izveidot izstrādes izkārtojumu katrai apakšdirektorijai |
| `tsl <count> <command>` | Izveidot vairāku rūšu spieta izkārtojumu |

## Ghostty terminālis

Ghostty terminālis tiek instalēts, izmantojot _Install > Terminal_ caur Omarchy izvēlni.

| Īsinājumtaustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Jauna sadale zem |
| `Ctrl + Shift + O` | Jauna sadale blakus |
| `Ctrl + Alt + Arrows` | Pārvietoties starp sadalēm |
| `Super + Ctrl + Shift + Arrows` | Mainīt sadales izmēru par 10 rindām |
| `Super + Ctrl + Shift + Alt + Arrows` | Mainīt sadales izmēru par 100 rindām |
| `Ctrl + Shift + T` | Jauna cilne  |
| `Ctrl + Shift + Arrows` | Pārvietoties starp cilnēm |
| `Alt + Numbers` | Doties uz konkrētu cilni |
| `Shift + Pg Up/Down` | Ritināt vēsturi |
| `Ctrl + Left mouse` | Atvērt saiti pārlūkā |

## Failu pārvaldnieks

| Īsinājumtaustiņš              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Doties uz ceļu                     |
| `Space`               | Priekšskatīt failu (bultiņas navigē) |
| `Alt + Up`       | Doties augšā uz vecākmapi        |

## Neovim (ar lazyvim)

### Navigācija

| Īsinājumtaustiņš                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Rādīt komandu opcijas            |
| `Space Space`              | Atvērt failu caur izplūdušo meklēšanu      |
| `Space E`                  | Pārslēgt sānjoslu                  |
| `Space G G`                | Rādīt git vadīklas               |
| `Space S G`                | Meklēt faila saturu             |
| `Ctrl + W W`               | Lēkt starp sānjoslu un redaktoru |
| `Ctrl + Left/right arrow`  | Mainīt sānjoslas izmēru          |
| `Shift + H`                      | Doties uz kreiso faila cilni             |
| `Shift + L`                      | Doties uz labo faila cilni            |
| `Space B D`                | Aizvērt faila cilni                  |

### Kamēr sānjoslā

| Īsinājumtaustiņš                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `A`                        | Pievienot jaunu failu vecākdirektorijā      |
| `Shift + A`                | Pievienot jaunu apakšdirektoriju vecākdirektorijā    |
| `D`                        | Dzēst iezīmēto failu/direktoriju     |
| `M`                        | Pārvietot iezīmēto failu/direktoriju       |
| `R`                        | Pārdēvēt iezīmēto failu/direktoriju     |
| `?`                        | Rādīt palīdzību visām komandām      |

[Skatiet visus Neovim īsinājumtaustiņus, ko konfigurējis LazyVim](https://www.lazyvim.org/keymaps).

## Ātrās emocijzīmes

Varat izmantot `Super + Ctrl + E`, lai parādītu pilnu emocijzīmju izvēli, kas ievietos atlasi starpliktuvē, vai varat izmantot šīs ātrās piekļuves opcijas.

| Īsinājumtaustiņš       | EM | Norāde       |
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
| `Shift + CapsLock M E` | 🙄 | acu griešana    |
| `Shift + CapsLock M I` | 😉 | mirkšķināšana       |
| `Shift + CapsLock M P` | 🙏 | lūgt |
| `Shift + CapsLock M D` | 🤤 | siekalošanās      |
| `Shift + CapsLock M M` | 💰 | nauda      |
| `Shift + CapsLock M X` | 🎉 | svinēšana |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | tosts      |
| `Shift + CapsLock M O` |👌 | ok |
| `Shift + CapsLock M G` |👋 | sveiciens |
| `Shift + CapsLock M A` |💪 | roka |
| `Shift + CapsLock M B` |🤯 | spridzināšana |

## Ātrie papildinājumi

| Īsinājumtaustiņš       | Papildinājums       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (garā domuzīme)   |
| `Shift + CapsLock Space N` | Jūsu vārds (kā ievadīts iestatīšanas laikā)  |
| `Shift + CapsLock Space E` | Jūsu e-pasts (kā ievadīts iestatīšanas laikā)  |

Varat pievienot vēl savus, rediģējot `~/.XCompose`, pēc tam palaižot `omarchy-restart-xcompose` terminālī, lai izmaiņas tiktu uztvertas.
