# Navigacija

Vse v sistemu Omarchy se dogaja prek tipkovnice — _VSE!_ Ko se sistem prvič zažene, z miško samo dobesedno ne morete storiti ničesar. Lahko pa pritisnete `Super + Space`, da prikažete meni Omarchy, in od tu lahko storite skoraj vse.

Toda meni Omarchy večino časa niti ni namenjen temu, da bi bil glavni način upravljanja sistema. Lahko smo hitrejši od tega! Vse najpomembnejše aplikacije so neposredno vezane na posamezne bližnjice. Terminal zaženete s `Super + Return`, brskalnik pa s `Super + Shift + Return`. Poskusite storiti eno za drugim in videli boste čarobnost polaganja ploščic v sistemu Hyprland v akciji:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Nato lahko pritisnete `Super + J`, da ju zložite eno na drugo namesto eno ob drugo:

 ![navigation-stacked](images/navigation-stacked.webp)

Pritisnite `Super + J` znova, da ju vrnete v položaja eno ob drugem. Nato poskusite `Super + Shift + Arrow Right`, medtem ko ste v brskalniku, da zamenjate okni.

Zdaj poskusite `Super + Shift + T`, da zaženete nadzornik dejavnosti. Ta se bo prikazal kot lebdeče okno. Lahko ga položite kot ploščico z uporabo `Super + T` (in to znova pritisnete, da spet postane lebdeče). Zdaj pritisnite `Super + Shift + F`, da odprete upravitelja datotek. Imeli boste lično štirismerno postavitev:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Med okni, ki jih želite aktivirati, se pomikate s `Super + Arrow`. To bo preklopilo fokus in premaknilo kazalec na sredino nove aplikacije. Na robu zaslona se nadaljuje na zaslon na tisti strani.

Če pritisnete `Super + Shift + 2`, boste trenutno fokusirano aplikacijo premaknili na drugi delovni prostor. `Super + Shift + 1` jo premakne nazaj. (In `Super + Shift + Alt + 2` bo trenutno fokusirano aplikacijo premaknil na drugi delovni prostor, ne da bi preklopili nanj).

Pri več kot enem zaslonu ima vsak zaslon svoje delovne prostore od 1 do 10. `Super + 2` gre na drugi delovni prostor zaslona, na katerem ste, zgornja vrstica vsakega zaslona pa prikazuje njegove delovne prostore in tistega, ki ga prikazuje. `Super + Tab` kroži med delovnimi prostori na zaslonu, na katerem ste. `Super + Shift + Ctrl + Arrows` premakne okno, na katerem ste, na zaslon v tisti smeri, na delovni prostor, ki ga ta prikazuje, `Super + Shift + Alt + Arrows` pa premakne delovni prostor, na katerem ste, na zaslon v tisti smeri, kjer prevzame isto številko, če je prosta. Zaslon obdrži svoje delovne prostore, ko ga izključite: pridružijo se delovnim prostorom drugega zaslona, oštevilčeni za tistimi, ki jih ta že ima, in se vrnejo pod svoje stare številke, ko se zaslon vrne.

Če držite `Super` in z miško kliknete okno, ga boste lahko prerazporedili, kjer sedi. Če držite `Super` in uporabite desni gumb miške, lahko oknu prosto spreminjate velikost.

Okno zaprete s `Super + W` ali `Super + Q` (vsa okna pa zaprete s `Ctrl + Alt + Delete`).

Lahko greste tudi na cel zaslon s `Super + F` ali celo samo na celotno širino (z ohranitvijo zgornje vrstice) s `Super + Alt + F` ali na cel zaslon znotraj okna s `Super + Ctrl + F` (dobro za YouTube!).

### Dwindle v primerjavi s postavitvijo scrolling

Privzeta postavitev v sistemu Omarchy se imenuje dwindle. Vsa okna, ki jih odprete na enem delovnem prostoru, ohranja vidna ves čas, tudi če jih mora zaradi tega pomanjšati.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Lahko pa se tudi odločite, da delovni prostor spremenite v postavitev scrolling, kjer so okna postavljena eno ob drugo, onkraj vidnega roba zaslona. En sam delovni prostor v to postavitev spremenite s `Super + L`.

Ponovni pritisk na `Super + L` delovni prostor spremeni v lebdečega, kjer se okna prosto prekrivajo in jih postavite sami, tretji pritisk pa ga vrne v dwindle. `Super + Alt + L` gre skozi nje v nasprotni smeri. Okno, ki vseeno lebdi — tisto, ki ste ga izstavili s `Super + T`, ali aplikacija, ki se vedno odpre lebdeča — ostane lebdeče, ko se delovni prostor vrne v polaganje ploščic. Zgornja vrstica delovni prostor, na katerem ste, označuje z njegovo postavitvijo: kvadrat za dwindle, krog za scrolling in trikotnik za lebdečo. Klik na to oznako prav tako kroži med postavitvami.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Izbira je na delovni prostor in ostane. Tako lahko delovni prostor 1 ohranite na dwindle za brskanje, delovni prostor 2 pa na scrolling za kodo, in po ponovnem zagonu se bosta vrnila tako.

Če želite postavitev scrolling uporabljati kot privzeto, lahko to nastavite v `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Lebdeči delovni prostori

Lebdeči delovni prostor deluje kot tradicionalno namizje: okna se prekrivajo, vi pa jih premikate in jim sami spreminjate velikost. Vsako okno dobi naslovno vrstico v barvah vaše teme, z gumbi za minimiziranje, maksimiranje in zapiranje. Tudi `Super + M` minimizira fokusirano okno. Minimizirano okno čaka v doku; kliknite njegovo aplikacijo, da ga vrnete. Kliknite okno, da ga prinesete v ospredje. Velikost mu spreminjajte s katerega koli roba ali vogala. Dvokliknite naslovno vrstico, da maksimirate okno, pri čemer zgornja vrstica ostane vidna, in znova, da dobite nazaj njegovo staro velikost. Chrome in drugi brskalniki, ki temeljijo na Chromiumu, Disks in Document Viewer preskočijo naslovno vrstico in namesto nje uporabljajo svojo glavo; `Super + Alt + F` jih maksimira, `Super + M` pa jih minimizira.

Lebdeči delovni prostor prikazuje tudi dok, z vašimi pripetimi aplikacijami, vsem, kar teče, in mrežo vseh aplikacij za gumbom za aplikacije, ki ga prav tako odpreta `Super + Alt + Space` in _Aplikacije_ v meniju Omarchy. Z desno miškino tipko kliknite aplikacijo na mreži ali pritisnite `Delete`, da jo odstranite. Kliknite aplikacijo, da jo odprete ali da njeno okno prinesete v ospredje; kliknite znova, da krožite med njenimi okni. Srednji klik odpre novo okno. Ikono povlecite vzdolž doka, da jo premaknete; če aplikacijo, ki teče, povlečete med druge, tam ostane. Z desno miškino tipko kliknite, da aplikacijo obdržite v doku, jo odstranite iz njega ali jo zaprete. Dok se umakne celozaslonskemu oknu. Z desno miškino tipko kliknite gumb za aplikacije, da dok premaknete na drug rob ali da se skrije, dokler kazalec ne doseže njegovega roba. Položaj je tudi pod _Videz > Dok > Položaj doka_, `omarchy dock position left` in `omarchy dock autohide on` pa oboje nastavita iz terminala. Aplikacije, ki jih obdržite v doku, so zbledele, medtem ko ne tečejo.

Novi delovni prostori in vsi, ki jim niste dali lastne postavitve s `Super + L`, uporabljajo privzeto postavitev. Spreminjanje privzete postavitve ponastavi vsak delovni prostor brez oken nanjo, medtem ko tisti z okni na njem obdrži postavitev, ki jo ima. Okno, minimizirano v dok, še vedno šteje kot okno na delovnem prostoru, ki ga je zapustilo. Izberite jo pod _Videz > Postavitev delovnega prostora_: Ploščice, Pomikanje ali Lebdenje. `omarchy-hyprland-workspace-layout-default scrolling` jo nastavi iz terminala.

### Združevanje oken v skupine

Okna lahko združite v skupine z uporabo `Super + G`. Ko ste enkrat v skupini, bo vsako okno, ki ga zaženete, medtem ko je ta aktivna, pripadalo skupini. Med temi združenimi okni se lahko premikate z uporabo `Super + Ctrl + Arrow Left/Right` ali `Super + Alt + 1/2/3/4`, da greste neposredno na združena okna po vrsti.

Okno lahko premaknete iz združevanja s `Super + Alt + G` ali razstavite celotno skupino tako, da znova pritisnete `Super + G`. Nazadnje lahko okna zunaj skupine premaknete vanjo s `Super + Alt + Arrows`.

### Izstavljanje oken

Okno lahko izstavite iz njegove dodelitve delovnemu prostoru s `Super + O`. To ga bo pripelo kot lebdeče okno, ki vam sledi, na kateri koli delovni prostor greste. Odlično za video predvajalnike in podobno.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Delovni prostor scratchpad

Obstaja poseben delovni prostor scratchpad v polni velikosti, ki prekriva kateri koli delovni prostor, na katerem ste trenutno. Do tega, kar je na njem, dostopate s `Super + S`, okna pa tja postavite s `Super + Alt + S`.

Dobro deluje za kontrole ali terminal, s katerim želite hitro komunicirati, ne da bi zapustili trenutni delovni prostor.

### Konzola Quake

Nazadnje je tu še konzola Quake s polovično višino, ki se spusti čez kateri koli delovni prostor, na katerem ste trenutno. Preklopite jo s `Super + Grave`, okno pa tja postavite s `Super + Shift + Grave`.

Odpre se z vašim privzetim agentom, pripravljenim na delo. Medtem ko ima konzola eno samo okno, se spusti kot sredinsko poravnan panel, namesto da bi se raztezala čez zaslon. Nanjo postavite drugo aplikacijo in vrne se na polno širino, tako da imata obe prostor, da sedita ena ob drugi.

Če želite okno premakniti s scratchpada ali konzole, ga pošljite neposredno na drug delovni prostor z nečim, kot je `Super + Shift + 1`.

### Treba se je malo navaditi!

Traja malo časa, da se navadite tako krmariti po svojem namizju, ko pa se, se bo težko vrniti k tradicionalni izkušnji namizja, ki ga poganja miška!
