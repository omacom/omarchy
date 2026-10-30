# Klawiatura, mysz, trackpad

Hyprland pozwala skonfigurować wszystkie urządzenia wejściowe w najdrobniejszych szczegółach. Możesz sprawić, że powtarzanie klawiszy będzie naddźwiękowo szybkie, albo ustawić trackpad na naturalne przewijanie. Wszystko to zmieniasz w `~/.config/hypr/input.lua`, do którego możesz też dotrzeć przez _Setup > Input_ w menu Omarchy (`Super + Space`). Wszystko, co tam ustawisz, zastępuje wartości domyślne Omarchy.

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

Możesz [zobaczyć wszystkie opcje wejścia](https://wiki.hypr.land/Configuring/Basics/Variables/#input) na wiki Hyprland poświęconej wejściom.

CapsLock działa jak zwykły Caps Lock, a `Shift + CapsLock` to klawisz compose do [szybkich emotikonów](07-hotkeys.md#quick-emojis) i [innych uzupełnień](07-hotkeys.md#quick-completions). Jeśli wolisz mieć klawisz compose gdzie indziej, zamień `omarchy:shift_caps_compose` w `kb_options`. Na przykład tak przeniesiesz klawisz compose na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gesty trackpada

Przesuń palcami po trackpadzie, aby poruszać się po pulpicie:

| Gest | Akcja |
| --- | --- |
| Trzy palce w lewo / w prawo | Poprzedni / następny obszar roboczy, w tym puste |
| Trzy palce w górę | Przełącz konsolę AI |
| Trzy palce w dół | Otwórz menu Omarchy |
| Cztery palce w lewo / w prawo | Przenieś aktywne okno na poprzedni / następny obszar roboczy |
| Cztery palce w dół | Przełącz pełny ekran |

Aby zmienić jeden z nich, najpierw usuń go w `~/.config/hypr/input.lua`, zanim dodasz własny [gest trackpada](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), ponieważ Hyprland nie przyjmie dwóch gestów na tych samych palcach i w tym samym kierunku:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Aby wyłączyć wszystkie gesty Omarchy, ustaw `omarchy_default_gestures = false` blisko początku `~/.config/hypr/hyprland.lua`, zanim załadują się wartości domyślne Omarchy.

W laptopach Dell XPS z haptycznym touchpadem możesz też ustawić siłę kliknięcia na niską, średnią lub wysoką w _Trigger > Hardware > Touchpad Haptics_.

### Pisanie po chińsku, japońsku i w innych językach

Wybierz japoński, koreański, chiński (uproszczony, Pinyin), Tajwan (Zhuyin) lub Hongkong (Cangjie), gdy instalator zapyta o klawiaturę. Omarchy automatycznie konfiguruje klawiaturę i dopasowany silnik wprowadzania, także podczas konfiguracji offline przy pierwszym uruchomieniu. Japoński używa Mozc, koreański używa standardowego dwuzestawowego Hangul, chiński uproszczony używa Pinyin, Tajwan używa standardowego układu Zhuyin z Chewing, a Hongkong używa Cangjie z hongkońskimi formami znaków. Japoński (klawiatura US) zapewnia Mozc z amerykańskim układem klawiatury. Klawisze Hangul, Zhuyin i Cangjie pozostają na swoich standardowych pozycjach, nawet gdy piszesz znakami łacińskimi w układzie Dvorak, Colemak lub AZERTY. Jeśli dodałeś Hangul lub Chewing przed tą zmianą, odznacz i ponownie zaznacz je w _Setup > Typing > Input Methods_, aby przenieść ich klawisze tam; Omarchy zostawia w spokoju silnik, na którym już piszesz.

Pisanie zaczyna się w trybie łacińskim. Naciśnij `Super + I`, aby przechodzić cyklicznie przez skonfigurowane metody wprowadzania, a `Super + Shift + I`, aby przechodzić w drugą stronę. Dotknij samego `Shift`, aby wyjść z metody wprowadzania takiej jak Pinyin do liter łacińskich, i dotknij go ponownie, aby wrócić, tak jak działają Sogou, Microsoft Pinyin i macOS; `Shift` plus litera nadal wpisuje wielką literę. Na klawiaturach japońskich 全角/半角 przełącza wprowadzanie, 変換 je włącza, a 無変換 je wyłącza. W koreańskim 한/영 przełącza Hangul, a 한자 konwertuje na Hanja, niezależnie od tego, czy klawiatura ma dedykowane klawisze, czy wysyła w ich zastępstwie Right Alt i Right Ctrl, jak robi to wiele laptopów, więc Right Alt i Right Ctrl nie są tam zwykłymi modyfikatorami; dyktowanie push-to-talk pozostaje na F9. `Ctrl + Space` pozostaje dostępne dla Tmux i Herdr; `Shift + CapsLock` pozostaje klawiszem compose.

Wskaźnik klawiatury pojawia się po prawej stronie paska, gdy masz wiele układów klawiatury lub metod wprowadzania. Kliknij go, aby przełączać języki wprowadzania; japoński wyświetla あ dla hiragany. Aby wybrać wariant znaków japońskich, przełącz się na japoński, wpisz słowo takie jak `nihongo`, a potem naciśnij dwukrotnie Space. Naciśnij Enter, aby zaakceptować wybór. Jeśli masz też wiele układów klawiatury, kliknij wskaźnik prawym przyciskiem myszy, aby przechodzić między nimi cyklicznie.

Użyj _Setup > Typing > Keyboard Layouts_, aby wybrać układy takie jak angielski i francuski, spośród tych samych opcji oferowanych podczas instalacji. Użyj _Setup > Typing > Input Methods_, aby wybrać, które silniki kompozycji są aktywne. Oba selektory otwierają się wewnątrz menu Omarchy z zaznaczonymi bieżącymi wyborami. Kliknij lub naciśnij Enter, aby przełączyć opcję; każda zmiana obowiązuje natychmiast. Odznaczenie metody wprowadzania usuwa ją z cyklu bez jej odinstalowywania; klawiatura pozostaje dostępna.

Uruchom `omarchy setup keyboard` lub `omarchy setup input`, aby otworzyć te same selektory. Aby dodać jeden język z wiersza poleceń, użyj `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` lub `cangjie5`. Quick, Boshiamy i Array znajdują się w tym samym pakiecie co Cangjie i pojawiają się w selektorze Input Methods. Twoje niestandardowe klawisze przełączania są zachowywane. Aby ustawić alternatywne układy lub klawisze silników, zainstaluj `fcitx5-configtool` poleceniem `omarchy pkg add fcitx5-configtool` i uruchom go z terminala. Wybranie języka wprowadzania nie zmienia języka pulpitu. Wybranie japońskiego, koreańskiego lub chińskiego w _Setup > Language_ dodaje jego metodę wprowadzania, gdy nie masz jeszcze żadnej.

Użyj `Super + I`, aby przechodzić cyklicznie przez metody wprowadzania lub układy klawiatury, a `Super + Shift + I`, aby iść w drugą stronę, więc przy trzech skonfigurowanych możesz poruszać się między dwoma sąsiadami. Wskaźnik wprowadzania pojawia się po prawej stronie paska tylko wtedy, gdy skonfigurowano więcej niż jedną metodę wprowadzania lub układ. To przypisanie pulpitu działa obok istniejących klawiszy przełączania Fcitx; możesz je nadpisać w `~/.config/hypr/bindings.lua`. Silniki wprowadzania i sekwencje compose używają usługi [Fcitx5](https://fcitx-im.org/) już działającej w każdej sesji.

### Używanie ALT jako SUPER

Na niektórych klawiaturach używanie głównego klawisza meta (klawisza Windows/cmd) jako SUPER nie jest wygodne. Możesz zamiast tego zmienić to na ALT, wprowadzając tę zmianę:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
