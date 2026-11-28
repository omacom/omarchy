# Navigare

Totul în Omarchy se face de la tastatură — _TOTUL!_ Când sistemul pornește prima dată, efectiv nu poți face nimic doar cu mouse-ul. Dar poți apăsa `Super + Space` ca să dezvălui Meniul Omarchy și de aici poți face cam totul.

Dar meniul Omarchy nici măcar nu este gândit să fie principalul mod de a opera sistemul în cea mai mare parte a timpului. Putem merge mai repede de atât! Toate aplicațiile cele mai importante sunt legate direct de taste rapide individuale. Pornești terminalul cu `Super + Return` și un browser cu `Super + Shift + Return`. Încearcă să le faci una după alta și vei vedea magia placării din Hyprland în acțiune:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Poți apoi apăsa `Super + J` ca să le stivuiești una peste alta în loc să fie una lângă alta:

 ![navigation-stacked](images/navigation-stacked.webp)

Apasă din nou `Super + J` ca să le readuci în pozițiile una lângă alta. Apoi încearcă `Super + Shift + Arrow Right` în timp ce ești în browser ca să interschimbi ferestrele.

Acum încearcă `Super + Shift + T` ca să pornești monitorul Activity. Acesta va apărea ca o fereastră flotantă, cu o bară de titlu de care îl poți trage și butoane pentru a-l minimiza, maximiza și închide. Fiecare fereastră flotantă primește una, oriunde s-ar afla. Îl poți placa folosind `Super + T` (și apasă din nou ca să-l faci din nou flotant). Acum apasă `Super + Shift + F` ca să deschizi managerul de fișiere. Vei avea o configurație îngrijită în patru direcții:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navighezi între fereastra pe care vrei s-o activezi cu `Super + Arrow`. Aceasta va schimba focalizarea și va muta cursorul în centrul noii aplicații. La marginea unui ecran, continuă către monitorul de pe acea parte.

Dacă apeși `Super + Shift + 2`, vei muta aplicația focalizată în prezent pe al doilea spațiu de lucru. `Super + Shift + 1` o mută înapoi. (Iar `Super + Shift + Alt + 2` va muta aplicația focalizată în prezent pe al doilea spațiu de lucru fără să comute la el).

Cu mai mult de un monitor, fiecare monitor are propriile spații de lucru de la 1 la 10. `Super + 2` merge la al doilea spațiu de lucru al monitorului pe care te afli, iar bara superioară a fiecărui monitor afișează propriile spații de lucru și pe cel pe care îl arată. `Super + Tab` parcurge ciclic spațiile de lucru de pe monitorul pe care te afli. `Super + Shift + Ctrl + Arrows` mută fereastra pe care te afli pe monitorul în acea direcție, pe spațiul de lucru pe care îl arată acesta, iar `Super + Shift + Alt + Arrows` mută spațiul de lucru pe care te afli pe monitorul în acea direcție, unde preia același număr dacă este liber. Un monitor își păstrează spațiile de lucru când îl deconectezi: acestea se alătură celor ale altui ecran, numerotate după cele pe care le are deja, și revin sub numerele lor vechi când monitorul se întoarce.

Dacă ții apăsat `Super` și folosești mouse-ul ca să dai clic pe o fereastră, vei putea rearanja unde stă aceasta. Dacă ții apăsat `Super` și folosești butonul din dreapta al mouse-ului, poți redimensiona liber fereastra.

Închizi o fereastră cu `Super + W` sau `Super + Q` (și închizi toate ferestrele cu `Ctrl + Alt + Delete`).

Poți, de asemenea, să treci pe ecran complet cu `Super + F` sau chiar doar pe lățime completă (păstrând bara superioară) cu `Super + Alt + F` sau pe ecran complet în interiorul unei ferestre cu `Super + Ctrl + F` (bun pentru YouTube!).

### Dispunerea dwindle vs. dispunerea cu derulare

Dispunerea implicită din Omarchy se numește dwindle. Păstrează toate ferestrele pe care le deschizi pe un singur spațiu de lucru vizibile în permanență, chiar dacă trebuie să le micșoreze.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Dar poți alege și să transformi un spațiu de lucru în dispunerea cu derulare, în care ferestrele sunt aliniate una lângă alta, dincolo de marginea vizibilă a ecranului. Transformi un singur spațiu de lucru în această dispunere prin `Super + L`.

Apăsarea din nou a `Super + L` transformă spațiul de lucru în unul flotant, în care ferestrele se suprapun liber și le așezi tu însuți, iar o a treia apăsare îl readuce la dwindle. `Super + Alt + L` le parcurge în sens invers. O fereastră care oricum plutește — una pe care ai scos-o cu `Super + T` sau o aplicație care se deschide întotdeauna flotant — rămâne flotantă când spațiul de lucru revine la placare. Bara superioară marchează spațiul de lucru pe care te afli cu dispunerea lui: un pătrat pentru dwindle, un cerc pentru derulare și un triunghi pentru flotant. Clicul pe acel semn parcurge ciclic și dispunerea, la fel și tasta de afișare de pe laptopurile care au una.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Alegerea este pentru fiecare spațiu de lucru și rămâne. Așa că poți păstra spațiul de lucru 1 pe dwindle pentru navigare și spațiul de lucru 2 pe derulare pentru cod și vor reveni așa după o repornire.

Dacă dorești să folosești dispunerea cu derulare ca implicită, poți seta asta în `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Spații de lucru flotante

Un spațiu de lucru flotant funcționează ca un desktop tradițional: ferestrele se suprapun, iar tu le muți și le dimensionezi singur. Fiecare fereastră primește o bară de titlu în culorile temei tale, cu butoane pentru minimizare, maximizare și închidere. `Super + M` minimizează și fereastra focalizată. O fereastră minimizată așteaptă în dock; dă clic pe aplicația ei ca s-o readuci. Dă clic pe o fereastră ca s-o aduci în față. Redimensioneaz-o de pe orice margine sau colț. Dă dublu clic pe o bară de titlu ca să maximizezi fereastra păstrând bara superioară la vedere și din nou ca să-i redai dimensiunea veche. Chrome și alte browsere bazate pe Chromium, Disks și Document Viewer sar peste bara de titlu și folosesc în schimb propriul antet; `Super + Alt + F` le maximizează, iar `Super + M` le minimizează.

Fiecare spațiu de lucru are un dock, cu aplicațiile tale fixate, tot ce rulează și o grilă cu fiecare aplicație în spatele butonului de aplicații, pe care `Super + Alt + Space` și _Apps_ din meniul Omarchy îl deschid de asemenea. Dă clic dreapta pe o aplicație din grilă sau apasă `Delete`, ca s-o dezinstalezi. Dă clic pe o aplicație ca s-o deschizi sau ca să-i aduci fereastra în față; dă clic din nou ca să parcurgi ciclic ferestrele ei. Files readuce doar o fereastră din spațiul de lucru pe care te afli și în rest deschide una nouă, iar Terminal și Agent pornesc întotdeauna alta, deși o fereastră minimizată revine prima. Clicul din mijloc deschide o fereastră nouă. Trage o pictogramă de-a lungul dock-ului ca s-o muți; tragerea unei aplicații care rulează printre celelalte o păstrează acolo. Dă clic dreapta ca să păstrezi o aplicație în dock, s-o scoți sau să o închizi. Dock-ul rămâne afișat cât timp un spațiu de lucru este gol, iar odată ce spațiul de lucru are o fereastră, se ascunde până când indicatorul ajunge la marginea lui. O fereastră pe ecran complet îl ascunde cu totul. Trage butonul de aplicații către altă margine a ecranului ca să muți dock-ul acolo. Dă clic dreapta pe el pentru _Position_, ca să alegi o margine, și _Layout_, ca să setezi dispunerea implicită așa cum face _Appearance > Workspace Layout_. Poziția se află și sub _Appearance > Dock > Dock Position_, iar `omarchy dock position left` o setează dintr-un terminal. Aplicațiile pe care le păstrezi în dock sunt estompate cât timp nu rulează. Ca să limitezi dock-ul la spațiile de lucru flotante, folosește _Appearance > Dock > Dock Only on Floating_ sau `omarchy dock tiling off`.

Noile spații de lucru și oricare cărora nu le-ai dat o dispunere proprie cu `Super + L` folosesc dispunerea implicită. Schimbarea celei implicite resetează la aceasta fiecare spațiu de lucru fără ferestre, în timp ce unul cu ferestre pe el păstrează dispunerea pe care o are. O fereastră minimizată în dock contează în continuare ca o fereastră pe spațiul de lucru din care a plecat. O alegi sub _Appearance > Workspace Layout_: Tiling, Scrolling sau Floating. `omarchy hyprland workspace layout default scrolling` o setează dintr-un terminal.

### Gruparea ferestrelor

Ferestrele pot fi grupate folosind `Super + G`. Odată ce ești într-un grup, fiecare fereastră pe care o pornești cât timp acesta este activ va aparține grupului. Te poți deplasa între aceste ferestre grupate folosind `Super + Ctrl + Arrow Left/Right` sau `Super + Alt + 1/2/3/4` ca să mergi direct la ferestrele grupate, în ordine.

Poți muta o fereastră în afara grupării cu `Super + Alt + G` sau poți desface întregul grup apăsând din nou `Super + G`. În cele din urmă, poți muta ferestre din afara grupului în el cu `Super + Alt + Arrows`.

### Scoaterea ferestrelor

Poți scoate o fereastră din alocarea ei în spațiul de lucru cu `Super + O`. Asta o va fixa ca fereastră flotantă care te urmează pe orice spațiu de lucru mergi. Excelent pentru playere video și altele asemenea.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Spațiul de lucru scratchpad

Există un spațiu de lucru scratchpad special, de dimensiune completă, care se suprapune peste orice spațiu de lucru pe care te afli în prezent. Accesezi ce este pe el folosind `Super + S` și plasezi ferestre acolo folosind `Super + Alt + S`.

Funcționează bine pentru controale sau un terminal cu care vrei să interacționezi rapid fără să părăsești spațiul de lucru curent.

### Consola Quake

În cele din urmă, există o consolă Quake la jumătate de înălțime care coboară peste orice spațiu de lucru pe care te afli în prezent. O comuți cu `Super + the key above Tab` (accent grav pe layout-urile din US) și plasezi o fereastră acolo folosind `Super + Shift + the key above Tab`.

Prima dată când se deschide, pornește agentul tău implicit sau îți cere să alegi unul dacă n-ai ales încă niciunul. Cât timp consola conține o singură fereastră, coboară ca un panou centrat, în loc să se întindă pe tot ecranul. Pune o a doua aplicație pe ea și revine la lățimea completă, astfel încât cele două să aibă loc să stea una lângă alta.

Ca să muți o fereastră fie de pe scratchpad, fie de pe consolă, trimite-o direct pe alt spațiu de lucru cu ceva de genul `Super + Shift + 1`.

### Ia ceva timp să te obișnuiești!

Durează puțin până te obișnuiești să navighezi pe desktop așa, dar odată ce reușești, va fi greu să te întorci la o experiență tradițională de desktop bazată pe mouse!
