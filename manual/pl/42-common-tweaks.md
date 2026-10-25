# Typowe dostosowania

To zbiór typowych dostosowań konfiguracji Omarchy. Wiedz, że aktualizacje systemu mogą czasem wymagać przywrócenia niektórych konfiguracji do ich pierwotnego stanu. Jeśli tak się stanie, twoje zmiany nie przepadną, tylko trafią do pliku `.bak` w tym samym katalogu.

Jeśli coś zepsujesz, możesz przywrócić poszczególne konfiguracje do ich pierwotnego stanu przez _Aktualizuj > Konfiguracja_ w menu Omarchy. Jeśli _naprawdę_ zepsujesz wszystko, możesz zresetować wszystkie konfiguracje poleceniem `omarchy-reinstall`.

### Pokazywanie wszystkich ikon zasobnika przez cały czas

Domyślnie ikony zasobnika, takie jak Dropbox, 1password albo Steam, są ukryte za strzałką rozwijania zasobnika, która odsłania je, gdy na nią najedziesz. Jeśli chcesz mieć je odsłonięte przez cały czas, kliknij strzałkę rozwijania prawym przyciskiem myszy, aby otworzyć menedżera ikon zasobnika, a potem przypnij ikony, które chcesz zachować widoczne (możesz też ukryć te, których nigdy nie chcesz widzieć).

### Zaokrąglone narożniki okien

Domyślny wygląd Omarchy opiera się na prostych narożnikach, ale jeśli chcesz go trochę zmiękczyć, możesz zmienić `~/.config/hypr/looknfeel.lua` tak, aby zaokrąglenie nie było już zakomentowane:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Usuwanie odstępów między oknami

Na ekranach laptopów niektórzy wolą nie marnować żadnych pikseli na odstępy między oknami (ani nawet na pasek menu, który możesz wyłączyć skrótem `Super + Shift + Space`). Wszystkie odstępy i obramowania możesz wyłączyć skrótem `Super + Shift + Backspace` albo usunąć je na stałe, usuwając komentarze w tej sekcji pliku `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
  },
})
```
