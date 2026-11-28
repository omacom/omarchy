# Bränding

Omarchy võimaldab sul määrata oma ettevõtte logo või isikliku pildi nii ekraanisäästja kui ka teaveekraani jaoks.

### Ekraanisäästja

Ekraanisäästja logo saad muuta jaotises _Välimus > Bränding > Ekraanisäästja_. See on ASCII logo, nii et saad teksti otse muuta, aga võid anda sellele ka png- või svg-pildi ja me teisendame selle ASCII-ks. See näeb päris lahe välja.

 ![branding-screensaver](images/branding-screensaver.webp)

Selles menüüs on kolm kirjet:

- **Muuda teksti** avab `~/.config/omarchy/branding/screensaver.txt` sinu redaktoris. Kirjuta või kleebi mida iganes soovid — ASCII kunsti, oma nimi, mõni ropp sõna. Salvesta ja välju ning ekraanisäästja käivitub kohe, et saaksid seda näha.
- **Määra pildist** avab failivalija png- või svg-faili jaoks, teisendab selle ASCII-ks ja näitab sulle tulemust. Selge siluetiga logod töötavad palju paremini kui fotod.
- **Taasta vaikeväärtus** paneb Omarchy logo tagasi.

### Teaveekraan

Samad kolm valikut asuvad jaotises _Välimus > Bränding > Teave_ Omarchy menüüst avatava _Teave_ ekraani jaoks ja need töötavad identselt — fail on `~/.config/omarchy/branding/about.txt` ja Teave aken ilmub pärast iga muudatust. Teave ekraani pilt teisendatakse väiksemaks kui ekraanisäästja oma, kuna see peab mahtuma aknasse, mitte täitma kogu sinu ekraani.

Kuni aken on avatud, kaldub iga paari sekundi järel üle pildi ere valge valgusriba ja jätab selle seejärel jälle paigale. Ka sinu enda pilt saab selle, kui iga märk selles on ühe veeru laiune — kõik _Määra pildist_ loodud pildid on. Emoji'dest või topeltlaiusega märkidest koostatud pilt jääb selle asemel paigale, nagu ka ekraan, kui sul on oma fastfetch konfiguratsioon: nendel juhtudel tähendab liikumatu logo seda, et animatsioon hoiab eemale, mitte ei ebaõnnestu, sest helgi libistamine üle nende paigutaks rea ülejäänud osa valesse kohta.

 ![branding-about](images/branding-about.webp)

### Piltide ise teisendamine

Mõlemad _Määra pildist_ valikud kutsuvad lihtsalt välja `omarchy transcode ascii`, mille saad teisendamise üle kontrolli saamiseks ka otse käivitada:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

See võtab `--width` ja `--height` terminali veergudes ja ridades, `--mode` väärtuseks kas `braille` (vaikeväärtus ja palju peenem) või `block`, `--threshold` protsendi otsustamaks, millised pikslid loetakse logo osaks, ja `--invert` juhuks, kui sinu logo on hele tumedal taustal. Kui teisendus tuleb välja nagu tomp, on lävi tavaliselt see nupp, mida keerata.

### Sõnad logo asemel

`omarchy ascii` joonistab teksti Delta Corps Priest 1 fondiga — FIGlet fondiga, millega on joonistatud ka Omarchy sõnamärk ise — nii et ekraanisäästja saab midagi öelda, mitte pilti näidata:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

See võtab teksti argumentidena või loeb selle torust, kui ühtegi argumenti pole antud. Font sisaldab ainult tähti ja tühikuid — see joonistati ilma numbrite ja kirjavahemärkideta — nii et kõik muu jäetakse välja ja nimetatakse stderr-is, selle asemel et see vaikselt alla neelata.
