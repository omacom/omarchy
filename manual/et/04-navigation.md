# Navigeerimine

Kõik Omarchys toimub klaviatuuri kaudu — _KÕIK!_ Kui süsteem esimest korda käivitub, ei saa sa hiirega üksi sõna otseses mõttes midagi teha. Kuid võid vajutada `Super + Space`, et avada Omarchy menüü, ja siit saad teha peaaegu kõike.

Kuid Omarchy menüü ei ole isegi mõeldud olema enamasti peamine viis süsteemi kasutada. Saame sellest kiiremaks! Kõik kõige olulisemad rakendused on seotud otse üksikute kiirklahvidega. Terminali käivitad klahvidega `Super + Return` ja brauseri klahvidega `Super + Shift + Return`. Proovi teha üks pärast teist ja näed tegevuses Hyprlandi paigutuse võlu:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Seejärel võid vajutada `Super + J`, et laduda need üksteise peale, mitte kõrvuti:

 ![navigation-stacked](images/navigation-stacked.webp)

Vajuta uuesti `Super + J`, et viia need tagasi kõrvuti asendisse. Seejärel proovi brauseris olles `Super + Shift + Arrow Right`, et aknad omavahel vahetada.

Nüüd proovi `Super + Shift + T`, et käivitada Activity monitor. See ilmub ujuva aknana. Saad selle paigutada klahvidega `Super + T` (ja vajutada seda uuesti, et muuta see jälle ujuvaks). Nüüd vajuta failihalduri avamiseks `Super + Shift + F`. Sul on korralik neljaosaline paigutus:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Navigeerid akna vahel, mille soovid aktiivseks muuta, klahvidega `Super + Arrow`. See vahetab fookust ja liigutab kursori uue rakenduse keskele. Ekraani serval liigub see edasi sellel küljel olevale monitorile.

Kui vajutad `Super + Shift + 2`, liigutad praegu fookuses oleva rakenduse teisele tööalale. `Super + Shift + 1` liigutab selle tagasi. (Ja `Super + Shift + Alt + 2` liigutab praegu fookuses oleva rakenduse teisele tööalale sinna ümber lülitumata).

Rohkem kui ühe monitori korral on igal monitoril oma tööalad 1 kuni 10. `Super + 2` läheb monitori, millel oled, teisele tööalale, ja iga monitori ülemine riba näitab selle oma tööalasid ja seda, mida see parajasti näitab. `Super + Tab` käib tsükliliselt läbi monitori, millel oled, tööalad. `Super + Shift + Ctrl + Arrows` liigutab akna, millel oled, selles suunas olevale monitorile, tööalale, mida see näitab, ja `Super + Shift + Alt + Arrows` liigutab tööala, millel oled, selles suunas olevale monitorile, kus see võtab sama numbri, kui see on vaba. Monitor säilitab oma tööalad, kui selle lahti ühendad: need liituvad teise ekraani omadega, nummerdatuna pärast neid, mis sellel juba on, ja lähevad monitori naastes tagasi oma vanade numbrite alla.

Kui hoiad all `Super` ja kasutad hiirt aknale klõpsamiseks, saad selle asukohta ümber paigutada. Kui hoiad all `Super` ja kasutad hiire paremat nuppu, saad akna suurust vabalt muuta.

Akna sulged klahvidega `Super + W` või `Super + Q` (ja kõik aknad sulged klahvidega `Ctrl + Alt + Delete`).

Saad ka minna täisekraanile klahvidega `Super + F` või isegi lihtsalt täislaiusesse (ülemise riba säilitades) klahvidega `Super + Alt + F` või täisekraanile akna sees klahvidega `Super + Ctrl + F` (hea YouTube'i jaoks!).

### Dwindle vs. keriv paigutus

Omarchy vaikepaigutust nimetatakse dwindle'iks. See hoiab kõiki ühel tööalal avatud aknaid kogu aeg nähtaval, isegi kui peab neid selleks väiksemaks kahandama.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Kuid võid valida ka tööala muutmise kerivaks paigutuseks, kus aknad on reastatud kõrvuti, väljaspool ekraani nähtavat serva. Ühe tööala muudad selleks paigutuseks klahvidega `Super + L`.

`Super + L` uuesti vajutamine muudab tööala ujuvaks, kus aknad kattuvad vabalt ja paigutad need ise, ning kolmas vajutus viib selle tagasi dwindle'isse. `Super + Alt + L` käib need läbi teises suunas. Aken, mis on niigi ujuv — selline, mille tõstsid välja klahvidega `Super + T`, või rakendus, mis avaneb alati ujuvana — jääb ujuvaks, kui tööala läheb tagasi paigutamisele. Ülemine riba tähistab tööala, millel oled, selle paigutusega: dwindle puhul ruut, keriva puhul ring ja ujuva puhul kolmnurk. Selle märgi klõpsamine vahetab samuti paigutust tsükliliselt.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valik kehtib tööala kaupa ja see püsib. Nii saad hoida tööala 1 veebilehitsemiseks dwindle peal ja tööala 2 koodi jaoks kerival paigutusel ning need tulevad pärast taaskäivitust samamoodi tagasi.

Kui soovid kasutada kerivat paigutust vaikeväärtusena, saad selle määrata failis `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Ujuvad tööalad

Ujuv tööala töötab nagu traditsiooniline töölaud: aknad kattuvad ning liigutad ja muudad nende suurust ise. Iga aken saab sinu teema värvides tiitliriba nuppudega minimeerimiseks, maksimeerimiseks ja sulgemiseks. `Super + M` minimeerib ka fookuses oleva akna. Minimeeritud aken ootab dokis; klõpsa selle rakendust, et see tagasi tuua. Klõpsa akent, et tuua see ettepoole. Muuda selle suurust mis tahes servast või nurgast. Topeltklõpsa tiitliriba, et aken maksimeerida, säilitades samal ajal ülemise riba nähtavana, ja uuesti, et saada selle vana suurus tagasi. Chrome ja teised Chromiumil põhinevad brauserid, Disks ja Document Viewer jätavad tiitliriba vahele ja kasutavad selle asemel oma päist; `Super + Alt + F` maksimeerib need ja `Super + M` minimeerib need.

Ujuv tööala näitab ka dokki sinu kinnitatud rakendustega, kõigega, mis töötab, ja iga rakenduse ruudustikuga rakenduste nupu taga, mille avavad ka `Super + Alt + Space` ja _Apps_ Omarchy menüüs. Rakenduse desinstallimiseks tee ruudustikul rakendusel paremklõps või vajuta `Delete`. Klõpsa rakendust, et see avada või tuua selle aken ettepoole; klõpsa uuesti, et selle aknaid tsükliliselt läbi käia. Files toob tagasi ainult akna tööalalt, millel oled, ja avab muidu uue, ning Terminal ja Agent käivitavad alati uue, kuigi minimeeritud aken tuleb kõigepealt tagasi. Keskmine klõps avab uue akna. Lohista ikooni piki dokki, et seda liigutada; töötava rakenduse lohistamine teiste sekka jätab selle sinna. Tee paremklõps, et rakendus dokis hoida, see sealt välja võtta või see sulgeda. Dokk annab teed täisekraani aknale. Tee rakenduste nupul paremklõps, et liigutada dokk teise serva või panna see peituma, kuni kursor jõuab selle servani. Asukoht on ka valiku _Appearance > Dock > Dock Position_ all ning `omarchy dock position left` ja `omarchy dock autohide on` määravad mõlemad terminalist. Rakendused, mida dokis hoiad, on tuhmid, kui nad ei tööta.

Uued tööalad ja kõik, millele sa ei ole klahvidega `Super + L` oma paigutust andnud, kasutavad vaikepaigutust. Vaikeväärtuse muutmine lähtestab sellele iga akendeta tööala, samas kui akendega tööala säilitab paigutuse, mis sellel on. Dokki minimeeritud aken loeb endiselt aknaks tööalal, kust see lahkus. Vali see valiku _Appearance > Workspace Layout_ alt: Tiling, Scrolling või Floating. `omarchy-hyprland-workspace-layout-default scrolling` määrab selle terminalist.

### Akende rühmitamine

Aknaid saab rühmitada klahvidega `Super + G`. Kui oled rühmas, kuulub iga aken, mille käivitad selle aktiivse oleku ajal, rühma. Nende rühmitatud akende vahel saad liikuda klahvidega `Super + Ctrl + Arrow Left/Right` või `Super + Alt + 1/2/3/4`, et minna otse rühmitatud akende juurde järjestuses.

Akna saad rühmast välja liigutada klahvidega `Super + Alt + G` või kogu rühma lahti võtta, vajutades uuesti `Super + G`. Lõpuks saad aknaid väljastpoolt rühma sinna sisse liigutada klahvidega `Super + Alt + Arrows`.

### Akende väljatõstmine

Saad akna selle tööala jaotusest välja tõsta klahvidega `Super + O`. See kinnitab selle ujuva aknana, mis järgneb sulle, ükskõik millisele tööalale sa lähed. Suurepärane videopleierite ja muu sarnase jaoks.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-tööala

On olemas spetsiaalne täissuuruses scratchpad-tööala, mis katab ükskõik millise tööala, millel praegu oled. Sellel olevale pääsed ligi klahvidega `Super + S` ja aknaid paigutad sinna klahvidega `Super + Alt + S`.

See töötab hästi juhtnuppude või terminali jaoks, millega soovid kiiresti suhelda praeguselt tööalalt lahkumata.

### Quake'i konsool

Lõpuks on olemas poole kõrgusega Quake'i konsool, mis langeb alla üle ükskõik millise tööala, millel praegu oled. Lülita seda klahvidega `Super + Grave` ja paiguta aken sinna klahvidega `Super + Shift + Grave`.

See avaneb nii, et sinu vaikeagent on kasutusvalmis. Kui konsool hoiab ühte akent, langeb see alla keskele paigutatud paneelina, mitte ei ulatu üle ekraani. Pane sinna teine rakendus ja see läheb tagasi täislaiusesse, nii et neil kahel on ruumi kõrvuti istuda.

Akna liigutamiseks kas scratchpadilt või konsoolilt ära saada see otse teisele tööalale millegagi nagu `Super + Shift + 1`.

### Sellega harjumine võtab aega!

Sellisel viisil oma töölaual navigeerimisega harjumine võtab veidi aega, kuid kui oled sellega harjunud, on raske minna tagasi traditsioonilise hiirega juhitava töölauakogemuse juurde!
