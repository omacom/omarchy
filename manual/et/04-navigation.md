# Navigeerimine

Kõik Omarchy's toimub klaviatuuri kaudu — _KÕIK!_ Kui süsteem esimest korda käivitub, ei saa te sõna otseses mõttes ainult hiirega midagi teha. Aga te saate vajutada `Super + Space`, et avada Omarchy menüü, ja sealt saate teha peaaegu kõike.

Aga Omarchy menüü ei ole enamasti isegi mõeldud olema peamine viis süsteemi kasutada. Me saame kiiremini! Kõik kõige olulisemad rakendused on seotud otse üksikute kiirklahvidega. Terminali käivitate klahvidega `Super + Return` ja brauseri klahvidega `Super + Shift + Return`. Proovige teha ühte pärast teist ja näete Hyprlandi plaatpaigutuse võlu tegevuses:

 ![navigation-browser-terminal](images/navigation-browser-terminal.webp)

Seejärel saate vajutada `Super + J`, et laduda need üksteise peale, mitte kõrvuti:

 ![navigation-stacked](images/navigation-stacked.webp)

Vajutage uuesti `Super + J`, et viia need tagasi kõrvuti asendisse. Seejärel proovige brauseris olles `Super + Shift + Arrow Right`, et aknad omavahel vahetada.

Nüüd proovige `Super + Ctrl + T`, et käivitada aktiivsusmonitor. See ilmub ujuva aknana. Saate selle plaatida klahvidega `Super + T` (ja vajutada seda uuesti, et muuta see taas ujuvaks). Nüüd vajutage `Super + Shift + F`, et avada failihaldur. Teil on kena neljaosaline paigutus:

 ![navigation-fourway-tiling](images/navigation-fourway-tiling.webp)

Te liigute akende vahel, mille soovite aktiivseks teha, klahvidega `Super + Arrow`. See vahetab fookust ja liigutab kursori uue rakenduse keskele.

Kui vajutate `Super + Shift + 2`, liigutate praegu fookuses oleva rakenduse teisele tööruumile. `Super + Shift + 1` liigutab selle tagasi. (Ja `Super + Shift + Alt + 2` liigutab praegu fookuses oleva rakenduse teisele tööruumile ilma sellele lülitumata).

Kui hoiate `Super` klahvi all ja klõpsate hiirega aknal, saate ümber korraldada, kus see asub. Kui hoiate `Super` klahvi all ja kasutate hiire paremat nuppu, saate akna suurust vabalt muuta.

Akna sulgete klahvidega `Super + W` või `Super + Q` (ja kõik aknad sulgete klahvidega `Ctrl + Alt + Delete`).

Saate minna ka täisekraanile klahvidega `Super + F` või isegi lihtsalt täislaiusesse (ülemist riba säilitades) klahvidega `Super + Alt + F` või akna sees täisekraanile klahvidega `Super + Ctrl + F` (hea YouTube'i jaoks!).

### Dwindle vs keriv paigutus

Omarchy vaikepaigutust nimetatakse dwindle'iks. See hoiab kõik aknad, mille ühes tööruumis avate, kogu aeg nähtaval, isegi kui see peab neid selleks kokku suruma.

 ![navigation-dwindle-layout](images/navigation-dwindle-layout.webp)

Aga te saate valida ka tööruumi muutmise kerivaks paigutuseks, kus aknad on rivistatud kõrvuti, kaugemale ekraani nähtavast servast. Te muudate üksiku tööruumi selleks paigutuseks klahvidega `Super + L`.

Uuesti `Super + L` vajutamine muudab tööruumi ujuvaks, kus aknad kattuvad vabalt ja paigutate need ise, ning kolmas vajutus viib selle tagasi dwindle'ile. `Super + Alt + L` läbib neid teistpidi. Aken, mis nagunii ujub — mille te tõstsite välja klahvidega `Super + T` või rakendus, mis avaneb alati ujuvalt — jääb ujuma ka siis, kui tööruum läheb tagasi plaatpaigutusele. Ülemine riba tähistab tööruumi, millel viibite, selle paigutusega: ruut dwindle'i jaoks, ring keriva jaoks ja kolmnurk ujuva jaoks. Selle märgi klõpsamine vahetab samuti paigutust järgemööda.

 ![navigation-scrolling-layout](images/navigation-scrolling-layout.webp)

Valik on iga tööruumi kohta eraldi ja see püsib. Nii saate hoida tööruumi 1 dwindle'il sirvimiseks ja tööruumi 2 kerival koodi jaoks ning need tulevad pärast taaskäivitust just nii tagasi.

Kui soovite kasutada kerivat paigutust vaikesättena, saate selle määrata failis `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    layout = "scrolling",
  },
})
```

### Ujuvad tööruumid

Ujuv tööruum toimib nagu traditsiooniline töölaud: aknad kattuvad ning liigutate ja muudate nende suurust ise. Iga aken saab tiitliriba teie teema värvides, nuppudega minimeerimiseks, maksimeerimiseks ja sulgemiseks. `Super + M` minimeerib ka fookuses oleva akna. Minimeeritud aken ootab dokis; klõpsake selle rakendust, et see tagasi tuua. Klõpsake akent, et see ette tuua. Muutke selle suurust mis tahes servast või nurgast. Topeltklõpsake tiitliribal, et aken maksimeerida, säilitades samas ülemise riba nähtaval, ja uuesti, et selle vana suurus tagasi saada.

Ujuv tööruum näitab ka dokki, kus on teie kinnitatud rakendused, kõik, mis töötab, ja kõigi rakenduste ruudustik rakenduste nupu taga, mille avavad ka `Super + Alt + Space` ja _Rakendused_ Omarchy menüüs. Paremklõpsake ruudustikus rakendust või vajutage `Delete`, et see desinstallida. Klõpsake rakendust, et see avada või selle aken ette tuua; klõpsake uuesti, et selle aknaid järgemööda läbida. Keskmine klõps avab uue akna. Lohistage ikooni mööda dokki, et seda liigutada; töötava rakenduse lohistamine teiste sekka jätab selle sinna. Paremklõpsake, et hoida rakendust dokis, võtta see sealt välja või sellest väljuda. Dokk taandub täisekraani akna eest. Paremklõpsake rakenduste nuppu, et liigutada dokk teise serva või panna see peituma, kuni kursor jõuab selle servani. Asukoht on ka jaotises _Trigger > Välimus > Dock > Doki asukoht_ ning `omarchy dock position left` ja `omarchy dock autohide on` määravad mõlemad terminalist. Rakendused, mida dokis hoiate, on tuhmunud, kuni need ei tööta.

Uued tööruumid ja ükskõik millised, millele te ei ole klahvidega `Super + L` omaenda paigutust andnud, kasutavad vaikepaigutust. Vaikesätte muutmine lähtestab iga akendeta tööruumi sellele, samas kui tööruum, millel on aknad, säilitab paigutuse, mis sellel on. Dokki minimeeritud aken loeb endiselt aknana tööruumil, millelt see lahkus. Valige see jaotises _Trigger > Välimus > Tööruumi paigutus_: Plaatimine, Kerimine või Ujuv. `omarchy-hyprland-workspace-layout-default scrolling` määrab selle terminalist.

### Akende rühmitamine

Aknaid saab rühmitada klahvidega `Super + G`. Kui olete rühmas, kuulub iga aken, mille selle aktiivsena käivitate, rühma. Saate rühmitatud akende vahel liikuda klahvidega `Super + Ctrl + Arrow Left/Right` või klahvidega `Super + Alt + 1/2/3/4`, et minna otse rühmitatud akna juurde järjekorras.

Saate akna rühmitusest välja liigutada klahvidega `Super + Alt + G` või kogu rühma lahti võtta, vajutades uuesti `Super + G`. Lõpuks saate liigutada väljaspool rühma olevaid aknaid sinna sisse klahvidega `Super + Alt + Arrows`.

### Akende väljatõstmine

Saate akna selle tööruumi jaotusest välja tõsta klahvidega `Super + O`. See kinnitab selle ujuva aknana, mis järgneb teile, mis tahes tööruumile te lähete. Suurepärane videomängijate ja muu sellise jaoks.

 ![navigation-popped-window](images/navigation-popped-window.webp)

### Scratchpadi tööruum

Lõpuks on olemas spetsiaalne scratchpadi tööruum, mis langeb alla selle tööruumi peale, millel praegu viibite, umbes nagu Quake'i konsool. Lülitage seda klahvidega `Super + Grave` või `Super + S` ja paigutage sinna aken klahvidega `Super + Shift + Grave` või `Super + Alt + S`.

See toimib eriti hästi terminali jaoks, milles töötab agent, või juhtelementide jaoks, millega soovite kiiresti suhelda ilma praeguselt tööruumilt lahkumata. Akna liigutamiseks scratchpadilt maha saatke see otse teisele tööruumile näiteks klahvidega `Super + Shift + 1`.

Kui scratchpadil on üks aken, langeb see alla tsentreeritud paneelina, mitte ei ulatu üle kogu ekraani. Pange sinna teine rakendus ja see läheb tagasi täislaiusesse, nii et neil kahel on ruumi kõrvuti istuda.

### See nõuab veidi harjumist!

Sellise töölauas navigeerimisega harjumine võtab veidi aega, aga kui olete harjunud, on raske naasta traditsioonilise hiirega juhitava töölauakogemuse juurde!
