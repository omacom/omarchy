# Karstie taustiņi

Visas galvenās taustiņu kombinācijas vari redzēt ar `Super + K` (Tmux kombinācijas ar `Super + Alt + K` un Herdr kombinācijas ar `Super + Ctrl + K`).

## Kā karstie taustiņi ir sakārtoti

Katrs karstais taustiņš atrodas savā plaknē, ko nosaka tā modifikatori, un katrai plaknei ir viens uzdevums. Tieši tāpēc karstie taustiņi nesajaucas, un tu parasti vari uzminēt, kur kas dzīvo.

| Plakne | Kas tur dzīvo | Piemēri |
| --- | --- | --- |
| `Super + key` | Sistēma: logi, darbvietas, izkārtojumi un galvenās izvēlnes | `Super + Space` Omarchy izvēlne, `Super + W` aizvērt logu, `Super + F` pilnekrāns |
| `Super + Shift + key` | Lietotnes | `Super + Shift + B` pārlūks, `Super + Shift + E` e-pasts, `Super + Shift + N` redaktors |
| `Super + Ctrl + key` | Paneļi un sistēmas izvēlnes | `Super + Ctrl + A` audio, `Super + Ctrl + N` tīkls, `Super + Ctrl + C` uzņemšanas izvēlne |
| `Super + Ctrl + Alt + key` | Ātrās darbības un paziņojumi | `Super + Ctrl + Alt + T` rādīt laiku, `Super + Ctrl + Alt + B` akumulators, `Super + Ctrl + Alt + C` ekrānuzņēmums |

Pievienojot `Alt` karstajam taustiņam, iegūsti tā paša varianta, nekad neko nesaistītu:

- `Super + Shift + B` atver pārlūku; `Super + Shift + Alt + B` atver privāto logu
- `Super + Shift + E` atver e-pastu; `Super + Shift + Alt + E` sāk jaunu
- `Super + F` pāriet pilnekrānā; `Super + Alt + F` pāriet pilnā platumā
- `Super + Ctrl + C` atver uzņemšanas izvēlni; `Super + Ctrl + Alt + C` izlaiž izvēlni un uzņem ekrānuzņēmumu

Kad pievieno karsto taustiņu:

1. Vispirms izvēlies plakni pēc tā, ko tas dara, tad izvēlies taustiņu.
2. Nepārvieto esošu karsto taustiņu, lai atbrīvotu vietu. Atrodi brīvu taustiņu pareizajā plaknē.
3. Lieto `Alt` tikai tā karstā taustiņa variantam, kuram tā nav.

Daži karstie taustiņi pārkāpj šos noteikumus, jo tā ir ērtāk. `Shift` ar bultiņu vai `Tab` pārvieto vai maina virzienu, nevis atver lietotni, un `Print`, multivides taustiņi, `Alt + Tab` un `Ctrl + Alt + Del` darbojas tāpat kā visur citur. Tie ir izņēmumi, nevis paraugi, ko kopēt.

Ja noklusējums tev neder (teiksim, vēlies `Super + Shift + S` ekrānuzņēmumiem kā Windows), pārdefinē to failā `~/.config/hypr/bindings.lua`.

## Navigācija

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy izvēlne (lietotnes un viss pārējais)    |
| `Super + Alt + Space` | Lietotņu režģis |
| `Super + Escape` | Sistēmas izvēlne (miega režīms, restartēšana u. c.)  |
| `Super + Ctrl + L` | Bloķēt datoru |
| `Super + W` vai `Super + Q` | Aizvērt logu             |
| `Ctrl + Alt + Del` | Aizvērt visus logus |
| `Super + T`               | Pārslēgt logu starp mozaīkas/pludināto režīmu             |
| `Super + J` | Pārslēgt loga novietojumu (horizontāls/vertikāls) |
| `Super + O`               | Pārslēgt loga izlekšanu lipīgajā un pludinātajā režīmā |
| `Super + L`               | Cikliski pārslēgt dwindle, scrolling un floating izkārtojumus |
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
| `Super + Arrow`  | Pārvietot fokusu uz logu bultiņas virzienā, pie ekrāna malas pārejot uz monitoru tajā pusē |
| `Super + Shift + Arrow`  | Apmainīt logu ar citu bultiņas virzienā, tostarp ar logu monitorā tajā pusē |
| `Super + Minus` | Paplašināt logu pa kreisi |
| `Super + Equal` | Sašaurināt logu pa kreisi |
| `Super + Shift + Minus` | Sašaurināt logu uz augšu |
| `Super + Shift + Equal` | Paplašināt logu uz leju |
| `Super + Alt + Minus/Equal` | Tā pati izmēru maiņa mazākos soļos |
| `Super + Ctrl + Minus/Equal` | Tā pati izmēru maiņa lielākos soļos |
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
| `Super + Alt + Arrow`  | Pārvietot logu grupējumā bultiņas virzienā, tostarp logu monitorā tajā pusē |
| `Super + Ctrl + Left/Right`  | Pārvietoties starp logiem mozaīkas grupas iekšpusē |
| `Super + Ctrl + Z` | Pietuvināt ekrānu (atkārto vēl lielākai pietuvināšanai) |
| `Super + Ctrl + Alt + Z` | Pilnībā attālināt ekrānu |
| `Super + /` | Iet uz priekšu cauri monitora mērogošanas iespējām |
| `Super + Alt + /` | Iet atpakaļ cauri monitora mērogošanas iespējām |
| `Alt + Tab` | Cikliski iet uz priekšu cauri logiem aktīvajā darbvietā |
| `Alt + Shift + Tab` | Cikliski iet atpakaļ cauri logiem aktīvajā darbvietā |
| `Ctrl + Alt + Tab`| Cikliski pārvietot fokusu uz priekšu cauri monitoriem |
| `Ctrl + Alt + Shift + Tab`| Cikliski pārvietot fokusu atpakaļ cauri monitoriem |

Izmēru maiņas saīsnes izmanto fiziskos taustiņus `code:20` un `code:21` (XKB `<AE11>` un `<AE12>`), neatkarīgi no simboliem, kas uzdrukāti uz tastatūras. ASV tastatūrās šie taustiņi ir `-` un `=`; japāņu (JIS) tastatūrās tie ir `-` un `^`; spāņu tastatūrās tie ir `'` un `¡`. JIS tastatūrā `Super + ^` ir `Super + Equal`, bet `Super + Shift + -` (kas raksta `=`) ir `Super + Shift + Minus`.

## Sistēmas vadība

| Karstais taustiņš                  | Funkcija              |
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
| `Super + Ctrl + S` | Kopīgošanas izvēlne (caur LocalSend) |
| `Super + Ctrl + C` | Uzņemšanas vadība (ekrānuzņēmums/-ieraksts/izvēlētājs) |
| `Super + Ctrl + O` | Pārslēgšanas izvēlne |
| `Super + Ctrl + H` | Aparatūras izvēlne |
| `Super + Ctrl + E` | Emoji izvēlētājs |
| `Super + Ctrl + .` | Pārkodēt multividi |
| `Super + Shift + Ctrl + A` | Izvēlēties AI aģentu |

## Pielāgojumi

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimālais ekrāna spilgtums |
| `Shift + Brightness Down` | Minimālais ekrāna spilgtums |
| `Alt + Brightness Up/Down` | Precīzas spilgtuma izmaiņas pa 1% |
| `Alt + Volume Up/Down` | Precīzas skaļuma izmaiņas pa 1% |
| `Keyboard Brightness Up/Down` | Tastatūras apgaismojums spilgtāks/blāvāks |
| `Keyboard Backlight` | Cikliski pārslēgt tastatūras apgaismojuma līmeņus |
| `Alt + Play` | Nākamais skaņdarbs |
| `Alt + Shift + Play` | Iepriekšējais skaņdarbs |

## Lietotņu palaišana

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Return`           | Terminālis    |
| `Super + Alt + Return` | Tmux terminālis |
| `Super + Ctrl + Return` | Herdr (aģentu pārvaldnieks) |
| `Super + Shift + Return`           | Pārlūks    |
| `Super + Shift + Alt + B`           | Pārlūks (privāts/inkognito)    |
| `Super + Shift + F`           | Failu pārvaldnieks    |
| `Super + Shift + Alt + F`           | Failu pārvaldnieks termināļa cwd mapē    |
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

Maini/pievieno kombinācijas failā `~/.config/hypr/bindings.lua`.

## Universālā starpliktuve

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + A`           | Atlasīt visu lietotnēs, kas atbalsta `Ctrl + A`    |
| `Super + C`           | Kopēt    |
| `Super + X`           | Izgriezt (ne terminālī)    |
| `Super + V`           | Ielīmēt    |
| `Super + Ctrl + V`           | Starpliktuves pārvaldnieks    |

Parasti Linux vidē terminālī kopēšanai un ielīmēšanai vajag `Ctrl + Shift + C/V`, bet visur citur — `Ctrl + C/V`. Šie Omarchy vienotie starpliktuves karstie taustiņi darbojas visur.

## Uzņemšana

| Karstais taustiņš              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Ekrānuzņēmums                      |
| `Super + Ctrl + Alt + C`            | Ekrānuzņēmums (tā pati iespēja tastatūrām bez Print Screen taustiņa) |
| `Super + Ctrl + C` | Uzņemšanas izvēlne |
| `Alt + Print Screen`            | Ekrāna ieraksts                     |
| `Super + Print Screen` | Krāsu izvēlētājs |
| `Super + Ctrl + Print Screen` | Teksta izvilkšana uz starpliktuvi |
| `Super + Alt + [` | Ieraksta laikā samazināt tīmekļa kameras pārklājumu |
| `Super + Alt + ]` | Ieraksta laikā palielināt tīmekļa kameras pārklājumu |
| `Alt + Shift + L` | Kopēt pašreizējo URL no tīmekļa lietotnes vai pārlūka |
| `Alt + Shift + D` | Lejupielādēt pašreizējās lapas video uz `~/Videos` |
| `Alt + Space` | Sākt/apturēt diktēšanu (nepieciešams _Setup > Defaults > Dictation_) |
| `Right Alt` | Turi, lai diktētu (nepieciešams _Setup > Defaults > Dictation_) |

Ekrāna ierakstiem karstais taustiņš vispirms pajautā, kuru audio vēlies, un tad sāk ierakstu. Nospied to vēlreiz, lai apturētu. Sīkāk skati [ekrānuzņēmumi un ieraksts](12-screenshots-recording.md).

Visas uzņemšanas iespējas ir pieejamas arī Omarchy izvēlnē (`Super + Space`) sadaļā _Trigger > Capture_.

## Paziņojumi

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + ,` | Darboties ar jaunāko paziņojumu: atvērt to vai nospiest tā vienīgo pogu, izvēlēties no tā iespējām vai noraidīt to, ja iespēju nav  |
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
| `Super + Ctrl + Backspace` | Pārslēgt viena loga kvadrātveida proporcijas |

Papildu fona attēli dzīvo mapē `~/.config/omarchy/backgrounds/<theme name>`. Pieejami arī Omarchy izvēlnē sadaļā _Install > Style > Background_.

Visas stila iespējas ir pieejamas arī Omarchy izvēlnē (`Super + Space`) sadaļā _Style_.

## Pārslēgi

| Karstais taustiņš                  | Funkcija              |
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

Prefiksa taustiņš ir `Ctrl + Space` (der arī `Ctrl + B`). Šīs kombinācijas vari mainīt failā `~/.config/tmux/tmux.conf`.

### Rūtis

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + v` | Sadalīt rūti blakus (vertikāli) |
| `Prefix + h` | Sadalīt rūti zemāk (horizontāli) |
| `Prefix + x` | Nogalināt rūti |
| `Prefix + z` | Pārslēgt rūts pietuvinājumu (pilnekrāns) |
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
| `Prefix + ?` | Rādīt Tmux taustiņu kombinācijas |
| `Prefix + :` | Komandu uzvedne |

### Tmux izkārtojuma funkcijas

Šīs funkcijas jāpalaiž Tmux sesijas iekšpusē.

| Komanda | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Izveidot izstrādes izkārtojumu ar redaktoru, AI un termināli |
| `tdlm <ai> [<second_ai>]` | Izveidot izstrādes izkārtojumu katrai apakšmapei |
| `tsl <count> <command>` | Izveidot vairāku rūšu spieta izkārtojumu |

## Ghostty terminālis

Ghostty termināli instalē Omarchy izvēlnē caur _Install > Terminal_.

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
| `Ctrl + L`            | Iet uz ceļu                     |
| `Space`               | Priekšskatīt failu (navigācija ar bultiņām) |
| `Alt + Up`       | Iet augšup uz vecākmapi        |

## Neovim (ar lazyvim)

### Navigācija

| Karstais taustiņš                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Rādīt komandu iespējas            |
| `Space Space`              | Atvērt failu caur izplūdušo meklēšanu      |
| `Space E`                  | Pārslēgt sānjoslu                  |
| `Space G G`                | Rādīt git vadību               |
| `Space S G`                | Meklēt faila saturā             |
| `Ctrl + W W`               | Lēkt starp sānjoslu un redaktoru |
| `Ctrl + Left/right arrow`  | Mainīt sānjoslas izmēru          |
| `Shift + H`                      | Iet uz kreiso faila cilni             |
| `Shift + L`                      | Iet uz labo faila cilni            |
| `Space B D`                | Aizvērt faila cilni                  |

### Esot sānjoslā

| Karstais taustiņš                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `A`                        | Pievienot jaunu failu vecākmapē      |
| `Shift + A`                | Pievienot jaunu apakšmapi vecākmapē    |
| `D`                        | Dzēst iezīmēto failu/mapi     |
| `M`                        | Pārvietot iezīmēto failu/mapi       |
| `R`                        | Pārdēvēt iezīmēto failu/mapi     |
| `?`                        | Rādīt palīdzību visām komandām      |

[Skatīt visus Neovim karstos taustiņus, ko konfigurē LazyVim](https://www.lazyvim.org/keymaps).

## Ātrie emoji

Vari izmantot `Super + Ctrl + E`, lai parādītu pilnu emoji izvēlētāju, kas atlasi ieliks starpliktuvē, vai arī vari izmantot šīs ātrās piekļuves iespējas.

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
| `Shift + CapsLock M W` | 🤞 | vēlējums       |
| `Shift + CapsLock M R` | 🤘 | roks       |
| `Shift + CapsLock M K` | 😘 | skūpsts       |
| `Shift + CapsLock M E` | 🙄 | acu griešana    |
| `Shift + CapsLock M I` | 😉 | piemiegšana       |
| `Shift + CapsLock M P` | 🙏 | lūgties |
| `Shift + CapsLock M D` | 🤤 | siekalošanās      |
| `Shift + CapsLock M M` | 💰 | nauda      |
| `Shift + CapsLock M X` | 🎉 | svinības |
| `Shift + CapsLock M 1` | 💯 | 100%       |
| `Shift + CapsLock M T` | 🥂 | tosts      |
| `Shift + CapsLock M O` |👌 | labi |
| `Shift + CapsLock M G` |👋 | sveiciens |
| `Shift + CapsLock M A` |💪 | roka |
| `Shift + CapsLock M B` |🤯 | sprāgstoša galva |

## Ātrie papildinājumi

| Karstais taustiņš       | Papildinājums       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (garā domuzīme)   |
| `Shift + CapsLock Space N` | Tavs vārds (kā ievadīts iestatīšanas laikā)  |
| `Shift + CapsLock Space E` | Tavs e-pasts (kā ievadīts iestatīšanas laikā)  |

Vari pievienot vēl savus, rediģējot `~/.XCompose` un pēc tam terminālī palaižot `omarchy-restart-xcompose`, lai izmaiņas tiktu uztvertas.
