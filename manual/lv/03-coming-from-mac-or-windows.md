# Pārnākot no Mac vai Windows

Ja esi gadiem ilgi lietojis macOS vai Windows, tavi pirksti zina simt lietu, ko tavas smadzenes ir aizmirsušas, ka vispār ir iemācījušās. Šī nodaļa ir tulkošanas slānis: kur šie instinkti nonāk sistēmā Omarchy. Pašas funkcijas ir sīki aprakstītas citur — šis ir tikai karte.

### Super ir visa centrā

Visa muskuļu atmiņa, ko esi izveidojis ap Cmd vai Windows taustiņu, pāriet uz vienu taustiņu: Super. Tas ir Windows taustiņš uz PC klaviatūras, un tas ir enkurs gandrīz katram karstajam taustiņam sistēmā Omarchy.

Tavs Spotlight vai Raycast vai Start izvēlnes reflekss kļūst par `Super + Space`. Tas atver Omarchy izvēlni, kas palaiž lietotnes, maina iestatījumus, instalē programmatūru, tver ekrānu — gandrīz visu. Sāc rakstīt, lai filtrētu. `Super + Alt + Space` parāda visas lietotnes vienā režģī, tāpat kā to dara Launchpad. Skatīt [navigāciju](04-navigation.md).

### Nav ikonu uz darbvirsmas, un doks turas malā

Nav ikonu, ko kārtot uz darbvirsmas, un doks paslēpjas, tiklīdz darbvietā ir logs, līdz pabīdi rādītāju līdz tā ekrāna malai, labajai, ja vien nepārvieto to (skatīt [navigāciju](04-navigation.md)). Lietotnes startē no karstā taustiņa (`Super + Return` terminālim, `Super + Shift + Return` pārlūkam un `Super + K` sarakstam ar visu, kas ir kartēts) vai no izvēlnes. Vienīgā pastāvīgā UI daļa ir [augšējā josla](05-the-top-bar.md), kas aptver to, ko agrāk tev darīja izvēļņu josla, sistēmas tekne un Notification Center — un gandrīz katrs logrīks uz tās kaut ko dara ar kreiso, labo un vidējo klikšķi.

### Logi izvietojas paši

Lielākā domāšanas maiņa: tu nevelc logus apkārt un nenofiksē tos pie ekrāna pusēm. Atver logu, un tas aizņem visu ekrānu. Atver otru, un tie sadala to. Tu nekad neizvelc logu no apakšas citam, jo logi nepārklājas.

Kad tev patiešām vajag peldošu logu, `Super + T` pārslēdz aktīvo ārā no mozaīkas (un atpakaļ). Bet vispirms dod mozaīkai īstu iespēju — tā ir visas lietas sirds. [Navigācija](04-navigation.md) tevi izvedīs tai cauri.

Darbvietas šķitīs pazīstamas: tās ir macOS Spaces vai Windows virtuālās darbvirsmas, tikai tu tās patiešām izmantosi, jo `Super + 1/2/3/4` uzreiz pārlec uz vienu un `Super + Shift + 1/2/3/4` nosūta aktīvo logu turp. Nekādas animācijas aiztures, tikai tūlītēji lēcieni. Tas nozīmē, ka tev varbūt pat nevajadzēs vairākus monitorus, ja pie tā biji pieradis agrāk.

### Kopēšana un ielīmēšana vienkārši darbojas

Uz Mac tev visur bija Cmd + C. Uz Windows tev visur bija Ctrl + C — izņemot termināli, kur tas nogalina tavu programmu. Omarchy tev dod `Super + C`, `Super + X` un `Super + V`, un tie darbojas visur, arī terminālī. Nekāda atsevišķa refleksa, kas jāiemācās čaulai.

Windows ļaudis: tava Win + V starpliktuves vēsture dzīvo uz `Super + Ctrl + V`, un tā glabā arī attēlus, ne tikai tekstu. Skatīt [vienoto starpliktuvi un vēsturi](08-unified-clipboard-history.md).

### Tulkošanas tabula

| Pēc kā tu sniedzies | Sistēmā Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy izvēlne |
| AirDrop | LocalSend, ar `Super + Ctrl + S` — skatīt [grafiskās saskarnes](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` vai `Print Screen` — skatīt [ekrānuzņēmumus un ierakstīšanu](12-screenshots-recording.md) |
| Notification Center | Paziņojumu vēsture uz `Super + Shift + Alt + ,` |
| Time Machine (sistēmai) | Automātiski [sistēmas momentuzņēmumi](47-system-snapshots.md) katrā atjauninājumā |
| App Store / instalatora lejupielāde | _Install_ izvēlnē vai `omarchy pkg add` — skatīt [citas pakotnes](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ izvēlnē, kas rediģē vienkāršus konfigurācijas failus — skatīt [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, uz `Super + Shift + F` — skatīt [grafiskās saskarnes](22-guis.md) |
| Safari / Edge | Google Chrome uz `Super + Shift + Return`; izvēlies citu sadaļā _Setup > Defaults > Browser_ — skatīt [pārlūkus](23-browsers.md) |
| Preview / Photos | Omaview attēliem, video un mūzikai, Document Viewer PDF failiem — skatīt [grafiskās saskarnes](22-guis.md) |
| TextEdit / Notepad | Plain, uz `Super + Shift + N`; izvēlies citu sadaļā _Setup > Defaults > Editor_ |

### Dažas lietas patiešām ir citādas

Daudzi iestatījumi dzīvo teksta failos, ko tu rediģē, nevis paneļos, kuros klikšķini. Tas izklausās primitīvi, līdz saproti, ka tas nozīmē: katru pielāgojumu var redzēt, nokopēt uz nākamo datoru un likt versiju kontrolē. _Setup_ izvēlne tevi iemet tieši pareizajā failā un restartē visu, kas jārestartē, kad esi pabeidzis.

Atjauninājumi nāk caur vienu komandu — _Update > Omarchy_ — kas atjaunina pašu Omarchy un katru pakotni sistēmā, pirms tam izveidojot momentuzņēmumu. Nekādu atsevišķu lietotņu atjauninātāju, kas kaitina nejauši. Skatīt [atjauninājumus](30-updates.md).

Programmatūra nāk no pakotņu pārvaldnieka, nevis no lejupielādētiem instalatoriem.

Un, kad aizver logu, lietotne patiešām aizveras. Nav tā macOS starpstāvokļa, kur programma turpina darboties bez logiem. `Super + W` — vai `Super + Q`, ja tā ir pirkstu atmiņa, ar ko ieradies — nozīmē prom.

### Uz Mac aparatūras

Omarchy labi darbojas uz Intel Mac datoriem un uz M1, M2 un M3 Mac datoriem ar Omarchy for Apple Silicon. Skatīt [Mac atbalstu](44-mac-support.md). Un klaviatūra ir tev draudzīga: Omarchy neko nepārkartē, un Linux Command taustiņu uztver kā Super, tāpēc Super atrodas tieši tur, kur vienmēr bija Cmd. Tavs īkšķis pārcelšanos nepamanīs.

### Dod tam divas nedēļas

Instinkti pārnesas ātrāk, nekā domā. Vienreiz izskrien cauri [karsto taustiņu](07-hotkeys.md) nodaļai, un ikreiz, kad piemirsti piesaisti, spied `Super + K` — tas parāda tās visas. Tas ir vienīgais karstais taustiņš, kas tev patiešām jāiegaumē.
