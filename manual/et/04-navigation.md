# Navigeerimine

Kõik Omarchys toimub klaviatuuri kaudu — _KÕIK!_ Kui süsteem esimest korda käivitub, ei saa sa sõna otseses mõttes hiirega üksi mitte midagi tehtud. Aga sa saad vajutada `Super + Space`, et kuvada Omarchy menüü, ja siit saad teha peaaegu kõike.

Kuid Omarchy menüü ei ole isegi mõeldud olema peamine viis süsteemi enamiku ajast kasutada. Me saame kiiremini! Kõik kõige olulisemad rakendused on seotud otse üksikute kiirklahvidega. Terminali käivitad klahvidega `Super + Return` ja brauseri klahvidega `Super + Shift + Return`. Proovi teha üht ja seejärel teist ning näed Hyprlandi paanide paigutuse võlu tegevuses:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Seejärel saad vajutada `Super + J`, et laduda need üksteise peale, mitte kõrvuti:

 ![navigation-stacked](images/navigation-stacked.webp)

Vajuta uuesti `Super + J`, et viia need tagasi kõrvuti asenditesse. Seejärel proovi brauseril olles `Super + Shift + Arrow Right`, et aknad omavahel vahetada.

Nüüd proovi `Super + Shift + T`, et käivitada Activity monitor. See ilmub hõljuva aknana. Saad selle paaniks muuta klahvidega `Super + T` (ja vajuta seda uuesti, et muuta see jälle hõljuvaks). Nüüd vajuta `Super + Shift + F`, et avada failihaldur. Sul on korralik neljaosaline paigutus:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Sa navigeerid akna, mille soovid aktiivseks muuta, vahel klahvidega `Super + Arrow`. See vahetab fookuse ja liigutab kursori uue rakenduse keskele. Ekraani serval liigub see edasi sellel küljel olevale monitorile.

Kui vajutad `Super + Shift + 2`, liigutad praegu fookuses oleva rakenduse teisele tööalale. `Super + Shift + 1` liigutab selle tagasi. (Ja `Super + Shift + Alt + 2` liigutab praegu fookuses oleva rakenduse teisele tööalale sinna ümber lülitumata).

Rohkem kui ühe monitori korral on igal monitoril oma tööalad 1 kuni 10. `Super + 2` läheb selle monitori teisele tööalale, millel sa oled, ja iga monitori ülemine riba näitab selle enda tööalasid ja seda, mida see parajasti kuvab. `Super + Tab` liigub selle monitori tööalade vahel, millel sa oled. `Super + Shift + Ctrl + Arrows` liigutab akna, millel sa oled, selles suunas olevale monitorile, selle kuvatavale tööalale, ja `Super + Shift + Alt + Arrows` liigutab tööala, millel sa oled, selles suunas olevale monitorile, kus see võtab sama numbri, kui see on vaba. Monitor säilitab oma tööalad, kui selle lahti ühendad: need liituvad teise ekraani omadega, nummerdatuna pärast sellel juba olevaid, ja lähevad oma vanade numbrite alla tagasi, kui monitor naaseb.

Kui hoiad all klahvi `Super` ja kasutad hiirt aknale klõpsamiseks, saad muuta, kus see asub. Kui hoiad all klahvi `Super` ja kasutad hiire paremat nuppu, saad akna suurust vabalt muuta.

Akna sulged klahvidega `Super + W` või `Super + Q` (ja kõik aknad sulged klahvidega `Ctrl + Alt + Delete`).

Saad minna ka täisekraanile klahvidega `Super + F` või isegi lihtsalt täislaiusesse (ülemise riba säilitades) klahvidega `Super + Alt + F` või akna sees täisekraanile klahvidega `Super + Ctrl + F` (hea YouTube'i jaoks!).

### Dwindle vs keriv paigutus

Omarchy vaikepaigutust nimetatakse dwindle'iks. See hoiab kõiki ühe tööala aknaid, mille avad, kogu aeg nähtaval, isegi kui see peab neid selleks väiksemaks kahandama.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Kuid sa saad ka valida tööala muutmise kerivaks paigutuseks, kus aknad on reastatud kõrvuti, väljaspool kuva nähtavat serva. Ühe tööala muudad selliseks paigutuseks klahvidega `Super + L`.

`Super + L` uuesti vajutamine muudab tööala hõljuvaks, kus aknad kattuvad vabalt ja sa paigutad need ise, ja kolmas vajutus viib selle tagasi dwindle'isse. `Super + Alt + L` käib need läbi teistpidi. Aken, mis hõljub niikuinii — selline, mille sa tõstsid välja klahvidega `Super + T`, või rakendus, mis avaneb alati hõljuvana — jääb hõljuma, kui tööala läheb tagasi paanimisele. Ülemine riba tähistab tööala, millel sa oled, selle paigutusega: dwindle puhul ruut, keriva puhul ring ja hõljuva puhul kolmnurk. Sellele tähisele klõpsamine vahetab samuti paigutust tsükliliselt.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valik käib tööala kaupa ja see jääb püsima. Nii saad hoida 1. tööala dwindle'is sirvimiseks ja 2. tööala kerivas paigutuses koodi jaoks ning need tulevad pärast taaskäivitust samamoodi tagasi.

Kui soovid kasutada kerivat paigutust vaikepaigutusena, saad selle määrata failis `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Hõljuvad tööalad

Hõljuv tööala töötab nagu traditsiooniline töölaud: aknad kattuvad ja sa liigutad ning muudad nende suurust ise. Iga aken saab sinu teema värvides tiitliriba koos nuppudega minimeerimiseks, maksimeerimiseks ja sulgemiseks. `Super + M` minimeerib ka fookuses oleva akna. Minimeeritud aken ootab dokis; klõpsa selle rakendust, et see tagasi tuua. Klõpsa akent, et see ettepoole tuua. Muuda selle suurust mis tahes servast või nurgast. Topeltklõpsa tiitliribal, et aken maksimeerida, hoides samal ajal ülemise riba nähtaval, ja uuesti, et selle vana suurus tagasi saada.

Hõljuv tööala näitab ka dokki koos sinu kinnitatud rakendustega, kõige sellega, mis parajasti töötab, ja iga rakenduse ruudustikuga rakenduste nupu taga, mille avavad ka `Super + Alt + Space` ja Omarchy menüüs olev _Apps_. Paremklõpsa ruudustikul rakendust või vajuta `Delete`, et see desinstallida. Klõpsa rakendust, et see avada või selle aken ettepoole tuua; klõpsa uuesti, et selle akende vahel tsükliliselt liikuda. Keskmine klõps avab uue akna. Lohista ikooni mööda dokki, et seda liigutada; töötava rakenduse teiste sekka lohistamine jätab selle sinna. Paremklõpsa, et rakendus dokki jätta, see sealt välja võtta või see sulgeda. Dokk läheb täisekraanil oleva akna eest ära. Paremklõpsa rakenduste nuppu, et dokk teisele servale liigutada või panna see peituma, kuni kursor selle servani jõuab. Asukoht on ka valiku _Appearance > Dock > Dock Position_ all ning `omarchy dock position left` ja `omarchy dock autohide on` määravad mõlemad terminalist. Rakendused, mille dokki jätad, on tuhmid, kuni need ei tööta.

Uued tööalad ja kõik need, millele sa ei ole klahvidega `Super + L` oma paigutust andnud, kasutavad vaikepaigutust. Vaikepaigutuse muutmine lähtestab iga akendeta tööala sellele, samas kui akendega tööala säilitab paigutuse, mis sellel on. Dokki minimeeritud aken loetakse endiselt aknaks tööalal, millelt see lahkus. Vali see valiku _Appearance > Workspace Layout_ alt: Tiling, Scrolling või Floating. `omarchy-hyprland-workspace-layout-default scrolling` määrab selle terminalist.

### Akende rühmitamine

Aknaid saab rühmitada klahvidega `Super + G`. Kui oled rühmas, kuulub rühma iga aken, mille käivitad sel ajal, kui see on aktiivne. Nende rühmitatud akende vahel saad liikuda klahvidega `Super + Ctrl + Arrow Left/Right` või `Super + Alt + 1/2/3/4`, et minna otse järjekorras rühmitatud aknani.

Saad akna rühmast välja liigutada klahvidega `Super + Alt + G` või kogu rühma lahti võtta, vajutades uuesti `Super + G`. Lõpuks saad aknad väljastpoolt rühma selle sisse liigutada klahvidega `Super + Alt + Arrows`.

### Akende välja tõstmine

Saad akna selle tööala jaotusest välja tõsta klahvidega `Super + O`. See kinnitab selle hõljuva aknana, mis järgneb sulle, mis tahes tööalale sa lähed. Suurepärane videopleierite ja muu sellise jaoks.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpad-tööala

On olemas spetsiaalne täissuuruses scratchpad-tööala, mis katab selle tööala, millel sa parajasti oled. Sellel olevale pääsed juurde klahvidega `Super + S` ja aknad asetad sinna klahvidega `Super + Alt + S`.

See töötab hästi juhtnuppude või terminali jaoks, millega soovid kiiresti suhelda praeguselt tööalalt lahkumata.

### Quake konsool

Lõpuks on olemas poolkõrgune Quake konsool, mis langeb alla selle tööala peale, millel sa parajasti oled. Lülita see sisse ja välja klahvidega `Super + Grave` ja aseta aken sinna klahvidega `Super + Shift + Grave`.

See avaneb koos sinu vaikeagendiga, mis on valmis tegutsema. Kui konsoolil on üksainus aken, langeb see alla tsentreeritud paneelina, mitte ei ulatu üle ekraani. Pane sellele teine rakendus ja see läheb tagasi täislaiusesse, nii et neil kahel on ruumi kõrvuti olla.

Akna liigutamiseks kas scratchpadilt või konsoolilt ära saada see otse teisele tööalale millegagi nagu `Super + Shift + 1`.

### See vajab harjumist!

Sellisel viisil oma töölaual navigeerimisega harjumine võtab veidi aega, kuid kui oled sellega harjunud, on raske traditsioonilise hiirega juhitava töölauakogemuse juurde tagasi minna!
