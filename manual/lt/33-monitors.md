# Monitoriai

Omarchy pagal numatytuosius nustatymus daro prielaidą, kad naudojate 2x palaikantį „retina“ klasės ekraną. Būtent tokio reikia, kad gautumėte tuos gražius, ryškius programuotojų šriftus. Būtent tokiam yra optimizuoti beveik visi nauji aukščiausios klasės nešiojamieji kompiuteriai su didelės raiškos ekranais. Būtent tokį norėtumėte naudoti su 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) arba 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Bet jei nenaudojate ekrano, kurio PPI yra 218 arba didesnis, norėsite pakeisti monitoriaus nustatymus. Pavyzdžiui, jei turite 27" arba 32" 4K, galite naudoti trupmeninį mastelio keitimą atidarę `~/.config/hypr/monitors.lua` (per _Setup > Monitors_ Omarchy meniu) ir perjungę į tam deriniui skirtą rekomendaciją:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Jei naudojate 1080p arba 1440p ekraną, greičiausiai tiesiog norėsite naudoti 1x mastelį, todėl galite naudoti:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE` pakeitimai taikomi programoms, paleistoms po pakeitimo (o GTK pripažįsta tik sveikuosius skaičius, todėl palikite jį ties artimiausiu jūsų monitoriaus mastelio sveikuoju skaičiumi). Taigi būtinai uždarykite langus, kurie po pakeitimo yra per dideli (arba uždarykite visus langus paspaudę `Ctrl + Alt + Del`!).

Taip pat galite greitai pereiti per pagrindinius monitoriaus mastelio santykius (1x, 1.25x, 1.6x, 2x, 3x, 4x) naudodami `Super + /`, kad padidintumėte, ir `Super + Alt + /`, kad sumažintumėte, arba pasirinkti vieną iš monitoriaus skydelio viršutinėje juostoje. Šie keičia tik tą monitorių, į kurį esate sutelkę dėmesį, todėl nešiojamojo kompiuterio ekranas ir išorinis ekranas gali kiekvienas turėti savo mastelį. Pasirinkimas įrašomas į `~/.config/hypr/monitors.lua` kaip `hl.monitor` taisyklė tam monitoriui, todėl išlieka po perkrovimo ir turi pirmenybę prieš `omarchy_monitor_scale`, kuris lieka masteliu kiekvienam monitoriui, neturinčiam savo taisyklės.

### Teksto didinimas arba mažinimas

Monitoriaus mastelio keitimas keičia visko dydį. Jei viskas, ko norite, yra didesnis arba mažesnis _tekstas_, tam yra vienas vienintelis reguliatorius:

```
omarchy display text size 14
```

Jis priima pikselių dydį nuo 9 iki 20 ir kartu pajudina Omarchy apvalkalą, GTK programas ir jūsų terminalą, todėl visas darbalaukis išlieka proporcingas. Paleiskite jį be argumento, kad pamatytumėte, kur esate, ir `omarchy display text size reset`, kad grįžtumėte prie numatytojo. Foot yra vienintelis atsilikėlis: jis neturi būdo iš naujo įkelti savo konfigūracijos, todėl veikiantys terminalai išlaiko seną dydį, kol atidarote naują.

### Nešiojamojo kompiuterio ekranų išplėtimas ir veidrodinis atspindėjimas

Kai prijungiate išorinį ekraną prie nešiojamojo kompiuterio, ekranas automatiškai išplečiamas. Bet galite tai pakeisti į veidrodinį atspindėjimą naudodami _Trigger > Hardware_ Omarchy meniu arba `Super + Ctrl + Alt + Delete`. Tai ypač naudinga, jei tas išorinis ekranas yra projektorius ir norite ką nors rodyti dirbdami.

Kai išplečiate, uždarius nešiojamojo kompiuterio dangtį vidinis ekranas automatiškai išsijungs. Atidarius dangtį jis vėl įsijungs. Taip pat galite tai valdyti rankiniu būdu naudodami _Trigger > Hardware_ Omarchy meniu arba `Super + Ctrl + Delete`.

### Kelių ekranų išdėstymas

Hyprland puikiai veikia su keliais ekranais. Daugiau apie tai, kaip juos išdėstyti, skaitykite [Hyprland monitorių dokumentacijoje](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchy sistemoje jie įrašomi į `~/.config/hypr/monitors.lua` kaip `hl.monitor` įrašai — faile pateikiami komentuoti pavyzdžiai, kaip prisegti konkretų monitorių prie raiškos, pozicijos ir pasukimo.

Kiekvienas monitorius turi savo darbo sritis nuo 1 iki 10, todėl `Super + 1` visada reiškia pirmąją monitoriaus, kuriame esate, darbo sritį. Užkulisiuose Hyprland vis tiek numeruoja darbo sritis visuose monitoriuose: jūsų nešiojamojo kompiuterio ekranas (arba pirmasis monitorius) gauna 1–10, kitas monitorius 11–20 ir taip toliau, o kiekvienas monitorius išlaiko savo bloką kiekvieną kartą, kai jį prijungiate. Naudokite tuos numerius, jei rašote [darbo sričių taisykles](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) arba langų taisykles konkrečiam monitoriui, todėl 12 darbo sritis yra antroji jūsų antrojo monitoriaus darbo sritis. `~/.local/state/omarchy/monitor-workspaces` išvardija, kurį bloką turi kiekvienas monitorius.

Rodyklių klavišai veikia tarp monitorių, kurie jūsų išdėstyme dalijasi kraštine. Ekranai, kurie liečia tik kampe arba tarp kurių yra tarpas, nėra kaimynai, todėl norėdami pereiti tarp jų naudokite `Ctrl + Alt + Tab`.

| Spartusis klavišas | Tarp monitorių |
| --- | --- |
| `Super + Arrow` | Perkelia dėmesį į tos pusės monitorių, kai ta kryptimi nebelieka langų |
| `Super + Shift + Arrow` | Apkeičia su langu tos pusės monitoriuje |
| `Super + Alt + Arrow` | Perkelia langą į grupę tos pusės monitoriuje |
| `Super + Shift + Ctrl + Arrow` | Perkelia langą į tos pusės monitorių, į darbo sritį, kurią jis rodo |
| `Super + Shift + Alt + Arrow` | Perkelia darbo sritį į tos pusės monitorių, išlaikydamas jos numerį, jei jis laisvas |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Perkelia dėmesį į kitą arba ankstesnį monitorių, kad ir koks būtų išdėstymas |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Lieka monitoriuje, kuriame esate |

Taip pat galite išbandyti [Hyprmon](https://github.com/erans/hyprmon/), jei norite TUI, padedančio išdėstyti kelis ekranus.

### Ryškumo valdymas

Monitoriaus ryškumas valdomas specialiais funkciniais klavišais ryškumui didinti / mažinti. Jei laikydami shift paspausite šiuos klavišus, pereisite į maksimalų arba minimalų ryškumą. Klavišai valdo ekraną, į kurį esate sutelkę dėmesį, todėl išoriniai monitoriai, kalbantys DDC/CI, reguliuojami taip pat kaip nešiojamojo kompiuterio ekranas.

### Apple ekranai

Jei naudojate Apple ekraną, įprasti klaviatūros ryškumo klavišai taip pat automatiškai veiks, jei esate sutelkę dėmesį į Apple ekraną. Tai daroma per `asdcontrol` komandą.

Atkreipkite dėmesį, kad jei naudojate Apple 6K XDR ekraną, `hyprctl monitors` sąraše galite pamatyti fantominį ekraną. Galite jį išjungti kažkuo panašiu į `hl.monitor({ output = "DP-2", disabled = true })` per _Setup > Monitors_.

Intel kompiuteriuose prie Apple ekranų turėtumėte jungtis naudodami įprastą Thunderbolt kabelį. Kituose kompiuteriuose be Thunderbolt paprastai turėsite naudoti [DP + USB-A -> USB-C kabelį](https://www.amazon.com/dp/B0BNX7MS6N), kad tai veiktų.
