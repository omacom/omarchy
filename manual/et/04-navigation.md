# Navigeerimine

Kõik Omarchys toimub klaviatuuri kaudu — _KÕIK!_ Kui süsteem esimest korda käivitub, ei saa sa sõna otseses mõttes pelgalt hiirega mitte midagi teha. Kuid võid vajutada `Super + Space`, et Omarchy menüü esile tuua, ja siit saad teha peaaegu kõike.

Kuid Omarchy menüü ei ole isegi mõeldud olema enamasti peamine viis süsteemi kasutada. Me saame sellest kiiremini! Kõik kõige olulisemad rakendused on seotud otse üksikute kiirklahvidega. Terminali käivitad klahvikombinatsiooniga `Super + Return` ja brauseri klahvikombinatsiooniga `Super + Shift + Return`. Proovi teha üht teise järel ja näed Hyprlandi plaatimise võlu tegevuses:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Seejärel võid vajutada `Super + J`, et need üksteise peale kuhjata, selle asemel et nad oleksid kõrvuti:

 ![navigation-stacked](images/navigation-stacked.webp)

Vajuta uuesti `Super + J`, et need kõrvuti asenditesse tagasi viia. Seejärel proovi brauseris olles klahvikombinatsiooni `Super + Shift + Arrow Right`, et aknad omavahel vahetada.

Nüüd proovi klahvikombinatsiooni `Super + Shift + T`, et käivitada tegevusmonitor. See ilmub ujuva aknana, millel on tiitliriba, millest seda lohistada, ning nupud selle minimeerimiseks, maksimeerimiseks ja sulgemiseks. Iga ujuv aken saab ühe, kus iganes see asub. Saad selle plaadituks muuta klahvikombinatsiooniga `Super + T` (ja vajutada seda uuesti, et see taas ujuvaks muuta). Nüüd vajuta `Super + Shift + F`, et failihaldur avada. Sul on korralik neljaosaline paigutus:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Akende vahel, mida soovid aktiivseks muuta, navigeerid klahvikombinatsiooniga `Super + Arrow`. See vahetab fookust ja viib kursori uue rakenduse keskele. Ekraani serval liigub see edasi sellel poolel olevale monitorile.

Kui vajutad `Super + Shift + 2`, viid parajasti fookuses oleva rakenduse teisele tööruumile. `Super + Shift + 1` viib selle tagasi. (Ja `Super + Shift + Alt + 2` viib parajasti fookuses oleva rakenduse teisele tööruumile ilma sellele lülitumata).

Rohkem kui ühe monitori korral on igal monitoril omad tööruumid 1 kuni 10. `Super + 2` läheb selle monitori teisele tööruumile, millel parajasti oled, ja iga monitori ülariba näitab selle oma tööruume ja seda, mida see parajasti näitab. `Super + Tab` käib läbi selle monitori tööruumid, millel parajasti oled. `Super + Shift + Ctrl + Arrows` viib akna, millel oled, selles suunas olevale monitorile, selle näidatavale tööruumile, ja `Super + Shift + Alt + Arrows` viib tööruuma, millel oled, selles suunas olevale monitorile, kus see võtab sama numbri, kui see on vaba. Monitor säilitab oma tööruumid, kui selle lahti ühendad: need ühinevad teise ekraani omadega, nummerdatuna pärast neid, mis sellel juba on, ja lähevad oma vanade numbrite alla tagasi, kui monitor naaseb.

Kui hoiad `Super` all ja kasutad hiirt aknas klõpsamiseks, saad selle asukohta ümber korraldada. Kui hoiad `Super` all ja kasutad hiire paremat nuppu, saad akna suurust vabalt muuta.

Akna sulged klahvikombinatsiooniga `Super + W` või `Super + Q` (ja kõik aknad sulged klahvikombinatsiooniga `Ctrl + Alt + Delete`).

Saad minna ka täisekraanile klahvikombinatsiooniga `Super + F` või isegi lihtsalt täislaiusesse (ülariba säilitades) klahvikombinatsiooniga `Super + Alt + F` või akna sees täisekraanile klahvikombinatsiooniga `Super + Ctrl + F` (hea YouTube'i jaoks!).

### Dwindle vs keriv paigutus

Omarchy vaikepaigutust nimetatakse dwindle'iks. See hoiab kõik aknad, mille ühel tööruumal avad, kogu aeg nähtaval, isegi kui see peab neid selleks väiksemaks kahandama.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Kuid võid valida ka tööruuma muutmise kerivaks paigutuseks, kus aknad on kõrvuti reastatud, kuva nähtavast servast kaugemale. Ühe tööruuma muudad sellesse paigutusse klahvikombinatsiooniga `Super + L`.

`Super + L` uuesti vajutamine muudab tööruuma ujuvaks, kus aknad kattuvad vabalt ja sa asetad need ise, ning kolmas vajutus viib selle tagasi dwindle'i. `Super + Alt + L` käib need läbi teistpidi. Aken, mis hõljub niikuinii — selline, mille sa `Super + T` abil välja poputasid, või rakendus, mis avaneb alati ujuvana — jääb ujuvaks, kui tööruum läheb tagasi plaatimisse. Ülariba tähistab tööruuma, millel oled, selle paigutusega: ruut dwindle'i, ring keriva ja kolmnurk ujuva jaoks. Selle märgi klõpsamine vahetab paigutust samuti, nagu ka kuvaklahv sülearvutitel, millel see on.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valik kehtib tööruumi kohta eraldi ja see jääb püsima. Nii saad hoida tööruuma 1 brausimiseks dwindle'il ja tööruuma 2 koodi jaoks kerival ning need tulevad pärast taaskäivitust samamoodi tagasi.

Kui soovid kerivat paigutust vaikepaigutusena kasutada, saad selle määrata failis `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Ujuvad tööruumid

Ujuv tööruum töötab nagu traditsiooniline töölaud: aknad kattuvad ning sa liigutad ja muudad nende suurust ise. Iga aken saab sinu teema värvides tiitliriba nuppudega minimeerimiseks, maksimeerimiseks ja sulgemiseks. `Super + M` minimeerib ka fookuses oleva akna. Minimeeritud aken ootab dokis; klõpsa selle rakendusel, et see tagasi tuua. Klõpsa aknal, et see ettepoole tuua. Muuda selle suurust mis tahes servast või nurgast. Topeltklõpsa tiitliribal, et aken maksimeerida, jättes ülariba nähtavale, ja uuesti, et selle vana suurus tagasi saada. Chrome ja teised Chromiumil põhinevad brauserid, Disks ja Document Viewer jätavad tiitliriba vahele ja kasutavad selle asemel oma päist; `Super + Alt + F` maksimeerib need ja `Super + M` minimeerib need.

Igal tööruumal on dokk sinu kinnitatud rakendustega, kõigega, mis parajasti töötab, ja iga rakenduse ruudustikuga rakenduste nupu taga, mille avavad ka `Super + Alt + Space` ja Omarchy menüüs _Apps_. Rakenduse desinstallimiseks tee ruudustikus rakendusel paremklõps või vajuta `Delete`. Klõpsa rakendusel, et see avada või selle aken ettepoole tuua; klõpsa uuesti, et selle aknaid järjest läbi käia. Files toob tagasi ainult selle tööruuma akna, millel parajasti oled, ja avab muidu uue, ning Terminal ja Agent käivitavad alati uue, kuigi minimeeritud aken tuleb enne tagasi. Keskmine klõps avab uue akna. Lohista ikooni mööda dokki, et seda liigutada; töötava rakenduse teiste sekka lohistamine jätab selle sinna. Tee paremklõps, et rakendus dokki jätta, see sealt eemaldada või see sulgeda. Dokk püsib väljas, kuni tööruum on tühi, ja kui tööruumal on aken, peidab see end seni, kuni kursor jõuab selle servani. Täisekraanaken peidab selle täielikult. Lohista rakenduste nupp ekraani teise serva poole, et dokk sinna viia. Tee sellel paremklõps valiku _Position_ jaoks, et serv valida, valiku _Layout_ jaoks, et vaikepaigutus määrata nii, nagu seda teeb _Appearance > Workspace Layout_, ja valiku _Visibility_ jaoks, et dokk alati peal hoida, lasta esimesel rakendusel see peita või hoida see alati peidetuna. `omarchy dock visibility always` määrab selle terminalist. Asukoht on ka valiku _Appearance > Dock > Dock Position_ all ja `omarchy dock position left` määrab selle terminalist. Rakendused, mida dokis hoiad, on tuhmid ajal, mil nad ei tööta. Doki ainult ujuvatel tööruumidel hoidmiseks kasuta valikut _Appearance > Dock > Dock Only on Floating_ või käsku `omarchy dock tiling off`.

Uued tööruumid ja kõik, millele sa pole `Super + L` abil oma paigutust andnud, kasutavad vaikepaigutust. Vaikepaigutuse muutmine lähtestab sellele iga akendeta tööruuma, akendega tööruum säilitab aga paigutuse, mis sellel on. Dokki minimeeritud aken loeb endiselt aknaks tööruumal, kust see lahkus. Vali see valiku _Appearance > Workspace Layout_ alt: Tiling, Scrolling või Floating. `omarchy hyprland workspace layout default scrolling` määrab selle terminalist.

### Akende rühmitamine

Aknaid saab rühmitada klahvikombinatsiooniga `Super + G`. Kui oled rühmas, kuulub iga aken, mille selle aktiivsuse ajal käivitad, rühma. Nende rühmitatud akende vahel saad liikuda klahvikombinatsiooniga `Super + Ctrl + Arrow Left/Right` või `Super + Alt + 1/2/3/4`, et minna otse rühmitatud akende juurde järjekorras.

Akna saad rühmitusest välja viia klahvikombinatsiooniga `Super + Alt + G` või kogu rühma lahti võtta, vajutades uuesti `Super + G`. Lõpuks saad rühmast väljaspool olevaid aknaid sinna sisse viia klahvikombinatsiooniga `Super + Alt + Arrows`.

### Akende välja poputamine

Akna saad selle tööruumi jaotusest välja poputada klahvikombinatsiooniga `Super + O`. See kinnitab selle ujuva aknana, mis järgneb sulle, ükskõik millisele tööruumile sa lähed. Suurepärane videopleierite ja muu sarnase jaoks.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-tööruum

On olemas eriline täissuuruses scratchpad-tööruum, mis asetub selle tööruuma peale, millel parajasti oled. Sellel olevale pääsed ligi klahvikombinatsiooniga `Super + S` ja aknaid asetad sinna klahvikombinatsiooniga `Super + Alt + S`.

See sobib hästi juhtelementide või terminali jaoks, millega soovid kiiresti suhelda ilma praeguselt tööruumalt lahkumata.

### Quake'i konsool

Lõpuks on olemas poole kõrgusega Quake'i konsool, mis langeb alla selle tööruuma peale, millel parajasti oled. Lülita seda klahvikombinatsiooniga `Super + the key above Tab` (US paigutustel grave) ja aseta sinna aken klahvikombinatsiooniga `Super + Shift + the key above Tab`.

Esimesel avamisel käivitab see sinu vaikeagendi või palub sul ühe valida, kui sa pole seda veel teinud. Kui konsool hoiab ühte akent, langeb see alla keskele paigutatud paneelina, selle asemel et üle ekraani ulatuda. Aseta sinna teine rakendus ja see läheb tagasi täislaiusesse, nii et neil kahel on ruumi kõrvuti istuda.

Akna kas scratchpadilt või konsoolilt ära viimiseks saada see otse teisele tööruumile millegagi nagu `Super + Shift + 1`.

### Sellega harjumine võtab veidi aega!

Sellisel viisil töölaual navigeerimisega harjumine võtab veidi aega, kuid kui sellega ära harjud, on raske traditsioonilise hiirega juhitava töölauakogemuse juurde tagasi minna!
