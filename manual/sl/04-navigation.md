# Navigacija

Vse v sistemu Omarchy se dogaja prek tipkovnice — _ČISTO VSE!_ Ko se sistem prvič zažene, z miško samo dobesedno ne morete narediti ničesar. Lahko pa pritisnete `Super + Space`, da prikažete meni Omarchy, od tu pa lahko naredite skoraj vse.

Toda meni Omarchy večinoma niti ni namenjen kot glavni način upravljanja sistema. Lahko smo hitrejši od tega! Vse najpomembnejše aplikacije so neposredno vezane na posamezne bližnjice. Terminal zaženete s `Super + Return`, brskalnik pa s `Super + Shift + Return`. Poskusite narediti eno za drugim in videli boste čarobnost ploščičnega razporejanja v Hyprlandu v akciji:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Nato lahko pritisnete `Super + J`, da ju zložite eno na drugo namesto eno ob drugo:

 ![navigation-stacked](images/navigation-stacked.webp)

Znova pritisnite `Super + J`, da ju vrnete v položaj eno ob drugo. Nato medtem ko ste v brskalniku, poskusite `Super + Shift + Arrow Right`, da zamenjate okni.

Zdaj poskusite `Super + Shift + T`, da zaženete Activity monitor. Ta se bo prikazal kot plavajoče okno z naslovno vrstico, za katero ga lahko vlečete, in gumbi za minimiziranje, maksimiziranje in zapiranje. Vsako plavajoče okno jo dobi, kjer koli je. Lahko ga razporedite v ploščice s `Super + T` (in znova pritisnete isto, da spet postane plavajoče). Zdaj pritisnite `Super + Shift + F`, da odprete upravitelja datotek. Imeli boste lično štirismerno postavitev:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Med okni, ki naj bodo aktivna, se pomikate s `Super + Arrow`. To preklopi fokus in premakne kazalec v središče nove aplikacije. Na robu zaslona nadaljuje na monitor na tisti strani.

Če pritisnete `Super + Shift + 2`, boste trenutno fokusirano aplikacijo premaknili na drugi delovni prostor. `Super + Shift + 1` jo premakne nazaj. (In `Super + Shift + Alt + 2` bo trenutno fokusirano aplikacijo premaknila na drugi delovni prostor, ne da bi preklopili nanj).

Z več kot enim monitorjem ima vsak monitor svoje delovne prostore od 1 do 10. `Super + 2` gre na drugi delovni prostor monitorja, na katerem ste, zgornja vrstica vsakega monitorja pa prikazuje njegove delovne prostore in tistega, ki ga prikazuje. `Super + Tab` kroži med delovnimi prostori na monitorju, na katerem ste. `Super + Shift + Ctrl + Arrows` premakne okno, na katerem ste, na monitor v tisti smeri, na delovni prostor, ki ga prikazuje, `Super + Shift + Alt + Arrows` pa premakne delovni prostor, na katerem ste, na monitor v tisti smeri, kjer prevzame isto številko, če je prosta. Monitor obdrži svoje delovne prostore, ko ga izključite: pridružijo se drugemu zaslonu, oštevilčeni za tistimi, ki jih ta že ima, in se vrnejo pod svoje stare številke, ko se monitor vrne.

Če držite `Super` in z miško kliknete na okno, boste lahko preuredili, kje sedi. Če držite `Super` in uporabite desni gumb miške, lahko oknu prosto spreminjate velikost.

Okno zaprete s `Super + W` ali `Super + Q` (in vsa okna zaprete s `Ctrl + Alt + Delete`).

Lahko greste tudi na cel zaslon s `Super + F` ali celo samo na celo širino (pri čemer ohranite zgornjo vrstico) s `Super + Alt + F` ali na cel zaslon znotraj okna s `Super + Ctrl + F` (dobro za YouTube!).

### Postavitev dwindle v primerjavi z drsečo postavitvijo

Privzeta postavitev sistema Omarchy se imenuje dwindle. Vsa okna, ki jih odprete na enem delovnem prostoru, ves čas ohranja vidna, tudi če jih mora zaradi tega zmanjšati.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Lahko pa se odločite tudi, da delovni prostor spremenite v drsečo postavitev, kjer so okna poravnana eno ob drugem, onkraj vidnega roba zaslona. Posamezen delovni prostor v to postavitev spremenite s `Super + L`.

Z vnovičnim pritiskom na `Super + L` delovni prostor postane plavajoč, kjer se okna prosto prekrivajo in jih postavljate sami, tretji pritisk pa ga vrne v dwindle. `Super + Alt + L` gre skozi njih v drugo smer. Okno, ki tako ali tako plava — okno, ki ste ga izvlekli s `Super + T`, ali aplikacija, ki se vedno odpre plavajoče — ostane plavajoče, ko se delovni prostor vrne v ploščično razporejanje. Zgornja vrstica delovni prostor, na katerem ste, označi z njegovo postavitvijo: kvadrat za dwindle, krog za drsečo in trikotnik za plavajočo. Klik na to oznako prav tako kroži med postavitvami, prav tako pa tudi tipka za zaslon na prenosnikih, ki jo imajo.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Izbira je na delovni prostor in ostane. Tako lahko delovni prostor 1 obdržite na dwindle za brskanje in delovni prostor 2 na drseči za kodo, in po ponovnem zagonu se bosta vrnila tako.

Če želite drsečo postavitev uporabiti kot privzeto, lahko to nastavite v `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plavajoči delovni prostori

Plavajoči delovni prostor deluje kot tradicionalno namizje: okna se prekrivajo, vi pa jih premikate in jim spreminjate velikost sami. Vsako okno dobi naslovno vrstico v barvah vaše teme, z gumbi za minimiziranje, maksimiziranje in zapiranje. `Super + M` minimizira tudi fokusirano okno. Minimizirano okno čaka v docku; kliknite njegovo aplikacijo, da ga prinesete nazaj. Kliknite okno, da ga prinesete v ospredje. Velikost mu spreminjajte z katerega koli roba ali kota. Dvokliknite naslovno vrstico, da maksimizirate okno, pri čemer ohranite zgornjo vrstico v pogledu, in znova, da dobite nazaj njegovo staro velikost. Chrome in drugi brskalniki, ki temeljijo na Chromiumu, Disks in Document Viewer preskočijo naslovno vrstico in namesto nje uporabijo svojo lastno glavo; `Super + Alt + F` jih maksimizira, `Super + M` pa jih minimizira.

Vsak delovni prostor ima dock, z vašimi pripetimi aplikacijami, vsem, kar se izvaja, in mrežo vseh aplikacij za gumbom za aplikacije, ki ga odpreta tudi `Super + Alt + Space` in _Apps_ v meniju Omarchy. Z desnim klikom na aplikacijo na mreži ali s pritiskom na `Delete` jo odstranite. Kliknite aplikacijo, da jo odprete ali da njeno okno prinesete v ospredje; kliknite znova, da krožite med njenimi okni. Files prinese nazaj okno samo z delovnega prostora, na katerem ste, sicer pa odpre novo, Terminal in Agent pa vedno zaženeta še eno, čeprav se minimizirano okno vrne najprej. Srednji klik odpre novo okno. Povlecite ikono vzdolž docka, da jo premaknete; če izvajajočo se aplikacijo povlečete med druge, tam ostane. Z desnim klikom aplikacijo obdržite v docku, jo vzamete ven ali jo zaprete. Dock ostane zunaj, medtem ko je delovni prostor prazen, in ko delovni prostor dobi okno, se skrije, dokler kazalec ne doseže njegovega roba. Celozaslonsko okno ga skrije v celoti. Povlecite gumb za aplikacije proti drugemu robu zaslona, da tja premaknete dock. Z desnim klikom nanj za _Position_, da izberete rob, _Layout_, da nastavite privzeto postavitev, kot to naredi _Appearance > Workspace Layout_, in _Visibility_, da dock obdržite vedno vklopljen, da ga prva aplikacija skrije ali da ostane vedno skrit. `omarchy dock visibility always` to nastavi iz terminala. Položaj je tudi pod _Appearance > Dock > Dock Position_, `omarchy dock position left` pa ga nastavi iz terminala. Aplikacije, ki jih obdržite v docku, so zbledele, medtem ko se ne izvajajo. Če želite dock obdržati samo za plavajoče delovne prostore, uporabite _Appearance > Dock > Dock Only on Floating_ ali `omarchy dock tiling off`.

Novi delovni prostori in vsi, ki jim s `Super + L` niste dali lastne postavitve, uporabijo privzeto postavitev. Sprememba privzete ponastavi vsak delovni prostor brez oken nanjo, medtem ko tisti z okni na njem obdrži postavitev, ki jo ima. Okno, minimizirano v dock, še vedno šteje kot okno na delovnem prostoru, ki ga je zapustilo. Izberite jo pod _Appearance > Workspace Layout_: Tiling, Scrolling ali Floating. `omarchy hyprland workspace layout default scrolling` jo nastavi iz terminala.

### Združevanje oken v skupine

Okna je mogoče združiti s `Super + G`. Ko ste v skupini, bo vsako okno, ki ga zaženete, medtem ko je ta aktivna, pripadalo skupini. Med temi združenimi okni se lahko premikate s `Super + Ctrl + Arrow Left/Right` ali s `Super + Alt + 1/2/3/4`, da greste neposredno na združena okna po vrstnem redu.

Okno lahko premaknete iz skupine s `Super + Alt + G` ali razstavite celotno skupino z vnovičnim pritiskom na `Super + G`. Nazadnje lahko okna zunaj skupine premaknete vanjo s `Super + Alt + Arrows`.

### Izvlečenje oken

Okno lahko s `Super + O` izvlečete iz njegove dodelitve delovnemu prostoru. To ga bo pripelo kot plavajoče okno, ki vam sledi, na kateri koli delovni prostor greste. Odlično za video predvajalnike in podobno.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Delovni prostor scratchpad

Obstaja poseben delovni prostor scratchpad v polni velikosti, ki prekriva kateri koli delovni prostor, na katerem ste trenutno. Do tega, kar je na njem, dostopate s `Super + S`, okna pa tja postavljate s `Super + Alt + S`.

Dobro deluje za kontrole ali terminal, s katerim želite hitro komunicirati, ne da bi zapustili trenutni delovni prostor.

### Konzola Quake

Nazadnje obstaja konzola Quake v polovični višini, ki se spusti čez kateri koli delovni prostor, na katerem ste trenutno. Preklopite jo s `Super + the key above Tab` (grave na postavitvah US), okno pa tja postavite s `Super + Shift + the key above Tab`.

Ko se prvič odpre, zažene vašega privzetega agenta ali pa vas prosi, da enega izberete, če ga še niste izbrali. Medtem ko konzola vsebuje eno samo okno, se spusti kot osredinjena plošča, namesto da bi obsegala zaslon. Postavite nanjo drugo aplikacijo in vrnila se bo na polno širino, tako da imata obe prostor, da sedita ena ob drugi.

Če želite okno premakniti s scratchpada ali s konzole, ga pošljite neposredno na drug delovni prostor z nečim, kot je `Super + Shift + 1`.

### Treba se je malo navaditi!

Traja malo časa, da se navadite tako krmariti po svojem namizju, toda ko se boste, se bo težko vrniti k tradicionalni izkušnji namizja, ki ga poganja miška!
