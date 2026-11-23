# Navigeerimine

Kõik Omarchy's toimub klaviatuuri kaudu — _KÕIK!_ Kui süsteem esimest korda käivitub, ei saa sa ainuüksi hiirega sõna otseses mõttes midagi teha. Kuid saad vajutada `Super + Space`, et kuvada Omarchy Menu, ja siit saad teha peaaegu kõike.

Kuid Omarchy menüü ei ole isegi mõeldud enamiku ajast süsteemi peamiseks juhtimisviisiks. Me saame sellest kiiremini! Kõik kõige olulisemad rakendused on seotud otse üksikute kiirklahvidega. Terminali käivitad klahvidega `Super + Return` ja brauseri klahvidega `Super + Shift + Return`. Proovi teha üht kohe teise järel ja näed Hyprlandi paanpaigutuse võlu tegevuses:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Seejärel saad vajutada `Super + J`, et laduda need kõrvuti seismise asemel üksteise peale:

 ![navigation-stacked](images/navigation-stacked.webp)

Vajuta uuesti `Super + J`, et viia need tagasi kõrvuti asenditesse. Seejärel proovi brauseris olles `Super + Shift + Arrow Right`, et aknad omavahel vahetada.

Nüüd proovi `Super + Shift + T`, et käivitada Activity monitor. See ilmub ujuva aknana. Saad selle paanpaigutada klahvidega `Super + T` (ja vajuta seda uuesti, et muuta see jälle ujuvaks). Nüüd vajuta `Super + Shift + F`, et avada failihaldur. Sul on korralik nelja aknaga paigutus:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Sa navigeerid akna vahel, mida soovid aktiivseks muuta, klahvidega `Super + Arrow`. See vahetab fookust ja liigutab kursori uue rakenduse keskele. Ekraani serval liigub see edasi sellel poolel olevale monitorile.

Kui vajutad `Super + Shift + 2`, liigutad praegu fookuses oleva rakenduse teisele tööruumile. `Super + Shift + 1` liigutab selle tagasi. (Ja `Super + Shift + Alt + 2` liigutab praegu fookuses oleva rakenduse teisele tööruumile, ilma sellele lülitumata).

Mitme monitori korral on igal monitoril oma tööruumid 1 kuni 10. `Super + 2` läheb selle monitori teisele tööruumile, millel sa oled, ja iga monitori ülemine riba näitab selle enda tööruume ja seda, mida see parajasti näitab. `Super + Tab` liigub läbi selle monitori tööruumide, millel sa oled. `Super + Shift + Ctrl + Arrows` liigutab akna, millel sa oled, selles suunas olevale monitorile, tööruumile, mida see näitab, ja `Super + Shift + Alt + Arrows` liigutab tööruumi, millel sa oled, selles suunas olevale monitorile, kus see võtab sama numbri, kui see on vaba. Monitor säilitab oma tööruumid, kui sa selle lahti ühendad: need liituvad teise ekraani omadega, nummerdatuna pärast neid, mis sellel juba on, ja lähevad tagasi oma vanade numbrite alla, kui monitor naaseb.

Kui hoiad `Super` all ja klõpsad hiirega aknal, saad selle asukohta ümber korraldada. Kui hoiad `Super` all ja kasutad hiire paremat nuppu, saad akna suurust vabalt muuta.

Akna sulged klahvidega `Super + W` või `Super + Q` (ja kõik aknad sulged klahvidega `Ctrl + Alt + Delete`).

Saad minna ka täisekraanile klahvidega `Super + F` või isegi ainult täislaiusesse (ülemist riba säilitades) klahvidega `Super + Alt + F` või täisekraanile akna sees klahvidega `Super + Ctrl + F` (hea YouTube'i jaoks!).

### Dwindle vs keriv paigutus

Omarchy vaikepaigutust nimetatakse dwindle'iks. See hoiab kõiki aknaid, mille avad ühel tööruumil, kogu aeg nähtaval, isegi kui see peab neid selleks väiksemaks kahandama.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Kuid saad valida ka tööruumi muutmise kerivaks paigutuseks, kus aknad on rivistatud kõrvuti, väljapoole ekraani nähtavat serva. Ühe tööruumi muudad sellesse paigutusse klahvidega `Super + L`.

`Super + L` uuesti vajutamine muudab tööruumi ujuvaks, kus aknad kattuvad vabalt ja paigutad need ise, ning kolmas vajutus viib selle tagasi dwindle'i. `Super + Alt + L` käib need läbi teistpidi. Aken, mis ujub niikuinii — selline, mille tõstsid välja `Super + T` abil, või rakendus, mis avaneb alati ujuvana — jääb ujuvaks, kui tööruum läheb tagasi paanpaigutusse. Ülemine riba märgib tööruumi, millel sa oled, selle paigutusega: ruut dwindle'i jaoks, ring keriva jaoks ja kolmnurk ujuva jaoks. Selle märgi klõpsamine vahetab ka paigutust läbi ning sama teeb ekraaniklahv sülearvutitel, millel see on.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valik kehtib tööruumide kaupa ja see jääb püsima. Nii saad hoida tööruumi 1 dwindle'il sirvimiseks ja tööruumi 2 kerival koodi jaoks ning need tulevad pärast taaskäivitust samamoodi tagasi.

Kui soovid kasutada kerivat paigutust vaikepaigutusena, saad selle seada failis `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Ujuvad tööruumid

Ujuv tööruum töötab nagu traditsiooniline töölaud: aknad kattuvad ning sa liigutad ja muudad nende suurust ise. Iga aken saab sinu teema värvides tiitliriba nuppudega minimeerimiseks, maksimeerimiseks ja sulgemiseks. `Super + M` minimeerib ka fookuses oleva akna. Minimeeritud aken ootab dokis; klõpsa selle rakendust, et see tagasi tuua. Klõpsa akent, et tuua see ettepoole. Muuda selle suurust mis tahes servast või nurgast. Topeltklõpsa tiitliribal, et maksimeerida aken, säilitades samal ajal ülemise riba nähtavana, ja uuesti, et saada selle vana suurus tagasi. Chrome ja teised Chromiumil põhinevad brauserid, Disks ja Document Viewer jätavad tiitliriba vahele ja kasutavad selle asemel oma päist; `Super + Alt + F` maksimeerib need ja `Super + M` minimeerib need.

Ujuv tööruum näitab ka dokki sinu kinnitatud rakendustega, kõigega, mis parajasti töötab, ja iga rakenduse ruudustikuga rakenduste nupu taga, mille avavad ka `Super + Alt + Space` ja _Apps_ Omarchy menüüs. Paremklõpsa ruudustikul rakendust või vajuta `Delete`, et see desinstallida. Klõpsa rakendust, et see avada või tuua selle aken ettepoole; klõpsa uuesti, et liikuda läbi selle akende. Files toob tagasi ainult akna tööruumilt, millel sa oled, ja avab muidu uue ning Terminal ja Agent käivitavad alati uue, kuigi minimeeritud aken tuleb kõigepealt tagasi. Keskmine klõps avab uue akna. Lohista ikooni dokil selle liigutamiseks; töötava rakenduse lohistamine teiste sekka jätab selle sinna. Paremklõpsa, et hoida rakendust dokis, võtta see sealt välja või see sulgeda. Dokk annab teed täisekraani aknale. Paremklõpsa rakenduste nuppu, et liigutada dokk teisele servale või panna see peituma, kuni kursor jõuab selle servani. Asukoht on ka valiku _Appearance > Dock > Dock Position_ all ning `omarchy dock position left` ja `omarchy dock autohide on` seavad mõlemad terminalist. Rakendused, mida hoiad dokis, on tuhmid, kui nad ei tööta.

Uued tööruumid ja kõik, millele sa ei ole `Super + L` abil oma paigutust andnud, kasutavad vaikepaigutust. Vaikepaigutuse muutmine lähtestab iga ilma akendeta tööruumi sellele, samas kui akendega tööruum säilitab paigutuse, mis sellel on. Dokki minimeeritud aken loetakse endiselt aknaks tööruumil, millelt see lahkus. Vali see valiku _Appearance > Workspace Layout_ alt: Tiling, Scrolling või Floating. `omarchy hyprland workspace layout default scrolling` seab selle terminalist.

### Akende rühmitamine

Aknaid saab rühmitada klahvidega `Super + G`. Kui oled rühmas, kuulub iga aken, mille käivitad sel ajal, kui see on aktiivne, rühma. Saad liikuda nende rühmitatud akende vahel klahvidega `Super + Ctrl + Arrow Left/Right` või `Super + Alt + 1/2/3/4`, et minna otse rühmitatud akende juurde järjestuses.

Saad akna rühmitusest välja liigutada klahvidega `Super + Alt + G` või kogu rühma lahti võtta, vajutades uuesti `Super + G`. Lõpuks saad liigutada väljaspool rühma olevaid aknaid sinna sisse klahvidega `Super + Alt + Arrows`.

### Akende väljatõstmine

Saad akna selle tööruumi paigutusest välja tõsta klahvidega `Super + O`. See kinnitab selle ujuva aknana, mis järgneb sulle, ükskõik millisele tööruumile sa lähed. Suurepärane videopleieritele ja muule sarnasele.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-tööruum

On olemas spetsiaalne täissuuruses scratchpad-tööruum, mis katab selle tööruumi, millel sa parajasti oled. Sellel olevale pääsed ligi klahvidega `Super + S` ja paigutad sinna aknaid klahvidega `Super + Alt + S`.

See töötab hästi juhtelementide või terminali jaoks, millega soovid kiiresti suhelda, lahkumata praeguselt tööruumilt.

### Quake'i konsool

Lõpuks on olemas poolkõrgune Quake'i konsool, mis langeb alla üle selle tööruumi, millel sa parajasti oled. Lülita seda klahvidega `Super + Grave` ja paiguta sinna aken klahvidega `Super + Shift + Grave`.

Esimest korda avanedes käivitab see sinu vaikeagendi või palub sul ühe valida, kui sa ei ole veel ühte valinud. Kui konsoolil on üks aken, langeb see alla keskele paigutatud paneelina, selle asemel et ulatuda üle ekraani. Pane sellele teine rakendus ja see läheb tagasi täislaiusesse, nii et neil kahel on ruumi kõrvuti istuda.

Akna liigutamiseks scratchpadilt või konsoolilt ära saada see otse teisele tööruumile millegagi nagu `Super + Shift + 1`.

### Sellega harjumine võtab aega!

Sellisel viisil töölaual navigeerimisega harjumine võtab veidi aega, kuid kui oled sellega harjunud, on raske minna tagasi traditsioonilise hiirega juhitava töölaua kogemuse juurde!
