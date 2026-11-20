# Meddelelser

Notifikationer lander i det øverste højre hjørne af den fokuserede skærm. Du kan også hurtigt få adgang til dato og klokkeslæt, batteristatus og det aktuelle vejr ved hjælp af genvejsmeddelelserne.

## Notifikationer

Notifikationer fra den samme app eller det samme websted stables i en bunke, så en snakkesalig Slack-kanal ikke skubber din mislykkede build væk fra skærmen. Hold markøren over en bunke for at vifte den ud; der glider ikke noget nyt ind under din markør, mens du læser. Klik på et kort for at hoppe til, hvor det kom fra, højreklik, midterklik, eller tryk på ✕ for at afvise det.

Kort tilbyder det, de bærer: _Kopiér kode_ til bekræftelseskoder (holdt ude af [udklipsholderhistorikken](08-unified-clipboard-history.md) og ryddet efter et minut), plus eventuelle knapper, som appen tilbyder. Links i en notifikations tekst åbnes, når de klikkes på.

`Super + ,` afviser den nyeste notifikation, eller åbner det, den peger på, når den tilbyder det, `Super + Alt + ,` afviser kun den sidste, `Super + Shift + ,` afviser dem alle, og `Super + Shift + Alt + ,` åbner historikken. For at bruge dem uden musen skal du trykke på `Super + Ctrl + ,`. Den nyeste notifikation er valgt, og dens knapper er nummereret: tryk på et nummer for at bruge en, `Enter` for at klikke på notifikationen, `↑` og `↓` for at bevæge dig mellem notifikationer, `Delete` for at afvise en, og `Esc` for at give tastaturet tilbage. Den giver også slip af sig selv efter et par sekunders inaktivitet.

At slå notifikationer fra holder dem tilbage, undtagen Omarchys egne bekræftelser, nødalarmer og bekræftelseskoder, som du bad om for et øjeblik siden. Sæt de sidste par tilbage på skærmen, holdt tilbage eller ej, med `Super + Shift + Alt + ,`. Historikken gemmes i en dag.

## Genvejsmeddelelser

### Dato og klokkeslæt

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Vejr

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Placeringen registreres ud fra din IP-adresse, hvilket normalt er tæt nok på, men ikke altid. Du kan fastlåse den med `omarchy weather location --set Malibu`, eller være præcis ved at tilføje koordinater: `omarchy weather location --set Malibu 34.0259,-118.7798`. Kør `omarchy weather location` alene for at se, hvor den tror, du er, og `--clear` for at gå tilbage til automatisk registrering.

### Batteri

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
