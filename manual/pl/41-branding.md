# Personalizacja marki

Omarchy pozwala ustawić logo twojej firmy albo osobisty obraz zarówno dla odblokowywania przy rozruchu, wygaszacza ekranu, jak i ekranu informacji.

### Odblokowywanie przy rozruchu

Możesz użyć `omarchy plymouth preview`, aby zobaczyć, jak wyglądałyby twoje niestandardowe logo i kolory. Polecenie przyjmuje kolor tła, kolor tekstu, logo w formacie png i ścieżkę obrazu podglądu:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Potem zastosuj konfigurację poleceniem `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, które nada też ekranowi logowania SDDM te same kolory i logo. Jeśli chcesz to wycofać, możesz użyć `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Wygaszacz ekranu

Logo używane przez wygaszacz ekranu możesz zmienić w _Styl > Wygaszacz_. To logo ASCII, więc możesz edytować tekst wprost, ale możesz też podać mu obraz png albo svg, a my przekonwertujemy go na ASCII. Wygląda naprawdę fajnie.

 ![branding-screensaver](images/branding-screensaver.webp)

W tym menu są trzy pozycje:

- **Edytuj tekst** otwiera `~/.config/omarchy/branding/screensaver.txt` w twoim edytorze. Wpisz albo wklej, co chcesz — grafikę ASCII, swoje imię, niecenzuralne słowo. Zapisz i wyjdź, a wygaszacz od razu się uruchomi, żebyś mógł to zobaczyć.
- **Ustaw z obrazu** otwiera wybór pliku dla png albo svg, konwertuje go na ASCII i pokazuje ci wynik. Logotypy o wyraźnej sylwetce działają znacznie lepiej niż zdjęcia.
- **Przywróć domyślne** przywraca logo Omarchy.

### Ekran informacji

Te same trzy opcje są w _Styl > Informacje_ dla ekranu _Informacje_, który dostajesz z menu Omarchy, i działają identycznie — plik to `~/.config/omarchy/branding/about.txt`, a okno Informacje wyskakuje po każdej zmianie. Grafika Informacje jest konwertowana do mniejszego rozmiaru niż grafika wygaszacza, bo musi zmieścić się w oknie, zamiast wypełniać cały wyświetlacz.

Gdy okno jest otwarte, błysk zieleni przechyla się przez grafikę co kilka sekund, a potem znów zostawia ją w bezruchu. Twoja własna grafika też go dostaje, o ile każdy znak w niej ma szerokość jednej kolumny — a wszystko, co produkuje _Ustaw z obrazu_, taki właśnie jest. Grafika zbudowana z emoji albo znaków o podwójnej szerokości pozostaje za to nieruchoma, podobnie jak ekran, jeśli zachowasz własną konfigurację fastfetch: nieruchome logo w tych przypadkach oznacza, że animacja schodzi z drogi, a nie że zawodzi, bo przesunięcie błysku przez takie grafiki ustawiłoby resztę wiersza w złym miejscu.

 ![branding-about](images/branding-about.webp)

### Samodzielna konwersja obrazów

Obie opcje _Ustaw z obrazu_ po prostu wywołują `omarchy transcode ascii`, które możesz uruchomić wprost, jeśli chcesz mieć kontrolę nad konwersją:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Przyjmuje `--width` i `--height` w kolumnach i wierszach terminala, `--mode` o wartości `braille` (domyślny i znacznie dokładniejszy) albo `block`, procent `--threshold` decydujący, które piksele liczą się jako część logo, oraz `--invert` na przypadek, gdy twoje logo jest jasne na ciemnym tle. Jeśli konwersja wychodzi jako plama, zwykle to właśnie próg jest pokrętłem, którym trzeba pokręcić.

### Słowa zamiast logo

`omarchy ascii` rysuje tekst krojem Delta Corps Priest 1, krojem FIGlet, którym narysowany jest sam znak słowny Omarchy, więc wygaszacz może coś mówić, zamiast pokazywać obrazek:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Przyjmuje tekst jako argumenty albo czyta go z potoku, gdy nie podano żadnego. Krój zawiera tylko litery i spacje — narysowano go bez cyfr i znaków interpunkcyjnych — więc wszystko inne jest odrzucane i nazywane na stderr, zamiast być po cichu połykane.
