# Értesítések

Az értesítések a fókuszban lévő kijelző jobb felső sarkában jelennek meg. A dátumot és az időt, az akkumulátor állapotát és az aktuális időjárást is gyorsan elérheted a gyorsbillentyűs értesítésekkel.

## Értesítések

Az ugyanattól az alkalmazástól vagy webhelytől érkező értesítések egy pakliba rendeződnek, így egy fecsegős Slack-csatorna nem tolja le a képernyőről a build hibáját. Vidd az egeret egy pakli fölé a szétterítéséhez; amíg olvasol, semmi új nem csúszik be a mutatód alá. Kattints egy kártyára, hogy oda ugorj, ahonnan érkezett, a bezárásához pedig kattints jobb gombbal, középső gombbal, vagy kattints a ✕ gombra.

A kártyák azt kínálják, amit hordoznak: _Kód másolása_ az ellenőrző kódokhoz (ezek nem kerülnek be a [vágólapelőzményekbe](08-unified-clipboard-history.md), és egy perc után törlődnek), valamint minden olyan gombot, amit az alkalmazás biztosít. Az értesítés szövegében lévő hivatkozások kattintásra megnyílnak.

Ha egér nélkül használnád őket, nyomd meg a `Super + Ctrl + ,` billentyűkombinációt. A legújabb értesítés lesz kiválasztva, a gombjai pedig számozva jelennek meg: nyomj meg egy számot az egyik használatához, az `Enter` billentyűt az értesítésre kattintáshoz, a `↑` és `↓` billentyűt az értesítések közötti mozgáshoz, a `Delete` billentyűt az egyik bezárásához, az `Esc` billentyűt pedig ahhoz, hogy visszaadd a billentyűzetet. Néhány másodperc tétlenség után magától is elenged.

Az értesítések némítása visszatartja őket, kivéve az Omarchy saját megerősítéseit, a vészjelzéseket és az ellenőrző kódokat, amelyeket egy pillanattal ezelőtt kértél. Az utolsó néhányat — akár visszatartották őket, akár nem — a `Super + Shift + Alt + ,` billentyűkombinációval teheted vissza a képernyőre. Az előzmények egy napig maradnak meg.

## Gyorsbillentyűs értesítések

### Dátum és idő

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Időjárás

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

A helyet az IP-címed alapján határozza meg, ami általában elég pontos, de nem mindig. Rögzítheted a `omarchy weather location --set Malibu` paranccsal, vagy megadhatod pontosan koordináták hozzáadásával is: `omarchy weather location --set Malibu 34.0259,-118.7798`. Futtasd önmagában a `omarchy weather location` parancsot, hogy lásd, szerinte hol vagy, a `--clear` kapcsolóval pedig visszatérhetsz az automatikus felismeréshez.

### Akkumulátor

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
