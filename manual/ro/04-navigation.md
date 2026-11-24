# Navigare

Totul în Omarchy se face de la tastatură — _TOTUL!_ Când sistemul pornește prima dată, literalmente nu poți face nimic doar cu mouse-ul. Dar poți apăsa `Super + Space` pentru a afișa Meniul Omarchy și de aici poți face cam totul.

Dar meniul Omarchy nici măcar nu este gândit să fie modul principal de operare a sistemului în cea mai mare parte a timpului. Putem merge mai repede decât atât! Toate aplicațiile cele mai importante sunt legate direct de taste rapide individuale. Pornești terminalul cu `Super + Return` și un browser cu `Super + Shift + Return`. Încearcă să le faci una după alta și vei vedea magia dispunerii în plăci a Hyprland în acțiune:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Poți apoi apăsa `Super + J` pentru a le stivui una peste alta în loc să fie una lângă alta:

 ![navigation-stacked](images/navigation-stacked.webp)

Apasă `Super + J` din nou pentru a le readuce în pozițiile una lângă alta. Apoi încearcă `Super + Shift + Arrow Right` în timp ce ești în browser pentru a schimba ferestrele între ele.

Acum încearcă `Super + Shift + T` pentru a porni monitorul Activity. Acesta va apărea ca o fereastră plutitoare. Îl poți dispune în plăci folosind `Super + T` (și apasă din nou pentru a-l face din nou plutitor). Acum apasă `Super + Shift + F` pentru a deschide managerul de fișiere. Vei avea o aranjare ordonată în patru:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navighezi între fereastra pe care vrei să o faci activă cu `Super + Arrow`. Acest lucru va schimba focalizarea și va muta cursorul în centrul noii aplicații. La marginea unui ecran, continuă spre monitorul de pe acea parte.

Dacă apeși `Super + Shift + 2`, vei muta aplicația focalizată curent pe al doilea spațiu de lucru. `Super + Shift + 1` o mută înapoi. (Și `Super + Shift + Alt + 2` va muta aplicația focalizată curent pe al doilea spațiu de lucru fără să comute la acesta).

Cu mai mult de un monitor, fiecare monitor are propriile spații de lucru de la 1 la 10. `Super + 2` merge la al doilea spațiu de lucru al monitorului pe care ești, iar bara de sus a fiecărui monitor afișează propriile spații de lucru și pe cel pe care îl afișează. `Super + Tab` parcurge ciclic spațiile de lucru de pe monitorul pe care ești. `Super + Shift + Ctrl + Arrows` mută fereastra pe care ești pe monitorul din acea direcție, pe spațiul de lucru pe care îl afișează acesta, iar `Super + Shift + Alt + Arrows` mută spațiul de lucru pe care ești pe monitorul din acea direcție, unde preia același număr dacă este liber. Un monitor își păstrează spațiile de lucru când îl deconectezi: acestea se alătură celor ale altui ecran, numerotate după cele pe care le are deja, și revin sub numerele lor vechi când monitorul revine.

Dacă ții apăsat `Super` și folosești mouse-ul pentru a face clic pe o fereastră, vei putea rearanja unde stă. Dacă ții apăsat `Super` și folosești butonul din dreapta al mouse-ului, poți redimensiona liber fereastra.

Închizi o fereastră cu `Super + W` sau `Super + Q` (și închizi toate ferestrele cu `Ctrl + Alt + Delete`).

De asemenea, poți trece pe ecran complet cu `Super + F` sau chiar doar pe lățime completă (păstrând bara de sus) cu `Super + Alt + F` sau pe ecran complet în interiorul unei ferestre cu `Super + Ctrl + F` (bun pentru YouTube!).

### Dispunerea dwindle vs. scrolling

Dispunerea implicită a Omarchy se numește dwindle. Păstrează toate ferestrele pe care le deschizi pe un singur spațiu de lucru vizibile în permanență, chiar dacă trebuie să le micșoreze.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Dar poți alege, de asemenea, să transformi un spațiu de lucru în dispunerea scrolling, în care ferestrele sunt aliniate una lângă alta, dincolo de marginea vizibilă a ecranului. Transformi un singur spațiu de lucru în această dispunere prin `Super + L`.

Apăsarea `Super + L` din nou transformă spațiul de lucru în unul plutitor, în care ferestrele se suprapun liber și le plasezi tu însuți, iar o a treia apăsare îl readuce la dwindle. `Super + Alt + L` le parcurge în sens invers. O fereastră care oricum plutește — una pe care ai scos-o cu `Super + T` sau o aplicație care se deschide întotdeauna plutitoare — rămâne plutitoare când spațiul de lucru revine la dispunerea în plăci. Bara de sus marchează spațiul de lucru pe care ești cu dispunerea sa: un pătrat pentru dwindle, un cerc pentru scrolling și un triunghi pentru plutitor. Un clic pe acel semn parcurge ciclic dispunerea, la fel și tasta de afișare de pe laptopurile care au una.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Alegerea este per spațiu de lucru și rămâne. Așa că poți păstra spațiul de lucru 1 pe dwindle pentru navigare și spațiul de lucru 2 pe scrolling pentru cod, iar acestea vor reveni așa după o repornire.

Dacă dorești să folosești dispunerea scrolling ca implicită, poți seta acest lucru în `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Spații de lucru plutitoare

Un spațiu de lucru plutitor funcționează ca un desktop tradițional: ferestrele se suprapun, iar tu le muți și le dimensionezi singur. Fiecare fereastră primește o bară de titlu în culorile temei tale, cu butoane pentru minimizare, maximizare și închidere. `Super + M` minimizează și fereastra focalizată. O fereastră minimizată așteaptă în dock; fă clic pe aplicația sa pentru a o readuce. Fă clic pe o fereastră pentru a o aduce în față. Redimensioneaz-o din orice margine sau colț. Fă dublu clic pe o bară de titlu pentru a maximiza fereastra păstrând bara de sus vizibilă și din nou pentru a-i readuce dimensiunea veche. Chrome și alte browsere bazate pe Chromium, Disks și Document Viewer sar peste bara de titlu și folosesc în schimb propriul antet; `Super + Alt + F` le maximizează, iar `Super + M` le minimizează.

Un spațiu de lucru plutitor afișează și un dock, cu aplicațiile tale fixate, tot ce rulează și o grilă cu fiecare aplicație în spatele butonului de aplicații, pe care `Super + Alt + Space` și _Apps_ din meniul Omarchy o deschid de asemenea. Fă clic dreapta pe o aplicație din grilă sau apasă `Delete` pentru a o dezinstala. Fă clic pe o aplicație pentru a o deschide sau pentru a-i aduce fereastra în față; fă clic din nou pentru a parcurge ciclic ferestrele sale. Files readuce doar o fereastră de pe spațiul de lucru pe care ești și altfel deschide una nouă, iar Terminal și Agent pornesc întotdeauna alta, deși o fereastră minimizată revine prima. Un clic cu butonul din mijloc deschide o fereastră nouă. Trage o pictogramă de-a lungul dock-ului pentru a o muta; tragerea unei aplicații care rulează printre celelalte o păstrează acolo. Fă clic dreapta pentru a păstra o aplicație în dock, pentru a o scoate sau pentru a o închide. Dock-ul se dă la o parte din calea unei ferestre pe ecran complet. Fă clic dreapta pe butonul de aplicații pentru a muta dock-ul la altă margine sau pentru a-l face să se ascundă până când indicatorul ajunge la marginea sa. Poziția se află și sub _Appearance > Dock > Dock Position_, iar `omarchy dock position left` și `omarchy dock autohide on` le setează pe ambele dintr-un terminal. Aplicațiile pe care le păstrezi în dock sunt estompate în timp ce nu rulează.

Spațiile de lucru noi și oricare cărora nu le-ai dat o dispunere proprie cu `Super + L` folosesc dispunerea implicită. Schimbarea celei implicite resetează la aceasta fiecare spațiu de lucru fără ferestre, în timp ce unul cu ferestre pe el păstrează dispunerea pe care o are. O fereastră minimizată în dock contează în continuare ca o fereastră pe spațiul de lucru pe care l-a părăsit. Alege-o sub _Appearance > Workspace Layout_: Tiling, Scrolling sau Floating. `omarchy hyprland workspace layout default scrolling` o setează dintr-un terminal.

### Gruparea ferestrelor

Ferestrele pot fi grupate folosind `Super + G`. Odată ce ești într-un grup, fiecare fereastră pe care o pornești în timp ce acesta este activ va aparține grupului. Te poți deplasa între aceste ferestre grupate folosind `Super + Ctrl + Arrow Left/Right` sau `Super + Alt + 1/2/3/4` pentru a merge direct la ferestrele grupate în ordine.

Poți muta o fereastră în afara grupării cu `Super + Alt + G` sau poți desface întregul grup apăsând din nou `Super + G`. În cele din urmă, poți muta ferestre din afara grupului în acesta cu `Super + Alt + Arrows`.

### Scoaterea ferestrelor

Poți scoate o fereastră din alocarea sa de spațiu de lucru cu `Super + O`. Acest lucru o va fixa ca o fereastră plutitoare care te urmează pe orice spațiu de lucru mergi. Excelent pentru playere video și altele asemenea.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Spațiul de lucru scratchpad

Există un spațiu de lucru scratchpad special, de dimensiune completă, care se suprapune peste orice spațiu de lucru pe care ești în prezent. Accesezi ce se află pe el folosind `Super + S` și plasezi ferestre acolo folosind `Super + Alt + S`.

Funcționează bine pentru controale sau pentru un terminal cu care vrei să interacționezi rapid fără să părăsești spațiul de lucru curent.

### Consola Quake

În cele din urmă, există o consolă Quake de înălțime jumătate care coboară peste orice spațiu de lucru pe care ești în prezent. Comut-o cu `Super + the key above Tab` (grave pe aranjamentele US) și plasează o fereastră acolo folosind `Super + Shift + the key above Tab`.

Prima dată când se deschide, pornește agentul tău implicit sau îți cere să alegi unul dacă nu ai ales încă unul. În timp ce consola conține o singură fereastră, ea coboară ca un panou centrat, în loc să se întindă pe tot ecranul. Pune o a doua aplicație pe ea și revine la lățimea completă, astfel încât cele două să aibă loc să stea una lângă alta.

Pentru a muta o fereastră de pe scratchpad sau de pe consolă, trimite-o direct pe alt spațiu de lucru cu ceva precum `Super + Shift + 1`.

### Îți ia ceva timp să te obișnuiești!

Îți ia puțin timp să te obișnuiești să navighezi pe desktop astfel, dar odată ce o faci, îți va fi greu să te întorci la o experiență desktop tradițională condusă de mouse!
