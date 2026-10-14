# Dacă vii de pe Mac sau Windows

Dacă ai petrecut ani pe macOS sau Windows, degetele tale știu o sută de lucruri pe care creierul tău a uitat că le-a învățat vreodată. Acest capitol este stratul de traducere: unde ajung acele instincte în Omarchy. Funcțiile în sine sunt tratate în profunzime în altă parte — aici e doar harta.

### Super este centrul tuturor lucrurilor

Toată memoria musculară pe care ai construit-o în jurul tastei Cmd sau al tastei Windows se transferă la o singură tastă: Super. Aceasta este tasta Windows pe o tastatură de PC și este ancora pentru aproape fiecare scurtătură din Omarchy.

Reflexul tău de Spotlight, Raycast sau meniu Start devine `Super + Space`. Aceasta deschide meniul Omarchy, care lansează aplicații, schimbă setări, instalează software, capturează ecranul — aproape orice. Începe să tastezi ca să filtrezi. `Super + Alt + Space` arată toate aplicațiile pe o grilă, așa cum face Launchpad. Vezi [navigarea](04-navigation.md).

### Nu există dock și nici pictograme pe desktop

Nimic pe care să faci clic ca să lansezi lucruri, nici pictograme de aranjat pe desktop. Aplicațiile pornesc dintr-o scurtătură (`Super + Return` pentru terminal, `Super + Shift + Return` pentru browser și `Super + K` pentru o listă cu tot ce este mapat) sau din meniu. Singura bucată persistentă de interfață este [bara de sus](05-the-top-bar.md), care acoperă ce făceau înainte pentru tine bara de meniu, tava de sistem și centrul de notificări — și aproape fiecare widget de pe ea face ceva la clic stânga, dreapta și mijlociu.

### Ferestrele se așază singure

Cea mai mare schimbare de mentalitate: nu tragi ferestrele de colo-colo și nu le prinzi de jumătățile ecranului. Deschizi o fereastră și ocupă tot ecranul. Deschizi o a doua și îl împart. Nu scoți niciodată o fereastră de sub alta, pentru că ferestrele nu se suprapun.

Când ai cu adevărat nevoie de o fereastră plutitoare, `Super + T` o scoate pe cea activă din mozaic (și o readuce). Dar dă-i mozaicului o șansă reală mai întâi — este inima întregului lucru. [Navigarea](04-navigation.md) te ghidează prin el.

Spațiile de lucru îți vor părea familiare: sunt Spaces din macOS sau desktopurile virtuale din Windows, numai că le vei folosi cu adevărat, pentru că `Super + 1/2/3/4` sare direct la unul, iar `Super + Shift + 1/2/3/4` trimite fereastra activă acolo. Fără întârziere de animație, doar salturi instantanee. Asta înseamnă că s-ar putea să nu mai ai nevoie nici măcar de mai multe monitoare, dacă așa te obișnuiseși înainte.

### Copierea și lipirea funcționează pur și simplu

Pe Mac aveai Cmd + C peste tot. Pe Windows aveai Ctrl + C peste tot — mai puțin în terminal, unde îți omoară programul. Omarchy îți dă `Super + C`, `Super + X` și `Super + V`, și funcționează peste tot, inclusiv în terminal. Fără un reflex separat de învățat pentru shell.

Cei de pe Windows: istoricul tău de clipboard de la Win + V trăiește pe `Super + Ctrl + V` și ține imagini, precum și text. Vezi [clipboardul unificat și istoricul](08-unified-clipboard-history.md).

### Tabelul de traducere

| După ce întinzi mâna | În Omarchy |
| ------------- | ---------- |
| Spotlight / Raycast / meniul Start | `Super + Space` — meniul Omarchy |
| AirDrop | LocalSend, prin `Super + Ctrl + S` — vezi [GUI-uri](22-guis.md) |
| Cmd + Shift + 4 / Win + Shift + S | `Print Screen` — vezi [capturile de ecran și înregistrarea](12-screenshots-recording.md) |
| Centrul de notificări | Istoricul notificărilor pe `Super + Shift + Alt + ,` |
| Time Machine (pentru sistem) | [Instantanee de sistem](47-system-snapshots.md) automate la fiecare actualizare |
| App Store / descărcarea unui program de instalare | _Instalează_ în meniu sau `omarchy pkg add` — vezi [alte pachete](29-other-packages.md) |
| Setările sistemului / Panoul de control | _Configurare_ în meniu, care editează fișiere de configurare simple — vezi [fișierele dot](31-dotfiles.md) |

### Unele lucruri chiar sunt diferite

Multe setări trăiesc în fișiere text pe care le editezi, nu în panouri prin care dai clic. Pare primitiv până când îți dai seama că înseamnă că fiecare modificare poate fi văzută, copiată pe mașina următoare și pusă sub controlul versiunilor. Meniul _Configurare_ te lasă direct în fișierul potrivit și repornește tot ce trebuie repornit când ai terminat.

Actualizările vin printr-o singură comandă — _Actualizează > Omarchy_ — care actualizează Omarchy în sine și fiecare pachet din sistem, făcând mai întâi un instantaneu. Fără programe de actualizare per aplicație care să te bată la cap întâmplător. Vezi [actualizările](30-updates.md).

Software-ul vine dintr-un manager de pachete, nu din programe de instalare descărcate.

Și când închizi o fereastră, aplicația chiar se închide. Nu există limbo-ul macOS în care programul continuă să ruleze fără ferestre. `Super + W` — sau `Super + Q`, dacă asta e memoria degetelor cu care ai sosit — înseamnă dispărut.

### Pe hardware Mac

Omarchy rulează bine pe Mac-uri cu Intel — vezi [suportul pentru Mac](44-mac-support.md). Și tastatura este blândă cu tine: Omarchy nu remapează nimic, iar Linux tratează tasta Command ca pe Super, așa că Super stă exact unde a fost întotdeauna Cmd. Degetul tău mare nu va observa mutarea.

### Dă-i două săptămâni

Instinctele se transferă mai repede decât crezi. Răsfoiește o dată capitolul despre [scurtături](07-hotkeys.md) și, de câte ori nu-ți mai amintești o mapare, apasă `Super + K` — ți le arată pe toate. Este singura scurtătură pe care chiar trebuie să o memorezi.
