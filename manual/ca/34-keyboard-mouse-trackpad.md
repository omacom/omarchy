# Teclat, ratolí i trackpad

Hyprland us permet configurar totes les entrades amb molt de detall. Podeu canviar la repetició del teclat perquè sigui supersònicament ràpida o fer que el trackpad utilitzi el desplaçament natural. Ho canvieu tot a `~/.config/hypr/input.lua`, al qual també podeu accedir mitjançant _Setup > Input_ al menú d'Omarchy (`Super + Space`). Qualsevol cosa que hi definiu substitueix els valors per defecte d'Omarchy.

Aquí en teniu un exemple:

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

Podeu [consultar totes les opcions d'entrada](https://wiki.hypr.land/Configuring/Basics/Variables/#input) al wiki de Hyprland sobre entrades.

CapsLock funciona com un bloqueig de majúscules normal, i `Shift + CapsLock` és la tecla de composició per als [emojis ràpids](07-hotkeys.md#quick-emojis) i [altres complecions](07-hotkeys.md#quick-completions). Si preferiu tenir la tecla de composició en un altre lloc, substituïu `omarchy:shift_caps_compose` a `kb_options`. Per exemple, això mou la tecla de composició a Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gestos del trackpad

Llisqueu sobre el trackpad per moure-us per l'escriptori:

| Gest | Acció |
| --- | --- |
| Tres dits a l'esquerra / a la dreta | Espai de treball anterior / següent, inclosos els buits |
| Tres dits amunt | Activa o desactiva la consola d'IA |
| Tres dits avall | Obre el menú d'Omarchy |
| Quatre dits a l'esquerra / a la dreta | Mou la finestra activa a l'espai de treball anterior / següent |
| Quatre dits avall | Activa o desactiva la pantalla completa |

Per canviar-ne un, desactiveu-lo a `~/.config/hypr/input.lua` abans d'afegir el vostre propi [gest del trackpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), ja que Hyprland no acceptarà dos gestos amb els mateixos dits i la mateixa direcció:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Per desactivar tots els gestos d'Omarchy, definiu `omarchy_default_gestures = false` a prop de la part superior de `~/.config/hypr/hyprland.lua`, abans que es carreguin els valors per defecte d'Omarchy.

Als portàtils Dell XPS amb un trackpad hàptic, també podeu definir la força del clic com a baixa, mitjana o alta a _Trigger > Hardware > Touchpad Haptics_.

### Escriure en xinès, japonès i altres llengües

Seleccioneu japonès, coreà, xinès (simplificat, Pinyin), Taiwan (Zhuyin) o Hong Kong (Cangjie) quan l'instal·lador us demani el teclat. Omarchy configura automàticament el teclat i el motor d'entrada corresponent, també durant la configuració sense connexió del primer arrencament. El japonès utilitza Mozc, el coreà utilitza el Hangul estàndard de dos conjunts, el xinès simplificat utilitza Pinyin, Taiwan utilitza la disposició Zhuyin estàndard de Chewing i Hong Kong utilitza Cangjie amb les formes de caràcters de Hong Kong. Japonès (teclat US) proporciona Mozc amb una disposició de teclat US. Les tecles de Hangul, Zhuyin i Cangjie es mantenen a les seves posicions estàndard encara que escriviu lletres llatines amb Dvorak, Colemak o AZERTY. Si abans d'això havíeu afegit Hangul o Chewing, deseleccioneu-lo i torneu-lo a seleccionar a _Setup > Typing > Input Methods_ per moure-hi les seves tecles; Omarchy no toca un motor amb el qual ja escriviu.

L'escriptura comença en mode llatí. Premeu `Super + I` per recórrer els mètodes d'entrada configurats, i `Super + Shift + I` per recórrer-los en sentit contrari. Toqueu `Shift` tot sol per sortir d'un mètode d'entrada com Pinyin i passar a les lletres llatines, i torneu-lo a tocar per tornar-hi, de la mateixa manera que funcionen Sogou, Microsoft Pinyin i macOS; `Shift` més una lletra continua escrivint una majúscula. Als teclats japonesos, 全角/半角 activa o desactiva l'entrada, 変換 l'activa i 無変換 la desactiva. Amb el coreà, 한/영 canvia Hangul i 한자 converteix a Hanja, tant si el vostre teclat té tecles dedicades com si envia Right Alt i Right Ctrl per a aquestes funcions, com fan molts portàtils, de manera que Right Alt i Right Ctrl no són modificadors normals en aquest cas; el dictat s'activa o es desactiva amb Alt + Space, en canvi. `Ctrl + Space` continua disponible per a Tmux i Herdr; `Shift + CapsLock` continua sent la tecla de composició.

L'indicador del teclat apareix a la dreta de la barra quan teniu diverses disposicions de teclat o mètodes d'entrada. Feu-hi clic per canviar de llengua d'entrada; el japonès mostra あ per a l'hiragana. Per a les opcions de caràcters japonesos, canvieu al japonès, escriviu una paraula com ara `nihongo` i després premeu Space dues vegades. Premeu Enter per acceptar la vostra elecció. Si també teniu diverses disposicions de teclat, feu clic amb el botó dret a l'indicador per recórrer-les.

Utilitzeu _Setup > Typing > Keyboard Layouts_ per seleccionar disposicions com ara l'anglès i el francès, entre les mateixes opcions ofertes durant la instal·lació. Utilitzeu _Setup > Typing > Input Methods_ per seleccionar quins motors de composició estan actius. Tots dos selectors s'obren dins del menú d'Omarchy amb les vostres seleccions actuals marcades. Feu clic o premeu Enter per activar o desactivar una opció; cada canvi s'aplica immediatament. Deseleccionar un mètode d'entrada l'elimina del cicle sense desinstal·lar-lo; el teclat continua disponible.

Executeu `omarchy setup keyboard` o `omarchy setup input` per obrir els mateixos selectors. Per afegir una llengua des de la línia d'ordres, utilitzeu `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` o `cangjie5`. Quick, Boshiamy i Array venen en el mateix paquet que Cangjie i apareixen al selector Input Methods. Les vostres tecles de canvi personalitzades es conserven. Per a disposicions o tecles alternatives del motor, instal·leu `fcitx5-configtool` amb `omarchy pkg add fcitx5-configtool` i inicieu-lo des d'un terminal. Seleccionar una llengua d'entrada no canvia la llengua de l'escriptori. Triar japonès, coreà o xinès a _Setup > Language_ hi afegeix el seu mètode d'entrada quan encara no en teniu cap.

Utilitzeu `Super + I` per recórrer els mètodes d'entrada o les disposicions de teclat, i `Super + Shift + I` per tornar en sentit contrari, de manera que, amb tres de configurats, podeu moure-us entre dos veïns. L'indicador d'entrada apareix a la dreta de la barra només quan hi ha més d'un mètode d'entrada o disposició configurat. Aquesta assignació de l'escriptori funciona juntament amb les vostres tecles de canvi de Fcitx existents; la podeu substituir a `~/.config/hypr/bindings.lua`. Els motors d'entrada i les seqüències de composició utilitzen el servei [Fcitx5](https://fcitx-im.org/) que ja s'executa a cada sessió.

### Utilitzar ALT com a SUPER

En alguns teclats, no és còmode utilitzar la tecla meta principal (tecla Windows/cmd) com a SUPER. Podeu canviar-ho perquè sigui ALT, en canvi, amb aquest canvi:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
