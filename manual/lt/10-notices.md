# Pranešimai

Pranešimai atsiranda viršutiniame dešiniajame sufokusuoto ekrano kampe. Spartaisiais klavišais iškviečiamais pranešimais taip pat galite greitai pasiekti datą ir laiką, baterijos būseną ir dabartinius orus.

## Pranešimai

To paties programos ar svetainės pranešimai sukraunami į kaladę, todėl plepus Slack kanalas nenustums jūsų nepavykusio kūrimo pranešimo už ekrano ribų. Užveskite pelę ant kaladės, kad ją išskleistumėte; kol skaitote, po jūsų žymekliu neįslys nieko naujo. Spustelėkite kortelę, kad pereitumėte ten, iš kur ji atkeliavo, spustelėkite dešiniuoju, viduriniu pelės mygtuku arba paspauskite ✕, kad ją atmestumėte.

Kortelės siūlo tai, ką atsineša: _Copy code_ patvirtinimo kodams (kurie neįtraukiami į [iškarpinės istoriją](08-unified-clipboard-history.md) ir išvalomi po minutės) ir visus mygtukus, kuriuos pateikia programa. Pranešimo tekste esančios nuorodos atidaromos jas spustelėjus.

`Super + ,` atmeta naujausią pranešimą arba atidaro tai, į ką jis rodo, kai tai siūlo, `Super + Alt + ,` atmeta tik paskutinį, `Super + Shift + ,` atmeta juos visus, o `Super + Shift + Alt + ,` atidaro istoriją. Norėdami juos naudoti be pelės, paspauskite `Super + Ctrl + ,`. Pasirenkamas naujausias pranešimas, o jo mygtukai sunumeruojami: paspauskite skaičių, kad kurį nors panaudotumėte, `Enter`, kad spustelėtumėte pranešimą, `↑` ir `↓`, kad judėtumėte tarp pranešimų, `Delete`, kad kurį nors atmestumėte, ir `Esc`, kad grąžintumėte klaviatūrą. Po kelių neveiklumo sekundžių ji taip pat atsipalaiduoja pati.

Pranešimų nutildymas juos sulaiko, išskyrus pačios Omarchy patvirtinimus, skubius įspėjimus ir patvirtinimo kodus, kurių paprašėte prieš akimirką. Paskutinius kelis vėl parodykite ekrane, sulaikytus ar ne, paspaudę `Super + Shift + Alt + ,`. Istorija saugoma vieną dieną.

## Spartieji pranešimai klavišais

### Data ir laikas

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Orai

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Vieta nustatoma pagal jūsų IP adresą, o to paprastai pakanka, bet ne visada. Galite ją patikslinti komanda `omarchy weather location --set Malibu` arba nurodyti tiksliai, pridėdami koordinates: `omarchy weather location --set Malibu 34.0259,-118.7798`. Paleiskite `omarchy weather location` atskirai, kad pamatytumėte, kur, jos manymu, esate, ir `--clear`, kad grįžtumėte prie automatinio nustatymo.

### Baterija

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
