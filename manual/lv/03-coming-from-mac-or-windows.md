# Ja pārejat no Mac vai Windows

Ja esat pavadījis gadus pie macOS vai Windows, jūsu pirksti zina simt lietu, ko jūsu smadzenes jau ir aizmirsušas, ka vispār ir iemācījušās. Šī nodaļa ir tulkošanas slānis: kur šie instinkti nonāk Omarchy vidē. Pašas funkcijas ir sīki aprakstītas citur — šī ir tikai karte.

### Super ir visa centrā

Visa muskuļu atmiņa, ko esat izveidojis ap Cmd vai Windows taustiņu, pāriet uz vienu taustiņu: Super. Tas ir Windows taustiņš uz PC tastatūras, un tas ir enkurs gandrīz katram karstajam taustiņam Omarchy vidē.

Jūsu Spotlight, Raycast vai Start izvēlnes reflekss kļūst par `Super + Space`. Tas atver Omarchy izvēlni, kas palaiž lietotnes, maina iestatījumus, instalē programmatūru, tver ekrānu — gandrīz visu. Sāciet rakstīt, lai filtrētu. `Super + Alt + Space` parāda visas lietotnes vienā režģī, tāpat kā Launchpad. Skatiet [navigāciju](04-navigation.md).

### Nav darbvirsmas ikonu, un doks parādās tikai peldošajā režīmā

Nav ikonu, ko kārtot uz darbvirsmas, un nav doka mozaīkas darbvietā — doks parādās tikai peldošajā darbvietā (skatiet [navigāciju](04-navigation.md)). Lietotnes palaiž ar karsto taustiņu (`Super + Return` terminālim, `Super + Shift + Return` pārlūkam un `Super + K` sarakstam ar visu, kas ir piesaistīts) vai no izvēlnes. Vienīgais pastāvīgais lietotāja saskarnes elements ir [augšējā josla](05-the-top-bar.md), kas aptver to, ko agrāk jūsu labā darīja izvēļņu josla, sistēmas tekne un Notification Center — un gandrīz katrs tās logrīks kaut ko dara ar kreiso, labo un vidējo klikšķi.

### Logi novietojas paši

Lielākā domāšanas maiņa: jūs nevelkat logus apkārt un nepievienojat tos ekrāna pusēm. Atverat logu, un tas aizņem visu ekrānu. Atverat otru, un tie to sadala. Jums nekad nav jāizvelk logs no otra apakšas, jo logi nepārklājas.

Kad jums patiešām vajag peldošu logu, `Super + T` pārslēdz aktīvo logu ārā no mozaīkas (un atpakaļ). Bet vispirms dodiet mozaīkai īstu iespēju — tā ir visas lietas sirds. [Navigācija](04-navigation.md) jūs caur to izvedīs.

Darbvietas šķitīs pazīstamas: tās ir macOS Spaces vai Windows virtuālās darbvirsmas, tikai jūs tās patiešām izmantosiet, jo `Super + 1/2/3/4` uzreiz pārlec uz kādu no tām un `Super + Shift + 1/2/3/4` turp nosūta aktīvo logu. Nekādas animācijas aizkaves, tikai tūlītēji lēcieni. Tas nozīmē, ka jums, iespējams, pat nevajadzēs vairākus monitorus, ja agrāk bijāt pie tā pieradis.

### Kopēšana un ielīmēšana vienkārši darbojas

Uz Mac jums visur bija Cmd + C. Uz Windows jums visur bija Ctrl + C — izņemot termināli, kur tas nogalina jūsu programmu. Omarchy jums dod `Super + C`, `Super + X` un `Super + V`, un tie darbojas visur, arī terminālī. Nekāda atsevišķa refleksa čaulai nav jāmācās.

Windows ļaudis: jūsu Win + V starpliktuves vēsture dzīvo uz `Super + Ctrl + V`, un tā glabā gan attēlus, gan tekstu. Skatiet [vienoto starpliktuvi un vēsturi](08-unified-clipboard-history.md).

### Tulkošanas tabula

| Jūs meklējat | Omarchy vidē |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy izvēlne |
| AirDrop | LocalSend, ar `Super + Ctrl + S` — skatiet [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` vai `Print Screen` — skatiet [ekrānuzņēmumus un ierakstīšanu](12-screenshots-recording.md) |
| Notification Center | Paziņojumu vēsture uz `Super + Shift + Alt + ,` |
| Time Machine (sistēmai) | Automātiski [sistēmas momentuzņēmumi](47-system-snapshots.md) pie katra atjauninājuma |
| App Store / instalētāja lejupielāde | _Install_ izvēlnē vai `omarchy pkg add` — skatiet [citas pakotnes](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ izvēlnē, kas rediģē vienkāršus konfigurācijas failus — skatiet [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, uz `Super + Shift + F` — skatiet [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome uz `Super + Shift + Return`; citu izvēlieties sadaļā _Setup > Defaults > Browser_ — skatiet [pārlūkus](23-browsers.md) |
| Preview / Photos | Omaview attēliem, video un mūzikai, Document Viewer PDF failiem — skatiet [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, uz `Super + Shift + N`; citu izvēlieties sadaļā _Setup > Defaults > Editor_ |

### Dažas lietas patiešām ir citādas

Daudzi iestatījumi dzīvo teksta failos, ko jūs rediģējat, nevis paneļos, kuros klikšķināt. Tas izklausās primitīvi, līdz saprotat, ka tas nozīmē, ka katru pielāgojumu var redzēt, nokopēt uz nākamo datoru un likt versiju kontrolē. _Setup_ izvēlne jūs iemet tieši pareizajā failā un, kad esat pabeidzis, restartē visu, kam jārestartējas.

Atjauninājumi nāk caur vienu komandu — _Update > Omarchy_ —, kas atjaunina pašu Omarchy un katru sistēmas pakotni, vispirms izveidojot momentuzņēmumu. Nekādu atsevišķu lietotņu atjauninātāju, kas kaitina jūs nejaušos brīžos. Skatiet [atjauninājumus](30-updates.md).

Programmatūra nāk no pakotņu pārvaldnieka, nevis no lejupielādētiem instalētājiem.

Un, kad aizverat logu, lietotne patiešām beidz darbu. Nav nekādas macOS limbo, kur programma turpina darboties bez logiem. `Super + W` — vai `Super + Q`, ja tieši ar tādu pirkstu atmiņu jūs ieradāties — nozīmē: prom.

### Uz Mac aparatūras

Omarchy labi darbojas uz Intel Mac datoriem — skatiet [Mac atbalstu](44-mac-support.md). Un tastatūra ir jums laipna: Omarchy neko nepārkartē, un Linux Command taustiņu uzskata par Super, tāpēc Super atrodas tieši tur, kur vienmēr bija Cmd. Jūsu īkšķis pārcelšanos nemanīs.

### Dodiet tam divas nedēļas

Instinkti pārnesas ātrāk, nekā domājat. Vienreiz pārskriet pāri [karsto taustiņu](07-hotkeys.md) nodaļai, un ikreiz, kad aizmirstat kādu piesaisti, spiediet `Super + K` — tas jums parāda tās visas. Tas ir vienīgais karstais taustiņš, kas jums patiešām jāiemācās no galvas.
