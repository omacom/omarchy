# Klawiatura, mysz, gładzik

Hyprland pozwala szczegółowo skonfigurować wszystkie urządzenia wejściowe. Możesz ustawić powtarzanie klawiszy na naddźwiękowo szybkie albo sprawić, by gładzik używał przewijania naturalnego. Wszystko to zmienisz w `~/.config/hypr/input.lua`, do którego dotrzesz też przez _Konfiguracja > Urządzenia wejściowe_ w menu Omarchy (`Super + Space`). Wszystko, co tam ustawisz, zastępuje domyślne ustawienia Omarchy.

Oto przykład:

```lua
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,dk",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",

    -- Change speed of keyboard repeat
    repeat_rate = 40,
    repeat_delay = 600,

    -- Increase sensitivity for mouse/trackpad (default: 0)
    sensitivity = 0.35,

    touchpad = {
      -- Use natural (inverse) scrolling
      natural_scroll = true,

      -- Use two-finger clicks for right-click instead of lower-right corner
      clickfinger_behavior = true,

      -- Control the speed of your scrolling
      scroll_factor = 0.3,
    },
  },
})

-- Scroll faster in the terminal
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
```

Możesz [zobaczyć wszystkie opcje urządzeń wejściowych](https://wiki.hypr.land/Configuring/Basics/Variables/#input) na wiki Hyprland poświęconej urządzeniom wejściowym.

CapsLock działa jak normalny Caps Lock, a `Shift + CapsLock` to klawisz compose do [szybkich emoji](07-hotkeys.md#quick-emojis) i [innych uzupełnień](07-hotkeys.md#quick-completions). Jeśli wolisz mieć klawisz compose gdzie indziej, zastąp `omarchy:shift_caps_compose` w `kb_options`. Ten przykład przenosi klawisz compose na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gesty gładzika

Przesuń palce po gładziku, aby poruszać się po pulpicie:

| Gest | Czynność |
| --- | --- |
| Trzy palce w lewo / w prawo | Poprzedni / następny obszar roboczy, w tym puste |
| Trzy palce w górę | Przełącz konsolę AI |
| Trzy palce w dół | Otwórz menu Omarchy |
| Cztery palce w lewo / w prawo | Przenieś aktywne okno do poprzedniego / następnego obszaru roboczego |
| Cztery palce w dół | Przełącz tryb pełnoekranowy |

Aby zmienić jeden z nich, wyłącz go w `~/.config/hypr/input.lua`, zanim dodasz własny [gest gładzika](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), ponieważ Hyprland nie przyjmie dwóch gestów na tę samą liczbę palców i ten sam kierunek:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Aby wyłączyć wszystkie gesty Omarchy, ustaw `omarchy_default_gestures = false` blisko początku pliku `~/.config/hypr/hyprland.lua`, zanim wczytają się domyślne ustawienia Omarchy.

Na laptopach Dell XPS z haptycznym gładzikiem możesz też ustawić siłę kliknięcia na niską, średnią lub wysoką w _Wyzwalacz > Sprzęt > Haptyka gładzika_.

### Pisanie po chińsku, japońsku i w innych językach

Wybierz język japoński, koreański, chiński (uproszczony, Pinyin), tajwański (Zhuyin) lub hongkoński (Cangjie), gdy instalator zapyta o klawiaturę. Omarchy automatycznie konfiguruje klawiaturę i pasujący silnik wprowadzania, także podczas wstępnej konfiguracji offline przy pierwszym uruchomieniu. Język japoński używa Mozc, koreański używa standardowego dwuzestawowego Hangul, chiński uproszczony używa Pinyin, Tajwan używa standardowego układu Zhuyin z Chewing, a Hongkong używa Cangjie z hongkońskimi formami znaków. Japoński (klawiatura US) zapewnia Mozc z amerykańskim układem klawiatury. Klawisze Hangul, Zhuyin i Cangjie pozostają na standardowych pozycjach, nawet gdy piszesz litery łacińskie przy użyciu Dvorak, Colemak lub AZERTY. Jeśli dodałeś wcześniej Hangul lub Chewing, odznacz je i ponownie zaznacz w _Konfiguracja > Pisanie > Metody wprowadzania_, aby przenieść ich klawisze w te miejsca; Omarchy zostawia w spokoju silnik, którego już używasz do pisania.

Pisanie zaczyna się w trybie łacińskim. Naciśnij `Super + I`, aby przechodzić cyklicznie przez skonfigurowane metody wprowadzania, a `Super + Shift + I`, aby przechodzić w odwrotną stronę. Naciśnij sam `Shift`, aby wyjść z metody wprowadzania takiej jak Pinyin do liter łacińskich, i naciśnij go ponownie, aby wrócić, tak jak działają Sogou, Microsoft Pinyin i macOS; `Shift` plus litera nadal pisze wielką literę. Na klawiaturach japońskich 全角/半角 przełącza wprowadzanie, 変換 włącza je, a 無変換 wyłącza je. W języku koreańskim 한/영 przełącza Hangul, a 한자 konwertuje na Hanja, niezależnie od tego, czy klawiatura ma dedykowane klawisze, czy wysyła w ich zastępstwie Right Alt i Right Ctrl, jak robi to wiele laptopów, więc Right Alt i Right Ctrl nie są tam zwykłymi modyfikatorami; zamiast tego dyktowanie przełącza się za pomocą Alt + Space. `Ctrl + Space` pozostaje dostępny dla Tmux i Herdr; `Shift + CapsLock` pozostaje klawiszem compose.

Wskaźnik klawiatury pojawia się po prawej stronie paska, gdy masz wiele układów klawiatury lub metod wprowadzania. Kliknij go, aby przełączać języki wprowadzania; język japoński wyświetla あ dla hiragany. Aby wybrać japońskie znaki, przełącz na język japoński, wpisz słowo takie jak `nihongo`, a następnie naciśnij Space dwa razy. Naciśnij Enter, aby zaakceptować wybór. Jeśli masz też wiele układów klawiatury, kliknij wskaźnik prawym przyciskiem myszy, aby przechodzić między nimi cyklicznie.

Użyj _Konfiguracja > Pisanie > Układy klawiatury_, aby wybrać układy takie jak angielski i francuski, spośród tych samych opcji oferowanych podczas instalacji. Użyj _Konfiguracja > Pisanie > Metody wprowadzania_, aby wybrać, które silniki kompozycji są aktywne. Oba selektory otwierają się wewnątrz menu Omarchy z zaznaczonymi bieżącymi wyborami. Kliknij lub naciśnij Enter, aby przełączyć wybór; każda zmiana obowiązuje natychmiast. Odznaczenie metody wprowadzania usuwa ją z cyklu bez jej odinstalowywania; klawiatura pozostaje dostępna.

Uruchom `omarchy setup keyboard` lub `omarchy setup input`, aby otworzyć te same selektory. Aby dodać jeden język z wiersza poleceń, użyj `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` lub `cangjie5`. Quick, Boshiamy i Array są dostarczane w tym samym pakiecie co Cangjie i pojawiają się w selektorze metod wprowadzania. Twoje niestandardowe klawisze przełączania zostają zachowane. Aby ustawić alternatywne układy lub klawisze silników, zainstaluj `fcitx5-configtool` za pomocą `omarchy pkg add fcitx5-configtool` i uruchom go z terminala. Wybranie języka wprowadzania nie zmienia języka pulpitu. Wybranie języka japońskiego, koreańskiego lub chińskiego w _Konfiguracja > Język_ dodaje jego metodę wprowadzania, gdy nie masz jeszcze żadnej.

Użyj `Super + I`, aby przechodzić cyklicznie przez metody wprowadzania lub układy klawiatury, a `Super + Shift + I`, aby wracać w drugą stronę, więc przy trzech skonfigurowanych możesz poruszać się między dwoma sąsiadami. Wskaźnik wprowadzania pojawia się po prawej stronie paska tylko wtedy, gdy skonfigurowano więcej niż jedną metodę wprowadzania lub układ. To powiązanie pulpitu działa obok istniejących klawiszy przełączania Fcitx; możesz je nadpisać w `~/.config/hypr/bindings.lua`. Silniki wprowadzania i sekwencje compose korzystają z usługi [Fcitx5](https://fcitx-im.org/), która już działa w każdej sesji.

### Użyj ALT jako SUPER

Na niektórych klawiaturach używanie głównego klawisza meta (klawisza Windows/cmd) jako SUPER nie jest wygodne. Możesz zamiast tego zmienić go na ALT, wprowadzając tę zmianę:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
