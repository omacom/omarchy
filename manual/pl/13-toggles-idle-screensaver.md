# Przełączniki, bezczynność i wygaszacz

Wiele z tego, co zmieniasz na co dzień, nie jest tak naprawdę ustawieniem. To tryb, który włączasz na godzinę i wyłączasz z powrotem: światło nocne, gdy pracujesz do późna, nie przeszkadzać, gdy prezentujesz, nieusypianie, gdy coś oglądasz. Omarchy nazywa je przełącznikami i wszystkie działają tak samo — skrót, wpis w menu i polecenie, wszystkie trafiające w ten sam przełącznik.

### Menu przełączników

`Super + Ctrl + O` otwiera _Akcje > Przełącz_ bezpośrednio, albo możesz dojść tam z menu Omarchy (`Super + Space`). Wszystko na tej liście to przełącznik, który możesz przełączyć bez zastanawiania się, gdzie mieszka stan. Przełączniki wyglądu pulpitu siedzą tuż obok, pod _Akcje > Wygląd_.

Z terminala te same przełączniki to `omarchy toggle <thing>`. Uruchom `omarchy toggle` samodzielnie, żeby zobaczyć całą grupę.

| Przełącznik | Skrót | Polecenie |
| ------ | ------ | ------- |
| Światło nocne | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| Wyciszenie powiadomień | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| Nieusypianie (brak blokady przy bezczynności) | `Super + Ctrl + I` | `omarchy toggle idle` |
| Rejestr awarii | — | `omarchy toggle crash-capture` |
| Wygaszacz | — | `omarchy toggle screensaver` |
| Synchronizacja motywu [Herdr](https://herdr.dev) | — | `omarchy toggle theme sync` |
| Pasek menu | `Super + Shift + Space` | `omarchy toggle bar` |
| Gładzik | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| Ekran dotykowy | — | `omarchy toggle touchscreen` |
| Uśpienie | — | `omarchy toggle suspend` |
| Hybrydowe GPU | — | `omarchy toggle hybrid gpu` |

Przełączniki gładzika, ekranu dotykowego i hybrydowego GPU mieszkają pod _Akcje > Sprzęt_ (`Super + Ctrl + H`), a nie pod Przełącz, bo pokazują się tylko, gdy faktycznie masz ten sprzęt. Przełączniki gładzika i ekranu dotykowego przetrwają przeładowanie Hyprland — nazwa wyłączonego urządzenia jest zapisywana do małego pliku stanu, który Hyprland czyta przy starcie, żeby wyłączyć je ponownie.

_Akcje > Wygląd_ mieści pasek menu i animacje oraz kilka rzeczy, które nie są poleceniami `omarchy toggle`, ale zachowują się tak samo: procent baterii na pasku, domyślny układ obszarów roboczych, odstępy okien (`Super + Shift + Backspace`) oraz kwadratowe proporcje 1 okna (`Super + Ctrl + Backspace`).

Większość z nich to po prostu plik flagi w `~/.local/state/omarchy/toggles/`. Jeśli chcesz się na którymś opierać w skrypcie, `omarchy-toggle-enabled` daje ci kod wyjścia zamiast zmuszać do poszukiwań:

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

Flagi są nazywane od stanu wyłączonego — `screensaver-off`, `suspend-off`, `bar-off` — więc ich obecność oznacza, że funkcja jest wyłączona.

### Wskaźniki na pasku

Gdy tryb jest włączony, dostajesz mały glif pośrodku górnego paska obok zegara. To widget wskaźników, który niesie dyktowanie, nagrywanie ekranu, oczekujące przypomnienia, światło nocne, nie przeszkadzać oraz nieusypianie.

Nieaktywne wskaźniki są ukryte. Najedź na obszar wokół nich, a pojawią się przygaszone, więc możesz kliknąć jeden, żeby go włączyć, nie znając jego skrótu. Kliknięcie aktywnego wyłącza go z powrotem. Jeśli wolisz widzieć je wszystkie przez cały czas, ustaw `alwaysShow` na `true` na wpisie `omarchy.indicators` w `~/.config/omarchy/shell.json` — zob. [górny pasek](05-the-top-bar.md), jak konfigurować widgety paska.

### Światło nocne

`Super + Ctrl + N` ociepla ekran do 4000K, a ponowne naciśnięcie przywraca 6500K. Napędza je hyprsunset, który przełącznik uruchamia dla ciebie, jeśli nie działa już wcześniej.

Domyślnie hyprsunset w ogóle nie rusza twojego ekranu. `~/.config/hypr/hyprsunset.conf` jest dostarczany z profilem tożsamościowym właśnie po to, aby ekran pozostał nietknięty, dopóki nie poprosisz o ciepło. Jeśli wolisz, żeby przełączał się według zegara, zastąp to profilem czasowym:

```
profile {
    time = 20:00
    temperature = 4000
}
```

Potem uruchamiaj hyprsunset przy logowaniu, dodając `o.launch_on_start("hyprsunset")` do `~/.config/hypr/autostart.lua`. Para 4000K/6500K używana przez przełącznik jest stała, więc jeśli chcesz innej temperatury, idziesz do pliku konfiguracyjnego.

### Nie przeszkadzać

`Super + Ctrl + ,` wycisza powiadomienia. Gdy jest włączone, nie wyskakują żadne powiadomienia, a wskaźnik przekreślonego dzwonka siedzi na pasku, żeby przypomnieć ci, dlaczego na pulpicie zapanowała cisza.

Nic jednak nie ginie. Wyciszone powiadomienie trafia prosto do historii powiadomień, a to dokładnie ten zapis, który chcesz mieć, gdy wracasz i zastanawiasz się, co cię ominęło. Otwórz ją przez `Super + Shift + Alt + ,`. Resztę opowieści o powiadomieniach znajdziesz w [powiadomienia informacyjne](10-notices.md).

Dwa rodzaje komunikatów nadal się przebijają: własne powiadomienia potwierdzające Omarchy dla czegoś, co właśnie zrobiłeś ("Theme changed", "Screenshot saved"), oraz krytyczne alerty wysłane z wiersza poleceń. Aplikacje czatowe, które oznaczają wszystko jako krytyczne, żeby włamać się przed ciebie, się nie kwalifikują.

### Bezczynność

Powłoka Omarchy zarządza zachowaniem przy bezczynności, a czasy znajdują się w bloku `idle` na poziomie głównym w `~/.config/omarchy/shell.json`:

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

Obie liczby to sekundy liczone od chwili przejścia w stan bezczynności — nie od siebie nawzajem. Przy wartościach domyślnych wygaszacz pojawia się więc po dwóch i pół minucie, a ekran blokady przejmuje po pięciu minutach, niezależnie od tego, czy wygaszacz się uruchomił. Zapisz plik, a powłoka od razu przejmie nowe czasy.

Jeśli odrzucisz wygaszacz przed terminem blokady, liczy się to jako aktywność i oczekująca blokada jest anulowana. Nie zostaniesz zablokowany za zerknięcie na maszynę.

Aby całkowicie przestać blokować przy bezczynności, `Super + Ctrl + I` — albo `omarchy toggle idle` — włącza nieusypianie, a na pasku pojawia się wskaźnik kubka kawy. To jest to, co nacisnąć przed długą prezentacją albo buildem, który chcesz oglądać. Naciśnij ponownie, żeby wrócić do normy. `omarchy toggle idle status` wypisuje bieżący stan jako JSON, jeśli potrzebujesz go ze skryptu.

Chodzi tu o blokowanie i wygaszacz, a nie o zasilanie. Uśpienie i hibernacja mają własną konfigurację w [uśpienie systemu](36-system-sleep.md).

### Wygaszacz

Wygaszacz Omarchy to sztuka ASCII przelatująca przez losowe efekty tekstowe, po jednej instancji na monitor. Każdy klawisz lub ruch myszy go wyłącza.

Możesz uruchomić go na żądanie z _System > Wygaszacz_ (`Super + Esc`), co wymusza go nawet, gdy wyłączyłeś wygaszacz przy bezczynności. Domyślnie nie ma przypisanego do niego skrótu.

`omarchy toggle screensaver` jest tym, co wyłącza ten przy bezczynności, jeśli wolisz przechodzić prosto od pracy do blokady. Potrzebuje terminala, który umie skonfigurować — Alacritty, Foot, Ghostty albo Kitty — i powie ci, jeśli twój domyślny terminal jest czymś innym.

Logo, które rysuje, jest twoje do zmiany pod _Styl > Wygaszacz_. Wgraj png lub svg, a Omarchy zamieni je na ASCII. Zob. [branding](41-branding.md).

### Ekran blokady

`Super + Ctrl + L` blokuje maszynę. Uruchamia to ekran blokady z powłoki Omarchy, wygasza ekran, resetuje układ klawiatury do pierwszego, żebyś nie wpisywał hasła w złym alfabecie, i — jeśli masz je uruchomione — po drodze blokuje 1Password.

Ekran blokady przyjmuje hasło, a po konfiguracji przyjmie też odcisk palca. To oraz pozostałe sposoby uwierzytelniania są opisane w [uwierzytelnianie sprzętowe](37-hardware-authentication.md).
