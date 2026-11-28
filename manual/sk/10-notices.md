# Oznámenia

Oznámenia sa zobrazujú v pravom hornom rohu zaostreného displeja. Pomocou oznámení klávesových skratiek môžete rýchlo získať prístup aj k dátumu a času, stavu batérie a aktuálnemu počasiu.

## Oznámenia

Oznámenia z rovnakej aplikácie alebo stránky sa skladajú do balíčka, takže ukecaný kanál na Slacku nevytlačí z obrazovky vaše zlyhanie zostavenia. Prejdením na balíček ho rozložíte; počas čítania sa vám pod kurzor nezasunie nič nové. Kliknutím na kartu prejdete na miesto, odkiaľ pochádza, kliknutím pravým tlačidlom, stredným tlačidlom alebo stlačením ✕ ju zatvoríte.

Karty ponúkajú to, čo prinášajú: _Kopírovať kód_ pre overovacie kódy (neukladajú sa do [histórie schránky](08-unified-clipboard-history.md) a po minúte sa vymažú), plus všetky tlačidlá, ktoré poskytuje aplikácia. Odkazy v texte oznámenia sa po kliknutí otvoria.

`Super + ,` zatvorí najnovšie oznámenie alebo otvorí to, na čo odkazuje, keď to ponúka, `Super + Alt + ,` zatvorí iba to posledné, `Super + Shift + ,` zatvorí všetky a `Super + Shift + Alt + ,` otvorí históriu. Ak ich chcete používať bez myši, stlačte `Super + Ctrl + ,`. Vyberie sa najnovšie oznámenie a jeho tlačidlá sa očíslujú: stlačením čísla použijete jedno z nich, `Enter` kliknete na oznámenie, `↑` a `↓` sa presúvate medzi oznámeniami, `Delete` jedno zatvoríte a `Esc` klávesnicu vrátite späť. Po niekoľkých sekundách nečinnosti sa uvoľní aj sama.

Stíšenie oznámení ich zadrží, okrem vlastných potvrdení systému Omarchy, núdzových upozornení a overovacích kódov, o ktoré ste požiadali pred chvíľou. Posledných pár vrátite na obrazovku, či už boli zadržané alebo nie, pomocou `Super + Shift + Alt + ,`. História sa uchováva jeden deň.

## Oznámenia klávesových skratiek

### Dátum a čas

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Počasie

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Poloha sa zisťuje z vašej adresy IP, čo je zvyčajne dosť presné, ale nie vždy. Môžete ju upresniť pomocou `omarchy weather location --set Malibu`, alebo byť úplne presní pridaním súradníc: `omarchy weather location --set Malibu 34.0259,-118.7798`. Spustením samotného príkazu `omarchy weather location` zistíte, kde si myslí, že sa nachádzate, a pomocou `--clear` sa vrátite k automatickej detekcii.

### Batéria

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
