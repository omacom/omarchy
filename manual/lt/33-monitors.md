# Monitoriai

Pagal numatytuosius nustatymus Omarchy daro prielaidą, kad naudojate 2x mastelį palaikantį retina klasės ekraną. Būtent to reikia, kad gautumėte tuos gražius, ryškius programuotojų šriftus. Būtent tam optimizuoti beveik visi nauji premium klasės nešiojamieji kompiuteriai su didelės raiškos ekranais. Būtent tai norėtumėte naudoti su 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) arba 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Bet jei nenaudojate ekrano, kurio PPI yra 218 ar didesnis, norėsite pakeisti monitoriaus nustatymus. Pavyzdžiui, jei turite 27" arba 32" 4K, galite naudoti trupmeninį mastelį atidarę `~/.config/hypr/monitors.lua` (per _Setup > Monitors_ Omarchy meniu) ir perjungę į rekomendaciją tam deriniui:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Jei naudojate 1080p arba 1440p ekraną, tikriausiai norėsite tiesiog naudoti 1x mastelį, todėl galite naudoti:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE` pakeitimai taikomi programoms, paleistoms po pakeitimo (o GTK priima tik sveikuosius skaičius, todėl palikite jį ties artimiausiu sveikuoju skaičiumi pagal savo monitoriaus mastelį). Taigi būtinai uždarykite langus, kurie po pakeitimo yra per dideli (arba uždarykite visus langus su `Ctrl + Alt + Del`!).

Taip pat galite greitai pereiti pagrindinius monitoriaus mastelio santykius (1x, 1.25x, 1.6x, 2x, 3x, 4x) naudodami `Super + /`, kad padidintumėte, ir `Super + Alt + /`, kad sumažintumėte, arba pasirinkti vieną iš monitoriaus skydelio viršutinėje juostoje. Šie pakeitimai taikomi tik monitoriui, į kurį esate sufokusavę, todėl nešiojamojo kompiuterio ekranas ir išorinis ekranas gali turėti kiekvienas savo mastelį. Pasirinkimas išsaugomas į `~/.config/hypr/monitors.lua` kaip to monitoriaus `hl.monitor` taisyklė, todėl išlieka po perkrovimo ir turi pirmenybę prieš `omarchy_monitor_scale`, kuris lieka masteliu kiekvienam monitoriui, neturinčiam savo taisyklės. Kadangi `GDK_SCALE` yra viena reikšmė visiems ekranams, šie pakeitimai ją nustato pagal mažiausio mastelio monitorių, todėl X11 programos tankesniame ekrane bus šiek tiek mažos, o ne per didelės kitame.

### Teksto didinimas arba mažinimas

Monitoriaus mastelis keičia visko dydį. Jei norite tik didesnio arba mažesnio _teksto_, tam yra vienas vienintelis reguliatorius:

```
omarchy display text size 14
```

Ji priima dydį pikseliais nuo 9 iki 20 ir kartu perkelia Omarchy apvalkalą, GTK programas ir jūsų terminalą, todėl visas darbalaukis išlieka proporcingas. Paleiskite ją be argumento, kad pamatytumėte, ties kuo esate, ir `omarchy display text size reset`, kad grįžtumėte prie numatytojo. Foot yra vienintelis atsilikėlis: jis neturi būdo iš naujo įkelti savo konfigūracijos, todėl veikiantys terminalai išlaiko seną dydį, kol atidarote naują.

### Nešiojamojo kompiuterio ekranų išplėtimas ir veidrodinis atspindėjimas

Kai prijungiate išorinį ekraną prie nešiojamojo kompiuterio, ekranas automatiškai išplečiamas. Bet galite tai pakeisti į veidrodinį atspindėjimą naudodami _Trigger > Hardware_ Omarchy meniu arba `Super + Ctrl + Alt + Delete`. Tai ypač naudinga, jei tas išorinis ekranas yra projektorius ir norite ką nors rodyti dirbdami.

Kai išplečiate, uždarius nešiojamojo kompiuterio dangtį, vidinis ekranas automatiškai išsijungs. Atidarius dangtį, jis vėl įsijungs. Taip pat galite tai valdyti rankiniu būdu naudodami _Trigger > Hardware_ Omarchy meniu arba `Super + Ctrl + Delete`.

### Kelių ekranų išdėstymas

Hyprland puikiai veikia su keliais ekranais. Daugiau apie tai, kaip juos išdėstyti, skaitykite [Hyprland monitorių dokumentacijoje](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchy sistemoje jie įrašomi į `~/.config/hypr/monitors.lua` kaip `hl.monitor` įrašai — faile pateikiami komentuoti pavyzdžiai, kaip priskirti konkrečiam monitoriui raišką, padėtį ir pasukimą.

Kiekvienas monitorius turi savas 1–10 darbo sritis, todėl `Super + 1` visada reiškia pirmąją monitoriaus, kuriame esate, darbo sritį. Užkulisiuose Hyprland vis tiek numeruoja darbo sritis visuose monitoriuose: jūsų nešiojamojo kompiuterio ekranas (arba pirmasis monitorius) gauna 1–10, kitas monitorius 11–20 ir taip toliau, o kiekvienas monitorius išlaiko savo bloką kiekvieną kartą, kai jį prijungiate. Naudokite tuos skaičius, jei rašote [darbo sričių taisykles](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) arba langų taisykles konkrečiam monitoriui, todėl 12 darbo sritis yra antroji jūsų antrojo monitoriaus darbo sritis. `~/.local/state/omarchy/monitor-workspaces` išvardija, kurį bloką turi kiekvienas monitorius.

Rodyklių klavišai veikia tarp monitorių, kurie jūsų išdėstyme turi bendrą kraštą. Ekranai, kurie liečia tik kampu arba tarp kurių yra tarpas, nėra kaimynai, todėl norėdami pereiti tarp jų naudokite `Ctrl + Alt + Tab`.

| Spartusis klavišas | Tarp monitorių |
| --- | --- |
| `Super + Arrow` | Perkelia fokusą į tos pusės monitorių, kai ta kryptimi nebelieka lango |
| `Super + Shift + Arrow` | Sukeičia su langu tos pusės monitoriuje |
| `Super + Alt + Arrow` | Perkelia langą į grupę tos pusės monitoriuje |
| `Super + Shift + Ctrl + Arrow` | Perkelia langą į tos pusės monitorių, į darbo sritį, kurią jis rodo |
| `Super + Shift + Alt + Arrow` | Perkelia darbo sritį į tos pusės monitorių, išlaikydama jos numerį, jei jis laisvas |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Perkelia fokusą į kitą arba ankstesnį monitorių, kad ir koks būtų išdėstymas |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Lieka monitoriuje, kuriame esate |

Taip pat galite išbandyti [Hyprmon](https://github.com/erans/hyprmon/), jei norite TUI, kuri padėtų jums išdėstyti kelis ekranus.

### Ryškumo valdymas

Monitoriaus ryškumas valdomas specialiais funkciniais klavišais ryškumui didinti / mažinti. Jei spausdami šiuos klavišus laikysite nuspaudę shift, pereisite prie maksimalaus arba minimalaus ryškumo. Klavišai valdo ekraną, į kurį esate sufokusavę, todėl išoriniai monitoriai, kalbantys DDC/CI, reguliuojami taip pat kaip nešiojamojo kompiuterio ekranas.

### Apple ekranai

Jei naudojate Apple ekraną, įprasti klaviatūros ryškumo klavišai taip pat automatiškai veiks, jei esate sufokusavę į Apple ekraną. Tai daroma per `asdcontrol` komandą.

Atkreipkite dėmesį, kad jei naudojate Apple 6K XDR ekraną, savo `hyprctl monitors` sąraše galite pamatyti fantominį ekraną. Galite jį išjungti kažkuo panašiu į `hl.monitor({ output = "DP-2", disabled = true })` per _Setup > Monitors_.

Intel kompiuteriuose prie Apple ekranų turėtumėte jungtis naudodami įprastą Thunderbolt kabelį. Kituose kompiuteriuose be Thunderbolt paprastai turėsite naudoti [DP + USB-A -> USB-C kabelį](https://www.amazon.com/dp/B0BNX7MS6N), kad tai veiktų.
