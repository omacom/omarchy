# Navigacija

Vse v Omarchyju se dogaja prek tipkovnice — _VSE!_ Ko se sistem prvič zažene, z miško samo dobesedno ne morete storiti ničesar. Lahko pa pritisnete `Super + Space`, da prikažete meni Omarchy, in od tu lahko storite skoraj vse.

Toda meni Omarchy večinoma niti ni namenjen temu, da bi bil glavni način upravljanja sistema. Lahko smo hitrejši od tega! Vse najpomembnejše aplikacije so neposredno vezane na posamezne bližnjice na tipkovnici. Terminal zaženete s `Super + Return`, brskalnik pa s `Super + Shift + Return`. Poskusite storiti eno za drugo in videli boste čarobnost Hyprlandovega razporejanja v ploščice v akciji:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Nato lahko pritisnete `Super + J`, da ju zložite eno na drugo namesto eno ob drugo:

 ![navigation-stacked](images/navigation-stacked.webp)

Znova pritisnite `Super + J`, da ju vrnete v položaj eno ob drugi. Nato medtem, ko ste v brskalniku, poskusite `Super + Shift + Arrow Right`, da zamenjate okni.

Zdaj poskusite `Super + Shift + T`, da zaženete nadzornik aktivnosti. Ta se bo prikazal kot lebdeče okno z naslovno vrstico, za katero ga lahko vlečete, in gumbi za minimiziranje, maksimiziranje in zapiranje. Vsako lebdeče okno jo dobi, kjerkoli je. Razporedite ga lahko v ploščice z `Super + T` (in to znova pritisnete, da spet postane lebdeče). Zdaj pritisnite `Super + Shift + F`, da odprete upravitelja datotek. Imeli boste lepo štirismerno postavitev:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Med okni, ki želite, da je aktivno, se pomikate s `Super + Arrow`. S tem preklopite fokus in premaknete kazalec v središče nove aplikacije. Na robu zaslona se nadaljuje na monitor na tisti strani.

Če pritisnete `Super + Shift + 2`, boste trenutno fokusirano aplikacijo premaknili na drugi delovni prostor. `Super + Shift + 1` jo premakne nazaj. (In `Super + Shift + Alt + 2` bo trenutno fokusirano aplikacijo premaknil na drugi delovni prostor, ne da bi preklopil nanj).

Pri več kot enem monitorju ima vsak monitor svojih delovnih prostorov od 1 do 10. `Super + 2` gre na drugi delovni prostor monitorja, na katerem ste, zgornja vrstica vsakega monitorja pa prikazuje njegove delovne prostore in tistega, ki ga prikazuje. `Super + Tab` kroži skozi delovne prostore na monitorju, na katerem ste. `Super + Shift + Ctrl + Arrows` premakne okno, na katerem ste, na monitor v tisti smeri, na delovni prostor, ki ga ta prikazuje, in `Super + Shift + Alt + Arrows` premakne delovni prostor, na katerem ste, na monitor v tisti smeri, kjer prevzame isto številko, če je prosta. Monitor obdrži svoje delovne prostore, ko ga odklopite: pridružijo se delovnim prostorom drugega zaslona, oštevilčeni za tistimi, ki jih ta že ima, in se vrnejo pod svoje stare številke, ko se monitor vrne.

Če držite `Super` in z miško kliknete na okno, boste lahko preuredili, kje sedi. Če držite `Super` in uporabite desni gumb na miški, lahko okno prosto spreminjate po velikosti.

Okno zaprete s `Super + W` ali `Super + Q` (in zaprete vsa okna s `Ctrl + Alt + Delete`).

Lahko greste tudi na cel zaslon s `Super + F` ali celo samo na celotno širino (pri čemer obdržite zgornjo vrstico) s `Super + Alt + F` ali na cel zaslon znotraj okna s `Super + Ctrl + F` (dobro za YouTube!).

### Postavitev dwindle v primerjavi z drsečo postavitvijo

Privzeta postavitev v Omarchyju se imenuje dwindle. Vsa okna, ki jih odprete na enem delovnem prostoru, ohranja vidna ves čas, tudi če jih mora zaradi tega zmanjšati.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Lahko pa se tudi odločite, da delovni prostor spremenite v drsečo postavitev, kjer so okna postavljena eno ob drugem, čez vidni rob zaslona. Posamezni delovni prostor v to postavitev spremenite prek `Super + L`.

Če znova pritisnete `Super + L`, delovni prostor postane lebdeč, kjer se okna prosto prekrivajo in jih postavljate sami, tretji pritisk pa ga vrne v dwindle. `Super + Alt + L` gre skozi njih v drugo smer. Okno, ki tako ali tako lebdi — tisto, ki ste ga izskočili s `Super + T`, ali aplikacija, ki se vedno odpre lebdeča — ostane lebdeče, ko se delovni prostor vrne v razporejanje v ploščice. Zgornja vrstica delovni prostor, na katerem ste, označi z njegovo postavitvijo: kvadrat za dwindle, krog za drsečo in trikotnik za lebdečo. Klik na to oznako prav tako kroži med postavitvami, enako pa stori tudi tipka za zaslon na prenosnikih, ki jo imajo.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Izbira je na delovni prostor in se obdrži. Tako lahko delovni prostor 1 obdržite na dwindle za brskanje in delovni prostor 2 na drseči za kodo, in po ponovnem zagonu se bosta vrnila tako.

Če želite drsečo postavitev uporabiti kot privzeto, lahko to nastavite v `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Lebdeči delovni prostori

Lebdeči delovni prostor deluje kot tradicionalno namizje: okna se prekrivajo, vi pa jih premikate in jim spreminjate velikost sami. Vsako okno dobi naslovno vrstico v barvah vaše teme, z gumbi za minimiziranje, maksimiziranje in zapiranje. `Super + M` prav tako minimizira fokusirano okno. Minimizirano okno čaka v doku; kliknite njegovo aplikacijo, da ga prinesete nazaj. Kliknite okno, da ga prinesete v ospredje. Spremenite mu velikost s kateregakoli roba ali kota. Dvokliknite naslovno vrstico, da maksimizirate okno, pri čemer zgornja vrstica ostane vidna, in znova, da dobite nazaj njegovo staro velikost. Chrome in drugi brskalniki na osnovi Chromiuma, Disks in Document Viewer preskočijo naslovno vrstico in namesto nje uporabijo svojo lastno glavo; `Super + Alt + F` jih maksimizira in `Super + M` jih minimizira.

Vsak delovni prostor ima dok s pripetimi aplikacijami, vsem, kar se izvaja, in mrežo vseh aplikacij za gumbom za aplikacije, ki ga prav tako odpreta `Super + Alt + Space` in _Apps_ v meniju Omarchy. Z desno tipko kliknite aplikacijo na mreži ali pritisnite `Delete`, da jo odstranite. Kliknite aplikacijo, da jo odprete ali da prinesete njeno okno v ospredje; kliknite znova, da krožite skozi njena okna. Files prinese nazaj le okno z delovnega prostora, na katerem ste, sicer pa odpre novo, Terminal in Agent pa vedno zaženeta drugo, čeprav se minimizirano okno vrne najprej. Klik s srednjim gumbom odpre novo okno. Povlecite ikono vzdolž doka, da jo premaknete; če aplikacijo, ki se izvaja, povlečete med druge, tam ostane. Kliknite z desno tipko, da aplikacijo obdržite v doku, jo vzamete iz njega ali jo zaprete. Dok ostane zunaj, dokler je delovni prostor prazen, in ko delovni prostor dobi okno, se skrije, dokler kazalec ne doseže njegovega roba. Celozaslonsko okno ga skrije v celoti. Gumb za aplikacije povlecite proti drugemu robu zaslona, da tja premaknete dok. Z desno tipko ga kliknite za _Position_, da izberete rob, in _Layout_, da nastavite privzeto postavitev, kot to stori _Appearance > Workspace Layout_. Položaj je tudi pod _Appearance > Dock > Dock Position_, in `omarchy dock position left` ga nastavi iz terminala. Aplikacije, ki jih obdržite v doku, so zbledele, dokler se ne izvajajo. Če želite dok omejiti na lebdeče delovne prostore, uporabite _Appearance > Dock > Dock Only on Floating_ ali `omarchy dock tiling off`.

Novi delovni prostori in vsi, ki jim s `Super + L` niste dali lastne postavitve, uporabijo privzeto postavitev. Spreminjanje privzete postavitve na to ponastavi vsak delovni prostor brez oken, tisti z okni na njem pa obdrži postavitev, ki jo ima. Okno, minimizirano v dok, še vedno šteje kot okno na delovnem prostoru, ki ga je zapustilo. Izberete jo pod _Appearance > Workspace Layout_: Ploščična, Drseča ali Lebdeča. `omarchy hyprland workspace layout default scrolling` jo nastavi iz terminala.

### Združevanje oken v skupine

Okna lahko združite v skupine z `Super + G`. Ko ste enkrat v skupini, bo vsako okno, ki ga zaženete, medtem ko je ta aktivna, pripadalo skupini. Med temi združenimi okni se lahko premikate z `Super + Ctrl + Arrow Left/Right` ali `Super + Alt + 1/2/3/4`, da greste neposredno na združena okna po vrstnem redu.

Okno lahko premaknete iz skupine s `Super + Alt + G` ali celotno skupino razstavite tako, da znova pritisnete `Super + G`. Nazadnje lahko okna zunaj skupine premaknete vanjo s `Super + Alt + Arrows`.

### Izskakovanje oken

Okno lahko izskočite iz njegove dodelitve delovnemu prostoru s `Super + O`. To ga bo pripelo kot lebdeče okno, ki vam sledi na katerikoli delovni prostor greste. Odlično za predvajalnike videa in podobno.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Delovni prostor scratchpad

Obstaja poseben delovni prostor scratchpad v polni velikosti, ki prekriva katerikoli delovni prostor, na katerem ste trenutno. Do tega, kar je na njem, dostopate z `Super + S`, okna pa tja postavljate z `Super + Alt + S`.

Dobro deluje za kontrolnike ali terminal, s katerim želite hitro komunicirati, ne da bi zapustili trenutni delovni prostor.

### Konzola Quake

Nazadnje obstaja konzola Quake v polovični višini, ki se spusti čez katerikoli delovni prostor, na katerem ste trenutno. Preklopite jo s `Super + the key above Tab` (grave na postavitvah US), okno pa tja postavite z `Super + Shift + the key above Tab`.

Ko se prvič odpre, zažene vašega privzetega agenta ali pa vas prosi, da enega izberete, če ga še niste izbrali. Medtem ko konzola vsebuje eno samo okno, se spusti kot centrirana plošča, namesto da bi se raztezala čez zaslon. Nanjo postavite drugo aplikacijo in vrne se na celotno širino, tako da imata obe prostor, da sedita ena ob drugi.

Če želite okno premakniti s scratchpada ali s konzole, ga pošljite neposredno na drug delovni prostor z nečim, kot je `Super + Shift + 1`.

### Nekaj se je treba navaditi!

Traja nekaj časa, da se navadite tako krmariti po svojem namizju, toda ko se, se bo težko vrniti k tradicionalni izkušnji namizja, ki ga poganja miška!
