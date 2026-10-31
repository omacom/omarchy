# Monitorid

Omarchy eeldab vaikimisi, et kasutad 2x-võimekusega retina-klassi ekraani. Seda on sul vaja, et saada need ilusad teravad programmeerimisfondid. Selleks on peaaegu kõik uued kõrge eraldusvõimega ekraanidega premium-klassi sülearvutid optimeeritud. Seda tahaksid sa kasutada 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) või 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) korral.

Aga kui sa ei kasuta ekraani, mille PPI on 218 või kõrgem, tasub sul monitori seadeid muuta. Näiteks kui sul on 27" või 32" 4K ekraan, saad kasutada murdskaleerimist, avades `~/.config/hypr/monitors.lua` (Omarchy menüüs _Seadistus > Monitorid_ kaudu) ja vahetades selle kombinatsiooni jaoks soovitatud seadistuse vastu:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Kui kasutad 1080p või 1440p ekraani, tahad ilmselt kasutada lihtsalt 1x skaleerimist, nii et saad kasutada seda:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Muudatused `GDK_SCALE` väärtuses rakenduvad pärast muudatust käivitatud rakendustele (ja GTK austab ainult täisarve, seega hoia see oma monitori skaala lähima täisarvu juures). Nii et pärast muudatust sulge kindlasti aknad, mis on liiga suured (või sulge kõik aknad `Ctrl + Alt + Del` abil!).

Saad ka kiiresti liikuda peamiste monitori skaleerimissuhete (1x, 1.25x, 1.6x, 2x, 3x, 4x) vahel, kasutades suuremaks minemiseks `Super + /` ja väiksemaks minemiseks `Super + Alt + /`, või valida ühe ülemisel ribal olevast monitoripaneelist. Need muudavad ainult monitori, millel oled fokusseeritud, nii et sülearvuti ekraanil ja välisel ekraanil võib kummalgi olla oma skaala. Valik salvestatakse `~/.config/hypr/monitors.lua` faili selle monitori `hl.monitor` reeglina, nii et see säilib pärast taaskäivitust ja on ülimuslik `omarchy_monitor_scale` suhtes, mis jääb skaalaks iga monitori jaoks, millel oma reeglit ei ole. Kuna `GDK_SCALE` on üks väärtus kõigi ekraanide jaoks, määratakse see nende muudatustega madalaima skaalaga monitori järgi, nii et X11 rakendused tulevad tihedamal ekraanil veidi väikesed, selle asemel et olla teisel liiga suured.

### Teksti suuremaks või väiksemaks muutmine

Monitori skaleerimine muudab kõige suurust. Kui sa tahad ainult suuremat või väiksemat _teksti_, on selleks üksainus nupp:

```
omarchy display text size 14
```

See võtab pikslisuuruse vahemikus 9 kuni 20 ja liigutab Omarchy kesta, GTK rakendusi ja sinu terminali koos, nii et kogu töölaud jääb proportsiooni. Käivita see ilma argumendita, et näha, kus sa oled, ja `omarchy display text size reset`, et minna tagasi vaikeväärtuse juurde. Foot on ainus mahajääja: sellel ei ole võimalust oma konfiguratsiooni uuesti laadida, nii et töötavad terminalid hoiavad oma vana suurust, kuni avad uue.

### Sülearvuti ekraanide laiendamine ja peegeldamine

Kui ühendad sülearvutiga välise ekraani, laiendatakse ekraani automaatselt. Aga sa saad selle muuta hoopis peegeldamiseks, kasutades Omarchy menüüs _Päästik > Riistvara_ või `Super + Ctrl + Alt + Delete`. See on eriti abiks, kui see väline ekraan on projektor ja sa tahad töötamise ajal midagi näidata.

Laiendamise ajal lülitab sülearvuti kaane sulgemine sisemise ekraani automaatselt välja. Kaane avamine lülitab selle tagasi sisse. Saad seda ka käsitsi juhtida, kasutades Omarchy menüüs _Päästik > Riistvara_ või `Super + Ctrl + Delete`.

### Mitme ekraani paigutamine

Hyprland töötab mitme ekraaniga suurepäraselt. Loe lähemalt, kuidas neid paigutada, [Hyprlandi monitoride dokumentatsioonist](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchys lähevad need `~/.config/hypr/monitors.lua` faili `hl.monitor` kirjetena — failiga on kaasas kommenteeritud näited konkreetse monitori kinnitamiseks eraldusvõime, asendi ja pööramise külge.

Igal monitoril on oma tööruumid 1 kuni 10, nii et `Super + 1` tähendab alati selle monitori esimest tööruumi, millel oled. Kulisside taga nummerdab Hyprland tööruume ikkagi kõigi monitoride lõikes: sinu sülearvuti ekraan (või esimene monitor) saab 1–10, järgmine monitor 11–20 ja nii edasi, ning iga monitor hoiab oma plokki iga kord, kui selle ühendad. Kasuta neid numbreid, kui kirjutad konkreetse monitori jaoks [tööruumi reegleid](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) või aknareegleid, nii et tööruum 12 on sinu teise monitori teine tööruum. `~/.local/state/omarchy/monitor-workspaces` loetleb, milline plokk igal monitoril on.

Nooleklahvid töötavad monitoride vahel, mis jagavad sinu paigutuses serva. Ekraanid, mis puudutavad ainult nurgast või mille vahel on vahe, ei ole naabrid, nii et kasuta nende vahel liikumiseks `Ctrl + Alt + Tab`.

| Kiirklahv | Monitoride vahel |
| --- | --- |
| `Super + Arrow` | Viib fookuse sellel poolel olevale monitorile, kui selles suunas enam ühtegi akent ei ole |
| `Super + Shift + Arrow` | Vahetab koha aknaga sellel poolel oleval monitoril |
| `Super + Alt + Arrow` | Viib akna sellel poolel oleval monitoril olevasse rühma |
| `Super + Shift + Ctrl + Arrow` | Viib akna sellel poolel olevale monitorile, selle parasjagu kuvatavale tööruumile |
| `Super + Shift + Alt + Arrow` | Viib tööruumi sellel poolel olevale monitorile, säilitades selle numbri, kui see on vaba |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Viib fookuse järgmisele või eelmisele monitorile, olenemata paigutusest |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Jäävad monitorile, millel oled |

Saad vaadata ka [Hyprmon](https://github.com/erans/hyprmon/), kui soovid TUI-d, mis aitab sul mitut ekraani paigutada.

### Heleduse reguleerimine

Monitori heledust juhitakse spetsiaalsete heleduse suurendamise/vähendamise funktsiooniklahvidega. Kui hoiad nende vajutamise ajal Shift all, lähed maksimaalsele või minimaalsele heledusele. Klahvid juhivad ekraani, millel oled fokusseeritud, nii et väliseid monitore, mis räägivad DDC/CI-d, reguleeritakse samamoodi nagu sülearvuti ekraani.

### Apple'i ekraanid

Kui kasutad Apple'i ekraani, töötavad tavalised klaviatuuri heleduse klahvid ka automaatselt, kui oled fokusseeritud Apple'i ekraanile. Seda tehakse `asdcontrol` käsu kaudu.

Pane tähele, et kui kasutad Apple 6K XDR ekraani, võid näha oma `hyprctl monitors` loendis fantoomekraani. Saad selle välja lülitada millegagi nagu `hl.monitor({ output = "DP-2", disabled = true })` _Seadistus > Monitorid_ kaudu.

Inteli masinatel peaksid Apple'i ekraanidega ühendama tavalise Thunderbolt kaabli abil. Teistel Thunderboltita masinatel pead tavaliselt kasutama [DP + USB-A -> USB-C kaablit](https://www.amazon.com/dp/B0BNX7MS6N), et see tööle saada.
