# Naršymas

Omarchy viskas vyksta klaviatūra — _VISKAS!_ Kai sistema paleidžiama pirmą kartą, vien pele tiesiog nieko negalite padaryti. Bet galite paspausti `Super + Space`, kad atvertumėte Omarchy meniu, o iš čia galite padaryti beveik viską.

Bet Omarchy meniu net nėra skirtas būti pagrindiniu būdu valdyti sistemą didžiąją laiko dalį. Galime greičiau! Visos svarbiausios programos tiesiogiai susietos su atskirais sparčiaisiais klavišais. Terminalą paleidžiate su `Super + Return`, o naršyklę — su `Super + Shift + Return`. Pabandykite vieną po kito ir pamatysite Hyprland langų dėliojimo plytelėmis magiją veikime:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Tada galite paspausti `Super + J`, kad sudėtumėte juos vieną ant kito, o ne greta:

 ![navigation-stacked](images/navigation-stacked.webp)

Paspauskite `Super + J` dar kartą, kad grąžintumėte juos į padėtis greta. Tada, būdami naršyklėje, pabandykite `Super + Shift + Arrow Right`, kad sukeistumėte langus vietomis.

Dabar pabandykite `Super + Shift + T`, kad paleistumėte veiklos monitorių. Jis pasirodys kaip slankusis langas. Galite jį išdėlioti plytelėmis su `Super + T` (ir paspausti tai dar kartą, kad vėl būtų slankusis). Dabar paspauskite `Super + Shift + F`, kad atvertumėte failų tvarkyklę. Turėsite tvarkingą keturių langų išdėstymą:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Tarp langų, kad suaktyvintumėte norimą, judate su `Super + Arrow`. Tai perkelia židinį ir perkelia žymeklį į naujos programos centrą. Ekrano krašte jis tęsiasi į monitorių toje pusėje.

Jei paspausite `Super + Shift + 2`, perkelsite šiuo metu sufokusuotą programą į antrą darbo sritį. `Super + Shift + 1` perkelia ją atgal. (O `Super + Shift + Alt + 2` perkels šiuo metu sufokusuotą programą į antrą darbo sritį neperjungdamas į ją).

Turint daugiau nei vieną monitorių, kiekvienas monitorius turi savo darbo sritis nuo 1 iki 10. `Super + 2` pereina į antrą monitoriaus, kuriame esate, darbo sritį, o kiekvieno monitoriaus viršutinėje juostoje rodomos jo darbo sritys ir ta, kurią jis rodo. `Super + Tab` ciklu pereina per monitoriaus, kuriame esate, darbo sritis. `Super + Shift + Ctrl + Arrows` perkelia langą, kuriame esate, į monitorių ta kryptimi, į jo rodomą darbo sritį, o `Super + Shift + Alt + Arrows` perkelia darbo sritį, kurioje esate, į monitorių ta kryptimi, kur ji gauna tą patį numerį, jei jis laisvas. Monitorius išsaugo savo darbo sritis, kai jį atjungiate: jos prisijungia prie kito ekrano, sunumeruotos po tų, kurias jis jau turi, ir grįžta su senais numeriais, kai monitorius grįžta.

Jei laikysite nuspaudę `Super` ir pele spustelėsite langą, galėsite pertvarkyti, kur jis yra. Jei laikysite `Super` ir naudosite dešinįjį pelės mygtuką, galėsite laisvai keisti lango dydį.

Langą uždarote su `Super + W` arba `Super + Q` (o visus langus uždarote su `Ctrl + Alt + Delete`).

Taip pat galite pereiti į viso ekrano režimą su `Super + F` arba net tik į viso pločio režimą (išlaikydami viršutinę juostą) su `Super + Alt + F`, arba į viso ekrano režimą lange su `Super + Ctrl + F` (gerai tinka YouTube!).

### Dwindle ir slenkamasis išdėstymas

Numatytasis Omarchy išdėstymas vadinamas dwindle. Jis visą laiką laiko visus vienoje darbo srityje atvertus langus matomus, net jei tenka juos sumažinti.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Bet taip pat galite pasirinkti darbo sritį paversti slenkamuoju išdėstymu, kuriame langai išrikiuoti greta, už matomo ekrano krašto. Vieną darbo sritį į šį išdėstymą paverčiate su `Super + L`.

Paspaudus `Super + L` dar kartą, darbo sritis tampa slankioji, kurioje langai laisvai persidengia ir jūs patys juos išdėstote, o trečias paspaudimas grąžina ją į dwindle. `Super + Alt + L` pereina per juos kita kryptimi. Langas, kuris ir taip yra slankusis — tas, kurį iškėlėte su `Super + T`, arba programa, kuri visada atsidaro slankioji — lieka slankusis, kai darbo sritis grįžta į plytelių dėliojimą. Viršutinė juosta pažymi darbo sritį, kurioje esate, jos išdėstymu: kvadratas reiškia dwindle, apskritimas — slenkamąjį, o trikampis — slankųjį. Spustelėjus tą ženklą, išdėstymas taip pat keičiamas ciklu.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Pasirinkimas yra kiekvienai darbo sričiai atskirai ir išlieka. Taigi galite palikti 1 darbo sritį dwindle naršymui, o 2 darbo sritį slenkamąją kodui, ir po paleidimo iš naujo jos tokios ir grįš.

Jei norite slenkamąjį išdėstymą naudoti kaip numatytąjį, galite tai nustatyti faile `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Slankiosios darbo sritys

Slankioji darbo sritis veikia kaip tradicinis darbalaukis: langai persidengia, o jūs patys juos judinate ir keičiate jų dydį. Kiekvienas langas gauna antraštės juostą jūsų temos spalvomis su mygtukais sumažinti, padidinti ir uždaryti. `Super + M` taip pat sumažina sufokusuotą langą. Sumažintas langas laukia doke; spustelėkite jo programą, kad jį grąžintumėte. Spustelėkite langą, kad iškeltumėte jį į priekį. Keiskite jo dydį nuo bet kurio krašto ar kampo. Dukart spustelėkite antraštės juostą, kad padidintumėte langą palikdami viršutinę juostą matomą, ir dar kartą, kad sugrąžintumėte seną jo dydį. Chrome ir kitos Chromium pagrindu veikiančios naršyklės, Disks ir Document Viewer praleidžia antraštės juostą ir vietoj jos naudoja savo antraštę; `Super + Alt + F` jas padidina, o `Super + M` jas sumažina.

Slankioji darbo sritis taip pat rodo doką su jūsų prisegtomis programomis, viskuo, kas veikia, ir visų programų tinkleliu už programų mygtuko, kurį taip pat atveria `Super + Alt + Space` ir _Apps_ Omarchy meniu. Dešiniuoju pelės mygtuku spustelėkite programą tinklelyje arba paspauskite `Delete`, kad ją pašalintumėte. Spustelėkite programą, kad ją atvertumėte arba iškeltumėte jos langą į priekį; spustelėkite dar kartą, kad ciklu pereitumėte per jos langus. Files grąžina tik langą iš darbo srities, kurioje esate, o kitu atveju atveria naują, o Terminal ir Agent visada paleidžia kitą, nors sumažintas langas grįžta pirmas. Vidurinis spustelėjimas atveria naują langą. Vilkite piktogramą išilgai doko, kad ją perkeltumėte; įvilkus veikiančią programą tarp kitų, ji ten lieka. Dešiniuoju pelės mygtuku spustelėkite, kad programą paliktumėte doke, ją iš jo išimtumėte arba ją uždarytumėte. Dokas pasitraukia iš kelio viso ekrano langui. Dešiniuoju pelės mygtuku spustelėkite programų mygtuką, kad perkeltumėte doką į kitą kraštą arba kad jis slėptųsi, kol žymeklis pasieks jo kraštą. Padėtis taip pat yra _Appearance > Dock > Dock Position_, o `omarchy dock position left` ir `omarchy dock autohide on` abi nustato iš terminalo. Programos, kurias laikote doke, yra pritemdytos, kol jos neveikia.

Naujos darbo sritys ir visos, kurioms nesuteikėte jų pačių išdėstymo su `Super + L`, naudoja numatytąjį išdėstymą. Pakeitus numatytąjį, kiekviena darbo sritis be langų nustatoma į jį iš naujo, o ta, kurioje yra langų, išlaiko turimą išdėstymą. Į doką sumažintas langas vis tiek laikomas langu darbo srityje, kurią jis paliko. Pasirinkite jį dalyje _Appearance > Workspace Layout_: Tiling, Scrolling arba Floating. `omarchy-hyprland-workspace-layout-default scrolling` nustato jį iš terminalo.

### Langų grupavimas

Langus galima grupuoti naudojant `Super + G`. Kai esate grupėje, kiekvienas langas, kurį paleidžiate tai būdami aktyvūs, priklausys grupei. Tarp šių sugrupuotų langų galite judėti naudodami `Super + Ctrl + Arrow Left/Right` arba `Super + Alt + 1/2/3/4`, kad pereitumėte tiesiai prie sugrupuotų langų iš eilės.

Langą iš grupavimo galite perkelti su `Super + Alt + G` arba išardyti visą grupę dar kartą paspausdami `Super + G`. Galiausiai langus už grupės ribų į ją galite perkelti su `Super + Alt + Arrows`.

### Langų iškėlimas

Langą iš jo darbo srities priskyrimo galite iškelti su `Super + O`. Tai prisegs jį kaip slankųjį langą, kuris seka jus į bet kurią darbo sritį, į kurią pereinate. Puikiai tinka vaizdo grotuvams ir panašiems.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad darbo sritis

Yra speciali viso dydžio scratchpad darbo sritis, kuri uždengia bet kurią darbo sritį, kurioje šiuo metu esate. Tai, kas joje yra, pasiekiate naudodami `Super + S`, o langus ten dedate naudodami `Super + Alt + S`.

Ji gerai tinka valdikliams ar terminalui, su kuriuo norite greitai sąveikauti nepalikdami dabartinės darbo srities.

### Quake konsolė

Galiausiai yra pusės aukščio Quake konsolė, kuri nusileidžia ant bet kurios darbo srities, kurioje šiuo metu esate. Ją perjungiate su `Super + Grave`, o langą ten dedate naudodami `Super + Shift + Grave`.

Ji atsidaro su jūsų numatytuoju agentu, paruoštu darbui. Kol konsolėje yra vienas langas, ji nusileidžia kaip centre esantis skydelis, o ne apima visą ekraną. Įdėkite į ją antrą programą ir ji grįžta į visą plotį, kad judvi turėtų vietos būti greta.

Kad langą perkeltumėte iš scratchpad arba konsolės, siųskite jį tiesiai į kitą darbo sritį su kažkuo panašiu į `Super + Shift + 1`.

### Priprasti prireiks laiko!

Prireikia šiek tiek laiko priprasti taip naršyti darbalaukį, bet kai priprasite, bus sunku grįžti prie tradicinės pele valdomos darbalaukio patirties!
