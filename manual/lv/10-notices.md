# Paziņojumi

Paziņojumi parādās fokusētā displeja augšējā labajā stūrī. Ar karsto taustiņu paziņojumiem vari arī ātri apskatīt datumu un laiku, akumulatora statusu un pašreizējos laikapstākļus.

## Paziņojumi

Paziņojumi no vienas un tās pašas lietotnes vai vietnes sakraujas vienā kaudzītē, lai pļāpīgs Slack kanāls neizstumtu no ekrāna tavu ziņojumu par neveiksmīgu būvējumu. Novieto kursoru virs kaudzītes, lai to izvērstu vēdeklī; kamēr lasi, nekas jauns neiebrauks zem tava kursora. Noklikšķini uz kartītes, lai pārietu uz tās izcelsmes vietu, noklikšķini ar labo pogu, ar vidējo pogu vai nospied ✕, lai to noraidītu.

Kartītes piedāvā to, ko tās nes: _Kopēt kodu_ verifikācijas kodiem (tie netiek iekļauti [starpliktuves vēsturē](08-unified-clipboard-history.md) un pēc minūtes tiek notīrīti), kā arī visas pogas, ko nodrošina lietotne. Paziņojuma tekstā esošās saites atveras, kad uz tām noklikšķina.

`Super + ,` noraida jaunāko paziņojumu vai atver to, uz ko tas norāda, kad tas to piedāvā, `Super + Alt + ,` noraida tikai pēdējo, `Super + Shift + ,` noraida tos visus, un `Super + Shift + Alt + ,` atver vēsturi. Lai tos izmantotu bez peles, nospied `Super + Ctrl + ,`. Tiek atlasīts jaunākais paziņojums, un tā pogas ir sanumurētas: nospied ciparu, lai izmantotu kādu no tām, `Enter`, lai noklikšķinātu uz paziņojuma, `↑` un `↓`, lai pārvietotos starp paziņojumiem, `Delete`, lai noraidītu kādu, un `Esc`, lai atdotu tastatūru. Pēc dažām dīkstāves sekundēm tā atlaiž arī pati.

Paziņojumu apklusināšana tos aiztur, izņemot pašas Omarchy apstiprinājumus, ārkārtas brīdinājumus un verifikācijas kodus, kurus tu tikko pirms brīža pieprasīji. Ar `Super + Shift + Alt + ,` atkal parādi ekrānā pēdējos dažus, neatkarīgi no tā, vai tie tika aizturēti vai ne. Vēsture tiek glabāta vienu dienu.

## Karsto taustiņu paziņojumi

### Datums un laiks

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Laikapstākļi

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Atrašanās vieta tiek noteikta pēc tavas IP adreses, kas parasti ir pietiekami precīzi, bet ne vienmēr. Vari to precizēt ar `omarchy weather location --set Malibu` vai norādīt pavisam precīzi, pievienojot koordinātas: `omarchy weather location --set Malibu 34.0259,-118.7798`. Palaid `omarchy weather location` atsevišķi, lai redzētu, kur, pēc tā domām, tu atrodies, un `--clear`, lai atgrieztos pie automātiskās noteikšanas.

### Akumulators

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
