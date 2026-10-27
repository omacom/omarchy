# Monitorid

Omarchy eeldab vaikimisi, et kasutad 2x-võimekusega retina-klassi ekraani. Just seda on sul vaja, et saada need ilusad, teravad programmeerijafondid. Selle jaoks on optimeeritud peaaegu kõik uued kõrge eraldusvõimega ekraanidega premium-klassi sülearvutid. Just seda tahaksid sa kasutada 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) või 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) puhul.

Aga kui sa ei kasuta ekraani, mille PPI on 218 või kõrgem, tasub sul monitori sätteid muuta. Näiteks kui sul on 27" või 32" 4K ekraan, saad kasutada murdskaleerimist, avades `~/.config/hypr/monitors.lua` (Omarchy menüüs _Setup > Monitors_ kaudu) ja lülitudes selle kombinatsiooni jaoks soovitatud sättele:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Kui kasutad 1080p või 1440p ekraani, tahad tõenäoliselt lihtsalt kasutada 1x skaleerimist, nii et saad kasutada:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE` muudatused kehtivad pärast muudatust käivitatud rakendustele (ja GTK austab ainult täisarve, nii et hoia see oma monitori skaala lähima täisarvu juures). Nii et sulge kindlasti aknad, mis on pärast muudatust liiga suured (või sulge kõik aknad klahvidega `Ctrl + Alt + Del`!).

Samuti saad kiiresti käia läbi peamised monitori skaleerimissuhted (1x, 1.25x, 1.6x, 2x, 3x, 4x), kasutades kõrgemale liikumiseks `Super + /` ja madalamale liikumiseks `Super + Alt + /`. Kui sul on vaikekonfiguratsioon, säilivad need muudatused ka pärast taaskäivitust.

### Teksti suuremaks või väiksemaks muutmine

Monitori skaleerimine muudab kõige suurust. Kui sa tahad ainult suuremat või väiksemat _teksti_, on selle jaoks üksainus nupp:

```
omarchy display text size 14
```

See võtab pikslisuuruse vahemikus 9 kuni 20 ja liigutab Omarchy kesta, GTK rakendusi ja sinu terminali koos, nii et kogu töölaud püsib proportsioonis. Käivita see ilma argumendita, et näha, kus sa parasjagu oled, ja `omarchy display text size reset`, et minna tagasi vaikeväärtuse juurde. Foot on ainus mahajääja: sellel pole võimalust oma konfiguratsiooni uuesti laadida, nii et töötavad terminalid säilitavad oma vana suuruse, kuni avad uue.

### Sülearvuti ekraanide laiendamine ja peegeldamine

Kui ühendad sülearvutiga välise ekraani, laiendatakse ekraani automaatselt. Aga sa saad selle muuta hoopis peegeldamiseks, kasutades Omarchy menüüs _Trigger > Hardware_ või `Super + Ctrl + Alt + Delete`. See on eriti abiks, kui see väline ekraan on projektor ja sa tahad töötamise ajal midagi näidata.

Laiendamise ajal lülitab sülearvuti kaane sulgemine sisemise ekraani automaatselt välja. Kaane avamine lülitab selle tagasi sisse. Saad seda ka käsitsi juhtida, kasutades Omarchy menüüs _Trigger > Hardware_ või `Super + Ctrl + Delete`.

### Mitme ekraani paigutamine

Hyprland töötab mitme ekraaniga suurepäraselt. Loe nende paigutamise kohta lähemalt [Hyprlandi monitoride dokumentatsioonist](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchys lähevad need faili `~/.config/hypr/monitors.lua` kirjetena `hl.monitor` — failiga on kaasas kommenteeritud näited konkreetse monitori kinnitamiseks kindla eraldusvõime, asukoha ja pööramise külge.

Igal monitoril on oma tööruumid 1 kuni 10, nii et `Super + 1` tähendab alati selle monitori esimest tööruumi, millel sa parasjagu oled. Kulisside taga nummerdab Hyprland tööruume ikkagi kõigi monitoride üleselt: sinu sülearvuti ekraan (või esimene monitor) saab 1–10, järgmine monitor 11–20 ja nii edasi ning iga monitor säilitab oma ploki iga kord, kui sa selle ühendad. Kasuta neid numbreid, kui kirjutad konkreetse monitori jaoks [tööruumi reegleid](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) või aknareegleid, nii et tööruum 12 on sinu teise monitori teine tööruum. `~/.local/state/omarchy/monitor-workspaces` loetleb, milline plokk igal monitoril on.

Nooleklahvid töötavad üle monitoride, millel on sinu paigutuses ühine serv. Ekraanid, mis puudutavad üksteist ainult nurgast või mille vahel on tühimik, ei ole naabrid, nii et kasuta nende vahel liikumiseks `Ctrl + Alt + Tab`.

| Kiirklahv | Monitoride vahel |
| --- | --- |
| `Super + Arrow` | Liigutab fookuse sellel küljel olevale monitorile, kui selles suunas pole enam ühtegi akent järel |
| `Super + Shift + Arrow` | Vahetab koha sellel küljel oleval monitoril oleva aknaga |
| `Super + Alt + Arrow` | Liigutab akna sellel küljel oleval monitoril olevasse rühma |
| `Super + Shift + Ctrl + Arrow` | Liigutab akna sellel küljel olevale monitorile, selle tööruumile, mida see parasjagu näitab |
| `Super + Shift + Alt + Arrow` | Liigutab tööruumi sellel küljel olevale monitorile, säilitades selle numbri, kui see on vaba |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Liigutab fookuse järgmisele või eelmisele monitorile, olenemata paigutusest |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Püsivad monitoril, millel sa parasjagu oled |

Võid vaadata ka [Hyprmoni](https://github.com/erans/hyprmon/), kui soovid TUI-d, mis aitab sind mitme ekraani paigutamisel.

### Heleduse juhtimine

Monitori heledust juhitakse spetsiaalsete heleduse suurendamise/vähendamise funktsiooniklahvidega. Kui hoiad nende vajutamise ajal all shift-klahvi, lähed maksimaalsele või minimaalsele heledusele. Klahvid juhivad ekraani, millel on fookus, nii et väliseid monitore, mis räägivad DDC/CI-d, reguleeritakse samamoodi nagu sülearvuti ekraani.

### Apple'i ekraanid

Kui kasutad Apple'i ekraani, töötavad ka tavalised klaviatuuri heledusklahvid automaatselt, kui sul on fookus Apple'i ekraanil. Seda tehakse käsu `asdcontrol` kaudu.

Pane tähele, et kui kasutad Apple'i 6K XDR ekraani, võid näha oma `hyprctl monitors` loendis fantoomekraani. Saad selle välja lülitada millegagi nagu `hl.monitor({ output = "DP-2", disabled = true })` valiku _Setup > Monitors_ kaudu.

Inteli masinatel peaksid Apple'i ekraanidega ühendama tavalise Thunderbolt kaabli abil. Teistel masinatel ilma Thunderboltita pead tavaliselt kasutama [DP + USB-A -> USB-C kaablit](https://www.amazon.com/dp/B0BNX7MS6N), et see tööle saada.
