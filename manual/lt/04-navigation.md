# Navigacija

Viskas Omarchy vyksta klaviatūra — _VISKAS!_ Kai sistema paleidžiama pirmą kartą, vien pele tiesiogine prasme nieko negalite nuveikti. Tačiau galite paspausti `Super + Space`, kad atskleistumėte Omarchy meniu, o iš čia galite daryti beveik viską.

Tačiau Omarchy meniu net nėra skirtas būti pagrindiniu būdu valdyti sistemą didžiąją laiko dalį. Galime dar greičiau! Visos svarbiausios programos tiesiogiai susietos su atskirais sparčiaisiais klavišais. Terminalą paleidžiate paspaudę `Super + Return`, o naršyklę — `Super + Shift + Return`. Pabandykite tai padaryti vieną po kito ir pamatysite veikiantį Hyprland langų išdėstymo plytelėmis stebuklą:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Tuomet galite paspausti `Super + J`, kad sukrautumėte juos vieną ant kito, o ne šalia vienas kito:

 ![navigation-stacked](images/navigation-stacked.webp)

Paspauskite `Super + J` dar kartą, kad grąžintumėte juos į padėtį šalia vienas kito. Tada, būdami naršyklėje, pabandykite `Super + Shift + Arrow Right`, kad sukeistumėte langus vietomis.

Dabar pabandykite `Super + Ctrl + T`, kad paleistumėte Activity monitorių. Jis pasirodys kaip slankusis langas. Galite jį įdėti į plytelių išdėstymą paspaudę `Super + T` (ir paspausti tai dar kartą, kad vėl taptų slankusis). Dabar paspauskite `Super + Shift + F`, kad atvertumėte failų tvarkytuvę. Turėsite tvarkingą keturių dalių išdėstymą:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Tarp langų, kad pasirinktumėte, kuris turi būti aktyvus, naviguojate paspaudę `Super + Arrow`. Tai perjungs fokusą ir perkels žymeklį į naujos programos centrą.

Jei paspausite `Super + Shift + 2`, perkelsite šiuo metu fokusuotą programą į antrąją darbo sritį. `Super + Shift + 1` perkelia ją atgal. (O `Super + Shift + Alt + 2` perkels šiuo metu fokusuotą programą į antrąją darbo sritį neperjungdamas į ją).

Jei laikysite nuspaudę `Super` ir pele spustelėsite langą, galėsite pertvarkyti, kur jis yra. Jei laikysite `Super` ir naudosite dešinįjį pelės mygtuką, galėsite laisvai keisti lango dydį.

Langą uždarote paspaudę `Super + W` arba `Super + Q` (o visus langus uždarote paspaudę `Ctrl + Alt + Delete`).

Taip pat galite įjungti viso ekrano režimą paspaudę `Super + F` arba net tiesiog viso pločio režimą (paliekant viršutinę juostą) paspaudę `Super + Alt + F`, arba viso ekrano režimą lange paspaudę `Super + Ctrl + F` (puiku YouTube!).

### Dwindle prieš slenkantį išdėstymą

Numatytasis Omarchy išdėstymas vadinamas dwindle. Jis visada laiko visus vienoje darbo srityje atvertus langus matomus, net jei tenka juos sumažinti.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Tačiau taip pat galite pasirinkti darbo sritį paversti slenkančiu išdėstymu, kuriame langai išrikiuojami šalia vienas kito, už matomo ekrano krašto ribų. Vieną darbo sritį į šį išdėstymą perjungiate paspaudę `Super + L`.

Dar kartą paspaudus `Super + L`, darbo sritis tampa slankioji, kurioje langai laisvai persidengia ir juos išdėstote patys, o trečiasis paspaudimas grąžina ją į dwindle. `Super + Alt + L` pereina juos priešinga kryptimi. Langas, kuris ir taip yra slankusis — toks, kurį iškėlėte paspaudę `Super + T`, arba programa, kuri visada atveriama kaip slankioji — lieka slankusis, kai darbo sritis grįžta į plytelių išdėstymą. Viršutinėje juostoje darbo sritis, kurioje esate, pažymėta jos išdėstymu: kvadratu — dwindle, apskritimu — slenkančiam, o trikampiu — slankiajam. Spustelėjus tą žymę, išdėstymas taip pat keičiamas ciklu.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Pasirinkimas yra atskirai kiekvienai darbo sričiai ir jis išlieka. Taigi 1 darbo srityje galite palikti dwindle naršymui, o 2 darbo srityje — slenkantį išdėstymą kodui, ir po paleidimo iš naujo jos grįš būtent tokios.

Jei norite naudoti slenkantį išdėstymą kaip numatytąjį, galite tai nustatyti faile `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Slankiosios darbo sritys

Slankioji darbo sritis veikia kaip tradicinis darbalaukis: langai persidengia, o jūs patys juos perkeliate ir keičiate jų dydį. Kiekvienas langas gauna jūsų temos spalvų antraštės juostą su mygtukais sumažinti, padidinti ir uždaryti. `Super + M` taip pat sumažina fokusuotą langą. Sumažintas langas laukia doke; spustelėkite jo programą, kad jį grąžintumėte. Spustelėkite langą, kad iškeltumėte jį į priekį. Keiskite jo dydį iš bet kurio krašto arba kampo. Dukart spustelėkite antraštės juostą, kad padidintumėte langą paliekant viršutinę juostą matomą, ir dar kartą, kad grąžintumėte ankstesnį jo dydį.

Slankioji darbo sritis taip pat rodo doką su jūsų prisegtomis programomis, viskuo, kas šiuo metu veikia, ir kiekvienos programos tinkleliu už programų mygtuko, kurį taip pat atveria `Super + Alt + Space` ir _Apps_ Omarchy meniu. Dešiniuoju pelės mygtuku spustelėkite programą tinklelyje arba paspauskite `Delete`, kad ją pašalintumėte. Spustelėkite programą, kad ją atvertumėte arba iškeltumėte jos langą į priekį; spustelėkite dar kartą, kad pereitumėte per jos langus ciklu. Vidurinysis spustelėjimas atveria naują langą. Vilkite piktogramą išilgai doko, kad ją perkeltumėte; nutempus veikiančią programą tarp kitų, ji ten ir lieka. Dešiniuoju pelės mygtuku spustelėkite, kad programą išlaikytumėte doke, išimtumėte ją iš jo arba ją uždarytumėte. Dokas pasitraukia iš kelio viso ekrano langui. Dešiniuoju pelės mygtuku spustelėkite programų mygtuką, kad perkeltumėte doką prie kito krašto arba kad jis slėptųsi, kol žymeklis pasieks jo kraštą. Padėtis taip pat yra skiltyje _Trigger > Appearance > Dock > Dock Position_, o `omarchy dock position left` ir `omarchy dock autohide on` nustato abu iš terminalo. Programos, kurias laikote doke, yra išblukusios, kol jos neveikia.

Naujos darbo sritys ir bet kurios, kurioms neskyrėte atskiro išdėstymo paspaudę `Super + L`, naudoja numatytąjį išdėstymą. Pakeitus numatytąjį išdėstymą, kiekviena darbo sritis be langų nustatoma į jį iš naujo, o sritis su langais išlaiko turimą išdėstymą. Į doką sumažintas langas vis tiek skaičiuojamas kaip langas darbo srityje, kurią jis paliko. Pasirinkite jį skiltyje _Trigger > Appearance > Workspace Layout_: Tiling, Scrolling arba Floating. `omarchy-hyprland-workspace-layout-default scrolling` nustato jį iš terminalo.

### Langų grupavimas

Langus galima grupuoti paspaudus `Super + G`. Kai būsite grupėje, kiekvienas langas, kurį paleisite jai esant aktyviai, priklausys grupei. Tarp šių sugrupuotų langų galite judėti paspaudę `Super + Ctrl + Arrow Left/Right` arba `Super + Alt + 1/2/3/4`, kad iš eilės eitumėte tiesiai prie sugrupuoto lango.

Langą iš grupavimo galite išimti paspaudę `Super + Alt + G` arba išardyti visą grupę dar kartą paspaudę `Super + G`. Galiausiai langus, esančius už grupės ribų, į ją galite perkelti paspaudę `Super + Alt + Arrows`.

### Langų iškėlimas

Langą iš jo darbo srities paskyrimo galite iškelti paspaudę `Super + O`. Tai prisegs jį kaip slankųjį langą, kuris seka paskui jus į bet kurią darbo sritį, į kurią einate. Puiku vaizdo grotuvams ir panašiems dalykams.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad darbo sritis

Galiausiai yra speciali scratchpad darbo sritis, kuri nusileidžia ant darbo srities, kurioje šiuo metu esate, labai panašiai kaip Quake konsolė. Ją perjungite paspaudę `Super + Grave` arba `Super + S`, o langą ten padėkite paspaudę `Super + Shift + Grave` arba `Super + Alt + S`.

Ji ypač gerai tinka terminalui, kuriame veikia agentas, arba valdikliams, su kuriais norite greitai sąveikauti nepalikdami dabartinės darbo srities. Norėdami perkelti langą iš scratchpad, nusiųskite jį tiesiai į kitą darbo sritį, pavyzdžiui, paspaudę `Super + Shift + 1`.

Kol scratchpad laikomas vienas langas, ji nusileidžia kaip centruotas skydelis, o ne užima visą ekraną. Padėkite ant jos antrą programą ir ji grįš į visą plotį, kad abi turėtų vietos būti šalia viena kitos.

### Prie to reikia priprasti!

Priprasti taip naviguoti darbalaukyje užtrunka šiek tiek laiko, bet kai priprasite, bus sunku grįžti prie tradicinio pele valdomo darbalaukio!
