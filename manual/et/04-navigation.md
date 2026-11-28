# Navigeerimine

Kõik Omarchys toimub klaviatuuri kaudu — _KÕIK!_ Kui süsteem esimest korda käivitub, ei saa sa hiirega üksi sõna otseses mõttes midagi teha. Aga sa võid vajutada `Super + Space`, et Omarchy Menu esile tuua, ja sealt saad teha peaaegu kõike.

Aga Omarchy menüü ei ole isegi mõeldud olema peamine viis, kuidas süsteemi enamasti kasutada. Saame sellest veel kiiremaks! Kõik kõige olulisemad rakendused on seotud otse üksikute kiirklahvidega. Terminali käivitad klahvidega `Super + Return` ja brauseri klahvidega `Super + Shift + Return`. Proovi üht teise järel teha ja näed Hyprlandi paigutuse võlu tegutsemas:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Seejärel võid vajutada `Super + J`, et laduda need üksteise peale, mitte kõrvuti:

 ![navigation-stacked](images/navigation-stacked.webp)

Vajuta uuesti `Super + J`, et viia need tagasi kõrvuti asenditesse. Seejärel proovi brauseris olles klahve `Super + Shift + Arrow Right`, et aknad omavahel vahetada.

Nüüd proovi klahve `Super + Shift + T`, et käivitada Activity monitor. See ilmub hõljuva aknana, millel on pealkirjariba, millest seda lohistada, ning nupud minimeerimiseks, maksimeerimiseks ja sulgemiseks. Iga hõljuv aken saab sellise, kus iganes see ka ei asuks. Saad selle paigutada klahvidega `Super + T` (ja vajutada sama uuesti, et muuta see uuesti hõljuvaks). Nüüd vajuta `Super + Shift + F`, et avada failihaldur. Sul on korralik neljaosaline paigutus:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Akende vahel, mille soovid aktiivseks teha, liigud klahvidega `Super + Arrow`. See vahetab fookust ja liigutab kursori uue rakenduse keskele. Ekraani serval liigub see edasi sellel poolel olevale monitorile.

Kui vajutad `Super + Shift + 2`, liigutad parajasti fookuses oleva rakenduse teisele tööruumile. `Super + Shift + 1` liigutab selle tagasi. (Ja `Super + Shift + Alt + 2` liigutab parajasti fookuses oleva rakenduse teisele tööruumile sinna vahetamata).

Rohkem kui ühe monitori korral on igal monitoril oma tööruumid 1 kuni 10. `Super + 2` viib sind selle monitori teisele tööruumile, millel parajasti oled, ja iga monitori ülemine riba näitab selle enda tööruume ja seda, mida ta parajasti kuvab. `Super + Tab` liigub läbi selle monitori tööruumide, millel parajasti oled. `Super + Shift + Ctrl + Arrows` liigutab akna, millel oled, selles suunas olevale monitorile, selle kuvatavale tööruumile, ja `Super + Shift + Alt + Arrows` liigutab tööruumi, millel oled, selles suunas olevale monitorile, kus see võtab sama numbri, kui see on vaba. Monitor säilitab oma tööruumid, kui selle lahti ühendad: need liituvad teise ekraani omadega, nummerdatuna pärast neid, mis sellel juba on, ja lähevad monitori naastes tagasi oma vanade numbrite alla.

Kui hoiad `Super` all ja kasutad hiirt aknale klõpsamiseks, saad selle asukohta ümber paigutada. Kui hoiad `Super` all ja kasutad hiire paremat nuppu, saad akna suurust vabalt muuta.

Akna sulged klahvidega `Super + W` või `Super + Q` (ja kõik aknad sulged klahvidega `Ctrl + Alt + Delete`).

Saad minna ka täisekraanile klahvidega `Super + F` või isegi ainult täislaiusesse (ülemist riba säilitades) klahvidega `Super + Alt + F` või akna sees täisekraanile klahvidega `Super + Ctrl + F` (hea YouTube'i jaoks!).

### Dwindle vs keriv paigutus

Omarchy vaikepaigutust nimetatakse dwindle. See hoiab kõiki aknaid, mille ühel tööruumil avad, kogu aeg nähtaval, isegi kui peab neid selleks väiksemaks kahandama.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Aga sa võid valida ka tööruumi muutmise kerivaks paigutuseks, kus aknad on reastatud kõrvuti, väljaspool ekraani nähtavat serva. Ühe tööruumi muudad selliseks paigutuseks klahvidega `Super + L`.

Uuesti `Super + L` vajutamine muudab tööruumi hõljuvaks, kus aknad kattuvad vabalt ja sa paigutad need ise, ja kolmas vajutus viib selle tagasi dwindle juurde. `Super + Alt + L` liigub neist läbi teistpidi. Aken, mis hõljub niikuinii — selline, mille hüppasid välja klahvidega `Super + T`, või rakendus, mis avaneb alati hõljuvana — jääb hõljuma, kui tööruum läheb tagasi paigutuse juurde. Ülemine riba tähistab tööruumi, millel oled, selle paigutusega: ruut dwindle jaoks, ring keriva jaoks ja kolmnurk hõljuva jaoks. Selle märgi klõpsamine vahetab samuti paigutust, ja sama teeb ka ekraaniklahv sülearvutitel, millel selline on.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valik on tööruumi kaupa ja see jääb püsima. Nii saad hoida tööruumi 1 dwindle peal lehitsemiseks ja tööruumi 2 kerival paigutusel koodi jaoks ning need tulevad pärast taaskäivitust samamoodi tagasi.

Kui soovid kasutada kerivat paigutust vaikepaigutusena, saad selle seada failis `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Hõljuvad tööruumid

Hõljuv tööruum töötab nagu tavapärane töölaud: aknad kattuvad ning sa liigutad ja muudad nende suurust ise. Iga aken saab pealkirjariba sinu teema värvides, nuppudega minimeerimiseks, maksimeerimiseks ja sulgemiseks. `Super + M` minimeerib ka fookuses oleva akna. Minimeeritud aken ootab dokis; klõpsa selle rakendusel, et see tagasi tuua. Klõpsa aknal, et see ette tuua. Muuda selle suurust igast servast või nurgast. Tee pealkirjaribal topeltklõps, et aken maksimeerida, säilitades samal ajal ülemise riba nähtaval, ja uuesti, et selle vana suurus tagasi saada. Chrome ja teised Chromiumil põhinevad brauserid, Disks ja Document Viewer jätavad pealkirjariba vahele ja kasutavad selle asemel oma päist; `Super + Alt + F` maksimeerib need ja `Super + M` minimeerib need.

Igal tööruumil on dokk, sinu kinnitatud rakendustega, kõigega, mis parajasti töötab, ja iga rakenduse ruudustikuga rakenduste nupu taga, mille avavad ka `Super + Alt + Space` ja Omarchy menüü _Apps_. Rakenduse desinstallimiseks tee ruudustikul rakendusel paremklõps või vajuta `Delete`. Klõpsa rakendusel selle avamiseks või selle akna ette toomiseks; klõpsa uuesti, et liikuda läbi selle akende. Files toob tagasi ainult akna tööruumilt, millel parajasti oled, ja avab muidu uue, ning Terminal ja Agent käivitavad alati uue, kuigi minimeeritud aken tuleb enne tagasi. Keskmine klõps avab uue akna. Lohista ikooni mööda dokki selle liigutamiseks; töötava rakenduse teiste sekka lohistamine jätab selle sinna. Tee paremklõps, et rakendust dokis hoida, see sealt välja võtta või see lõpetada. Dukk jääb välja, kuni tööruum on tühi, ja kui tööruumil on aken, peidab see end, kuni kursor jõuab selle servani. Täisekraanaken peidab selle täielikult. Lohista rakenduste nuppu ekraani teise serva poole, et dokk sinna liigutada. Tee sellel paremklõps _Position_ jaoks, et serv valida, ja _Layout_ jaoks, et seada vaikepaigutus, nagu teeb _Appearance > Workspace Layout_. Asukoht on ka _Appearance > Dock > Dock Position_ all ja `omarchy dock position left` seab selle terminalist. Rakendused, mida dokis hoiad, on tuhmid, kui nad ei tööta. Doki ainult hõljuvatele tööruumidele jätmiseks kasuta _Appearance > Dock > Dock Only on Floating_ või `omarchy dock tiling off`.

Uued tööruumid ja kõik, millele sa ei ole klahvidega `Super + L` oma paigutust andnud, kasutavad vaikepaigutust. Vaikepaigutuse muutmine lähtestab sellele iga akendeta tööruumi, samas kui akendega tööruum säilitab paigutuse, mis sellel on. Doki minimeeritud aken loeb endiselt aknaks tööruumil, millelt see lahkus. Vali see _Appearance > Workspace Layout_ alt: Tiling, Scrolling või Floating. `omarchy hyprland workspace layout default scrolling` seab selle terminalist.

### Akende rühmitamine

Aknaid saab rühmitada klahvidega `Super + G`. Kui oled rühmas, kuulub iga aken, mille selle aktiivsena käivitad, rühma. Nende rühmitatud akende vahel saad liikuda klahvidega `Super + Ctrl + Arrow Left/Right` või `Super + Alt + 1/2/3/4`, et minna otse rühmitatud akende juurde järjekorras.

Akna saad rühmitamisest välja liigutada klahvidega `Super + Alt + G` või kogu rühma lahti võtta, vajutades uuesti `Super + G`. Lõpuks saad aknaid väljastpoolt rühma sinna sisse liigutada klahvidega `Super + Alt + Arrows`.

### Akende väljahüpitamine

Akna saad selle tööruumi jaotusest välja hüpitada klahvidega `Super + O`. See kinnitab selle hõljuva aknana, mis järgneb sulle, ükskõik millisele tööruumile lähed. Suurepärane videopleierite ja muu sarnase jaoks.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-tööruum

On olemas spetsiaalne täissuuruses scratchpad-tööruum, mis katab tööruumi, millel parajasti oled. Sellel olevale pääsed ligi klahvidega `Super + S` ja aknaid paigutad sinna klahvidega `Super + Alt + S`.

See töötab hästi juhtelementide või terminali jaoks, millega soovid kiiresti suhelda praeguselt tööruumilt lahkumata.

### Quake-konsool

Lõpuks on olemas poole kõrgusega Quake-konsool, mis langeb alla üle tööruumi, millel parajasti oled. Lülita see klahvidega `Super + the key above Tab` (USA paigutustel grave-klahv) ja paiguta aken sinna klahvidega `Super + Shift + the key above Tab`.

Esimesel avamisel käivitab see sinu vaikeagendi või palub sul ühe valida, kui sa ei ole veel ühte valinud. Kui konsool hoiab ühte akent, langeb see alla tsentreeritud paneelina, mitte ei ulatu üle ekraani. Pane sinna teine rakendus ja see läheb tagasi täislaiusesse, nii et neil kahel on ruumi kõrvuti istuda.

Akna liigutamiseks scratchpadilt või konsoolilt ära saada see otse teisele tööruumile millegagi nagu `Super + Shift + 1`.

### Sellega tuleb harjuda!

Sellisel viisil töölaual navigeerimisega harjumine võtab veidi aega, aga kui oled harjunud, on raske minna tagasi tavapärase hiirega juhitava töölauakogemuse juurde!
