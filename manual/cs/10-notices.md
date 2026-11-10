# Oznámení

Oznámení se zobrazují v pravém horním rohu zaměřeného displeje. Pomocí klávesových zkratek pro oznámení můžete také rychle zobrazit datum a čas, stav baterie a aktuální počasí.

## Oznámení

Oznámení ze stejné aplikace nebo webu se skládají do balíčku, takže upovídaný kanál na Slacku nevytlačí vaše selhání buildu z obrazovky. Když na balíček najedete myší, rozprostře se; zatímco čtete, nic nového pod váš ukazatel nevklouzne. Kliknutím na kartu přejdete tam, odkud přišla, kliknutím pravým tlačítkem, prostředním tlačítkem nebo stisknutím ✕ ji zavřete.

Karty nabízejí to, co nesou: _Kopírovat kód_ pro ověřovací kódy (neukládají se do [historie schránky](08-unified-clipboard-history.md) a po minutě se vymažou) plus veškerá tlačítka, která aplikace poskytuje. Odkazy v textu oznámení se otevřou po kliknutí.

Chcete-li je používat bez myši, stiskněte `Super + Ctrl + ,`. Vybere se nejnovější oznámení a jeho tlačítka se očíslují: stisknutím čísla jedno použijete, `Enter` klikne na oznámení, `↑` a `↓` přepínáte mezi oznámeními, `Delete` jedno zavřete a `Esc` vrátíte klávesnici zpět. Po několika sekundách nečinnosti se ovládání také samo uvolní.

Ztlumení oznámení je pozdrží, s výjimkou vlastních potvrzení Omarchy, nouzových upozornění a ověřovacích kódů, které jste si před chvílí sami vyžádali. Posledních několik jich vrátíte na obrazovku, ať už byla pozdržena, nebo ne, pomocí `Super + Shift + Alt + ,`. Historie se uchovává jeden den.

## Oznámení přes klávesové zkratky

### Datum a čas

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Počasí

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Polohu určuje vaše IP adresa, což je obvykle dostatečně přesné, ale ne vždy. Můžete ji upřesnit pomocí `omarchy weather location --set Malibu`, nebo být zcela přesní přidáním souřadnic: `omarchy weather location --set Malibu 34.0259,-118.7798`. Spuštěním samotného `omarchy weather location` zjistíte, kde si myslí, že jste, a pomocí `--clear` se vrátíte k automatické detekci.

### Baterie

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
