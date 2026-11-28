# Navigacija

Viskas Omarchy sistemoje vyksta klaviatūra — _VISKAS!_ Kai sistema paleidžiama pirmą kartą, vien pele tiesiogine prasme nieko negalite padaryti. Tačiau galite paspausti `Super + Space`, kad atvertumėte Omarchy meniu, o iš čia galite padaryti beveik viską.

Bet Omarchy meniu net nėra skirtas būti pagrindinis būdas valdyti sistemą didžiąją laiko dalį. Galime dar greičiau! Visos svarbiausios programos tiesiogiai susietos su atskirais sparčiaisiais klavišais. Terminalą paleidžiate paspaudę `Super + Return`, o naršyklę — `Super + Shift + Return`. Pabandykite tai padaryti vieną po kito ir pamatysite veikiančią Hyprland langų išdėstymo plytelėmis magiją:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Tada galite paspausti `Super + J`, kad sudėtumėte juos vieną ant kito, o ne vieną šalia kito:

 ![navigation-stacked](images/navigation-stacked.webp)

Paspauskite `Super + J` dar kartą, kad grąžintumėte juos į padėtį vieną šalia kito. Tada, būdami naršyklėje, pabandykite `Super + Shift + Arrow Right`, kad sukeistumėte langus vietomis.

Dabar pabandykite `Super + Shift + T`, kad paleistumėte veiklos monitorių. Jis pasirodys kaip plaukiojantis langas su antraštės juosta, už kurios jį galima vilkti, ir mygtukais jam sumažinti, padidinti ir uždaryti. Tokią juostą gauna kiekvienas plaukiojantis langas, kad ir kur jis būtų. Galite jį išdėstyti plytelėmis naudodami `Super + T` (ir paspauskite tai dar kartą, kad jis vėl taptų plaukiojantis). Dabar paspauskite `Super + Shift + F`, kad atvertumėte failų tvarkyklę. Turėsite tvarkingą keturių langų išdėstymą:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Tarp langų, kad suaktyvintumėte norimą, judate su `Super + Arrow`. Tai perjungia aktyvų langą ir perkelia žymeklį į naujos programos centrą. Ekrano krašte jis tęsiasi į toje pusėje esantį monitorių.

Jei paspausite `Super + Shift + 2`, perkelsite šiuo metu aktyvią programą į antrą darbo erdvę. `Super + Shift + 1` perkelia ją atgal. (O `Super + Shift + Alt + 2` perkels šiuo metu aktyvią programą į antrą darbo erdvę neperjungdamas į ją).

Kai monitorių yra daugiau nei vienas, kiekvienas monitorius turi savo darbo erdves nuo 1 iki 10. `Super + 2` eina į antrą jūsų esamo monitoriaus darbo erdvę, o kiekvieno monitoriaus viršutinė juosta rodo jo paties darbo erdves ir tą, kurią jis rodo. `Super + Tab` ciklu pereina per jūsų esamo monitoriaus darbo erdves. `Super + Shift + Ctrl + Arrows` perkelia langą, su kuriuo dirbate, į monitorių ta kryptimi, į jo rodomą darbo erdvę, o `Super + Shift + Alt + Arrows` perkelia darbo erdvę, kurioje esate, į monitorių ta kryptimi, kur ji gauna tą patį numerį, jei jis laisvas. Monitorius išlaiko savo darbo erdves, kai jį atjungiate: jos prisijungia prie kito ekrano, sunumeruotos po tų, kurias jis jau turi, ir grįžta su senais numeriais, kai monitorius sugrįžta.

Jei laikysite nuspaudę `Super` ir pele spustelėsite langą, galėsite pertvarkyti, kur jis yra. Jei laikysite `Super` ir naudosite dešinįjį pelės mygtuką, galėsite laisvai keisti lango dydį.

Langą uždarote su `Super + W` arba `Super + Q` (o visus langus uždarote su `Ctrl + Alt + Delete`).

Taip pat galite pereiti į viso ekrano režimą su `Super + F` arba net tiesiog į viso pločio režimą (palikdami viršutinę juostą) su `Super + Alt + F`, arba į viso ekrano režimą lange su `Super + Ctrl + F` (puikiai tinka YouTube!).

### Dwindle prieš slenkantį išdėstymą

Numatytasis Omarchy išdėstymas vadinamas dwindle. Jis visą laiką laiko visus vienoje darbo erdvėje atvertus langus matomus, net jei tenka juos sumažinti.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Bet taip pat galite pasirinkti darbo erdvę paversti slenkančiu išdėstymu, kuriame langai išrikiuoti vienas šalia kito už matomo ekrano krašto. Vieną darbo erdvę į šį išdėstymą perjungiate su `Super + L`.

Paspaudus `Super + L` dar kartą, darbo erdvė tampa plaukiojanti, kurioje langai laisvai persidengia ir juos išdėstote patys, o trečias paspaudimas grąžina ją į dwindle. `Super + Alt + L` pereina per juos priešinga kryptimi. Langas, kuris ir taip plaukioja — toks, kurį iškėlėte su `Super + T`, arba programa, kuri visada atsidaro plaukiojanti — lieka plaukiojantis, kai darbo erdvė grįžta į išdėstymą plytelėmis. Viršutinė juosta pažymi darbo erdvę, kurioje esate, jos išdėstymu: kvadratas reiškia dwindle, apskritimas — slenkantį, o trikampis — plaukiojantį. Spustelėjus tą ženklą, išdėstymas taip pat keičiamas ciklu, ir tą patį daro ekrano klavišas nešiojamuosiuose kompiuteriuose, kurie tokį turi.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Pasirinkimas taikomas kiekvienai darbo erdvei atskirai ir išlieka. Taigi galite palikti 1 darbo erdvę su dwindle naršymui, o 2 darbo erdvę su slenkančiu išdėstymu kodui, ir jos taip sugrįš po paleidimo iš naujo.

Jei norite slenkantį išdėstymą naudoti kaip numatytąjį, galite tai nustatyti faile `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plaukiojančios darbo erdvės

Plaukiojanti darbo erdvė veikia kaip tradicinis darbalaukis: langai persidengia, o jūs juos perkeliate ir keičiate jų dydį patys. Kiekvienas langas gauna antraštės juostą jūsų temos spalvomis su mygtukais sumažinti, padidinti ir uždaryti. `Super + M` taip pat sumažina aktyvų langą. Sumažintas langas laukia doke; spustelėkite jo programą, kad jį susigrąžintumėte. Spustelėkite langą, kad iškeltumėte jį į priekį. Keiskite jo dydį nuo bet kurio krašto ar kampo. Dukart spustelėkite antraštės juostą, kad padidintumėte langą palikdami viršutinę juostą matomą, ir dar kartą, kad grąžintumėte seną jo dydį. Chrome ir kitos Chromium pagrindu veikiančios naršyklės, Disks ir Document Viewer praleidžia antraštės juostą ir vietoj jos naudoja savo antraštę; `Super + Alt + F` jas padidina, o `Super + M` jas sumažina.

Kiekviena darbo erdvė turi doką su jūsų prisegtomis programomis, viskuo, kas šiuo metu veikia, ir visų programų tinkleliu už programų mygtuko, kurį taip pat atveria `Super + Alt + Space` ir _Apps_ Omarchy meniu. Dešiniuoju pelės mygtuku spustelėkite programą tinklelyje arba paspauskite `Delete`, kad ją pašalintumėte. Spustelėkite programą, kad ją atvertumėte arba iškeltumėte jos langą į priekį; spustelėkite dar kartą, kad ciklu pereitumėte per jos langus. Files susigrąžina langą tik iš darbo erdvės, kurioje esate, o kitu atveju atveria naują, o Terminal ir Agent visada paleidžia dar vieną, nors sumažintas langas pirmiausia sugrįžta. Vidurinis spustelėjimas atveria naują langą. Vilkite piktogramą išilgai doko, kad ją perkeltumėte; įvilkus veikiančią programą tarp kitų, ji ten lieka. Dešiniuoju pelės mygtuku spustelėkite, kad programą paliktumėte doke, išimtumėte ją iš jo arba uždarytumėte. Dokas lieka matomas, kol darbo erdvė tuščia, o kai darbo erdvėje atsiranda langas, jis slepiasi, kol žymeklis pasiekia jo kraštą. Viso ekrano langas jį paslepia visiškai. Vilkite programų mygtuką link kito ekrano krašto, kad doką perkeltumėte ten. Dešiniuoju pelės mygtuku spustelėkite jį ir pasirinkite _Position_, kad pasirinktumėte kraštą, ir _Layout_, kad nustatytumėte numatytąjį išdėstymą, kaip tai daro _Appearance > Workspace Layout_. Padėtis taip pat yra skiltyje _Appearance > Dock > Dock Position_, o `omarchy dock position left` ją nustato iš terminalo. Programos, kurias laikote doke, yra pritemdytos, kol neveikia. Kad dokas liktų tik plaukiojančioms darbo erdvėms, naudokite _Appearance > Dock > Dock Only on Floating_ arba `omarchy dock tiling off`.

Naujos darbo erdvės ir visos, kurioms nesuteikėte savo išdėstymo su `Super + L`, naudoja numatytąjį išdėstymą. Pakeitus numatytąjį, kiekviena darbo erdvė be langų nustatoma iš naujo į jį, o ta, kurioje yra langų, išlaiko turimą išdėstymą. Į doką sumažintas langas vis tiek laikomas langu darbo erdvėje, kurią jis paliko. Pasirinkite jį skiltyje _Appearance > Workspace Layout_: Tiling, Scrolling arba Floating. `omarchy hyprland workspace layout default scrolling` jį nustato iš terminalo.

### Langų grupavimas

Langus galima grupuoti naudojant `Super + G`. Kai esate grupėje, kiekvienas langas, kurį paleidžiate tai būsenai esant aktyviai, priklausys grupei. Tarp šių sugrupuotų langų galite judėti naudodami `Super + Ctrl + Arrow Left/Right` arba `Super + Alt + 1/2/3/4`, kad pereitumėte tiesiai prie sugrupuotų langų eilės tvarka.

Langą iš grupavimo galite perkelti su `Super + Alt + G` arba išardyti visą grupę dar kartą paspausdami `Super + G`. Galiausiai langus, esančius už grupės ribų, į ją galite perkelti su `Super + Alt + Arrows`.

### Langų iškėlimas

Langą iš jo darbo erdvės paskyrimo galite iškelti su `Super + O`. Tai jį prisegs kaip plaukiojantį langą, kuris seka jus į bet kurią darbo erdvę, į kurią einate. Puikiai tinka vaizdo leistuvams ir panašiems dalykams.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad darbo erdvė

Yra speciali viso dydžio scratchpad darbo erdvė, kuri uždengia bet kurią darbo erdvę, kurioje šiuo metu esate. Kas joje yra, pasiekiate naudodami `Super + S`, o langus ten dedate naudodami `Super + Alt + S`.

Ji puikiai tinka valdikliams ar terminalui, su kuriuo norite greitai sąveikauti nepalikdami dabartinės darbo erdvės.

### Quake konsolė

Galiausiai yra pusės aukščio Quake konsolė, kuri nusileidžia ant bet kurios darbo erdvės, kurioje šiuo metu esate. Ją perjungiate su `Super + the key above Tab` (JAV išdėstymuose — grave), o langą ten dedate naudodami `Super + Shift + the key above Tab`.

Pirmą kartą jai atsidarius, ji paleidžia jūsų numatytąjį agentą arba paprašo pasirinkti vieną, jei dar nesate pasirinkę. Kol konsolėje yra vienas langas, ji nusileidžia kaip centruotas skydelis, o ne apima visą ekraną. Įdėkite į ją antrą programą ir ji grįžta į visą plotį, kad abi turėtų vietos būti viena šalia kitos.

Kad langą perkeltumėte iš scratchpad arba konsolės, nusiųskite jį tiesiai į kitą darbo erdvę, pavyzdžiui, su `Super + Shift + 1`.

### Prie to reikia priprasti!

Priprasti taip naršyti darbalaukyje užtrunka šiek tiek laiko, bet kai priprasite, bus sunku grįžti prie tradicinio pele valdomo darbalaukio!
