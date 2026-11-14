# Monitoriai

Omarchy pagal numatytuosius nustatymus daro prielaidą, kad naudojate 2x mastelį palaikantį „retina“ klasės ekraną. Būtent to reikia toms gražioms, ryškioms programuotojų šriftams. Būtent tam optimizuoti beveik visi nauji aukščiausios klasės nešiojamieji kompiuteriai su didelės raiškos ekranais. Būtent to norėtumėte su 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) arba 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Bet jei nenaudojate ekrano, kurio PPI yra 218 arba didesnis, norėsite pakeisti monitoriaus nustatymus. Pavyzdžiui, jei turite 27" arba 32" 4K, galite pasirinkti jam trupmeninį mastelį monitoriaus skydelyje viršutinėje juostoje arba nustatyti numatytąjį kiekvienam monitoriui atidarę `~/.config/hypr/monitors.lua` ir perjungę į tam deriniui skirtą rekomendaciją:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Jei naudojate 1080p arba 1440p ekraną, tikriausiai tiesiog norėsite naudoti 1x mastelį, ir tą patį GTK bei X11 programoms, todėl galite naudoti:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` pakeitimai taikomi programoms, paleistoms po pakeitimo (o GTK palaiko tik sveikuosius skaičius, todėl palikite jį ties artimiausiu jūsų monitoriaus mastelio sveikuoju skaičiumi). Todėl būtinai uždarykite langus, kurie po pakeitimo yra per dideli (arba uždarykite visus langus su `Ctrl + Alt + Del`!).

Taip pat galite greitai pereiti per pagrindinius monitoriaus mastelio santykius (1x, 1.25x, 1.6x, 2x, 3x, 4x) naudodami `Super + /`, kad padidintumėte, ir `Super + Alt + /`, kad sumažintumėte, arba pasirinkti vieną iš monitoriaus skydelio viršutinėje juostoje. Jie keičia tik tą monitorių, kuriame esate susitelkę, todėl nešiojamojo kompiuterio ekranas ir išorinis ekranas gali kiekvienas turėti savo mastelį. Skydelyje taip pat nustatoma kiekvieno monitoriaus raiška, atnaujinimo dažnis ir pasukimas. Jūsų pasirinkimai tam fiziniam monitoriui išsaugomi `~/.local/state/omarchy/monitors/settings`, todėl išlieka po perkrovimo ir keliauja paskui monitorių į bet kurį prievadą ar doką, prie kurio jis bus prijungtas kitą kartą. Jie turi pirmenybę prieš bet kurią to paties monitoriaus taisyklę `~/.config/hypr/monitors.lua`, kurio Omarchy niekada neredaguoja. Jei verčiau monitorius visiškai nustatytumėte tame faile, pridėkite į jį `omarchy_monitor_panel_settings = false`, ir skydelio pakeitimai galios tik tol, kol Hyprland bus perkrautas. Kadangi `GDK_SCALE` yra viena reikšmė visiems ekranams, pagal pasirinktą mastelį ji nustatoma iš monitoriaus su mažiausiu masteliu, todėl X11 programos tankesniame ekrane atrodo šiek tiek per mažos, o ne per didelės kitame.

### Teksto didinimas arba mažinimas

Monitoriaus mastelis keičia visko dydį. Jei norite tik didesnio arba mažesnio _teksto_, tam yra vienas vienintelis reguliatorius:

```
omarchy display text size 14
```

Jis priima pikselių dydį nuo 9 iki 20 ir kartu keičia Omarchy apvalkalą, GTK programas ir jūsų terminalą, todėl visas darbalaukis išlieka proporcingas. Paleiskite jį be argumento, kad pamatytumėte, ties kuo esate, ir `omarchy display text size reset`, kad grįžtumėte prie numatytojo. Foot yra vienintelis atsiliekantis: jis neturi būdo iš naujo įkelti savo konfigūracijos, todėl jau veikiantys terminalai išlaiko seną dydį, kol atidarote naują.

### Nešiojamojo kompiuterio ekranų plėtimas ir atspindėjimas

Kai prijungiate išorinį ekraną prie nešiojamojo kompiuterio, ekranas automatiškai išplečiamas. Bet galite tai pakeisti į atspindėjimą naudodami _Trigger > Hardware_ Omarchy meniu arba `Super + Ctrl + Alt + Delete`. Tai ypač naudinga, jei tas išorinis ekranas yra projektorius ir norite ką nors parodyti dirbdami.

Kai plečiate, uždarę nešiojamojo kompiuterio dangtį automatiškai išjungsite vidinį ekraną. Atidarę dangtį jį vėl įjungsite. Taip pat galite tai valdyti rankiniu būdu naudodami _Trigger > Hardware_ Omarchy meniu arba `Super + Ctrl + Delete`.

### Kelių ekranų išdėstymas

Hyprland puikiai veikia su keliais ekranais. Monitoriaus skydelis viršutinėje juostoje piešia juos ten, kur jie stovi: vilkite vieną prie kito šono, kad perkeltumėte jį ten, ir išdėstymas išsaugomas kartu su kitais kiekvieno monitoriaus nustatymais. Apie viską, ko skydelis neapima, daugiau apie tai, kaip juos išdėstyti, skaitykite [Hyprland monitorių dokumentacijoje](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchy sistemoje jie įrašomi į `~/.config/hypr/monitors.lua` kaip `hl.monitor` įrašai — faile pateikiami pakomentuoti pavyzdžiai, kaip palikti monitorių išjungtą, režimų, kurių skydelis nesiūlo, 10 bitų spalvų ir kintamo atnaujinimo dažnio.

Kiekvienas monitorius turi savo darbo sritis nuo 1 iki 10, todėl `Super + 1` visada reiškia pirmąją monitoriaus, kuriame esate, darbo sritį. Užkulisiuose Hyprland vis tiek numeruoja darbo sritis per visus monitorius: jūsų nešiojamojo kompiuterio ekranas (arba pirmasis monitorius) gauna 1–10, kitas monitorius — 11–20 ir taip toliau, o kiekvienas monitorius išlaiko savo bloką kiekvieną kartą, kai jį prijungiate. Naudokite tuos numerius, jei rašote [darbo sričių taisykles](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) arba langų taisykles konkrečiam monitoriui, taigi darbo sritis 12 yra antroji jūsų antrojo monitoriaus darbo sritis. `~/.local/state/omarchy/monitors/workspaces` išvardija, kurį bloką turi kiekvienas monitorius.

Rodyklių klavišai veikia tarp monitorių, kurie jūsų išdėstyme dalijasi kraštu. Ekranai, kurie liečiasi tik kampu arba tarp kurių yra tarpas, nėra kaimynai, todėl naudokite `Ctrl + Alt + Tab`, kad pereitumėte tarp jų.

| Spartusis klavišas | Per monitorius |
| --- | --- |
| `Super + Arrow` | Perkelia židinį į tos pusės monitorių, kai ta kryptimi nebelieka lango |
| `Super + Shift + Arrow` | Sukeičia su langu tos pusės monitoriuje |
| `Super + Alt + Arrow` | Perkelia langą į grupę tos pusės monitoriuje |
| `Super + Shift + Ctrl + Arrow` | Perkelia langą į tos pusės monitorių, į jo rodomą darbo sritį |
| `Super + Shift + Alt + Arrow` | Perkelia darbo sritį į tos pusės monitorių, išlaikydamas jos numerį, jei jis laisvas |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Perkelia židinį į kitą arba ankstesnį monitorių, kad ir koks būtų išdėstymas |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Lieka monitoriuje, kuriame esate |

Taip pat galite išbandyti [Hyprmon](https://github.com/erans/hyprmon/), jei norėtumėte TUI, padedančios išdėstyti kelis ekranus.

### Ryškumo valdymas

Monitoriaus ryškumas valdomas specialiais funkciniais klavišais ryškumui didinti ir mažinti. Jei spausdami juos laikysite nuspaudę shift, pasieksite maksimalų arba minimalų ryškumą. Klavišai valdo ekraną, kuriame esate susitelkę, todėl išoriniai monitoriai, kalbantys DDC/CI, reguliuojami taip pat kaip nešiojamojo kompiuterio ekranas.

### Apple ekranai

Jei naudojate Apple ekraną, įprasti klaviatūros ryškumo klavišai taip pat automatiškai veiks, jei esate susitelkę į Apple ekraną. Tai daroma per `asdcontrol` komandą.

Atkreipkite dėmesį, kad jei naudojate Apple 6K XDR ekraną, savo `hyprctl monitors` sąraše galite matyti vaiduoklišką ekraną. Galite jį išjungti kažkuo panašiu į `hl.monitor({ output = "DP-2", disabled = true })` faile `~/.config/hypr/monitors.lua`.

Intel kompiuteriuose prie Apple ekranų turėtumėte jungtis naudodami įprastą Thunderbolt kabelį. Kituose kompiuteriuose be Thunderbolt paprastai turėsite naudoti [DP + USB-A -> USB-C kabelį](https://www.amazon.com/dp/B0BNX7MS6N), kad viskas veiktų.
