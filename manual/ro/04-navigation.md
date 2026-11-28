# Navigare

Totul în Omarchy se întâmplă de la tastatură — _TOTUL!_ Când sistemul pornește pentru prima dată, efectiv nu poți face nimic doar cu mouse-ul. Dar poți apăsa `Super + Space` pentru a afișa meniul Omarchy și de aici poți face aproape totul.

Dar meniul Omarchy nici măcar nu este gândit să fie modul principal de operare a sistemului în cea mai mare parte a timpului. Putem fi mai rapizi de atât! Toate aplicațiile cele mai importante sunt legate direct de taste rapide individuale. Pornești terminalul cu `Super + Return` și un browser cu `Super + Shift + Return`. Încearcă să le faci una după alta și vei vedea magia tiling-ului din Hyprland în acțiune:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Apoi poți apăsa `Super + J` pentru a le stivui una peste alta în loc să stea una lângă alta:

 ![navigation-stacked](images/navigation-stacked.webp)

Apasă din nou `Super + J` pentru a le readuce în pozițiile una lângă alta. Apoi încearcă `Super + Shift + Arrow Right` cât timp ești în browser pentru a interschimba ferestrele.

Acum încearcă `Super + Shift + T` pentru a porni Activity monitor. Acesta va apărea ca o fereastră plutitoare, cu o bară de titlu de care o poți trage și butoane pentru a o minimiza, maximiza și închide. Fiecare fereastră plutitoare primește una, oriunde s-ar afla. O poți aranja în tiling cu `Super + T` (și apasă din nou pentru a o face iarăși plutitoare). Acum apasă `Super + Shift + F` pentru a deschide managerul de fișiere. Vei avea o configurație îngrijită în patru direcții:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navighezi între fereastra pe care vrei să o activezi cu `Super + Arrow`. Aceasta va schimba focalizarea și va muta cursorul în centrul noii aplicații. La marginea unui ecran, continuă spre monitorul de pe acea parte.

Dacă apeși `Super + Shift + 2`, vei muta aplicația focalizată în prezent pe al doilea spațiu de lucru. `Super + Shift + 1` o mută înapoi. (Iar `Super + Shift + Alt + 2` va muta aplicația focalizată în prezent pe al doilea spațiu de lucru fără să comute la el).

Cu mai mult de un monitor, fiecare monitor are propriile spații de lucru de la 1 la 10. `Super + 2` merge la al doilea spațiu de lucru al monitorului pe care te afli, iar bara de sus a fiecărui monitor își arată propriile spații de lucru și pe cel pe care îl afișează. `Super + Tab` trece pe rând prin spațiile de lucru de pe monitorul pe care te afli. `Super + Shift + Ctrl + Arrows` mută fereastra pe care te afli pe monitorul în acea direcție, pe spațiul de lucru pe care îl afișează acesta, iar `Super + Shift + Alt + Arrows` mută spațiul de lucru pe care te afli pe monitorul în acea direcție, unde preia același număr dacă este liber. Un monitor își păstrează spațiile de lucru când îl deconectezi: ele se alătură altui ecran, numerotate după cele pe care le are deja, și revin sub numerele lor vechi când monitorul se întoarce.

Dacă ții apăsat `Super` și folosești mouse-ul pentru a face clic pe o fereastră, vei putea rearanja unde stă. Dacă ții apăsat `Super` și folosești butonul din dreapta al mouse-ului, poți redimensiona liber fereastra.

Închizi o fereastră cu `Super + W` sau `Super + Q` (și închizi toate ferestrele cu `Ctrl + Alt + Delete`).

Poți trece și pe tot ecranul cu `Super + F` sau chiar doar pe toată lățimea (păstrând bara de sus) cu `Super + Alt + F` sau pe tot ecranul în interiorul unei ferestre cu `Super + Ctrl + F` (bun pentru YouTube!).

### Aspectul dwindle vs scrolling

Aspectul implicit din Omarchy se numește dwindle. Păstrează toate ferestrele pe care le deschizi pe un singur spațiu de lucru vizibile în permanență, chiar dacă trebuie să le micșoreze.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Dar poți alege și să transformi un spațiu de lucru în aspectul scrolling, în care ferestrele sunt aliniate una lângă alta, dincolo de marginea vizibilă a afișajului. Transformi un singur spațiu de lucru în acest aspect cu `Super + L`.

Apăsând din nou `Super + L` transformi spațiul de lucru în unul plutitor, în care ferestrele se suprapun liber și le așezi tu însuți, iar o a treia apăsare îl readuce la dwindle. `Super + Alt + L` trece prin ele în sens invers. O fereastră care oricum plutește — una pe care ai scos-o cu `Super + T` sau o aplicație care se deschide întotdeauna plutitoare — rămâne plutitoare când spațiul de lucru revine la tiling. Bara de sus marchează spațiul de lucru pe care te afli cu aspectul lui: un pătrat pentru dwindle, un cerc pentru scrolling și un triunghi pentru plutitor. Și clicul pe acel semn trece pe rând prin aspecte, la fel ca tasta de afișare de pe laptopurile care au una.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Alegerea este per spațiu de lucru și rămâne. Așa că poți păstra spațiul de lucru 1 pe dwindle pentru navigare și spațiul de lucru 2 pe scrolling pentru cod și vor reveni așa după o repornire.

Dacă dorești să folosești aspectul scrolling ca implicit, poți seta asta în `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Spații de lucru plutitoare

Un spațiu de lucru plutitor funcționează ca un desktop tradițional: ferestrele se suprapun, iar tu le muți și le dimensionezi singur. Fiecare fereastră primește o bară de titlu în culorile temei tale, cu butoane pentru minimizare, maximizare și închidere. `Super + M` minimizează și fereastra focalizată. O fereastră minimizată așteaptă în dock; fă clic pe aplicația ei pentru a o readuce. Fă clic pe o fereastră pentru a o aduce în față. Redimensioneaz-o de pe orice margine sau colț. Fă dublu clic pe o bară de titlu pentru a maximiza fereastra păstrând bara de sus vizibilă și din nou pentru a-i reda dimensiunea veche. Chrome și alte browsere bazate pe Chromium, Disks și Document Viewer sar peste bara de titlu și folosesc în schimb propriul lor antet; `Super + Alt + F` le maximizează, iar `Super + M` le minimizează.

Fiecare spațiu de lucru are un dock, cu aplicațiile tale fixate, tot ce rulează și o grilă cu fiecare aplicație în spatele butonului de aplicații, pe care `Super + Alt + Space` și _Apps_ din meniul Omarchy îl deschid de asemenea. Fă clic dreapta pe o aplicație din grilă sau apasă `Delete` pentru a o dezinstala. Fă clic pe o aplicație pentru a o deschide sau pentru a-i aduce fereastra în față; fă clic din nou pentru a trece pe rând prin ferestrele ei. Files readuce doar o fereastră din spațiul de lucru pe care te afli și în rest deschide una nouă, iar Terminal și Agent pornesc întotdeauna o alta, deși o fereastră minimizată revine prima. Clicul din mijloc deschide o fereastră nouă. Trage o pictogramă de-a lungul dock-ului pentru a o muta; trăgând o aplicație care rulează printre celelalte, o păstrezi acolo. Fă clic dreapta pentru a păstra o aplicație în dock, a o scoate sau a o închide. Dock-ul rămâne afișat cât timp un spațiu de lucru este gol, iar odată ce spațiul de lucru are o fereastră, se ascunde până când cursorul ajunge la marginea lui. O fereastră pe tot ecranul îl ascunde complet. Trage butonul de aplicații spre altă margine a ecranului pentru a muta dock-ul acolo. Fă clic dreapta pe el pentru _Position_, ca să alegi o margine, _Layout_, ca să setezi aspectul implicit așa cum face _Appearance > Workspace Layout_, și _Visibility_, ca să păstrezi dock-ul mereu vizibil, să faci ca prima aplicație să îl ascundă sau să îl păstrezi mereu ascuns. `omarchy dock visibility always` setează asta dintr-un terminal. Poziția se află și sub _Appearance > Dock > Dock Position_, iar `omarchy dock position left` o setează dintr-un terminal. Aplicațiile pe care le păstrezi în dock sunt estompate cât timp nu rulează. Pentru a păstra dock-ul doar pentru spațiile de lucru plutitoare, folosește _Appearance > Dock > Dock Only on Floating_ sau `omarchy dock tiling off`.

Spațiile de lucru noi și oricare cărora nu le-ai dat un aspect propriu cu `Super + L` folosesc aspectul implicit. Schimbarea aspectului implicit resetează la acesta fiecare spațiu de lucru fără ferestre, în timp ce unul cu ferestre pe el păstrează aspectul pe care îl are. O fereastră minimizată în dock contează în continuare ca fereastră pe spațiul de lucru pe care l-a părăsit. Alege-l sub _Appearance > Workspace Layout_: Tiling, Scrolling sau Floating. `omarchy hyprland workspace layout default scrolling` îl setează dintr-un terminal.

### Gruparea ferestrelor

Ferestrele pot fi grupate folosind `Super + G`. Odată ce ești într-un grup, fiecare fereastră pe care o pornești cât timp acesta este activ va aparține grupului. Te poți deplasa între aceste ferestre grupate folosind `Super + Ctrl + Arrow Left/Right` sau `Super + Alt + 1/2/3/4` pentru a merge direct la ferestrele grupate, în ordine.

Poți scoate o fereastră din grupare cu `Super + Alt + G` sau poți desface întregul grup apăsând din nou `Super + G`. În cele din urmă, poți muta ferestre din afara grupului în el cu `Super + Alt + Arrows`.

### Scoaterea ferestrelor

Poți scoate o fereastră din alocarea spațiului ei de lucru cu `Super + O`. Asta o va fixa ca fereastră plutitoare care te urmează pe orice spațiu de lucru mergi. Excelent pentru playere video și altele asemenea.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Spațiul de lucru scratchpad

Există un spațiu de lucru scratchpad special, de dimensiune completă, care se suprapune peste orice spațiu de lucru pe care te afli în prezent. Accesezi ce se află pe el folosind `Super + S` și așezi ferestre acolo folosind `Super + Alt + S`.

Funcționează bine pentru comenzi sau un terminal cu care vrei să interacționezi rapid fără să părăsești spațiul de lucru curent.

### Consola Quake

În cele din urmă, există o consolă Quake de jumătate de înălțime care coboară peste orice spațiu de lucru pe care te afli în prezent. O comuți cu `Super + the key above Tab` (grave pe configurațiile US) și așezi o fereastră acolo folosind `Super + Shift + the key above Tab`.

Prima dată când se deschide, pornește agentul tău implicit sau îți cere să alegi unul dacă nu ai ales încă unul. Cât timp consola conține o singură fereastră, coboară ca un panou centrat, în loc să se întindă pe tot ecranul. Pune o a doua aplicație pe ea și revine la lățimea completă, astfel încât cele două să aibă loc să stea una lângă alta.

Pentru a muta o fereastră de pe scratchpad sau de pe consolă, trimite-o direct pe alt spațiu de lucru cu ceva de genul `Super + Shift + 1`.

### Îți ia ceva timp să te obișnuiești!

Îți ia puțin timp să te obișnuiești să navighezi pe desktop în felul acesta, dar odată ce o faci, îți va fi greu să te întorci la o experiență desktop tradițională, condusă cu mouse-ul!
