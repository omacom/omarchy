# Klawiatura, mysz, gładzik

Hyprland pozwala konfigurować wszystkie wejścia z dużą szczegółowością. Możesz zmienić powtarzanie klawiatury na naddźwiękowo szybkie lub sprawić, by gładzik używał naturalnego przewijania. Zmieniasz to wszystko w `~/.config/hypr/input.lua`, do którego możesz także dotrzeć przez _Ustawienia > Wejście_ w menu Omarchy (`Super + Space`). Wszystko, co tam ustawisz, zastępuje domyślne ustawienia Omarchy.

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

Możesz [zobaczyć wszystkie opcje wejścia](https://wiki.hypr.land/Configuring/Basics/Variables/#input) na wiki Hyprland dla wejść.

CapsLock działa jak normalny Caps Lock, a `Shift + CapsLock` jest klawiszem Compose dla [szybkich emoji](07-hotkeys.md#quick-emojis) i [innych uzupełnień](07-hotkeys.md#quick-completions). Jeśli wolisz mieć klawisz Compose w innym miejscu, zastąp `omarchy:shift_caps_compose` w `kb_options`. Na przykład przenosi to klawisz Compose na Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gesty gładzika

Możesz również włączyć [gesty panelu dotykowego](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), takie jak przesuwanie trzema palcami, aby zmieniać obszary robocze:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Na laptopach Dell XPS z haptycznym panelem dotykowym możesz również ustawić siłę kliknięcia na niską, średnią lub wysoką w _Akcje > Sprzęt > Haptyka gładzika_.

### Pisanie po chińsku, japońsku i w innych językach

Wybierz japoński, koreański, chiński (uproszczony, Pinyin) lub chiński (tradycyjny, Zhuyin), gdy instalator zapyta o twoją klawiaturę. Omarchy konfiguruje klawiaturę i dopasowany silnik wprowadzania automatycznie, w tym podczas konfiguracji pierwszego uruchomienia offline. Japoński używa Mozc, koreański używa standardowego hangula dwuzestawowego, chiński uproszczony używa Pinyin, a chiński tradycyjny używa standardowego układu Zhuyin Chewing. Japoński (klawiatura US) zapewnia Mozc z układem klawiatury US.

Pisanie rozpoczyna się w trybie łacińskim. Naciśnij `Super + I`, aby przełączać się między skonfigurowanymi metodami wprowadzania, i `Super + Shift + I`, aby przełączać się wstecz. Dotknij samego `Shift`, aby wyjść z metody wprowadzania, takiej jak Pinyin, na litery łacińskie, i dotknij go ponownie, aby wrócić, tak jak działają Sogou, Microsoft Pinyin i macOS; `Shift` plus litera nadal pisze wielką literę. Na klawiaturach japońskich 全角/半角 przełącza wprowadzanie, 変換 włącza je, a 無変換 wyłącza je. Na układzie klawiatury koreańskiej dedykowane klawisze 한/영 i 한자 przełączają hangul i konwertują na hanja. `Ctrl + Space` pozostaje dostępne dla Tmux i Herdr; `Shift + CapsLock` pozostaje klawiszem Compose.

Wskaźnik klawiatury pojawia się po prawej stronie paska, gdy masz wiele układów klawiatury lub metod wprowadzania. Kliknij go, aby przełączać języki wprowadzania; japoński wyświetla あ dla hiragany. W przypadku wyborów znaków japońskich przełącz się na japoński, wpisz słowo, takie jak `nihongo`, a następnie naciśnij Space dwukrotnie. Naciśnij Enter, aby zaakceptować swój wybór. Jeśli masz również wiele układów klawiatury, kliknij wskaźnik prawym przyciskiem myszy, aby przełączać je.

Użyj _Ustawienia > Pisanie > Układy klawiatury_, aby wybrać układy, takie jak angielski i francuski, spośród tych samych wyborów oferowanych podczas instalacji. Użyj _Ustawienia > Pisanie > Metody wprowadzania_, aby wybrać, które silniki składania są aktywne. Oba selektory otwierają się wewnątrz menu Omarchy z zaznaczonymi bieżącymi wyborami. Kliknij lub naciśnij Enter, aby przełączyć wybór; każda zmiana obowiązuje natychmiast. Odznaczenie metody wprowadzania usuwa ją z cyklu bez odinstalowywania jej; klawiatura pozostaje dostępna.

Uruchom `omarchy setup keyboard` lub `omarchy setup input`, aby otworzyć te same selektory. Aby dodać jeden język z wiersza poleceń, użyj `omarchy setup input mozc`, `hangul`, `pinyin` lub `chewing`. Twoje niestandardowe klawisze przełączania są zachowywane. W przypadku alternatywnych układów lub klawiszy silników zainstaluj `fcitx5-configtool` za pomocą `omarchy pkg add fcitx5-configtool` i uruchom go z terminala. Wybranie języka wprowadzania nie zmienia języka pulpitu.

Użyj `Super + I`, aby przełączać się między metodami wprowadzania lub układami klawiatury, i `Super + Shift + I`, aby wrócić w drugą stronę, więc przy trzech skonfigurowanych możesz poruszać się między dwoma sąsiadami. Wskaźnik wprowadzania pojawia się po prawej stronie paska tylko wtedy, gdy skonfigurowana jest więcej niż jedna metoda wprowadzania lub układ. To powiązanie pulpitu działa obok istniejących klawiszy przełączania Fcitx; możesz nadpisać je w `~/.config/hypr/bindings.lua`. Silniki wprowadzania i sekwencje Compose używają usługi [Fcitx5](https://fcitx-im.org/) już działającej w każdej sesji.

### Używaj ALT jako SUPER

Na niektórych klawiaturach używanie głównego klawisza Meta (klawisza Windows/cmd) jako SUPER nie jest wygodne. Możesz zmienić to na ALT, używając tej zmiany:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
