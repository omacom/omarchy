# Komunikaty

Powiadomienia lądują w prawym górnym rogu aktywnego ekranu. Za pomocą komunikatów skrótów klawiszowych możesz też szybko sprawdzić datę i godzinę, stan baterii oraz bieżącą pogodę.

## Powiadomienia

Powiadomienia z tej samej aplikacji lub witryny układają się w stos, więc gadatliwy kanał na Slacku nie zepchnie z ekranu informacji o nieudanym buildzie. Najedź na stos, aby go rozłożyć; nic nowego nie wślizgnie się pod wskaźnik, gdy czytasz. Kliknij kartę, aby przejść do miejsca, z którego pochodzi, kliknij prawym przyciskiem myszy, kliknij środkowym przyciskiem myszy lub naciśnij ✕, aby ją odrzucić.

Karty oferują to, co niosą: _Copy code_ dla kodów weryfikacyjnych (przechowywanych poza [historią schowka](08-unified-clipboard-history.md) i czyszczonych po minucie) oraz wszystkie przyciski udostępniane przez aplikację. Linki w tekście powiadomienia otwierają się po kliknięciu.

`Super + ,` odrzuca najnowsze powiadomienie lub otwiera to, na co wskazuje, gdy oferuje taką możliwość, `Super + Alt + ,` odrzuca tylko ostatnie, `Super + Shift + ,` odrzuca wszystkie, a `Super + Shift + Alt + ,` otwiera historię. Aby korzystać z nich bez myszy, naciśnij `Super + Ctrl + ,`. Zostanie zaznaczone najnowsze powiadomienie, a jego przyciski zostaną ponumerowane: naciśnij numer, aby użyć jednego z nich, `Enter`, aby kliknąć powiadomienie, `↑` i `↓`, aby przechodzić między powiadomieniami, `Delete`, aby odrzucić jedno, oraz `Esc`, aby oddać klawiaturę. Odda ją też samo po kilku sekundach bezczynności.

Wyciszenie powiadomień wstrzymuje je, z wyjątkiem własnych potwierdzeń Omarchy, alertów alarmowych i kodów weryfikacyjnych, o które przed chwilą prosiłeś. Wyświetl kilka ostatnich ponownie na ekranie — wstrzymanych lub nie — za pomocą `Super + Shift + Alt + ,`. Historia jest przechowywana przez jeden dzień.

## Komunikaty skrótów klawiszowych

### Data i godzina

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Pogoda

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Lokalizacja jest wykrywana na podstawie Twojego adresu IP, co zwykle jest wystarczająco dokładne, ale nie zawsze. Możesz ją doprecyzować poleceniem `omarchy weather location --set Malibu` lub podać dokładne współrzędne: `omarchy weather location --set Malibu 34.0259,-118.7798`. Uruchom samo `omarchy weather location`, aby zobaczyć, gdzie według systemu jesteś, oraz `--clear`, aby wrócić do automatycznego wykrywania.

### Bateria

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
