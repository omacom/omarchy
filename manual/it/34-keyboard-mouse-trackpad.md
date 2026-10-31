# Tastiera, Mouse, Trackpad

Hyprland ti permette di configurare tutti i tuoi dispositivi di input in grande dettaglio. Puoi rendere la ripetizione della tastiera supersonicamente veloce o far usare al trackpad lo scorrimento naturale. Modifichi tutto in `~/.config/hypr/input.lua`, raggiungibile anche tramite _Setup > Input_ nel menu Omarchy (`Super + Space`). Tutto ciò che imposti lì sostituisce le impostazioni predefinite di Omarchy.

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

Puoi [vedere tutte le opzioni di input](https://wiki.hypr.land/Configuring/Basics/Variables/#input) sulla wiki di Hyprland dedicata agli input.

CapsLock funziona come un normale Caps Lock, e `Shift + CapsLock` è il tasto di composizione per le [emoji rapide](07-hotkeys.md#quick-emojis) e gli [altri completamenti](07-hotkeys.md#quick-completions). Se preferisci avere il tasto di composizione altrove, sostituisci `omarchy:shift_caps_compose` in `kb_options`. Ad esempio, questo sposta il tasto di composizione su Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gesti del trackpad

Scorri sul trackpad per muoverti sul desktop:

| Gesto | Azione |
| --- | --- |
| Tre dita a sinistra / destra | Workspace precedente / successivo, inclusi quelli vuoti |
| Tre dita verso l'alto | Attiva/disattiva la console AI |
| Tre dita verso il basso | Apri il menu Omarchy |
| Quattro dita a sinistra / destra | Sposta la finestra attiva nel workspace precedente / successivo |
| Quattro dita verso il basso | Attiva/disattiva lo schermo intero |

Per modificarne uno, annullalo in `~/.config/hypr/input.lua` prima di aggiungere il tuo [gesto del trackpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), poiché Hyprland non accetta due gesti con le stesse dita e la stessa direzione:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Per disattivare tutti i gesti di Omarchy, imposta `omarchy_default_gestures = false` vicino alla parte superiore di `~/.config/hypr/hyprland.lua`, prima che vengano caricate le impostazioni predefinite di Omarchy.

Sui laptop Dell XPS con touchpad aptico, puoi anche impostare l'intensità del clic su bassa, media o alta in _Trigger > Hardware > Touchpad Haptics_.

### Digitare in cinese, giapponese e altre lingue

Seleziona Giapponese, Coreano, Cinese (semplificato, Pinyin), Taiwan (Zhuyin) o Hong Kong (Cangjie) quando il programma di installazione ti chiede la tastiera. Omarchy configura automaticamente la tastiera e il motore di input corrispondente, anche durante la configurazione offline al primo avvio. Il giapponese usa Mozc, il coreano usa l'Hangul standard a due set, il cinese semplificato usa Pinyin, Taiwan usa la disposizione Zhuyin standard di Chewing e Hong Kong usa Cangjie con le forme dei caratteri di Hong Kong. Giapponese (tastiera US) fornisce Mozc con un layout di tastiera US. I tasti Hangul, Zhuyin e Cangjie restano nelle loro posizioni standard anche quando digiti lettere latine con Dvorak, Colemak o AZERTY. Se hai aggiunto Hangul o Chewing prima di questo, deselezionalo e riselezionalo in _Setup > Typing > Input Methods_ per spostare lì i suoi tasti; Omarchy lascia intatto un motore con cui digiti già.

La digitazione inizia in modalità latina. Premi `Super + I` per scorrere i metodi di input configurati, e `Super + Shift + I` per scorrere all'indietro. Tocca `Shift` da solo per uscire da un metodo di input come Pinyin e passare alle lettere latine, e toccalo di nuovo per tornare indietro, come funzionano Sogou, Microsoft Pinyin e macOS; `Shift` più una lettera digita comunque una maiuscola. Sulle tastiere giapponesi, 全角/半角 attiva/disattiva l'input, 変換 lo attiva e 無変換 lo disattiva. Con il coreano, 한/영 passa a Hangul e 한자 converte in Hanja, sia che la tua tastiera abbia tasti dedicati sia che invii Right Alt e Right Ctrl per essi, come fanno molti laptop, quindi Right Alt e Right Ctrl non sono semplici modificatori lì; la dettatura si attiva/disattiva invece con Alt + Space. `Ctrl + Space` resta disponibile per Tmux e Herdr; `Shift + CapsLock` resta il tasto di composizione.

L'indicatore della tastiera appare a destra della barra quando hai più layout di tastiera o metodi di input. Fai clic su di esso per cambiare lingua di input; il giapponese mostra あ per l'hiragana. Per le scelte dei caratteri giapponesi, passa al giapponese, digita una parola come `nihongo`, quindi premi Space due volte. Premi Enter per accettare la tua scelta. Se hai anche più layout di tastiera, fai clic con il pulsante destro sull'indicatore per scorrerli.

Usa _Setup > Typing > Keyboard Layouts_ per selezionare layout come English e French, tra le stesse scelte offerte durante l'installazione. Usa _Setup > Typing > Input Methods_ per selezionare quali motori di composizione sono attivi. Entrambi i selettori si aprono all'interno del menu Omarchy con le tue selezioni attuali contrassegnate. Fai clic o premi Enter per attivare/disattivare una scelta; ogni modifica si applica immediatamente. Deselezionare un metodo di input lo rimuove dal ciclo senza disinstallarlo; la tastiera resta disponibile.

Esegui `omarchy setup keyboard` o `omarchy setup input` per aprire gli stessi selettori. Per aggiungere una lingua dalla riga di comando, usa `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` o `cangjie5`. Quick, Boshiamy e Array sono inclusi nello stesso pacchetto di Cangjie e appaiono nel selettore Input Methods. I tuoi tasti di commutazione personalizzati vengono preservati. Per layout o tasti alternativi del motore, installa `fcitx5-configtool` con `omarchy pkg add fcitx5-configtool` e avvialo da un terminale. Selezionare una lingua di input non cambia la lingua del desktop. Scegliere Giapponese, Coreano o Cinese in _Setup > Language_ aggiunge il suo metodo di input quando non ne hai ancora nessuno.

Usa `Super + I` per scorrere i metodi di input o i layout di tastiera, e `Super + Shift + I` per tornare nell'altra direzione, così con tre configurati puoi muoverti tra due vicini. L'indicatore di input appare a destra della barra solo quando è configurato più di un metodo di input o layout. Questa scorciatoia del desktop funziona insieme ai tuoi tasti di commutazione Fcitx esistenti; puoi sostituirla in `~/.config/hypr/bindings.lua`. I motori di input e le sequenze di composizione usano il servizio [Fcitx5](https://fcitx-im.org/) già in esecuzione in ogni sessione.

### Usa ALT come SUPER

Su alcune tastiere, non è comodo usare il tasto meta primario (tasto Windows/cmd) come SUPER. Puoi cambiarlo in ALT invece, usando questa modifica:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
