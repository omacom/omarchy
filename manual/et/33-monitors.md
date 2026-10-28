# Monitorid

Omarchy eeldab vaikimisi, et kasutad 2x-võimekusega retina-klassi ekraani. Just seda on vaja, et saada need mõnusad, teravad programmeerijafondid. Selle jaoks on optimeeritud peaaegu kõik uued kõrge eraldusvõimega ekraanidega premium-klassi sülearvutid. Just seda tahaksid kasutada 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) või 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) puhul.

Aga kui sa ei kasuta ekraani, mille PPI on 218 või kõrgem, tahad monitori seadeid muuta. Näiteks kui sul on 27" või 32" 4K, saad kasutada murdskaleerimist, avades `~/.config/hypr/monitors.lua` (Omarchy menüüs _Setup > Monitors_ kaudu) ja lülitudes selle kombinatsiooni jaoks antud soovitusele:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Kui kasutad 1080p või 1440p ekraani, tahad tõenäoliselt kasutada lihtsalt 1x skaleerimist, nii et saad kasutada:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE` muudatused rakenduvad rakendustele, mis käivitatakse pärast muudatust (ja GTK austab ainult täisarve, nii et hoia see oma monitori skaala lähima täisarvu juures). Nii et sulge kindlasti need aknad, mis on pärast muudatust liiga suured (või sulge kõik aknad klahvidega `Ctrl + Alt + Del`!).

Saad ka kiiresti liikuda läbi peamiste monitori skaleerimissuhete (1x, 1.25x, 1.6x, 2x, 3x, 4x), kasutades suuremaks minemiseks klahve `Super + /` ja väiksemaks minemiseks klahve `Super + Alt + /`, või valida ühe ülemise riba monitoripaneelilt. Need muudavad ainult monitori, millel fookus on, nii et sülearvuti ekraanil ja välisel ekraanil saab kummalgi olla oma skaala. Valik salvestatakse faili `~/.config/hypr/monitors.lua` selle monitori `hl.monitor` reeglina, nii et see püsib ka pärast taaskäivitust ja on ülimuslik `omarchy_monitor_scale` ees, mis jääb skaalaks iga monitori jaoks, millel oma reeglit pole.

### Teksti suuremaks või väiksemaks tegemine

Monitori skaleerimine muudab kõige suurust. Kui tahad ainult suuremat või väiksemat _teksti_, on selle jaoks üksainus nupp:

```
omarchy display text size 14
```

See võtab pikslisuuruse vahemikus 9 kuni 20 ja liigutab Omarchy kesta, GTK rakendusi ja sinu terminali koos, nii et kogu töölaud jääb proportsiooni. Käivita see ilma argumendita, et näha, kus sa oled, ja `omarchy display text size reset`, et minna tagasi vaikeväärtuse juurde. Foot on ainus mahajääja: sellel pole võimalust oma konfiguratsiooni uuesti laadida, nii et töötavad terminalid hoiavad oma vana suurust, kuni avad uue.

### Sülearvuti ekraanide laiendamine ja peegeldamine

Kui ühendad sülearvutiga välise ekraani, laiendatakse ekraani automaatselt. Aga saad selle muuta hoopis peegeldamiseks, kasutades Omarchy menüüs _Trigger > Hardware_ või klahve `Super + Ctrl + Alt + Delete`. See on eriti abiks, kui see väline ekraan on projektor ja tahad töötamise ajal midagi näidata.

Kui laiendad, lülitab sülearvuti kaane sulgemine sisemise ekraani automaatselt välja. Kaane avamine lülitab selle tagasi sisse. Saad seda ka käsitsi juhtida, kasutades Omarchy menüüs _Trigger > Hardware_ või klahve `Super + Ctrl + Delete`.

### Mitme ekraani paigutamine

Hyprland töötab mitme ekraaniga suurepäraselt. Loe lähemalt, kuidas neid paigutada, [Hyprlandi monitoride dokumentatsioonist](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchys lähevad need faili `~/.config/hypr/monitors.lua` kirjetena `hl.monitor` — failiga tulevad kaasa kommenteeritud näited konkreetse monitori kinnitamiseks kindla eraldusvõime, asukoha ja pööramise külge.

Igal monitoril on oma tööalad 1 kuni 10, nii et `Super + 1` tähendab alati selle monitori esimest tööala, millel sa oled. Kulisside taga nummerdab Hyprland tööalad ikkagi üle kõigi monitoride: sinu sülearvuti ekraan (või esimene monitor) saab 1–10, järgmine monitor 11–20 ja nii edasi, ning iga monitor hoiab oma plokki iga kord, kui selle ühendad. Kasuta neid numbreid, kui kirjutad konkreetse monitori jaoks [tööalade reegleid](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) või aknareegleid, nii et tööala 12 on sinu teise monitori teine tööala. `~/.local/state/omarchy/monitor-workspaces` loetleb, milline plokk igal monitoril on.

Nooleklahvid töötavad üle monitoride, mis jagavad sinu paigutuses serva. Ekraanid, mis puudutavad ainult nurgast või mille vahel on vahe, ei ole naabrid, nii et kasuta nende vahel liikumiseks klahve `Ctrl + Alt + Tab`.

| Kiirklahv | Üle monitoride |
| --- | --- |
| `Super + Arrow` | Liigutab fookuse sellel küljel olevale monitorile, kui selles suunas pole enam ühtegi akent jäänud |
| `Super + Shift + Arrow` | Vahetab kohad sellel küljel oleval monitoril oleva aknaga |
| `Super + Alt + Arrow` | Liigutab akna sellel küljel oleval monitoril olevasse rühma |
| `Super + Shift + Ctrl + Arrow` | Liigutab akna sellel küljel olevale monitorile, sellel kuvatavale tööalale |
| `Super + Shift + Alt + Arrow` | Liigutab tööala sellel küljel olevale monitorile, säilitades selle numbri, kui see on vaba |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Liigutab fookuse järgmisele või eelmisele monitorile, paigutusest sõltumata |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Jäävad monitorile, millel sa oled |

Võid vaadata ka [Hyprmoni](https://github.com/erans/hyprmon/), kui tahad TUI-d, mis aitaks sind mitme ekraani paigutamisega.

### Heleduse juhtimine

Monitori heledust juhitakse spetsiaalsete heleduse suurendamise/vähendamise funktsiooniklahvidega. Kui hoiad nende vajutamise ajal all shift-klahvi, lähed maksimaalsele või minimaalsele heledusele. Klahvid juhivad ekraani, millel fookus on, nii et väliseid monitore, mis räägivad DDC/CI-d, reguleeritakse samamoodi nagu sülearvuti ekraani.

### Apple'i ekraanid

Kui kasutad Apple'i ekraani, töötavad ka tavalised klaviatuuri heledusklahvid automaatselt, kui fookus on Apple'i ekraanil. Seda tehakse käsu `asdcontrol` kaudu.

Pane tähele, et kui kasutad Apple 6K XDR ekraani, võid näha oma `hyprctl monitors` loendis fantoomekraani. Saad selle välja lülitada millegi sellisega nagu `hl.monitor({ output = "DP-2", disabled = true })` kaudu _Setup > Monitors_.

Inteli masinatel peaksid Apple'i ekraanidega ühendama tavalise Thunderbolt kaabli abil. Teistel Thunderboltita masinatel pead selle tööle saamiseks tavaliselt kasutama [DP + USB-A -> USB-C kaablit](https://www.amazon.com/dp/B0BNX7MS6N).
