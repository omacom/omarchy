# Navigacija

Visa Omarchy valdoma klaviatūra — _VISKAS!_ Kai sistema paleidžiama pirmą kartą, vien pele tiesiog nieko negalite padaryti. Tačiau galite paspausti `Super + Space`, kad atvertumėte Omarchy meniu, o iš čia galite padaryti beveik viską.

Tačiau Omarchy meniu net nėra numatytas kaip pagrindinis sistemos valdymo būdas dažniausiai. Galime dar greičiau! Visos svarbiausios programos tiesiogiai susietos su atskirais sparčiaisiais klavišais. Terminalą paleidžiate su `Super + Return`, o naršyklę — su `Super + Shift + Return`. Pabandykite tai padaryti viena po kitos ir pamatysite Hyprland plytelių išdėstymo magiją:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Tada galite paspausti `Super + J`, kad sudėtumėte juos vienas ant kito, o ne vieną šalia kito:

 ![navigation-stacked](images/navigation-stacked.webp)

Dar kartą paspauskite `Super + J`, kad grąžintumėte juos į padėtį vieną šalia kito. Tada, būdami naršyklėje, pabandykite `Super + Shift + Arrow Right` langams sukeisti.

Dabar pabandykite `Super + Shift + T`, kad paleistumėte aktyvumo stebėjimo priemonę Activity. Ji pasirodys kaip plaukiojantis langas. Galite jį paversti plytele naudodami `Super + T` (ir paspausti dar kartą, kad vėl būtų plaukiojantis). Dabar paspauskite `Super + Shift + F`, kad atvertumėte failų tvarkytuvę. Turėsite dailų keturių dalių išdėstymą:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Tarp langų, kurį norite padaryti aktyvų, judate su `Super + Arrow`. Tai perkelia židinį ir perkelia žymeklį į naujos programos centrą. Ekrano krašte jis tęsiasi į monitorių toje pusėje.

Jei paspausite `Super + Shift + 2`, perkelsite šiuo metu sufokusuotą programą į antrą darbo erdvę. `Super + Shift + 1` ją grąžina atgal. (O `Super + Shift + Alt + 2` perkels šiuo metu sufokusuotą programą į antrą darbo erdvę nepersijungdamas į ją).

Kai monitorių daugiau nei vienas, kiekvienas monitorius turi savo darbo erdves nuo 1 iki 10. `Super + 2` pereina į antrą monitoriaus, kuriame esate, darbo erdvę, o kiekvieno monitoriaus viršutinė juosta rodo savo darbo erdves ir tą, kurią rodo. `Super + Tab` cikliškai perjungia monitoriaus, kuriame esate, darbo erdves. `Super + Shift + Ctrl + Arrows` perkelia langą, kuriame esate, į monitorių ta kryptimi, į jo rodomą darbo erdvę, o `Super + Shift + Alt + Arrows` perkelia darbo erdvę, kurioje esate, į monitorių ta kryptimi, kur ji gauna tą patį numerį, jei jis laisvas. Monitorius išlaiko savo darbo erdves, kai jį atjungiate: jos prisijungia prie kito ekrano, sunumeruotos po tų, kurias jis jau turi, ir grįžta su senais numeriais, kai monitorius sugrįžta.

Jei laikysite nuspaudę `Super` ir pele spustelėsite langą, galėsite pertvarkyti, kur jis yra. Jei laikysite `Super` ir naudosite dešinįjį pelės mygtuką, galėsite laisvai keisti lango dydį.

Langą uždarote su `Super + W` arba `Super + Q` (o visus langus uždarote su `Ctrl + Alt + Delete`).

Taip pat galite pereiti į viso ekrano režimą su `Super + F` arba net tiesiog į viso pločio režimą (palikdami viršutinę juostą) su `Super + Alt + F`, arba į viso ekrano režimą lange su `Super + Ctrl + F` (tinka YouTube!).

### „Dwindle“ ir slenkamasis išdėstymas

Numatytasis Omarchy išdėstymas vadinamas dwindle. Jis visą laiką laiko visus langus, kuriuos atveriate vienoje darbo erdvėje, matomus, net jei turi juos sumažinti.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Tačiau taip pat galite pasirinkti darbo erdvę paversti slenkamuoju išdėstymu, kuriame langai išrikiuoti vienas šalia kito už matomo ekrano krašto. Vieną darbo erdvę į šį išdėstymą paverčiate naudodami `Super + L`.

Dar kartą paspaudus `Super + L`, darbo erdvė tampa plaukiojanti, kur langai laisvai persidengia ir jūs patys juos išdėstote, o trečias paspaudimas grąžina ją į dwindle. `Super + Alt + L` pereina per juos priešinga kryptimi. Langas, kuris bet kuriuo atveju plaukioja — toks, kurį iškėlėte su `Super + T`, arba programa, kuri visada atsidaro plaukiojanti — lieka plaukiojantis, kai darbo erdvė grįžta į plytelių režimą. Viršutinė juosta žymi darbo erdvę, kurioje esate, jos išdėstymu: kvadratas reiškia dwindle, apskritimas — slenkamąjį, o trikampis — plaukiojantį. Spustelėjus tą ženklą, išdėstymas taip pat keičiamas cikliškai, o taip pat tai daro ir ekrano klavišas nešiojamuosiuose kompiuteriuose, kurie jį turi.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Pasirinkimas yra kiekvienai darbo erdvei atskiras ir išlieka. Taigi darbo erdvę 1 galite laikyti dwindle režime naršymui, o darbo erdvę 2 — slenkamajame kodui, ir jos taip sugrįš po paleidimo iš naujo.

Jei norite slenkamąjį išdėstymą naudoti kaip numatytąjį, galite tai nustatyti faile `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plaukiojančios darbo erdvės

Plaukiojanti darbo erdvė veikia kaip tradicinis darbalaukis: langai persidengia, o jūs patys juos perkeliate ir keičiate jų dydį. Kiekvienas langas gauna pavadinimo juostą jūsų temos spalvomis su mygtukais sumažinti, padidinti ir uždaryti. `Super + M` taip pat sumažina sufokusuotą langą. Sumažintas langas laukia doke; spustelėkite jo programą, kad jį grąžintumėte. Spustelėkite langą, kad iškeltumėte jį į priekį. Keiskite jo dydį nuo bet kurio krašto ar kampo. Dukart spustelėkite pavadinimo juostą, kad padidintumėte langą palikdami viršutinę juostą matomą, ir dar kartą, kad grąžintumėte seną jo dydį. Chrome ir kitos Chromium pagrindu veikiančios naršyklės, Disks ir Document Viewer pavadinimo juostą praleidžia ir vietoj jos naudoja savo antraštę; `Super + Alt + F` jas padidina, o `Super + M` jas sumažina.

Plaukiojanti darbo erdvė taip pat rodo doką su jūsų prisegtomis programomis, viskuo, kas veikia, ir visų programų tinkleliu už programų mygtuko, kurį taip pat atveria `Super + Alt + Space` ir _Apps_ Omarchy meniu. Dešiniuoju pelės mygtuku spustelėkite programą tinklelyje arba paspauskite `Delete`, kad ją pašalintumėte. Spustelėkite programą, kad ją atvertumėte arba iškeltumėte jos langą į priekį; spustelėkite dar kartą, kad cikliškai pereitumėte per jos langus. Files grąžina langą tik iš darbo erdvės, kurioje esate, ir priešingu atveju atveria naują, o Terminal ir Agent visada paleidžia kitą, nors sumažintas langas grįžta pirmas. Viduriniuoju spustelėjimu atveriamas naujas langas. Vilkite piktogramą išilgai doko, kad ją perkeltumėte; įvilkus veikiančią programą tarp kitų, ji ten lieka. Dešiniuoju pelės mygtuku spustelėkite, kad programą paliktumėte doke, išimtumėte ją arba uždarytumėte. Dokas pasitraukia iš kelio viso ekrano langui. Dešiniuoju pelės mygtuku spustelėkite programų mygtuką, kad doką perkeltumėte į kitą kraštą arba kad jis slėptųsi, kol žymeklis pasieks jo kraštą. Padėtis taip pat yra skiltyje _Appearance > Dock > Dock Position_, o `omarchy dock position left` ir `omarchy dock autohide on` abi nustato iš terminalo. Programos, kurias laikote doke, yra pritemdytos, kol neveikia.

Naujos darbo erdvės ir visos, kurioms nesuteikėte savo išdėstymo su `Super + L`, naudoja numatytąjį išdėstymą. Pakeitus numatytąjį, kiekviena darbo erdvė be langų nustatoma iš naujo į jį, o ta, kurioje yra langų, išlaiko turimą išdėstymą. Į doką sumažintas langas vis tiek laikomas langu darbo erdvėje, kurią paliko. Pasirinkite jį skiltyje _Appearance > Workspace Layout_: Tiling, Scrolling arba Floating. `omarchy hyprland workspace layout default scrolling` nustato jį iš terminalo.

### Langų grupavimas

Langus galima grupuoti naudojant `Super + G`. Kai esate grupėje, kiekvienas langas, kurį paleidžiate, kol ji aktyvi, priklausys grupei. Tarp šių sugrupuotų langų galite judėti naudodami `Super + Ctrl + Arrow Left/Right` arba `Super + Alt + 1/2/3/4`, kad pereitumėte tiesiai prie sugrupuotų langų eilės tvarka.

Langą iš grupavimo galite perkelti naudodami `Super + Alt + G` arba išardyti visą grupę dar kartą paspausdami `Super + G`. Galiausiai langus už grupės ribų į ją galite perkelti su `Super + Alt + Arrows`.

### Langų iškėlimas

Langą iš jo darbo erdvės paskirstymo galite iškelti su `Super + O`. Tai jį prisegs kaip plaukiojantį langą, kuris seka jus, į kurią darbo erdvę benueitumėte. Puikiai tinka vaizdo leistuvams ir panašiems dalykams.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Laikinosios darbo erdvės (scratchpad)

Yra speciali viso dydžio laikinoji darbo erdvė, kuri uždengia bet kurią darbo erdvę, kurioje šiuo metu esate. Kas joje yra, pasiekiate naudodami `Super + S`, o langus ten dedate naudodami `Super + Alt + S`.

Ji gerai tinka valdikliams ar terminalui, su kuriuo norite greitai sąveikauti nepalikdami dabartinės darbo erdvės.

### „Quake“ konsolė

Galiausiai yra pusės aukščio „Quake“ konsolė, kuri nusileidžia virš bet kurios darbo erdvės, kurioje šiuo metu esate. Ją perjungiate su `Super + the key above Tab` (JAV išdėstymuose — grave), o langą ten dedate naudodami `Super + Shift + the key above Tab`.

Pirmą kartą atsidariusi ji paleidžia jūsų numatytąjį agentą arba paprašo pasirinkti vieną, jei dar nepasirinkote. Kol konsolėje yra vienas langas, ji nusileidžia kaip centre esantis skydelis, o ne per visą ekraną. Įdėkite į ją antrą programą ir ji grįžta į visą plotį, kad abi turėtų vietos būti viena šalia kitos.

Norėdami langą perkelti iš laikinosios darbo erdvės ar konsolės, nusiųskite jį tiesiai į kitą darbo erdvę su kažkuo panašiu į `Super + Shift + 1`.

### Priprasti prireiks laiko!

Prireikia šiek tiek laiko priprasti taip naršyti darbalaukyje, bet kai priprasite, bus sunku grįžti prie tradicinės pele valdomos darbalaukio patirties!
