# Navigacija

Vse v Omarchyju poteka prek tipkovnice — _VSE!_ Ko se sistem prvič zažene, samo z miško dobesedno ne moreš narediti ničesar. Lahko pa pritisneš `Super + Space`, da prikažeš meni Omarchy, in od tu lahko narediš praktično vse.

Toda meni Omarchy večino časa niti ni namenjen temu, da bi bil glavni način upravljanja sistema. Lahko smo hitrejši od tega! Vse najpomembnejše aplikacije so vezane neposredno na posamezne bližnjice. Terminal zaženeš s `Super + Return`, brskalnik pa s `Super + Shift + Return`. Poskusi narediti eno za drugo in videl boš čarovnijo polaganja ploščic v Hyprlandu v akciji:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Nato lahko pritisneš `Super + J`, da ju zložiš eno na drugo namesto eno ob drugo:

 ![navigation-stacked](images/navigation-stacked.webp)

Znova pritisni `Super + J`, da ju vrneš v položaj eno ob drugo. Nato v brskalniku poskusi `Super + Shift + Arrow Right`, da zamenjaš okni.

Zdaj poskusi `Super + Ctrl + T`, da zaženeš nadzornik dejavnosti. Ta se bo prikazal kot lebdeče okno. V ploščice ga lahko spremeniš s `Super + T` (in to znova pritisneš, da spet postane lebdeče). Zdaj pritisni `Super + Shift + F`, da odpreš upravitelja datotek. Imel boš urejeno štiridelno postavitev:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Med okni se premikaš do tistega, ki ga želiš imeti aktivno, s `Super + Arrow`. To bo preklopilo fokus in premaknilo kazalec na sredino nove aplikacije.

Če pritisneš `Super + Shift + 2`, boš trenutno fokusirano aplikacijo premaknil na drugi delovni prostor. `Super + Shift + 1` jo premakne nazaj. (In `Super + Shift + Alt + 2` bo trenutno fokusirano aplikacijo premaknil na drugi delovni prostor, ne da bi preklopil nanj.)

Če držiš `Super` in z miško klikneš okno, boš lahko prerazporedil, kje sedi. Če držiš `Super` in uporabiš desni gumb miške, lahko okno prosto spreminjaš po velikosti.

Okno zapreš s `Super + W` ali `Super + Q` (in vsa okna zapreš s `Ctrl + Alt + Delete`).

Lahko greš tudi v celozaslonski način s `Super + F` ali celo samo na celotno širino (pri čemer obdržiš zgornjo vrstico) s `Super + Alt + F` ali v celozaslonski način znotraj okna s `Super + Ctrl + F` (dobro za YouTube!).

### Postavitev dwindle v primerjavi z drsno postavitvijo

Privzeta postavitev v Omarchyju se imenuje dwindle. Vsa okna, ki jih odpreš na enem delovnem prostoru, ves čas ohranja vidna, tudi če jih mora pomanjšati.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Lahko pa se odločiš tudi, da delovni prostor spremeniš v drsno postavitev, kjer so okna zvrščena eno ob drugo, čez vidni rob zaslona. En delovni prostor v to postavitev spremeniš s `Super + L`.

Če znova pritisneš `Super + L`, delovni prostor postane lebdeč, kjer se okna prosto prekrivajo in jih postaviš sam, tretji pritisk pa ga vrne v dwindle. `Super + Alt + L` gre skozi njih v drugo smer. Okno, ki tako ali tako lebdi — tisto, ki si ga izvlekel s `Super + T`, ali aplikacija, ki se vedno odpre lebdeče — še naprej lebdi, ko se delovni prostor vrne na ploščice. Zgornja vrstica delovni prostor, na katerem si, označuje z njegovo postavitvijo: kvadrat za dwindle, krog za drsenje in trikotnik za lebdenje. Klik na to oznako prav tako kroži med postavitvami.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Izbira velja za vsak delovni prostor posebej in se ohrani. Tako lahko delovni prostor 1 obdržiš na dwindle za brskanje in delovni prostor 2 na drsenju za kodo, in po vnovičnem zagonu se bosta vrnila prav taka.

Če želiš kot privzeto uporabljati drsno postavitev, to lahko nastaviš v `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Lebdeči delovni prostori

Lebdeči delovni prostor deluje kot tradicionalno namizje: okna se prekrivajo, ti pa jih premikaš in jim spreminjaš velikost sam. Vsako okno dobi naslovno vrstico v barvah tvoje teme, z gumbi za minimiziranje, maksimiranje in zapiranje. `Super + M` minimizira tudi fokusirano okno. Minimizirano okno čaka v doku; klikni njegovo aplikacijo, da ga prikličeš nazaj. Klikni okno, da ga pripelješ v ospredje. Velikost mu spreminjaj s katerega koli roba ali vogala. Dvakrat klikni naslovno vrstico, da okno maksimiraš, pri čemer zgornja vrstica ostane vidna, in znova dvakrat klikni, da mu vrneš staro velikost.

Lebdeči delovni prostor prikazuje tudi dok s pripetimi aplikacijami, vsem, kar se izvaja, in mrežo vseh aplikacij za gumbom za aplikacije, ki jo odpreta tudi `Super + Alt + Space` in _Aplikacije_ v meniju Omarchy. Z desno miškino tipko klikni aplikacijo na mreži ali pritisni `Delete`, da jo odstraniš. Klikni aplikacijo, da jo odpreš ali pripelješ njeno okno v ospredje; znova klikni, da krožiš med njenimi okni. Srednji klik odpre novo okno. Ikono povleci vzdolž doka, da jo premakneš; če delujočo aplikacijo povlečeš med druge, tam ostane. Z desno miškino tipko klikni, da aplikacijo obdržiš v doku, jo vzameš iz njega ali zapreš. Dok se umakne s poti celozaslonskemu oknu. Z desno miškino tipko klikni gumb za aplikacije, da dok premakneš na drug rob ali poskrbiš, da se skriva, dokler kazalec ne doseže njegovega roba. Položaj je tudi pod _Trigger > Videz > Dock > Položaj Docka_, `omarchy dock position left` in `omarchy dock autohide on` pa oba nastavita iz terminala. Aplikacije, ki jih obdržiš v doku, so zbledele, dokler se ne izvajajo.

Novi delovni prostori in vsi, ki jim nisi dal lastne postavitve s `Super + L`, uporabljajo privzeto postavitev. Sprememba privzete nastavitve na novo nastavi vsak delovni prostor brez oken nanjo, medtem ko tisti z okni obdrži postavitev, ki jo ima. Okno, minimizirano v dok, še vedno šteje kot okno na delovnem prostoru, ki ga je zapustilo. Izberi jo pod _Trigger > Videz > Postavitev delovnega prostora_: Ploščice, Drsenje ali Lebdenje. `omarchy-hyprland-workspace-layout-default scrolling` jo nastavi iz terminala.

### Združevanje oken v skupine

Okna je mogoče združiti v skupine s `Super + G`. Ko si enkrat v skupini, bo vsako okno, ki ga zaženeš, medtem ko je ta aktivna, pripadalo skupini. Med temi združenimi okni se lahko premikaš s `Super + Ctrl + Arrow Left/Right` ali neposredno na združeno okno po vrsti s `Super + Alt + 1/2/3/4`.

Okno lahko iz skupine premakneš s `Super + Alt + G` ali celotno skupino razstaviš tako, da znova pritisneš `Super + G`. Nazadnje lahko okna zunaj skupine premakneš vanjo s `Super + Alt + Arrows`.

### Izvlečenje oken

Okno lahko izvlečeš iz njegove dodelitve delovnemu prostoru s `Super + O`. To ga bo pripelo kot lebdeče okno, ki ti sledi na kateri koli delovni prostor, na katerega greš. Odlično za predvajalnike videa in podobno.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Delovni prostor scratchpad

Nazadnje je tu še posebni delovni prostor scratchpad, ki se spusti čez kateri koli delovni prostor, na katerem si trenutno, zelo podobno kot konzola v igri Quake. Preklopiš ga s `Super + Grave` ali `Super + S`, okno tja postaviš s `Super + Shift + Grave` ali `Super + Alt + S`.

Posebej dobro deluje za terminal, v katerem se izvaja agent, ali za kontrolnike, s katerimi želiš hitro komunicirati, ne da bi zapustil trenutni delovni prostor. Če želiš okno premakniti s scratchpada, ga pošlji neposredno na drug delovni prostor z nečim, kot je `Super + Shift + 1`.

Medtem ko scratchpad vsebuje eno samo okno, se spusti kot osrednja plošča, namesto da bi se raztezalo čez zaslon. Dodaj mu drugo aplikacijo in vrne se na celotno širino, tako da imata obe prostor, da sedita ena ob drugi.

### Na to se je treba malo navaditi!

Potreben je kratek čas, da se navadiš tako krmariti po namizju, a ko se, se bo težko vrniti k tradicionalni izkušnji namizja, gnani z miško!
