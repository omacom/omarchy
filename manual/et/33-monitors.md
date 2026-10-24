# Kuvarid

Omarchy eeldab vaikimisi, et töötad 2x-võimelisel retina klassi ekraanil. See on see, mida vajad nende kenade, teravate programmeerijate kirjatüüpide saamiseks. See on see, milleks peaaegu kõik kõrge eraldusvõimega ekraanidega uued premium sülearvutid on optimeeritud. See on see, mida tahaksid käitada 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) või 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) peal.

Kuid kui sa ei kasuta ekraani, mille PPI on 218 või rohkem, tahad kuvari seadeid muuta. Näiteks kui sul on 27" või 32" 4K, saad kasutada murdskaleerimist, avades faili `~/.config/hypr/monitors.lua` (Omarchy menüü jaotise _Seaded > Kuvarid_ kaudu) ja lülitudes selle kombinatsiooni soovitusele:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Kui kasutad 1080p või 1440p ekraani, tahad ilmselt lihtsalt kasutada 1x skaleerimist, nii et saad kasutada:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Muudatused `GDK_SCALE`-is kehtivad rakendustele, mis käivitatakse pärast muudatust (ja GTK austab ainult täisarve, nii et hoia see oma kuvari skaala lähima täisarvu juures). Nii et veendu, et lahkud pärast muudatust akendest, mis on liiga suured (või sule kõik aknad kombinatsiooniga `Ctrl + Alt + Del`!).

Saad kiiresti läbi käia ka peamised kuvari skaleerimissuhted (1x, 1.25x, 1.6x, 2x, 3x, 4x), kasutades kõrgemale minemiseks `Super + /` ja madalamale minemiseks `Super + Alt + /`. Kui sul on vaikekonfiguratsioon, jäävad need muudatused ka pärast taaskäivitust püsima.

### Teksti suuremaks või väiksemaks tegemine

Kuvari skaleerimine muudab kõike suurust. Kui soovid ainult suuremat või väiksemat _teksti_, on selleks üks nupp:

```
omarchy display text size 14
```

See võtab pikslisuuruse 9 ja 20 vahel ja liigutab Omarchy kesta, GTK rakendusi ja sinu terminali koos, nii et kogu töölaud jääb proportsiooni. Käivita see ilma argumendita, et näha, kus oled, ja `omarchy display text size reset`, et tagasi vaikeväärtusele minna. Foot on ainus mahajääja: sellel pole võimalust oma konfiguratsiooni uuesti laadida, nii et töötavad terminalid säilitavad oma vana suuruse, kuni avad uue.

### Sülearvuti ekraanide laiendamine ja peegeldamine

Kui ühendad sülearvutile välise ekraani, laiendatakse ekraani automaatselt. Kuid saad selle muuta peegeldamiseks, kasutades Omarchy menüü jaotist _Käivita > Riistvara_ või kombinatsiooni `Super + Ctrl + Alt + Delete`. See on eriti kasulik, kui see väline ekraan on projektor ja soovid töötamise ajal midagi näidata.

Laiendamisel lülitab sülearvuti kaane sulgemine sisemise ekraani automaatselt välja. Kaane avamine lülitab selle tagasi sisse. Seda saad juhtida ka käsitsi, kasutades Omarchy menüü jaotist _Käivita > Riistvara_ või kombinatsiooni `Super + Ctrl + Delete`.

### Mitme ekraani korraldamine

Hyprland töötab suurepäraselt mitme ekraaniga. Loe lähemalt nende paigutamise kohta [Hyprlandi kuvari dokumentatsioonist](https://wiki.hypr.land/Configuring/Basics/Monitors/). Saad [siduda ka kindlaid tööalasid kindlate kuvaritega](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/). Omarchys lähevad need reeglid faili `~/.config/hypr/monitors.lua` kirjetena `hl.monitor` — fail tuleb kommenteeritud näidetega kindla kuvari kinnistamiseks eraldusvõimele, asendile ja pööramisele.

Saad vaadata ka rakendust [Hyprmon](https://github.com/erans/hyprmon/), kui soovid TUI-d, mis aitaks sul mitme ekraani positsioneerimist.

### Heleduse juhtimine

Kuvari heledust juhivad spetsiaalsed heleduse suurendamise/vähendamise funktsiooniklahvid. Kui hoiad nende vajutamise ajal shifti all, lähed maksimaalsele või minimaalsele heledusele. Klahvid juhivad ekraani, millele oled fokusseeritud, nii et väliseid kuvareid, mis räägivad DDC/CI, kohandatakse samamoodi nagu sülearvuti ekraani.

### Apple'i ekraanid

Kui kasutad Apple'i ekraani, töötavad tavalised klaviatuuri heledusklahvid automaatselt ka, kui oled Apple'i ekraanile fokusseeritud. Seda tehakse käsu `asdcontrol` kaudu.

Pane tähele, et kui kasutad Apple'i 6K XDR ekraani, võid näha oma `hyprctl monitors` loendis fantoomekraani. Saad selle välja lülitada millegagi nagu `hl.monitor({ output = "DP-2", disabled = true })` jaotise _Seaded > Kuvarid_ kaudu.

Inteli masinatel peaksid Apple'i ekraanidele ühenduma tavalise Thunderbolti kaabliga. Teistel masinatel ilma Thunderboltita pead tavaliselt kasutama [DP + USB-A -> USB-C kaablit](https://www.amazon.com/dp/B0BNX7MS6N), et see töötaks.
