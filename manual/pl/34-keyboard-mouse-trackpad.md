# Klawiatura, mysz, trackpad

Hyprland pozwala skonfigurować wszystkie urządzenia wejściowe w najdrobniejszych szczegółach. Możesz ustawić powtarzanie klawiszy na naddźwiękową prędkość albo sprawić, że trackpad będzie używał naturalnego przewijania. Wszystko to zmienisz w `~/.config/hypr/input.lua`, do którego możesz też dotrzeć przez _Setup > Input_ w menu Omarchy (`Super + Space`). Wszystko, co tam ustawisz, zastępuje domyślne ustawienia Omarchy.

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

Na wiki Hyprland możesz [zobaczyć wszystkie opcje dotyczące urządzeń wejściowych](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock działa jak zwykły Caps Lock, a `Shift + CapsLock` jest klawiszem compose do [szybkich emoji](07-hotkeys.md#quick-emojis) i [innych uzupełnień](07-hotkeys.md#quick-completions). Jeśli wolisz mieć klawisz compose gdzie indziej, zastąp `omarchy:shift_caps_compose` w `kb_options`. Ten przykład na przykład przenosi klawisz compose na prawy Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Klawisze funkcyjne

Górny rząd klawiatury laptopa domyślnie wysyła klawisze multimedialne (głośność, jasność itd.), a przytrzymanie `Fn` daje F1-F12; `Fn + Esc` blokuje to w drugą stronę, dopóki nie naciśniesz tego ponownie. Większość klawiatur sama pamięta tę blokadę. Laptopy ASUS i klawiatury w stylu Apple zostawiają to Linuksowi, który przy każdym uruchomieniu zaczyna od klawiszy multimedialnych. Aby zamiast tego zaczynać od F1-F12, uruchom `omarchy keyboard toprow fnkeys` (oraz `omarchy keyboard toprow mediakeys`, aby wrócić); na niektórych laptopach zmiana zaczyna obowiązywać po ponownym uruchomieniu. Komputery Mac z Apple Silicon zachowują własne ustawienie.

### Gesty trackpada

Przesuwaj palcami po trackpadzie, aby poruszać się po pulpicie:

| Gest | Czynność |
| --- | --- |
| Trzy palce w lewo / w prawo | Poprzedni / następny obszar roboczy, w tym puste |
| Trzy palce w górę | Przełącz konsolę AI |
| Trzy palce w dół | Otwórz menu Omarchy |
| Cztery palce w lewo / w prawo | Przenieś aktywne okno na poprzedni / następny obszar roboczy |
| Cztery palce w dół | Przełącz pełny ekran |

Aby zmienić któryś z nich, wyłącz go w `~/.config/hypr/input.lua`, zanim dodasz własny [gest trackpada](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), ponieważ Hyprland nie przyjmie dwóch gestów na tę samą liczbę palców i ten sam kierunek:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Aby wyłączyć wszystkie gesty Omarchy, ustaw `omarchy_default_gestures = false` bliżej początku `~/.config/hypr/hyprland.lua`, zanim wczytają się domyślne ustawienia Omarchy.

Na laptopach Dell XPS z haptycznym touchpadem możesz też ustawić siłę kliknięcia na niską, średnią lub wysoką w _Trigger > Hardware > Touchpad Haptics_.

### Pisanie po chińsku, japońsku i w innych językach

Gdy instalator zapyta o twoją klawiaturę, wybierz japoński, koreański, chiński (uproszczony, Pinyin), Tajwan (Zhuyin) lub Hongkong (Cangjie). Omarchy automatycznie konfiguruje klawiaturę i pasujący silnik wprowadzania, także podczas konfiguracji offline przy pierwszym uruchomieniu. Japoński używa Mozc, koreański używa standardowego dwuzestawowego układu Hangul, chiński uproszczony używa Pinyin, Tajwan używa standardowego układu Zhuyin silnika Chewing, a Hongkong używa Cangjie z hongkońskimi formami znaków. Japoński (klawiatura US) zapewnia Mozc z układem klawiatury US. Klawisze Hangul, Zhuyin i Cangjie pozostają w swoich standardowych pozycjach, nawet gdy piszesz litery łacińskie w układach Dvorak, Colemak lub AZERTY. Jeśli dodałeś Hangul lub Chewing przed tą zmianą, odznacz i ponownie zaznacz to w _Setup > Keyboard > Input Methods_, aby przenieść jego klawisze w te miejsca; Omarchy zostawia w spokoju silnik, na którym już piszesz.

Pisanie zaczyna się w trybie łacińskim. Naciśnij `Super + I`, aby przechodzić cyklicznie przez skonfigurowane metody wprowadzania, oraz `Super + Shift + I`, aby przechodzić w odwrotną stronę. Dotknij samego `Shift`, aby wyjść z metody wprowadzania takiej jak Pinyin do liter łacińskich, i dotknij go ponownie, aby wrócić, tak jak działają Sogou, Microsoft Pinyin i macOS; `Shift` wraz z literą nadal wpisuje wielką literę. Na klawiaturach japońskich 全角/半角 przełącza wprowadzanie, 変換 je włącza, a 無変換 je wyłącza. W przypadku koreańskiego 한/영 przełącza Hangul, a 한자 konwertuje na Hanja, niezależnie od tego, czy twoja klawiatura ma dedykowane klawisze, czy wysyła za nie Right Alt i Right Ctrl, jak robi to wiele laptopów, więc Right Alt i Right Ctrl nie są tam zwykłymi modyfikatorami; dyktowanie przełącza się zamiast tego za pomocą Alt + Space. `Ctrl + Space` pozostaje dostępne dla Tmux i Herdr; `Shift + CapsLock` pozostaje klawiszem compose.

Wskaźnik klawiatury pojawia się po prawej stronie paska, gdy masz wiele układów klawiatury lub metod wprowadzania. Kliknij go, aby przełączać języki wprowadzania; japoński wyświetla あ dla hiragany. Aby wybrać japońskie znaki, przełącz na japoński, wpisz słowo takie jak `nihongo`, a następnie naciśnij Space dwa razy. Naciśnij Enter, aby zaakceptować swój wybór. Jeśli masz też wiele układów klawiatury, kliknij wskaźnik prawym przyciskiem myszy, aby przechodzić między nimi cyklicznie.

Użyj _Setup > Keyboard > Keyboard Inputs_, aby wybrać układy takie jak angielski i francuski spośród tych samych opcji oferowanych podczas instalacji. Użyj _Setup > Keyboard > Input Methods_, aby wybrać, które silniki składania znaków są aktywne. Oba narzędzia wyboru otwierają się wewnątrz menu Omarchy z zaznaczonymi twoimi bieżącymi wyborami. Kliknij lub naciśnij Enter, aby przełączyć wybór; każda zmiana obowiązuje natychmiast. Odznaczenie metody wprowadzania usuwa ją z cyklu bez jej odinstalowywania; klawiatura pozostaje dostępna.

Uruchom `omarchy setup keyboard` lub `omarchy setup input`, aby otworzyć te same narzędzia wyboru. Aby dodać jeden język z wiersza poleceń, użyj `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` lub `cangjie5`. Quick, Boshiamy i Array znajdują się w tym samym pakiecie co Cangjie i pojawiają się w narzędziu wyboru Input Methods. Twoje niestandardowe klawisze przełączania są zachowywane. Aby ustawić alternatywne układy lub klawisze silnika, zainstaluj `fcitx5-configtool` za pomocą `omarchy pkg add fcitx5-configtool` i uruchom go z terminala. Wybranie języka wprowadzania nie zmienia języka pulpitu. Wybranie japońskiego, koreańskiego lub chińskiego w _Setup > Language_ dodaje jego metodę wprowadzania, gdy nie masz jeszcze żadnej.

Użyj `Super + I`, aby przechodzić cyklicznie przez metody wprowadzania lub układy klawiatury, oraz `Super + Shift + I`, aby przechodzić w przeciwną stronę, więc przy trzech skonfigurowanych możesz poruszać się między dwoma sąsiadami. Wskaźnik wprowadzania pojawia się po prawej stronie paska tylko wtedy, gdy skonfigurowano więcej niż jedną metodę wprowadzania lub układ. To powiązanie pulpitu działa obok twoich istniejących klawiszy przełączania Fcitx; możesz je nadpisać w `~/.config/hypr/bindings.lua`. Silniki wprowadzania i sekwencje compose używają usługi [Fcitx5](https://fcitx-im.org/), która już działa w każdej sesji.

### Używanie ALT jako SUPER

Na niektórych klawiaturach używanie głównego klawisza meta (klawisza Windows/cmd) jako SUPER nie jest wygodne. Możesz zmienić to na ALT, używając tej zmiany:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
