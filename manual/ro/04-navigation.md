# Navigare

Totul în Omarchy se întâmplă de la tastatură — _TOTUL!_ Când sistemul pornește prima dată, literalmente nu poți face nimic doar cu mouse-ul. Dar poți apăsa `Super + Space` pentru a afișa Omarchy Menu și de aici poți face aproape totul.

Dar meniul Omarchy nici măcar nu este menit să fie principalul mod de a opera sistemul în majoritatea timpului. Putem fi mai rapizi de atât! Toate aplicațiile cele mai importante sunt legate direct de taste rapide individuale. Pornești terminalul cu `Super + Return` și un browser cu `Super + Shift + Return`. Încearcă să le faci una după alta și vei vedea magia dispunerii în mozaic a lui Hyprland în acțiune:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Apoi poți apăsa `Super + J` pentru a le stivui una peste alta în loc să fie una lângă alta:

 ![navigation-stacked](images/navigation-stacked.webp)

Apasă din nou `Super + J` pentru a le readuce în pozițiile lor una lângă alta. Apoi încearcă `Super + Shift + Arrow Right` în timp ce ești în browser pentru a interschimba ferestrele.

Acum încearcă `Super + Shift + T` pentru a porni monitorul de activitate. Acesta va apărea ca o fereastră plutitoare. Îl poți dispune în mozaic folosind `Super + T` (și apasă din nou pentru a-l face din nou plutitor). Acum apasă `Super + Shift + F` pentru a deschide managerul de fișiere. Vei avea o configurație îngrijită în patru direcții:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navighezi între fereastra pe care vrei să o activezi cu `Super + Arrow`. Aceasta va schimba focalizarea și va muta cursorul în centrul noii aplicații. La marginea unui ecran, continuă către monitorul de pe acea parte.

Dacă apeși `Super + Shift + 2`, vei muta aplicația focalizată curent pe al doilea spațiu de lucru. `Super + Shift + 1` o mută înapoi. (Și `Super + Shift + Alt + 2` va muta aplicația focalizată curent pe al doilea spațiu de lucru fără a comuta la el).

Cu mai mult de un monitor, fiecare monitor are propriile spații de lucru de la 1 la 10. `Super + 2` merge la al doilea spațiu de lucru al monitorului pe care te afli, iar bara superioară a fiecărui monitor își arată propriile spații de lucru și pe cel pe care îl afișează. `Super + Tab` parcurge ciclic spațiile de lucru de pe monitorul pe care te afli. `Super + Shift + Ctrl + Arrows` mută fereastra pe care te afli pe monitorul din acea direcție, pe spațiul de lucru pe care îl afișează acesta, iar `Super + Shift + Alt + Arrows` mută spațiul de lucru pe care te afli pe monitorul din acea direcție, unde preia același număr dacă este liber. Un monitor își păstrează spațiile de lucru când îl deconectezi: ele se alătură altui ecran, numerotate după cele pe care le are deja acesta, și revin la vechile lor numere când monitorul revine.

Dacă ții apăsat `Super` și folosești mouse-ul pentru a face clic pe o fereastră, vei putea rearanja unde se află. Dacă ții apăsat `Super` și folosești butonul din dreapta al mouse-ului, poți redimensiona liber fereastra.

Închizi o fereastră cu `Super + W` sau `Super + Q` (și închizi toate ferestrele cu `Ctrl + Alt + Delete`).

De asemenea, poți trece pe tot ecranul cu `Super + F` sau chiar doar pe toată lățimea (păstrând bara superioară) cu `Super + Alt + F` sau pe tot ecranul în interiorul unei ferestre cu `Super + Ctrl + F` (bun pentru YouTube!).

### Dispunerea dwindle vs. scrolling

Dispunerea implicită a lui Omarchy se numește dwindle. Ea păstrează toate ferestrele pe care le deschizi pe un singur spațiu de lucru vizibile în permanență, chiar dacă trebuie să le micșoreze.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Dar poți alege și să transformi un spațiu de lucru în dispunerea scrolling, unde ferestrele sunt aliniate una lângă alta, dincolo de marginea vizibilă a ecranului. Transformi un singur spațiu de lucru în această dispunere prin `Super + L`.

Apăsarea din nou a `Super + L` transformă spațiul de lucru în plutitor, unde ferestrele se suprapun liber și le așezi tu însuți, iar o a treia apăsare îl readuce la dwindle. `Super + Alt + L` le parcurge în sens invers. O fereastră care oricum plutește — una pe care ai scos-o cu `Super + T` sau o aplicație care se deschide întotdeauna plutitoare — rămâne plutitoare când spațiul de lucru revine la dispunerea în mozaic. Bara superioară marchează spațiul de lucru pe care te afli cu dispunerea sa: un pătrat pentru dwindle, un cerc pentru scrolling și un triunghi pentru plutitor. Un clic pe acel semn parcurge ciclic și dispunerea.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Alegerea este per spațiu de lucru și se păstrează. Așa că poți păstra spațiul de lucru 1 pe dwindle pentru navigare și spațiul de lucru 2 pe scrolling pentru cod și vor reveni așa după o repornire.

Dacă dorești să folosești dispunerea scrolling ca implicită, poți seta asta în `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Spații de lucru plutitoare

Un spațiu de lucru plutitor funcționează ca un desktop tradițional: ferestrele se suprapun, iar tu le muți și le dimensionezi singur. Fiecare fereastră primește o bară de titlu în culorile temei tale, cu butoane pentru minimizare, maximizare și închidere. `Super + M` minimizează și fereastra focalizată. O fereastră minimizată așteaptă în dock; fă clic pe aplicația ei pentru a o readuce. Fă clic pe o fereastră pentru a o aduce în față. Redimensioneaz-o de pe orice margine sau colț. Fă dublu clic pe o bară de titlu pentru a maximiza fereastra păstrând bara superioară la vedere și din nou pentru a-i reda dimensiunea veche.

Un spațiu de lucru plutitor arată și un dock, cu aplicațiile tale fixate, tot ce rulează și o grilă cu fiecare aplicație în spatele butonului de aplicații, pe care `Super + Alt + Space` și _Apps_ din meniul Omarchy îl deschid și ele. Fă clic dreapta pe o aplicație din grilă sau apasă `Delete` pentru a o dezinstala. Fă clic pe o aplicație pentru a o deschide sau pentru a-i aduce fereastra în față; fă clic din nou pentru a parcurge ciclic ferestrele ei. Clicul din mijloc deschide o fereastră nouă. Trage o pictogramă de-a lungul dock-ului pentru a o muta; tragerea unei aplicații care rulează printre celelalte o păstrează acolo. Fă clic dreapta pentru a păstra o aplicație în dock, a o scoate sau a o închide. Dock-ul se dă la o parte din calea unei ferestre pe tot ecranul. Fă clic dreapta pe butonul de aplicații pentru a muta dock-ul pe altă margine sau pentru a-l face să se ascundă până când indicatorul ajunge la marginea lui. Poziția se află și sub _Appearance > Dock > Dock Position_, iar `omarchy dock position left` și `omarchy dock autohide on` le setează pe amândouă dintr-un terminal. Aplicațiile pe care le păstrezi în dock sunt estompate cât timp nu rulează.

Spațiile de lucru noi și oricare cărora nu le-ai dat o dispunere proprie cu `Super + L` folosesc dispunerea implicită. Schimbarea celei implicite resetează la ea fiecare spațiu de lucru fără ferestre, în timp ce unul cu ferestre pe el păstrează dispunerea pe care o are. O fereastră minimizată în dock contează în continuare ca o fereastră pe spațiul de lucru pe care l-a părăsit. Alege-o sub _Appearance > Workspace Layout_: Tiling, Scrolling sau Floating. `omarchy-hyprland-workspace-layout-default scrolling` o setează dintr-un terminal.

### Gruparea ferestrelor

Ferestrele pot fi grupate folosind `Super + G`. Odată ce ești într-un grup, fiecare fereastră pe care o pornești cât timp acesta este activ va aparține grupului. Te poți muta între aceste ferestre grupate folosind `Super + Ctrl + Arrow Left/Right` sau `Super + Alt + 1/2/3/4` pentru a merge direct la ferestrele grupate în ordine.

Poți muta o fereastră afară din grupare cu `Super + Alt + G` sau poți destrăma întregul grup apăsând din nou `Super + G`. În cele din urmă, poți muta ferestre din afara grupului în el cu `Super + Alt + Arrows`.

### Scoaterea ferestrelor

Poți scoate o fereastră din alocarea spațiului ei de lucru cu `Super + O`. Asta o va fixa ca o fereastră plutitoare care te urmează pe orice spațiu de lucru mergi. Excelent pentru playere video și altele asemenea.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Spațiul de lucru scratchpad

Există un spațiu de lucru scratchpad special, de dimensiune completă, care se suprapune peste orice spațiu de lucru pe care te afli în prezent. Accesezi ce se află pe el folosind `Super + S` și așezi ferestre acolo folosind `Super + Alt + S`.

Funcționează bine pentru controale sau un terminal cu care vrei să interacționezi rapid fără a părăsi spațiul de lucru curent.

### Consola Quake

În cele din urmă, există o consolă Quake de jumătate de înălțime care coboară peste orice spațiu de lucru pe care te afli în prezent. Comut-o cu `Super + Grave` și așază o fereastră acolo folosind `Super + Shift + Grave`.

Se deschide cu agentul tău implicit gata de acțiune. Cât timp consola conține o singură fereastră, ea coboară ca un panou centrat, în loc să se întindă pe tot ecranul. Pune o a doua aplicație pe ea și revine la lățimea completă, astfel încât cele două să aibă loc să stea una lângă alta.

Pentru a muta o fereastră fie de pe scratchpad, fie de pe consolă, trimite-o direct pe alt spațiu de lucru cu ceva de genul `Super + Shift + 1`.

### Ai nevoie de puțin timp să te obișnuiești!

Este nevoie de puțin timp să te obișnuiești să navighezi pe desktopul tău așa, dar odată ce o faci, îți va fi greu să te întorci la o experiență tradițională de desktop condusă de mouse!
