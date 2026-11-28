# Dacă vii de pe Mac sau Windows

Dacă ai petrecut ani întregi pe macOS sau Windows, degetele tale știu o sută de lucruri pe care creierul tău a uitat că le-a învățat vreodată. Acest capitol este stratul de traducere: unde ajung instinctele alea în Omarchy. Funcționalitățile în sine sunt tratate în profunzime în altă parte — aceasta este doar harta.

### Super este centrul a tot

Toată memoria musculară pe care ai construit-o în jurul lui Cmd sau al tastei Windows se transferă pe o singură tastă: Super. Asta este tasta Windows pe o tastatură PC și este ancora pentru aproape fiecare scurtătură din Omarchy.

Reflexul tău de Spotlight sau Raycast sau meniu Start devine `Super + Space`. Asta deschide meniul Omarchy, care lansează aplicații, schimbă setări, instalează software, capturează ecranul — cam tot. Începe să tastezi ca să filtrezi. `Super + Alt + Space` afișează fiecare aplicație pe o singură grilă, așa cum face Launchpad. Vezi [navigare](04-navigation.md).

### Fără pictograme pe desktop, iar dock-ul stă deoparte

Fără pictograme de aranjat pe desktop, iar dock-ul se ascunde odată ce un spațiu de lucru are o fereastră, până când duci indicatorul la marginea ecranului unde se află, cea din dreapta dacă nu îl muți (vezi [navigare](04-navigation.md)). Aplicațiile pornesc dintr-o scurtătură (`Super + Return` pentru terminal, `Super + Shift + Return` pentru browser și `Super + K` pentru o listă cu tot ce este mapat) sau din meniu. Singurul element persistent de UI este [bara de sus](05-the-top-bar.md), care acoperă ce făceau pentru tine înainte bara de meniu, zona de notificări a sistemului și Notification Center — și aproape fiecare widget de pe ea face ceva la clic stânga, dreapta și mijloc.

### Ferestrele se așază singure

Cea mai mare schimbare de mentalitate: nu tragi ferestrele de colo-colo și nu le lipești de jumătăți de ecran. Deschizi o fereastră și ocupă tot ecranul. Deschizi a doua și îl împart. Nu pescuiești niciodată o fereastră de sub alta, pentru că ferestrele nu se suprapun.

Când ai nevoie cu adevărat de o fereastră plutitoare, `Super + T` o scoate pe cea activă din tiling (și o aduce înapoi). Dar dă-i mai întâi o șansă reală tiling-ului — este inima întregului lucru. [Navigarea](04-navigation.md) te ghidează prin asta.

Spațiile de lucru vor părea familiare: sunt Spaces din macOS sau desktopurile virtuale din Windows, doar că pe astea chiar le vei folosi, pentru că `Super + 1/2/3/4` sare direct la unul, iar `Super + Shift + 1/2/3/4` trimite fereastra activă acolo. Fără întârziere de animație, doar salturi instantanee. Asta înseamnă că s-ar putea să nici nu mai ai nevoie de mai multe monitoare, dacă erai obișnuit cu asta înainte.

### Copierea și lipirea pur și simplu funcționează

Pe Mac aveai Cmd + C peste tot. Pe Windows aveai Ctrl + C peste tot — mai puțin în terminal, unde îți omoară programul. Omarchy îți dă `Super + C`, `Super + X` și `Super + V`, și funcționează peste tot, inclusiv în terminal. Fără reflex separat de învățat pentru shell.

Pentru cei de pe Windows: istoricul clipboard-ului tău de pe Win + V trăiește pe `Super + Ctrl + V` și păstrează imagini la fel ca text. Vezi [clipboard unificat și istoric](08-unified-clipboard-history.md).

### Tabelul de traducere

| Ce cauți | În Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / meniu Start | `Super + Space` — meniul Omarchy |
| AirDrop | LocalSend, prin `Super + Ctrl + S` — vezi [GUI-uri](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` sau `Print Screen` — vezi [capturi de ecran și înregistrare](12-screenshots-recording.md) |
| Notification Center | Istoricul notificărilor pe `Super + Shift + Alt + ,` |
| Time Machine (pentru sistem) | [Instantanee de sistem](47-system-snapshots.md) automate la fiecare actualizare |
| App Store / descărcarea unui program de instalare | _Install_ în meniu sau `omarchy pkg add` — vezi [alte pachete](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ în meniu, care editează fișiere de configurare simple — vezi [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, pe `Super + Shift + F` — vezi [GUI-uri](22-guis.md) |
| Safari / Edge | Google Chrome pe `Super + Shift + Return`; alege altul la _Setup > Defaults > Browser_ — vezi [browsere](23-browsers.md) |
| Preview / Photos | Omaview pentru imagini, video și muzică, Document Viewer pentru PDF-uri — vezi [GUI-uri](22-guis.md) |
| TextEdit / Notepad | Plain, pe `Super + Shift + N`; alege altul la _Setup > Defaults > Editor_ |

### Unele lucruri chiar sunt diferite

Multe setări trăiesc în fișiere text pe care le editezi, nu în panouri prin care dai clic. Sună primitiv până îți dai seama că înseamnă că fiecare ajustare poate fi văzută, copiată pe următoarea ta mașină și pusă în controlul versiunilor. Meniul _Setup_ te lasă direct în fișierul potrivit și repornește ce trebuie repornit când ai terminat.

Actualizările vin printr-o singură comandă — _Update > Omarchy_ — care actualizează Omarchy însuși și fiecare pachet de pe sistem, făcând mai întâi un instantaneu. Fără actualizatoare separate pentru fiecare aplicație care să te bată la cap la întâmplare. Vezi [actualizări](30-updates.md).

Software-ul vine dintr-un manager de pachete, nu din programe de instalare descărcate.

Și când închizi o fereastră, aplicația chiar se închide. Nu există limbo-ul din macOS unde programul continuă să ruleze fără nicio fereastră. `Super + W` — sau `Super + Q`, dacă asta este memoria din degete cu care ai venit — înseamnă dispărut.

### Pe hardware Mac

Omarchy rulează bine pe Mac-uri Intel și pe Mac-uri M1, M2 și M3 cu Omarchy for Apple Silicon. Vezi [suport Mac](44-mac-support.md). Și tastatura este blândă cu tine: Omarchy nu remapează nimic, iar Linux tratează tasta Command drept Super, așa că Super stă exact unde a fost dintotdeauna Cmd. Degetul mare nu va observa mutarea.

### Dă-i două săptămâni

Instinctele se transferă mai repede decât ai crede. Parcurge o dată capitolul [scurtături](07-hotkeys.md), iar ori de câte ori uiți o asociere, apasă `Super + K` — ți le arată pe toate. Asta este singura scurtătură pe care trebuie chiar să o memorezi.
