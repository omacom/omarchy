# Upozornění

Oznámení se objevují v pravém horním rohu zaměřeného displeje. Pomocí upozornění klávesových zkratek také rychle zobrazíte datum a čas, stav baterie a aktuální počasí.

## Oznámení

Oznámení ze stejné aplikace nebo webu se skládají do balíčku, takže upovídaný kanál na Slacku nevytlačí z obrazovky vaše selhání buildu. Najeďte na balíček, abyste ho rozložili do vějíře; zatímco čtete, nic nového vám pod ukazatel nevklouzne. Kliknutím na kartu přejdete tam, odkud přišla, kliknutím pravým tlačítkem, kliknutím prostředním tlačítkem nebo stisknutím ✕ ji zavřete.

Karty nabízejí to, co nesou: _Kopírovat kód_ u ověřovacích kódů (neukládají se do [historie schránky](08-unified-clipboard-history.md) a po minutě se vymažou), plus všechna tlačítka, která aplikace poskytuje. Odkazy v textu oznámení se po kliknutí otevřou.

`Super + ,` zavře nejnovější oznámení, nebo otevře to, na co ukazuje, když to nabízí, `Super + Alt + ,` zavře pouze poslední z nich, `Super + Shift + ,` zavře všechna a `Super + Shift + Alt + ,` otevře historii. Chcete-li je používat bez myši, stiskněte `Super + Ctrl + ,`. Vybere se nejnovější oznámení a jeho tlačítka se očíslují: stisknutím čísla některé použijete, `Enter` kliknete na oznámení, `↑` a `↓` se přesouváte mezi oznámeními, `Delete` jedno zavřete a `Esc` vrátíte klávesnici zpět. Po pár sekundách nečinnosti se ovládání také samo uvolní.

Ztišení oznámení je pozdrží, s výjimkou vlastních potvrzení Omarchy, nouzových upozornění a ověřovacích kódů, o které jste si před chvílí řekli. Posledních několik jich vrátíte na obrazovku, ať už byla pozdržená, nebo ne, pomocí `Super + Shift + Alt + ,`. Historie se uchovává jeden den.

## Upozornění klávesových zkratek

### Datum a čas

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Počasí

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Poloha se zjišťuje z vaší IP adresy, což obvykle stačí, ale ne vždy. Můžete ji zpřesnit pomocí `omarchy weather location --set Malibu`, nebo být naprosto přesní přidáním souřadnic: `omarchy weather location --set Malibu 34.0259,-118.7798`. Spuštěním samotného `omarchy weather location` zjistíte, kde si myslí, že jste, a pomocí `--clear` se vrátíte k automatické detekci.

### Baterie

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
