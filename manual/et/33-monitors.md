# Monitorid

Omarchy eeldab vaikimisi, et kasutad 2x-võimekusega retina-klassi ekraani. Seda on vaja, et saada need mõnusad, teravad programmeerijafondid. Selle jaoks on optimeeritud peaaegu kõik uued kõrge eraldusvõimega ekraaniga premium-klassi sülearvutid. Just sellist tahaksid kasutada 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) või 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) puhul.

Aga kui sul pole ekraani PPI-ga 218 või rohkem, tasub monitori sätteid muuta. Näiteks kui sul on 27" või 32" 4K, saad sellele valida murdarvulise skaala ülaribal olevast monitoripaneelist või määrata vaikeskaala kõigile monitoridele, avades `~/.config/hypr/monitors.lua` ja valides selle kombinatsiooni jaoks soovitatud väärtuse:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Kui kasutad 1080p või 1440p ekraani, tahad tõenäoliselt lihtsalt kasutada 1x skaleerimist ja sama ka GTK ja X11 rakenduste puhul, nii et võid kasutada:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` muudatused kehtivad rakendustele, mis käivitatakse pärast muudatust (ja GTK arvestab ainult täisarve, nii et hoia see oma monitori skaala lähima täisarvu juures). Nii et sulge kindlasti aknad, mis on pärast muudatust liiga suured (või sulge kõik aknad klahvidega `Ctrl + Alt + Del`!).

Põhilisi monitori skaleerimissuhteid (1x, 1.25x, 1.6x, 2x, 3x, 4x) saad ka kiiresti läbi käia, kasutades suuremaks minemiseks `Super + /` ja väiksemaks minemiseks `Super + Alt + /`, või valida ühe ülaribal olevast monitoripaneelist. Need muudavad ainult monitori, millel on fookus, nii et sülearvuti ekraanil ja välisel ekraanil võib kummalgi olla oma skaala. Paneel määrab ka iga monitori eraldusvõime, värskendussageduse ja pööramise. Sinu valikud salvestatakse selle füüsilise monitori jaoks faili `~/.local/state/omarchy/monitors/settings`, nii et need püsivad ka pärast taaskäivitust ja järgnevad monitorile, millisesse porti või dokki see järgmisena ühendatakse. Need on ülimuslikud sama monitori mis tahes reegli suhtes failis `~/.config/hypr/monitors.lua`, mida Omarchy kunagi ei muuda. Kui eelistad oma monitore määrata täielikult selles failis, lisa sinna `omarchy_monitor_panel_settings = false` ja paneeli muudatused kestavad ainult seni, kuni Hyprland uuesti laaditakse. Kuna `GDK_SCALE` on kõigi ekraanide jaoks üks väärtus, määratakse see valitud skaala puhul madalaima skaalaga monitori järgi, nii et X11 rakendused tulevad tihedamal ekraanil pisut väikesed, selle asemel et teisel liiga suured olla.

### Teksti suuremaks või väiksemaks tegemine

Monitori skaleerimine muudab kõige suurust. Kui tahad ainult suuremat või väiksemat _teksti_, on selleks üksainus nupp:

```
omarchy display text size 14
```

See võtab pikslisuuruse vahemikus 9 kuni 20 ja liigutab Omarchy kesta, GTK rakendusi ja sinu terminali koos, nii et kogu töölaud jääb proportsiooni. Käivita see ilma argumendita, et näha, kus sa oled, ja `omarchy display text size reset`, et minna tagasi vaikeväärtuse juurde. Foot on ainus mahajääja: sellel pole võimalust oma konfiguratsiooni uuesti laadida, nii et töötavad terminalid hoiavad oma vana suurust, kuni avad uue.

### Sülearvuti ekraanide laiendamine ja peegeldamine

Kui ühendad sülearvutiga välise ekraani, laiendatakse ekraani automaatselt. Aga saad selle muuta hoopis peegeldamiseks, kasutades Omarchy menüüs _Trigger > Hardware_ või `Super + Ctrl + Alt + Delete`. See on eriti kasulik, kui see väline ekraan on projektor ja tahad töötamise ajal midagi näidata.

Laiendamise ajal lülitab sülearvuti kaane sulgemine sisemise ekraani automaatselt välja. Kaane avamine lülitab selle tagasi sisse. Saad seda ka käsitsi juhtida, kasutades Omarchy menüüs _Trigger > Hardware_ või `Super + Ctrl + Delete`.

### Mitme ekraani paigutamine

Hyprland töötab suurepäraselt mitme ekraaniga. Ülaribal olev monitoripaneel joonistab need sinna, kus nad asuvad: lohista üks teise külje vastu, et see sinna liigutada, ja paigutus salvestatakse koos iga monitori muude sätetega. Kõige kohta, mida paneel ei kata, loe lähemalt nende paigutamise kohta [Hyprlandi monitoride dokumentatsioonist](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchys lähevad need faili `~/.config/hypr/monitors.lua` kirjetena `hl.monitor` — failiga on kaasas kommenteeritud näited monitori väljalülitatuna hoidmise, paneeli poolt pakkumata režiimide, 10-bitise värvi ja muutuva värskendussageduse kohta.

Igal monitoril on oma tööruumid 1 kuni 10, nii et `Super + 1` tähendab alati selle monitori esimest tööruumi, millel oled. Kulisside taga nummerdab Hyprland tööruumid siiski kõigi monitoride lõikes: sinu sülearvuti ekraan (või esimene monitor) saab 1–10, järgmine monitor 11–20 ja nii edasi ning iga monitor hoiab oma plokki iga kord, kui selle ühendad. Kasuta neid numbreid, kui kirjutad konkreetse monitori jaoks [tööruumi reegleid](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) või aknareegleid, nii et tööruum 12 on sinu teise monitori teine tööruum. `~/.local/state/omarchy/monitors/workspaces` loetleb, milline plokk igal monitoril on.

Nooleklahvid töötavad monitoride vahel, mis jagavad sinu paigutuses serva. Ekraanid, mis puutuvad kokku ainult nurgast või mille vahel on vahe, pole naabrid, nii et kasuta nende vahel liikumiseks `Ctrl + Alt + Tab`.

| Kiirklahv | Monitoride vahel |
| --- | --- |
| `Super + Arrow` | Liigutab fookuse sellel poolel olevale monitorile, kui selles suunas pole enam ühtegi akent |
| `Super + Shift + Arrow` | Vahetab kohad sellel poolel oleval monitoril oleva aknaga |
| `Super + Alt + Arrow` | Liigutab akna sellel poolel oleval monitoril olevasse rühma |
| `Super + Shift + Ctrl + Arrow` | Liigutab akna sellel poolel olevale monitorile, tööruumile, mida see näitab |
| `Super + Shift + Alt + Arrow` | Liigutab tööruumi sellel poolel olevale monitorile, säilitades selle numbri, kui see on vaba |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Liigutab fookuse järgmisele või eelmisele monitorile, olenemata paigutusest |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Jäävad monitorile, millel oled |

Saad vaadata ka [Hyprmoni](https://github.com/erans/hyprmon/), kui tahad TUI-d, mis aitaks sind mitme ekraani paigutamisel.

### Heleduse juhtimine

Monitori heledust juhitakse spetsiaalsete funktsiooniklahvidega heleduse suurendamiseks/vähendamiseks. Kui hoiad nende vajutamise ajal shift-klahvi all, lähed maksimaalsele või minimaalsele heledusele. Klahvid juhivad ekraani, millel on fookus, nii et DDC/CI-d kõnelevaid välismonitore reguleeritakse samamoodi nagu sülearvuti ekraani.

### Apple'i ekraanid

Kui kasutad Apple'i ekraani, töötavad tavalised klaviatuuri heledusklahvid automaatselt samuti, kui fookus on Apple'i ekraanil. Seda tehakse käsu `asdcontrol` kaudu.

Pane tähele, et kui kasutad Apple 6K XDR ekraani, võid näha oma `hyprctl monitors` loendis fantoomekraani. Saad selle välja lülitada millegagi nagu `hl.monitor({ output = "DP-2", disabled = true })` failis `~/.config/hypr/monitors.lua`.

Inteli masinatel peaksid Apple'i ekraanidega ühenduma tavalise Thunderbolt kaabli abil. Teistel Thunderboltita masinatel pead selle toimimiseks tavaliselt kasutama [DP + USB-A -> USB-C kaablit](https://www.amazon.com/dp/B0BNX7MS6N).
