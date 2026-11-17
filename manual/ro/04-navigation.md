# Navigare

Totul în Omarchy se întâmplă prin tastatură — _TOTUL!_ Când sistemul pornește prima dată, literalmente nu poți face nimic doar cu mouse-ul. Dar poți apăsa `Super + Space` ca să afișezi Meniul Omarchy și de aici poți face aproape orice.

Dar meniul Omarchy nici măcar nu este gândit să fie modul principal de operare a sistemului în majoritatea timpului. Putem fi mai rapizi de atât! Toate aplicațiile cele mai importante sunt legate direct de taste rapide individuale. Pornești terminalul cu `Super + Return` și un browser cu `Super + Shift + Return`. Încearcă să le faci una după alta și vei vedea magia aranjării în mozaic din Hyprland în acțiune:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Apoi poți apăsa `Super + J` ca să le suprapui una peste alta în loc să fie una lângă alta:

 ![navigation-stacked](images/navigation-stacked.webp)

Apasă din nou `Super + J` ca să le readuci în pozițiile una lângă alta. Apoi încearcă `Super + Shift + Arrow Right` în timp ce ești în browser ca să schimbi ferestrele între ele.

Acum încearcă `Super + Shift + T` ca să pornești monitorul Activity. Acesta va apărea ca o fereastră plutitoare. Îl poți aranja în mozaic folosind `Super + T` (și apasă din nou ca să-l faci plutitor la loc). Acum apasă `Super + Shift + F` ca să deschizi managerul de fișiere. Vei avea o configurație ordonată în patru:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navighezi între fereastra pe care vrei să o activezi cu `Super + Arrow`. Aceasta va schimba focalizarea și va muta cursorul în centrul noii aplicații. La marginea unui ecran, continuă spre monitorul din acea parte.

Dacă apeși `Super + Shift + 2`, vei muta aplicația focalizată curent pe al doilea spațiu de lucru. `Super + Shift + 1` o mută înapoi. (Iar `Super + Shift + Alt + 2` va muta aplicația focalizată curent pe al doilea spațiu de lucru fără să comute la el).

Cu mai mult de un monitor, fiecare monitor are propriile spații de lucru de la 1 la 10. `Super + 2` merge la al doilea spațiu de lucru al monitorului pe care ești, iar bara superioară a fiecărui monitor își arată propriile spații de lucru și pe cel pe care îl afișează. `Super + Tab` parcurge ciclic spațiile de lucru de pe monitorul pe care ești. `Super + Shift + Ctrl + Arrows` mută fereastra pe care ești pe monitorul în acea direcție, pe spațiul de lucru pe care îl afișează, iar `Super + Shift + Alt + Arrows` mută spațiul de lucru pe care ești pe monitorul în acea direcție, unde preia același număr dacă este liber. Un monitor își păstrează spațiile de lucru când îl deconectezi: ele se alătură celor ale altui ecran, numerotate după cele pe care le are deja, și revin sub numerele lor vechi când monitorul se întoarce.

Dacă ții apăsat `Super` și folosești mouse-ul ca să dai clic pe o fereastră, vei putea rearanja unde stă. Dacă ții apăsat `Super` și folosești butonul din dreapta al mouse-ului, poți redimensiona liber fereastra.

Închizi o fereastră cu `Super + W` sau `Super + Q` (și închizi toate ferestrele cu `Ctrl + Alt + Delete`).

Poți trece și pe ecran complet cu `Super + F` sau chiar doar pe lățime completă (păstrând bara superioară) cu `Super + Alt + F` sau pe ecran complet în interiorul unei ferestre cu `Super + Ctrl + F` (bun pentru YouTube!).

### Aspectul dwindle vs. aspectul cu derulare

Aspectul implicit din Omarchy se numește dwindle. Păstrează toate ferestrele pe care le deschizi pe un singur spațiu de lucru vizibile în permanență, chiar dacă trebuie să le micșoreze.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Dar poți alege și să transformi un spațiu de lucru în aspectul cu derulare, unde ferestrele sunt aliniate una lângă alta, dincolo de marginea vizibilă a afișajului. Transformi un singur spațiu de lucru în acest aspect prin `Super + L`.

Dacă apeși din nou `Super + L`, spațiul de lucru devine plutitor, unde ferestrele se suprapun liber și le așezi tu însuți, iar a treia apăsare îl readuce la dwindle. `Super + Alt + L` le parcurge în sens invers. O fereastră care oricum plutește — una pe care ai scos-o cu `Super + T` sau o aplicație care se deschide întotdeauna plutitoare — rămâne plutitoare când spațiul de lucru revine la aranjarea în mozaic. Bara superioară marchează spațiul de lucru pe care ești cu aspectul său: un pătrat pentru dwindle, un cerc pentru derulare și un triunghi pentru plutitor. Dacă dai clic pe acel semn, aspectul se schimbă ciclic, de asemenea.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Alegerea este per spațiu de lucru și rămâne. Așa că poți păstra spațiul de lucru 1 pe dwindle pentru navigare pe web și spațiul de lucru 2 pe derulare pentru cod, și vor reveni așa după o repornire.

Dacă vrei să folosești aspectul cu derulare ca implicit, poți seta asta în `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Spații de lucru plutitoare

Un spațiu de lucru plutitor funcționează ca un desktop tradițional: ferestrele se suprapun, iar tu le muți și le dimensionezi singur. Fiecare fereastră primește o bară de titlu în culorile temei tale, cu butoane pentru minimizare, maximizare și închidere. `Super + M` minimizează, de asemenea, fereastra focalizată. O fereastră minimizată așteaptă în dock; dă clic pe aplicația ei ca să o aduci înapoi. Dă clic pe o fereastră ca să o aduci în față. Redimensioneaz-o de pe orice margine sau colț. Dă dublu clic pe o bară de titlu ca să maximizezi fereastra păstrând bara superioară vizibilă, și din nou ca să-i recuperezi dimensiunea veche. Chrome și alte browsere bazate pe Chromium, Disks și Document Viewer sar peste bara de titlu și folosesc în schimb propriul antet; `Super + Alt + F` le maximizează, iar `Super + M` le minimizează.

Un spațiu de lucru plutitor arată și un dock, cu aplicațiile tale fixate, tot ce rulează și o grilă cu fiecare aplicație în spatele butonului de aplicații, pe care `Super + Alt + Space` și _Apps_ din meniul Omarchy o deschid, de asemenea. Dă clic dreapta pe o aplicație din grilă sau apasă `Delete` ca să o dezinstalezi. Dă clic pe o aplicație ca să o deschizi sau ca să-i aduci fereastra în față; dă clic din nou ca să parcurgi ciclic ferestrele ei. Files aduce înapoi doar o fereastră din spațiul de lucru pe care ești și altfel deschide una nouă, iar Terminal și Agent pornesc întotdeauna alta, deși o fereastră minimizată revine prima. Clicul din mijloc deschide o fereastră nouă. Trage o pictogramă de-a lungul dock-ului ca să o muți; dacă tragi o aplicație care rulează printre celelalte, ea rămâne acolo. Dă clic dreapta ca să păstrezi o aplicație în dock, să o scoți sau să o închizi. Dock-ul se dă la o parte din calea unei ferestre pe ecran complet. Dă clic dreapta pe butonul de aplicații ca să muți dock-ul pe altă margine sau ca să-l faci să se ascundă până când indicatorul ajunge la marginea lui. Poziția se află și sub _Appearance > Dock > Dock Position_, iar `omarchy dock position left` și `omarchy dock autohide on` le setează pe amândouă dintr-un terminal. Aplicațiile pe care le păstrezi în dock sunt estompate cât timp nu rulează.

Spațiile de lucru noi și oricare cărora nu le-ai dat un aspect propriu cu `Super + L` folosesc aspectul implicit. Schimbarea aspectului implicit resetează la el fiecare spațiu de lucru fără ferestre, în timp ce unul cu ferestre pe el își păstrează aspectul pe care îl are. O fereastră minimizată în dock contează în continuare ca o fereastră pe spațiul de lucru pe care l-a părăsit. Alege-l sub _Appearance > Workspace Layout_: Tiling, Scrolling sau Floating. `omarchy-hyprland-workspace-layout-default scrolling` îl setează dintr-un terminal.

### Gruparea ferestrelor

Ferestrele pot fi grupate folosind `Super + G`. Odată ce ești într-un grup, fiecare fereastră pe care o pornești cât timp acesta este activ va aparține grupului. Te poți deplasa între aceste ferestre grupate folosind `Super + Ctrl + Arrow Left/Right` sau `Super + Alt + 1/2/3/4` ca să mergi direct la ferestrele grupate în ordine.

Poți muta o fereastră în afara grupării cu `Super + Alt + G` sau poți desface întregul grup apăsând din nou `Super + G`. În cele din urmă, poți muta ferestre din afara grupului în el cu `Super + Alt + Arrows`.

### Scoaterea ferestrelor

Poți scoate o fereastră din alocarea ei de spațiu de lucru cu `Super + O`. Asta o va fixa ca o fereastră plutitoare care te urmează pe orice spațiu de lucru mergi. Excelent pentru playere video și altele asemenea.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Spațiul de lucru scratchpad

Există un spațiu de lucru scratchpad special, de dimensiune completă, care se suprapune peste orice spațiu de lucru pe care ești în prezent. Accesezi ce se află pe el folosind `Super + S`, și așezi ferestre acolo folosind `Super + Alt + S`.

Funcționează bine pentru comenzi sau un terminal cu care vrei să interacționezi rapid fără să părăsești spațiul de lucru curent.

### Consola Quake

În cele din urmă, există o consolă Quake de jumătate de înălțime care coboară peste orice spațiu de lucru pe care ești în prezent. Comut-o cu `Super + Grave`, și așază o fereastră acolo folosind `Super + Shift + Grave`.

Se deschide cu agentul tău implicit gata de lucru. Cât timp consola conține o singură fereastră, coboară ca un panou centrat, în loc să se întindă pe tot ecranul. Pune o a doua aplicație pe ea și revine la lățimea completă, astfel încât cele două să aibă loc să stea una lângă alta.

Ca să muți o fereastră de pe scratchpad sau de pe consolă, trimite-o direct pe alt spațiu de lucru cu ceva de genul `Super + Shift + 1`.

### Durează puțin până te obișnuiești!

Durează puțin până te obișnuiești să navighezi pe desktop în felul acesta, dar odată ce o faci, îți va fi greu să te întorci la o experiență desktop tradițională, condusă de mouse!
