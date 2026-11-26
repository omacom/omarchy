# Navigeerimine

Kõik Omarchys toimub klaviatuuri kaudu — _KÕIK!_ Kui süsteem esimest korda käivitub, ei saa sa hiirega üksi sõna otseses mõttes mitte midagi teha. Kuid võid vajutada `Super + Space`, et avada Omarchy Menu, ja siit saad teha peaaegu kõike.

Kuid Omarchy menüü ei ole isegi mõeldud olema enamiku ajast süsteemi peamine kasutamisviis. Me saame kiiremini! Kõik kõige olulisemad rakendused on seotud otse üksikute kiirklahvidega. Käivitad terminali klahvidega `Super + Return` ja brauseri klahvidega `Super + Shift + Return`. Proovi teha üht pärast teist ja näed tegevuses Hyprlandi paanitamise võlu:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Seejärel võid vajutada `Super + J`, et laduda need üksteise peale, mitte kõrvuti:

 ![navigation-stacked](images/navigation-stacked.webp)

Vajuta uuesti `Super + J`, et viia need tagasi kõrvuti asenditesse. Seejärel proovi brauseris olles `Super + Shift + Arrow Right`, et aknad omavahel vahetada.

Nüüd proovi `Super + Shift + T`, et käivitada Activity monitor. See ilmub hõljuva aknana. Saad selle paanida klahvidega `Super + T` (ja vajuta seda uuesti, et muuta see jälle hõljuvaks). Nüüd vajuta `Super + Shift + F`, et avada failihaldur. Sul on korralik neljaks jaotatud paigutus:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Aknade vahel, mille soovid aktiivseks muuta, navigeerid klahvidega `Super + Arrow`. See vahetab fookuse ja liigutab kursori uue rakenduse keskele. Ekraani serval liigub see edasi sellel küljel olevale monitorile.

Kui vajutad `Super + Shift + 2`, liigutad praegu fookuses oleva rakenduse teisele tööruumile. `Super + Shift + 1` liigutab selle tagasi. (Ja `Super + Shift + Alt + 2` liigutab praegu fookuses oleva rakenduse teisele tööruumile, sellele ümber lülitumata).

Rohkem kui ühe monitori korral on igal monitoril omad tööruumid 1 kuni 10. `Super + 2` läheb selle monitori teisele tööruumile, millel sa oled, ja iga monitori ülemine riba näitab selle enda tööruume ja seda, mida see parajasti näitab. `Super + Tab` liigub läbi selle monitori tööruumide, millel sa oled. `Super + Shift + Ctrl + Arrows` liigutab akna, millel sa oled, selles suunas olevale monitorile, selle tööruumile, mida see parajasti näitab, ja `Super + Shift + Alt + Arrows` liigutab tööruumi, millel sa oled, selles suunas olevale monitorile, kus see võtab sama numbri, kui see on vaba. Monitor säilitab oma tööruumid, kui selle lahti ühendad: need liituvad teise ekraani omadega, nummerdatuna pärast sellel juba olevaid, ja lähevad tagasi oma vanade numbrite alla, kui monitor naaseb.

Kui hoiad `Super` all ja kasutad hiirt aknale klõpsamiseks, saad muuta selle asukohta. Kui hoiad `Super` all ja kasutad hiire paremat nuppu, saad akna suurust vabalt muuta.

Akna sulged klahvidega `Super + W` või `Super + Q` (ja kõik aknad sulged klahvidega `Ctrl + Alt + Delete`).

Saad ka minna täisekraanile klahvidega `Super + F` või isegi lihtsalt täislaiusesse (ülemise riba säilitades) klahvidega `Super + Alt + F` või akna sees täisekraanile klahvidega `Super + Ctrl + F` (hea YouTube'i jaoks!).

### Dwindle vs keriv paigutus

Omarchy vaikepaigutuse nimi on dwindle. See hoiab kõiki ühel tööruumil avatud aknaid kogu aeg nähtaval, isegi kui peab neid väiksemaks kahandama.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Kuid võid ka valida tööruumi muutmise kerivaks paigutuseks, kus aknad on reastatud kõrvuti, ekraani nähtavast servast kaugemale. Üksiku tööruumi muudad selliseks paigutuseks klahvidega `Super + L`.

`Super + L` uuesti vajutamine muudab tööruumi hõljuvaks, kus aknad kattuvad vabalt ja paigutad need ise, ning kolmas vajutus viib selle tagasi dwindle'isse. `Super + Alt + L` läbib need teises suunas. Aken, mis hõljub niikuinii — selline, mille oled klahvidega `Super + T` välja hüpanud, või rakendus, mis avaneb alati hõljuvana — jääb hõljuma, kui tööruum läheb tagasi paanimisele. Ülemine riba tähistab tööruumi, millel oled, selle paigutusega: ruut dwindle'i puhul, ring keriva puhul ja kolmnurk hõljuva puhul. Selle märgi klõpsamine vahetab samuti paigutust läbi, ja sama teeb ekraaniklahv sülearvutitel, millel see on.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valik on tööruumi kaupa ja see püsib. Nii saad hoida 1. tööruumi dwindle'il sirvimiseks ja 2. tööruumi kerival koodi jaoks ning need tulevad pärast taaskäivitust samamoodi tagasi.

Kui soovid kasutada kerivat paigutust vaikepaigutusena, saad selle määrata failis `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Hõljuvad tööruumid

Hõljuv tööruum töötab nagu traditsiooniline töölaud: aknad kattuvad ning liigutad ja määrad nende suuruse ise. Iga aken saab sinu teema värvides tiitliriba koos nuppudega minimeerimiseks, maksimeerimiseks ja sulgemiseks. `Super + M` minimeerib ka fookuses oleva akna. Minimeeritud aken ootab dokis; klõpsa selle rakendust, et see tagasi tuua. Klõpsa akent, et tuua see ettepoole. Muuda selle suurust mis tahes servast või nurgast. Topeltklõpsa tiitliribal, et akent maksimeerida, säilitades ülemise riba nähtavana, ja uuesti, et saada selle vana suurus tagasi. Chrome ja teised Chromiumil põhinevad brauserid, Disks ja Document Viewer jätavad tiitliriba vahele ja kasutavad selle asemel oma päist; `Super + Alt + F` maksimeerib need ja `Super + M` minimeerib need.

Hõljuv tööruum näitab ka dokki sinu kinnitatud rakendustega, kõigega, mis parajasti töötab, ja iga rakenduse ruudustikuga rakenduste nupu taga, mille avavad ka `Super + Alt + Space` ja Omarchy menüüs _Apps_. Paremklõpsa ruudustikul rakendust või vajuta `Delete`, et see desinstallida. Klõpsa rakendust, et see avada või tuua selle aken ettepoole; klõpsa uuesti, et liikuda läbi selle akende. Files toob tagasi ainult akna tööruumilt, millel oled, ja avab muul juhul uue, ning Terminal ja Agent käivitavad alati uue, kuigi minimeeritud aken tuleb kõigepealt tagasi. Keskmine klõps avab uue akna. Lohista ikooni mööda dokki, et seda liigutada; töötava rakenduse lohistamine teiste sekka hoiab selle seal. Paremklõpsa, et rakendus dokis hoida, see sealt välja võtta või see sulgeda. Dokk läheb täisekraani akna eest ära. Paremklõpsa rakenduste nuppu, et liigutada dokk teisele servale või panna see peituma, kuni kursor jõuab selle servani. Asukoht on ka valiku _Appearance > Dock > Dock Position_ all ning `omarchy dock position left` ja `omarchy dock autohide on` määravad mõlemad terminalist. Rakendused, mida dokis hoiad, on tuhmid, kuni need ei tööta.

Uued tööruumid ja kõik, millele sa pole klahvidega `Super + L` oma paigutust andnud, kasutavad vaikepaigutust. Vaikepaigutuse muutmine lähtestab iga akendeta tööruumi sellele, samas kui akendega tööruum säilitab paigutuse, mis sellel on. Dokki minimeeritud aken loeb endiselt aknana tööruumil, millelt see lahkus. Vali see valiku _Appearance > Workspace Layout_ alt: Tiling, Scrolling või Floating. `omarchy hyprland workspace layout default scrolling` määrab selle terminalist.

### Akende rühmitamine

Aknaid saab rühmitada klahvidega `Super + G`. Kui oled rühmas, kuulub rühma iga aken, mille käivitad selle aktiivsena oleku ajal. Nende rühmitatud akende vahel saad liikuda klahvidega `Super + Ctrl + Arrow Left/Right` või `Super + Alt + 1/2/3/4`, et minna otse rühmitatud akende juurde järjekorras.

Akna saad rühmitusest välja liigutada klahvidega `Super + Alt + G` või kogu rühma laiali lammutada, vajutades uuesti `Super + G`. Lõpuks saad rühmast väljaspool olevaid aknaid sellesse liigutada klahvidega `Super + Alt + Arrows`.

### Akende väljahüppamine

Akna saad selle tööruumi paigutusest välja hüppama panna klahvidega `Super + O`. See kinnitab selle hõljuva aknana, mis järgneb sulle, ükskõik millisele tööruumile lähed. Suurepärane videopleierite ja muu sarnase jaoks.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad tööruum

On olemas spetsiaalne täissuuruses scratchpad tööruum, mis katab tööruumi, millel parajasti oled. Sellel olevale pääsed ligi klahvidega `Super + S` ja aknaid paigutad sinna klahvidega `Super + Alt + S`.

See töötab hästi juhtnuppude või terminali jaoks, millega soovid kiiresti suhelda praeguselt tööruumilt lahkumata.

### Quake konsool

Lõpuks on olemas poole kõrgusega Quake konsool, mis langeb alla üle tööruumi, millel parajasti oled. Lülita seda klahvidega `Super + the key above Tab` (US paigutustes grave) ja paiguta sinna aken klahvidega `Super + Shift + the key above Tab`.

Esimesel avamisel käivitab see sinu vaikeagendi või palub sul ühe valida, kui sa pole seda veel teinud. Kuni konsool hoiab üht akent, langeb see alla tsentreeritud paneelina, mitte ei ulatu üle ekraani. Pane sellele teine rakendus ja see läheb tagasi täislaiusesse, nii et neil kahel on ruumi kõrvuti istuda.

Akna liigutamiseks scratchpadilt või konsoolilt ära saada see otse teisele tööruumile näiteks klahvidega `Super + Shift + 1`.

### Sellega tuleb harjuda!

Sellise töölaua navigeerimisega harjumine võtab veidi aega, kuid kui oled sellega harjunud, on raske minna tagasi traditsioonilise hiirega juhitava töölauakogemuse juurde!
