# Ja tu nāc no Mac vai Windows

Ja esi gadiem ilgi strādājis ar macOS vai Windows, tavi pirksti zina simt lietu, ko smadzenes ir aizmirsušas, ka vispār ir iemācījušās. Šī nodaļa ir tulkošanas slānis: kur šie instinkti nonāk sistēmā Omarchy. Pašas funkcijas ir padziļināti aprakstītas citur — šis ir tikai karte.

### Super ir visa centrs

Visas muskuļu atmiņas, ko esi izveidojis ap Cmd vai Windows taustiņu, pāriet uz vienu taustiņu: Super. Tas ir Windows taustiņš uz PC klaviatūras, un tas ir enkurs gandrīz katram īsinājumtaustiņam sistēmā Omarchy.

Tavs Spotlight, Raycast vai sākuma izvēlnes reflekss kļūst par `Super + Space`. Tas atver Omarchy izvēlni, kas palaiž lietotnes, maina iestatījumus, instalē programmatūru, tver ekrānu — gandrīz visu. Sāc rakstīt, lai filtrētu. `Super + Alt + Space` parāda visas lietotnes vienā režģī, tāpat kā Launchpad. Skati [navigāciju](04-navigation.md).

### Nekādu ikonu uz darbvirsmas, un doks netraucē

Nav ikonu, ko kārtot uz darbvirsmas, un doks paslēpjas, tiklīdz darbvietā ir logs, līdz tu pabīdi rādītāju līdz tā ekrāna malai — apakšējai, ja vien tu to nepārvieto (skati [navigāciju](04-navigation.md)). Lietotnes tiek palaistas ar īsinājumtaustiņu (`Super + Return` terminālim, `Super + Shift + Return` pārlūkam un `Super + K` sarakstam ar visu, kas ir kartēts) vai no izvēlnes. Vienīgais pastāvīgais saskarnes elements ir [augšējā josla](05-the-top-bar.md), kas pilda to, ko agrāk tev darīja izvēļņu josla, sistēmas teknē un Notification Center — un gandrīz katrs tās logrīks kaut ko dara ar kreiso, labo un vidējo klikšķi.

### Logi novietojas paši

Lielākā domāšanas maiņa: tu nevelc logus apkārt un nepieķer tos pie ekrāna pusēm. Atver logu, un tas aizņem visu ekrānu. Atver otru, un tie to sadala. Tev nekad nav jāizvelk logs no cita apakšas, jo logi nepārklājas.

Kad tev patiešām vajag peldošu logu, `Super + T` pārslēdz aktīvo logu ārā no flīzēšanas (un atpakaļ). Bet vispirms dod flīzēšanai īstu iespēju — tā ir visas lietas sirds. [Navigācija](04-navigation.md) tevi izvedīs caur to.

Darbvietas šķitīs pazīstamas: tās ir macOS Spaces vai Windows virtuālās darbvirsmas, tikai tu tās patiešām lietosi, jo `Super + 1/2/3/4` uzreiz pārlec uz kādu no tām un `Super + Shift + 1/2/3/4` nosūta aktīvo logu turp. Nekādas animācijas aiztures, tikai tūlītēji lēcieni. Tas nozīmē, ka tev varbūt pat nevajadzēs vairākus monitorus, ja pirms tam biji pie tā pieradis.

### Kopēšana un ielīmēšana vienkārši strādā

Mac datorā tev visur bija Cmd + C. Windows datorā tev visur bija Ctrl + C — izņemot termināli, kur tas nogalina tavu programmu. Omarchy tev dod `Super + C`, `Super + X` un `Super + V`, un tie strādā visur, arī terminālī. Nekāda atsevišķa refleksa, ko mācīties čaulai.

Windows cilvēki: jūsu Win + V starpliktuves vēsture dzīvo uz `Super + Ctrl + V`, un tā glabā gan attēlus, gan tekstu. Skati [vienotā starpliktuve un vēsture](08-unified-clipboard-history.md).

### Tulkošanas tabula

| Pēc kā tu sniedzies | Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy izvēlne |
| AirDrop | LocalSend, ar `Super + Ctrl + S` — skati [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` vai `Print Screen` — skati [ekrānuzņēmumi un ierakstīšana](12-screenshots-recording.md) |
| Notification Center | Paziņojumu vēsture uz `Super + Shift + Alt + ,` |
| Time Machine (sistēmai) | Automātiski [sistēmas momentuzņēmumi](47-system-snapshots.md) katrā atjauninājumā |
| App Store / instalētāja lejupielāde | _Install_ izvēlnē vai `omarchy pkg add` — skati [citas pakotnes](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ izvēlnē, kas rediģē vienkāršus konfigurācijas failus — skati [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, uz `Super + Shift + F` — skati [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome uz `Super + Shift + Return`; izvēlies citu sadaļā _Setup > Defaults > Browser_ — skati [pārlūki](23-browsers.md) |
| Preview / Photos | Omaview attēliem, video un mūzikai, Document Viewer PDF failiem — skati [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, uz `Super + Shift + N`; izvēlies citu sadaļā _Setup > Defaults > Editor_ |

### Dažas lietas patiešām ir citādas

Daudzi iestatījumi dzīvo teksta failos, ko tu rediģē, nevis paneļos, kuros klikšķini. Tas izklausās primitīvi, līdz saproti, ka tas nozīmē, ka katru pielāgojumu var redzēt, nokopēt uz nākamo datoru un ievietot versiju vadībā. _Setup_ izvēlne tevi iemet tieši pareizajā failā un restartē visu, kas jārestartē, kad esi pabeidzis.

Atjauninājumi nāk caur vienu komandu — _Update > Omarchy_ — kas atjaunina pašu Omarchy un katru pakotni sistēmā, pirms tam izveidojot momentuzņēmumu. Nekādu atsevišķu lietotņu atjauninātāju, kas baksta tevi nejaušos brīžos. Skati [atjauninājumus](30-updates.md).

Programmatūra nāk no pakotņu pārvaldnieka, nevis no lejupielādētiem instalētājiem.

Un, kad tu aizver logu, lietotne patiešām aizveras. Nav nekādas macOS raksturīgās starptelpas, kur programma turpina darboties bez logiem. `Super + W` — vai `Super + Q`, ja tā ir pirkstu atmiņa, ar kuru tu ieradies — nozīmē: prom.

### Uz Mac aparatūras

Omarchy labi strādā Intel Mac datoros un M1, M2 un M3 Mac datoros ar Omarchy for Apple Silicon. Skati [Mac atbalstu](44-mac-support.md). Un klaviatūra ir tev laipna: Omarchy neko nepārkartē, un Linux Command taustiņu uztver kā Super, tāpēc Super atrodas tieši tur, kur vienmēr bija Cmd. Tavs īkšķis pārcelšanos nepamanīs.

### Dod tam divas nedēļas

Instinkti pārceļas ātrāk, nekā tu domā. Vienreiz pārskrien pāri [īsinājumtaustiņu](07-hotkeys.md) nodaļai, un ikreiz, kad piemirsti kādu saistījumu, spied `Super + K` — tas tev parādīs visus. Tas ir vienīgais īsinājumtaustiņš, kas tev patiešām jāiegaumē.
