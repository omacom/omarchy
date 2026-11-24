# Popularne modyfikacje

To zbiór popularnych dostosowań konfiguracji Omarchy. Pamiętaj, że aktualizacje systemu mogą czasami wymagać przywrócenia niektórych konfiguracji do ich pierwotnego stanu. Jeśli tak się stanie, Twoje zmiany nie przepadną, ale zostaną umieszczone w pliku `.bak.<timestamp>` obok oryginału.

Jeśli coś zepsujesz, możesz przywrócić poszczególne konfiguracje do ich pierwotnej wersji za pomocą _Aktualizacja > Konfiguracja_ w menu Omarchy. Jeśli *naprawdę* wszystko zepsujesz, możesz zresetować wszystkie konfiguracje za pomocą `omarchy reinstall configs` lub ponownie zainstalować każdy domyślny pakiet i konfigurację za pomocą `omarchy reinstall`.

### Pokazuj wszystkie ikony zasobnika przez cały czas

Domyślnie ikony zasobnika, takie jak Dropbox, 1password czy Steam, są ukryte za strzałką rozwijania zasobnika, która ujawnia je po najechaniu na nią. Jeśli chcesz, aby były odsłonięte przez cały czas, kliknij strzałkę rozwijania prawym przyciskiem myszy, aby otworzyć menedżera ikon zasobnika, a następnie przypnij ikony, które chcesz zachować jako widoczne (możesz też ukryć te, których nigdy nie chcesz widzieć).

### Zaokrąglone rogi okien

Domyślny wygląd Omarchy opiera się na prostokątnych rogach, ale jeśli chcesz to trochę złagodzić, wybierz _Wygląd > Okna > Rogi okien > Zaokrąglone rogi_ w menu Omarchy lub uruchom `omarchy hyprland corners rounded`. _Rogi motywu_ przywraca to, czego używa motyw. Aby wybrać własny promień, pozostań przy opcji _Rogi motywu_ (`omarchy hyprland corners theme`), ponieważ opcje Zaokrąglone i Ostre wczytują się po Twojej konfiguracji i ją nadpisują, i odkomentuj zaokrąglenie w `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Usuwanie odstępów między oknami

Na ekranach laptopów niektórzy wolą nie marnować żadnych pikseli na odstępy między oknami (ani nawet na pasek górny, który możesz wyłączyć za pomocą `Super + Shift + Space`). Możesz wyłączyć wszystkie odstępy i obramowania za pomocą `Super + Shift + Backspace` lub usunąć je na stałe, usuwając komentarze w tej sekcji pliku `~/.config/hypr/looknfeel.lua`:

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
