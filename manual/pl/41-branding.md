# Branding

Omarchy pozwala ustawić logo firmy lub osobisty obraz zarówno dla odblokowania podczas rozruchu, wygaszacza ekranu, jak i ekranu About.

### Odblokowanie podczas rozruchu

Możesz użyć `omarchy plymouth preview`, aby zobaczyć, jak wyglądałyby Twoje własne logo i kolory. Przyjmuje kolor tła, kolor tekstu, logo w formacie png oraz ścieżkę obrazu podglądu:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Następnie zastosuj konfigurację poleceniem `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, które nada te same kolory i logo również ekranowi logowania SDDM. Jeśli chcesz to cofnąć, możesz użyć `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Wygaszacz ekranu

Logo używane przez wygaszacz ekranu możesz zmienić w _Appearance > Branding > Screensaver_. To logo ASCII, więc możesz bezpośrednio edytować tekst, ale możesz też podać mu obraz png lub svg, a my przekonwertujemy go do ASCII. Wygląda to całkiem fajnie.

 ![branding-screensaver](images/branding-screensaver.webp)

W tym menu są trzy pozycje:

- **Edit Text** otwiera `~/.config/omarchy/branding/screensaver.txt` w Twoim edytorze. Wpisz lub wklej, co tylko chcesz — grafikę ASCII, swoje imię, nieprzyzwoite słowo. Zapisz i wyjdź, a wygaszacz ekranu od razu się uruchomi, żebyś mógł go zobaczyć.
- **Set From Image** otwiera selektor plików dla png lub svg, konwertuje go do ASCII i pokazuje Ci wynik. Logo o wyraźnej sylwetce sprawdzają się znacznie lepiej niż zdjęcia.
- **Restore Default** przywraca logo Omarchy.

### Ekran About

Te same trzy opcje znajdują się w _Appearance > Branding > About_ dla ekranu _About_, który uzyskujesz z menu Omarchy, i działają identycznie — plik to `~/.config/omarchy/branding/about.txt`, a okno About wyskakuje po każdej zmianie. Grafika About jest konwertowana do mniejszego rozmiaru niż grafika wygaszacza ekranu, ponieważ musi zmieścić się w oknie, a nie wypełnić cały wyświetlacz.

Gdy okno jest otwarte, zielony błysk przesuwa się po grafice co kilka sekund, a potem znów pozostawia ją nieruchomą. Twoja własna grafika też go dostaje, o ile każdy znak w niej ma szerokość jednej kolumny — a wszystko, co tworzy _Set From Image_, taką ma. Grafika zbudowana z emoji lub znaków o podwójnej szerokości pozostaje natomiast nieruchoma, podobnie jak ekran, jeśli masz własną konfigurację fastfetch: nieruchome logo w tych przypadkach oznacza, że animacja ustępuje z drogi, a nie że coś się nie powiodło, ponieważ przesunięcie błysku po nich umieściłoby resztę wiersza w niewłaściwym miejscu.

 ![branding-about](images/branding-about.webp)

### Samodzielne konwertowanie obrazów

Obie opcje _Set From Image_ po prostu wywołują `omarchy transcode ascii`, które możesz uruchomić bezpośrednio, jeśli chcesz mieć kontrolę nad konwersją:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Przyjmuje `--width` i `--height` w kolumnach i wierszach terminala, `--mode` o wartości `braille` (domyślna i znacznie drobniejsza) albo `block`, procentową wartość `--threshold` decydującą o tym, które piksele liczą się jako część logo, oraz `--invert` na wypadek, gdy Twoje logo jest jasne na ciemnym tle. Jeśli konwersja wyjdzie jako plama, pokrętłem, którym zwykle warto kręcić, jest threshold.

### Słowa zamiast logo

`omarchy ascii` rysuje tekst fontem Delta Corps Priest 1, fontem FIGlet, którym narysowany jest sam znak słowny Omarchy, więc wygaszacz ekranu może coś mówić, zamiast pokazywać obrazek:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Przyjmuje tekst jako argumenty albo odczytuje go z potoku, gdy nie podano żadnego. Font zawiera tylko litery i spacje — został narysowany bez cyfr i znaków interpunkcyjnych — więc wszystko inne jest odrzucane i wymieniane na stderr, zamiast po cichu znikać.
