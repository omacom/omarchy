# Navigare

Totul în Omarchy se face de la tastatură — _TOTUL!_ Când sistemul pornește prima dată, literalmente nu poți face nimic doar cu mouse-ul. Dar poți apăsa `Super + Space` ca să afișezi Meniul Omarchy și de aici poți face cam totul.

Dar meniul Omarchy nici măcar nu este gândit să fie modalitatea principală de operare a sistemului în cea mai mare parte a timpului. Putem fi mai rapizi de atât! Toate aplicațiile cele mai importante sunt legate direct de taste rapide individuale. Pornești terminalul cu `Super + Return` și un browser cu `Super + Shift + Return`. Încearcă să le faci una după alta și vei vedea magia placării din Hyprland în acțiune:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Apoi poți apăsa `Super + J` ca să le stivuiești una peste alta în loc să fie una lângă alta:

 ![navigation-stacked](images/navigation-stacked.webp)

Apasă `Super + J` din nou ca să le readuci în pozițiile una lângă alta. Apoi încearcă `Super + Shift + Arrow Right` cât timp ești pe browser ca să interschimbi ferestrele.

Acum încearcă `Super + Shift + T` ca să pornești monitorul de activitate. Acesta va apărea ca o fereastră plutitoare. Îl poți aduce în placare folosind `Super + T` (și apasă din nou ca să-l faci din nou plutitor). Acum apasă `Super + Shift + F` ca să deschizi managerul de fișiere. Vei avea o configurație îngrijită în patru direcții:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navighezi între ferestre, pe cea pe care vrei să o activezi, cu `Super + Arrow`. Aceasta va schimba focalizarea și va muta cursorul în centrul noii aplicații. La marginea unui ecran, continuă către monitorul de pe acea parte.

Dacă apeși `Super + Shift + 2`, vei muta aplicația focalizată curent pe al doilea spațiu de lucru. `Super + Shift + 1` o mută înapoi. (Iar `Super + Shift + Alt + 2` va muta aplicația focalizată curent pe al doilea spațiu de lucru fără să comuți la acesta).

Cu mai mult de un monitor, fiecare monitor are propriile sale spații de lucru de la 1 la 10. `Super + 2` merge la al doilea spațiu de lucru al monitorului pe care ești, iar bara superioară a fiecărui monitor afișează propriile sale spații de lucru și pe cel pe care îl arată. `Super + Tab` parcurge ciclic spațiile de lucru de pe monitorul pe care ești. `Super + Shift + Ctrl + Arrows` mută fereastra pe care ești pe monitorul în acea direcție, pe spațiul de lucru pe care îl arată acesta, iar `Super + Shift + Alt + Arrows` mută spațiul de lucru pe care ești pe monitorul în acea direcție, unde preia același număr dacă este liber. Un monitor își păstrează spațiile de lucru când îl deconectezi: ele se alătură unui alt ecran, numerotate după cele pe care le are deja, și revin sub vechile lor numere când monitorul se întoarce.

Dacă ții apăsat `Super` și folosești mouse-ul ca să dai clic pe o fereastră, vei putea rearanja locul în care stă. Dacă ții apăsat `Super` și folosești butonul drept al mouse-ului, poți redimensiona liber fereastra.

Închizi o fereastră cu `Super + W` sau `Super + Q` (și închizi toate ferestrele cu `Ctrl + Alt + Delete`).

De asemenea, poți trece pe ecran complet cu `Super + F` sau chiar doar pe lățime completă (păstrând bara superioară) cu `Super + Alt + F` ori pe ecran complet în interiorul unei ferestre cu `Super + Ctrl + F` (bun pentru YouTube!).

### Dwindle vs aranjamentul cu derulare

Aranjamentul implicit din Omarchy se numește dwindle. Păstrează toate ferestrele pe care le deschizi pe un singur spațiu de lucru vizibile în permanență, chiar dacă trebuie să le micșoreze.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Dar poți alege și să transformi un spațiu de lucru în aranjamentul cu derulare, în care ferestrele sunt aliniate una lângă alta, dincolo de marginea vizibilă a ecranului. Transformi un singur spațiu de lucru în acest aranjament prin `Super + L`.

Apăsarea `Super + L` din nou transformă spațiul de lucru într-unul plutitor, în care ferestrele se suprapun liber și le plasezi tu însuți, iar o a treia apăsare îl readuce la dwindle. `Super + Alt + L` le parcurge în sens invers. O fereastră care oricum plutește — una pe care ai extras-o cu `Super + T` sau o aplicație care se deschide întotdeauna plutitoare — rămâne plutitoare când spațiul de lucru revine la placare. Bara superioară marchează spațiul de lucru pe care ești cu aranjamentul său: un pătrat pentru dwindle, un cerc pentru derulare și un triunghi pentru plutitor. Și clicul pe acel semn parcurge ciclic aranjamentul.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Alegerea este per spațiu de lucru și se păstrează. Așa că poți păstra spațiul de lucru 1 pe dwindle pentru navigare și spațiul de lucru 2 pe derulare pentru cod, iar ele vor reveni astfel după o repornire.

Dacă vrei să folosești aranjamentul cu derulare ca implicit, poți seta asta în `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Spații de lucru plutitoare

Un spațiu de lucru plutitor funcționează ca un desktop tradițional: ferestrele se suprapun, iar tu le muți și le dimensionezi singur. Fiecare fereastră primește o bară de titlu în culorile temei tale, cu butoane pentru minimizare, maximizare și închidere. Și `Super + M` minimizează fereastra focalizată. O fereastră minimizată așteaptă în dock; dă clic pe aplicația ei ca să o aduci înapoi. Dă clic pe o fereastră ca să o aduci în față. Redimensioneaz-o de la orice margine sau colț. Dă dublu clic pe o bară de titlu ca să maximizezi fereastra păstrând bara superioară la vedere și din nou ca să-i redai vechea dimensiune.

Un spațiu de lucru plutitor afișează și un dock, cu aplicațiile tale fixate, tot ce rulează și o grilă cu toate aplicațiile în spatele butonului pentru aplicații, pe care `Super + Alt + Space` și _Apps_ din meniul Omarchy îl deschid de asemenea. Dă clic dreapta pe o aplicație din grilă sau apasă `Delete` ca să o dezinstalezi. Dă clic pe o aplicație ca să o deschizi sau ca să-i aduci fereastra în față; dă clic din nou ca să parcurgi ciclic ferestrele ei. Clicul din mijloc deschide o fereastră nouă. Trage o pictogramă de-a lungul dock-ului ca să o muți; tragerea unei aplicații care rulează printre celelalte o păstrează acolo. Dă clic dreapta ca să păstrezi o aplicație în dock, să o scoți de acolo sau să o închizi. Dock-ul se dă din calea unei ferestre pe ecran complet. Dă clic dreapta pe butonul pentru aplicații ca să muți dock-ul pe altă margine sau ca să-l faci să se ascundă până când indicatorul ajunge la marginea lui. Poziția se află și sub _Appearance > Dock > Dock Position_, iar `omarchy dock position left` și `omarchy dock autohide on` le setează pe amândouă dintr-un terminal. Aplicațiile pe care le păstrezi în dock sunt estompate cât timp nu rulează.

Spațiile de lucru noi și oricare cărora nu le-ai dat un aranjament propriu cu `Super + L` folosesc aranjamentul implicit. Schimbarea celui implicit resetează la acesta fiecare spațiu de lucru fără ferestre, în timp ce unul cu ferestre pe el păstrează aranjamentul pe care îl are. O fereastră minimizată în dock încă se numără ca fereastră pe spațiul de lucru pe care l-a părăsit. Alege-l sub _Appearance > Workspace Layout_: Tiling, Scrolling sau Floating. `omarchy-hyprland-workspace-layout-default scrolling` îl setează dintr-un terminal.

### Gruparea ferestrelor

Ferestrele pot fi grupate folosind `Super + G`. Odată ce ești într-un grup, fiecare fereastră pe care o pornești cât timp acesta este activ va aparține grupului. Te poți deplasa între aceste ferestre grupate folosind `Super + Ctrl + Arrow Left/Right` sau `Super + Alt + 1/2/3/4` ca să mergi direct la fereastra grupată, în ordine.

Poți muta o fereastră în afara grupării cu `Super + Alt + G` sau poți desface întregul grup apăsând din nou `Super + G`. În cele din urmă, poți muta ferestre din afara grupului în acesta cu `Super + Alt + Arrows`.

### Extragerea ferestrelor

Poți extrage o fereastră din alocarea ei în spațiul de lucru cu `Super + O`. Asta o va fixa ca fereastră plutitoare care te urmează pe orice spațiu de lucru ai merge. Excelentă pentru playere video și altele asemenea.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Spațiul de lucru scratchpad

Există un spațiu de lucru scratchpad special, de dimensiune completă, care se suprapune peste orice spațiu de lucru pe care ești în prezent. Accesezi ce se află pe el folosind `Super + S` și plasezi ferestre acolo folosind `Super + Alt + S`.

Funcționează bine pentru comenzi sau un terminal cu care vrei să interacționezi rapid fără să părăsești spațiul de lucru curent.

### Consola Quake

În cele din urmă, există o consolă Quake cu înălțime la jumătate, care coboară peste orice spațiu de lucru pe care ești în prezent. Comut-o cu `Super + Grave` și plasează o fereastră acolo folosind `Super + Shift + Grave`.

Se deschide cu agentul tău implicit pregătit de lucru. Cât timp consola conține o singură fereastră, ea coboară ca un panou centrat, în loc să se întindă pe tot ecranul. Pune o a doua aplicație pe ea și revine la lățimea completă, astfel încât cele două să aibă loc să stea una lângă alta.

Ca să muți o fereastră de pe scratchpad sau de pe consolă, trimite-o direct pe alt spațiu de lucru cu ceva de genul `Super + Shift + 1`.

### E nevoie de puțin timp să te obișnuiești!

E nevoie de puțin timp să te obișnuiești să navighezi pe desktop în felul acesta, dar odată ce o faci, va fi greu să te întorci la o experiență tradițională de desktop bazată pe mouse!
