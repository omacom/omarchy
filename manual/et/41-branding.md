# Bränding

Omarchy võimaldab sul määrata oma ettevõtte logo või isikliku pildi nii alglaadimise avamisele, ekraanisäästjale kui ka teaveekraanile.

### Alglaadimise avamine

Saad kasutada käsku `omarchy plymouth preview`, et näha, millised sinu kohandatud logo ja värvid välja näeksid. See võtab taustavärvi, tekstivärvi, logo png ja eelvaatepildi tee:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Seejärel rakenda seadistus käsuga `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, mis annab ka SDDM-i sisselogimisekraanile samad värvid ja logo. Kui tahad selle tagasi pöörata, saad kasutada käsku `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Ekraanisäästja

Saad ekraanisäästja jaoks kasutatavat logo muuta kohas _Välimus > Bränding > Ekraanisäästja_. See on ASCII logo, nii et saad teksti otse muuta, aga võid anda sellele ka png- või svg-pildi ja me teisendame selle ASCII-ks. See näeb päris lahe välja.

 ![branding-screensaver](images/branding-screensaver.webp)

Selles menüüs on kolm kirjet:

- **Muuda teksti** avab sinu redaktoris faili `~/.config/omarchy/branding/screensaver.txt`. Kirjuta või kleebi mida iganes soovid — ASCII kunsti, oma nime, roppu sõna. Salvesta ja välju ning ekraanisäästja käivitub kohe, et saaksid seda näha.
- **Määra pildist** avab failivalija png või svg jaoks, teisendab selle ASCII-ks ja näitab sulle tulemust. Selge siluetiga logod toimivad palju paremini kui fotod.
- **Taasta vaikeseade** paneb Omarchy logo tagasi.

### Teaveekraan

Samad kolm valikut asuvad Omarchy menüüst saadava _Teave_ ekraani jaoks kohas _Välimus > Bränding > Teave_ ja need toimivad identselt — fail on `~/.config/omarchy/branding/about.txt` ja Teave aken ilmub pärast iga muudatust esile. Teave kunst teisendatakse väiksemasse mõõtu kui ekraanisäästja oma, kuna see peab mahtuma aknasse, mitte täitma sinu ekraani.

Kuni aken on avatud, kaldub iga paari sekundi tagant üle kunsti ereda valge valguse riba ja jätab selle seejärel jälle paigale. Ka sinu oma kunst saab selle, kuni iga märk selles on ühe veeru laiune — kõik, mida _Määra pildist_ toodab, on. Emoji'dest või kahelaiustest märkidest ehitatud kunst püsib selle asemel paigal ja nii teeb ka ekraan, kui hoiad enda fastfetch konfiguratsiooni: neil juhtudel tähendab paigal püsiv logo, et animatsioon hoiab meelega eemale, mitte et see oleks katki, kuna helgi libistamine üle nende paneks rea ülejäänud osa valesse kohta maanduma.

 ![branding-about](images/branding-about.webp)

### Piltide ise teisendamine

Mõlemad _Määra pildist_ valikud kutsuvad lihtsalt välja käsu `omarchy transcode ascii`, mida saad otse käivitada, kui tahad teisenduse üle kontrolli:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

See võtab `--width` ja `--height` terminali veergudes ja ridades, `--mode` väärtuseks kas `braille` (vaikeseade ja palju peenem) või `block`, `--threshold` protsendi otsustamaks, millised pikslid loetakse logo osaks, ja `--invert` juhuks, kui sinu logo on hele tumedal taustal. Kui teisendus tuleb välja nagu plärakas, on lävi tavaliselt see nupp, mida keerata.

### Sõnad logo asemel

`omarchy ascii` joonistab teksti kirjastiilis Delta Corps Priest 1, FIGlet kirjastiilis, milles on joonistatud ka Omarchy sõnamärk ise, nii et ekraanisäästja võib pildi näitamise asemel midagi öelda:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

See võtab teksti argumentidena või loeb selle torust, kui ühtegi ei anta. Kirjastiil sisaldab ainult tähti ja tühikuid — see joonistati ilma numbrite ja kirjavahemärkideta — nii et kõik muu jäetakse välja ja nimetatakse stderr-is, selle asemel et see vaikselt alla neelata.
