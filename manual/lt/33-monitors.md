# Monitoriai

„Omarchy“ pagal numatytuosius nustatymus daro prielaidą, kad naudojate 2x raišką palaikantį „retina“ klasės ekraną. Būtent to reikia tiems gražiems, ryškiems programuotojų šriftams. Beveik visi nauji aukščiausios klasės nešiojamieji kompiuteriai su didelės raiškos ekranais yra optimizuoti būtent tam. Būtent to norėtumėte 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) arba 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Bet jei jūsų ekrano PPI nėra 218 ar didesnis, norėsite pakeisti monitoriaus nustatymus. Pavyzdžiui, jei turite 27" arba 32" 4K, galite parinkti jam trupmeninį mastelį iš monitoriaus skydelio viršutinėje juostoje arba nustatyti numatytąjį visiems monitoriams atidarę `~/.config/hypr/monitors.lua` ir perjungę į tam deriniui skirtą rekomendaciją:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Jei naudojate 1080p arba 1440p ekraną, tikriausiai tiesiog norėsite naudoti 1x mastelį, ir tą patį GTK bei X11 programoms, tad galite naudoti:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` pakeitimai taikomi programoms, paleistoms po pakeitimo (o GTK pripažįsta tik sveikuosius skaičius, todėl palikite artimiausią sveikąjį skaičių pagal savo monitoriaus mastelį). Tad būtinai uždarykite langus, kurie po pakeitimo yra per dideli (arba uždarykite visus langus su `Ctrl + Alt + Del`!).

Taip pat galite greitai pereiti per pagrindinius monitoriaus mastelio santykius (1x, 1.25x, 1.6x, 2x, 3x, 4x) naudodami `Super + /`, kad eitumėte aukščiau, ir `Super + Alt + /`, kad eitumėte žemiau, arba pasirinkti vieną iš monitoriaus skydelio viršutinėje juostoje. Šie pakeitimai keičia tik monitorių, į kurį esate sutelkę dėmesį, todėl nešiojamojo kompiuterio ekranas ir išorinis ekranas gali turėti kiekvienas savo mastelį. Skydelis taip pat nustato kiekvieno monitoriaus raišką, atnaujinimo dažnį ir pasukimą. Jūsų pasirinkimai išsaugomi tam fiziniam monitoriui faile `~/.local/state/omarchy/monitors/settings`, todėl jie išlieka po perkrovimo ir seka paskui monitorių į bet kurį prievadą ar doką, į kurį jį prijungsite vėliau. Jie turi pirmenybę prieš bet kurią tam pačiam monitoriui skirtą taisyklę faile `~/.config/hypr/monitors.lua`, kurio „Omarchy“ niekada neredaguoja. Jei verčiau visus monitorius nustatytumėte tik tame faile, įrašykite į jį `omarchy_monitor_panel_settings = false`, ir skydelio pakeitimai galios tik tol, kol „Hyprland“ bus įkeltas iš naujo. Kadangi `GDK_SCALE` yra viena reikšmė visiems ekranams, pasirinktas mastelis nustatomas pagal žemiausią mastelį turintį monitorių, todėl X11 programos tankesniame ekrane atrodys šiek tiek mažos, o ne per didelės kitame.

### Teksto didinimas arba mažinimas

Monitoriaus mastelis keičia visko dydį. Jei norite tik didesnio ar mažesnio _teksto_, tam yra vienas vienintelis reguliatorius:

```
omarchy display text size 14
```

Jis priima dydį pikseliais nuo 9 iki 20 ir kartu keičia „Omarchy“ apvalkalą, GTK programas ir jūsų terminalą, todėl visas darbalaukis išlieka proporcingas. Paleiskite jį be argumento, kad pamatytumėte, kur esate dabar, ir `omarchy display text size reset`, kad grįžtumėte prie numatytojo. „Foot“ yra vienintelis atsilikėlis: jis neturi būdo iš naujo įkelti savo konfigūracijos, todėl veikiantys terminalai išlaikys seną dydį, kol atidarysite naują.

### Nešiojamojo kompiuterio ekranų išplėtimas ir veidrodinis atspindėjimas

Kai prijungiate išorinį ekraną prie nešiojamojo kompiuterio, ekranas automatiškai išplečiamas. Bet galite tai pakeisti į veidrodinį atspindėjimą naudodami _Extend_ | _Mirror_ monitoriaus skydelyje viršutinėje juostoje, _Trigger > Hardware_ „Omarchy“ meniu arba `Super + Ctrl + Alt + Delete`. Tai ypač naudinga, jei tas išorinis ekranas yra projektorius ir norite ką nors rodyti dirbdami.

Kai išplečiate, uždarę nešiojamojo kompiuterio dangtį automatiškai išjungsite vidinį ekraną. Atidarę dangtį jį vėl įjungsite. Tai taip pat galite valdyti rankiniu būdu naudodami _Trigger > Hardware_ „Omarchy“ meniu arba `Super + Ctrl + Delete`.

### Kelių ekranų išdėstymas

„Hyprland“ puikiai veikia su keliais ekranais. Monitoriaus skydelis viršutinėje juostoje nubrėžia juos ten, kur jie yra: vilkite vieną prie kito šono, kad perkeltumėte jį ten, ir išdėstymas išsaugomas kartu su kitais kiekvieno monitoriaus nustatymais. Visa, ko skydelis neapima, skaitykite daugiau apie tai, kaip juos išdėstyti, [„Hyprland“ monitorių dokumentacijoje](https://wiki.hypr.land/Configuring/Basics/Monitors/). „Omarchy“ sistemoje jie įrašomi į `~/.config/hypr/monitors.lua` kaip `hl.monitor` įrašai — failas pateikiamas su komentuotais pavyzdžiais, kaip laikyti monitorių išjungtą, naudoti režimus, kurių skydelis nesiūlo, 10 bitų spalvas ir kintamą atnaujinimo dažnį.

Kiekvienas monitorius turi savo darbo erdves nuo 1 iki 10, todėl `Super + 1` visada reiškia pirmąją monitoriaus, kuriame esate, darbo erdvę. Užkulisiuose „Hyprland“ vis tiek numeruoja darbo erdves visuose monitoriuose: jūsų nešiojamojo kompiuterio ekranas (arba pirmasis monitorius) gauna 1–10, kitas monitorius — 11–20 ir taip toliau, o kiekvienas monitorius išlaiko savo bloką kiekvieną kartą, kai jį prijungiate. Naudokite tuos skaičius, jei rašote [darbo erdvių taisykles](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) arba langų taisykles konkrečiam monitoriui, taigi 12 darbo erdvė yra antroji jūsų antrojo monitoriaus darbo erdvė. `~/.local/state/omarchy/monitors/workspaces` nurodo, kurį bloką turi kiekvienas monitorius.

Rodyklių klavišai veikia tarp monitorių, kurie jūsų išdėstyme turi bendrą kraštą. Ekranai, kurie liečiasi tik kampe arba tarp kurių yra tarpas, nėra kaimynai, todėl norėdami pereiti tarp jų naudokite `Ctrl + Alt + Tab`.

| Spartusis klavišas | Tarp monitorių |
| --- | --- |
| `Super + Arrow` | Perkelia židinį į monitorių toje pusėje, kai ta kryptimi nebelieka lango |
| `Super + Shift + Arrow` | Sukeičia vietomis su langu monitoriuje toje pusėje |
| `Super + Alt + Arrow` | Perkelia langą į grupę monitoriuje toje pusėje |
| `Super + Shift + Ctrl + Arrow` | Perkelia langą į monitorių toje pusėje, į jo rodomą darbo erdvę |
| `Super + Shift + Alt + Arrow` | Perkelia darbo erdvę į monitorių toje pusėje, išlaikydama jos numerį, jei jis laisvas |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Perkelia židinį į kitą arba ankstesnį monitorių, kad ir koks būtų išdėstymas |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Lieka monitoriuje, kuriame esate |

Taip pat galite išbandyti [Hyprmon](https://github.com/erans/hyprmon/), jei norite TUI, kuris padėtų jums išdėstyti kelis ekranus.

### Ryškumo valdymas

Monitoriaus ryškumas valdomas specialiais funkciniais klavišais ryškumui didinti / mažinti. Jei spausdami šiuos klavišus laikysite nuspaudę shift, pereisite prie didžiausio arba mažiausio ryškumo. Klavišai valdo ekraną, į kurį esate sutelkę dėmesį, todėl išoriniai monitoriai, kalbantys DDC/CI, reguliuojami taip pat kaip nešiojamojo kompiuterio ekranas.

### Apple ekranai

Jei naudojate „Apple“ ekraną, įprasti klaviatūros ryškumo klavišai taip pat automatiškai veiks, jei esate sutelkę dėmesį į „Apple“ ekraną. Tai atliekama per `asdcontrol` komandą.

Atkreipkite dėmesį, kad jei naudojate „Apple“ 6K XDR ekraną, savo `hyprctl monitors` sąraše galite pamatyti fantominį ekraną. Galite jį išjungti kažkuo panašiu į `hl.monitor({ output = "DP-2", disabled = true })` faile `~/.config/hypr/monitors.lua`.

„Intel“ kompiuteriuose prie „Apple“ ekranų turėtumėte jungtis naudodami įprastą „Thunderbolt“ kabelį. Kituose kompiuteriuose be „Thunderbolt“ paprastai turėsite naudoti [DP + USB-A -> USB-C kabelį](https://www.amazon.com/dp/B0BNX7MS6N), kad viskas veiktų.
