# Klawiatura, mysz, gładzik

Hyprland pozwala skonfigurować wszystkie urządzenia wejściowe w najdrobniejszych szczegółach. Możesz ustawić powtarzanie klawiatury na naddźwiękową szybkość albo sprawić, by gładzik używał naturalnego przewijania. Wszystko to zmienisz w `~/.config/hypr/input.lua`, do którego dotrzesz też przez _Setup > Input_ w menu Omarchy (`Super + Space`). Wszystko, co tam ustawisz, zastępuje domyślne ustawienia Omarchy.

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

Na wiki Hyprland możesz [zobaczyć wszystkie opcje wejścia](https://wiki.hypr.land/Configuring/Basics/Variables/#input) dla urządzeń wejściowych.

CapsLock działa jak normalny Caps Lock, a `Shift + CapsLock` to klawisz compose dla [szybkich emoji](07-hotkeys.md#quick-emojis) i [innych uzupełnień](07-hotkeys.md#quick-completions). Jeśli wolisz mieć klawisz compose gdzie indziej, zastąp `omarchy:shift_caps_compose` w `kb_options`. Ten przykład przenosi na przykład klawisz compose na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Klawisze funkcyjne

Górny rząd klawiatury laptopa domyślnie wysyła klawisze multimedialne (głośność, jasność i tak dalej), a przytrzymanie `Fn` daje F1-F12; `Fn + Esc` blokuje to w odwrotną stronę, aż naciśniesz je ponownie. Większość klawiatur sama pamięta tę blokadę. Laptopy ASUS i klawiatury w stylu Apple zostawiają to Linuxowi, który przy każdym uruchomieniu startuje je na klawiszach multimedialnych. Aby zamiast tego startowały na F1-F12, uruchom `omarchy device keyboard toprow fnkeys` (a `omarchy device keyboard toprow mediakeys`, aby wrócić); na niektórych laptopach zmiana zaczyna obowiązywać po ponownym uruchomieniu. Komputery Mac z Apple Silicon zachowują własne ustawienie.

### Gesty gładzika

Przeciągnij palcami po gładziku, aby poruszać się po pulpicie:

| Gest | Akcja |
| --- | --- |
| Trzy palce w lewo / w prawo | Poprzedni / następny obszar roboczy, w tym puste |
| Trzy palce w górę | Przełącz konsolę AI |
| Trzy palce w dół | Otwórz menu Omarchy |
| Cztery palce w lewo / w prawo | Przenieś aktywne okno na poprzedni / następny obszar roboczy |
| Cztery palce w dół | Przełącz pełny ekran |

Aby zmienić jeden z nich, wyłącz go w `~/.config/hypr/input.lua`, zanim dodasz własny [gest gładzika](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), ponieważ Hyprland nie przyjmie dwóch gestów dla tych samych palców i tego samego kierunku:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Aby wyłączyć wszystkie gesty Omarchy, ustaw `omarchy_default_gestures = false` blisko początku pliku `~/.config/hypr/hyprland.lua`, zanim załadują się domyślne ustawienia Omarchy.

W laptopach Dell XPS z haptycznym gładzikiem możesz też ustawić siłę kliknięcia na niską, średnią lub wysoką w _Trigger > Hardware > Touchpad Haptics_.

### Pisanie po chińsku, japońsku i w innych językach

Wybierz japoński, koreański, chiński (uproszczony, Pinyin), Tajwan (Zhuyin) lub Hongkong (Cangjie), gdy instalator zapyta o klawiaturę. Omarchy automatycznie konfiguruje klawiaturę i pasujący silnik wprowadzania, także podczas konfiguracji przy pierwszym uruchomieniu w trybie offline. Japoński używa Mozc, koreański używa standardowego dwuzestawowego Hangul, chiński uproszczony używa Pinyin, Tajwan używa standardowego układu Zhuyin z Chewing, a Hongkong używa Cangjie z hongkońskimi formami znaków. Japoński (klawiatura US) zapewnia Mozc z układem klawiatury US. Klawisze Hangul, Zhuyin i Cangjie pozostają na swoich standardowych pozycjach, nawet gdy piszesz litery łacińskie w układach Dvorak, Colemak lub AZERTY. Jeśli dodałeś wcześniej Hangul lub Chewing, odznacz i zaznacz je ponownie w _Setup > Keyboard > Input Methods_, aby przenieść ich klawisze w te miejsca; silnik, na którym już piszesz, Omarchy zostawia w spokoju.

Pisanie zaczyna się w trybie łacińskim. Naciśnij `Super + I`, aby przechodzić cyklicznie przez skonfigurowane metody wprowadzania, a `Super + Shift + I`, aby przechodzić wstecz. Stuknij sam `Shift`, aby wyjść z metody wprowadzania takiej jak Pinyin do liter łacińskich, i stuknij go ponownie, aby wrócić, tak jak działają Sogou, Microsoft Pinyin i macOS; `Shift` plus litera nadal wpisuje wielką literę. Na klawiaturach japońskich 全角/半角 przełącza wprowadzanie, 変換 je włącza, a 無変換 je wyłącza. Przy koreańskim 한/영 przełącza Hangul, a 한자 konwertuje na Hanja, niezależnie od tego, czy klawiatura ma dedykowane klawisze, czy wysyła w ich miejsce Right Alt i Right Ctrl, jak wiele laptopów, więc Right Alt i Right Ctrl nie są tam zwykłymi modyfikatorami; dyktowanie przełącza się natomiast za pomocą Alt + Space. `Ctrl + Space` pozostaje dostępny dla Tmux i Herdr; `Shift + CapsLock` pozostaje klawiszem compose.

Wskaźnik klawiatury pojawia się po prawej stronie paska, gdy masz wiele układów klawiatury lub metod wprowadzania. Kliknij go, aby przełączać języki wprowadzania; japoński wyświetla あ dla hiragany. Aby wybrać japońskie znaki, przełącz na japoński, wpisz słowo takie jak `nihongo`, a potem naciśnij Space dwa razy. Naciśnij Enter, aby zaakceptować wybór. Jeśli masz też wiele układów klawiatury, kliknij wskaźnik prawym przyciskiem, aby przechodzić między nimi cyklicznie.

Użyj _Setup > Keyboard > Keyboard Inputs_, aby wybrać układy, takie jak angielski i francuski, spośród tych samych opcji oferowanych podczas instalacji. Użyj _Setup > Keyboard > Input Methods_, aby wybrać, które silniki kompozycji są aktywne. Oba selektory otwierają się wewnątrz menu Omarchy z zaznaczonymi bieżącymi wyborami. Kliknij lub naciśnij Enter, aby przełączyć wybór; każda zmiana obowiązuje od razu. Odznaczenie metody wprowadzania usuwa ją z cyklu bez jej odinstalowywania; klawiatura pozostaje dostępna.

Uruchom `omarchy setup keyboard` lub `omarchy setup input`, aby otworzyć te same selektory. Aby dopisać jeden język z wiersza poleceń, użyj `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` lub `cangjie5`. Quick, Boshiamy i Array są w tym samym pakiecie co Cangjie i pojawiają się w selektorze Input Methods. Twoje niestandardowe klawisze przełączania są zachowywane. Aby ustawić alternatywne układy lub klawisze silników, zainstaluj `fcitx5-configtool` za pomocą `omarchy pkg add fcitx5-configtool` i uruchom go z terminala. Wybranie języka wprowadzania nie zmienia języka pulpitu. Wybranie japońskiego, koreańskiego lub chińskiego w _Setup > Region > Language_ dodaje jego metodę wprowadzania, gdy nie masz jeszcze żadnej.

Użyj `Super + I`, aby przechodzić cyklicznie przez metody wprowadzania lub układy klawiatury, a `Super + Shift + I`, aby wracać w drugą stronę, więc przy trzech skonfigurowanych możesz poruszać się między dwoma sąsiadami. Wskaźnik wprowadzania pojawia się po prawej stronie paska tylko wtedy, gdy skonfigurowana jest więcej niż jedna metoda wprowadzania lub układ. To powiązanie pulpitu działa obok istniejących klawiszy przełączania Fcitx; możesz je nadpisać w `~/.config/hypr/bindings.lua`. Silniki wprowadzania i sekwencje compose używają usługi [Fcitx5](https://fcitx-im.org/) już działającej w każdej sesji.

### Użyj ALT jako SUPER

Na niektórych klawiaturach używanie głównego klawisza meta (klawisza Windows/cmd) jako SUPER nie jest wygodne. Możesz zmienić go na ALT, wprowadzając tę zmianę:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
