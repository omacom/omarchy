# Navigacija

Vse v sistemu Omarchy se dogaja prek tipkovnice — _VSE!_ Ko se sistem prvič zažene, z miško samo dobesedno ne morete storiti ničesar. Lahko pa pritisnete `Super + Space`, da prikažete meni Omarchy, in od tu lahko storite praktično vse.

Toda meni Omarchy večinoma sploh ni namenjen temu, da bi bil glavni način upravljanja sistema. Lahko smo hitrejši od tega! Vse najpomembnejše aplikacije so neposredno vezane na posamezne bližnjice. Terminal zaženete s `Super + Return`, brskalnik pa s `Super + Shift + Return`. Poskusite storiti eno za drugim in videli boste čarobnost ploščičnega razporejanja v Hyprlandu pri delu:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Nato lahko pritisnete `Super + J`, da ju zložite eno na drugo namesto eno ob drugo:

 ![navigation-stacked](images/navigation-stacked.webp)

Znova pritisnite `Super + J`, da ju vrnete v položaj eno ob drugem. Nato v brskalniku poskusite pritisniti `Super + Shift + Arrow Right`, da zamenjate okni.

Zdaj poskusite s `Super + Shift + T` zagnati nadzornik dejavnosti Activity. Ta se bo prikazal kot plavajoče okno. V ploščično postavitev ga lahko postavite s `Super + T` (in to znova pritisnete, da spet postane plavajoče). Zdaj pritisnite `Super + Shift + F`, da odprete upravitelja datotek. Imeli boste urejeno štirismerno postavitev:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Med okni se pomikate do tistega, ki želite, da je aktivno, s `Super + Arrow`. S tem se preklopi fokus in kazalec se premakne na sredino nove aplikacije. Na robu zaslona se nadaljuje na monitor na tisti strani.

Če pritisnete `Super + Shift + 2`, boste trenutno fokusirano aplikacijo premaknili na drugi delovni prostor. `Super + Shift + 1` jo premakne nazaj. (In `Super + Shift + Alt + 2` bo trenutno fokusirano aplikacijo premaknil na drugi delovni prostor, ne da bi preklopil nanj).

Pri več kot enem monitorju ima vsak monitor svojih delovnih prostorov od 1 do 10. `Super + 2` gre na drugi delovni prostor monitorja, na katerem ste, zgornja vrstica vsakega monitorja pa prikazuje njegove delovne prostore in tistega, ki ga prikazuje. `Super + Tab` kroži med delovnimi prostori na monitorju, na katerem ste. `Super + Shift + Ctrl + Arrows` premakne okno, na katerem ste, na monitor v tisti smeri, na delovni prostor, ki ga ta prikazuje, `Super + Shift + Alt + Arrows` pa premakne delovni prostor, na katerem ste, na monitor v tisti smeri, kjer prevzame isto številko, če je prosta. Monitor obdrži svoje delovne prostore, ko ga izključite: pridružijo se delovnim prostorom drugega zaslona, oštevilčeni za tistimi, ki jih ta že ima, in se vrnejo pod svoje stare številke, ko se monitor vrne.

Če držite `Super` in z miško kliknete okno, boste lahko preuredili, kje je postavljeno. Če držite `Super` in uporabite desni gumb miške, lahko oknu prosto spreminjate velikost.

Okno zaprete s `Super + W` ali `Super + Q` (vsa okna pa zaprete s `Ctrl + Alt + Delete`).

Lahko greste tudi na cel zaslon s `Super + F` ali celo samo na celotno širino (pri čemer obdržite zgornjo vrstico) s `Super + Alt + F` ali na cel zaslon znotraj okna s `Super + Ctrl + F` (dobro za YouTube!).

### Postavitev dwindle v primerjavi z drsno postavitvijo

Privzeta postavitev v sistemu Omarchy se imenuje dwindle. Vsa okna, ki jih odprete na enem delovnem prostoru, ohranja ves čas vidna, tudi če jih mora zaradi tega pomanjšati.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Lahko pa se odločite tudi, da delovni prostor spremenite v drsno postavitev, kjer so okna postavljena eno ob drugem, onkraj vidnega roba zaslona. En sam delovni prostor v to postavitev spremenite s `Super + L`.

Ponovni pritisk na `Super + L` delovni prostor spremeni v plavajočega, kjer se okna prosto prekrivajo in jih postavite sami, tretji pritisk pa ga vrne v dwindle. `Super + Alt + L` gre skozi nje v drugo smer. Okno, ki je tako ali tako plavajoče — tisto, ki ste ga izločili s `Super + T`, ali aplikacija, ki se vedno odpre kot plavajoča — ostane plavajoče, ko se delovni prostor vrne v ploščično razporejanje. Zgornja vrstica delovni prostor, na katerem ste, označi z njegovo postavitvijo: kvadrat za dwindle, krog za drsno in trikotnik za plavajočo. Tudi klik na to oznako kroži med postavitvami.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Izbira velja za vsak delovni prostor posebej in se ohrani. Tako lahko delovni prostor 1 obdržite na dwindle za brskanje, delovni prostor 2 pa na drsni za kodo, in po ponovnem zagonu se bosta vrnila takšna.

Če želite drsno postavitev uporabljati kot privzeto, lahko to nastavite v `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plavajoči delovni prostori

Plavajoči delovni prostor deluje kot tradicionalno namizje: okna se prekrivajo, vi pa jih premikate in jim sami spreminjate velikost. Vsako okno dobi naslovno vrstico v barvah vaše teme, z gumbi za pomanjšanje, povečanje in zapiranje. Tudi `Super + M` pomanjša fokusirano okno. Pomanjšano okno čaka v doku; kliknite njegovo aplikacijo, da ga prikličete nazaj. Kliknite okno, da ga prinesete v ospredje. Velikost mu spreminjajte s katerega koli roba ali kota. Dvokliknite naslovno vrstico, da povečate okno, pri čemer zgornja vrstica ostane vidna, in znova, da dobite nazaj njegovo staro velikost. Chrome in drugi brskalniki na osnovi Chromiuma, Disks in Document Viewer preskočijo naslovno vrstico in namesto nje uporabijo svojo lastno glavo; `Super + Alt + F` jih poveča, `Super + M` pa jih pomanjša.

Plavajoči delovni prostor prikazuje tudi dok z vašimi pripetimi aplikacijami, vsem, kar se izvaja, in mrežo vseh aplikacij za gumbom za aplikacije, ki ga odpreta tudi `Super + Alt + Space` in _Aplikacije_ v meniju Omarchy. Z desno tipko miške kliknite aplikacijo na mreži ali pritisnite `Delete`, da jo odstranite. Kliknite aplikacijo, da jo odprete ali da njeno okno prinesete v ospredje; znova kliknite, da krožite med njenimi okni. Files prikliče nazaj samo okno z delovnega prostora, na katerem ste, sicer pa odpre novo, Terminal in Agent pa vedno zaženeta drugo, čeprav se najprej vrne pomanjšano okno. Srednji klik odpre novo okno. Ikono povlecite vzdolž doka, da jo premaknete; če aplikacijo, ki se izvaja, povlečete med druge, tam ostane. Kliknite z desno tipko miške, da aplikacijo obdržite v doku, jo vzamete iz njega ali jo zaprete. Dok se umakne celozaslonskemu oknu. Kliknite z desno tipko miške na gumb za aplikacije, da dok premaknete na drug rob ali da se skrije, dokler kazalec ne doseže njegovega roba. Položaj je tudi pod _Videz > Dok > Položaj doka_, `omarchy dock position left` in `omarchy dock autohide on` pa oboje nastavita iz terminala. Aplikacije, ki jih obdržite v doku, so obledele, medtem ko se ne izvajajo.

Novi delovni prostori in vsi, ki jim s `Super + L` niste dali lastne postavitve, uporabijo privzeto postavitev. Sprememba privzete postavitve ponastavi nanjo vsak delovni prostor brez oken, tisti z okni pa obdrži postavitev, ki jo ima. Okno, pomanjšano v dok, še vedno šteje kot okno na delovnem prostoru, ki ga je zapustilo. Izberite jo pod _Videz > Postavitev delovnega prostora_: Ploščična, Drsna ali Plavajoča. `omarchy-hyprland-workspace-layout-default scrolling` jo nastavi iz terminala.

### Združevanje oken v skupine

Okna je mogoče združiti v skupino s `Super + G`. Ko ste v skupini, bo vsako okno, ki ga zaženete, medtem ko je ta aktivna, pripadalo skupini. Med temi združenimi okni se lahko premikate s `Super + Ctrl + Arrow Left/Right` ali s `Super + Alt + 1/2/3/4`, da greste neposredno na združena okna po vrstnem redu.

Okno lahko premaknete iz skupine s `Super + Alt + G` ali razstavite celotno skupino tako, da znova pritisnete `Super + G`. Nazadnje lahko okna zunaj skupine premaknete vanjo s `Super + Alt + Arrows`.

### Izločanje oken

Okno lahko izločite iz njegove dodelitve delovnemu prostoru s `Super + O`. S tem ga boste pripeli kot plavajoče okno, ki vam sledi na kateri koli delovni prostor, na katerega greste. Odlično za predvajalnike videa in podobno.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Delovni prostor scratchpad

Obstaja poseben delovni prostor scratchpad v polni velikosti, ki prekriva kateri koli delovni prostor, na katerem ste trenutno. Do tega, kar je na njem, dostopate s `Super + S`, okna pa tja postavite s `Super + Alt + S`.

Dobro deluje za kontrole ali terminal, s katerim želite hitro komunicirati, ne da bi zapustili trenutni delovni prostor.

### Konzola Quake

Nazadnje je tu še konzola Quake v polovični višini, ki se spusti čez kateri koli delovni prostor, na katerem ste trenutno. Preklopite jo s `Super + Grave`, okno pa tja postavite s `Super + Shift + Grave`.

Odpre se z vašim privzetim agentom, pripravljenim na delo. Medtem ko je v konzoli eno samo okno, se spusti kot osredinjen panel, namesto da bi se raztegnila čez zaslon. Postavite nanjo drugo aplikacijo in vrnila se bo na polno širino, tako da bosta imeli prostora, da sedita ena ob drugi.

Če želite okno premakniti s scratchpada ali s konzole, ga pošljite neposredno na drug delovni prostor, na primer s `Super + Shift + 1`.

### Treba se je malo navaditi!

Traja malo časa, da se navadite na takšno navigacijo po namizju, toda ko se boste, se bo težko vrniti na tradicionalno izkušnjo namizja, ki ga poganja miška!
