# Powiadomienia

Powiadomienia lądują w prawym górnym rogu aktywnego ekranu. Możesz też szybko sprawdzić datę i godzinę, stan baterii oraz bieżącą pogodę za pomocą powiadomień na skróty klawiszowe.

## Powiadomienia

Powiadomienia z tej samej aplikacji lub witryny układają się w stos, więc gadatliwy kanał Slack nie zepchnie z ekranu informacji o niepowodzeniu kompilacji. Najedź kursorem na stos, aby go rozłożyć; nic nowego nie wsuwa się pod wskaźnik, gdy czytasz. Kliknij kartę, aby przejść do miejsca, z którego pochodzi, kliknij prawym przyciskiem, środkowym przyciskiem lub naciśnij ✕, aby ją odrzucić.

Karty oferują to, co zawierają: _Kopiuj kod_ dla kodów weryfikacyjnych (przechowywanych poza [historią schowka](08-unified-clipboard-history.md) i czyszczonych po minucie) oraz wszelkie przyciski dostarczone przez aplikację. Linki w tekście powiadomienia otwierają się po kliknięciu.

Aby używać ich bez myszy, naciśnij `Super + Ctrl + ,`. Najnowsze powiadomienie jest zaznaczone, a jego przyciski ponumerowane: naciśnij numer, aby użyć jednego z nich, `Enter`, aby kliknąć powiadomienie, `↑` i `↓`, aby przechodzić między powiadomieniami, `Delete`, aby odrzucić jedno, oraz `Esc`, aby oddać klawiaturę. Po kilku sekundach bezczynności samo ustępuje.

Wyciszenie powiadomień wstrzymuje je, z wyjątkiem własnych potwierdzeń Omarchy, alertów awaryjnych i kodów weryfikacyjnych, o które prosiłeś przed chwilą. Wyświetl ponownie ostatnie kilka powiadomień, wstrzymanych lub nie, za pomocą `Super + Shift + Alt + ,`. Historia jest przechowywana przez jeden dzień.

## Powiadomienia na skróty klawiszowe

### Data i godzina

`Super + Ctrl + Alt + T`

 ![notice-datetime](images/notice-datetime.webp)

### Pogoda

`Super + Ctrl + Alt + W`

 ![notice-weather](images/notice-weather.webp)

Lokalizacja jest wykrywana na podstawie Twojego adresu IP, co zazwyczaj jest wystarczająco dokładne, ale nie zawsze. Możesz ją doprecyzować za pomocą `omarchy weather location --set Malibu` lub określić dokładnie, dodając współrzędne: `omarchy weather location --set Malibu 34.0259,-118.7798`. Uruchom samo `omarchy weather location`, aby zobaczyć, gdzie jego zdaniem się znajdujesz, oraz `--clear`, aby wrócić do automatycznego wykrywania.

### Bateria

`Super + Ctrl + Alt + B`

 ![notice-battery](images/notice-battery.webp)
