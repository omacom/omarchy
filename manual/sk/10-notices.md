# Oznámenia

Oznámenia sa zobrazujú v pravom hornom rohu zaostreného displeja. Pomocou oznámení klávesových skratiek môžete rýchlo získať prístup aj k dátumu a času, stavu batérie a aktuálnemu počasiu.

## Oznámenia

Oznámenia z rovnakej aplikácie alebo stránky sa ukladajú do balíčka, takže ukecaný kanál v Slacku vám nevytlačí z obrazovky zlyhanie buildu. Umiestnením kurzora na balíček ho rozložíte; kým čítate, nič nové sa vám pod kurzor nezasunie. Kliknutím na kartu prejdete tam, odkiaľ pochádza, kliknutím pravým tlačidlom, kliknutím stredným tlačidlom alebo stlačením ✕ ju zrušíte.

Karty ponúkajú to, čo nesú: _Kopírovať kód_ pre overovacie kódy (neukladajú sa do [histórie schránky](08-unified-clipboard-history.md) a po minúte sa vymažú) a všetky tlačidlá, ktoré poskytuje aplikácia. Odkazy v texte oznámenia sa otvoria po kliknutí.

Ak ich chcete používať bez myši, stlačte `Super + Ctrl + ,`. Najnovšie oznámenie je vybrané a jeho tlačidlá sú očíslované: stlačením čísla použijete jedno z nich, stlačením `Enter` kliknete na oznámenie, stlačením `↑` a `↓` sa presúvate medzi oznámeniami, stlačením `Delete` jedno zrušíte a stlačením `Esc` vrátite ovládanie klávesnici. Po niekoľkých sekundách nečinnosti sa uvoľní aj samo.

Stíšenie oznámení ich pozdrží, okrem vlastných potvrdení Omarchy, núdzových upozornení a overovacích kódov, o ktoré ste pred chvíľou požiadali. Posledných niekoľko ich vrátite späť na obrazovku, či už boli pozdržané alebo nie, pomocou `Super + Shift + Alt + ,`. História sa uchováva jeden deň.

## Oznámenia klávesových skratiek

### Dátum a čas

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Počasie

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Poloha sa zisťuje z vašej IP adresy, čo je zvyčajne dostatočne presné, ale nie vždy. Môžete ju upresniť pomocou `omarchy weather location --set Malibu` alebo byť úplne presní pridaním súradníc: `omarchy weather location --set Malibu 34.0259,-118.7798`. Spustením samotného `omarchy weather location` zistíte, kde si myslí, že sa nachádzate, a pomocou `--clear` sa vrátite k automatickému zisťovaniu.

### Batéria

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
