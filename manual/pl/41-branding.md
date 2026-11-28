# Branding

Omarchy pozwala ustawić logo firmy lub osobisty obraz zarówno dla wygaszacza ekranu, jak i dla ekranu Informacje.

### Wygaszacz ekranu

Logo używane przez wygaszacz ekranu możesz zmienić w _Wygląd > Branding > Wygaszacz ekranu_. To logo w ASCII, więc możesz bezpośrednio edytować tekst, ale możesz też podać mu obraz png lub svg, a my przekonwertujemy go na ASCII. Wygląda to naprawdę fajnie.

 ![branding-screensaver](images/branding-screensaver.webp)

W tym menu są trzy pozycje:

- **Edytuj tekst** otwiera `~/.config/omarchy/branding/screensaver.txt` w twoim edytorze. Wpisz lub wklej, co tylko chcesz — grafikę ASCII, swoje imię, nieprzyzwoite słowo. Zapisz i zamknij, a wygaszacz ekranu od razu się uruchomi, żebyś mógł to zobaczyć.
- **Ustaw z obrazu** otwiera okno wyboru pliku png lub svg, konwertuje go na ASCII i pokazuje ci wynik. Loga o wyraźnej sylwetce działają znacznie lepiej niż zdjęcia.
- **Przywróć domyślne** przywraca logo Omarchy.

### Ekran Informacje

Te same trzy opcje znajdziesz w _Wygląd > Branding > Informacje_ dla ekranu _Informacje_, który otwierasz z menu Omarchy, i działają identycznie — plik to `~/.config/omarchy/branding/about.txt`, a okno Informacje pojawia się po każdej zmianie. Grafika na ekran Informacje jest konwertowana do mniejszego rozmiaru niż grafika wygaszacza ekranu, ponieważ musi zmieścić się w oknie, a nie wypełniać cały ekran.

Gdy okno jest otwarte, co kilka sekund przez grafikę przechyla się smuga jasnego, białego światła, a potem znów zostawia ją nieruchomą. Twoja własna grafika też dostaje ten efekt, o ile każdy znak w niej ma szerokość jednej kolumny — a wszystko, co tworzy _Ustaw z obrazu_, właśnie takie jest. Grafika zbudowana z emoji lub znaków o podwójnej szerokości zamiast tego pozostaje nieruchoma, podobnie jak ekran, jeśli zachowasz własną konfigurację fastfetch: nieruchome logo w tych przypadkach oznacza, że animacja trzyma się z dala, a nie że coś się nie udało, ponieważ przesunięcie błysku po takiej grafice sprawiłoby, że reszta linii wylądowałaby w niewłaściwym miejscu.

 ![branding-about](images/branding-about.webp)

### Samodzielne konwertowanie obrazów

Obie opcje _Ustaw z obrazu_ po prostu wywołują `omarchy transcode ascii`, które możesz uruchomić bezpośrednio, jeśli chcesz mieć kontrolę nad konwersją:

```
omarchy transcode ascii ~/logo.svg ~/.config/omarchy/branding/screensaver.txt --width 100
```

Przyjmuje `--width` i `--height` w kolumnach i wierszach terminala, `--mode` o wartości `braille` (domyślnej i znacznie dokładniejszej) lub `block`, `--threshold` w procentach, decydujący o tym, które piksele liczą się jako część logo, oraz `--invert` na wypadek, gdy twoje logo jest jasne na ciemnym tle. Jeśli konwersja wyjdzie jako plama, zwykle to właśnie próg warto dostroić.

### Słowa zamiast logo

`omarchy ascii` rysuje tekst czcionką Delta Corps Priest 1, czcionką FIGlet, którą narysowano sam znak słowny Omarchy, więc wygaszacz ekranu może coś powiedzieć, zamiast pokazywać obraz:

```
omarchy ascii "Back in five" > ~/.config/omarchy/branding/screensaver.txt
```

Przyjmuje tekst jako argumenty lub odczytuje go z potoku, gdy nie podano żadnego. Czcionka zawiera tylko litery i spacje — narysowano ją bez cyfr i znaków interpunkcyjnych — więc wszystko inne jest odrzucane i wypisywane z nazwy na stderr, a nie po cichu połykane.
