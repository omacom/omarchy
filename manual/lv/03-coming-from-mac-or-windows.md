# Pāreja no Mac vai Windows

Ja gadiem esi pavadījis macOS vai Windows vidē, tavi pirksti zina simt lietu, par kurām tavas smadzenes jau ir aizmirsušas, ka tās jebkad ir iemācījušās. Šī nodaļa ir tulkojuma slānis: kur šie instinkti nonāk Omarchy. Pašas funkcijas padziļināti apskatītas citur — šis ir tikai ceļvedis.

### Super ir visa centrā

Visa muskuļu atmiņa, ko esi izveidojis ap Cmd vai Windows taustiņu, pāriet uz vienu taustiņu: Super. Tas ir Windows taustiņš uz datora klaviatūras, un tas ir pamats gandrīz katrai īsinājumtaustiņu kombinācijai Omarchy.

Tavs Spotlight, Raycast vai Start izvēlnes reflekss kļūst par `Super + Space`. Tas atver Omarchy izvēlni, kas palaiž lietotnes, maina iestatījumus, instalē programmatūru, tver ekrānu — praktiski visu. Sāc rakstīt, lai filtrētu. `Super + Alt + Space` parāda visas lietotnes vienā režģī, tāpat kā Launchpad. Skati [navigāciju](04-navigation.md).

### Nekādu darbvirsmas ikonu, un doks parādās tikai peldošajā režīmā

Nekādu ikonu, ko kārtot uz darbvirsmas, un nekāda doka uz mozaīkas darbvietas — doks parādās tikai peldošajā darbvietā (skati [navigāciju](04-navigation.md)). Lietotnes palaiž ar īsinājumtaustiņu (`Super + Return` terminālim, `Super + Shift + Return` pārlūkam un `Super + K` sarakstam ar visu, kas ir piesaistīts) vai no izvēlnes. Vienīgais pastāvīgais saskarnes elements ir [augšējā josla](05-the-top-bar.md), kas aptver to, ko agrāk tev darīja izvēļņu josla, sistēmas tekne un Notification Center — un gandrīz katrs tās logrīks kaut ko dara ar kreiso, labo un vidējo klikšķi.

### Logi izvietojas paši

Lielākā domāšanas maiņa: tu nevelc logus apkārt un nenostiprini tos pie ekrāna pusēm. Atver logu, un tas aizņem visu ekrānu. Atver otru, un tie sadala ekrānu. Tu nekad neizvelc logu no apakšas citam, jo logi nepārklājas.

Kad tev patiešām vajag peldošu logu, `Super + T` pārslēdz aktīvo logu ārā no mozaīkas izkārtojuma (un atpakaļ). Bet vispirms dod mozaīkas izkārtojumam īstu iespēju — tā ir visas lietas sirds. [Navigācija](04-navigation.md) tevi caur to izvedīs.

Darbvietas šķitīs pazīstamas: tās ir macOS Spaces vai Windows virtuālās darbvirsmas, tikai tu tās patiešām izmantosi, jo `Super + 1/2/3/4` uzreiz pārlec uz kādu no tām, bet `Super + Shift + 1/2/3/4` nosūta aktīvo logu turp. Nekādas animācijas aiztures, tikai tūlītēji lēcieni. Tas nozīmē, ka tev varbūt pat nevajadzēs vairākus monitorus, ja pie tā biji pieradis agrāk.

### Kopēšana un ielīmēšana vienkārši strādā

Mac datorā tev visur bija Cmd + C. Windows datorā tev visur bija Ctrl + C — izņemot termināli, kur tas nogalina tavu programmu. Omarchy tev dod `Super + C`, `Super + X` un `Super + V`, un tie strādā visur, arī terminālī. Nekāda atsevišķa refleksa, kas jāiemācās čaulai.

Windows ļaudis: jūsu Win + V starpliktuves vēsture dzīvo uz `Super + Ctrl + V`, un tā glabā arī attēlus, ne tikai tekstu. Skati [vienotā starpliktuve un vēsture](08-unified-clipboard-history.md).

### Tulkošanas tabula

| Tu ķeries pie | Omarchy vidē |
| ------------- | ---------- |
| Spotlight / Raycast / Start izvēlne | `Super + Space` — Omarchy izvēlne |
| AirDrop | LocalSend, ar `Super + Ctrl + S` — skati [GUI](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` vai `Print Screen` — skati [ekrānuzņēmumi un ierakstīšana](12-screenshots-recording.md) |
| Notification Center | Paziņojumu vēsture ar `Super + Shift + Alt + ,` |
| Time Machine (sistēmai) | Automātiski [sistēmas momentuzņēmumi](47-system-snapshots.md) pie katra atjauninājuma |
| App Store / instalētāja lejupielādēšana | _Install_ izvēlnē vai `omarchy pkg add` — skati [citas pakotnes](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ izvēlnē, kas rediģē vienkāršus konfigurācijas failus — skati [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, ar `Super + Shift + F` — skati [GUI](22-guis.md) |
| Safari / Edge | Google Chrome ar `Super + Shift + Return`; izvēlies citu sadaļā _Setup > Defaults > Browser_ — skati [pārlūki](23-browsers.md) |
| Preview / Photos | Omaview attēliem, video un mūzikai, Document Viewer PDF failiem — skati [GUI](22-guis.md) |
| TextEdit / Notepad | Plain, ar `Super + Shift + N`; izvēlies citu sadaļā _Setup > Defaults > Editor_ |

### Dažas lietas patiešām ir citādas

Daudzi iestatījumi dzīvo teksta failos, kurus tu rediģē, nevis paneļos, kuros tu klikšķini. Tas izklausās primitīvi, līdz saproti, ka tas nozīmē: katru pielāgojumu var redzēt, nokopēt uz nākamo datoru un ievietot versiju vadībā. _Setup_ izvēlne tevi iemet tieši pareizajā failā un restartē visu, kas jārestartē, kad esi pabeidzis.

Atjauninājumi nāk caur vienu komandu — _Update > Omarchy_ — kas atjaunina pašu Omarchy un katru sistēmas pakotni, pirms tam izveidojot momentuzņēmumu. Nekādu atsevišķu lietotņu atjauninātāju, kas tevi traucē nejaušos brīžos. Skati [atjauninājumus](30-updates.md).

Programmatūra nāk no pakotņu pārvaldnieka, nevis no lejupielādētiem instalētājiem.

Un, kad tu aizver logu, lietotne patiešām aizveras. Nav tā macOS starpstāvokļa, kur programma turpina darboties bez logiem. `Super + W` — vai `Super + Q`, ja tā ir pirkstu atmiņa, ar kuru ieradies — nozīmē: prom.

### Uz Mac aparatūras

Omarchy labi darbojas Intel Mac datoros un M1, M2 un M3 Mac datoros ar Omarchy for Apple Silicon. Skati [Mac atbalstu](44-mac-support.md). Un klaviatūra pret tevi ir laipna: Omarchy neko nepārpiešķir, un Linux uztver Command taustiņu kā Super, tāpēc Super atrodas tieši tur, kur vienmēr bija Cmd. Tavs īkšķis pārcelšanos nemanīs.

### Dod tam divas nedēļas

Instinkti pārnesas ātrāk, nekā domā. Vienreiz pārskati [īsinājumtaustiņu](07-hotkeys.md) nodaļu, un ikreiz, kad aizmirsti kādu piesaisti, nospied `Super + K` — tas tev parāda tās visas. Tas ir vienīgais īsinājumtaustiņš, kas tev patiešām jāiegaumē.
