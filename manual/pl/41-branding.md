# Branding

Omarchy pozwala ustawić logo Twojej firmy lub osobisty obraz zarówno na ekranie odblokowywania przy rozruchu, w wygaszaczu ekranu, jak i na ekranie About.

### Odblokowywanie przy rozruchu

Możesz użyć `omarchy plymouth preview`, aby zobaczyć, jak wyglądałoby Twoje własne logo i kolory. Polecenie przyjmuje kolor tła, kolor tekstu, logo w formacie png oraz ścieżkę obrazu podglądu:

```
omarchy plymouth preview '#1d2021' '#ebdbb2' logo.png preview.png
```

Następnie zastosuj konfigurację poleceniem `omarchy plymouth set '#1d2021' '#ebdbb2' logo.png`, które nada ekranowi logowania SDDM te same kolory i logo. Jeśli chcesz to cofnąć, możesz użyć `omarchy plymouth reset`.

 ![branding-plymouth-shopify](images/branding-plymouth-shopify.webp)

### Wygaszacz ekranu

Logo używane w wygaszaczu ekranu możesz zmienić w _Appearance > Branding > Screensaver_. To logo ASCII, więc możesz bezpośrednio edytować tekst, ale możesz też podać mu obraz png lub svg, a my przekonwertujemy go do ASCII. Wygląda to całkiem nieźle.

 ![branding-screensaver](images/branding-screensaver.webp)

W tym menu znajdują się trzy pozycje:

- **Edit Text** otwiera `~/.config/omarchy/branding/screensaver.txt` w Twoim edytorze. Wpisz lub wklej, co tylko chcesz — grafikę ASCII, swoje imię, nieprzyzwoite słowo. Zapisz i zamknij, a wygaszacz ekranu od razu się uruchomi, żebyś mógł go zobaczyć.
- **Set From Image** otwiera okno wyboru pliku png lub svg, konwertuje go do ASCII i pokazuje Ci wynik. Loga o wyraźnej sylwetce działają znacznie lepiej niż zdjęcia.
- **Restore Default** przywraca logo Omarchy.

### Ekran About

Te same trzy opcje znajdują się w _Appearance > Branding > About_ dla ekranu _About_, który otwierasz z menu Omarchy, i działają identycznie — plik to `~/.config/omarchy/branding/about.txt`, a okno About pojawia się po każdej zmianie. Grafika About jest konwertowana do mniejszego rozmiaru niż grafika wygaszacza ekranu, ponieważ musi zmieścić się w oknie, a nie wypełniać cały ekran.

Gdy okno jest otwarte, co kilka sekund przez grafikę przechyla się pasmo jasnego, białego światła, a potem znów pozostawia ją w bezruchu. Twoja własna grafika też je otrzyma, o ile każdy znak w niej ma szerokość jednej kolumny — a każda grafika utworzona przez _Set From Image_ taką ma. Grafika zbudowana z emoji lub znaków o podwójnej szerokości pozostaje natomiast nieruchoma, podobnie jak ekran, jeśli zachowasz własną konfigurację fastfetch: nieruchome logo w tych przypadkach oznacza, że animacja trzyma się z daleka, a nie że coś się nie udało, ponieważ przesunięcie błysku przez takie znaki umieściłoby resztę wiersza w niewłaściwym miejscu.

 ![branding-about](images/branding-about.webp)

### Samodzielna konwersja obrazów

Obie opcje _Set From Image_ po prostu wywołują `omarchy transcode ascii`, które możesz uruchomić bezpośrednio, jeśli chcesz mieć kontrolę nad konwersją:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Przyjmuje ono `--width` i `--height` w kolumnach i wierszach terminala, `--mode` o wartości `braille` (domyślnej i znacznie dokładniejszej) lub `block`, `--threshold` jako wartość procentową decydującą, które piksele liczą się jako część logo, oraz `--invert` na wypadek, gdy Twoje logo jest jasne na ciemnym tle. Jeśli konwersja wychodzi jako plama, zwykle trzeba pokręcić właśnie progiem.

### Słowa zamiast logo

`omarchy ascii` rysuje tekst czcionką Delta Corps Priest 1, czcionką FIGlet, którą narysowano sam znak słowny Omarchy, więc wygaszacz ekranu może coś mówić, zamiast pokazywać obraz:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Przyjmuje tekst jako argumenty lub odczytuje go z potoku, gdy nie podano żadnych. Czcionka zawiera wyłącznie litery i spacje — narysowano ją bez cyfr i znaków interpunkcyjnych — więc wszystko inne jest odrzucane i wymieniane na stderr, zamiast po cichu znikać.
