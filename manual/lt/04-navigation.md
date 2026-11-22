# Navigacija

Viskas Omarchy sistemoje vyksta klaviatūra — _VISKAS!_ Kai sistema paleidžiama pirmą kartą, vien pele tiesiog nieko negalite padaryti. Bet galite paspausti `Super + Space`, kad atvertumėte Omarchy meniu, o iš čia galite padaryti beveik viską.

Tačiau Omarchy meniu net nėra skirtas būti pagrindiniu būdu valdyti sistemą didžiąją laiko dalį. Galime greičiau! Visos svarbiausios programos yra tiesiogiai susietos su atskirais sparčiaisiais klavišais. Terminalą paleidžiate su `Super + Return`, o naršyklę — su `Super + Shift + Return`. Pabandykite vieną po kito ir pamatysite Hyprland plytelių išdėstymo magiją veikiant:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Galite tada paspausti `Super + J`, kad sukrautumėte juos vieną ant kito, o ne greta:

 ![navigation-stacked](images/navigation-stacked.webp)

Paspauskite `Super + J` dar kartą, kad grąžintumėte juos į greta esančias pozicijas. Tada pabandykite `Super + Shift + Arrow Right` būdami naršyklėje, kad sukeistumėte langus.

Dabar pabandykite `Super + Shift + T`, kad paleistumėte Activity monitorių. Jis pasirodys kaip plaukiojantis langas. Galite jį išdėstyti plytelėmis naudodami `Super + T` (ir paspauskite tai dar kartą, kad vėl būtų plaukiojantis). Dabar paspauskite `Super + Shift + F`, kad atvertumėte failų tvarkyklę. Turėsite tvarkingą keturių dalių sąranką:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Tarp langų, kurį norite aktyvinti, naršote su `Super + Arrow`. Tai perkels fokusą ir perkels žymeklį į naujos programos centrą. Ekrano krašte jis tęsiasi į monitorių toje pusėje.

Jei paspausite `Super + Shift + 2`, perkelsite šiuo metu fokusuotą programą į antrą darbo sritį. `Super + Shift + 1` perkelia ją atgal. (O `Super + Shift + Alt + 2` perkels šiuo metu fokusuotą programą į antrą darbo sritį neperjungdamas į ją).

Turint daugiau nei vieną monitorių, kiekvienas monitorius turi savo darbo sritis nuo 1 iki 10. `Super + 2` eina į antrą jūsų monitoriaus darbo sritį, o kiekvieno monitoriaus viršutinė juosta rodo savo darbo sritis ir tą, kurią jis rodo. `Super + Tab` cikliškai pereina per jūsų monitoriaus darbo sritis. `Super + Shift + Ctrl + Arrows` perkelia langą, kuriame esate, į monitorių ta kryptimi, į jo rodomą darbo sritį, o `Super + Shift + Alt + Arrows` perkelia darbo sritį, kurioje esate, į monitorių ta kryptimi, kur ji gauna tą patį numerį, jei jis laisvas. Monitorius išlaiko savo darbo sritis, kai jį atjungiate: jos prisijungia prie kito ekrano, sunumeruotos po tų, kurias jis jau turi, ir grįžta su senais numeriais, kai monitorius sugrįžta.

Jei laikysite nuspaudę `Super` ir pele spustelėsite langą, galėsite pertvarkyti, kur jis yra. Jei laikysite `Super` ir naudosite dešinį pelės mygtuką, galėsite laisvai keisti lango dydį.

Langą uždarote su `Super + W` arba `Super + Q` (o visus langus uždarote su `Ctrl + Alt + Delete`).

Taip pat galite eiti į viso ekrano režimą su `Super + F` arba net tiesiog per visą plotį (išlaikydami viršutinę juostą) su `Super + Alt + F` arba per visą ekraną lango viduje su `Super + Ctrl + F` (gerai YouTube!).

### Dwindle ir slenkantis išdėstymas

Omarchy numatytasis išdėstymas vadinamas dwindle. Jis laiko visus langus, kuriuos atidarote vienoje darbo srityje, visada matomus, net jei turi juos sumažinti.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Bet taip pat galite pasirinkti paversti darbo sritį slenkančiu išdėstymu, kur langai išrikiuoti greta, už matomo ekrano krašto. Vieną darbo sritį į šį išdėstymą paverčiate per `Super + L`.

Dar kartą paspaudus `Super + L`, darbo sritis tampa plaukiojanti, kur langai laisvai persidengia ir juos išdėstote patys, o trečias paspaudimas grąžina ją į dwindle. `Super + Alt + L` pereina per juos priešinga kryptimi. Langas, kuris bet kokiu atveju plaukioja — kurį iškėlėte su `Super + T` arba programa, kuri visada atsidaro plaukiojanti — lieka plaukiojantis, kai darbo sritis grįžta į plytelių išdėstymą. Viršutinė juosta pažymi jūsų darbo sritį jos išdėstymu: kvadratas dwindle, apskritimas slenkančiam ir trikampis plaukiojančiam. Spustelėjus tą ženklą taip pat cikliškai keičiamas išdėstymas, ir taip pat daro ekrano klavišas nešiojamuosiuose kompiuteriuose, kurie tokį turi.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Pasirinkimas yra kiekvienai darbo sričiai atskirai ir jis išlieka. Taigi galite laikyti 1 darbo sritį dwindle naršymui, o 2 darbo sritį slenkančią kodui, ir jos tokios sugrįš po perkrovimo.

Jei norite naudoti slenkantį išdėstymą kaip numatytąjį, galite tai nustatyti faile `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Plaukiojančios darbo sritys

Plaukiojanti darbo sritis veikia kaip tradicinis darbalaukis: langai persidengia, o jūs patys juos perkeliate ir keičiate jų dydį. Kiekvienas langas gauna pavadinimo juostą jūsų temos spalvomis, su mygtukais sumažinti, padidinti ir uždaryti. `Super + M` taip pat sumažina fokusuotą langą. Sumažintas langas laukia doke; spustelėkite jo programą, kad jį susigrąžintumėte. Spustelėkite langą, kad iškeltumėte jį į priekį. Keiskite jo dydį nuo bet kurio krašto ar kampo. Dukart spustelėkite pavadinimo juostą, kad padidintumėte langą, palikdami viršutinę juostą matomą, ir dar kartą, kad atgautumėte seną dydį. Chrome ir kitos Chromium pagrindu veikiančios naršyklės, Disks ir Document Viewer praleidžia pavadinimo juostą ir vietoj to naudoja savo antraštę; `Super + Alt + F` jas padidina, o `Super + M` jas sumažina.

Plaukiojanti darbo sritis taip pat rodo doką, su jūsų prisegtomis programomis, viskuo, kas veikia, ir kiekvienos programos tinkleliu už programų mygtuko, kurį taip pat atveria `Super + Alt + Space` ir _Apps_ Omarchy meniu. Dešiniuoju pelės mygtuku spustelėkite programą tinklelyje arba paspauskite `Delete`, kad ją pašalintumėte. Spustelėkite programą, kad ją atvertumėte arba iškeltumėte jos langą į priekį; spustelėkite dar kartą, kad cikliškai pereitumėte per jos langus. Files tik susigrąžina langą iš darbo srities, kurioje esate, o kitu atveju atveria naują, o Terminal ir Agent visada paleidžia kitą, nors sumažintas langas pirmiausia sugrįžta. Vidurinis spustelėjimas atveria naują langą. Vilkite piktogramą išilgai doko, kad ją perkeltumėte; veikiančios programos įvilkimas tarp kitų ją ten palieka. Dešiniuoju pelės mygtuku spustelėkite, kad programą paliktumėte doke, ją išimtumėte arba uždarytumėte. Dokas pasitraukia iš kelio viso ekrano langui. Dešiniuoju pelės mygtuku spustelėkite programų mygtuką, kad perkeltumėte doką prie kito krašto arba kad jis slėptųsi, kol žymeklis pasieks jo kraštą. Pozicija taip pat yra skiltyje _Appearance > Dock > Dock Position_, o `omarchy dock position left` ir `omarchy dock autohide on` abi nustato iš terminalo. Programos, kurias laikote doke, yra pritemdytos, kol jos neveikia.

Naujos darbo sritys ir bet kuri, kuriai nesuteikėte savo išdėstymo su `Super + L`, naudoja numatytąjį išdėstymą. Pakeitus numatytąjį, kiekviena darbo sritis be langų nustatoma į jį, o ta, kurioje yra langų, išlaiko turimą išdėstymą. Langas, sumažintas į doką, vis tiek skaičiuojasi kaip langas darbo srityje, kurią jis paliko. Pasirinkite jį skiltyje _Appearance > Workspace Layout_: Tiling, Scrolling arba Floating. `omarchy hyprland workspace layout default scrolling` nustato jį iš terminalo.

### Langų grupavimas

Langus galima grupuoti naudojant `Super + G`. Kai esate grupėje, kiekvienas langas, kurį paleidžiate tuo metu, kol ji aktyvi, priklausys grupei. Tarp šių sugrupuotų langų galite judėti naudodami `Super + Ctrl + Arrow Left/Right` arba `Super + Alt + 1/2/3/4`, kad eitumėte tiesiogiai į sugrupuotus langus eilės tvarka.

Galite perkelti langą iš grupės su `Super + Alt + G` arba išardyti visą grupę dar kartą paspausdami `Super + G`. Galiausiai galite perkelti langus už grupės ribų į ją su `Super + Alt + Arrows`.

### Langų iškėlimas

Galite iškelti langą iš jam paskirtos darbo srities su `Super + O`. Tai prisegs jį kaip plaukiojantį langą, kuris seka jus į bet kurią darbo sritį, į kurią einate. Puikiai tinka vaizdo grotuvams ir panašiems dalykams.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad darbo sritis

Yra speciali viso dydžio scratchpad darbo sritis, kuri uždengia bet kurią darbo sritį, kurioje šiuo metu esate. Tai, kas joje yra, pasiekiate naudodami `Super + S`, o langus ten dedate naudodami `Super + Alt + S`.

Ji gerai tinka valdikliams arba terminalui, su kuriuo norite greitai sąveikauti nepalikdami dabartinės darbo srities.

### Quake konsolė

Galiausiai yra pusės aukščio Quake konsolė, kuri nusileidžia virš bet kurios darbo srities, kurioje šiuo metu esate. Perjunkite ją su `Super + Grave`, o langą ten padėkite naudodami `Super + Shift + Grave`.

Pirmą kartą atsidarius, ji paleidžia jūsų numatytąjį agentą arba paprašo pasirinkti vieną, jei dar nepasirinkote. Kol konsolėje yra vienas langas, ji nusileidžia kaip centruotas skydelis, o ne apima visą ekraną. Padėkite joje antrą programą ir ji grįš į visą plotį, kad abi turėtų vietos būti greta.

Norėdami perkelti langą iš scratchpad ar konsolės, siųskite jį tiesiogiai į kitą darbo sritį su kažkuo panašiu į `Super + Shift + 1`.

### Prie to reikia priprasti!

Užtrunka šiek tiek laiko priprasti taip naršyti darbalaukyje, bet kai priprasite, bus sunku grįžti prie tradicinės pele valdomo darbalaukio patirties!
