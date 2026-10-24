# Navigare

Totul în Omarchy se face de la tastatură — _TOTUL!_ Când pornește sistemul prima dată, literalmente nu poți face nimic doar cu mouse-ul. Dar poți apăsa `Super + Space` pentru a deschide Meniul Omarchy și, de aici, poți face cam tot.

Dar meniul Omarchy nici măcar nu este gândit să fie modul principal de operare a sistemului în majoritatea timpului. Putem fi mai rapizi de atât! Toate aplicațiile cele mai importante sunt legate direct de taste rapide individuale. Pornești terminalul cu `Super + Return` și un browser cu `Super + Shift + Return`. Încearcă să le faci una după alta și vei vedea magia dispunerii în mozaic din Hyprland în acțiune:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Apoi poți apăsa `Super + J` pentru a le stivui una peste alta, în loc să fie una lângă alta:

 ![navigation-stacked](images/navigation-stacked.webp)

Apasă din nou `Super + J` pentru a le readuce în pozițiile lor una lângă alta. Apoi încearcă `Super + Shift + Arrow Right` în timp ce ești pe browser, pentru a schimba ferestrele între ele.

Acum încearcă `Super + Ctrl + T` pentru a porni monitorul de activitate. Acela va apărea ca o fereastră plutitoare. Îl poți pune în mozaic folosind `Super + T` (și poți apăsa din nou pentru a-l face din nou plutitor). Acum apasă `Super + Shift + F` pentru a deschide managerul de fișiere. Vei avea o dispunere îngrijită în patru:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navighezi între ferestre pentru a o face activă pe cea pe care o vrei cu `Super + Arrow`. Aceasta va muta focalizarea și va duce cursorul în centrul noii aplicații.

Dacă apeși `Super + Shift + 2`, vei muta aplicația focalizată curent pe al doilea spațiu de lucru. `Super + Shift + 1` o aduce înapoi. (Iar `Super + Shift + Alt + 2` va muta aplicația focalizată curent pe al doilea spațiu de lucru, fără să comute la el).

Dacă ții apăsat `Super` și folosești mouse-ul pentru a face clic pe o fereastră, vei putea rearanja locul în care stă. Dacă ții apăsat `Super` și folosești butonul drept al mouse-ului, poți redimensiona liber fereastra.

Închizi o fereastră cu `Super + W` sau `Super + Q` (și închizi toate ferestrele cu `Ctrl + Alt + Delete`).

Poți trece și pe ecran complet cu `Super + F` sau doar pe lățimea completă (păstrând bara de sus) cu `Super + Alt + F` sau pe ecran complet în interiorul unei ferestre cu `Super + Ctrl + F` (bun pentru YouTube!).

### Dispunerea dwindle vs scrolling

Dispunerea implicită din Omarchy se numește dwindle. Ea păstrează vizibile în permanență toate ferestrele pe care le deschizi pe un singur spațiu de lucru, chiar dacă trebuie să le micșoreze.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Dar poți alege și să transformi un spațiu de lucru în dispunerea scrolling, în care ferestrele sunt aliniate una lângă alta, dincolo de marginea vizibilă a ecranului. Transformi un singur spațiu de lucru în această dispunere prin `Super + L`.

Dacă apeși din nou `Super + L`, spațiul de lucru devine plutitor, ferestrele se suprapun liber și le așezi singur, iar o a treia apăsare îl readuce la dwindle. `Super + Alt + L` le parcurge în sens invers. O fereastră care oricum plutește — una pe care ai scos-o cu `Super + T` sau o aplicație care se deschide întotdeauna plutitoare — rămâne plutitoare când spațiul de lucru revine la mozaic. Bara de sus marchează spațiul de lucru pe care te afli cu dispunerea lui: un pătrat pentru dwindle, un cerc pentru scrolling și un triunghi pentru plutitor. Un clic pe acel marcaj comută și el, ciclic, dispunerea.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Alegerea este pentru fiecare spațiu de lucru în parte și rămâne. Așadar, poți păstra spațiul de lucru 1 pe dwindle pentru navigare și spațiul de lucru 2 pe scrolling pentru cod, iar ele vor reveni așa după o repornire.

Dacă vrei să folosești dispunerea scrolling ca implicită, poți seta asta în `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Spații de lucru plutitoare

Un spațiu de lucru plutitor funcționează ca un desktop tradițional: ferestrele se suprapun, iar tu le muți și le dimensionezi singur. Fiecare fereastră primește o bară de titlu în culorile temei tale, cu butoane pentru minimizare, maximizare și închidere. Și `Super + M` minimizează fereastra focalizată. O fereastră minimizată așteaptă în dock; fă clic pe aplicația ei pentru a o readuce. Fă clic pe o fereastră pentru a o aduce în față. Redimensioneaz-o de pe orice margine sau colț. Fă dublu clic pe o bară de titlu pentru a maximiza fereastra, păstrând bara de sus vizibilă, și din nou pentru a-i recupera dimensiunea veche.

Un spațiu de lucru plutitor arată și un dock, cu aplicațiile tale fixate, cu tot ce rulează și cu o grilă cu toate aplicațiile în spatele butonului de aplicații, pe care îl deschid și `Super + Alt + Space`, și _Apps_ din meniul Omarchy. Fă clic dreapta pe o aplicație din grilă sau apasă `Delete` pentru a o dezinstala. Fă clic pe o aplicație pentru a o deschide sau pentru a-i aduce fereastra în față; fă clic din nou pentru a parcurge ciclic ferestrele ei. Clicul mijlociu deschide o fereastră nouă. Trage o pictogramă de-a lungul dockului pentru a o muta; dacă tragi o aplicație care rulează printre celelalte, ea rămâne acolo. Fă clic dreapta pentru a păstra o aplicație în dock, pentru a o scoate sau pentru a o închide. Dockul se dă la o parte din calea unei ferestre pe ecran complet. Fă clic dreapta pe butonul de aplicații pentru a muta dockul pe altă margine sau pentru a-l face să se ascundă până când indicatorul ajunge la marginea lui. Poziția se află și sub _Trigger > Appearance > Dock > Dock Position_, iar `omarchy dock position left` și `omarchy dock autohide on` le setează pe amândouă dintr-un terminal. Aplicațiile pe care le păstrezi în dock sunt estompate cât timp nu rulează.

Spațiile de lucru noi și oricare cărora nu le-ai dat o dispunere proprie cu `Super + L` folosesc dispunerea implicită. Schimbarea celei implicite resetează la ea fiecare spațiu de lucru fără ferestre, în timp ce unul cu ferestre pe el își păstrează dispunerea pe care o are. O fereastră minimizată în dock încă se consideră o fereastră pe spațiul de lucru pe care l-a părăsit. Alege-o sub _Trigger > Appearance > Workspace Layout_: Tiling, Scrolling sau Floating. `omarchy-hyprland-workspace-layout-default scrolling` o setează dintr-un terminal.

### Gruparea ferestrelor

Ferestrele pot fi grupate folosind `Super + G`. Odată ce ești într-un grup, fiecare fereastră pe care o pornești cât timp acela este activ va aparține grupului. Te poți deplasa între aceste ferestre grupate folosind `Super + Ctrl + Arrow Left/Right` sau `Super + Alt + 1/2/3/4` pentru a merge direct la fereastra grupată, în ordine.

Poți scoate o fereastră din grupare cu `Super + Alt + G` sau poți desface întregul grup apăsând din nou `Super + G`. În sfârșit, poți muta ferestre din afara grupului în el cu `Super + Alt + Arrows`.

### Desprinderea ferestrelor

Poți desprinde o fereastră din alocarea ei pe spațiul de lucru cu `Super + O`. Asta o va fixa ca fereastră plutitoare care te urmează pe orice spațiu de lucru mergi. Grozav pentru playere video și altele asemenea.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Spațiul de lucru scratchpad

În sfârșit, există un spațiu de lucru scratchpad special, care coboară peste orice spațiu de lucru pe care te afli în prezent, cam ca o consolă Quake. Comută-l cu `Super + Grave` sau `Super + S` și așază acolo o fereastră folosind `Super + Shift + Grave` sau `Super + Alt + S`.

Funcționează deosebit de bine pentru un terminal care rulează un agent sau pentru comenzi cu care vrei să interacționezi rapid fără să părăsești spațiul de lucru curent. Pentru a muta o fereastră de pe scratchpad, trimite-o direct pe alt spațiu de lucru cu ceva de genul `Super + Shift + 1`.

Cât timp scratchpadul conține o singură fereastră, el coboară ca un panou centrat, în loc să se întindă pe tot ecranul. Pune o a doua aplicație pe el și va reveni la lățimea completă, astfel încât cele două să aibă loc să stea una lângă alta.

### Trebuie să te obișnuiești puțin!

Durează puțin până te obișnuiești să navighezi pe desktop așa, dar odată ce o faci, îți va fi greu să te întorci la o experiență tradițională de desktop, condusă cu mouse-ul!
