# Navigacija

Vse v Omarchyju se dogaja prek tipkovnice — _VSE!_ Ko se sistem prvič zažene, z miško samo dobesedno ne morete storiti ničesar. Lahko pa pritisnete `Super + Space`, da prikažete Meni Omarchy, in od tu lahko storite skoraj vse.

Toda meni Omarchy večinoma sploh ni namenjen kot glavni način upravljanja sistema. Lahko smo hitrejši od tega! Vse najpomembnejše aplikacije so vezane neposredno na posamezne bližnjice. Terminal zaženete s `Super + Return`, brskalnik pa s `Super + Shift + Return`. Poskusite storiti eno za drugim in videli boste čarobnost Hyprlandovega tlakovanja v akciji:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Nato lahko pritisnete `Super + J`, da ju zložite eno na drugo namesto eno ob drugo:

 ![navigation-stacked](images/navigation-stacked.webp)

Znova pritisnite `Super + J`, da ju vrnete v položaj eno ob drugem. Nato v brskalniku poskusite `Super + Shift + Arrow Right`, da zamenjate okni.

Zdaj poskusite `Super + Shift + T`, da zaženete nadzornik dejavnosti. Ta se bo prikazal kot lebdeče okno. Lahko ga postavite v tlakovanje s `Super + T` (in to pritisnete znova, da spet postane lebdeče). Zdaj pritisnite `Super + Shift + F`, da odprete upravitelj datotek. Imeli boste lično štirismerno postavitev:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Med okni, ki želite, da je aktivno, se pomikate s `Super + Arrow`. To bo preklopilo fokus in premaknilo kazalec v središče nove aplikacije. Na robu zaslona se nadaljuje na monitor na tisti strani.

Če pritisnete `Super + Shift + 2`, boste trenutno fokusirano aplikacijo premaknili na drugi delovni prostor. `Super + Shift + 1` jo premakne nazaj. (`Super + Shift + Alt + 2` pa bo trenutno fokusirano aplikacijo premaknil na drugi delovni prostor, ne da bi preklopili nanj).

Pri več kot enem monitorju ima vsak monitor svojih delovnih prostorov od 1 do 10. `Super + 2` gre na drugi delovni prostor monitorja, na katerem ste, zgornja vrstica vsakega monitorja pa prikazuje njegove delovne prostore in tistega, ki ga prikazuje. `Super + Tab` kroži med delovnimi prostori na monitorju, na katerem ste. `Super + Shift + Ctrl + Arrows` premakne okno, na katerem ste, na monitor v tisti smeri, na delovni prostor, ki ga ta prikazuje, `Super + Shift + Alt + Arrows` pa premakne delovni prostor, na katerem ste, na monitor v tisti smeri, kjer prevzame isto številko, če je prosta. Monitor obdrži svoje delovne prostore, ko ga izključite: pridružijo se delovnim prostorom drugega zaslona, oštevilčeni za tistimi, ki jih ta že ima, in se vrnejo pod svoje stare številke, ko se monitor vrne.

Če držite `Super` in z miško kliknete okno, boste lahko preuredili, kje je postavljeno. Če držite `Super` in uporabite desni gumb miške, lahko oknu prosto spreminjate velikost.

Okno zaprete s `Super + W` ali `Super + Q` (vsa okna pa zaprete s `Ctrl + Alt + Delete`).

Lahko greste tudi na cel zaslon s `Super + F` ali celo le na celo širino (pri čemer obdržite zgornjo vrstico) s `Super + Alt + F` ali na cel zaslon znotraj okna s `Super + Ctrl + F` (dobro za YouTube!).

### Postavitev dwindle v primerjavi z drsno postavitvijo

Privzeta postavitev v Omarchyju se imenuje dwindle. Vsa okna, ki jih odprete na enem delovnem prostoru, ves čas ohranja vidna, tudi če jih mora zaradi tega zmanjšati.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Lahko pa se tudi odločite, da delovni prostor spremenite v drsno postavitev, kjer so okna postavljena eno ob drugem onkraj vidnega roba zaslona. Posamezen delovni prostor v to postavitev spremenite s `Super + L`.

Če znova pritisnete `Super + L`, delovni prostor postane lebdeč, kjer se okna prosto prekrivajo in jih postavite sami, tretji pritisk pa ga vrne v dwindle. `Super + Alt + L` gre skozi nje v drugo smer. Okno, ki tako ali tako lebdi — tisto, ki ste ga iztaknili s `Super + T`, ali aplikacija, ki se vedno odpre lebdeče — ostane lebdeče, ko se delovni prostor vrne v tlakovanje. Zgornja vrstica delovni prostor, na katerem ste, označuje z njegovo postavitvijo: kvadrat za dwindle, krog za drsno in trikotnik za lebdeče. Klik na to oznako tudi kroži med postavitvami, prav tako pa tipka za zaslon na prenosnikih, ki jo imajo.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Izbira velja za posamezen delovni prostor in ostane. Tako lahko delovni prostor 1 obdržite na dwindle za brskanje in delovni prostor 2 na drsni postavitvi za kodo, po ponovnem zagonu pa se bosta vrnila takšna.

Če želite drsno postavitev uporabljati kot privzeto, lahko to nastavite v `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Lebdeči delovni prostori

Lebdeči delovni prostor deluje kot tradicionalno namizje: okna se prekrivajo, premikate in velikost jim spreminjate sami. Vsako okno dobi naslovno vrstico v barvah vaše teme, z gumbi za minimiziranje, maksimiziranje in zapiranje. `Super + M` minimizira tudi fokusirano okno. Minimizirano okno čaka v docku; kliknite njegovo aplikacijo, da ga prikličete nazaj. Kliknite okno, da ga postavite v ospredje. Velikost mu spreminjajte s katerega koli roba ali vogala. Dvokliknite naslovno vrstico, da okno maksimizirate, medtem ko zgornja vrstica ostane vidna, in znova, da dobite nazaj njegovo staro velikost. Chrome in drugi brskalniki na osnovi Chromiuma, Disks in Document Viewer preskočijo naslovno vrstico in namesto nje uporabljajo svojo glavo; `Super + Alt + F` jih maksimizira, `Super + M` pa jih minimizira.

Lebdeči delovni prostor prikazuje tudi dock, z vašimi pripetimi aplikacijami, vsemi, ki se izvajajo, in mrežo vseh aplikacij za gumbom za aplikacije, ki ga odpreta tudi `Super + Alt + Space` in _Apps_ v meniju Omarchy. Z desno tipko kliknite aplikacijo v mreži ali pritisnite `Delete`, da jo odstranite. Kliknite aplikacijo, da jo odprete ali da njeno okno postavite v ospredje; kliknite znova, da krožite med njenimi okni. Files prikliče nazaj le okno iz delovnega prostora, na katerem ste, sicer pa odpre novo, Terminal in Agent pa vedno zaženeta drugo, čeprav se minimizirano okno vrne prvo. Srednji klik odpre novo okno. Povlecite ikono vzdolž docka, da jo premaknete; če delujočo aplikacijo povlečete med druge, tam ostane. Z desno tipko kliknite, da aplikacijo obdržite v docku, jo vzamete iz njega ali jo zaprete. Dock se umakne celozaslonskemu oknu. Z desno tipko kliknite gumb za aplikacije, da dock premaknete na drug rob ali da se skriva, dokler kazalec ne doseže njegovega roba. Položaj je tudi pod _Appearance > Dock > Dock Position_, `omarchy dock position left` in `omarchy dock autohide on` pa oboje nastavita iz terminala. Aplikacije, ki jih obdržite v docku, so zbledele, medtem ko se ne izvajajo.

Novi delovni prostori in vsi, ki jim s `Super + L` niste dali lastne postavitve, uporabljajo privzeto postavitev. Sprememba privzete postavitve vsak delovni prostor brez oken ponastavi nanjo, tisti z okni na njem pa obdrži postavitev, ki jo ima. Okno, minimizirano v dock, še vedno šteje kot okno na delovnem prostoru, ki ga je zapustilo. Izberite jo pod _Appearance > Workspace Layout_: Tiling, Scrolling ali Floating. `omarchy hyprland workspace layout default scrolling` jo nastavi iz terminala.

### Združevanje oken v skupine

Okna lahko združite v skupino s `Super + G`. Ko ste v skupini, bo vsako okno, ki ga zaženete, medtem ko je ta aktivna, pripadalo skupini. Med temi združenimi okni se lahko premikate s `Super + Ctrl + Arrow Left/Right` ali s `Super + Alt + 1/2/3/4`, da greste neposredno na združena okna po vrsti.

Okno lahko iz združevanja premaknete s `Super + Alt + G` ali pa celo skupino razstavite tako, da znova pritisnete `Super + G`. Na koncu lahko okna zunaj skupine premaknete vanjo s `Super + Alt + Arrows`.

### Iztaknjenje oken

Okno lahko s `Super + O` iztaknete iz njegove dodelitve delovnemu prostoru. S tem ga boste pripeli kot lebdeče okno, ki vam sledi na kateri koli delovni prostor, na katerega greste. Odlično za predvajalnike videa in podobno.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Delovni prostor Scratchpad

Obstaja poseben delovni prostor scratchpad v polni velikosti, ki prekriva kateri koli delovni prostor, na katerem ste trenutno. Do tega, kar je na njem, dostopate s `Super + S`, okna pa tja postavljate s `Super + Alt + S`.

Dobro deluje za kontrolnike ali terminal, s katerim želite hitro komunicirati, ne da bi zapustili trenutni delovni prostor.

### Konzola Quake

Na koncu je tu še konzola Quake s polovično višino, ki se spusti čez kateri koli delovni prostor, na katerem ste trenutno. Preklapljate jo s `Super + Grave`, okno pa tja postavite s `Super + Shift + Grave`.

Ko se prvič odpre, zažene vašega privzetega agenta ali pa vas prosi, da enega izberete, če ga še niste izbrali. Medtem ko je v konzoli eno samo okno, se spusti kot osredinjen panel, namesto da bi se raztegnila čez zaslon. Postavite nanjo drugo aplikacijo in vrnila se bo na celo širino, tako da imata obe prostor, da sedita ena ob drugi.

Če želite okno premakniti s scratchpada ali s konzole, ga pošljite neposredno na drug delovni prostor s čim, kot je `Super + Shift + 1`.

### Malo se je treba navaditi!

Traja nekaj časa, da se navadite na takšno navigacijo po namizju, toda ko se, se bo težko vrniti k tradicionalni izkušnji namizja, ki jo poganja miška!
