# Ja pārnākat no Mac vai Windows

Ja esi pavadījis gadus macOS vai Windows vidē, tavi pirksti zina simtiem lietu, ko tavas smadzenes jau ir aizmirsušas, ka vispār iemācījušās. Šī nodaļa ir tulkošanas slānis: kur šie instinkti nonāk Omarchy. Pašas funkcijas ir padziļināti aprakstītas citur — šī ir tikai karte.

### Super ir visa centrs

Visa muskuļu atmiņa, ko esi izveidojis ap Cmd vai Windows taustiņu, pāriet uz vienu taustiņu: Super. Tas ir Windows taustiņš PC klaviatūrā, un tas ir enkurs gandrīz katram īsinājumtaustiņam Omarchy.

Tavs Spotlight, Raycast vai Start izvēlnes reflekss kļūst par `Super + Space`. Tas atver Omarchy izvēlni, kas palaiž lietotnes, maina iestatījumus, instalē programmatūru, tver ekrānu — gandrīz visu. Sāc rakstīt, lai filtrētu. `Super + Alt + Space` parāda visas lietotnes vienā režģī, tāpat kā Launchpad. Skaties [navigācija](04-navigation.md).

### Nav ne doka, ne darbvirsmas ikonu

Nav nekā, uz kā noklikšķināt, lai palaistu lietas, un nav ikonu, ko kārtot uz darbvirsmas. Lietotnes startē no īsinājumtaustiņa (`Super + Return` terminālim, `Super + Shift + Return` pārlūkam un `Super + K` visu piesaistīto saīšņu sarakstam) vai no izvēlnes. Vienīgais pastāvīgais saskarnes elements ir [augšējā josla](05-the-top-bar.md), kas aptver to, ko agrāk tev darīja izvēļņu josla, sistēmas tekne un Notification Center — un gandrīz katrs tās logrīks kaut ko dara ar kreiso, labo un vidējo klikšķi.

### Logi paši atrod savu vietu

Lielākā domāšanas maiņa: tu nevelc logus apkārt un nepieķer tos pie ekrāna pusēm. Atver logu, un tas aizņem visu ekrānu. Atver otru, un tie to sadala. Tev nekad nav jāvelk ārā logs no cita apakšas, jo logi nepārklājas.

Kad tev patiešām vajag peldošu logu, `Super + T` pārslēdz aktīvo logu ārā no mozaīkas izkārtojuma (un atpakaļ). Bet vispirms dod mozaīkas izkārtojumam īstu iespēju — tā ir visas sistēmas sirds. [Navigācija](04-navigation.md) tevi tam izved cauri.

Darba virsmas šķitīs pazīstamas: tās ir macOS Spaces vai Windows virtuālās darbvirsmas, tikai tu tās patiešām izmantosi, jo `Super + 1/2/3/4` uzreiz pāriet uz vienu, bet `Super + Shift + 1/2/3/4` turp nosūta aktīvo logu. Nekādas animācijas aizkaves, tikai tūlītēji lēcieni. Tas nozīmē, ka tev, iespējams, pat nevajadzēs vairākus monitorus, ja agrāk biji pie tā pieradis.

### Kopēšana un ielīmēšana vienkārši strādā

Mac datorā tev visur bija Cmd + C. Windows datorā tev visur bija Ctrl + C — izņemot termināli, kur tas nogalina tavu programmu. Omarchy tev dod `Super + C`, `Super + X` un `Super + V`, un tie strādā visur, ieskaitot termināli. Nekāda atsevišķa refleksa, kas jāapgūst čaulai.

Windows ļaudis: jūsu Win + V starpliktuves vēsture dzīvo uz `Super + Ctrl + V`, un tajā glabājas gan attēli, gan teksts. Skaties [vienotā starpliktuve un vēsture](08-unified-clipboard-history.md).

### Tulkošanas tabula

| Tu sniedzies pēc | Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start izvēlne | `Super + Space` — Omarchy izvēlne |
| AirDrop | LocalSend, ar `Super + Ctrl + S` — skaties [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` vai `Print Screen` — skaties [ekrānuzņēmumi un ierakstīšana](12-screenshots-recording.md) |
| Notification Center | Paziņojumu vēsture uz `Super + Shift + Alt + ,` |
| Time Machine (sistēmai) | Automātiski [sistēmas momentuzņēmumi](47-system-snapshots.md) katrā atjauninājumā |
| App Store / instalētāja lejupielāde | _Install_ izvēlnē vai `omarchy pkg add` — skaties [citas pakotnes](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ izvēlnē, kas rediģē vienkāršus konfigurācijas failus — skaties [dotfiles](31-dotfiles.md) |

### Dažas lietas patiešām ir citādas

Daudzi iestatījumi dzīvo teksta failos, kurus tu rediģē, nevis paneļos, kuros tu klikšķini. Tas izklausās primitīvi, līdz apjēdz, ka tas nozīmē, ka katru pielāgojumu var redzēt, nokopēt uz nākamo datoru un ievietot versiju kontrolē. _Setup_ izvēlne tevi iemet tieši pareizajā failā un, kad esi pabeidzis, pārstartē visu, kas jāpārstartē.

Atjauninājumi nāk caur vienu komandu — _Update > Omarchy_ —, kas atjaunina pašu Omarchy un katru sistēmas pakotni, pirms tam izveidojot momentuzņēmumu. Nekādu atsevišķu lietotņu atjauninātāju, kas baksta nejaušos brīžos. Skaties [atjauninājumi](30-updates.md).

Programmatūra nāk no pakotņu pārvaldnieka, nevis no lejupielādētiem instalētājiem.

Un, kad tu aizver logu, lietotne patiešām aizveras. Nav nekādas macOS starpstadijas, kur programma turpina darboties bez neviena loga. `Super + W` — vai `Super + Q`, ja tā ir pirkstu atmiņa, ar ko esi ieradies, — nozīmē: prom.

### Uz Mac aparatūras

Omarchy labi darbojas Intel Mac datoros — skaties [Mac atbalsts](44-mac-support.md). Un klaviatūra ir laipna pret tevi: Omarchy neko nepārkartē, un Linux Command taustiņu apstrādā kā Super, tāpēc Super atrodas tieši tur, kur Cmd vienmēr bija. Tavs īkšķis pārcelšanos nemanīs.

### Dod tam divas nedēļas

Instinkti pāriet ātrāk, nekā domā. Vienreiz izskrien cauri [īsinājumtaustiņi](07-hotkeys.md) nodaļai, un ikreiz, kad piemirsti kādu piesaisti, nospied `Super + K` — tas tev parāda visas. Tas ir vienīgais īsinājumtaustiņš, kas tev patiešām jāiemācās no galvas.
