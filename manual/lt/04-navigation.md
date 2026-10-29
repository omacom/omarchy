# Navigacija

Visa Omarchy veikia klaviatūra — _VISA!_ Kai sistema pirmą kartą paleidžiama, vien pele tiesiog nieko negali padaryti. Bet gali paspausti `Super + Space`, kad atvertum Omarchy meniu, o iš čia gali padaryti beveik viską.

Tačiau Omarchy meniu net nėra skirtas būti pagrindiniu sistemos valdymo būdu didžiąją laiko dalį. Galime greičiau! Visos svarbiausios programos tiesiogiai susietos su atskirais sparčiaisiais klavišais. Terminalą paleidi su `Super + Return`, o naršyklę — su `Super + Shift + Return`. Pamėgink padaryti viena po kito ir pamatysi Hyprland išklotinio išdėstymo magiją veikime:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Tada gali paspausti `Super + J`, kad sudėtum juos vieną ant kito, o ne greta:

 ![navigation-stacked](images/navigation-stacked.webp)

Paspausk `Super + J` dar kartą, kad grąžintum juos į padėtis greta. Tada, būdamas naršyklėje, pamėgink `Super + Shift + Arrow Right`, kad sukeistum langus vietomis.

Dabar pamėgink `Super + Shift + T`, kad paleistum Aktyvumo monitorių. Jis pasirodys kaip plaukiojantis langas. Gali jį paversti išklotiniu su `Super + T` (ir paspausti tai dar kartą, kad vėl taptų plaukiojantis). Dabar paspausk `Super + Shift + F`, kad atvertum failų tvarkytuvę. Turėsi dailią keturių dalių sąranką:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Tarp langų, kurį nori padaryti aktyvų, naršai su `Super + Arrow`. Tai perjungs fokusą ir perkels žymeklį į naujos programos centrą. Ekrano krašte jis tęsiasi į monitorių toje pusėje.

Jei paspausi `Super + Shift + 2`, perkelsi dabartinę fokusuotą programą į antrą darbo sritį. `Super + Shift + 1` perkelia ją atgal. (O `Super + Shift + Alt + 2` perkels dabartinę fokusuotą programą į antrą darbo sritį neperjungdamas į ją).

Su daugiau nei vienu monitoriumi kiekvienas monitorius turi savo darbo sritis nuo 1 iki 10. `Super + 2` eina į antra to monitoriaus, kuriame esi, darbo sritį, o kiekvieno monitoriaus viršutinė juosta rodo jo darbo sritis ir tą, kurią jis rodo. `Super + Tab` cikliškai pereina darbo sritis monitoriuje, kuriame esi. `Super + Shift + Ctrl + Arrows` perkelia langą, kuriame esi, į monitorių ta kryptimi, į jo rodomą darbo sritį, o `Super + Shift + Alt + Arrows` perkelia darbo sritį, kurioje esi, į monitorių ta kryptimi, kur ji gauna tą patį numerį, jei jis laisvas. Monitorius išlaiko savo darbo sritis, kai jį atjungi: jos prisijungia prie kito ekrano, numeruojamos po tų, kurias jis jau turi, ir grįžta prie savo senų numerių, kai monitorius sugrįžta.

Jei laikysi nuspaudęs `Super` ir pele spustelėsi langą, galėsi pertvarkyti, kur jis yra. Jei laikysi `Super` ir naudoji dešinį pelės mygtuką, gali laisvai keisti lango dydį.

Langą uždarai su `Super + W` arba `Super + Q` (o visus langus uždarai su `Ctrl + Alt + Delete`).

Taip pat gali eiti į visą ekraną su `Super + F` arba net tiesiog į visą plotį (išlaikydamas viršutinę juostą) su `Super + Alt + F` arba į visą ekraną lange su `Super + Ctrl + F` (puiku YouTube!).

### Dwindle ir slenkamasis išdėstymas

Numatytasis Omarchy išdėstymas vadinasi dwindle. Jis visą laiką laiko visus langus, kuriuos atveri vienoje darbo srityje, matomus, net jei tenka juos sumažinti.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Bet taip pat gali pasirinkti darbo sritį paversti slenkamuoju išdėstymu, kur langai išrikiuoti greta, už matomo ekrano krašto. Vieną darbo sritį į šį išdėstymą paversti su `Super + L`.

Paspaudus `Super + L` dar kartą, darbo sritis pavirsta plaukiojančia, kur langai laisvai persidengia ir juos išdėstai pats, o trečias paspaudimas grąžina ją į dwindle. `Super + Alt + L` pereina juos priešinga kryptimi. Langas, kuris bet kuriuo atveju plaukioja — kurį iškėlei su `Super + T` arba programa, kuri visada atsidaro plaukiojanti — lieka plaukiojantis, kai darbo sritis grįžta į išklotinį išdėstymą. Viršutinė juosta pažymi darbo sritį, kurioje esi, jos išdėstymu: kvadratas dwindle, apskritimas slenkamajam ir trikampis plaukiojančiam. Spustelėjus tą žymę, išdėstymas taip pat cikliškai keičiamas.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Pasirinkimas yra kiekvienai darbo sričiai atskirai ir jis išlieka. Taigi gali darbo sritį 1 laikyti dwindle naršymui, o darbo sritį 2 — slenkamąją kodui, ir jos taip sugrįš po paleidimo iš naujo.

Jei nori slenkamąjį išdėstymą naudoti kaip numatytąjį, gali tai nustatyti `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plaukiojančios darbo sritys

Plaukiojanti darbo sritis veikia kaip tradicinis darbalaukis: langai persidengia, o tu pats juos judi ir keiti dydį. Kiekvienas langas gauna pavadinimo juostą tavo temos spalvomis, su mygtukais sumažinti, padidinti ir uždaryti. `Super + M` taip pat sumažina fokusuotą langą. Sumažintas langas laukia doke; spustelėk jo programą, kad jį susigrąžintum. Spustelėk langą, kad iškeltum jį į priekį. Keisk jo dydį nuo bet kurio krašto ar kampo. Dukart spustelėk pavadinimo juostą, kad padidintum langą išlaikydamas viršutinę juostą matomą, ir dar kartą, kad susigrąžintum jo seną dydį.

Plaukiojanti darbo sritis taip pat rodo doką su tavo prisegtomis programomis, viskuo, kas veikia, ir visų programų tinkleliu už programų mygtuko, kurį taip pat atveria `Super + Alt + Space` ir _Apps_ Omarchy meniu. Dešiniuoju pelės mygtuku spustelėk programą tinklelyje arba paspausk `Delete`, kad ją pašalintum. Spustelėk programą, kad ją atvertum arba iškeltum jos langą į priekį; spustelėk dar kartą, kad cikliškai pereitum jos langus. Vidurinis spustelėjimas atveria naują langą. Vilk piktogramą išilgai doko, kad ją perkeltum; nutempus veikiančią programą tarp kitų, ji ten pasilieka. Dešiniuoju pelės mygtuku spustelėk, kad programą išlaikytum doke, išimtum ją arba ją uždarytum. Dokas pasitraukia iš kelio viso ekrano langui. Dešiniuoju pelės mygtuku spustelėk programų mygtuką, kad perkeltum doką į kitą kraštą arba jis slėptųsi, kol rodyklė pasieks jo kraštą. Padėtis taip pat yra _Appearance > Dock > Dock Position_, o `omarchy dock position left` ir `omarchy dock autohide on` abi nustato iš terminalo. Programos, kurias laikai doke, yra pritemdytos, kol jos neveikia.

Naujos darbo sritys ir bet kuri, kuriai nesuteikei savo išdėstymo su `Super + L`, naudoja numatytąjį išdėstymą. Pakeitus numatytąjį, kiekviena darbo sritis be langų nustatoma iš naujo į jį, o ta, kurioje yra langų, išlaiko išdėstymą, kurį turi. Į doką sumažintas langas vis tiek laikomas langu darbo srityje, kurią jis paliko. Pasirink jį _Appearance > Workspace Layout_: Tiling, Scrolling arba Floating. `omarchy-hyprland-workspace-layout-default scrolling` nustato jį iš terminalo.

### Langų grupavimas

Langus galima grupuoti naudojant `Super + G`. Kai esi grupėje, kiekvienas langas, kurį paleidi, kol ji aktyvi, priklausys grupei. Tarp šių sugrupuotų langų gali judėti naudodamas `Super + Ctrl + Arrow Left/Right` arba `Super + Alt + 1/2/3/4`, kad eitum tiesiai prie sugrupuoto lango eilės tvarka.

Langą iš grupavimo gali perkelti su `Super + Alt + G` arba išardyti visą grupę dar kartą paspausdamas `Super + G`. Galiausiai langus, esančius už grupės ribų, į ją gali perkelti su `Super + Alt + Arrows`.

### Langų iškėlimas

Langą iš jo darbo srities paskyrimo gali iškelti su `Super + O`. Tai prisegs jį kaip plaukiojantį langą, kuris seka tave, į kurią darbo sritį beeitum. Puiku vaizdo grotuvams ir panašiems.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad darbo sritis

Yra speciali viso dydžio scratchpad darbo sritis, kuri uždengia bet kurią darbo sritį, kurioje šiuo metu esi. Tai, kas joje yra, pasieki su `Super + S`, o langus ten dedi su `Super + Alt + S`.

Ji puikiai tinka valdikliams ar terminalui, su kuriuo nori greitai sąveikauti nepalikdamas dabartinės darbo srities.

### Quake konsolė

Galiausiai yra pusės aukščio Quake konsolė, kuri nusileidžia ant bet kurios darbo srities, kurioje šiuo metu esi. Perjunk ją su `Super + Grave`, o langą ten padėk naudodamas `Super + Shift + Grave`.

Ji atsidaro su tavo numatytuoju agentu, pasiruošusiu veikti. Kol konsolėje yra vienas langas, ji nusileidžia kaip centruotas skydelis, o ne driekiasi per ekraną. Padėk joje antrą programą ir ji grįš į visą plotį, kad abi turėtų vietos būti greta.

Norėdamas langą perkelti iš scratchpad arba konsolės, nusiųsk jį tiesiai į kitą darbo sritį su kažkuo panašiu į `Super + Shift + 1`.

### Reikia šiek tiek priprasti!

Reikia šiek tiek laiko priprasti taip naršyti darbalaukyje, bet kai priprasi, bus sunku grįžti prie tradicinės pele valdomo darbalaukio patirties!
