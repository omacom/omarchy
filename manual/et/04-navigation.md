# Navigeerimine

Kõik Omarchys toimub klaviatuuri kaudu — _KÕIK!_ Kui süsteem esimest korda käivitub, ei saa sa sõna otseses mõttes ainult hiirega mitte midagi teha. Kuid sa saad vajutada `Super + Space`, et kuvada Omarchy menüü, ja siit saad teha peaaegu kõike.

Aga Omarchy menüü ei ole isegi mõeldud olema enamasti peamine viis süsteemi kasutada. Me saame sellest kiiremini! Kõik kõige olulisemad rakendused on seotud otse üksikute kiirklahvidega. Terminali käivitad klahvidega `Super + Return` ja brauseri klahvidega `Super + Shift + Return`. Proovi teha üht teise järel ja näed Hyprlandi plaatijas võlu tegevuses:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Seejärel saad vajutada `Super + J`, et laduda need üksteise peale, mitte kõrvuti:

 ![navigation-stacked](images/navigation-stacked.webp)

Vajuta uuesti `Super + J`, et need oma kõrvuti asenditesse tagasi viia. Seejärel proovi brauseris olles `Super + Shift + Arrow Right`, et aknad omavahel vahetada.

Nüüd proovi `Super + Shift + T`, et käivitada Activity monitor. See ilmub ujuva aknana. Sa saad selle plaadituks muuta klahvidega `Super + T` (ja vajutada seda uuesti, et see taas ujuvaks muuta). Nüüd vajuta `Super + Shift + F`, et avada failihaldur. Sul on kena neljaosaline paigutus:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Aktiivseks soovitud akna juurde navigeerid klahvidega `Super + Arrow`. See vahetab fookust ja liigutab kursori uue rakenduse keskele. Ekraani serval liigub see edasi sellel poolel olevale monitorile.

Kui vajutad `Super + Shift + 2`, liigutad parajasti fookuses oleva rakenduse teisele tööruumile. `Super + Shift + 1` liigutab selle tagasi. (Ja `Super + Shift + Alt + 2` liigutab parajasti fookuses oleva rakenduse teisele tööruumile sinna ümber lülitumata).

Mitme monitori korral on igal monitoril oma tööruumid 1 kuni 10. `Super + 2` viib sind selle monitori teisele tööruumile, millel sa parajasti oled, ja iga monitori ülariba näitab selle enda tööruume ja seda, mida see parajasti kuvab. `Super + Tab` käib läbi selle monitori tööruumid, millel sa oled. `Super + Shift + Ctrl + Arrows` liigutab akna, millel sa oled, selles suunas olevale monitorile, selle kuvatavale tööruumile, ja `Super + Shift + Alt + Arrows` liigutab tööruumi, millel sa oled, selles suunas olevale monitorile, kus see saab sama numbri, kui see on vaba. Monitor säilitab oma tööruumid, kui selle lahti ühendad: need liituvad teise ekraani omadega, nummerdatuna pärast sellel juba olevaid, ja lähevad oma vanade numbrite alla tagasi, kui monitor naaseb.

Kui hoiad `Super` all ja klõpsad hiirega aknal, saad selle asukohta ümber paigutada. Kui hoiad `Super` all ja kasutad hiire paremat nuppu, saad akna suurust vabalt muuta.

Akna suled klahvidega `Super + W` või `Super + Q` (ja kõik aknad klahvidega `Ctrl + Alt + Delete`).

Sa saad minna ka täisekraanile klahvidega `Super + F` või isegi lihtsalt täislaiusesse (ülariba säilitades) klahvidega `Super + Alt + F` või akna sees täisekraanile klahvidega `Super + Ctrl + F` (hea YouTube'i jaoks!).

### Dwindle vs keriv paigutus

Omarchy vaikepaigutust nimetatakse dwindle. See hoiab kõik aknad, mille ühel tööruumil avad, kogu aeg nähtaval, isegi kui peab neid selleks väiksemaks kahandama.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Aga sa saad valida ka tööruumi muutmise kerivaks paigutuseks, kus aknad on rivistatud kõrvuti, väljaspool ekraani nähtavat serva. Ühe tööruumi muudad sellesse paigutusse klahvidega `Super + L`.

`Super + L` uuesti vajutamine muudab tööruumi ujuvaks, kus aknad kattuvad vabalt ja paigutad need ise, ja kolmas vajutus toob selle dwindle'i tagasi. `Super + Alt + L` käib need läbi teistpidi. Aken, mis on niigi ujuv — selline, mille tõstsid välja klahvidega `Super + T`, või rakendus, mis avaneb alati ujuvalt — jääb ujuvaks, kui tööruum läheb plaatijasse tagasi. Ülariba tähistab tööruumi, millel oled, selle paigutusega: ruut dwindle'i, ring keriva ja kolmnurk ujuva puhul. Sellel tähisel klõpsamine vahetab paigutust samuti tsükliliselt.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valik käib tööruumide kaupa ja see jääb püsima. Nii saad hoida tööruumi 1 dwindle'is sirvimiseks ja tööruumi 2 kerivas koodi jaoks ning need tulevad pärast taaskäivitust samamoodi tagasi.

Kui soovid kasutada kerivat paigutust vaikimisi, saad selle seada failis `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Ujuvad tööruumid

Ujuv tööruum töötab nagu traditsiooniline töölaud: aknad kattuvad ning sa liigutad ja muudad nende suurust ise. Iga aken saab sinu teema värvides tiitliriba nuppudega minimeerimiseks, maksimeerimiseks ja sulgemiseks. `Super + M` minimeerib ka fookuses oleva akna. Minimeeritud aken ootab dokis; klõpsa selle rakendust, et see tagasi tuua. Klõpsa akent, et see ette tuua. Muuda selle suurust mis tahes servast või nurgast. Topeltklõpsa tiitliriba, et aken maksimeerida ülariba nähtaval hoides, ja uuesti, et selle vana suurus tagasi saada.

Ujuval tööruumil kuvatakse ka dokk sinu kinnitatud rakendustega, kõigega, mis töötab, ja iga rakenduse ruudustikuga rakenduste nupu taga, mille avavad ka `Super + Alt + Space` ja Omarchy menüüs _Rakendused_. Paremklõpsa ruudustikul rakendust või vajuta `Delete`, et see desinstallida. Klõpsa rakendust, et see avada või selle aken ette tuua; klõpsa uuesti, et selle aknaid tsükliliselt läbi käia. Keskmine klõps avab uue akna. Lohista ikooni mööda dokki, et seda liigutada; töötava rakenduse lohistamine teiste sekka jätab selle sinna. Paremklõpsa, et rakendus dokis hoida, see sealt välja võtta või see lõpetada. Dokk annab täisekraaniaknale teed. Paremklõpsa rakenduste nuppu, et dokk teise serva liigutada või lasta sellel peituda, kuni kursor selle servani jõuab. Asukoht on ka _Välimus > Dokk > Doki asukoht_ all ning `omarchy dock position left` ja `omarchy dock autohide on` seavad mõlemad terminalist. Rakendused, mida dokis hoiad, on tuhmid, kui nad ei tööta.

Uued tööruumid ja kõik, millele sa pole klahvidega `Super + L` oma paigutust andnud, kasutavad vaikepaigutust. Vaikeseade muutmine lähtestab iga akendeta tööruumi sellele, samas kui akendega tööruum säilitab paigutuse, mis sellel on. Dokki minimeeritud aken loeb endiselt aknaks tööruumil, kust see lahkus. Vali see _Välimus > Tööruumi paigutus_ alt: Plaatimine, Kerimine või Ujuv. `omarchy-hyprland-workspace-layout-default scrolling` seab selle terminalist.

### Akende rühmitamine

Aknaid saab rühmitada klahvidega `Super + G`. Kui oled rühmas, kuulub iga aken, mille selle aktiivsuse ajal käivitad, rühma. Nende rühmitatud akende vahel saad liikuda klahvidega `Super + Ctrl + Arrow Left/Right` või `Super + Alt + 1/2/3/4`, et minna otse rühmitatud akende juurde järjekorras.

Sa saad akna rühmitusest välja liigutada klahvidega `Super + Alt + G` või kogu rühma lahti võtta, vajutades uuesti `Super + G`. Lõpuks saad rühmast väljaspool olevaid aknaid sinna sisse liigutada klahvidega `Super + Alt + Arrows`.

### Akende välja tõstmine

Sa saad akna selle tööruumijaotusest välja tõsta klahvidega `Super + O`. See kinnitab selle ujuva aknana, mis järgneb sulle, ükskõik millisele tööruumile sa lähed. Suurepärane videopleierite ja muu sarnase jaoks.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-tööruum

On olemas spetsiaalne täissuuruses Scratchpad-tööruum, mis kattub mis tahes tööruumiga, millel parajasti oled. Sellel olevale pääsed ligi klahvidega `Super + S` ja aknad paigutad sinna klahvidega `Super + Alt + S`.

See sobib hästi juhtelementide või terminali jaoks, millega soovid kiiresti suhelda praeguselt tööruumilt lahkumata.

### Quake-konsool

Lõpuks on olemas poolkõrgune Quake-konsool, mis langeb alla üle mis tahes tööruumi, millel parajasti oled. Lülita see klahvidega `Super + Grave` ja paiguta aken sinna klahvidega `Super + Shift + Grave`.

See avaneb sinu vaikeagendiga, mis on kasutusvalmis. Kui konsoolil on üks aken, langeb see alla keskele paigutatud paneelina, mitte ei ulatu üle ekraani. Pane sinna teine rakendus ja see läheb täislaiusesse tagasi, nii et neil kahel on ruumi kõrvuti istuda.

Akna kas Scratchpadilt või konsoolilt ära liigutamiseks saada see otse teisele tööruumile näiteks klahvidega `Super + Shift + 1`.

### Sellega tuleb harjuda!

Sellise töölaua navigeerimisega harjumine võtab natuke aega, kuid kui oled harjunud, on raske traditsioonilise hiirega juhitava töölauakogemuse juurde tagasi minna!
