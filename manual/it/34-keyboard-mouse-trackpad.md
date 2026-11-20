# Tastiera, Mouse, Trackpad

Hyprland ti permette di configurare tutti i tuoi dispositivi di input in grande dettaglio. Puoi impostare la ripetizione della tastiera a una velocità supersonica o far usare al trackpad lo scorrimento naturale. Modifichi tutto in `~/.config/hypr/input.lua`, raggiungibile anche tramite _Setup > Input_ nel menu Omarchy (`Super + Space`). Tutto ciò che imposti lì sostituisce le impostazioni predefinite di Omarchy.

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

CapsLock funziona come un normale Caps Lock, e `Shift + CapsLock` è il tasto compose per le [emoji rapide](07-hotkeys.md#quick-emojis) e gli [altri completamenti](07-hotkeys.md#quick-completions). Se preferisci avere il tasto compose altrove, sostituisci `omarchy:shift_caps_compose` in `kb_options`. Ad esempio, questo sposta il tasto compose su Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Tasti funzione

La riga superiore di una tastiera per laptop invia per impostazione predefinita i tasti multimediali (volume, luminosità e così via), e tenendo premuto `Fn` ottieni F1-F12; `Fn + Esc` blocca il comportamento nell'altro modo finché non lo premi di nuovo. La maggior parte delle tastiere ricorda autonomamente quel blocco. I laptop ASUS e le tastiere in stile Apple lo lasciano a Linux, che a ogni avvio li fa partire con i tasti multimediali. Per farli partire invece con F1-F12, esegui `omarchy device keyboard toprow fnkeys` (e `omarchy device keyboard toprow mediakeys` per tornare indietro); su alcuni laptop la modifica ha effetto dopo un riavvio. I Mac con Apple Silicon mantengono la propria impostazione.

### Gesti del trackpad

Scorri sul trackpad per muoverti sul desktop:

| Gesto | Azione |
| --- | --- |
| Tre dita a sinistra / destra | Workspace precedente / successivo, inclusi quelli vuoti |
| Tre dita verso l'alto | Attiva/disattiva la console AI |
| Tre dita verso il basso | Apri il menu Omarchy |
| Quattro dita a sinistra / destra | Sposta la finestra attiva sullo workspace precedente / successivo |
| Quattro dita verso il basso | Attiva/disattiva lo schermo intero |

Per modificarne uno, annullalo in `~/.config/hypr/input.lua` prima di aggiungere il tuo [gesto del touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), poiché Hyprland non accetta due gesti con le stesse dita e nella stessa direzione:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Per disattivare tutti i gesti di Omarchy, imposta `omarchy_default_gestures = false` vicino alla parte superiore di `~/.config/hypr/hyprland.lua`, prima che vengano caricate le impostazioni predefinite di Omarchy.

Sui laptop Dell XPS con touchpad aptico, puoi anche impostare l'intensità del clic su low, mid o high in _Trigger > Hardware > Touchpad Haptics_.

### Digitare in cinese, giapponese e altre lingue

Seleziona Japanese, Korean, Chinese (Simplified, Pinyin), Taiwan (Zhuyin) o Hong Kong (Cangjie) quando il programma di installazione ti chiede la tastiera. Omarchy configura automaticamente la tastiera e il motore di input corrispondente, anche durante la configurazione offline al primo avvio. Il giapponese usa Mozc, il coreano usa l'Hangul standard a due serie, il cinese semplificato usa Pinyin, Taiwan usa la disposizione Zhuyin standard di Chewing e Hong Kong usa Cangjie con le forme dei caratteri di Hong Kong. Japanese (US keyboard) fornisce Mozc con un layout di tastiera US. I tasti Hangul, Zhuyin e Cangjie restano nelle loro posizioni standard anche quando digiti lettere latine con Dvorak, Colemak o AZERTY. Se hai aggiunto Hangul o Chewing prima di questo, deselezionalo e riselezionalo in _Setup > Keyboard > Input Methods_ per spostare lì i suoi tasti; Omarchy non tocca un motore con cui stai già digitando.

La digitazione inizia in modalità latina. Premi `Super + I` per passare ciclicamente tra i metodi di input configurati e `Super + Shift + I` per tornare indietro ciclicamente. Tocca `Shift` da solo per uscire da un metodo di input come Pinyin e passare alle lettere latine, e toccalo di nuovo per tornare indietro, come funzionano Sogou, Microsoft Pinyin e macOS; `Shift` più una lettera continua a digitare una maiuscola. Sulle tastiere giapponesi, 全角/半角 attiva/disattiva l'input, 変換 lo attiva e 無変換 lo disattiva. Con il coreano, 한/영 passa a Hangul e 한자 converte in Hanja, sia che la tastiera abbia tasti dedicati sia che invii Right Alt e Right Ctrl per essi, come fanno molti laptop, quindi Right Alt e Right Ctrl non sono semplici modificatori in quel caso; la dettatura si attiva/disattiva invece con Alt + Space. `Ctrl + Space` resta disponibile per Tmux e Herdr; `Shift + CapsLock` resta il tasto compose.

L'indicatore della tastiera appare a destra della barra quando hai più layout di tastiera o metodi di input. Cliccalo per cambiare lingua di input; Japanese mostra あ per l'hiragana. Per le scelte dei caratteri giapponesi, passa a Japanese, digita una parola come `nihongo`, quindi premi Space due volte. Premi Enter per accettare la tua scelta. Se hai anche più layout di tastiera, fai clic con il tasto destro sull'indicatore per passarli ciclicamente.

Usa _Setup > Keyboard > Keyboard Inputs_ per selezionare layout come English e French, tra le stesse scelte offerte durante l'installazione. Usa _Setup > Keyboard > Input Methods_ per selezionare quali motori di composizione sono attivi. Entrambi i selettori si aprono all'interno del menu Omarchy con le selezioni correnti contrassegnate. Fai clic o premi Enter per attivare/disattivare una scelta; ogni modifica si applica immediatamente. Deselezionare un metodo di input lo rimuove dal ciclo senza disinstallarlo; la tastiera resta disponibile.

Esegui `omarchy setup keyboard` o `omarchy setup input` per aprire gli stessi selettori. Per aggiungere una lingua dalla riga di comando, usa `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` o `cangjie5`. Quick, Boshiamy e Array sono inclusi nello stesso pacchetto di Cangjie e compaiono nel selettore Input Methods. I tuoi tasti di commutazione personalizzati vengono preservati. Per layout o tasti alternativi dei motori, installa `fcitx5-configtool` con `omarchy pkg add fcitx5-configtool` e avvialo da un terminale. Selezionare una lingua di input non cambia la lingua del desktop. Scegliere Japanese, Korean o Chinese in _Setup > Language_ aggiunge il relativo metodo di input quando non ne hai ancora nessuno.

Usa `Super + I` per passare ciclicamente tra metodi di input o layout di tastiera e `Super + Shift + I` per tornare nell'altra direzione, così con tre configurati puoi muoverti tra due vicini. L'indicatore di input appare a destra della barra solo quando è configurato più di un metodo di input o layout. Questa scorciatoia del desktop funziona insieme ai tuoi tasti di commutazione Fcitx esistenti; puoi sovrascriverla in `~/.config/hypr/bindings.lua`. I motori di input e le sequenze compose usano il servizio [Fcitx5](https://fcitx-im.org/) già in esecuzione in ogni sessione.

### Usare ALT come SUPER

Su alcune tastiere non è comodo usare il tasto meta primario (tasto Windows/cmd) come SUPER. Puoi cambiarlo in ALT usando questa modifica:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
