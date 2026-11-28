# Monitorid

Omarchy eeldab vaikimisi, et sul on kasutusel 2x skaleerimist toetav retina-klassi ekraan. Seda on vaja, et saada need ilusad, teravad programmeerijafondid. Selle jaoks on optimeeritud peaaegu kõik uued kõrge eraldusvõimega ekraanidega premium-klassi sülearvutid. Seda tahaksid kasutada 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) või 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) puhul.

Aga kui sa ei kasuta ekraani, mille PPI on 218 või kõrgem, tahad monitori seadistusi muuta. Näiteks kui sul on 27" või 32" 4K, saad sellele valida murdarvulise skaala ülariba monitoripaneelilt või määrata vaikeväärtuse igale monitorile, avades faili `~/.config/hypr/monitors.lua` ja vahetades selle selle kombinatsiooni jaoks soovitatud seadistuse vastu:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Kui kasutad 1080p või 1440p ekraani, tahad tõenäoliselt lihtsalt kasutada 1x skaleerimist, ja sama GTK ja X11 rakenduste jaoks, nii et saad kasutada:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` muudatused kehtivad rakendustele, mis käivitatakse pärast muudatust (ja GTK arvestab ainult täisarve, nii et hoia seda oma monitori skaala lähima täisarvu juures). Seega sulge pärast muudatust kindlasti need aknad, mis on liiga suured (või sulge kõik aknad klahvidega `Ctrl + Alt + Del`!).

Saad ka monitori peamised skaleerimissuhted (1x, 1.25x, 1.6x, 2x, 3x, 4x) kiiresti läbi käia, kasutades suuremaks minemiseks klahve `Super + /` ja väiksemaks minemiseks klahve `Super + Alt + /`, või valida ühe ülariba monitoripaneelilt. Need muudavad ainult monitori, millel on parasjagu fookus, nii et sülearvuti ekraanil ja välisel ekraanil saab kummalgi olla oma skaala. Paneel määrab ka iga monitori eraldusvõime, värskendussageduse ja pööramise. Sinu valikud salvestatakse selle füüsilise monitori jaoks faili `~/.local/state/omarchy/monitors/settings`, nii et need püsivad taaskäivitusest kauem ja järgnevad monitorile, ükskõik millisesse porti või dokki see järgmisena ühendatakse. Need on ülimuslikud sama monitori iga reegli suhtes failis `~/.config/hypr/monitors.lua`, mida Omarchy kunagi ei muuda. Kui eelistad oma monitorid seadistada täielikult selles failis, lisa sinna `omarchy_monitor_panel_settings = false` ja paneeli muudatused kestavad ainult seni, kuni Hyprland uuesti laetakse. Kuna `GDK_SCALE` on kõigi ekraanide jaoks üks väärtus, määratakse valitud skaala puhul see kõige väiksema skaalaga monitori järgi, nii et X11 rakendused tulevad tihedamal ekraanil pisut väikesed, selle asemel et olla teisel liiga suured.

### Teksti suuremaks või väiksemaks tegemine

Monitori skaleerimine muudab kõige suurust. Kui tahad ainult suuremat või väiksemat _teksti_, on selleks üksainus nupp:

```
omarchy display text size 14
```

See võtab pikslisuuruse vahemikus 9 kuni 20 ja liigutab Omarchy kesta, GTK rakendusi ja sinu terminali koos, nii et kogu töölaud jääb proportsiooni. Käivita see ilma argumendita, et näha, kus sa parasjagu oled, ja `omarchy display text size reset`, et naasta vaikeväärtuse juurde. Foot on ainus mahajääja: sellel pole võimalust oma konfiguratsiooni uuesti laadida, nii et töötavad terminalid säilitavad vana suuruse, kuni avad uue.

### Sülearvuti ekraanide laiendamine ja peegeldamine

Kui ühendad sülearvutiga välise ekraani, laiendatakse kuva automaatselt. Aga saad selle vahetada peegeldamise vastu ülariba monitoripaneelil valikutega _Extend_ | _Mirror_, Omarchy menüüs valikuga _Trigger > Hardware_ või klahvidega `Super + Ctrl + Alt + Delete`. See on eriti abiks, kui see väline ekraan on projektor ja tahad töötamise ajal midagi näidata.

Kui laiendad, lülitab sülearvuti kaane sulgemine sisemise ekraani automaatselt välja. Kaane avamine lülitab selle uuesti sisse. Saad seda ka käsitsi juhtida Omarchy menüüs valikuga _Trigger > Hardware_ või klahvidega `Super + Ctrl + Delete`.

Kuni sülearvuti on vooluvõrku ühendatud, ei pane kaane sulgemine seda kunagi unerežiimi, nii et dokitud sülearvuti jääb ärkvele isegi siis, kui väline ekraan korraks lahti ühendub. Kui ühtegi välist ekraani ühendatud pole, lukustab kaane sulgemine vooluvõrgus olles selle lihtsalt. Akutoitel läheb see kaane sulgemisel nagu tavaliselt puhkerežiimi.

### Mitme ekraani paigutamine

Hyprland töötab mitme ekraaniga suurepäraselt. Ülariba monitoripaneel joonistab need sinna, kus nad asuvad: lohista üks vastu teise külge, et see sinna liigutada, ja paigutus salvestatakse koos iga monitori muude seadistustega. Kõige kohta, mida paneel ei kata, loe nende paigutamise kohta lähemalt [Hyprlandi monitoride dokumentatsioonist](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchys lähevad need faili `~/.config/hypr/monitors.lua` kirjetena `hl.monitor` — failiga on kaasas kommenteeritud näited monitori väljalülitatuna hoidmise, paneeli poolt pakkumata režiimide, 10-bitise värvi ja muutuva värskendussageduse kohta.

Igal monitoril on oma tööalad 1 kuni 10, nii et `Super + 1` tähendab alati selle monitori esimest tööala, millel parasjagu oled. Kulisside taga nummerdab Hyprland tööalad ikkagi kõigi monitoride lõikes: sinu sülearvuti ekraan (või esimene monitor) saab 1–10, järgmine monitor 11–20 ja nii edasi, ja iga monitor säilitab oma ploki iga kord, kui selle ühendad. Kasuta neid numbreid, kui kirjutad konkreetse monitori jaoks [tööala reegleid](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) või aknareegleid, nii et tööala 12 on sinu teise monitori teine tööala. Fail `~/.local/state/omarchy/monitors/workspaces` loetleb, milline plokk igal monitoril on.

Nooleklahvid töötavad monitoride vahel, mis jagavad sinu paigutuses serva. Ekraanid, mis puutuvad kokku ainult nurgast või mille vahel on vahe, ei ole naabrid, nii et kasuta nende vahel liikumiseks klahve `Ctrl + Alt + Tab`.

| Kiirklahv | Monitoride vahel |
| --- | --- |
| `Super + Arrow` | Liigutab fookuse sellel küljel olevale monitorile, kui selles suunas pole enam ühtegi akent |
| `Super + Shift + Arrow` | Vahetab koha aknaga sellel küljel oleval monitoril |
| `Super + Alt + Arrow` | Liigutab akna gruppi sellel küljel oleval monitoril |
| `Super + Shift + Ctrl + Arrow` | Liigutab akna sellel küljel olevale monitorile, selle tööalale, mida see parasjagu näitab |
| `Super + Shift + Alt + Arrow` | Liigutab tööala sellel küljel olevale monitorile, säilitades selle numbri, kui see on vaba |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Liigutab fookuse järgmisele või eelmisele monitorile, paigutusest sõltumata |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Jäävad monitorile, millel parasjagu oled |

Võid vaadata ka [Hyprmoni](https://github.com/erans/hyprmon/), kui tahad TUI-d, mis aitab sul mitut ekraani paigutada.

### Heleduse juhtimine

Monitori heledust juhitakse spetsiaalsete heleduse suurendamise/vähendamise funktsiooniklahvidega. Kui hoiad nende vajutamise ajal Shift-klahvi all, lähed maksimaalsele või minimaalsele heledusele. Klahvid juhivad ekraani, millel on parasjagu fookus, nii et DDC/CI-d rääkivaid väliseid monitore reguleeritakse samamoodi nagu sülearvuti ekraani.

### Apple'i ekraanid

Kui kasutad Apple'i ekraani, töötavad ka tavalised klaviatuuri heleduseklahvid automaatselt, kui fookus on Apple'i ekraanil. Seda tehakse käsu `asdcontrol` kaudu.

Pane tähele, et kui kasutad Apple'i 6K XDR ekraani, võid näha oma loendis `hyprctl monitors` fantoomekraani. Saad selle välja lülitada millegagi nagu `hl.monitor({ output = "DP-2", disabled = true })` failis `~/.config/hypr/monitors.lua`.

Inteli masinatel peaksid Apple'i ekraanidega ühenduma tavalise Thunderbolt-kaabli abil. Teistel masinatel, millel Thunderbolti pole, pead selle tööle saamiseks tavaliselt kasutama [DP + USB-A -> USB-C kaablit](https://www.amazon.com/dp/B0BNX7MS6N).
