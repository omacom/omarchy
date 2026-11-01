# Dacă vii de pe Mac sau Windows

Dacă ai petrecut ani pe macOS sau Windows, degetele tale știu o sută de lucruri pe care creierul tău a uitat că le-a învățat vreodată. Acest capitol este stratul de traducere: unde se duc acele instincte în Omarchy. Funcțiile în sine sunt tratate în profunzime în altă parte — aceasta este doar harta.

### Super este centrul a tot

Toată memoria musculară pe care ai construit-o în jurul Cmd sau al tastei Windows se transferă pe o singură tastă: Super. Aceasta este tasta Windows pe o tastatură PC și este ancora pentru aproape fiecare scurtătură din Omarchy.

Reflexul tău de Spotlight sau Raycast sau meniu Start devine `Super + Space`. Acesta deschide meniul Omarchy, care lansează aplicații, schimbă setări, instalează software, capturează ecranul — aproape orice. Începe să tastezi pentru a filtra. `Super + Alt + Space` afișează toate aplicațiile pe un singur grid, la fel ca Launchpad. Vezi [navigare](04-navigation.md).

### Nu există dock și nici pictograme pe desktop

Nimic pe care să dai clic pentru a lansa lucruri, nicio pictogramă de aranjat pe desktop. Aplicațiile pornesc dintr-o scurtătură (`Super + Return` pentru terminal, `Super + Shift + Return` pentru browser și `Super + K` pentru o listă cu tot ce este mapat) sau din meniu. Singurul element persistent de interfață este [bara de sus](05-the-top-bar.md), care acoperă tot ce făceau înainte pentru tine bara de meniu, zona de notificare a sistemului și Notification Center — și aproape fiecare widget de pe ea face ceva la clic stânga, dreapta și mijloc.

### Ferestrele se așază singure

Cea mai mare schimbare de mentalitate: nu tragi ferestrele de colo-colo și nu le lipești de jumătăți de ecran. Deschizi o fereastră și ocupă tot ecranul. Deschizi a doua și îl împart. Niciodată nu pescuiești o fereastră de sub alta, pentru că ferestrele nu se suprapun.

Când ai cu adevărat nevoie de o fereastră plutitoare, `Super + T` o scoate pe cea activă din tiling (și o aduce înapoi). Dar dă mai întâi o șansă reală tiling-ului — este inima întregului sistem. [Navigarea](04-navigation.md) te ghidează prin el.

Spațiile de lucru îți vor părea familiare: sunt Spaces din macOS sau desktopuri virtuale din Windows, doar că le vei folosi cu adevărat, pentru că `Super + 1/2/3/4` sare direct la unul și `Super + Shift + 1/2/3/4` trimite acolo fereastra activă. Fără întârziere de animație, doar salturi instant. Asta înseamnă că s-ar putea să nu mai ai nevoie nici de mai multe monitoare, dacă erai obișnuit cu asta înainte.

### Copierea și lipirea pur și simplu funcționează

Pe Mac aveai Cmd + C peste tot. Pe Windows aveai Ctrl + C peste tot — cu excepția terminalului, unde îți omoară programul. Omarchy îți dă `Super + C`, `Super + X` și `Super + V`, și funcționează peste tot, inclusiv în terminal. Niciun reflex separat de învățat pentru shell.

Utilizatori Windows: istoricul clipboard-ului de pe Win + V trăiește pe `Super + Ctrl + V` și păstrează imagini, nu doar text. Vezi [clipboard unificat și istoric](08-unified-clipboard-history.md).

### Tabelul de traducere

| Cauți instinctiv | În Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — meniul Omarchy |
| AirDrop | LocalSend, via `Super + Ctrl + S` — vezi [GUI-uri](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` sau `Print Screen` — vezi [capturi de ecran și înregistrare](12-screenshots-recording.md) |
| Notification Center | Istoricul notificărilor pe `Super + Shift + Alt + ,` |
| Time Machine (pentru sistem) | [Instantanee de sistem](47-system-snapshots.md) automate la fiecare actualizare |
| App Store / descărcarea unui program de instalare | _Install_ în meniu, sau `omarchy pkg add` — vezi [alte pachete](29-other-packages.md) |
| System Settings / Control Panel | _Setup_ în meniu, care editează fișiere simple de configurare — vezi [dotfiles](31-dotfiles.md) |

### Unele lucruri chiar sunt diferite

Multe setări trăiesc în fișiere text pe care le editezi, nu în panouri prin care dai clic. Sună primitiv până îți dai seama că înseamnă că fiecare ajustare poate fi văzută, copiată pe următoarea ta mașină și pusă sub control al versiunilor. Meniul _Setup_ te lasă direct în fișierul potrivit și repornește tot ce trebuie repornit când ai terminat.

Actualizările vin printr-o singură comandă — _Update > Omarchy_ — care actualizează Omarchy însuși și fiecare pachet de pe sistem, făcând mai întâi un snapshot. Fără programe de actualizare pentru fiecare aplicație care să te bată la cap la întâmplare. Vezi [actualizări](30-updates.md).

Software-ul vine dintr-un manager de pachete, nu din programe de instalare descărcate.

Și când închizi o fereastră, aplicația chiar se închide. Nu există limbo-ul din macOS în care programul continuă să ruleze fără ferestre. `Super + W` — sau `Super + Q`, dacă aceasta este memoria din degete cu care ai sosit — înseamnă că a dispărut.

### Pe hardware Mac

Omarchy rulează bine pe Mac-uri Intel — vezi [suport pentru Mac](44-mac-support.md). Și tastatura este prietenoasă cu tine: Omarchy nu remapează nimic, iar Linux tratează tasta Command ca Super, așa că Super stă exact unde a stat întotdeauna Cmd. Degetul mare nu va observa mutarea.

### Dă-i două săptămâni

Instinctele se transferă mai repede decât ai crede. Răsfoiește o dată capitolul despre [taste rapide](07-hotkeys.md), iar ori de câte ori nu-ți amintești o combinație, apasă `Super + K` — ți le arată pe toate. Aceasta este singura scurtătură pe care trebuie cu adevărat să o memorezi.
