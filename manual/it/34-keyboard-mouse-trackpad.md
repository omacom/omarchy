# Tastiera, mouse, trackpad

Hyprland ti permette di configurare tutti i tuoi input in grande dettaglio. Puoi rendere la ripetizione della tastiera supersonicamente veloce o far usare al trackpad lo scorrimento naturale. Cambi tutto in `~/.config/hypr/input.lua`, che puoi raggiungere anche tramite _Impostazioni > Input_ nel menu Omarchy (`Super + Space`). Qualsiasi cosa imposti lì sostituisce i predefiniti di Omarchy.

Ecco un esempio:

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

Puoi [vedere tutte le opzioni di input](https://wiki.hypr.land/Configuring/Basics/Variables/#input) sul wiki di Hyprland per gli input.

CapsLock funziona come un normale Caps Lock, e `Shift + CapsLock` è il tasto compose per le [emoji rapide](07-hotkeys.md#quick-emojis) e gli [altri completamenti](07-hotkeys.md#quick-completions). Se preferisci avere il tasto compose altrove, sostituisci `omarchy:shift_caps_compose` in `kb_options`. Ad esempio, questo sposta il tasto compose su Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gesti del trackpad

Puoi anche attivare i [gesti del touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), come scorrere con tre dita per cambiare workspace:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Sui portatili Dell XPS con touchpad aptico, puoi anche impostare l'intensità del clic su basso, medio o alto in _Azioni > Hardware > Vibrazione touchpad_.

### Digitare in cinese, giapponese e altre lingue

Seleziona giapponese, coreano, cinese (semplificato, Pinyin) o cinese (tradizionale, Zhuyin) quando l'installatore chiede la tua tastiera. Omarchy configura automaticamente la tastiera e il motore di input corrispondente, anche durante la configurazione offline al primo avvio. Il giapponese usa Mozc, il coreano usa l'Hangul standard a due set, il cinese semplificato usa Pinyin e il cinese tradizionale usa la disposizione Zhuyin standard di Chewing. Giapponese (tastiera US) fornisce Mozc con un layout di tastiera US.

La digitazione inizia in modalità latina. Premi `Super + I` per scorrere i metodi di input configurati e `Super + Shift + I` per tornare indietro. Tocca `Shift` da solo per uscire da un metodo di input come Pinyin verso le lettere latine, e toccalo di nuovo per tornare indietro, come funzionano Sogou, Microsoft Pinyin e macOS; `Shift` più una lettera digita comunque una maiuscola. Sulle tastiere giapponesi, 全角/半角 attiva/disattiva l'input, 変換 lo attiva e 無変換 lo disattiva. Su un layout di tastiera coreana, i tasti dedicati 한/영 e 한자 commutano Hangul e convertono in Hanja. `Ctrl + Space` resta disponibile per Tmux e Herdr; `Shift + CapsLock` resta il tasto compose.

L'indicatore della tastiera appare a destra della barra quando hai più layout di tastiera o metodi di input. Fai clic su di esso per cambiare lingua di input; il giapponese mostra あ per hiragana. Per le scelte dei caratteri giapponesi, passa al giapponese, digita una parola come `nihongo`, poi premi Space due volte. Premi Enter per accettare la tua scelta. Se hai anche più layout di tastiera, fai clic con il tasto destro sull'indicatore per scorrerli.

Usa _Impostazioni > Digitazione > Layout tastiera_ per selezionare layout come inglese e francese, tra le stesse scelte offerte durante l'installazione. Usa _Impostazioni > Digitazione > Metodi di input_ per selezionare quali motori di composizione sono attivi. Entrambi i selettori si aprono all'interno del menu Omarchy con le selezioni correnti contrassegnate. Fai clic o premi Enter per attivare/disattivare una scelta; ogni modifica si applica immediatamente. Deselezionare un metodo di input lo rimuove dal ciclo senza disinstallarlo; la tastiera resta disponibile.

Esegui `omarchy setup keyboard` o `omarchy setup input` per aprire gli stessi selettori. Per aggiungere una lingua da riga di comando, usa `omarchy setup input mozc`, `hangul`, `pinyin` o `chewing`. I tuoi tasti di commutazione personalizzati vengono preservati. Per layout o tasti alternativi del motore, installa `fcitx5-configtool` con `omarchy pkg add fcitx5-configtool` e avvialo da un terminale. Selezionare una lingua di input non cambia la lingua del desktop.

Usa `Super + I` per scorrere i metodi di input o i layout di tastiera e `Super + Shift + I` per andare nell'altra direzione, così con tre configurati puoi muoverti tra due vicini. L'indicatore di input appare a destra della barra solo quando è configurato più di un metodo di input o layout. Questa associazione del desktop funziona insieme ai tuoi tasti di commutazione Fcitx esistenti; puoi sovrascriverla in `~/.config/hypr/bindings.lua`. I motori di input e le sequenze compose usano il servizio [Fcitx5](https://fcitx-im.org/) già in esecuzione in ogni sessione.

### Usare ALT come SUPER

Su alcune tastiere non è comodo usare il tasto meta primario (tasto Windows/cmd) come SUPER. Puoi cambiarlo in ALT usando questa modifica:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
