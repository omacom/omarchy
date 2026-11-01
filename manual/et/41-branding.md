# Bränding

Omarchy võimaldab sul määrata oma ettevõtte logo või isikliku pildi nii alglaadimisel avamise ekraanile, ekraanisäästjale kui ka teabeekraanile.

### Alglaadimisel avamine

Võid kasutada käsku `omarchy plymouth preview`, et näha, millised sinu kohandatud logo ja värvid välja näeksid. See võtab taustavärvi, tekstivärvi, logo png ja eelvaate pildi tee:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Seejärel rakenda seadistus käsuga `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, mis annab ka SDDM-i sisselogimisekraanile samad värvid ja logo. Kui soovid selle tagasi võtta, võid kasutada käsku `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Ekraanisäästja

Ekraanisäästja jaoks kasutatavat logo saad muuta jaotises _Appearance > Branding > Screensaver_. See on ASCII logo, nii et saad teksti otse muuta, aga võid sellele anda ka png või svg pildi ja me teisendame selle ASCII-ks. See näeb päris lahe välja.

 ![branding-screensaver](images/branding-screensaver.webp)

Selles menüüs on kolm kirjet:

- **Edit Text** avab faili `~/.config/omarchy/branding/screensaver.txt` sinu redaktoris. Kirjuta või kleebi mida iganes soovid — ASCII-kunsti, oma nime, roppu sõna. Salvesta ja välju ning ekraanisäästja käivitub kohe, et saaksid seda näha.
- **Set From Image** avab failivalija png või svg jaoks, teisendab selle ASCII-ks ja näitab sulle tulemust. Selge siluetiga logod toimivad palju paremini kui fotod.
- **Restore Default** paneb Omarchy logo tagasi.

### Teabeekraan

Samad kolm valikut on jaotises _Appearance > Branding > About_ selle _About_ ekraani jaoks, mille saad Omarchy menüüst, ja need töötavad identselt — fail on `~/.config/omarchy/branding/about.txt` ja About aken ilmub pärast iga muudatust esile. About'i kunst teisendatakse väiksemasse mõõtu kui ekraanisäästja oma, kuna see peab mahtuma aknasse, mitte täitma kogu sinu ekraani.

Kuni aken on avatud, libiseb iga mõne sekundi tagant üle kunsti roheline helk ja jätab selle seejärel jälle paigale. Ka sinu oma kunst saab selle, seni kui iga märk selles on ühe veeru laiune — kõik, mida _Set From Image_ toodab, ongi. Emoji'dest või kahe veeru laiustest märkidest koostatud kunst jääb selle asemel paigale, ja samuti ekraan, kui hoiad omaenda fastfetch konfigi: neil juhtudel tähendab paigal püsiv logo seda, et animatsioon hoiab viisakalt eemale, mitte ei ebaõnnestu, sest helgi libistamine üle nende paneks ülejäänud rea valesse kohta.

 ![branding-about](images/branding-about.webp)

### Piltide ise teisendamine

Mõlemad _Set From Image_ valikud lihtsalt kutsuvad käsku `omarchy transcode ascii`, mida saad otse käivitada, kui soovid teisenduse üle kontrolli:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

See võtab `--width` ja `--height` terminali veergudes ja ridades, `--mode` kas `braille` (vaikevalik ja palju peenem) või `block`, `--threshold` protsendi otsustamaks, millised pikslid loetakse logo osaks, ja `--invert`, kui sinu logo on hele tumedal taustal. Kui teisendus tuleb välja nagu plönn, on lävi tavaliselt see nupp, mida keerata.

### Sõnad logo asemel

`omarchy ascii` joonistab teksti kirjastiiliga Delta Corps Priest 1, FIGlet fondiga, millega on joonistatud ka Omarchy sõnamärk ise, nii et ekraanisäästja saab midagi öelda, mitte pilti näidata:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

See võtab teksti argumentidena või loeb selle torust, kui ühtegi pole antud. Font sisaldab ainult tähti ja tühikuid — see joonistati ilma numbrite ja kirjavahemärkideta — nii et kõik muu jäetakse välja ja nimetatakse stderr-is, selle asemel et see vaikselt alla neelata.
