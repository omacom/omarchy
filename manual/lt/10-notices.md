# Pranešimai

Pranešimai atsiranda viršutiniame dešiniajame sufokusuoto ekrano kampe. Spartųjų klavišų pranešimais taip pat galite greitai pasiekti datą ir laiką, akumuliatoriaus būseną ir dabartinius orus.

## Pranešimai

Tos pačios programos ar svetainės pranešimai sukraunami į kaladę, kad plepus Slack kanalas nenustumtų jūsų nepavykusio surinkimo pranešimo nuo ekrano. Užveskite žymeklį ant kaladės, kad ji išsiskleistų; kol skaitote, po jūsų žymekliu nepakišama nieko naujo. Spustelėkite kortelę, kad pereitumėte ten, iš kur ji atėjo, spauskite dešinįjį ar vidurinį pelės mygtuką arba paspauskite ✕, kad ją atmestumėte.

Kortelės siūlo tai, ką turi: _Kopijuoti kodą_ patvirtinimo kodams (nelaikoma [iškarpinės istorijoje](08-unified-clipboard-history.md) ir išvaloma po minutės), taip pat visus programos pateikiamus mygtukus. Nuorodos pranešimo tekste atidaromos jas spustelėjus.

Norėdami jais naudotis be pelės, paspauskite `Super + Ctrl + ,`. Pasirenkamas naujausias pranešimas, o jo mygtukai sunumeruojami: paspauskite skaičių, kad panaudotumėte vieną, `Enter`, kad spustelėtumėte pranešimą, `↑` ir `↓`, kad judėtumėte tarp pranešimų, `Delete`, kad atmestumėte vieną, ir `Esc`, kad grąžintumėte klaviatūrą. Po kelių neveiklumo sekundžių jis taip pat pats paleidžia.

Nutildžius pranešimus, jie sulaikomi, išskyrus pačios Omarchy patvirtinimus, avarinius įspėjimus ir patvirtinimo kodus, kurių ką tik patys paprašėte. Paskutinius kelis vėl parodykite ekrane, sulaikytus ar ne, su `Super + Shift + Alt + ,`. Istorija saugoma vieną dieną.

## Spartųjų klavišų pranešimai

### Data ir laikas

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Orai

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Vieta nustatoma pagal jūsų IP adresą, kurio paprastai pakanka, bet ne visada. Galite ją patikslinti su `omarchy weather location --set Malibu` arba nurodyti tiksliai, pridėdami koordinates: `omarchy weather location --set Malibu 34.0259,-118.7798`. Paleiskite `omarchy weather location` atskirai, kad pamatytumėte, kur, jo manymu, esate, ir `--clear`, kad grįžtumėte prie automatinio nustatymo.

### Akumuliatorius

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
