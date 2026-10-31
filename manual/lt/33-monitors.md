# Monitoriai

Omarchy pagal numatytuosius nustatymus daro prielaidą, kad naudojate 2x galintį retina klasės ekraną. Tai jums reikia, kad gautumėte tuos gražius, ryškius programuotojų šriftus. Tam optimizuoti beveik visi nauji premium klasės nešiojamieji kompiuteriai su didelės raiškos ekranais. Tai norėtumėte naudoti su 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) arba 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Bet jei nenaudojate ekrano, kurio PPI yra 218 ar didesnis, norėsite pakeisti monitoriaus nustatymus. Pavyzdžiui, jei turite 27" arba 32" 4K, galite jam parinkti trupmeninį mastelį monitorių skydelyje viršutinėje juostoje arba nustatyti numatytąjį visiems monitoriams atidarę `~/.config/hypr/monitors.lua` ir perjungę į tam deriniui skirtą rekomendaciją:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Jei naudojate 1080p arba 1440p ekraną, greičiausiai tiesiog norėsite naudoti 1x mastelį, ir tą patį GTK ir X11 programoms, todėl galite naudoti:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` pakeitimai taikomi programoms, paleistoms po pakeitimo (o GTK priima tik sveikuosius skaičius, todėl palikite jį ties artimiausiu sveikuoju skaičiumi jūsų monitoriaus masteliui). Todėl būtinai uždarykite langus, kurie po pakeitimo yra per dideli (arba uždarykite visus langus su `Ctrl + Alt + Del`!).

Taip pat galite greitai peržengti per pagrindinius monitoriaus mastelio santykius (1x, 1.25x, 1.6x, 2x, 3x, 4x) naudodami `Super + /`, kad padidintumėte, ir `Super + Alt + /`, kad sumažintumėte, arba pasirinkti vieną monitorių skydelyje viršutinėje juostoje. Šie pakeitimai keičia tik monitorių, kuriame esate sufokusavę, todėl nešiojamojo kompiuterio ekranas ir išorinis ekranas gali turėti kiekvienas savo mastelį. Skydelyje taip pat nustatoma kiekvieno monitoriaus raiška. Jūsų pasirinkimai tam fiziniam monitoriui išsaugomi `~/.local/state/omarchy/monitors/settings`, todėl jie išlieka po perkrovimo ir seka monitorių į bet kurį prievadą ar doką, į kurį jis bus prijungtas kitą kartą. Jie turi pirmenybę prieš bet kurią tam pačiam monitoriui skirtą taisyklę `~/.config/hypr/monitors.lua`, kurio Omarchy niekada neredaguoja. Kadangi `GDK_SCALE` yra viena reikšmė visiems ekranams, pasirinktas mastelis nustatomas pagal monitorių su mažiausiu masteliu, todėl X11 programos tankesniame ekrane bus šiek tiek mažos, o ne per didelės kitame.

### Teksto didinimas arba mažinimas

Monitoriaus mastelis keičia visko dydį. Jei norite tik didesnio ar mažesnio _teksto_, tam yra vienintelis reguliatorius:

```
omarchy display text size 14
```

Galima nurodyti dydį pikseliais nuo 9 iki 20, ir jis kartu perkelia Omarchy apvalkalą, GTK programas ir jūsų terminalą, todėl visas darbalaukis lieka proporcingas. Paleiskite jį be argumento, kad pamatytumėte, kur esate, ir `omarchy display text size reset`, kad grįžtumėte prie numatytojo. Foot yra vienintelis atsilikėlis: jis neturi būdo iš naujo įkelti savo konfigūracijos, todėl veikiantys terminalai išlaikys seną dydį, kol atidarysite naują.

### Nešiojamojo kompiuterio ekranų išplėtimas ir dubliavimas

Kai prijungiate išorinį ekraną prie nešiojamojo kompiuterio, ekranas automatiškai išplečiamas. Bet tai galite pakeisti į dubliavimą naudodami _Trigger > Hardware_ Omarchy meniu arba `Super + Ctrl + Alt + Delete`. Tai ypač naudinga, jei tas išorinis ekranas yra projektorius ir norite ką nors rodyti dirbdami.

Kai išplečiate, nešiojamojo kompiuterio dangčio uždarymas automatiškai išjungs vidinį ekraną. Dangčio atidarymas jį vėl įjungs. Tai taip pat galite valdyti rankiniu būdu naudodami _Trigger > Hardware_ Omarchy meniu arba `Super + Ctrl + Delete`.

### Kelių ekranų išdėstymas

Hyprland puikiai veikia su keliais ekranais. Monitorių skydelis viršutinėje juostoje nupiešia juos ten, kur jie stovi: vilkite vieną prie kito šono, kad perkeltumėte jį ten, ir išdėstymas išsaugomas kartu su kitais kiekvieno monitoriaus nustatymais. Visa, ko skydelis neapima, daugiau apie tai, kaip juos išdėstyti, skaitykite [Hyprland monitorių dokumentacijoje](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchy sistemoje jie įrašomi į `~/.config/hypr/monitors.lua` kaip `hl.monitor` įrašai — failas pateikiamas su komentuotais pavyzdžiais, kaip konkretų monitorių priskirti raiškai, pozicijai ir pasukimui.

Kiekvienas monitorius turi savo darbo sritis nuo 1 iki 10, todėl `Super + 1` visada reiškia pirmąją monitoriaus, kuriame esate, darbo sritį. Užkulisiuose Hyprland vis tiek numeruoja darbo sritis visuose monitoriuose: jūsų nešiojamojo kompiuterio ekranas (arba pirmasis monitorius) gauna 1–10, kitas monitorius 11–20 ir taip toliau, o kiekvienas monitorius išlaiko savo bloką kiekvieną kartą jį prijungus. Naudokite tuos numerius, jei rašote [darbo sričių taisykles](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) arba langų taisykles konkrečiam monitoriui, todėl 12 darbo sritis yra antroji jūsų antrojo monitoriaus darbo sritis. `~/.local/state/omarchy/monitors/workspaces` išvardija, kurį bloką turi kiekvienas monitorius.

Rodyklių klavišai veikia tarp monitorių, kurie jūsų išdėstyme turi bendrą kraštinę. Ekranai, kurie liečia tik kampu arba tarp kurių yra tarpas, nėra kaimynai, todėl jiems perjungti naudokite `Ctrl + Alt + Tab`.

| Spartusis klavišas | Tarp monitorių |
| --- | --- |
| `Super + Arrow` | Perkelia fokusą į tos pusės monitorių, kai ta kryptimi nebelieka nė vieno lango |
| `Super + Shift + Arrow` | Sukeičia vietomis su langu tos pusės monitoriuje |
| `Super + Alt + Arrow` | Perkelia langą į grupę tos pusės monitoriuje |
| `Super + Shift + Ctrl + Arrow` | Perkelia langą į tos pusės monitorių, į darbo sritį, kurią jis rodo |
| `Super + Shift + Alt + Arrow` | Perkelia darbo sritį į tos pusės monitorių, išlaikydama jos numerį, jei jis laisvas |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Perkelia fokusą į kitą arba ankstesnį monitorių, nepaisant išdėstymo |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Lieka monitoriuje, kuriame esate |

Taip pat galite išbandyti [Hyprmon](https://github.com/erans/hyprmon/), jei norite TUI, padedančios išdėstyti kelis ekranus.

### Ryškumo valdymas

Monitoriaus ryškumas valdomas specialiais funkcijų klavišais ryškumui didinti ir mažinti. Jei spaudžiant juos laikysite nuspaudę shift, pasieksite maksimalų arba minimalų ryškumą. Klavišai valdo ekraną, kuriame esate sufokusavę, todėl išoriniai monitoriai, kalbantys DDC/CI, reguliuojami taip pat kaip nešiojamojo kompiuterio ekranas.

### Apple ekranai

Jei naudojate Apple ekraną, įprasti klaviatūros ryškumo klavišai taip pat automatiškai veiks, jei esate sufokusavę Apple ekraną. Tai atliekama per `asdcontrol` komandą.

Atkreipkite dėmesį, kad jei naudojate Apple 6K XDR ekraną, `hyprctl monitors` sąraše galite matyti fantominį ekraną. Jį galite išjungti kažkuo panašiu į `hl.monitor({ output = "DP-2", disabled = true })` faile `~/.config/hypr/monitors.lua`.

Intel kompiuteriuose prie Apple ekranų turėtumėte jungtis naudodami įprastą Thunderbolt kabelį. Kituose kompiuteriuose be Thunderbolt paprastai turėsite naudoti [DP + USB-A -> USB-C kabelį](https://www.amazon.com/dp/B0BNX7MS6N), kad tai veiktų.
