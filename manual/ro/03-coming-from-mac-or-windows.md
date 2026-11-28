# Dacă vii de pe Mac sau Windows

Dacă ai petrecut ani de zile pe macOS sau Windows, degetele tale știu o sută de lucruri pe care creierul tău a uitat că le-a învățat vreodată. Acest capitol este stratul de traducere: unde ajung acele instincte în Omarchy. Funcțiile în sine sunt tratate în profunzime în altă parte — aici este doar harta.

### Super este centrul a tot

Toată memoria musculară pe care ți-ai format-o în jurul lui Cmd sau al tastei Windows se transferă la o singură tastă: Super. Aceasta este tasta Windows de pe o tastatură PC și este ancora pentru aproape fiecare combinație de taste din Omarchy.

Reflexul tău pentru Spotlight, Raycast sau meniul Start devine `Super + Space`. Acesta deschide meniul Omarchy, care lansează aplicații, modifică setări, instalează software, capturează ecranul — cam tot. Începe să tastezi ca să filtrezi. `Super + Alt + Space` arată fiecare aplicație pe o singură grilă, așa cum face Launchpad. Vezi [navigare](04-navigation.md).

### Fără pictograme pe desktop, iar dock-ul stă deoparte

Fără pictograme de aranjat pe desktop, iar dock-ul se ascunde odată ce un spațiu de lucru are o fereastră, până când împingi cursorul spre marginea lui a ecranului, cea de jos dacă nu îl muți (vezi [navigare](04-navigation.md)). Aplicațiile pornesc dintr-o combinație de taste (`Super + Return` pentru terminal, `Super + Shift + Return` pentru browser și `Super + K` pentru o listă cu tot ce este mapat) sau din meniu. Singurul element de interfață persistent este [bara de sus](05-the-top-bar.md), care acoperă ceea ce făceau pentru tine înainte bara de meniu, zona de notificare a sistemului și Notification Center — și aproape fiecare widget de pe ea face ceva la clic stânga, dreapta și mijloc.

### Ferestrele se așază singure

Cea mai mare schimbare de mentalitate: nu tragi ferestrele de colo-colo și nu le lipești de jumătăți de ecran. Deschizi o fereastră și ocupă tot ecranul. Deschizi a doua și îl împart. Nu pescuiești niciodată o fereastră de sub alta, pentru că ferestrele nu se suprapun.

Când ai cu adevărat nevoie de o fereastră plutitoare, `Super + T` o scoate pe cea activă din dispunerea în mozaic (și o aduce înapoi). Dar mai întâi dă-i dispunerii în mozaic o șansă reală — este inima întregului lucru. [Navigarea](04-navigation.md) te ghidează prin ea.

Spațiile de lucru ți se vor părea familiare: sunt Spaces din macOS sau desktopurile virtuale din Windows, doar că le vei folosi cu adevărat, pentru că `Super + 1/2/3/4` sare direct la unul, iar `Super + Shift + 1/2/3/4` trimite acolo fereastra activă. Fără întârziere de animație, doar salturi instantanee. Asta înseamnă că s-ar putea să nu mai ai nevoie nici măcar de mai multe monitoare, dacă erai obișnuit cu asta înainte.

### Copierea și lipirea pur și simplu funcționează

Pe Mac aveai Cmd + C peste tot. Pe Windows aveai Ctrl + C peste tot — cu excepția terminalului, unde îți omoară programul. Omarchy îți dă `Super + C`, `Super + X` și `Super + V`, și funcționează peste tot, inclusiv în terminal. Niciun reflex separat de învățat pentru shell.

Pentru cei de pe Windows: istoricul clipboard-ului tău de la Win + V se află pe `Super + Ctrl + V` și păstrează imagini, precum și text. Vezi [clipboard unificat și istoric](08-unified-clipboard-history.md).

### Tabelul de traducere

| Cauți | În Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / meniul Start | `Super + Space` — meniul Omarchy |
| AirDrop | LocalSend, prin `Super + Ctrl + S` — vezi [GUIs](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` sau `Print Screen` — vezi [capturi de ecran și înregistrare](12-screenshots-recording.md) |
| Notification Center | Istoricul notificărilor pe `Super + Shift + Alt + ,` |
| Time Machine (pentru sistem) | [Instantanee de sistem](47-system-snapshots.md) automate la fiecare actualizare |
| App Store / descărcarea unui program de instalare | _Install_ în meniu sau `omarchy pkg add` — vezi [alte pachete](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ în meniu, care editează fișiere simple de configurare — vezi [dotfiles](31-dotfiles.md) |
| Finder / File Explorer | Files, pe `Super + Shift + F` — vezi [GUIs](22-guis.md) |
| Safari / Edge | Google Chrome pe `Super + Shift + Return`; alege altul la _Setup > Defaults > Browser_ — vezi [browsere](23-browsers.md) |
| Preview / Photos | Omaview pentru imagini, video și muzică, Document Viewer pentru PDF-uri — vezi [GUIs](22-guis.md) |
| TextEdit / Notepad | Plain, pe `Super + Shift + N`; alege altul la _Setup > Defaults > Editor_ |

### Unele lucruri chiar sunt diferite

Multe setări trăiesc în fișiere text pe care le editezi, nu în panouri prin care dai clic. Sună primitiv până când îți dai seama că înseamnă că fiecare ajustare poate fi văzută, copiată pe următoarea ta mașină și pusă sub control al versiunilor. Meniul _Setup_ te lasă direct în fișierul potrivit și repornește tot ce trebuie repornit când ai terminat.

Actualizările vin printr-o singură comandă — _Update > Omarchy_ — care actualizează Omarchy însuși și fiecare pachet de pe sistem, făcând mai întâi un instantaneu. Fără actualizatoare separate pentru fiecare aplicație care să te bată la cap la întâmplare. Vezi [actualizări](30-updates.md).

Software-ul vine dintr-un manager de pachete, nu din programe de instalare descărcate.

Și când închizi o fereastră, aplicația chiar se închide. Nu există limbo-ul din macOS în care programul continuă să ruleze fără nicio fereastră. `Super + W` — sau `Super + Q`, dacă aceasta este memoria degetelor cu care ai venit — înseamnă dispărut.

### Pe hardware Mac

Omarchy rulează bine pe Mac-urile Intel și pe Mac-urile M1, M2 și M3 cu Omarchy for Apple Silicon. Vezi [suport Mac](44-mac-support.md). Iar tastatura este blândă cu tine: Omarchy nu remapează nimic, iar Linux tratează tasta Command drept Super, așa că Super stă exact acolo unde a fost întotdeauna Cmd. Degetul tău mare nu va observa mutarea.

### Dă-i două săptămâni

Instinctele se transferă mai repede decât ai crede. Răsfoiește o dată capitolul [combinații de taste](07-hotkeys.md), iar ori de câte ori uiți o mapare, apasă `Super + K` — ți le arată pe toate. Aceasta este singura combinație de taste pe care trebuie cu adevărat să o memorezi.
