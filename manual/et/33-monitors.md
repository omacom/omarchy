# Monitorid

Omarchy eeldab vaikimisi, et kasutad 2x-võimekusega retina-klassi ekraani. Just seda on sul vaja, et saada need kenad, teravad programmeerijafondid. Just selleks on optimeeritud peaaegu kõik uued kõrge eraldusvõimega ekraanidega premium-klassi sülearvutid. Just seda tahaksid kasutada 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) või 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) puhul.

Aga kui sa ei kasuta ekraani, mille PPI on 218 või rohkem, tahad monitori sätteid muuta. Näiteks kui sul on 27" või 32" 4K, saad sellele valida murdarvulise skaala ülemise riba monitoripaneelilt või määrata iga monitori vaikeväärtuse, avades faili `~/.config/hypr/monitors.lua` ja vahetades selle selle kombinatsiooni soovituse vastu:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Kui kasutad 1080p või 1440p ekraani, tahad tõenäoliselt kasutada lihtsalt 1x skaleerimist, ja sama GTK ja X11 rakenduste puhul, nii et saad kasutada:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Muudatused sättes `GDK_SCALE` kehtivad rakendustele, mis käivitatakse pärast muudatust (ja GTK arvestab ainult täisarve, nii et hoia see oma monitori skaala lähima täisarvu juures). Nii et veendu, et sulged pärast muudatust aknad, mis on ülemõõdulised (või sulge kõik aknad klahvidega `Ctrl + Alt + Del`!).

Saad ka kiiresti läbida peamised monitori skaleerimissuhted (1x, 1.25x, 1.6x, 2x, 3x, 4x), kasutades suuremaks minemiseks klahve `Super + /` ja väiksemaks minemiseks klahve `Super + Alt + /`, või valida ühe ülemise riba monitoripaneelilt. Need muudavad ainult monitori, millel on fookus, nii et sülearvuti ekraanil ja välisel ekraanil saab kummalgi olla oma skaala. Paneel määrab ka iga monitori eraldusvõime. Sinu valikud salvestatakse selle füüsilise monitori jaoks faili `~/.local/state/omarchy/monitors/settings`, nii et need säilivad pärast taaskäivitust ja järgnevad monitorile, millisesse porti või dokki see järgmisena ühendatakse. Need on ülimuslikud sama monitori mis tahes reegli suhtes failis `~/.config/hypr/monitors.lua`, mida Omarchy kunagi ei muuda. Kui eelistad oma monitore määrata täielikult selles failis, lisa sinna `omarchy_monitor_panel_settings = false` ja paneeli muudatused kestavad ainult seni, kuni Hyprland uuesti laaditakse. Kuna `GDK_SCALE` on kõigi ekraanide jaoks üks väärtus, määrab valitud skaala selle madalaima skaalaga monitori järgi, nii et X11 rakendused tulevad tihedamal ekraanil välja veidi väikesed, mitte teisel ülemõõdulised.

### Teksti suuremaks või väiksemaks tegemine

Monitori skaleerimine muudab kõige suurust. Kui kõik, mida soovid, on suurem või väiksem _tekst_, on selleks üksainus nupp:

```
omarchy display text size 14
```

See võtab pikslisuuruse vahemikus 9 kuni 20 ja liigutab Omarchy kesta, GTK rakendusi ja sinu terminali koos, nii et kogu töölaud püsib proportsioonis. Käivita see ilma argumendita, et näha, kus sa oled, ja `omarchy display text size reset`, et minna tagasi vaikeväärtuse juurde. Foot on ainus mahajääja: sellel pole võimalust oma konfiguratsiooni uuesti laadida, nii et töötavad terminalid säilitavad oma vana suuruse, kuni avad uue.

### Sülearvuti ekraanide laiendamine ja peegeldamine

Kui ühendad sülearvutiga välise ekraani, laiendatakse ekraani automaatselt. Aga saad selle muuta hoopis peegeldamiseks, kasutades Omarchy menüüs valikut _Trigger > Hardware_ või klahve `Super + Ctrl + Alt + Delete`. See on eriti kasulik, kui see väline ekraan on projektor ja soovid töötamise ajal midagi näidata.

Kui laiendad, lülitab sülearvuti kaane sulgemine sisemise ekraani automaatselt välja. Kaane avamine lülitab selle tagasi sisse. Seda saad ka käsitsi juhtida Omarchy menüüs valikuga _Trigger > Hardware_ või klahvidega `Super + Ctrl + Delete`.

### Mitme ekraani paigutamine

Hyprland töötab mitme ekraaniga suurepäraselt. Ülemise riba monitoripaneel joonistab need sinna, kus nad asuvad: lohista üks teise külje vastu, et see sinna liigutada, ja paigutus salvestatakse koos iga monitori muude sätetega. Kõige kohta, mida paneel ei kata, loe lähemalt, kuidas need paigutada, [Hyprlandi monitoride dokumentatsioonist](https://wiki.hypr.land/Configuring/Basics/Monitors/). Omarchys lähevad need faili `~/.config/hypr/monitors.lua` kirjetena `hl.monitor` — failiga on kaasas kommenteeritud näited konkreetse monitori fikseerimiseks kindla eraldusvõime, asukoha ja pööramise juurde.

Igal monitoril on oma tööalad 1 kuni 10, nii et `Super + 1` tähendab alati selle monitori esimest tööala, millel sa oled. Kulisside taga nummerdab Hyprland tööalad siiski kõigi monitoride üleselt: sinu sülearvuti ekraan (või esimene monitor) saab 1–10, järgmine monitor 11–20 ja nii edasi, ja iga monitor säilitab oma ploki iga kord, kui selle ühendad. Kasuta neid numbreid, kui kirjutad konkreetse monitori jaoks [tööalade reegleid](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) või aknareegleid, nii et tööala 12 on sinu teise monitori teine tööala. `~/.local/state/omarchy/monitors/workspaces` loetleb, milline plokk igal monitoril on.

Nooleklahvid töötavad üle nende monitoride, mis jagavad sinu paigutuses ühist serva. Ekraanid, mis puutuvad kokku ainult nurgast või mille vahel on vahe, ei ole naabrid, nii et kasuta nende vahel liikumiseks klahve `Ctrl + Alt + Tab`.

| Kiirklahv | Monitoride vahel |
| --- | --- |
| `Super + Arrow` | Viib fookuse sellel küljel olevale monitorile, kui selles suunas enam aknaid ei ole |
| `Super + Shift + Arrow` | Vahetab sellel küljel oleval monitoril oleva aknaga |
| `Super + Alt + Arrow` | Liigutab akna sellel küljel oleval monitoril olevasse rühma |
| `Super + Shift + Ctrl + Arrow` | Liigutab akna sellel küljel olevale monitorile, selle tööalale, mida see näitab |
| `Super + Shift + Alt + Arrow` | Liigutab tööala sellel küljel olevale monitorile, säilitades selle numbri, kui see on vaba |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Viib fookuse järgmisele või eelmisele monitorile, olenemata paigutusest |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Püsivad monitoril, millel sa oled |

Võid vaadata ka [Hyprmon](https://github.com/erans/hyprmon/), kui soovid TUI-d, mis aitab sul mitut ekraani paigutada.

### Heleduse reguleerimine

Monitori heledust reguleeritakse spetsiaalsete heleduse suurendamise/vähendamise funktsiooniklahvidega. Kui hoiad nende vajutamise ajal all Shift-klahvi, lähed maksimaalsele või minimaalsele heledusele. Klahvid reguleerivad ekraani, millel on fookus, nii et väliseid monitore, mis räägivad DDC/CI keelt, reguleeritakse samamoodi nagu sülearvuti ekraani.

### Apple'i ekraanid

Kui kasutad Apple'i ekraani, töötavad tavalised klaviatuuri heledusklahvid samuti automaatselt, kui fookus on Apple'i ekraanil. Seda tehakse käsu `asdcontrol` kaudu.

Pane tähele, et kui kasutad Apple'i 6K XDR ekraani, võid näha oma `hyprctl monitors` loendis fantoomekraani. Saad selle välja lülitada millegi sellisega nagu `hl.monitor({ output = "DP-2", disabled = true })` failis `~/.config/hypr/monitors.lua`.

Inteli masinatel peaksid Apple'i ekraanidega ühendama tavalise Thunderbolt kaabli abil. Teistel, Thunderboltita masinatel pead tavaliselt kasutama [DP + USB-A -> USB-C kaablit](https://www.amazon.com/dp/B0BNX7MS6N), et see tööle saada.
