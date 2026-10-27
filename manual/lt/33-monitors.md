# Monitoriai

Omarchy pagal numatytuosius nustatymus daro prielaidą, kad naudojate 2x mastelį palaikantį retina klasės ekraną. Būtent to reikia tiems gražiems, ryškiems programuotojų šriftams. Būtent tam optimizuoti beveik visi nauji aukščiausios klasės nešiojamieji kompiuteriai su didelės raiškos ekranais. Būtent taip norėtumėte dirbti su 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) arba 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Tačiau jei nenaudojate ekrano, kurio PPI yra 218 ar daugiau, norėsite pakeisti monitoriaus nustatymus. Pavyzdžiui, jei turite 27" arba 32" 4K, galite naudoti trupmeninį mastelio keitimą atidarę `~/.config/hypr/monitors.lua` (per _Setup > Monitors_ Omarchy meniu) ir perjungę į tam deriniui skirtą rekomendaciją:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Jei naudojate 1080p arba 1440p ekraną, tikriausiai tiesiog norėsite naudoti 1x mastelį, todėl galite naudoti:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE` pakeitimai taikomi programoms, paleistoms po pakeitimo (o GTK atsižvelgia tik į sveikuosius skaičius, todėl palikite jį ties artimiausiu sveikuoju jūsų monitoriaus mastelio skaičiumi). Todėl būtinai uždarykite langus, kurie po pakeitimo yra per dideli (arba uždarykite visus langus su `Ctrl + Alt + Del`!).

Taip pat galite greitai pereiti pagrindinius monitoriaus mastelio santykius (1x, 1.25x, 1.6x, 2x, 3x, 4x) naudodami `Super + /`, kad pereitumėte prie didesnio, ir `Super + Alt + /`, kad pereitumėte prie mažesnio. Jei turite numatytąją konfigūraciją, šie pakeitimai išliks ir po perkrovimo.

### Teksto padarymas didesniu arba mažesniu

Monitoriaus mastelio keitimas keičia visko dydį. Jei viskas, ko norite, yra didesnis arba mažesnis _tekstas_, tam yra vienas vienintelis reguliatorius:

```
omarchy display text size 14
```

Jis priima pikselių dydį nuo 9 iki 20 ir kartu perkelia Omarchy apvalkalą, GTK programas ir jūsų terminalą, todėl visas darbalaukis išlieka proporcingas. Paleiskite jį be argumento, kad pamatytumėte, ties kuo esate, ir `omarchy display text size reset`, kad grįžtumėte prie numatytojo. Foot yra vienintelis atsilikėlis: jis neturi būdo iš naujo įkelti savo konfigūracijos, todėl veikiantys terminalai išlaiko seną dydį, kol atidarote naują.

### Nešiojamojo kompiuterio ekranų išplėtimas ir veidrodinis atspindėjimas

Kai prijungiate išorinį ekraną prie nešiojamojo kompiuterio, vaizdas automatiškai išplečiamas. Tačiau galite tai pakeisti į veidrodinį atspindėjimą vietoj to naudodami _Trigger > Hardware_ Omarchy meniu arba `Super + Ctrl + Alt + Delete`. Tai ypač naudinga, jei tas išorinis ekranas yra projektorius ir norite ką nors rodyti dirbdami.

Kai naudojate išplėtimą, uždarius nešiojamojo kompiuterio dangtį, vidinis ekranas automatiškai išsijungs. Atidarius dangtį, jis vėl įsijungs. Tai taip pat galite valdyti rankiniu būdu naudodami _Trigger > Hardware_ Omarchy meniu arba `Super + Ctrl + Delete`.

### Kelių ekranų išdėstymas

Hyprland puikiai veikia su keliais ekranais. Daugiau apie tai, kaip juos išdėstyti, skaitykite [Hyprland monitorių dokumentacijoje](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchy sistemoje jie įrašomi į `~/.config/hypr/monitors.lua` kaip `hl.monitor` įrašai — faile pateikiami komentuoti pavyzdžiai, kaip priskirti konkretų monitorių raiškai, pozicijai ir pasukimui.

Kiekvienas monitorius turi savo darbo erdves nuo 1 iki 10, todėl `Super + 1` visada reiškia pirmąją monitoriaus, kuriame esate, darbo erdvę. Užkulisiuose Hyprland vis tiek numeruoja darbo erdves visuose monitoriuose: jūsų nešiojamojo kompiuterio ekranas (arba pirmasis monitorius) gauna 1–10, kitas monitorius 11–20 ir taip toliau, o kiekvienas monitorius išlaiko savo bloką kiekvieną kartą, kai jį prijungiate. Naudokite tuos skaičius, jei rašote [darbo erdvių taisykles](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) arba langų taisykles konkrečiam monitoriui, todėl darbo erdvė 12 yra antroji jūsų antrojo monitoriaus darbo erdvė. `~/.local/state/omarchy/monitor-workspaces` išvardija, kokį bloką turi kiekvienas monitorius.

Rodyklių klavišai veikia tarp monitorių, kurie jūsų išdėstyme turi bendrą kraštą. Ekranai, kurie liečiasi tik kampe arba tarp kurių yra tarpas, nėra kaimynai, todėl norėdami pereiti tarp jų naudokite `Ctrl + Alt + Tab`.

| Spartusis klavišas | Tarp monitorių |
| --- | --- |
| `Super + Arrow` | Perkelia židinį į monitorių toje pusėje, kai ta kryptimi nebelieka lango |
| `Super + Shift + Arrow` | Sukeičia vietomis su langu monitoriuje toje pusėje |
| `Super + Alt + Arrow` | Perkelia langą į grupę monitoriuje toje pusėje |
| `Super + Shift + Ctrl + Arrow` | Perkelia langą į monitorių toje pusėje, į darbo erdvę, kurią jis rodo |
| `Super + Shift + Alt + Arrow` | Perkelia darbo erdvę į monitorių toje pusėje, išlaikydamas jos numerį, jei jis laisvas |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Perkelia židinį į kitą arba ankstesnį monitorių, nepaisant išdėstymo |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Lieka monitoriuje, kuriame esate |

Taip pat galite peržiūrėti [Hyprmon](https://github.com/erans/hyprmon/), jei norėtumėte TUI, padedančios išdėstyti kelis ekranus.

### Ryškumo valdymas

Monitoriaus ryškumas valdomas specialiais funkciniais klavišais ryškumui didinti / mažinti. Jei spausdami šiuos klavišus laikysite nuspaudę shift, pereisite prie maksimalaus arba minimalaus ryškumo. Klavišai valdo ekraną, į kurį esate sutelkę dėmesį, todėl išoriniai monitoriai, kurie kalba DDC/CI, reguliuojami taip pat, kaip nešiojamojo kompiuterio ekranas.

### Apple ekranai

Jei naudojate Apple ekraną, įprasti klaviatūros ryškumo klavišai taip pat automatiškai veiks, jei esate sutelkę dėmesį į Apple ekraną. Tai atliekama per `asdcontrol` komandą.

Atkreipkite dėmesį, kad jei naudojate Apple 6K XDR ekraną, savo `hyprctl monitors` sąraše galite matyti fantominį ekraną. Galite jį išjungti kažkuo panašiu į `hl.monitor({ output = "DP-2", disabled = true })` per _Setup > Monitors_.

Intel kompiuteriuose prie Apple ekranų turėtumėte jungtis naudodami įprastą Thunderbolt kabelį. Kituose kompiuteriuose be Thunderbolt paprastai turėsite naudoti [DP + USB-A -> USB-C kabelį](https://www.amazon.com/dp/B0BNX7MS6N), kad tai veiktų.
