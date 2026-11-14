# Navigacija

Viskas Omarchy sistemoje vyksta klaviatūra — _VISKAS!_ Kai sistema paleidžiama pirmą kartą, tiesiogine prasme nieko negalėsite padaryti vien pele. Bet galite paspausti `Super + Space`, kad atvertumėte Omarchy meniu, o iš čia galėsite padaryti beveik viską.

Tačiau Omarchy meniu net nėra skirtas būti pagrindiniu sistemos valdymo būdu didžiąją laiko dalį. Galime dar greičiau! Visos svarbiausios programos yra tiesiogiai pririštos prie atskirų sparčiųjų klavišų. Terminalą paleidžiate su `Super + Return`, o naršyklę — su `Super + Shift + Return`. Pabandykite paspausti vieną po kito ir pamatysite Hyprland plytelių išdėstymo magiją veikiant:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Tada galite paspausti `Super + J`, kad sudėtumėte juos vieną ant kito, o ne greta:

 ![navigation-stacked](images/navigation-stacked.webp)

Paspauskite `Super + J` dar kartą, kad grąžintumėte juos į padėtį greta. Tada, būdami naršyklėje, pabandykite `Super + Shift + Arrow Right`, kad sukeistumėte langus vietomis.

Dabar pabandykite `Super + Shift + T`, kad paleistumėte Activity monitor. Jis pasirodys kaip slankusis langas. Galite jį paversti plytele naudodami `Super + T` (ir paspaudę tai dar kartą vėl padarysite jį slankųjį). Dabar paspauskite `Super + Shift + F`, kad atvertumėte failų tvarkyklę. Turėsite tvarkingą keturių dalių išdėstymą:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Tarp langų, kad aktyvuotumėte norimą, judate naudodami `Super + Arrow`. Tai perjungia fokusą ir perkelia žymeklį į naujos programos centrą. Prie ekrano krašto judėjimas tęsiasi į toje pusėje esantį monitorių.

Jei paspausite `Super + Shift + 2`, perkelsite šiuo metu fokusuotą programą į antrąją darbo sritį. `Super + Shift + 1` perkelia ją atgal. (O `Super + Shift + Alt + 2` perkels šiuo metu fokusuotą programą į antrąją darbo sritį neperjungdamas į ją).

Turint daugiau nei vieną monitorių, kiekvienas monitorius turi savo darbo sritis nuo 1 iki 10. `Super + 2` nukelia į antrąją monitoriaus, kuriame esate, darbo sritį, o kiekvieno monitoriaus viršutinė juosta rodo jo paties darbo sritis ir tą, kurią jis rodo. `Super + Tab` ciklais pereina per monitoriaus, kuriame esate, darbo sritis. `Super + Shift + Ctrl + Arrows` perkelia langą, kuriame esate, į monitorių ta kryptimi, į jo rodomą darbo sritį, o `Super + Shift + Alt + Arrows` perkelia darbo sritį, kurioje esate, į monitorių ta kryptimi, kur ji gauna tą patį numerį, jei jis laisvas. Monitorius išsaugo savo darbo sritis, kai jį atjungiate: jos prisijungia prie kito ekrano, sunumeruotos po tų, kurias jis jau turi, ir grįžta su senaisiais numeriais, kai monitorius sugrįžta.

Jei laikysite nuspaudę `Super` ir pele spustelėsite langą, galėsite pakeisti, kur jis yra. Jei laikysite `Super` ir naudosite dešinįjį pelės mygtuką, galėsite laisvai keisti lango dydį.

Langą uždarote su `Super + W` arba `Super + Q` (o visus langus uždarote su `Ctrl + Alt + Delete`).

Taip pat galite pereiti į viso ekrano režimą su `Super + F` arba tiesiog į viso pločio režimą (paliekant viršutinę juostą) su `Super + Alt + F`, arba į viso ekrano režimą lange su `Super + Ctrl + F` (tinka YouTube!).

### Dwindle prieš slenkamąjį išdėstymą

Numatytasis Omarchy išdėstymas vadinamas dwindle. Jis visą laiką išlaiko visus langus, kuriuos atidarote vienoje darbo srityje, matomus, net jei tenka juos sumažinti.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Tačiau taip pat galite pasirinkti darbo sritį paversti slenkamuoju išdėstymu, kuriame langai išrikiuoti greta, už matomo ekrano krašto. Vieną darbo sritį į šį išdėstymą paverčiate naudodami `Super + L`.

Paspaudus `Super + L` dar kartą, darbo sritis tampa slankiąja, kurioje langai laisvai persidengia ir jūs juos dėliojate patys, o trečias paspaudimas grąžina ją į dwindle. `Super + Alt + L` pereina per juos priešinga kryptimi. Langas, kuris ir taip yra slankusis — toks, kurį iškėlėte su `Super + T`, arba programa, kuri visada atsidaro kaip slankioji — lieka slankusis, kai darbo sritis grįžta į plytelių išdėstymą. Viršutinė juosta pažymi darbo sritį, kurioje esate, jos išdėstymu: kvadratas reiškia dwindle, apskritimas — slenkamąjį, o trikampis — slankųjį. Spustelėjus tą ženklą, išdėstymas taip pat keičiamas ciklais.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Pasirinkimas taikomas kiekvienai darbo sričiai atskirai ir išlieka. Taigi darbo sritį 1 galite laikyti dwindle režime naršymui, o darbo sritį 2 — slenkamajame režime kodui, ir po paleidimo iš naujo jos sugrįš tokios pačios.

Jei norite naudoti slenkamąjį išdėstymą kaip numatytąjį, galite tai nustatyti faile `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Slankiosios darbo sritys

Slankioji darbo sritis veikia kaip įprastas darbalaukis: langai persidengia, o jūs juos judinate ir keičiate jų dydį patys. Kiekvienas langas gauna antraštės juostą jūsų temos spalvomis, su mygtukais sumažinti, padidinti ir uždaryti. `Super + M` taip pat sumažina fokusuotą langą. Sumažintas langas laukia doke; spustelėkite jo programą, kad jį sugrąžintumėte. Spustelėkite langą, kad iškeltumėte jį į priekį. Keiskite jo dydį nuo bet kurio krašto ar kampo. Dukart spustelėkite antraštės juostą, kad padidintumėte langą, palikdami viršutinę juostą matomą, ir dar kartą, kad atgautumėte senąjį dydį. Chrome ir kitos Chromium pagrindu veikiančios naršyklės, Disks ir Document Viewer praleidžia antraštės juostą ir vietoj jos naudoja savo antraštę; `Super + Alt + F` jas padidina, o `Super + M` jas sumažina.

Slankioji darbo sritis taip pat rodo doką su jūsų prisegtomis programomis, viskuo, kas veikia, ir visų programų tinkleliu už programų mygtuko, kurį taip pat atveria `Super + Alt + Space` ir _Programos_ Omarchy meniu. Dešiniuoju pelės mygtuku spustelėkite programą tinklelyje arba paspauskite `Delete`, kad ją pašalintumėte. Spustelėkite programą, kad ją atvertumėte arba iškeltumėte jos langą į priekį; spustelėkite dar kartą, kad ciklais pereitumėte per jos langus. Vidurinis spustelėjimas atveria naują langą. Vilkite piktogramą išilgai doko, kad ją perkeltumėte; nutempus veikiančią programą tarp kitų, ji ten pasiliks. Dešiniuoju pelės mygtuku spustelėkite, kad programą laikytumėte doke, ją iš jo išimtumėte arba ją uždarytumėte. Dokas pasitraukia iš kelio viso ekrano langui. Dešiniuoju pelės mygtuku spustelėkite programų mygtuką, kad doką perkeltumėte prie kito krašto arba kad jis slėptųsi, kol žymeklis pasieks jo kraštą. Padėtis taip pat yra skiltyje _Išvaizda > Dokas > Doko padėtis_, o `omarchy dock position left` ir `omarchy dock autohide on` abu nustato iš terminalo. Programos, kurias laikote doke, yra pritemdytos, kol jos neveikia.

Naujos darbo sritys ir bet kuri, kuriai nesate suteikę savo išdėstymo su `Super + L`, naudoja numatytąjį išdėstymą. Pakeitus numatytąjį, kiekviena darbo sritis be langų nustatoma į jį iš naujo, o ta, kurioje yra langų, išlaiko turimą išdėstymą. Langas, sumažintas į doką, vis tiek laikomas langu darbo srityje, kurią paliko. Pasirinkite jį skiltyje _Išvaizda > Darbo srities išdėstymas_: Plytelės, Slenkamasis arba Slankusis. `omarchy-hyprland-workspace-layout-default scrolling` nustato jį iš terminalo.

### Langų grupavimas

Langus galima grupuoti naudojant `Super + G`. Kai esate grupėje, kiekvienas langas, kurį paleidžiate, kol ji aktyvi, priklausys grupei. Tarp šių sugrupuotų langų galite judėti naudodami `Super + Ctrl + Arrow Left/Right` arba `Super + Alt + 1/2/3/4`, kad pereitumėte tiesiai prie sugrupuotų langų iš eilės.

Langą iš grupavimo galite iškelti naudodami `Super + Alt + G` arba išardyti visą grupę dar kartą paspaudę `Super + G`. Galiausiai langus, esančius už grupės ribų, galite perkelti į ją naudodami `Super + Alt + Arrows`.

### Langų iškėlimas

Langą iš jo darbo srities priskyrimo galite iškelti naudodami `Super + O`. Tai prisegs jį kaip slankųjį langą, kuris seka jus į bet kurią darbo sritį, į kurią einate. Puikiai tinka vaizdo grotuvams ir panašiems dalykams.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad darbo sritis

Egzistuoja speciali viso dydžio scratchpad darbo sritis, kuri uždengia bet kurią darbo sritį, kurioje šiuo metu esate. Tai, kas joje yra, pasiekiate naudodami `Super + S`, o langus ten dedate naudodami `Super + Alt + S`.

Ji puikiai tinka valdikliams arba terminalui, su kuriuo norite greitai sąveikauti nepalikdami dabartinės darbo srities.

### Quake konsolė

Galiausiai yra pusės aukščio Quake konsolė, kuri nusileidžia virš bet kurios darbo srities, kurioje šiuo metu esate. Ją perjungiate naudodami `Super + Grave`, o langą ten dedate naudodami `Super + Shift + Grave`.

Ji atsidaro su jūsų numatytuoju agentu, paruoštu darbui. Kol konsolėje yra vienas langas, ji nusileidžia kaip centre esantis skydelis, o ne apima visą ekraną. Padėkite joje antrą programą ir ji grįš į visą plotį, kad abi turėtų vietos būti greta.

Norėdami perkelti langą iš scratchpad arba konsolės, nusiųskite jį tiesiai į kitą darbo sritį naudodami ką nors panašaus į `Super + Shift + 1`.

### Reikia šiek tiek priprasti!

Užtrunka šiek tiek, kol priprantate taip naršyti darbalaukyje, bet kai priprasite, bus sunku grįžti prie įprastos pele valdomos darbalaukio patirties!
