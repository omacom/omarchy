# Navigacija

Vse v sistemu Omarchy se dogaja prek tipkovnice — _VSE!_ Ko se sistem prvič zažene, z miško samo dobesedno ne morete storiti ničesar. Lahko pa pritisnete `Super + Space`, da prikažete meni Omarchy, in od tu lahko storite skoraj vse.

Toda meni Omarchy večino časa niti ni namenjen kot glavni način upravljanja sistema. Lahko smo hitrejši od tega! Vse najpomembnejše aplikacije so vezane neposredno na posamezne bližnjice. Terminal zaženete s `Super + Return`, brskalnik pa s `Super + Shift + Return`. Poskusite storiti eno za drugim in videli boste čarobnost ploščenja v Hyprland v akciji:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Nato lahko pritisnete `Super + J`, da ju zložite eno na drugo namesto drugo poleg druge:

 ![navigation-stacked](images/navigation-stacked.webp)

Znova pritisnite `Super + J`, da ju vrnete v položaj drugo poleg druge. Nato poskusite pritisniti `Super + Shift + Arrow Right`, ko ste v brskalniku, da zamenjate okni.

Zdaj poskusite s `Super + Shift + T`, da zaženete nadzornik dejavnosti. Ta se bo prikazal kot plavajoče okno. Lahko ga ploščičite s `Super + T` (in to znova pritisnete, da spet postane plavajoče). Zdaj pritisnite `Super + Shift + F`, da odprete upravitelja datotek. Imeli boste urejeno štirismerno postavitev:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Med okni, ki naj bodo aktivna, se premikate s `Super + Arrow`. To bo preklopilo fokus in premaknilo kazalec na sredino nove aplikacije. Na robu zaslona se nadaljuje na monitor na tisti strani.

Če pritisnete `Super + Shift + 2`, boste trenutno fokusirano aplikacijo premaknili na drugi delovni prostor. `Super + Shift + 1` jo premakne nazaj. (In `Super + Shift + Alt + 2` bo trenutno fokusirano aplikacijo premaknil na drugi delovni prostor, ne da bi preklopil nanj).

Pri več kot enem monitorju ima vsak monitor svoje delovne prostore od 1 do 10. `Super + 2` gre na drugi delovni prostor monitorja, na katerem ste, zgornja vrstica vsakega monitorja pa prikazuje njegove delovne prostore in tistega, ki ga prikazuje. `Super + Tab` kroži med delovnimi prostori na monitorju, na katerem ste. `Super + Shift + Ctrl + Arrows` premakne okno, na katerem ste, na monitor v tisti smeri, na delovni prostor, ki ga ta prikazuje, `Super + Shift + Alt + Arrows` pa premakne delovni prostor, na katerem ste, na monitor v tisti smeri, kjer prevzame isto številko, če je prosta. Monitor obdrži svoje delovne prostore, ko ga izklopite: pridružijo se delovnim prostorom drugega zaslona, oštevilčeni za tistimi, ki jih ta že ima, in se vrnejo pod svoje stare številke, ko se monitor vrne.

Če držite `Super` in z miško kliknete okno, boste lahko preuredili, kje se nahaja. Če držite `Super` in uporabite desni gumb miške, lahko oknu prosto spreminjate velikost.

Okno zaprete s `Super + W` ali `Super + Q` (vsa okna pa zaprete s `Ctrl + Alt + Delete`).

Lahko greste tudi na cel zaslon s `Super + F` ali celo samo na celotno širino (pri čemer obdržite zgornjo vrstico) s `Super + Alt + F` ali na cel zaslon znotraj okna s `Super + Ctrl + F` (dobro za YouTube!).

### Postavitev dwindle v primerjavi z drsno postavitvijo

Privzeta postavitev sistema Omarchy se imenuje dwindle. Vsa okna, ki jih odprete na enem delovnem prostoru, ves čas ohranja vidna, tudi če jih mora za to pomanjšati.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Lahko pa se odločite tudi, da delovni prostor spremenite v drsno postavitev, kjer so okna poravnana drugo poleg drugega, onkraj vidnega roba zaslona. Posamezen delovni prostor v to postavitev spremenite s `Super + L`.

Ponoven pritisk na `Super + L` delovni prostor spremeni v plavajočega, kjer se okna prosto prekrivajo in jih postavljate sami, tretji pritisk pa ga vrne v dwindle. `Super + Alt + L` gre skozi njih v drugo smer. Okno, ki tako ali tako plava — tisto, ki ste ga izskočili s `Super + T`, ali aplikacija, ki se vedno odpre plavajoče — ostane plavajoče, ko se delovni prostor vrne v ploščenje. Zgornja vrstica delovni prostor, na katerem ste, označi z njegovo postavitvijo: kvadrat za dwindle, krog za drsno in trikotnik za plavajočo. Klik na to oznako prav tako kroži med postavitvami.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Izbira je na delovni prostor in se ohrani. Tako lahko delovni prostor 1 obdržite na dwindle za brskanje in delovni prostor 2 na drsni za kodo, po ponovnem zagonu pa se bosta vrnila na tak način.

Če želite drsno postavitev uporabljati kot privzeto, lahko to nastavite v `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plavajoči delovni prostori

Plavajoči delovni prostor deluje kot tradicionalno namizje: okna se prekrivajo, vi pa jih premikate in jim spreminjate velikost sami. Vsako okno dobi naslovno vrstico v barvah vaše teme, z gumbi za minimiziranje, maksimiziranje in zapiranje. `Super + M` minimizira tudi fokusirano okno. Minimizirano okno čaka v doku; kliknite njegovo aplikacijo, da ga vrnete. Kliknite okno, da ga prinesete v ospredje. Velikost mu spreminjajte s katerega koli roba ali kota. Dvokliknite naslovno vrstico, da maksimizirate okno, pri čemer zgornja vrstica ostane v pogledu, in znova, da dobite nazaj njegovo staro velikost.

Plavajoči delovni prostor prikazuje tudi dok, z vašimi pripetimi aplikacijami, vsemi, ki se izvajajo, in mrežo vseh aplikacij za gumbom za aplikacije, ki ga odpreta tudi `Super + Alt + Space` in _Aplikacije_ v meniju Omarchy. Z desno miškino tipko kliknite aplikacijo na mreži ali pritisnite `Delete`, da jo odstranite. Kliknite aplikacijo, da jo odprete ali da njeno okno prinesete v ospredje; kliknite znova, da krožite med njenimi okni. Srednji klik odpre novo okno. Povlecite ikono vzdolž doka, da jo premaknete; če aplikacijo, ki se izvaja, povlečete med druge, tam ostane. Kliknite z desno miškino tipko, da aplikacijo obdržite v doku, jo vzamete iz njega ali jo zaprete. Dok se umakne celozaslonskemu oknu. Kliknite gumb za aplikacije z desno miškino tipko, da dok premaknete na drug rob ali da se skriva, dokler kazalec ne doseže njegovega roba. Položaj je tudi pod _Videz > Dok > Položaj doka_, `omarchy dock position left` in `omarchy dock autohide on` pa oboje nastavita iz terminala. Aplikacije, ki jih obdržite v doku, so zbledele, medtem ko se ne izvajajo.

Novi delovni prostori in vsi, ki jim s `Super + L` niste dali lastne postavitve, uporabljajo privzeto postavitev. Sprememba privzete postavitve ponastavi vsak delovni prostor brez oken nanjo, medtem ko tisti z okni na njem obdrži postavitev, ki jo ima. Okno, minimizirano v dok, še vedno šteje kot okno na delovnem prostoru, ki ga je zapustilo. Izberite jo pod _Videz > Postavitev delovnega prostora_: Ploščenje, Drsna ali Plavajoča. `omarchy-hyprland-workspace-layout-default scrolling` jo nastavi iz terminala.

### Združevanje oken v skupine

Okna je mogoče združiti v skupine s `Super + G`. Ko ste v skupini, bo vsako okno, ki ga zaženete, medtem ko je ta aktivna, pripadalo skupini. Med temi združenimi okni se lahko premikate s `Super + Ctrl + Arrow Left/Right` ali s `Super + Alt + 1/2/3/4`, da greste neposredno na združeno okno po vrsti.

Okno lahko premaknete iz skupine s `Super + Alt + G` ali razstavite celotno skupino tako, da znova pritisnete `Super + G`. Nazadnje lahko okna izven skupine premaknete vanjo s `Super + Alt + Arrows`.

### Izskakanje oken

Okno lahko izskočite iz njegove dodelitve delovnemu prostoru s `Super + O`. To ga bo pripelo kot plavajoče okno, ki vam sledi na kateri koli delovni prostor, na katerega greste. Odlično za video predvajalnike in podobno.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Delovni prostor beležke

Obstaja poseben delovni prostor beležke polne velikosti, ki prekriva kateri koli delovni prostor, na katerem ste trenutno. Do tega, kar je na njem, dostopate s `Super + S`, okna pa tja postavljate s `Super + Alt + S`.

Dobro deluje za kontrole ali terminal, s katerim želite hitro komunicirati, ne da bi zapustili trenutni delovni prostor.

### Konzola Quake

Nazadnje je tu še konzola Quake polovične višine, ki se spusti čez kateri koli delovni prostor, na katerem ste trenutno. Preklopite jo s `Super + Grave`, okno pa tja postavite s `Super + Shift + Grave`.

Odpre se z vašim privzetim agentom, pripravljenim na delo. Medtem ko konzola vsebuje eno samo okno, se spusti kot osredinjena plošča, namesto da bi segla čez zaslon. Postavite nanjo drugo aplikacijo in se vrne na celotno širino, tako da imata obe prostor, da sedita druga poleg druge.

Če želite okno premakniti z beležke ali konzole, ga pošljite neposredno na drug delovni prostor z nečim, kot je `Super + Shift + 1`.

### Nekaj časa traja, da se privadite!

Traja malo časa, da se privadite na takšno navigacijo po namizju, toda ko se boste, se bo težko vrniti na tradicionalno izkušnjo namizja, ki jo poganja miška!
