# Monitorid

Omarchy eeldab vaikimisi, et kasutad 2x-võimekusega retina-klassi ekraani. Just seda on vaja, et saada need mõnusad, teravad programmeerijafondid. Selleks on optimeeritud peaaegu kõik uued kõrge eraldusvõimega ekraanidega premium-klassi sülearvutid. Just seda tahaksid kasutada 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) või 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) puhul.

Aga kui sa ei kasuta ekraani, mille PPI on 218 või rohkem, tasub sul monitori seadeid muuta. Näiteks kui sul on 27" või 32" 4K ekraan, saad sellele ülariba monitoripaneelilt valida murdarvulise skaleerimise või määrata vaikeväärtuse kõigile monitoridele, avades faili `~/.config/hypr/monitors.lua` ja valides selle kombinatsiooni jaoks soovitatud variandi:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Kui kasutad 1080p või 1440p ekraani, tahad tõenäoliselt lihtsalt kasutada 1x skaleerimist, ja sama ka GTK ja X11 rakenduste puhul, nii et saad kasutada:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Muudatused `GDK_SCALE` väärtuses rakenduvad rakendustele, mis käivitatakse pärast muudatust (ja GTK arvestab ainult täisarve, nii et hoia see oma monitori skaleerimise lähima täisarvu juures). Nii et veendu, et sulged aknad, mis on pärast muudatust liiga suured (või sulge kõik aknad klahvidega `Ctrl + Alt + Del`!).

Suuri monitori skaleerimissuhteid (1x, 1.25x, 1.6x, 2x, 3x, 4x) saad kiiresti läbi käia ka klahviga `Super + /`, et minna suuremaks, ja `Super + Alt + /`, et minna väiksemaks, või valida ühe ülariba monitoripaneelilt. Need muudavad ainult monitori, millele oled keskendunud, nii et sülearvuti ekraanil ja välisel ekraanil võib kummalgi olla oma skaleerimine. Paneel määrab ka iga monitori eraldusvõime, värskendussageduse ja pööramise. Sinu valikud salvestatakse selle füüsilise monitori jaoks faili `~/.local/state/omarchy/monitors/settings`, nii et need jäävad alles ka pärast taaskäivitust ja järgnevad monitorile, millisesse porti või dokki see järgmisena ühendatakse. Need on ülimuslikud sama monitori iga reegli suhtes failis `~/.config/hypr/monitors.lua`, mida Omarchy kunagi ei muuda. Kui eelistad määrata monitorid täielikult selles failis, lisa sinna `omarchy_monitor_panel_settings = false` ja paneeli muudatused kehtivad ainult seni, kuni Hyprland uuesti laaditakse. Kuna `GDK_SCALE` on kõigi ekraanide jaoks üks väärtus, määratakse valitud skaleerimisel see kõige väiksema skaleerimisega monitori järgi, nii et X11 rakendused tulevad tihedamal ekraanil veidi väikesed, selle asemel et teisel ekraanil liiga suured olla.

### Teksti suuremaks või väiksemaks tegemine

Monitori skaleerimine muudab kõige suurust. Kui tahad ainult suuremat või väiksemat _teksti_, on selleks üksainus nupp:

```
omarchy display text size 14
```

See võtab pikslisuuruse vahemikus 9 kuni 20 ja liigutab Omarchy kesta, GTK rakendusi ja sinu terminali koos, nii et kogu töölaud püsib proportsioonis. Käivita see ilma argumendita, et näha, kus sa parasjagu oled, ja `omarchy display text size reset`, et minna tagasi vaikeväärtuse juurde. Foot on ainus mahajääja: sellel pole võimalust oma konfiguratsiooni uuesti laadida, nii et töötavad terminalid säilitavad vana suuruse, kuni avad uue.

### Sülearvuti ekraanide laiendamine ja peegeldamine

Kui ühendad sülearvutiga välise ekraani, laiendatakse ekraani automaatselt. Aga saad selle muuta hoopis peegeldamiseks, valides ülariba monitoripaneelil _Laienda_ | _Peegelda_, Omarchy menüüs _Trigger > Riistvara_ või klahvidega `Super + Ctrl + Alt + Delete`. See on eriti abiks, kui see väline ekraan on projektor ja tahad töötamise ajal midagi näidata.

Laiendamise ajal lülitab sülearvuti kaane sulgemine sisemise ekraani automaatselt välja. Kaane avamine lülitab selle tagasi sisse. Seda saad juhtida ka käsitsi Omarchy menüü _Trigger > Riistvara_ kaudu või klahvidega `Super + Ctrl + Delete`.

### Mitme ekraani paigutamine

Hyprland töötab suurepäraselt mitme ekraaniga. Ülariba monitoripaneel joonistab need sinna, kus nad asuvad: lohista üks vastu teise külge, et see sinna liigutada, ja paigutus salvestatakse koos iga monitori muude seadetega. Kõige kohta, mida paneel ei kata, loe nende paigutamise kohta lähemalt siit: [Hyprlandi monitoride dokumentatsioon](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchys lähevad need faili `~/.config/hypr/monitors.lua` kirjetena `hl.monitor` — failiga on kaasas kommenteeritud näited monitori väljalülitamiseks, režiimide kohta, mida paneel ei paku, 10-bitise värvi ja muutuva värskendussageduse kohta.

Igal monitoril on oma tööruumid 1 kuni 10, nii et `Super + 1` tähendab alati selle monitori esimest tööruumi, millel parasjagu oled. Kapoti all nummerdab Hyprland tööruumid siiski kõigi monitoride lõikes: sinu sülearvuti ekraan (või esimene monitor) saab 1–10, järgmine monitor 11–20 ja nii edasi ning iga monitor säilitab oma ploki iga kord, kui selle ühendad. Kasuta neid numbreid, kui kirjutad konkreetse monitori jaoks [tööruumi reegleid](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) või aknareegleid, nii et tööruum 12 on sinu teise monitori teine tööruum. Failis `~/.local/state/omarchy/monitors/workspaces` on loetletud, milline plokk igal monitoril on.

Nooleklahvid töötavad üle monitoride, millel on sinu paigutuses ühine serv. Ekraanid, mis puudutavad ainult nurka või mille vahel on vahe, ei ole naabrid, nii et nende vahel liikumiseks kasuta `Ctrl + Alt + Tab`.

| Kiirklahv | Üle monitoride |
| --- | --- |
| `Super + Arrow` | Viib fookuse sellel küljel olevale monitorile, kui selles suunas pole enam akent |
| `Super + Shift + Arrow` | Vahetab sellel küljel oleval monitoril oleva aknaga |
| `Super + Alt + Arrow` | Liigutab akna sellel küljel oleva monitori rühma |
| `Super + Shift + Ctrl + Arrow` | Liigutab akna sellel küljel olevale monitorile, selle tööruumile, mida see näitab |
| `Super + Shift + Alt + Arrow` | Liigutab tööruumi sellel küljel olevale monitorile, säilitades selle numbri, kui see on vaba |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Viib fookuse järgmisele või eelmisele monitorile, olenemata paigutusest |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Jäävad monitorile, millel parasjagu oled |

Võid vaadata ka [Hyprmon](https://github.com/erans/hyprmon/), kui tahad TUI-d, mis aitab sul mitut ekraani paigutada.

### Heleduse reguleerimine

Monitori heledust juhitakse spetsiaalsete heleduse suurendamise/vähendamise funktsiooniklahvidega. Kui hoiad nende vajutamise ajal all shift-klahvi, lähed maksimaalsele või minimaalsele heledusele. Klahvid juhivad ekraani, millele oled keskendunud, nii et DDC/CI-d rääkivaid väliseid monitore reguleeritakse samamoodi nagu sülearvuti ekraani.

### Apple ekraanid

Kui kasutad Apple'i ekraani, töötavad tavalised klaviatuuri heleduseklahvid automaatselt ka siis, kui oled keskendunud Apple'i ekraanile. Seda tehakse käsu `asdcontrol` kaudu.

Märkus: kui kasutad Apple'i 6K XDR ekraani, võid näha oma `hyprctl monitors` loendis fantoom-ekraani. Selle saad välja lülitada millegi sellisega nagu `hl.monitor({ output = "DP-2", disabled = true })` failis `~/.config/hypr/monitors.lua`.

Inteli masinatel peaksid Apple'i ekraanidega ühendama tavalise Thunderbolt kaabli abil. Teistel masinatel, millel Thunderbolti pole, pead selle toimimiseks tavaliselt kasutama [DP + USB-A -> USB-C kaablit](https://www.amazon.com/dp/B0BNX7MS6N).
