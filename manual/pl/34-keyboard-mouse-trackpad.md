# Klawiatura, mysz, gładzik

Hyprland pozwala szczegółowo skonfigurować wszystkie urządzenia wejściowe. Możesz ustawić naddźwiękowo szybkie powtarzanie klawiszy albo sprawić, by gładzik używał naturalnego przewijania. Wszystko to zmieniasz w `~/.config/hypr/input.lua`, do którego możesz też dotrzeć przez _Setup > Input_ w menu Omarchy (`Super + Space`). Wszystko, co tam ustawisz, zastępuje domyślne ustawienia Omarchy.

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

Wszystkie opcje dotyczące urządzeń wejściowych możesz [zobaczyć na wiki Hyprland](https://wiki.hypr.land/Configuring/Basics/Variables/#input).

CapsLock działa jak zwykły Caps Lock, a `Shift + CapsLock` jest klawiszem compose do [szybkich emoji](07-hotkeys.md#quick-emojis) i [innych uzupełnień](07-hotkeys.md#quick-completions). Jeśli wolisz mieć klawisz compose w innym miejscu, zamień `omarchy:shift_caps_compose` w `kb_options`. Ten przykład przenosi na przykład klawisz compose na prawy Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gesty na gładziku

Możesz też włączyć [gesty touchpada](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), na przykład przeciąganie trzema palcami, aby zmieniać obszary robocze:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Na laptopach Dell XPS z haptycznym touchpadem możesz też ustawić siłę kliknięcia na niską, średnią lub wysoką w _Trigger > Hardware > Touchpad Haptics_.

### Pisanie po chińsku, japońsku i w innych językach

Wybierz japoński, koreański, chiński (uproszczony, Pinyin), tajwański (Zhuyin) lub hongkoński (Cangjie), gdy instalator zapyta o klawiaturę. Omarchy automatycznie konfiguruje klawiaturę i pasujący silnik wprowadzania, także podczas konfiguracji przy pierwszym uruchomieniu w trybie offline. Japoński używa Mozc, koreański używa standardowego dwuzestawowego układu Hangul, chiński uproszczony używa Pinyin, tajwański używa standardowego układu Zhuyin z Chewing, a hongkoński używa Cangjie z hongkońskimi formami znaków. Japoński (klawiatura US) zapewnia Mozc z układem klawiatury US. Klawisze Hangul, Zhuyin i Cangjie pozostają na swoich standardowych pozycjach, nawet gdy piszesz łacińskimi literami w układzie Dvorak, Colemak lub AZERTY. Jeśli dodałeś Hangul lub Chewing przed tą zmianą, odznacz je i zaznacz ponownie w _Setup > Typing > Input Methods_, aby przenieść ich klawisze w to miejsce; Omarchy zostawia w spokoju silnik, na którym już piszesz.

Pisanie zaczyna się w trybie łacińskim. Naciśnij `Super + I`, aby przechodzić cyklicznie przez skonfigurowane metody wprowadzania, oraz `Super + Shift + I`, aby przechodzić w odwrotnym kierunku. Naciśnij sam `Shift`, aby wyjść z metody wprowadzania takiej jak Pinyin do liter łacińskich, i naciśnij go ponownie, aby wrócić, tak jak działają Sogou, Microsoft Pinyin i macOS; `Shift` plus litera nadal wpisuje wielką literę. Na klawiaturach japońskich 全角/半角 przełącza wprowadzanie, 変換 je włącza, a 無変換 je wyłącza. W przypadku koreańskiego 한/영 przełącza Hangul, a 한자 konwertuje na Hanja, niezależnie od tego, czy twoja klawiatura ma dedykowane klawisze, czy wysyła w ich miejsce prawy Alt i prawy Ctrl, jak robi to wiele laptopów, więc prawy Alt i prawy Ctrl nie są tam zwykłymi modyfikatorami; dyktowanie push-to-talk pozostaje na F9. `Ctrl + Space` pozostaje dostępne dla Tmux i Herdr; `Shift + CapsLock` pozostaje klawiszem compose.

Wskaźnik klawiatury pojawia się po prawej stronie paska, gdy masz wiele układów klawiatury lub metod wprowadzania. Kliknij go, aby przełączać języki wprowadzania; japoński wyświetla あ dla hiragany. Aby wybrać japońskie znaki, przełącz na japoński, wpisz słowo takie jak `nihongo`, a następnie naciśnij dwukrotnie Space. Naciśnij Enter, aby zaakceptować wybór. Jeśli masz też wiele układów klawiatury, kliknij wskaźnik prawym przyciskiem myszy, aby przechodzić między nimi cyklicznie.

Użyj _Setup > Typing > Keyboard Layouts_, aby wybrać układy takie jak angielski i francuski, spośród tych samych opcji oferowanych podczas instalacji. Użyj _Setup > Typing > Input Methods_, aby wybrać, które silniki kompozycji są aktywne. Oba selektory otwierają się wewnątrz menu Omarchy z zaznaczonymi bieżącymi wyborami. Kliknij lub naciśnij Enter, aby przełączyć wybór; każda zmiana obowiązuje natychmiast. Odznaczenie metody wprowadzania usuwa ją z cyklu bez jej odinstalowywania; klawiatura pozostaje dostępna.

Uruchom `omarchy setup keyboard` lub `omarchy setup input`, aby otworzyć te same selektory. Aby dopisać jeden język z wiersza poleceń, użyj `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` lub `cangjie5`. Quick, Boshiamy i Array znajdują się w tym samym pakiecie co Cangjie i pojawiają się w selektorze Input Methods. Twoje niestandardowe klawisze przełączania są zachowywane. Aby uzyskać alternatywne układy lub klawisze silników, zainstaluj `fcitx5-configtool` za pomocą `omarchy pkg add fcitx5-configtool` i uruchom go z terminala. Wybranie języka wprowadzania nie zmienia języka pulpitu. Wybranie japońskiego, koreańskiego lub chińskiego w _Setup > Language_ dodaje jego metodę wprowadzania, gdy nie masz jeszcze żadnej.

Użyj `Super + I`, aby przechodzić cyklicznie przez metody wprowadzania lub układy klawiatury, oraz `Super + Shift + I`, aby iść w drugą stronę, więc przy trzech skonfigurowanych możesz poruszać się między dwoma sąsiadami. Wskaźnik wprowadzania pojawia się po prawej stronie paska tylko wtedy, gdy skonfigurowana jest więcej niż jedna metoda wprowadzania lub układ. To powiązanie pulpitu działa obok twoich istniejących klawiszy przełączania Fcitx; możesz je nadpisać w `~/.config/hypr/bindings.lua`. Silniki wprowadzania i sekwencje compose używają usługi [Fcitx5](https://fcitx-im.org/), która już działa w każdej sesji.

### Używanie ALT jako SUPER

Na niektórych klawiaturach używanie głównego klawisza meta (klawisza Windows/cmd) jako SUPER nie jest wygodne. Możesz zamiast tego zmienić go na ALT, wprowadzając tę zmianę:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
