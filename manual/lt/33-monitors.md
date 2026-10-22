# Monitoriai

Omarchy pagal nutylėjimą daro prielaidą, kad veiki su 2x pajėgiu retina klasės ekranu. To tau reikia, kad gautum tuos gražius, ryškius programuotojų šriftus. Būtent tam yra optimizuota beveik visi nauji aukščiausios klasės nešiojamieji kompiuteriai su aukštos raiškos ekranais. Būtent tai norėtum paleisti su 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) arba 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Bet jei nedirbi su ekranu, kurio PPI yra 218 ar daugiau, norėsi pakeisti monitoriaus nuostatas. Pavyzdžiui, jei turi 27" arba 32" 4K, gali naudoti trupmeninį mastelį atverdamas `~/.config/hypr/monitors.lua` (per _Nuostatos > Monitoriai_ Omarchy meniu) ir perjungdamas į rekomendaciją tam deriniui:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Jei naudoji 1080p arba 1440p ekraną, greičiausiai tiesiog norėsi naudoti 1x mastelį, tad gali naudoti:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE` pakeitimai pritaikomi programoms, paleistoms po pakeitimo (o GTK gerbia tik sveikus skaičius, tad laikyk jį ties artimiausiu tavo monitoriaus mastelio sveiku skaičiumi). Tad būtinai uždaryk langus, kurie po pakeitimo yra per dideli (arba uždaryk visus langus su `Ctrl + Alt + Del`!).

Taip pat gali greitai pereiti per pagrindinius monitoriaus mastelio santykius (1x, 1.25x, 1.6x, 2x, 3x, 4x) naudodamas `Super + /`, kad eitum aukščiau, ir `Super + Alt + /`, kad eitum žemiau. Jei turi numatytąją konfigūraciją, šie pakeitimai taip pat išliks po perkrovimo.

### Padaryti tekstą didesnį arba mažesnį

Monitoriaus mastelis keičia visko dydį. Jei viskas, ko nori, yra didesnis arba mažesnis _tekstas_, tam yra viena rankenėlė:

```
omarchy display text size 14
```

Tai priima pikselių dydį nuo 9 iki 20 ir kartu perkelia Omarchy shell, GTK programas ir tavo terminalą, tad visas darbalaukis išlieka proporcingas. Paleisk jį be argumento, kad pamatytum, kur esi, ir `omarchy display text size reset`, kad sugrįžtum prie numatytojo. Foot yra vienintelis atsilikėlis: jis neturi būdo iš naujo įkelti savo konfigūracijos, tad veikiantys terminalai išlaiko savo seną dydį, kol atversi naują.

### Nešiojamojo kompiuterio ekranų pratęsimas ir dubliavimas

Kai prijungi išorinį ekraną prie savo nešiojamojo, ekranas automatiškai pratęsiamas. Bet gali tai pakeisti į dubliavimą vietoj to, naudodamas _Veiksmai > Aparatinė įranga_ Omarchy meniu arba `Super + Ctrl + Alt + Delete`. Tai ypač naudinga, jei tas išorinis ekranas yra projektorius, o tu nori ką nors rodyti dirbdamas.

Kai pratęsia, nešiojamojo dangtelio uždarymas automatiškai išjungs vidinį ekraną. Dangtelio atidarymas jį vėl įjungs. Tai taip pat gali valdyti rankiniu būdu naudodamas _Veiksmai > Aparatinė įranga_ Omarchy meniu arba `Super + Ctrl + Delete`.

### Kelių ekranų išdėstymas

Hyprland puikiai veikia su keliais ekranais. Daugiau apie tai, kaip juos išdėstyti, skaityk [Hyprland monitoriaus dokumentacijoje](https://wiki.hypr.land/Configuring/Basics/Monitors/). Taip pat gali [susieti konkrečias darbo sritis su konkrečiais monitoriais](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/). Omarchy atveju šios taisyklės dedamos į `~/.config/hypr/monitors.lua` kaip `hl.monitor` įrašai — failas pristatomas su komentuotais pavyzdžiais, kaip prikabinti konkretų monitorių prie raiškos, padėties ir pasukimo.

Taip pat gali pažvelgti į [Hyprmon](https://github.com/erans/hyprmon/), jei norėtum TUI, padedančios tau su kelių ekranų išdėstymu.

### Ryškumo valdymas

Monitoriaus ryškumas kontroliuojamas tam skirtais funkcijos klavišais ryškumui didinti/mažinti. Jei juos spausdamas laikai nuspaudęs shift, nueisi iki maksimalaus arba minimalaus ryškumo. Klavišai kontroliuoja ekraną, į kurį esi sutelkęs dėmesį, tad išoriniai monitoriai, kalbantys DDC/CI, koreguojami taip pat kaip nešiojamojo ekranas.

### Apple ekranai

Jei naudoji Apple ekraną, įprasti klaviatūros ryškumo klavišai taip pat automatiškai veiks, jei esi sutelkęs dėmesį į Apple ekraną. Tai daroma per komandą `asdcontrol`.

Atmink, kad jei naudoji Apple 6K XDR ekraną, gali matyti fantominį ekraną savo `hyprctl monitors` sąraše. Gali jį išjungti, pavyzdžiui, su `hl.monitor({ output = "DP-2", disabled = true })` per _Nuostatos > Monitoriai_.

Intel mašinose prie Apple ekranų turėtum jungtis naudodamas įprastą Thunderbolt laidą. Kitose mašinose be Thunderbolt, kad tai veiktų, paprastai turėsi naudoti [DP + USB-A -> USB-C laidą](https://www.amazon.com/dp/B0BNX7MS6N).
