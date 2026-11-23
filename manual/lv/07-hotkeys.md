# Karstie taustiņi

Visas galvenās taustiņu piesaistes vari redzēt ar `Super + K` (Tmux piesaistes ar `Super + Alt + K` un Herdr piesaistes ar `Super + Ctrl + K`).

## Kā karstie taustiņi ir sakārtoti

Katrs karstais taustiņš atrodas uz plaknes, ko nosaka tā modifikatori, un katrai plaknei ir viens uzdevums. Tas neļauj karstajiem taustiņiem saplūst kopā un nozīmē, ka parasti vari uzminēt, kur kas dzīvo.

| Plakne | Kas tur dzīvo | Piemēri |
| --- | --- | --- |
| `Super + key` | Sistēma: logi, darbvietas, izkārtojumi un galvenās izvēlnes | `Super + Space` Omarchy izvēlne, `Super + W` aizvērt logu, `Super + F` pilnekrāns |
| `Super + Shift + key` | Lietotnes | `Super + Shift + B` pārlūks, `Super + Shift + E` e-pasts, `Super + Shift + N` redaktors |
| `Super + Ctrl + key` | Paneļi un sistēmas izvēlnes | `Super + Ctrl + A` audio, `Super + Ctrl + N` tīkls, `Super + Ctrl + C` uztveršanas izvēlne |
| `Super + Ctrl + Alt + key` | Ātrās darbības un paziņojumi | `Super + Ctrl + Alt + T` rādīt laiku, `Super + Ctrl + Alt + B` akumulators, `Super + Ctrl + Alt + C` ekrānuzņēmums |

`Alt` pievienošana karstajam taustiņam dod tās pašas lietas variantu, nekad neko nesaistītu:

- `Super + Shift + B` atver pārlūku; `Super + Shift + Alt + B` atver privātu logu
- `Super + Shift + E` atver e-pastu; `Super + Shift + Alt + E` sāk jaunu
- `Super + F` pāriet pilnekrānā; `Super + Alt + F` pāriet pilnā platumā
- `Super + Ctrl + C` atver uztveršanas izvēlni; `Super + Ctrl + Alt + C` izlaiž izvēlni un uzņem ekrānuzņēmumu

Pievienojot karsto taustiņu:

1. Izvēlies plakni pēc tā, ko tas dara, pēc tam izvēlies taustiņu.
2. Nepārvieto esošu karsto taustiņu, lai atbrīvotu vietu. Atrodi brīvu taustiņu uz pareizās plaknes.
3. `Alt` izmanto tikai karstā taustiņa bez tā variantam.

Daži karstie taustiņi pārkāpj šos noteikumus, jo tā ir ērti. `Shift` ar bultiņu vai `Tab` pārvieto vai maina virzienu, nevis atver lietotni, un `Print`, multivides taustiņi, `Alt + Tab` un `Ctrl + Alt + Del` darbojas tā, kā tie darbojas visur citur. Tie ir izņēmumi, nevis paraugi, ko kopēt.

Ja noklusējums tev neder (teiksim, vēlies `Super + Shift + S` ekrānuzņēmumiem kā Windows), pārpiesaki to `~/.config/hypr/bindings.lua`.

## Navigācija

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Space`           | Omarchy izvēlne (lietotnes un viss pārējais)    |
| `Super + Alt + Space` | Lietotņu režģis |
| `Super + Escape` | Sistēmas izvēlne (iemidzināt, restartēt u. c.)  |
| `Super + Ctrl + L` | Bloķēt datoru |
| `Super + W` or `Super + Q` | Aizvērt logu             |
| `Ctrl + Alt + Del` | Aizvērt visus logus |
| `Super + K` | Rādīt visus karstos taustiņus |
| `Super + Alt + K` | Rādīt tmux karstos taustiņus |
| `Super + Ctrl + K` | Rādīt herdr karstos taustiņus |
| `Super + M` | Minimizēt logu dokā |
| `Super + T`               | Pārslēgt logu starp salikšanu un peldošo režīmu             |
| `Super + J` | Pārslēgt loga pozīciju (horizontāli/vertikāli) |
| `Super + O`               | Pārvērst logu lipīgā un peldošā logā |
| `Super + L`               | Cikliski pārslēgties starp dwindle, scrolling un floating izkārtojumiem |
| `Super + Alt + L`         | Cikliski pārslēgties starp izkārtojumiem pretējā virzienā |
| `Super + P`               | Pārslēgt pseidologa stilu (dabiskais pret izstiepto) |
| `Super + F`                 | Pāriet pilnekrānā              |
| `Super + Alt + F`                 | Pāriet pilnā platumā              |
| `Super + Ctrl + F`                 | Pāriet pilnekrānā loga iekšpusē              |
| `Super + 1…9/0`         | Pārlēkt uz konkrētu darbvietu (0 ir 10) fokusētajā monitorā |
| `Super + Tab` | Pārlēkt uz nākamo darbvietu fokusētajā monitorā |
| `Super + Shift + Tab` | Pārlēkt uz iepriekšējo darbvietu fokusētajā monitorā |
| `Super + Ctrl + Tab` | Pārlēkt uz agrāko darbvietu fokusētajā monitorā |
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
| `Super + Left Mouse` | Vilkt logu |
| `Super + Right Mouse` | Mainīt loga izmēru |
| `Super + Scroll Wheel` | Ritināli caur darbvietām fokusētajā monitorā |
| `Super + G`               | Pārslēgt logu grupēšanu      |
| `Super + Alt + G`               | Izņemt logu no grupas      |
| `Super + Alt + Tab`               | Cikliski pārslēgties starp logiem grupā      |
| `Super + Alt + Shift + Tab`               | Cikliski pārslēgties atpakaļ starp logiem grupā      |
| `Super + Alt + Scroll Wheel` | Cikliski pārslēgties starp logiem grupā |
| `Super + Alt + 1/2/3/4/5`               | Pārlēkt uz konkrētu logu grupā      |
| `Super + Alt + Arrow`  | Pārvietot logu grupā bultiņas virzienā, ieskaitot logu monitorā tajā pusē |
| `Super + Ctrl + Left/Right`  | Pārvietoties starp logiem salikšanas grupas iekšpusē |
| `Super + Ctrl + Z` | Tuvināt ekrānu (atkārto, lai tuvinātu vēl vairāk) |
| `Super + Ctrl + Alt + Z` | Pilnībā tālināt ekrānu |
| `Super + /` | Virzīties uz priekšu starp monitora mērogošanas iespējām |
| `Super + Alt + /` | Virzīties atpakaļ starp monitora mērogošanas iespējām |
| `Alt + Tab` | Cikliski virzīties uz priekšu starp logiem aktīvajā darbvietā |
| `Alt + Shift + Tab` | Cikliski virzīties atpakaļ starp logiem aktīvajā darbvietā |
| `Ctrl + Alt + Tab`| Cikliski pārvietot fokusu uz priekšu starp monitoriem |
| `Ctrl + Alt + Shift + Tab`| Cikliski pārvietot fokusu atpakaļ starp monitoriem |
| `Super + I` | Pārslēgt ievades valodu (ja ir vairāk nekā viens izkārtojums vai ievades metode) |
| `Super + Shift + I` | Pārslēgt ievades valodu atpakaļ |

Skārienpaliktnī vilkšanas žesti ar trim un četriem pirkstiem pārslēdz darbvietas, pārvieto logus un atver izvēlni un Quake konsoli; žestus skati [tastatūra, pele un skārienpaliktnis](34-keyboard-mouse-trackpad.md).

Izmēra maiņai izmanto divus taustiņus pa labi no 0 neatkarīgi no tā, kas uz tavas tastatūras uzdrukāts: `-` un `=` uz US tastatūrām, `+` un `´` uz dāņu un zviedru, `+` un `\` uz norvēģu, `ß` un `´` uz vācu, `'` un `¡` uz spāņu un `-` un `^` uz japāņu (JIS). `Super + K` tos uzskaita tā, kā tava tastatūra tos drukā. JIS gadījumā `Super + ^` ir `Super + Equal`, savukārt `Super + Shift + -` (kas raksta `=`) ir `Super + Shift + Minus`. Monitora mērogošana un paroļu pārvaldnieks izmanto `/`; izkārtojumos, kas `/` raksta tikai ar Shift, kā lielākā daļa Eiropas izkārtojumu, tie izmanto taustiņu pa kreisi no labā Shift (`-` dāņu un vācu gadījumā).

## Sistēmas vadība

| Karstais taustiņš                  | Funkcija              |
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
| `Super + Ctrl + S` | Koplietošanas izvēlne (caur LocalSend) |
| `Super + Ctrl + C` | Uztveršanas vadība (ekrānuzņēmums/-ieraksts/-atlasītājs) |
| `Super + Ctrl + O` | Pārslēgt izvēlni |
| `Super + Ctrl + H` | Aparatūras izvēlne |
| `Super + Ctrl + E` | Emocijzīmju atlasītājs |
| `Super + Ctrl + .` | Pārkodēt multividi |
| `Super + Shift + Ctrl + A` | Palaist noklusējuma aģentu |
| `Power` taustiņš | Sistēmas izvēlne |
| `Super + Shift + Copilot` taustiņš | Omarchy izvēlne |

## Pielāgojumi

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Shift + Brightness Up` | Maksimālais ekrāna spilgtums |
| `Shift + Brightness Down` | Minimālais ekrāna spilgtums |
| `Alt + Brightness Up/Down` | Precīzas 1% spilgtuma izmaiņas |
| `Alt + Volume Up/Down` | Precīzas 1% skaļuma izmaiņas |
| `Keyboard Brightness Up/Down` | Tastatūras apgaismojums spilgtāks/blāvāks |
| `Keyboard Backlight` | Cikliski pārslēgt tastatūras apgaismojuma līmeņus |
| `Ctrl + Brightness Up/Down` | Tastatūras apgaismojums spilgtāks/blāvāks tastatūrām bez saviem taustiņiem |
| `Mic Mute` | Izslēgt mikrofonu |
| `Shift + Mute` | Pārslēgt audio izvadi |
| `Touchpad Toggle` | Ieslēgt vai izslēgt skārienpaliktni |
| `Display` key | Cikliski pārslēgt darbvietas izkārtojumu |
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
| `Super + Shift + /`           | Paroļu pārvaldnieks (1password)    |
| `Super + Shift + Q` or `Calculator` key  | Kalkulators (Omacalc)    |
| `Super + Shift + D`           | Docker (lazydocker, pēc instalēšanas)    |
| `Super + Shift + T`           | Aktivitāte (btop)    |
| `Super + Shift + N`           | Redaktors (Plain vai tavs izvēlētais noklusējums)  |
| `Super + Shift + C`           | Kalendārs ([HEY](https://hey.com/))  |
| `Super + Shift + E`           | E-pasts ([HEY](https://hey.com/))  |
| `Super + Shift + Alt + E`           | Jauns e-pasts ([HEY](https://hey.com/))  |
| `Super + Shift + A`           | Tavs noklusējuma aģents vai ChatGPT, līdz izvēlies kādu |
| `Super + Shift + Alt + A`           | MI (Grok)  |
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

Maini/pievieno piesaistes `~/.config/hypr/bindings.lua`.

## Universālā starpliktuve

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + A`           | Atlasīt visu lietotnēs, kas atbalsta `Ctrl + A`    |
| `Super + C`           | Kopēt    |
| `Super + X`           | Izgriezt (ne terminālī)    |
| `Super + V`           | Ielīmēt    |
| `Super + Ctrl + V`           | Starpliktuves pārvaldnieks    |

Parasti Linux sistēmā terminālī kopēšanai'n'ielīmēšanai vajag `Ctrl + Shift + C/V`, bet visur citur — `Ctrl + C/V`. Šie Omarchy vienotās starpliktuves karstie taustiņi darbojas visur.

## Uztveršana

| Karstais taustiņš              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Print Screen`            | Ekrānuzņēmums                      |
| `Super + Ctrl + Alt + C`            | Ekrānuzņēmums (tas pats uzņēmums tastatūrām bez Print Screen taustiņa) |
| `Super + Ctrl + C` | Uztveršanas izvēlne |
| `Alt + Print Screen`            | Ekrānieraksts                     |
| `Super + Shift + Ctrl + Alt + C` | Ekrānieraksts bez audio, izlaižot izvēlni (nospied vēlreiz, lai apturētu) |
| `Super + Print Screen` | Krāsu atlasītājs |
| `Super + Ctrl + Print Screen` | Teksta izgūšana starpliktuvē |
| `Super + Alt + [` | Ieraksta laikā samazināt tīmekļa kameras pārklājumu |
| `Super + Alt + ]` | Ieraksta laikā palielināt tīmekļa kameras pārklājumu |
| `Alt + Shift + L` | Kopēt pašreizējo URL no tīmekļa lietotnes vai pārlūka |
| `Alt + Shift + D` | Lejupielādēt pašreizējās lapas video uz `~/Videos` |
| `Alt + Space` | Sākt/apturēt diktēšanu (nepieciešams _Setup > Defaults > Dictation_) |
| `Right Alt` | Turi, lai diktētu (nepieciešams _Setup > Defaults > Dictation_) |

Veicot ekrānierakstus, karstais taustiņš vispirms jautā, kādu audio vēlies, un pēc tam sāk ierakstīt. Nospied to vēlreiz, lai apturētu. Detalizētu informāciju skati [ekrānuzņēmumi un ierakstīšana](12-screenshots-recording.md).

Visas uztveršanas iespējas ir pieejamas arī Omarchy izvēlnes (`Super + Space`) sadaļā _Trigger > Capture_.

## Paziņojumi

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + ,` | Rīkoties ar jaunāko paziņojumu: atvērt to vai nospiest tā vienīgo pogu, izvēlēties no tā izvēlēm vai noraidīt to, ja izvēļu nav  |
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

Papildu fona attēli atrodas `~/.config/omarchy/backgrounds/<theme name>`. Pieejams arī Omarchy izvēlnē _Install > Style > Background_.

Visas stila iespējas ir pieejamas arī Omarchy izvēlnes (`Super + Space`) sadaļā _Appearance_.

## Pārslēgi

| Karstais taustiņš                  | Funkcija              |
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

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + R` | Iestatīt atgādinājumu  |
| `Super + Ctrl + Alt + R` | Redzēt visus atgādinājumus  |
| `Super + Ctrl + Shift + R` | Notīrīt visus atgādinājumus  |

## Informatīvie paziņojumi

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Super + Ctrl + Alt + T` | Rādīt laiku kā paziņojumu  |
| `Super + Ctrl + Alt + B` | Rādīt akumulatoru kā paziņojumu  |
| `Super + Ctrl + Alt + W` | Pārslēgt laikapstākļus kā paziņojumu  |

## Tmux

Prefiksa taustiņš ir `Ctrl + Space` (der arī `Ctrl + B`). Šīs piesaistes vari mainīt `~/.config/tmux/tmux.conf`.

### Rūtis

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + v` | Sadalīt rūti blakus (vertikāli) |
| `Prefix + h` | Sadalīt rūti apakšā (horizontāli) |
| `Prefix + x` | Izbeigt rūti |
| `Prefix + z` | Pārslēgt rūts tālummaiņu (pilnekrāns) |
| `Alt + Enter` | Sadalīt rūti apakšā (bez prefiksa) |
| `Alt + Shift + Enter` | Sadalīt rūti blakus (bez prefiksa) |
| `Alt + Escape` | Izbeigt rūti (bez prefiksa) |
| `Ctrl + Alt + Arrows` | Pārvietoties starp rūtīm |
| `Ctrl + Alt + Shift + Arrows` | Mainīt rūšu izmēru |

### Logi

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + c` | Jauns logs |
| `Prefix + k` | Izbeigt logu |
| `Prefix + r` | Pārdēvēt logu |
| `Alt + 1-9` | Doties uz konkrētu logu |
| `Alt + Arrow Left/Right` | Pārvietoties starp logiem |
| `Alt + Shift + Arrow Left/Right` | Pārvietot logu pa kreisi/pa labi |

### Sesijas

| Karstais taustiņš                  | Funkcija              |
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

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + [` | Ieeiet kopēšanas režīmā |
| `v` | Sākt atlasi (kopēšanas režīmā) |
| `y` | Kopēt atlasi (kopēšanas režīmā) |

### Vispārīgi

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Prefix + q` | Pārlādēt konfigurāciju |
| `Prefix + ?` | Rādīt Tmux taustiņu piesaistes |
| `Prefix + :` | Komandu uzvedne |

### Tmux izkārtojuma funkcijas

Šīs funkcijas jāpalaiž Tmux sesijas iekšpusē.

| Komanda | Funkcija |
| ------- | -------- |
| `tdl <ai> [<second_ai>]` | Izveidot izstrādes izkārtojumu ar redaktoru, AI un termināli |
| `tdlm <ai> [<second_ai>]` | Izveidot izstrādes izkārtojumu katrai apakšmapei |
| `tsl <count> <command>` | Izveidot vairāku rūšu spieta izkārtojumu |

## Ghostty terminālis

Ghostty terminālis tiek instalēts Omarchy izvēlnē, izmantojot _Install > Terminal_.

| Karstais taustiņš                  | Funkcija              |
| ----------------------- | --------------------- |
| `Ctrl + Shift + E` | Jauns sadalījums apakšā |
| `Ctrl + Shift + O` | Jauns sadalījums blakus |
| `Ctrl + Alt + Arrows` | Pārvietoties starp sadalījumiem |
| `Super + Ctrl + Shift + Arrows` | Mainīt sadalījuma izmēru par 10 rindām |
| `Super + Ctrl + Shift + Alt + Arrows` | Mainīt sadalījuma izmēru par 100 rindām |
| `Ctrl + Shift + T` | Jauna cilne  |
| `Ctrl + Shift + Arrows` | Pārvietoties starp cilnēm |
| `Alt + Numbers` | Doties uz konkrētu cilni |
| `Shift + Pg Up/Down` | Ritināli vēsturi |
| `Ctrl + Left mouse` | Atvērt saiti pārlūkā |

## Failu pārvaldnieks

| Karstais taustiņš              | Funkcija                       |
| ------------------- | ------------------------------ |
| `Ctrl + L`            | Doties uz ceļu                     |
| `Space`               | Priekšskatīt failu (navigācija ar bultiņām) |
| `Alt + Up`       | Doties uz augšu uz vecākmapi        |

## Neovim (ar lazyvim)

### Navigācija

| Karstais taustiņš                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `Space`                    | Rādīt komandu iespējas            |
| `Space Space`              | Atvērt failu ar neskaidro meklēšanu      |
| `Space E`                  | Pārslēgt sānjoslu                  |
| `Space G G`                | Rādīt git vadību               |
| `Space S G`                | Meklēt faila saturā             |
| `Ctrl + W W`               | Pārlēkt starp sānjoslu un redaktoru |
| `Ctrl + Left/right arrow`  | Mainīt sānjoslas izmēru          |
| `Shift + H`                      | Doties uz kreiso faila cilni             |
| `Shift + L`                      | Doties uz labo faila cilni            |
| `Space B D`                | Aizvērt faila cilni                  |

### Kamēr esi sānjoslā

| Karstais taustiņš                   | Funkcija                        |
| ------------------------ | ------------------------------- |
| `A`                        | Pievienot jaunu failu vecākmapē      |
| `Shift + A`                | Pievienot jaunu apakšmapi vecākmapē    |
| `D`                        | Dzēst iezīmēto failu/mapi     |
| `M`                        | Pārvietot iezīmēto failu/mapi       |
| `R`                        | Pārdēvēt iezīmēto failu/mapi     |
| `?`                        | Rādīt palīdzību visām komandām      |

[Skaties visus Neovim karstos taustiņus, ko konfigurē LazyVim](https://www.lazyvim.org/keymaps).

## Ātrās emocijzīmes

Vari izmantot `Super + Ctrl + E`, lai rādītu pilnu emocijzīmju atlasītāju, kas atlasi ievietos starpliktuvē, vai izmantot šīs ātrās piekļuves iespējas.

| Karstais taustiņš       | EM | Mājiens       |
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
| `Shift + CapsLock M B` |🤯 | sprādziens |

## Ātrie papildinājumi

| Karstais taustiņš       | Papildinājums       |
| ------------ |  ---------- |
| `Shift + CapsLock Space Space` | — (garā domuzīme)   |
| `Shift + CapsLock Space N` | Tavs vārds (kā ievadīts iestatīšanā)  |
| `Shift + CapsLock Space E` | Tavs e-pasts (kā ievadīts iestatīšanā)  |

Vari pievienot vēl savus, rediģējot `~/.XCompose` un pēc tam terminālī palaižot `omarchy restart xcompose`, lai izmaiņas tiktu uztvertas.
