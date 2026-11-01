# Navigacija

Vse v Omarchyju se dogaja prek tipkovnice — _VSE!_ Ko se sistem prvič zažene, z miško samo dobesedno ne moreš narediti ničesar. Lahko pa pritisneš `Super + Space`, da prikažeš meni Omarchy, in od tu lahko narediš skoraj vse.

Vendar meni Omarchy večinoma sploh ni namenjen temu, da bi bil glavni način upravljanja sistema. Lahko smo hitrejši od tega! Vse najpomembnejše aplikacije so vezane neposredno na posamezne bližnjice. Terminal zaženeš s `Super + Return`, brskalnik pa s `Super + Shift + Return`. Poskusi eno za drugim in videl boš čarobnost tlakovanja v Hyprlandu v akciji:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Nato lahko pritisneš `Super + J`, da ju zložiš eno na drugo namesto eno ob drugo:

 ![navigation-stacked](images/navigation-stacked.webp)

Znova pritisni `Super + J`, da ju vrneš v položaj eno ob drugo. Nato v brskalniku poskusi `Super + Shift + Arrow Right`, da zamenjaš okni.

Zdaj poskusi `Super + Shift + T`, da zaženeš nadzornik dejavnosti. Pojavil se bo kot plavajoče okno. Lahko ga vtlačiš s `Super + T` (in to znova pritisneš, da spet postane plavajoče). Zdaj pritisni `Super + Shift + F`, da odpreš upravitelja datotek. Imel boš lično razporeditev na štiri dele:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Med okni, ki želiš, da je aktivno, se pomikaš s `Super + Arrow`. To preklopi fokus in premakne kazalec na sredino nove aplikacije. Na robu zaslona nadaljuje na monitor na tisti strani.

Če pritisneš `Super + Shift + 2`, premakneš trenutno fokusirano aplikacijo na drugi delovni prostor. `Super + Shift + 1` jo premakne nazaj. (In `Super + Shift + Alt + 2` premakne trenutno fokusirano aplikacijo na drugi delovni prostor, ne da bi preklopil nanj).

Pri več kot enem monitorju ima vsak monitor svojih delovnih prostorov od 1 do 10. `Super + 2` gre na drugi delovni prostor monitorja, na katerem si, zgornja vrstica vsakega monitorja pa prikazuje njegove delovne prostore in tistega, ki ga prikazuje. `Super + Tab` kroži med delovnimi prostori na monitorju, na katerem si. `Super + Shift + Ctrl + Arrows` premakne okno, na katerem si, na monitor v tisti smeri, na delovni prostor, ki ga prikazuje, `Super + Shift + Alt + Arrows` pa premakne delovni prostor, na katerem si, na monitor v tisti smeri, kjer prevzame isto številko, če je prosta. Monitor obdrži svoje delovne prostore, ko ga izklopiš: pridružijo se drugemu zaslonu, oštevilčeni za tistimi, ki jih že ima, in se vrnejo pod svoje stare številke, ko se monitor vrne.

Če držiš `Super` in z miško klikneš na okno, ga boš lahko preuredil, kjer sedi. Če držiš `Super` in uporabiš desni gumb miške, lahko oknu prosto spreminjaš velikost.

Okno zapreš s `Super + W` ali `Super + Q` (vsa okna pa zapreš s `Ctrl + Alt + Delete`).

Lahko greš tudi na cel zaslon s `Super + F` ali celo samo na celotno širino (pri čemer obdržiš zgornjo vrstico) s `Super + Alt + F` ali na cel zaslon znotraj okna s `Super + Ctrl + F` (dobro za YouTube!).

### Postavitev dwindle proti drsni postavitvi

Privzeta postavitev v Omarchyju se imenuje dwindle. Vsa okna, ki jih odpreš na enem delovnem prostoru, ohranja ves čas vidna, tudi če jih mora za to pomanjšati.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Lahko pa se odločiš, da delovni prostor spremeniš v drsno postavitev, kjer so okna zvrščena eno ob drugem onkraj vidnega roba zaslona. Posamezen delovni prostor v to postavitev spremeniš s `Super + L`.

Ponovni pritisk na `Super + L` spremeni delovni prostor v plavajočega, kjer se okna prosto prekrivajo in jih postavljaš sam, tretji pritisk pa ga vrne v dwindle. `Super + Alt + L` gre skozi njih v drugo smer. Okno, ki tako ali tako plava — tisto, ki si ga izločil s `Super + T`, ali aplikacija, ki se vedno odpre plavajoče — ostane plavajoče, ko se delovni prostor vrne v tlakovanje. Zgornja vrstica označuje delovni prostor, na katerem si, z njegovo postavitvijo: kvadrat za dwindle, krog za drsno in trikotnik za plavajočo. Klik na to oznako prav tako kroži med postavitvami.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Izbira velja za vsak delovni prostor posebej in ostane. Tako lahko delovni prostor 1 obdržiš na dwindle za brskanje in delovni prostor 2 na drsni za kodo, po ponovnem zagonu pa se bosta vrnila takšna.

Če želiš drsno postavitev uporabljati kot privzeto, lahko to nastaviš v `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plavajoči delovni prostori

Plavajoči delovni prostor deluje kot tradicionalno namizje: okna se prekrivajo, premikaš in velikost jim spreminjaš sam. Vsako okno dobi naslovno vrstico v barvah tvoje teme, z gumbi za minimiziranje, maksimiziranje in zapiranje. `Super + M` minimizira tudi fokusirano okno. Minimizirano okno čaka v doku; klikni njegovo aplikacijo, da ga pripelješ nazaj. Klikni okno, da ga pripelješ v ospredje. Velikost mu spreminjaj s katerega koli roba ali kota. Dvoklikni naslovno vrstico, da maksimiziraš okno in pri tem obdržiš zgornjo vrstico v pogledu, in znova, da dobiš nazaj njegovo staro velikost.

Plavajoči delovni prostor prikazuje tudi dok s tvojimi pripetimi aplikacijami, vsem, kar se izvaja, in mrežo vseh aplikacij za gumbom za aplikacije, ki ga odpreta tudi `Super + Alt + Space` in _Apps_ v meniju Omarchy. Z desno miškino tipko klikni aplikacijo na mreži ali pritisni `Delete`, da jo odstraniš. Klikni aplikacijo, da jo odpreš ali da pripelješ njeno okno v ospredje; klikni znova, da krožiš med njenimi okni. Srednji klik odpre novo okno. Povleci ikono vzdolž doka, da jo premakneš; če povlečeš aplikacijo, ki se izvaja, med druge, tam ostane. Z desno miškino tipko klikni, da aplikacijo obdržiš v doku, jo vzameš ven ali jo zapreš. Dok se umakne celozaslonskemu oknu. Z desno miškino tipko klikni gumb za aplikacije, da dok premakneš na drug rob ali da se skrije, dokler kazalec ne doseže njegovega roba. Položaj je tudi pod _Appearance > Dock > Dock Position_, `omarchy dock position left` in `omarchy dock autohide on` pa iz terminala nastavita oboje. Aplikacije, ki jih obdržiš v doku, so zbledele, dokler se ne izvajajo.

Novi delovni prostori in vsi, ki jim s `Super + L` nisi dal lastne postavitve, uporabljajo privzeto postavitev. Sprememba privzete postavitve ponastavi vsak delovni prostor brez oken nanjo, tisti z okni pa obdrži postavitev, ki jo ima. Okno, minimizirano v dok, še vedno šteje kot okno na delovnem prostoru, ki ga je zapustilo. Izberi jo pod _Appearance > Workspace Layout_: Tiling, Scrolling ali Floating. `omarchy-hyprland-workspace-layout-default scrolling` jo nastavi iz terminala.

### Združevanje oken v skupine

Okna lahko združiš v skupino s `Super + G`. Ko si v skupini, bo vsako okno, ki ga zaženeš, medtem ko je ta aktivna, pripadalo skupini. Med temi združenimi okni se lahko pomikaš s `Super + Ctrl + Arrow Left/Right` ali s `Super + Alt + 1/2/3/4`, da greš neposredno na združena okna po vrsti.

Okno lahko premakneš iz skupine s `Super + Alt + G` ali razstaviš celotno skupino tako, da znova pritisneš `Super + G`. Na koncu lahko okna zunaj skupine premakneš vanjo s `Super + Alt + Arrows`.

### Izločanje oken

Okno lahko izločiš iz njegove dodelitve delovnemu prostoru s `Super + O`. To ga bo pripelo kot plavajoče okno, ki ti sledi na kateri koli delovni prostor, na katerega greš. Odlično za video predvajalnike in podobno.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Delovni prostor scratchpad

Obstaja poseben delovni prostor scratchpad v polni velikosti, ki prekriva kateri koli delovni prostor, na katerem si trenutno. Do tega, kar je na njem, dostopaš s `Super + S`, okna pa tja postaviš s `Super + Alt + S`.

Dobro deluje za kontrole ali terminal, s katerim želiš hitro komunicirati, ne da bi zapustil trenutni delovni prostor.

### Konzola Quake

Na koncu je tu še konzola Quake v polovični višini, ki se spusti čez kateri koli delovni prostor, na katerem si trenutno. Preklopiš jo s `Super + Grave`, okno pa tja postaviš s `Super + Shift + Grave`.

Odpre se s tvojim privzetim agentom, pripravljenim na delo. Dokler ima konzola eno samo okno, se spusti kot sredinsko poravnan panel, namesto da bi se raztegnila čez zaslon. Postavi nanjo drugo aplikacijo in vrne se na celotno širino, tako da imata obe prostor, da sedita ena ob drugi.

Da okno premakneš s scratchpada ali s konzole, ga pošlji neposredno na drug delovni prostor z nečim, kot je `Super + Shift + 1`.

### Treba se je malo navaditi!

Traja malo časa, da se navadiš tako krmariti po svojem namizju, ko pa se, se bo težko vrniti k tradicionalni izkušnji namizja, ki ga poganja miška!
