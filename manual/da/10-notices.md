# Notifikationer

Notifikationer lander i øverste højre hjørne af den fokuserede skærm. Du kan også hurtigt få adgang til dato og klokkeslæt, batteristatus og det aktuelle vejr ved hjælp af genvejsnotifikationerne.

## Notifikationer

Notifikationer fra den samme app eller det samme websted stables i en bunke, så en snakkesalig Slack-kanal ikke skubber din fejlslagne build af skærmen. Hold markøren over en bunke for at folde den ud; der glider ikke noget nyt ind under markøren, mens du læser. Klik på et kort for at springe til det sted, det kom fra, højreklik, klik med midterknappen, eller tryk på ✕ for at afvise det.

Kort tilbyder det, de indeholder: _Kopiér kode_ til verifikationskoder (holdes ude af [udklipsholderhistorikken](08-unified-clipboard-history.md) og ryddes efter et minut) samt alle de knapper, appen leverer. Links i en notifikations tekst åbnes, når der klikkes på dem.

Hvis du vil bruge dem uden musen, skal du trykke på `Super + Ctrl + ,`. Den nyeste notifikation vælges, og dens knapper nummereres: tryk på et tal for at bruge en af dem, `Enter` for at klikke på notifikationen, `↑` og `↓` for at flytte mellem notifikationer, `Delete` for at afvise en og `Esc` for at give tastaturet tilbage. Den giver også selv slip efter et par sekunders inaktivitet.

Når notifikationer slås fra, holdes de tilbage, undtagen Omarchys egne bekræftelser, nødalarmer og verifikationskoder, som du bad om for et øjeblik siden. Få de seneste vist på skærmen igen, uanset om de blev holdt tilbage eller ej, med `Super + Shift + Alt + ,`. Historikken gemmes i et døgn.

## Genvejsnotifikationer

### Dato og klokkeslæt

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Vejr

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Placeringen registreres ud fra din IP-adresse, hvilket som regel er tæt nok på, men ikke altid. Du kan fastlåse den med `omarchy weather location --set Malibu`, eller være helt præcis ved at tilføje koordinater: `omarchy weather location --set Malibu 34.0259,-118.7798`. Kør `omarchy weather location` alene for at se, hvor den tror, du er, og `--clear` for at vende tilbage til automatisk registrering.

### Batteri

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
