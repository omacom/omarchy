# Navigacija

Viskas Omarchy sistemoje vyksta klaviatūra — _VISKAS!_ Kai sistema pirmą kartą paleidžiama, tiesiogine prasme nieko negalite padaryti vien su pele. Bet galite paspausti `Super + Space`, kad atvertumėte Omarchy Menu, ir iš čia galite padaryti beveik viską.

Bet Omarchy meniu net nėra skirtas būti pagrindiniu sistemos valdymo būdu didžiąją laiko dalį. Galime greičiau! Visos svarbiausios programos tiesiogiai susietos su atskirais sparčiaisiais klavišais. Terminalą paleidžiate su `Super + Return`, o naršyklę — su `Super + Shift + Return`. Pabandykite padaryti vieną po kito ir pamatysite Hyprland plytelių išdėstymo magiją veikiant:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Tada galite paspausti `Super + J`, kad sudėtumėte juos vieną ant kito vietoj greta:

 ![navigation-stacked](images/navigation-stacked.webp)

Dar kartą paspauskite `Super + J`, kad grąžintumėte juos į pozicijas greta. Tada pabandykite `Super + Shift + Arrow Right` būdami naršyklėje, kad sukeistumėte langus vietomis.

Dabar pabandykite `Super + Shift + T`, kad paleistumėte Activity monitorių. Jis pasirodys kaip plaukiojantis langas. Galite jį išdėstyti plytelėmis naudodami `Super + T` (ir paspauskite tai dar kartą, kad vėl taptų plaukiojantis). Dabar paspauskite `Super + Shift + F`, kad atvertumėte failų tvarkyklę. Turėsite tvarkingą keturių langų išdėstymą:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Tarp lango, kurį norite aktyvuoti, naviguojate su `Super + Arrow`. Tai perjungs fokusą ir perkels žymeklį į naujos programos centrą. Ekrano krašte jis tęsiasi į monitorių toje pusėje.

Jei paspausite `Super + Shift + 2`, perkelsite šiuo metu fokusuotą programą į antrąją darbo sritį. `Super + Shift + 1` perkelia ją atgal. (O `Super + Shift + Alt + 2` perkels šiuo metu fokusuotą programą į antrąją darbo sritį neperjungdamas į ją).

Turint daugiau nei vieną monitorių, kiekvienas monitorius turi savo darbo sritis nuo 1 iki 10. `Super + 2` eina į monitoriaus, kuriame esate, antrąją darbo sritį, o kiekvieno monitoriaus viršutinė juosta rodo savo darbo sritis ir tą, kurią rodo. `Super + Tab` ciklu pereina per monitoriaus, kuriame esate, darbo sritis. `Super + Shift + Ctrl + Arrows` perkelia langą, kuriame esate, į monitorių ta kryptimi, į darbo sritį, kurią jis rodo, o `Super + Shift + Alt + Arrows` perkelia darbo sritį, kurioje esate, į monitorių ta kryptimi, kur ji gauna tą patį numerį, jei jis laisvas. Monitorius išlaiko savo darbo sritis, kai jį atjungiate: jos prisijungia prie kito ekrano, sunumeruotos po tų, kurias jis jau turi, ir grįžta su senaisiais numeriais, kai monitorius grįžta.

Jei laikote nuspaudę `Super` ir pele spustelėjate langą, galėsite pertvarkyti, kur jis yra. Jei laikote `Super` ir naudojate dešinįjį pelės mygtuką, galite laisvai keisti lango dydį.

Langą uždarote su `Super + W` arba `Super + Q` (o visus langus uždarote su `Ctrl + Alt + Delete`).

Taip pat galite pereiti į viso ekrano režimą su `Super + F` arba net tiesiog per visą plotį (išlaikydami viršutinę juostą) su `Super + Alt + F`, arba viso ekrano režimą lange su `Super + Ctrl + F` (gerai YouTube!).

### Dwindle ir slenkamasis išdėstymas

Omarchy numatytasis išdėstymas vadinamas dwindle. Jis išlaiko visus langus, kuriuos atveriate vienoje darbo srityje, matomus visą laiką, net jei turi juos sumažinti.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Bet taip pat galite pasirinkti paversti darbo sritį slenkamuoju išdėstymu, kur langai išrikiuoti greta, už matomo ekrano krašto. Vieną darbo sritį į šį išdėstymą paverčiate su `Super + L`.

Dar kartą paspaudus `Super + L`, darbo sritis tampa plaukiojanti, kur langai laisvai persidengia ir jūs juos išdėstote patys, o trečias paspaudimas grąžina ją į dwindle. `Super + Alt + L` pereina per juos kita kryptimi. Langas, kuris bet kokiu atveju plaukioja — toks, kurį iškėlėte su `Super + T`, arba programa, kuri visada atsidaro plaukiojanti — lieka plaukiojantis, kai darbo sritis grįžta į plytelių išdėstymą. Viršutinė juosta pažymi darbo sritį, kurioje esate, jos išdėstymu: kvadratas dwindle, apskritimas slenkamajam ir trikampis plaukiojančiam. Spustelėjus tą ženklą, išdėstymas taip pat keičiamas ciklu.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Pasirinkimas yra kiekvienai darbo sričiai atskirai, ir jis išlieka. Taigi galite laikyti 1 darbo sritį su dwindle naršymui, o 2 darbo sritį su slenkamuoju kodui, ir jos grįš tokios po paleidimo iš naujo.

Jei norite naudoti slenkamąjį išdėstymą kaip numatytąjį, galite tai nustatyti `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plaukiojančios darbo sritys

Plaukiojanti darbo sritis veikia kaip tradicinis darbalaukis: langai persidengia, o jūs juos perkeliate ir keičiate jų dydį patys. Kiekvienas langas gauna pavadinimo juostą jūsų temos spalvomis, su mygtukais sumažinti, padidinti ir uždaryti. `Super + M` taip pat sumažina fokusuotą langą. Sumažintas langas laukia doke; spustelėkite jo programą, kad grąžintumėte jį atgal. Spustelėkite langą, kad iškeltumėte jį į priekį. Keiskite jo dydį nuo bet kurio krašto ar kampo. Dukart spustelėkite pavadinimo juostą, kad padidintumėte langą išlaikydami viršutinę juostą matomą, ir dar kartą, kad grąžintumėte senąjį dydį.

Plaukiojanti darbo sritis taip pat rodo doką su jūsų prisegtomis programomis, viskuo, kas veikia, ir kiekvienos programos tinkleliu už programų mygtuko, kurį taip pat atveria `Super + Alt + Space` ir _Apps_ Omarchy meniu. Dešiniuoju pelės mygtuku spustelėkite programą tinklelyje arba paspauskite `Delete`, kad ją pašalintumėte. Spustelėkite programą, kad ją atvertumėte arba iškeltumėte jos langą į priekį; spustelėkite dar kartą, kad ciklu pereitumėte per jos langus. Vidurinis spustelėjimas atveria naują langą. Vilkite piktogramą išilgai doko, kad ją perkeltumėte; įvilkus veikiančią programą tarp kitų, ji ten lieka. Dešiniuoju pelės mygtuku spustelėkite, kad paliktumėte programą doke, išimtumėte ją arba uždarytumėte ją. Dokas pasitraukia iš kelio viso ekrano langui. Dešiniuoju pelės mygtuku spustelėkite programų mygtuką, kad perkeltumėte doką prie kito krašto arba kad jis slėptųsi, kol žymeklis pasieks jo kraštą. Pozicija taip pat yra _Appearance > Dock > Dock Position_, o `omarchy dock position left` ir `omarchy dock autohide on` nustato abu iš terminalo. Programos, kurias laikote doke, yra pritemdytos, kol jos neveikia.

Naujos darbo sritys ir bet kuri, kuriai nesuteikėte savo išdėstymo su `Super + L`, naudoja numatytąjį išdėstymą. Pakeitus numatytąjį, kiekviena darbo sritis be langų nustatoma į jį iš naujo, o ta, kurioje yra langų, išlaiko turimą išdėstymą. Langas, sumažintas į doką, vis tiek laikomas langu darbo srityje, kurią jis paliko. Pasirinkite jį _Appearance > Workspace Layout_: Tiling, Scrolling arba Floating. `omarchy-hyprland-workspace-layout-default scrolling` nustato jį iš terminalo.

### Langų grupavimas

Langus galima grupuoti naudojant `Super + G`. Kai esate grupėje, kiekvienas langas, kurį paleidžiate, kol tai aktyvu, priklausys grupei. Galite judėti tarp šių sugrupuotų langų naudodami `Super + Ctrl + Arrow Left/Right` arba `Super + Alt + 1/2/3/4`, kad eitumėte tiesiai į sugrupuotus langus eilės tvarka.

Galite perkelti langą iš grupavimo su `Super + Alt + G` arba išardyti visą grupę dar kartą paspausdami `Super + G`. Galiausiai galite perkelti langus už grupės ribų į ją su `Super + Alt + Arrows`.

### Langų iškėlimas

Galite iškelti langą iš jo darbo srities paskyrimo su `Super + O`. Tai prisegs jį kaip plaukiojantį langą, kuris seka jus, į kurią darbo sritį beeitumėte. Puiku vaizdo grotuvams ir panašiems dalykams.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad darbo sritis

Yra speciali viso dydžio scratchpad darbo sritis, kuri uždengia bet kurią darbo sritį, kurioje šiuo metu esate. Pasiekiate, kas joje yra, naudodami `Super + S`, o langus ten dedate naudodami `Super + Alt + S`.

Ji gerai veikia valdikliams ar terminalui, su kuriuo norite greitai sąveikauti nepalikdami dabartinės darbo srities.

### Quake konsolė

Galiausiai yra pusės aukščio Quake konsolė, kuri nusileidžia virš bet kurios darbo srities, kurioje šiuo metu esate. Perjunkite ją su `Super + Grave`, o langą ten padėkite naudodami `Super + Shift + Grave`.

Ji atsidaro su jūsų numatytuoju agentu, paruoštu darbui. Kol konsolėje yra vienas langas, ji nusileidžia kaip centruotas skydelis, o ne apima ekraną. Padėkite joje antrą programą ir ji grįžta į visą plotį, kad abu turėtų vietos būti greta.

Norėdami perkelti langą iš scratchpad arba konsolės, siųskite jį tiesiai į kitą darbo sritį su kažkuo panašiu į `Super + Shift + 1`.

### Reikia šiek tiek priprasti!

Reikia šiek tiek laiko priprasti naršyti darbalaukį taip, bet kai priprasite, bus sunku grįžti prie tradicinės pele valdomos darbalaukio patirties!
