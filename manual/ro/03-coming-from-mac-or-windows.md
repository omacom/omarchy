# Vii de pe Mac sau Windows

Dacă ai petrecut ani întregi pe macOS sau Windows, degetele tale știu o sută de lucruri pe care creierul tău a uitat că le-a învățat vreodată. Acest capitol este stratul de traducere: unde se duc instinctele acelea în Omarchy. Funcțiile în sine sunt tratate în profunzime în altă parte — aceasta este doar harta.

### Super este centrul a tot

Toată memoria musculară pe care ți-ai format-o în jurul lui Cmd sau al tastei Windows se transferă pe o singură tastă: Super. Aceasta este tasta Windows de pe o tastatură de PC și este ancora pentru aproape fiecare comandă rapidă din Omarchy.

Reflexul tău de Spotlight sau Raycast sau de meniu Start devine `Super + Space`. Asta deschide meniul Omarchy, care lansează aplicații, schimbă setări, instalează software, capturează ecranul — cam tot. Începe să tastezi ca să filtrezi. `Super + Alt + Space` arată fiecare aplicație pe o singură grilă, așa cum face Launchpad. Vezi [navigare](04-navigation.md).

### Fără pictograme pe desktop, iar dockul apare doar când plutești

Fără pictograme de aranjat pe desktop și fără dock pe un spațiu de lucru în mozaic — dockul apare doar pe un spațiu de lucru plutitor (vezi [navigare](04-navigation.md)). Aplicațiile pornesc dintr-o comandă rapidă (`Super + Return` pentru terminal, `Super + Shift + Return` pentru browser și `Super + K` pentru o listă cu tot ce este mapat) sau din meniu. Singurul element persistent de interfață este [bara de sus](05-the-top-bar.md), care acoperă ce făceau înainte pentru tine bara de meniu, tava de sistem și Notification Center — și aproape fiecare widget de pe ea face ceva la clic stânga, dreapta și mijloc.

### Ferestrele se așază singure

Cea mai mare schimbare de mentalitate: nu tragi ferestrele de colo-colo și nu le fixezi pe jumătăți de ecran. Deschizi o fereastră și ocupă tot ecranul. Deschizi a doua și îl împart. Nu scoți niciodată o fereastră de sub alta, pentru că ferestrele nu se suprapun.

Când chiar ai nevoie de o fereastră plutitoare, `Super + T` o scoate pe cea activă din aranjarea în mozaic (și o aduce înapoi). Dar dă-i mai întâi aranjării în mozaic o șansă reală — este inima întregului lucru. [Navigare](04-navigation.md) te ghidează prin ea.

Spațiile de lucru ți se vor părea familiare: sunt Spaces din macOS sau desktopuri virtuale din Windows, doar că le vei folosi cu adevărat, pentru că `Super + 1/2/3/4` sare direct la unul, iar `Super + Shift + 1/2/3/4` trimite acolo fereastra activă. Fără întârziere de animație, doar salturi instantanee. Asta înseamnă că s-ar putea să nici nu ai nevoie de mai multe monitoare, dacă erai obișnuit cu asta înainte.

### Copierea și lipirea pur și simplu funcționează

Pe Mac aveai Cmd + C peste tot. Pe Windows aveai Ctrl + C peste tot — cu excepția terminalului, unde îți omoară programul. Omarchy îți dă `Super + C`, `Super + X` și `Super + V` și funcționează peste tot, inclusiv în terminal. Fără reflex separat de învățat pentru shell.

Utilizatori de Windows: istoricul clipboardului tău de pe Win + V trăiește pe `Super + Ctrl + V` și păstrează imagini, nu doar text. Vezi [clipboard unificat și istoric](08-unified-clipboard-history.md).

### Tabelul de traducere

| Cauți | În Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / meniul Start | `Super + Space` — meniul Omarchy |
| AirDrop | LocalSend, prin `Super + Ctrl + S` — vezi [GUI-uri](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` sau `Print Screen` — vezi [capturi de ecran și înregistrare](12-screenshots-recording.md) |
| Notification Center | Istoricul notificărilor pe `Super + Shift + Alt + ,` |
| Time Machine (pentru sistem) | [Instantanee de sistem](47-system-snapshots.md) automate la fiecare actualizare |
| App Store / descărcarea unui program de instalare | _Install_ în meniu sau `omarchy pkg add` — vezi [alte pachete](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ în meniu, care editează fișiere de configurare simple — vezi [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, pe `Super + Shift + F` — vezi [GUI-uri](22-guis.md) |
| Safari / Edge | Google Chrome pe `Super + Shift + Return`; alege altul sub _Setup > Defaults > Browser_ — vezi [browsere](23-browsers.md) |
| Preview / Photos | Omaview pentru imagini, video și muzică, Document Viewer pentru PDF-uri — vezi [GUI-uri](22-guis.md) |
| TextEdit / Notepad | Plain, pe `Super + Shift + N`; alege altul sub _Setup > Defaults > Editor_ |

### Unele lucruri chiar sunt diferite

Multe setări trăiesc în fișiere text pe care le editezi, nu în panouri prin care dai clic. Sună primitiv până îți dai seama că înseamnă că fiecare ajustare poate fi văzută, copiată pe următoarea ta mașină și pusă sub control al versiunilor. Meniul _Setup_ te lasă direct în fișierul potrivit și repornește tot ce trebuie repornit când ai terminat.

Actualizările vin printr-o singură comandă — _Update > Omarchy_ — care actualizează Omarchy însuși și fiecare pachet de pe sistem, făcând mai întâi o instantanee. Fără programe de actualizare pentru fiecare aplicație care să te sâcâie la întâmplare. Vezi [actualizări](30-updates.md).

Software-ul vine de la un manager de pachete, nu din programe de instalare descărcate.

Iar când închizi o fereastră, aplicația chiar se închide. Nu există limbo-ul macOS în care programul continuă să ruleze fără ferestre. `Super + W` — sau `Super + Q`, dacă asta este memoria degetelor cu care ai venit — înseamnă dispărută.

### Pe hardware Mac

Omarchy rulează bine pe Mac-uri Intel și pe Mac-uri M1, M2 și M3 cu Omarchy for Apple Silicon. Vezi [suport Mac](44-mac-support.md). Iar tastatura este blândă cu tine: Omarchy nu remapează nimic, iar Linux tratează tasta Command ca Super, așa că Super stă exact unde a fost mereu Cmd. Degetul tău mare nu va observa mutarea.

### Dă-i două săptămâni

Instinctele se transferă mai repede decât ai crede. Parcurge o dată capitolul [comenzi rapide](07-hotkeys.md), iar ori de câte ori ai un lapsus privind o combinație, apasă `Super + K` — ți le arată pe toate. Aceasta este singura comandă rapidă pe care chiar trebuie să o memorezi.
