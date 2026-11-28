# Navigacija

Viskas Omarchy sistemoje vyksta klaviatūra — _VISKAS!_ Kai sistema pirmą kartą paleidžiama, tiesiogine prasme nieko negalite padaryti vien pele. Bet galite paspausti `Super + Space`, kad atskleistumėte Omarchy meniu, o iš čia galite padaryti beveik viską.

Bet Omarchy meniu net nėra skirtas būti pagrindiniu būdu valdyti sistemą didžiąją laiko dalį. Galime greičiau nei tai! Visos svarbiausios programos yra tiesiogiai susietos su atskirais sparčiaisiais klavišais. Terminalą paleidžiate su `Super + Return`, o naršyklę — su `Super + Shift + Return`. Pamėginkite padaryti vieną po kito ir pamatysite Hyprland plytelių išdėstymo magiją veikiant:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Tada galite paspausti `Super + J`, kad sudėtumėte juos vieną ant kito, o ne vieną šalia kito:

 ![navigation-stacked](images/navigation-stacked.webp)

Paspauskite `Super + J` dar kartą, kad sugrąžintumėte juos į pozicijas vieną šalia kito. Tada, būdami naršyklėje, pamėginkite `Super + Shift + Arrow Right`, kad sukeistumėte langus vietomis.

Dabar pamėginkite `Super + Shift + T`, kad paleistumėte Activity monitorių. Jis pasirodys kaip slankusis langas, su antraštės juosta, už kurios jį galima vilkti, ir mygtukais jam sumažinti, išdidinti ir uždaryti. Kiekvienas slankusis langas tokią gauna, kad ir kur jis būtų. Galite jį išdėstyti plytelėmis naudodami `Super + T` (ir paspausti tai dar kartą, kad jis vėl taptų slankusis). Dabar paspauskite `Super + Shift + F`, kad atvertumėte failų tvarkytuvę. Turėsite tvarkingą keturių langų išdėstymą:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Tarp langų, kurį norite, kad būtų aktyvus, naršote su `Super + Arrow`. Tai perjungs židinį ir perkels žymeklį į naujos programos centrą. Prie ekrano krašto jis tęsiasi į monitorių toje pusėje.

Jei paspausite `Super + Shift + 2`, perkelsite šiuo metu sufokusuotą programą į antrąją darbo sritį. `Super + Shift + 1` ją perkelia atgal. (O `Super + Shift + Alt + 2` perkels šiuo metu sufokusuotą programą į antrąją darbo sritį į ją neperjungdamas).

Su daugiau nei vienu monitoriumi kiekvienas monitorius turi savo darbo sritis nuo 1 iki 10. `Super + 2` eina į antrąją monitoriaus, kuriame esate, darbo sritį, o kiekvieno monitoriaus viršutinė juosta rodo jo paties darbo sritis ir tą, kurią jis rodo. `Super + Tab` pereina per darbo sritis monitoriuje, kuriame esate. `Super + Shift + Ctrl + Arrows` perkelia langą, kuriame esate, į monitorių ta kryptimi, į jo rodomą darbo sritį, o `Super + Shift + Alt + Arrows` perkelia darbo sritį, kurioje esate, į monitorių ta kryptimi, kur ji gauna tą patį numerį, jei jis laisvas. Monitorius išlaiko savo darbo sritis, kai jį atjungiate: jos prisijungia prie kito ekrano darbo sričių, sunumeruotos po tų, kurias jis jau turi, ir sugrįžta po senaisiais numeriais, kai monitorius sugrįžta.

Jei laikysite nuspaudę `Super` ir pele spustelėsite langą, galėsite pertvarkyti, kur jis yra. Jei laikysite `Super` ir naudosite dešinįjį pelės mygtuką, galėsite laisvai keisti lango dydį.

Langą uždarote su `Super + W` arba `Super + Q` (o visus langus uždarote su `Ctrl + Alt + Delete`).

Taip pat galite pereiti į viso ekrano režimą su `Super + F` ar net tiesiog į viso pločio režimą (išlaikydami viršutinę juostą) su `Super + Alt + F` arba į viso ekrano režimą lange su `Super + Ctrl + F` (puiku YouTube!).

### Dwindle ir slenkantis išdėstymas

Numatytasis Omarchy išdėstymas vadinamas dwindle. Jis visą laiką laiko visus langus, kuriuos atveriate vienoje darbo srityje, matomus, net jei turi juos sumažinti.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Bet taip pat galite pasirinkti darbo sritį paversti slenkančiuoju išdėstymu, kur langai išrikiuoti vienas šalia kito už matomo ekrano krašto. Vieną darbo sritį į šį išdėstymą paverčiate per `Super + L`.

Paspaudus `Super + L` dar kartą darbo sritis tampa slankioji, kur langai laisvai persidengia ir jūs juos dėstate patys, o trečias paspaudimas ją sugrąžina į dwindle. `Super + Alt + L` pereina per juos priešinga kryptimi. Langas, kuris bet kuriuo atveju yra slankusis — toks, kurį iškėlėte su `Super + T`, arba programa, kuri visada atsidaro slankioji — lieka slankusis, kai darbo sritis sugrįžta į plytelių išdėstymą. Viršutinė juosta pažymi darbo sritį, kurioje esate, jos išdėstymu: kvadratas — dwindle, apskritimas — slenkančiajam, o trikampis — slankiajam. Spustelėjus tą žymą išdėstymas taip pat keičiamas ciklu, ir tą patį daro ekrano klavišas nešiojamuosiuose kompiuteriuose, kurie tokį turi.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Pasirinkimas yra kiekvienai darbo sričiai atskirai ir jis išlieka. Taigi galite 1 darbo sritį laikyti dwindle naršymui, o 2 darbo sritį — slenkančiąją kodui, ir jos tokios sugrįš po paleidimo iš naujo.

Jei norite slenkantįjį išdėstymą naudoti kaip numatytąjį, galite tai nustatyti `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Slankiosios darbo sritys

Slankioji darbo sritis veikia kaip tradicinis darbalaukis: langai persidengia, o jūs juos perkeliate ir jų dydį keičiate patys. Kiekvienas langas gauna jūsų temos spalvų antraštės juostą su mygtukais sumažinti, išdidinti ir uždaryti. `Super + M` taip pat sumažina sufokusuotą langą. Sumažintas langas laukia doke; spustelėkite jo programą, kad jį sugrąžintumėte. Spustelėkite langą, kad iškeltumėte jį į priekį. Keiskite jo dydį nuo bet kurio krašto ar kampo. Dukart spustelėkite antraštės juostą, kad išdidintumėte langą, išlaikydami viršutinę juostą matomą, ir dar kartą, kad susigrąžintumėte senąjį jo dydį. Chrome ir kitos Chromium pagrindu veikiančios naršyklės, Disks ir Document Viewer praleidžia antraštės juostą ir vietoj jos naudoja savo pačių antraštę; `Super + Alt + F` jas išdidina, o `Super + M` jas sumažina.

Kiekviena darbo sritis turi doką, su jūsų prisegtomis programomis, viskuo, kas veikia, ir visų programų tinkleliu už programų mygtuko, kurį taip pat atveria `Super + Alt + Space` ir _Apps_ Omarchy meniu. Dešiniuoju pelės mygtuku spustelėkite programą tinklelyje arba paspauskite `Delete`, kad ją pašalintumėte. Spustelėkite programą, kad ją atvertumėte arba iškeltumėte jos langą į priekį; spustelėkite dar kartą, kad ciklu pereitumėte per jos langus. Files sugrąžina tik langą iš darbo srities, kurioje esate, o kitu atveju atveria naują, o Terminal ir Agent visada paleidžia dar vieną, nors sumažintas langas sugrąžinamas pirmiausia. Vidurinis spustelėjimas atveria naują langą. Vilkite piktogramą išilgai doko, kad ją perkeltumėte; nuvilkus veikiančią programą tarp kitų, ji ten paliekama. Dešiniuoju pelės mygtuku spustelėkite, kad programą paliktumėte doke, ją iš jo išimtumėte arba ją uždarytumėte. Dokas lieka iškeltas, kol darbo sritis tuščia, o kai darbo sritis turi langą, jis pasislepia, kol žymeklis pasiekia jo kraštą. Viso ekrano langas jį paslepia visiškai. Vilkite programų mygtuką kito ekrano krašto link, kad doką perkeltumėte ten. Spustelėkite jį dešiniuoju pelės mygtuku, kad gautumėte _Position_ kraštui pasirinkti, _Layout_ numatytajam išdėstymui nustatyti, kaip tai daro _Appearance > Workspace Layout_, ir _Visibility_, kad dokas visada būtų įjungtas, kad pirmoji programa jį paslėptų arba kad jis visada liktų paslėptas. `omarchy dock visibility always` tai nustato iš terminalo. Pozicija taip pat yra po _Appearance > Dock > Dock Position_, o `omarchy dock position left` ją nustato iš terminalo. Programos, kurias laikote doke, yra nublankusios, kol neveikia. Kad dokas liktų tik slankiosioms darbo sritims, naudokite _Appearance > Dock > Dock Only on Floating_ arba `omarchy dock tiling off`.

Naujos darbo sritys ir bet kuri, kuriai nesate suteikę jos pačios išdėstymo su `Super + L`, naudoja numatytąjį išdėstymą. Pakeitus numatytąjį, kiekviena darbo sritis be langų nustatoma į jį iš naujo, o ta, kurioje yra langų, išlaiko išdėstymą, kurį turi. Langas, sumažintas į doką, vis tiek laikomas langu darbo srityje, kurią jis paliko. Pasirinkite jį po _Appearance > Workspace Layout_: Tiling, Scrolling arba Floating. `omarchy hyprland workspace layout default scrolling` tai nustato iš terminalo.

### Langų grupavimas

Langus galima grupuoti naudojant `Super + G`. Kai esate grupėje, kiekvienas langas, kurį paleidžiate, kol tai aktyvu, priklausys grupei. Tarp šių sugrupuotų langų galite judėti naudodami `Super + Ctrl + Arrow Left/Right` arba `Super + Alt + 1/2/3/4`, kad eitumėte tiesiai į sugrupuotus langus eilės tvarka.

Galite perkelti langą iš grupavimo su `Super + Alt + G` arba išardyti visą grupę dar kartą paspausdami `Super + G`. Galiausiai galite perkelti langus už grupės ribų į ją su `Super + Alt + Arrows`.

### Langų iškėlimas

Galite iškelti langą iš jam paskirtos darbo srities su `Super + O`. Tai jį prisegs kaip slankųjį langą, kuris seka jus į bet kurią darbo sritį, į kurią einate. Puiku vaizdo grotuvams ir panašiems dalykams.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad darbo sritis

Yra speciali viso dydžio scratchpad darbo sritis, kuri perdengia bet kurią darbo sritį, kurioje šiuo metu esate. Tai, kas joje yra, pasiekiate naudodami `Super + S`, o langus ten dedate naudodami `Super + Alt + S`.

Ji puikiai tinka valdikliams ar terminalui, su kuriuo norite greitai sąveikauti nepalikdami dabartinės darbo srities.

### Quake konsolė

Galiausiai yra pusės aukščio Quake konsolė, kuri nusileidžia virš bet kurios darbo srities, kurioje šiuo metu esate. Perjunkite ją su `Super + the key above Tab` (grave JAV išdėstymuose) ir padėkite ten langą naudodami `Super + Shift + the key above Tab`.

Pirmą kartą, kai ji atsidaro, ji paleidžia jūsų numatytąjį agentą arba paprašo pasirinkti vieną, jei dar nesate pasirinkę. Kol konsolė laiko vieną langą, ji nusileidžia kaip centruotas skydelis, o ne apima visą ekraną. Padėkite į ją antrą programą ir ji sugrįš į visą plotį, kad abi turėtų vietos sėdėti viena šalia kitos.

Kad perkeltumėte langą iš scratchpad ar konsolės, siųskite jį tiesiai į kitą darbo sritį su kažkuo panašiu į `Super + Shift + 1`.

### Reikia šiek tiek laiko priprasti!

Reikia šiek tiek laiko priprasti taip naršyti darbalaukyje, bet kai priprasite, bus sunku sugrįžti prie tradicinės pele valdomos darbalaukio patirties!
