# Monitoriai

Omarchy pagal numatytuosius nustatymus daro prielaidą, kad naudojate 2x mastelį galintį palaikyti retina klasės ekraną. Būtent to reikia tiems gražiems, ryškiems programuotojų šriftams. Būtent tam optimizuoti beveik visi nauji aukščiausios klasės nešiojamieji kompiuteriai su didelės skiriamosios gebos ekranais. Būtent to norėtumėte su 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) arba 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Tačiau jei nenaudojate ekrano, kurio PPI yra 218 arba didesnis, norėsite pakeisti monitoriaus nustatymus. Pavyzdžiui, jei turite 27" arba 32" 4K ekraną, galite jam pasirinkti trupmeninį mastelį monitoriaus skydelyje viršutinėje juostoje arba nustatyti numatytąjį visiems monitoriams atidarę `~/.config/hypr/monitors.lua` ir perjungę į tam deriniui skirtą rekomendaciją:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Jei naudojate 1080p arba 1440p ekraną, tikriausiai tiesiog norėsite naudoti 1x mastelį, ir tą patį GTK bei X11 programoms, todėl galite naudoti:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` pakeitimai taikomi programoms, paleistoms po pakeitimo (o GTK pripažįsta tik sveikuosius skaičius, todėl palikite jį ties artimiausiu jūsų monitoriaus mastelio sveikuoju skaičiumi). Todėl būtinai uždarykite po pakeitimo likusius per didelius langus (arba uždarykite visus langus su `Ctrl + Alt + Del`!).

Taip pat galite greitai pereiti per pagrindinius monitoriaus mastelio santykius (1x, 1.25x, 1.6x, 2x, 3x, 4x) naudodami `Super + /`, kad padidintumėte, ir `Super + Alt + /`, kad sumažintumėte, arba pasirinkti vieną monitoriaus skydelyje viršutinėje juostoje. Jie keičia tik tą monitorių, į kurį esate sutelkę dėmesį, todėl nešiojamojo kompiuterio ekranas ir išorinis ekranas gali turėti kiekvienas savo mastelį. Skydelis taip pat nustato kiekvieno monitoriaus skiriamąją gebą. Jūsų pasirinkimai tam fiziniam monitoriui įrašomi į `~/.local/state/omarchy/monitors/settings`, todėl jie išlieka po perkrovimo ir seka monitorių, į kurį prievadą ar doką jis bus prijungtas kitą kartą. Jie turi pirmenybę prieš bet kurią tam pačiam monitoriui skirtą taisyklę faile `~/.config/hypr/monitors.lua`, kurio Omarchy niekada neredaguoja. Jei verčiau monitorius visiškai nustatytumėte tame faile, pridėkite į jį `omarchy_monitor_panel_settings = false`, ir skydelio pakeitimai galios tik tol, kol Hyprland bus įkeltas iš naujo. Kadangi `GDK_SCALE` yra viena reikšmė visiems ekranams, pasirinktas mastelis jį nustato pagal mažiausią mastelį turintį monitorių, todėl X11 programos tankesniame ekrane bus šiek tiek per mažos, užuot kitame buvusios per didelės.

### Teksto didinimas arba mažinimas

Monitoriaus mastelis keičia visko dydį. Jei norite tik didesnio arba mažesnio _teksto_, tam yra viena rankenėlė:

```
omarchy display text size 14
```

Ji priima pikselių dydį nuo 9 iki 20 ir kartu perkelia Omarchy apvalkalą, GTK programas ir jūsų terminalą, todėl visas darbalaukis išlieka proporcingas. Paleiskite ją be argumento, kad pamatytumėte, kur esate, ir `omarchy display text size reset`, kad grįžtumėte prie numatytojo. Foot yra vienintelis atsilikėlis: jis neturi būdo iš naujo įkelti savo konfigūracijos, todėl veikiantys terminalai išlaiko seną dydį, kol atidarysite naują.

### Nešiojamojo kompiuterio ekranų išplėtimas ir dubliavimas

Kai prie nešiojamojo kompiuterio prijungiate išorinį ekraną, ekranas automatiškai išplečiamas. Tačiau galite tai pakeisti į dubliavimą naudodami _Trigger > Hardware_ Omarchy meniu arba `Super + Ctrl + Alt + Delete`. Tai ypač naudinga, jei tas išorinis ekranas yra projektorius ir norite ką nors rodyti dirbdami.

Kai išplečiate, uždarę nešiojamojo kompiuterio dangtį automatiškai išjungsite vidinį ekraną. Atidarę dangtį vėl jį įjungsite. Taip pat galite tai valdyti rankiniu būdu naudodami _Trigger > Hardware_ Omarchy meniu arba `Super + Ctrl + Delete`.

### Kelių ekranų išdėstymas

Hyprland puikiai veikia su keliais ekranais. Monitoriaus skydelis viršutinėje juostoje nupiešia juos ten, kur jie yra: vilkite vieną prie kito šono, kad perkeltumėte jį ten, ir išdėstymas įrašomas kartu su kitais kiekvieno monitoriaus nustatymais. Visam kitam, ko skydelis neapima, daugiau apie tai, kaip juos išdėstyti, skaitykite [Hyprland monitorių dokumentacijoje](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchy sistemoje jie yra faile `~/.config/hypr/monitors.lua` kaip `hl.monitor` įrašai — faile pateikiami komentuoti pavyzdžiai, kaip priskirti konkrečiam monitoriui skiriamąją gebą, padėtį ir pasukimą.

Kiekvienas monitorius turi savo darbo sritis nuo 1 iki 10, todėl `Super + 1` visada reiškia pirmąją monitoriaus, kuriame esate, darbo sritį. Užkulisiuose Hyprland vis tiek numeruoja darbo sritis visuose monitoriuose: jūsų nešiojamojo kompiuterio ekranas (arba pirmasis monitorius) gauna 1–10, kitas monitorius 11–20 ir taip toliau, o kiekvienas monitorius išlaiko savo bloką kiekvieną kartą, kai jį prijungiate. Naudokite tuos numerius, jei rašote [darbo sričių taisykles](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) arba langų taisykles konkrečiam monitoriui, todėl darbo sritis 12 yra antroji jūsų antrojo monitoriaus darbo sritis. `~/.local/state/omarchy/monitors/workspaces` nurodo, kurį bloką turi kiekvienas monitorius.

Rodyklių klavišai veikia tarp monitorių, kurie jūsų išdėstyme turi bendrą kraštą. Ekranai, kurie liečiasi tik kampe arba tarp kurių yra tarpas, nėra kaimynai, todėl jiems perjungti naudokite `Ctrl + Alt + Tab`.

| Spartusis klavišas | Tarp monitorių |
| --- | --- |
| `Super + Arrow` | Perkelia židinį į monitorių toje pusėje, kai ta kryptimi nebelieka lango |
| `Super + Shift + Arrow` | Sukeičia su langu monitoriuje toje pusėje |
| `Super + Alt + Arrow` | Perkelia langą į grupę monitoriuje toje pusėje |
| `Super + Shift + Ctrl + Arrow` | Perkelia langą į monitorių toje pusėje, į darbo sritį, kurią jis rodo |
| `Super + Shift + Alt + Arrow` | Perkelia darbo sritį į monitorių toje pusėje, išlaikydamas jos numerį, jei jis laisvas |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Perkelia židinį į kitą arba ankstesnį monitorių, kad ir koks būtų išdėstymas |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Lieka monitoriuje, kuriame esate |

Taip pat galite išbandyti [Hyprmon](https://github.com/erans/hyprmon/), jei norėtumėte TUI, padedančios išdėstyti kelis ekranus.

### Ryškumo valdymas

Monitoriaus ryškumas valdomas specialiais ryškumo didinimo / mažinimo funkcijų klavišais. Jei spausdami juos laikysite nuspaudę Shift, pereisite prie didžiausio arba mažiausio ryškumo. Klavišai valdo ekraną, į kurį esate sutelkę dėmesį, todėl išoriniai monitoriai, kalbantys DDC/CI, reguliuojami taip pat kaip nešiojamojo kompiuterio ekranas.

### Apple ekranai

Jei naudojate Apple ekraną, įprasti klaviatūros ryškumo klavišai taip pat automatiškai veiks, jei esate sutelkę dėmesį į Apple ekraną. Tai atliekama per `asdcontrol` komandą.

Atkreipkite dėmesį: jei naudojate Apple 6K XDR ekraną, savo `hyprctl monitors` sąraše galite pamatyti vaiduoklišką ekraną. Galite jį išjungti kažkuo panašiu į `hl.monitor({ output = "DP-2", disabled = true })` faile `~/.config/hypr/monitors.lua`.

Intel kompiuteriuose prie Apple ekranų turėtumėte jungtis naudodami įprastą Thunderbolt kabelį. Kituose kompiuteriuose be Thunderbolt paprastai turėsite naudoti [DP + USB-A -> USB-C kabelį](https://www.amazon.com/dp/B0BNX7MS6N), kad tai veiktų.
