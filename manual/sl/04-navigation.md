# Navigacija

V Omarchy se vse dogaja prek tipkovnice — _VSE!_ Ko se sistem prvič zažene, z miško samo dobesedno ne morete narediti ničesar. Lahko pa pritisnete `Super + Space`, da prikažete Omarchy Menu, in od tu lahko naredite skoraj vse.

Toda Omarchy menu večino časa sploh ni namenjen temu, da bi bil glavni način upravljanja sistema. Lahko smo hitrejši od tega! Vse najpomembnejše aplikacije so vezane neposredno na posamezne bližnjice. Terminal zaženete s `Super + Return`, brskalnik pa s `Super + Shift + Return`. Poskusite narediti eno za drugim in videli boste čarovnijo Hyprlandovega polaganja ploščic v akciji:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Nato lahko pritisnete `Super + J`, da jih zložite eno na drugo namesto eno ob drugo:

 ![navigation-stacked](images/navigation-stacked.webp)

Znova pritisnite `Super + J`, da jih vrnete v položaj eno ob drugo. Nato v brskalniku poskusite `Super + Shift + Arrow Right`, da zamenjate okni.

Zdaj poskusite `Super + Shift + T`, da zaženete monitor Activity. To se bo pojavilo kot lebdeče okno. Lahko ga položite kot ploščico z `Super + T` (in to znova pritisnete, da spet postane lebdeče). Zdaj pritisnite `Super + Shift + F`, da odprete upravitelja datotek. Dobili boste urejeno štirismerno postavitev:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Med okni, ki želite, da so aktivna, se pomikate s `Super + Arrow`. To bo preklopilo fokus in premaknilo kazalec na sredino nove aplikacije. Na robu zaslona se nadaljuje na monitor na tisti strani.

Če pritisnete `Super + Shift + 2`, boste trenutno fokusirano aplikacijo premaknili na drugi delovni prostor. `Super + Shift + 1` jo premakne nazaj. (In `Super + Shift + Alt + 2` bo trenutno fokusirano aplikacijo premaknila na drugi delovni prostor, ne da bi preklopila nanj).

Pri več kot enem monitorju ima vsak monitor svoje delovne prostore od 1 do 10. `Super + 2` gre na drugi delovni prostor monitorja, na katerem ste, zgornja vrstica vsakega monitorja pa prikazuje njegove delovne prostore in tistega, ki ga prikazuje. `Super + Tab` kroži med delovnimi prostori na monitorju, na katerem ste. `Super + Shift + Ctrl + Arrows` premakne okno, na katerem ste, na monitor v tisti smeri, na delovni prostor, ki ga prikazuje, `Super + Shift + Alt + Arrows` pa premakne delovni prostor, na katerem ste, na monitor v tisti smeri, kjer prevzame isto številko, če je prosta. Monitor obdrži svoje delovne prostore, ko ga izklopite: pridružijo se delovnim prostorom drugega zaslona, oštevilčeni za tistimi, ki jih že ima, in se vrnejo pod svoje stare številke, ko se monitor vrne.

Če držite `Super` in z miško kliknete na okno, ga boste lahko premaknili tja, kjer sedi. Če držite `Super` in uporabite desni gumb miške, lahko oknu prosto spreminjate velikost.

Okno zaprete s `Super + W` ali `Super + Q` (vsa okna pa zaprete s `Ctrl + Alt + Delete`).

Lahko greste tudi na cel zaslon s `Super + F` ali celo samo na celotno širino (pri čemer obdržite zgornjo vrstico) s `Super + Alt + F` ali na cel zaslon znotraj okna s `Super + Ctrl + F` (dobro za YouTube!).

### Postavitev dwindle v primerjavi s pomično postavitvijo

Omarchyjeva privzeta postavitev se imenuje dwindle. Vsa okna, ki jih odprete na enem delovnem prostoru, ves čas ohranja vidna, tudi če jih mora zaradi tega zmanjšati.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Lahko pa se tudi odločite, da delovni prostor spremenite v pomično postavitev, kjer so okna poravnana eno ob drugem, čez viden rob zaslona. Posamezen delovni prostor v to postavitev spremenite s `Super + L`.

Če znova pritisnete `Super + L`, delovni prostor postane lebdeč, kjer se okna prosto prekrivajo in jih postavite sami, tretji pritisk pa ga vrne v dwindle. `Super + Alt + L` gre skozi njih v drugo smer. Okno, ki tako ali tako lebdi — tisto, ki ste ga izločili s `Super + T`, ali aplikacija, ki se vedno odpre kot lebdeča — ostane lebdeče, ko se delovni prostor vrne v polaganje ploščic. Zgornja vrstica označuje delovni prostor, na katerem ste, z njegovo postavitvijo: kvadrat za dwindle, krog za pomično in trikotnik za lebdečo. Klik na to oznako prav tako kroži med postavitvami, prav tako pa tipka za zaslon na prenosnikih, ki jo imajo.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Izbira velja za vsak delovni prostor posebej in ostane. Tako lahko delovni prostor 1 obdržite na dwindle za brskanje in delovni prostor 2 na pomični za kodo, in po ponovnem zagonu se bosta vrnila tako.

Če želite pomično postavitev uporabljati kot privzeto, lahko to nastavite v `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Lebdeči delovni prostori

Lebdeči delovni prostor deluje kot tradicionalno namizje: okna se prekrivajo, vi pa jih premikate in jim spreminjate velikost sami. Vsako okno dobi naslovno vrstico v barvah vaše teme, z gumbi za minimiziranje, maksimiziranje in zapiranje. `Super + M` minimizira tudi fokusirano okno. Minimizirano okno čaka v doku; kliknite njegovo aplikacijo, da ga vrnete. Kliknite okno, da ga pripeljete v ospredje. Velikost mu spreminjajte s katerega koli roba ali vogala. Dvokliknite naslovno vrstico, da maksimizirate okno, pri čemer zgornja vrstica ostane vidna, in znova, da dobite nazaj njegovo staro velikost. Chrome in drugi brskalniki, ki temeljijo na Chromiumu, Disks in Document Viewer preskočijo naslovno vrstico in namesto nje uporabljajo svojo glavo; `Super + Alt + F` jih maksimizira, `Super + M` pa jih minimizira.

Lebdeči delovni prostor prikazuje tudi dok, z vašimi pripetimi aplikacijami, vsem, kar se izvaja, in mrežo vseh aplikacij za gumbom za aplikacije, ki ga odpreta tudi `Super + Alt + Space` in _Aplikacije_ v meniju Omarchy. Z desno miškino tipko kliknite aplikacijo na mreži ali pritisnite `Delete`, da jo odstranite. Kliknite aplikacijo, da jo odprete ali da pripeljete njeno okno v ospredje; kliknite znova, da krožite med njenimi okni. Files pripelje nazaj samo okno z delovnega prostora, na katerem ste, sicer pa odpre novega, Terminal in Agent pa vedno zaženeta drugo, čeprav se minimizirano okno vrne najprej. Srednji klik odpre novo okno. Povlecite ikono vzdolž doka, da jo premaknete; če delujočo aplikacijo povlečete med druge, tam ostane. Z desno miškino tipko kliknite, da aplikacijo obdržite v doku, jo odstranite ali zaprete. Dok se umakne celozaslonskemu oknu. Z desno miškino tipko kliknite gumb za aplikacije, da dok premaknete na drug rob ali da se skrije, dokler kazalec ne doseže njegovega roba. Položaj je tudi pod _Videz > Dok > Položaj doka_, `omarchy dock position left` in `omarchy dock autohide on` pa oboje nastavita iz terminala. Aplikacije, ki jih obdržite v doku, so zbledele, medtem ko se ne izvajajo.

Novi delovni prostori in vsi, ki jim s `Super + L` niste dali lastne postavitve, uporabljajo privzeto postavitev. Spreminjanje privzete postavitve ponastavi vsak delovni prostor brez oken nanjo, medtem ko tisti z okni na njem obdrži postavitev, ki jo ima. Okno, minimizirano v dok, še vedno šteje kot okno na delovnem prostoru, ki ga je zapustilo. Izberite jo pod _Videz > Postavitev delovnega prostora_: Polaganje ploščic, Pomična ali Lebdeča. `omarchy hyprland workspace layout default scrolling` jo nastavi iz terminala.

### Združevanje oken v skupine

Okna lahko združite v skupino s `Super + G`. Ko ste v skupini, bo vsako okno, ki ga zaženete, medtem ko je ta aktivna, pripadalo skupini. Med temi združenimi okni se lahko premikate s `Super + Ctrl + Arrow Left/Right` ali s `Super + Alt + 1/2/3/4`, da greste neposredno na združena okna po vrstnem redu.

Okno lahko premaknete iz skupine s `Super + Alt + G` ali razstavite celotno skupino tako, da znova pritisnete `Super + G`. Nazadnje lahko okna zunaj skupine premaknete vanjo s `Super + Alt + Arrows`.

### Izločanje oken

Okno lahko izločite iz njegove dodelitve delovnemu prostoru s `Super + O`. To ga bo pripelo kot lebdeče okno, ki vas spremlja, na kateri koli delovni prostor greste. Odlično za video predvajalnike in podobno.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Delovni prostor scratchpad

Obstaja poseben delovni prostor scratchpad v polni velikosti, ki prekriva kateri koli delovni prostor, na katerem ste trenutno. Do tega, kar je na njem, dostopate s `Super + S`, okna pa tja postavite s `Super + Alt + S`.

Dobro deluje za kontrole ali terminal, s katerim želite hitro interagirati, ne da bi zapustili trenutni delovni prostor.

### Konzola Quake

Nazadnje je tu še konzola Quake s polovično višino, ki se spusti čez kateri koli delovni prostor, na katerem ste trenutno. Preklopite jo s `Super + the key above Tab` (grave na postavitvah US), okno pa tja postavite s `Super + Shift + the key above Tab`.

Ko se prvič odpre, zažene vašega privzetega agenta ali vas prosi, da enega izberete, če ga še niste izbrali. Medtem ko ima konzola eno samo okno, se spusti kot centrirana plošča, namesto da bi se raztezala čez zaslon. Postavite nanjo drugo aplikacijo in vrnila se bo na polno širino, da imata obe prostor, da sedita ena ob drugi.

Da okno premaknete bodisi z delovnega prostora scratchpad bodisi s konzole, ga pošljite neposredno na drug delovni prostor z nečim, kot je `Super + Shift + 1`.

### Potrebno se je malo navaditi!

Malo traja, da se navadite na takšno navigacijo po namizju, toda ko se, se boste težko vrnili na tradicionalno izkušnjo namizja, ki jo poganja miška!
