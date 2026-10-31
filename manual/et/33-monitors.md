# Monitorid

Omarchy eeldab vaikimisi, et kasutad 2x-võimekusega retina-klassi ekraani. Seda on vaja, et saada need mõnusad, teravad programmeerijafondid. Selle jaoks on optimeeritud peaaegu kõik uued kõrge eraldusvõimega ekraaniga premium-klassi sülearvutid. Seda tahaksid kasutada 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) või 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) peal.

Aga kui sa ei kasuta ekraani, mille PPI on 218 või kõrgem, tasub sul monitori seadeid muuta. Näiteks kui sul on 27" või 32" 4K, saad sellele valida murdarvulise skaala ülaribal olevast monitoripaneelist või määrata vaikeväärtuse igale monitorile, avades `~/.config/hypr/monitors.lua` ja vahetades selle kombinatsiooni jaoks soovitatud valiku vastu:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Kui kasutad 1080p või 1440p ekraani, tahad tõenäoliselt lihtsalt kasutada 1x skaleerimist ning sama ka GTK ja X11 rakenduste puhul, nii et saad kasutada:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` muudatused kehtivad rakendustele, mis käivitatakse pärast muudatust (ja GTK arvestab ainult täisarve, nii et hoia see oma monitori skaala lähima täisarvu juures). Nii et sulge kindlasti need aknad, mis on pärast muudatust liiga suured (või sulge kõik aknad klahvidega `Ctrl + Alt + Del`!).

Saad ka kiiresti läbi käia peamised monitori skaleerimissuhted (1x, 1.25x, 1.6x, 2x, 3x, 4x), kasutades kõrgemaks minemiseks klahve `Super + /` ja madalamaks minemiseks klahve `Super + Alt + /`, või valida ühe ülaribal olevast monitoripaneelist. Need muudavad ainult monitori, millel oled fokuseeritud, nii et sülearvuti ekraanil ja välisel ekraanil saab kummalgi olla oma skaala. Paneel määrab ka iga monitori eraldusvõime. Sinu valikud salvestatakse selle füüsilise monitori jaoks faili `~/.local/state/omarchy/monitors/settings`, nii et need püsivad ka pärast taaskäivitust ja järgnevad monitorile, ükskõik millisesse porti või dokki see järgmisena ühendatakse. Need on ülimuslikud sama monitori mis tahes reegli suhtes failis `~/.config/hypr/monitors.lua`, mida Omarchy kunagi ei muuda. Kuna `GDK_SCALE` on kõigi ekraanide jaoks üks väärtus, määratakse valitud skaala puhul see madalaima skaalaga monitori järgi, nii et X11 rakendused tulevad tihedamal ekraanil veidi väikesed, selle asemel et olla teisel liiga suured.

### Teksti suuremaks või väiksemaks tegemine

Monitori skaleerimine muudab kõige suurust. Kui tahad ainult suuremat või väiksemat _teksti_, on selle jaoks üksainus nupp:

```
omarchy display text size 14
```

See võtab pikslisuuruse vahemikus 9 kuni 20 ja liigutab Omarchy kesta, GTK rakendusi ja sinu terminali koos, nii et kogu töölaud püsib proportsioonis. Käivita see ilma argumendita, et näha, kus sa oled, ja `omarchy display text size reset`, et minna tagasi vaikeväärtuse juurde. Foot on ainus mahajääja: sellel pole võimalust oma konfiguratsiooni uuesti laadida, nii et töötavad terminalid hoiavad oma vana suurust, kuni avad uue.

### Sülearvuti ekraanide laiendamine ja peegeldamine

Kui ühendad sülearvutiga välise ekraani, laiendatakse ekraani automaatselt. Aga saad selle muuta hoopis peegeldamiseks, kasutades Omarchy menüüs valikut _Trigger > Hardware_ või klahve `Super + Ctrl + Alt + Delete`. See on eriti abiks, kui see väline ekraan on projektor ja tahad töötamise ajal midagi näidata.

Kui laiendad, lülitab sülearvuti kaane sulgemine sisemise ekraani automaatselt välja. Kaane avamine lülitab selle tagasi sisse. Saad seda ka käsitsi juhtida, kasutades Omarchy menüüs valikut _Trigger > Hardware_ või klahve `Super + Ctrl + Delete`.

### Mitme ekraani paigutamine

Hyprland töötab mitme ekraaniga suurepäraselt. Ülaribal olev monitoripaneel joonistab need sinna, kus nad asuvad: lohista üks teise serva vastu, et see sinna liigutada, ja paigutus salvestatakse koos iga monitori muude seadetega. Kõige kohta, mida paneel ei kata, loe lähemalt nende paigutamise kohta [Hyprlandi monitoride dokumentatsioonist](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchys lähevad need faili `~/.config/hypr/monitors.lua` kirjetena `hl.monitor` — failiga on kaasas kommenteeritud näited konkreetse monitori kinnistamiseks eraldusvõime, asukoha ja pööramise külge.

Igal monitoril on oma tööruumid 1 kuni 10, nii et `Super + 1` tähendab alati selle monitori esimest tööruumi, millel oled. Kulisside taga nummerdab Hyprland tööruumid ikkagi kõigi monitoride lõikes: sinu sülearvuti ekraan (või esimene monitor) saab 1–10, järgmine monitor 11–20 ja nii edasi ning iga monitor hoiab oma plokki iga kord, kui selle ühendad. Kasuta neid numbreid, kui kirjutad konkreetse monitori jaoks [tööruumide reegleid](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) või aknareegleid, nii et tööruum 12 on sinu teise monitori teine tööruum. `~/.local/state/omarchy/monitors/workspaces` loetleb, milline plokk igal monitoril on.

Nooleklahvid töötavad monitoride vahel, mis jagavad sinu paigutuses serva. Ekraanid, mis puudutavad üksteist ainult nurgast või mille vahel on vahe, ei ole naabrid, nii et kasuta nende vahel liikumiseks klahve `Ctrl + Alt + Tab`.

| Kiirklahv | Monitoride vahel |
| --- | --- |
| `Super + Arrow` | Liigutab fookuse sellel küljel olevale monitorile, kui selles suunas pole enam ühtegi akent järel |
| `Super + Shift + Arrow` | Vahetab sellel küljel oleval monitoril oleva aknaga |
| `Super + Alt + Arrow` | Liigutab akna sellel küljel oleval monitoril olevasse rühma |
| `Super + Shift + Ctrl + Arrow` | Liigutab akna sellel küljel olevale monitorile, selle näidatavale tööruumile |
| `Super + Shift + Alt + Arrow` | Liigutab tööruumi sellel küljel olevale monitorile, säilitades selle numbri, kui see on vaba |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Liigutab fookuse järgmisele või eelmisele monitorile, paigutusest sõltumata |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Jäävad monitorile, millel oled |

Vaata ka [Hyprmon](https://github.com/erans/hyprmon/), kui tahad TUI-d, mis aitaks sind mitme ekraani paigutamisel.

### Heleduse juhtimine

Monitori heledust juhitakse spetsiaalsete heleduse suurendamise/vähendamise funktsiooniklahvidega. Kui hoiad nende vajutamise ajal shift-klahvi all, lähed maksimaalsele või minimaalsele heledusele. Klahvid juhivad ekraani, millel oled fokuseeritud, nii et väliseid monitore, mis räägivad DDC/CI-d, reguleeritakse samamoodi nagu sülearvuti ekraani.

### Apple'i ekraanid

Kui kasutad Apple'i ekraani, töötavad tavalised klaviatuuri heledusklahvid ka automaatselt, kui oled fokuseeritud Apple'i ekraanile. Seda tehakse käsu `asdcontrol` kaudu.

Pane tähele, et kui kasutad Apple 6K XDR ekraani, võid näha oma `hyprctl monitors` loendis fantoom-ekraani. Saad selle välja lülitada millegagi nagu `hl.monitor({ output = "DP-2", disabled = true })` failis `~/.config/hypr/monitors.lua`.

Inteli masinatel peaksid Apple'i ekraanidega ühenduma tavalise Thunderbolt kaabli abil. Teistel masinatel, millel Thunderbolti pole, pead selle tööle saamiseks tavaliselt kasutama [DP + USB-A -> USB-C kaablit](https://www.amazon.com/dp/B0BNX7MS6N).
