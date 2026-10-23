# Ja nāc no Mac vai Windows

Ja esi pavadījis gadus macOS vai Windows, tavi pirksti zina simt lietu, ko tavas smadzenes ir aizmirsušas, ka tās kādreiz ir iemācījušās. Šī nodaļa ir tulkošanas slānis: kur šie instinkti nonāk Omarchy. Pašas funkcijas ir padziļināti apskatītas citur — šī ir tikai karte.

### Super ir visa centrs

Visa muskuļu atmiņa, ko esi izveidojis ap Cmd vai Windows taustiņu, pāriet uz vienu taustiņu: Super. Tas ir Windows taustiņš datora tastatūrā, un tas ir enkurs gandrīz katrai karstajai taustiņa kombinācijai Omarchy.

Tavs Spotlight, Raycast vai izvēlnes Start reflekss kļūst par `Super + Space`. Tas atver Omarchy izvēlni, kas palaiž lietotnes, maina iestatījumus, instalē programmatūru, uzņem ekrānu — gandrīz visu. Sāc rakstīt, lai filtrētu. `Super + Alt + Space` rāda visas lietotnes vienā režģī, kā to dara Launchpad. Skat. [navigācija](04-navigation.md).

### Nav ne doka, ne darbvirsmas ikonu

Nav nekā, uz kā noklikšķināt, lai palaistu lietas, nav ikonu, ko sakārtot uz darbvirsmas. Lietotnes startē no karstās taustiņa kombinācijas (`Super + Return` terminālim, `Super + Shift + Return` pārlūkam un `Super + K` sarakstam ar visu, kas ir piesaistīts) vai no izvēlnes. Vienīgā pastāvīgā UI daļa ir [augšējā josla](05-the-top-bar.md), kas aptver to, ko izvēlņu josla, sistēmas tekne un paziņojumu centrs tev darīja iepriekš — un gandrīz katrs logrīks tajā kaut ko dara ar kreiso, labo un vidējo klikšķi.

### Logi novietojas paši

Lielākā domāšanas maiņa: tu nevelc logus apkārt un nepiesaisti tos ekrāna pusēm. Atver logu, un tas aizņem visu ekrānu. Atver otru, un tie to sadala. Tu nekad nezvejo logu no cita apakšas, jo logi nepārklājas.

Kad tev patiešām vajag peldošu logu, `Super + T` pārslēdz aktīvo logu ārā no mozaīkas (un atpakaļ). Bet vispirms dod mozaīkai reālu iespēju — tā ir visa būtība. [Navigācija](04-navigation.md) izved tevi cauri tam.

Darbvietas šķitīs pazīstamas: tās ir macOS Spaces vai Windows virtuālās darbvirsmas, tikai tu tās patiešām lietosi, jo `Super + 1/2/3/4` lec tieši uz vienu, un `Super + Shift + 1/2/3/4` nosūta aktīvo logu turp. Nekādas animācijas kavēšanās, tikai tūlītēji lēcieni. Tas nozīmē, ka tev varbūt pat nevajadzēs vairākus monitorus, ja tu biji pieradis pie tā iepriekš.

### Kopēšana un ielīmēšana vienkārši darbojas

Mac tev visur bija Cmd + C. Windows tev visur bija Ctrl + C — izņemot termināli, kur tas nogalina tavu programmu. Omarchy dod tev `Super + C`, `Super + X` un `Super + V`, un tie darbojas visur, tostarp terminālī. Nav atsevišķa refleksa, kas jāiemācās čaulai.

Windows cilvēki: jūsu Win + V starpliktuves vēsture dzīvo uz `Super + Ctrl + V`, un tā glabā attēlus, kā arī tekstu. Skat. [vienotā starpliktuve un vēsture](08-unified-clipboard-history.md).

### Tulkošanas tabula

| Tu sniedzies pēc | Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start izvēlne | `Super + Space` — Omarchy izvēlne |
| AirDrop | LocalSend, izmantojot `Super + Ctrl + S` — skat. [GUI](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — skat. [ekrānuzņēmumi un ierakstīšana](12-screenshots-recording.md) |
| Paziņojumu centrs | Paziņojumu vēsture uz `Super + Shift + Alt + ,` |
| Time Machine (sistēmai) | Automātiski [sistēmas momentuzņēmumi](47-system-snapshots.md) pie katra atjauninājuma |
| App Store / instalētāja lejupielāde | _Instalēt_ izvēlnē vai `omarchy pkg add` — skat. [citas pakotnes](29-other-packages.md) |
| Sistēmas iestatījumi / Vadības panelis | _Iestatīšana_ izvēlnē, kas rediģē vienkāršus konfigurācijas failus — skat. [dotfaili](31-dotfiles.md) |

### Dažas lietas patiešām ir citādākas

Daudz iestatījumu dzīvo teksta failos, ko tu rediģē, nevis paneļos, cauri kuriem tu klikšķini. Tas izklausās primitīvi, līdz tu saproti, ka tas nozīmē, ka katru pielāgojumu var redzēt, nokopēt uz nākamo iekārtu un ievietot versiju kontrolē. Izvēlne _Iestatīšana_ ieved tevi tieši pareizajā failā un restartē visu, kas jārestartē, kad esi pabeidzis.

Atjauninājumi nāk ar vienu komandu — _Atjaunināt > Omarchy_ —, kas atjaunina pašu Omarchy un katru pakotni sistēmā, vispirms izveidojot momentuzņēmumu. Nekādi katras lietotnes atjauninātāji, kas kaitina tevi nejauši. Skat. [atjauninājumi](30-updates.md).

Programmatūra nāk no pakotņu pārvaldnieka, nevis no lejupielādētiem instalētājiem.

Un, kad tu aizver logu, lietotne patiešām aizveras. Nav macOS starpstāvokļa, kur programma turpina darboties bez logiem. `Super + W` — vai `Super + Q`, ja tā ir pirkstu atmiņa, ar kuru tu ieradies — nozīmē, ka tās vairs nav.

### Uz Mac aparatūras

Omarchy labi darbojas Intel Mac datoros — skat. [Mac atbalsts](44-mac-support.md). Un tastatūra pret tevi ir laipna: Omarchy neko nepārsaista, un Linux Command taustiņu uztver kā Super, tāpēc Super sēž tieši tur, kur Cmd vienmēr bija. Tavs īkšķis pāreju nepamanīs.

### Dod tam divas nedēļas

Instinkti pāriet ātrāk, nekā tu domā. Vienu reizi pārskati nodaļu [karstie taustiņi](07-hotkeys.md), un, kad vien aizmirsti piesaisti, nospied `Super + K` — tas rāda tev tās visas. Tā ir vienīgā karstā taustiņa kombinācija, kas tev patiešām jāiegaumē.
