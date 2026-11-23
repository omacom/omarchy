# Értesítések

Az értesítések a fókuszban lévő kijelző jobb felső sarkában jelennek meg. A dátumot és az időt, az akkumulátor állapotát és az aktuális időjárást is gyorsan elérheted a gyorsbillentyűs értesítésekkel.

## Értesítések

Az ugyanattól az alkalmazástól vagy webhelytől érkező értesítések pakliba rendeződnek, így egy fecsegős Slack-csatorna nem tolja le a képernyőről a build hibáját. Vidd az egeret egy pakli fölé, hogy szétterüljön; amíg olvasol, semmi új nem csúszik be a mutatód alá. Kattints egy kártyára, hogy oda ugorj, ahonnan érkezett; jobb gombbal, középső gombbal vagy a ✕ megnyomásával bezárhatod.

A kártyák azt kínálják, amit hordoznak: _Kód másolása_ az ellenőrző kódokhoz (ezek nem kerülnek be a [vágólap-előzményekbe](08-unified-clipboard-history.md), és egy perc után törlődnek), plusz minden gombot, amit az alkalmazás ad. Az értesítés szövegében lévő linkek kattintásra megnyílnak.

A `Super + ,` bezárja a legújabb értesítést, vagy megnyitja, amire mutat, ha felkínálja azt, a `Super + Alt + ,` csak az utolsót zárja be, a `Super + Shift + ,` mindet bezárja, a `Super + Shift + Alt + ,` pedig megnyitja az előzményeket. Ha egér nélkül használnád őket, nyomd meg a `Super + Ctrl + ,` billentyűkombinációt. A legújabb értesítés lesz kiválasztva, a gombjai pedig számozva jelennek meg: nyomj meg egy számot az egyik használatához, `Enter` billentyűt az értesítésre kattintáshoz, `↑` és `↓` billentyűt az értesítések közötti mozgáshoz, `Delete` billentyűt az egyik bezárásához, és `Esc` billentyűt a billentyűzet visszaadásához. Néhány másodpercnyi tétlenség után magától is elenged.

Az értesítések némítása visszatartja őket, kivéve az Omarchy saját megerősítéseit, a vészjelzéseket és az ellenőrző kódokat, amelyeket egy pillanattal ezelőtt kértél. Az utolsó néhányat, akár visszatartották őket, akár nem, a `Super + Shift + Alt + ,` billentyűkombinációval teheted vissza a képernyőre. Az előzményeket egy napig őrzi meg.

## Gyorsbillentyűs értesítések

### Dátum és idő

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Időjárás

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

A helyet az IP-címed alapján határozza meg, ami általában elég pontos, de nem mindig. Rögzítheted az `omarchy weather location --set Malibu` paranccsal, vagy pontos lehetsz koordináták hozzáadásával: `omarchy weather location --set Malibu 34.0259,-118.7798`. Futtasd önmagában az `omarchy weather location` parancsot, hogy lásd, hol gondol téged, a `--clear` kapcsolóval pedig visszatérhetsz az automatikus érzékeléshez.

### Akkumulátor

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
