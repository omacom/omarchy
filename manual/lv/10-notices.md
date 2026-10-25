# Paziņojumi

Paziņojumi nonāk fokusētā displeja augšējā labajā stūrī. Ar karsto taustiņu paziņojumiem vari arī ātri piekļūt datumam un laikam, akumulatora statusam un aktuālajiem laikapstākļiem.

## Paziņojumi

Paziņojumi no vienas un tās pašas lietotnes vai vietnes sagrupējas kaudzē, tāpēc pļāpīgs Slack kanāls neizstumj tavu būvējuma kļūmi no ekrāna. Novieto kursoru virs kaudzes, lai to izvērstu vēdeklī; kamēr lasi, nekas jauns neieslīd zem tava kursora. Noklikšķini uz kartītes, lai pārietu tur, no kurienes tā nākusi; noklikšķini ar labo pogu, ar vidējo pogu vai nospied ✕, lai to noraidītu.

Kartītes piedāvā to, ko tās nes: _Kopēt kodu_ verifikācijas kodiem (tie netiek saglabāti [starpliktuves vēsturē](08-unified-clipboard-history.md) un pēc minūtes tiek notīrīti), kā arī visas pogas, ko nodrošina lietotne. Saites paziņojuma tekstā atveras, uz tām noklikšķinot.

Lai tos lietotu bez peles, nospied `Super + Ctrl + ,`. Tiek atlasīts jaunākais paziņojums un tā pogas tiek sanumurētas: nospied ciparu, lai izmantotu kādu no tām, `Enter`, lai noklikšķinātu uz paziņojuma, `↑` un `↓`, lai pārvietotos starp paziņojumiem, `Delete`, lai kādu noraidītu, un `Esc`, lai atdotu tastatūru atpakaļ. Pēc dažām dīkstāves sekundēm tā arī pati atlaižas.

Paziņojumu apklusināšana tos aiztur, izņemot pašas Omarchy apstiprinājumus, ārkārtas brīdinājumus un verifikācijas kodus, kurus tu pirms brīža pats pieprasīji. Parādi pēdējos dažus atkal uz ekrāna, aizturētus vai ne, ar `Super + Shift + Alt + ,`. Vēsture tiek glabāta vienu dienu.

## Karsto taustiņu paziņojumi

### Datums un laiks

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Laikapstākļi

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Atrašanās vieta tiek noteikta pēc tavas IP adreses, kas parasti ir pietiekami tuvu, bet ne vienmēr. Vari to precizēt ar `omarchy weather location --set Malibu` vai norādīt pavisam precīzi, pievienojot koordinātas: `omarchy weather location --set Malibu 34.0259,-118.7798`. Palaid `omarchy weather location` atsevišķi, lai redzētu, kur, pēc tās domām, tu atrodies, un `--clear`, lai atgrieztos pie automātiskās noteikšanas.

### Akumulators

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
