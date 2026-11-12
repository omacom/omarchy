# Navigeerimine

Kõik Omarchys toimub klaviatuuri kaudu — _KÕIK!_ Kui süsteem esimest korda käivitub, ei saa sa hiirega üksi sõna otseses mõttes mitte midagi teha. Aga sa võid vajutada `Super + Space`, et paljastada Omarchy Menu, ja siit saad teha peaaegu kõike.

Omarchy menüü ei ole aga isegi mõeldud olema peamine viis süsteemi enamasti kasutada. Me saame sellest kiiremaks minna! Kõik kõige tähtsamad rakendused on seotud otse üksikute kiirklahvidega. Terminali käivitad klahvikombinatsiooniga `Super + Return` ja brauseri klahvikombinatsiooniga `Super + Shift + Return`. Proovi teha üht teisele järgi ja näed Hyprlandi paanimise võlu tegevuses:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Seejärel võid vajutada `Super + J`, et laduda need üksteise peale, mitte kõrvuti:

 ![navigation-stacked](images/navigation-stacked.webp)

Vajuta uuesti `Super + J`, et viia need tagasi kõrvuti asenditesse. Seejärel proovi brauseris olles `Super + Shift + Arrow Right`, et aknad omavahel vahetada.

Nüüd proovi `Super + Shift + T`, et käivitada Tegevusmonitor. See ilmub ujuva aknana. Saad selle paanida klahvikombinatsiooniga `Super + T` (ja vajutada sama uuesti, et muuta see jälle ujuvaks). Nüüd vajuta `Super + Shift + F`, et avada failihaldur. Sul on korralik neljaosaline seadistus:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Sa liigud akende vahel, mille soovid aktiivseks muuta, klahvikombinatsiooniga `Super + Arrow`. See vahetab fookust ja liigutab kursori uue rakenduse keskele. Ekraani serval liigub see edasi sellel küljel olevale monitorile.

Kui vajutad `Super + Shift + 2`, liigutad parajasti fookuses oleva rakenduse teisele tööalale. `Super + Shift + 1` liigutab selle tagasi. (Ja `Super + Shift + Alt + 2` liigutab parajasti fookuses oleva rakenduse teisele tööalale ilma sellele lülitumata).

Mitme monitori korral on igal monitoril oma tööalad 1 kuni 10. `Super + 2` läheb selle monitori teisele tööalale, millel sa oled, ja iga monitori ülemine riba näitab selle oma tööalasid ja seda, mida see parajasti näitab. `Super + Tab` liigub tsükliliselt selle monitori tööalade vahel, millel sa oled. `Super + Shift + Ctrl + Arrows` liigutab akna, millel sa oled, selles suunas olevale monitorile, selle tööalale, mida see näitab, ja `Super + Shift + Alt + Arrows` liigutab tööala, millel sa oled, selles suunas olevale monitorile, kus see võtab sama numbri, kui see on vaba. Monitor säilitab oma tööalad, kui selle lahti ühendad: need liituvad teise ekraani omadega, nummerdatuna pärast neid, mis sellel juba on, ja lähevad tagasi oma vanade numbrite alla, kui monitor naaseb.

Kui hoiad `Super` all ja kasutad hiirt aknale klõpsamiseks, saad muuta, kus see asub. Kui hoiad `Super` all ja kasutad hiire paremat nuppu, saad akna suurust vabalt muuta.

Akna sulged klahvikombinatsiooniga `Super + W` või `Super + Q` (ja kõik aknad sulged klahvikombinatsiooniga `Ctrl + Alt + Delete`).

Saad minna ka täisekraanile klahvikombinatsiooniga `Super + F` või isegi ainult täislaiusesse (ülemist riba säilitades) klahvikombinatsiooniga `Super + Alt + F` või täisekraanile akna sees klahvikombinatsiooniga `Super + Ctrl + F` (hea YouTube'i jaoks!).

### Dwindle vs keriv paigutus

Omarchy vaikepaigutust nimetatakse dwindle'iks. See hoiab kõiki aknaid, mille ühel tööalal avad, kogu aeg nähtaval, isegi kui see peab neid selleks väiksemaks kahandama.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Aga saad valida ka tööala muutmise kerivaks paigutuseks, kus aknad on reastatud kõrvuti, väljaspool ekraani nähtavat serva. Ühe tööala muudad selliseks paigutuseks klahvikombinatsiooniga `Super + L`.

Klahvikombinatsiooni `Super + L` uuesti vajutamine muudab tööala ujuvaks, kus aknad kattuvad vabalt ja sa paigutad need ise, ning kolmas vajutus viib selle tagasi dwindle'isse. `Super + Alt + L` läbib need teises suunas. Aken, mis ujub nagunii — selline, mille tõstsid välja klahvikombinatsiooniga `Super + T`, või rakendus, mis avaneb alati ujuvana — jääb ujuvaks, kui tööala läheb tagasi paanimisele. Ülemine riba tähistab tööala, millel sa oled, selle paigutusega: dwindle'i jaoks ruut, keriva jaoks ring ja ujuva jaoks kolmnurk. Sellel märgil klõpsamine liigub paigutuste vahel tsükliliselt samuti.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valik on tööala kaupa ja see püsib. Nii saad hoida tööala 1 dwindle'il sirvimiseks ja tööala 2 kerival koodi jaoks ning need tulevad pärast taaskäivitust samamoodi tagasi.

Kui soovid kasutada kerivat paigutust vaikepaigutusena, saad selle määrata failis `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Ujuvad tööalad

Ujuv tööala töötab nagu traditsiooniline töölaud: aknad kattuvad ja sa liigutad ning muudad nende suurust ise. Iga aken saab sinu teema värvides tiitliriba koos nuppudega minimeerimiseks, maksimeerimiseks ja sulgemiseks. `Super + M` minimeerib ka fookuses oleva akna. Minimeeritud aken ootab dokis; klõpsa selle rakendust, et see tagasi tuua. Klõpsa akent, et see ette tuua. Muuda selle suurust mis tahes servast või nurgast. Topeltklõpsa tiitliribal, et aken maksimeerida, säilitades samal ajal ülemise riba nähtaval, ja uuesti, et selle vana suurus tagasi saada. Chrome ja teised Chromiumil põhinevad brauserid, Disks ja Document Viewer jätavad tiitliriba vahele ja kasutavad selle asemel oma päist; `Super + Alt + F` maksimeerib need ja `Super + M` minimeerib need.

Ujuv tööala näitab ka dokki koos sinu kinnitatud rakendustega, kõigega, mis töötab, ja iga rakenduse ruudustikuga rakenduste nupu taga, mille avavad ka `Super + Alt + Space` ja _Rakendused_ Omarchy menüüs. Rakenduse desinstallimiseks tee ruudustikul rakendusel paremklõps või vajuta `Delete`. Klõpsa rakendust, et see avada või selle aken ette tuua; klõpsa uuesti, et selle akende vahel tsükliliselt liikuda. Keskmise nupuga klõpsamine avab uue akna. Lohista ikooni mööda dokki, et seda liigutada; töötava rakenduse lohistamine teiste sekka hoiab selle seal. Tee paremklõps, et rakendus dokis hoida, see sealt välja võtta või see sulgeda. Dokk annab täisekraanil akna eest teed. Tee rakenduste nupul paremklõps, et dokk teisele servale liigutada või lasta sellel peituda, kuni kursor jõuab selle servani. Asukoht on ka jaotise _Välimus > Dock > Doki asukoht_ all ning `omarchy dock position left` ja `omarchy dock autohide on` määravad mõlemad terminalist. Rakendused, mida dokis hoiad, on tuhmid, kui need ei tööta.

Uued tööalad ja kõik, millele sa ei ole klahvikombinatsiooniga `Super + L` oma paigutust andnud, kasutavad vaikepaigutust. Vaikepaigutuse muutmine lähtestab sellele iga akendeta tööala, samas kui akendega tööala säilitab paigutuse, mis sellel on. Dokki minimeeritud aken loeb endiselt aknana tööalal, millelt see lahkus. Vali see jaotise _Välimus > Tööala paigutus_ alt: Paanimine, Kerimine või Ujuv. `omarchy-hyprland-workspace-layout-default scrolling` määrab selle terminalist.

### Akende rühmitamine

Aknaid saab rühmitada klahvikombinatsiooniga `Super + G`. Kui oled rühmas, kuulub iga aken, mille käivitad ajal, mil see on aktiivne, rühma. Nende rühmitatud akende vahel saad liikuda klahvikombinatsiooniga `Super + Ctrl + Arrow Left/Right` või klahvikombinatsiooniga `Super + Alt + 1/2/3/4`, et minna otse rühmitatud akende juurde järjestuses.

Akna saad rühmitamisest välja liigutada klahvikombinatsiooniga `Super + Alt + G` või kogu rühma lahti võtta, vajutades uuesti `Super + G`. Lõpuks saad rühmast väljaspool olevaid aknaid sinna sisse liigutada klahvikombinatsiooniga `Super + Alt + Arrows`.

### Akende välja tõstmine

Akna saad selle tööala jaotusest välja tõsta klahvikombinatsiooniga `Super + O`. See kinnitab selle ujuva aknana, mis järgneb sulle, mis tahes tööalale sa ka ei läheks. Suurepärane videopleierite ja muu sarnase jaoks.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-tööala

On olemas eriline täissuuruses scratchpad-tööala, mis katab üle selle tööala, millel sa parajasti oled. Sellel olevale pääsed ligi klahvikombinatsiooniga `Super + S` ja aknaid paigutad sinna klahvikombinatsiooniga `Super + Alt + S`.

See töötab hästi juhtnuppude või terminali jaoks, millega soovid kiiresti suhelda ilma praeguselt tööalalt lahkumata.

### Quake konsool

Lõpuks on olemas poole kõrgusega Quake konsool, mis langeb alla üle selle tööala, millel sa parajasti oled. Lülita seda klahvikombinatsiooniga `Super + Grave` ja paiguta sinna aken klahvikombinatsiooniga `Super + Shift + Grave`.

See avaneb nii, et sinu vaikeagent on valmis tegutsema. Kui konsool hoiab üht akent, langeb see alla tsentreeritud paneelina, mitte ei ulatu üle ekraani. Pane sinna teine rakendus ja see läheb tagasi täislaiusesse, nii et neil kahel on ruumi kõrvuti istuda.

Akna liigutamiseks kas scratchpadilt või konsoolilt ära saada see otse teisele tööalale millegagi nagu `Super + Shift + 1`.

### Sellega tuleb harjuda!

Oma töölaua niimoodi navigeerimisega harjumine võtab natuke aega, aga kui oled harjunud, on raske minna tagasi traditsioonilise hiirega juhitava töölauakogemuse juurde!
