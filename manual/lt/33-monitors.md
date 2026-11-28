# Monitoriai

Omarchy pagal numatytuosius nustatymus daro prielaidą, kad naudojate 2x galintį retina klasės ekraną. Būtent to reikia tiems gražiems, ryškiems programuotojo šriftams. Būtent tam optimizuoti beveik visi nauji premium klasės nešiojamieji kompiuteriai su didelės raiškos ekranais. Būtent tai norėtumėte naudoti su 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) arba 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Bet jei nenaudojate ekrano, kurio PPI yra 218 ar didesnis, norėsite pakeisti monitoriaus nustatymus. Pavyzdžiui, jei turite 27" ar 32" 4K, galite pasirinkti jam trupmeninį mastelį monitoriaus skydelyje viršutinėje juostoje arba nustatyti numatytąjį kiekvienam monitoriui atidarę `~/.config/hypr/monitors.lua` ir perjungę į tam deriniui skirtą rekomendaciją:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Jei naudojate 1080p ar 1440p ekraną, tikriausiai tiesiog norėsite naudoti 1x mastelį, ir tą patį GTK bei X11 programoms, todėl galite naudoti:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` pakeitimai taikomi programoms, paleistoms po pakeitimo (o GTK pripažįsta tik sveikuosius skaičius, todėl palikite jį ties artimiausiu sveikuoju jūsų monitoriaus mastelio skaičiumi). Todėl būtinai uždarykite langus, kuriuos turite ir kurie po pakeitimo yra per dideli (arba uždarykite visus langus su `Ctrl + Alt + Del`!).

Taip pat galite greitai pereiti per pagrindinius monitoriaus mastelio santykius (1x, 1.25x, 1.6x, 2x, 3x, 4x) naudodami `Super + /`, kad padidintumėte, ir `Super + Alt + /`, kad sumažintumėte, arba pasirinkti vieną monitoriaus skydelyje viršutinėje juostoje. Jie keičia tik monitorių, kuriame esate sufokusavę, todėl nešiojamojo kompiuterio ekranas ir išorinis ekranas gali kiekvienas turėti savo mastelį. Skydelis taip pat nustato kiekvieno monitoriaus raišką, atnaujinimo dažnį ir pasukimą. Jūsų pasirinkimai tam fiziniam monitoriui įrašomi į `~/.local/state/omarchy/monitors/settings`, todėl jie išlieka po perkrovimo ir seka paskui monitorių į bet kurį prievadą ar doką, į kurį jis bus prijungtas kitą kartą. Jie turi pirmenybę prieš bet kurią tam pačiam monitoriui skirtą taisyklę faile `~/.config/hypr/monitors.lua`, kurio Omarchy niekada neredaguoja. Jei verčiau monitorius visiškai nustatytumėte tame faile, pridėkite į jį `omarchy_monitor_panel_settings = false`, ir skydelio pakeitimai galios tik tol, kol Hyprland persikraus. Kadangi `GDK_SCALE` yra viena reikšmė visiems ekranams, pasirinktas mastelis nustato ją pagal monitorių su mažiausiu masteliu, todėl X11 programos tankesniame ekrane atrodo šiek tiek per mažos, o ne per didelės kitame.

### Teksto didinimas ar mažinimas

Monitoriaus mastelis keičia visko dydį. Jei norite tik didesnio ar mažesnio _teksto_, tam yra vienas vienintelis reguliatorius:

```
omarchy display text size 14
```

Jis priima dydį pikseliais nuo 9 iki 20 ir kartu pakeičia Omarchy apvalkalą, GTK programas ir jūsų terminalą, todėl visas darbalaukis lieka proporcingas. Paleiskite jį be argumento, kad pamatytumėte, ties kuo esate, o `omarchy display text size reset` — kad grįžtumėte prie numatytojo. Foot yra vienintelis atsiliekantis: jis neturi būdo iš naujo įkelti savo konfigūracijos, todėl veikiantys terminalai išlaikys seną dydį, kol atidarysite naują.

### Nešiojamojo kompiuterio ekranų išplėtimas ir atspindėjimas

Kai prijungiate išorinį ekraną prie nešiojamojo kompiuterio, ekranas automatiškai išplečiamas. Bet vietoje to galite tai pakeisti į atspindėjimą naudodami _Extend_ | _Mirror_ monitoriaus skydelyje viršutinėje juostoje, _Trigger > Hardware_ Omarchy meniu arba `Super + Ctrl + Alt + Delete`. Tai ypač naudinga, jei tas išorinis ekranas yra projektorius ir norite ką nors parodyti dirbdami.

Kai išplečiate, nešiojamojo kompiuterio dangčio uždarymas automatiškai išjungs vidinį ekraną. Dangčio atidarymas jį vėl įjungs. Taip pat galite tai valdyti rankiniu būdu naudodami _Trigger > Hardware_ Omarchy meniu arba `Super + Ctrl + Delete`.

Kol nešiojamasis kompiuteris prijungtas prie maitinimo, dangčio uždarymas niekada jo neužmigdo, todėl prie doko prijungtas nešiojamasis kompiuteris lieka pabudęs, net jei išorinis ekranas trumpam atsijungia. Kai išorinis ekranas neprijungtas, dangčio uždarymas esant maitinimui jį tik užrakina. Veikiant iš akumuliatoriaus, dangčio uždarymas kaip įprasta pristabdo sistemą.

### Kelių ekranų išdėstymas

Hyprland puikiai veikia su keliais ekranais. Monitoriaus skydelis viršutinėje juostoje nubrėžia juos ten, kur jie yra: nuvilkite vieną prie kito šono, kad perkeltumėte jį ten, ir išdėstymas įrašomas kartu su kitais kiekvieno monitoriaus nustatymais. Apie visa, ko skydelis neapima, ir kaip juos išdėstyti daugiau skaitykite [Hyprland monitorių dokumentacijoje](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchy sistemoje jie įrašomi į `~/.config/hypr/monitors.lua` kaip `hl.monitor` įrašai — failas pateikiamas su komentuotais pavyzdžiais, kaip palikti monitorių išjungtą, naudoti režimus, kurių skydelis nesiūlo, 10 bitų spalvą ir kintamą atnaujinimo dažnį.

Kiekvienas monitorius turi savo darbo sritis nuo 1 iki 10, todėl `Super + 1` visada reiškia pirmąją monitoriaus, kuriame esate, darbo sritį. Užkulisiuose Hyprland vis tiek numeruoja darbo sritis per visus monitorius: jūsų nešiojamojo kompiuterio ekranas (arba pirmasis monitorius) gauna 1–10, kitas monitorius 11–20 ir taip toliau, ir kiekvienas monitorius išlaiko savo bloką kiekvieną kartą, kai jį prijungiate. Naudokite tuos skaičius, jei rašote [darbo sričių taisykles](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ar langų taisykles konkrečiam monitoriui, todėl 12 darbo sritis yra antroji jūsų antrojo monitoriaus darbo sritis. `~/.local/state/omarchy/monitors/workspaces` nurodo, kurį bloką turi kiekvienas monitorius.

Rodyklių klavišai veikia tarp monitorių, kurie jūsų išdėstyme turi bendrą kraštą. Ekranai, kurie liečiasi tik kampe arba tarp kurių yra tarpas, nėra kaimynai, todėl naudokite `Ctrl + Alt + Tab`, kad pereitumėte tarp jų.

| Spartusis klavišas | Tarp monitorių |
| --- | --- |
| `Super + Arrow` | Perkelia fokusą į monitorių toje pusėje, kai ta kryptimi nebelieka lango |
| `Super + Shift + Arrow` | Sukeičia vietomis su langu monitoriuje toje pusėje |
| `Super + Alt + Arrow` | Perkelia langą į grupę monitoriuje toje pusėje |
| `Super + Shift + Ctrl + Arrow` | Perkelia langą į monitorių toje pusėje, į darbo sritį, kurią jis rodo |
| `Super + Shift + Alt + Arrow` | Perkelia darbo sritį į monitorių toje pusėje, išlaikydama jos numerį, jei jis laisvas |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Perkelia fokusą į kitą ar ankstesnį monitorių, kad ir koks būtų išdėstymas |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Lieka monitoriuje, kuriame esate |

Taip pat galite peržiūrėti [Hyprmon](https://github.com/erans/hyprmon/), jei norite TUI, padedančios išdėstyti kelis ekranus.

### Ryškumo valdymas

Monitoriaus ryškumas valdomas specialiais funkcijų klavišais ryškumui didinti ir mažinti. Jei laikysite nuspaudę Shift spausdami šiuos klavišus, pereisite prie maksimalaus arba minimalaus ryškumo. Klavišai valdo ekraną, kuriame esate sufokusavę, todėl išoriniai monitoriai, kurie bendrauja per DDC/CI, reguliuojami taip pat kaip nešiojamojo kompiuterio ekranas.

### Apple ekranai

Jei naudojate Apple ekraną, įprasti klaviatūros ryškumo klavišai taip pat automatiškai veiks, jei esate sufokusavę Apple ekraną. Tai atliekama per `asdcontrol` komandą.

Atkreipkite dėmesį, kad jei naudojate Apple 6K XDR ekraną, savo `hyprctl monitors` sąraše galite matyti vaiduoklinį ekraną. Galite jį išjungti kažkuo panašiu į `hl.monitor({ output = "DP-2", disabled = true })` faile `~/.config/hypr/monitors.lua`.

Intel kompiuteriuose prie Apple ekranų turėtumėte jungtis naudodami įprastą Thunderbolt kabelį. Kituose kompiuteriuose be Thunderbolt paprastai turėsite naudoti [DP + USB-A -> USB-C kabelį](https://www.amazon.com/dp/B0BNX7MS6N), kad tai veiktų.
