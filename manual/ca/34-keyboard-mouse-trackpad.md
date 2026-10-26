# Teclat, ratolí i panell tàctil

Hyprland et permet configurar totes les entrades amb molt de detall. Pots fer que la repetició del teclat sigui supersònicament ràpida o fer que el panell tàctil utilitzi el desplaçament natural. Ho canvies tot a `~/.config/hypr/input.lua`, on també pots arribar mitjançant _Setup > Input_ al menú d'Omarchy (`Super + Space`). Qualsevol cosa que hi defineixis substitueix els valors per defecte d'Omarchy.

Aquí tens un exemple:

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

Pots [consultar totes les opcions d'entrada](https://wiki.hypr.land/Configuring/Basics/Variables/#input) a la wiki de Hyprland per a les entrades.

CapsLock funciona com un Caps Lock normal, i `Shift + CapsLock` és la tecla de composició per als [emojis ràpids](07-hotkeys.md#quick-emojis) i [altres completacions](07-hotkeys.md#quick-completions). Si prefereixes tenir la tecla de composició en un altre lloc, substitueix `omarchy:shift_caps_compose` a `kb_options`. Per exemple, això mou la tecla de composició a Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gestos del panell tàctil

També pots activar els [gestos del panell tàctil](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), com lliscar amb tres dits per canviar d'espais de treball:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

Als portàtils Dell XPS amb un panell tàctil hàptic, també pots definir la força del clic com a baixa, mitjana o alta a _Trigger > Hardware > Touchpad Haptics_.

### Escriure en xinès, japonès i altres llengües

Selecciona japonès, coreà, xinès (simplificat, Pinyin), Taiwan (Zhuyin) o Hong Kong (Cangjie) quan l'instal·lador et demani el teclat. Omarchy configura el teclat i el motor d'entrada corresponent automàticament, també durant la configuració sense connexió del primer arrencada. El japonès utilitza Mozc, el coreà utilitza l'Hangul estàndard de dos conjunts, el xinès simplificat utilitza Pinyin, Taiwan utilitza la disposició Zhuyin estàndard de Chewing, i Hong Kong utilitza Cangjie amb les formes de caràcters de Hong Kong. Japonès (teclat dels EUA) proporciona Mozc amb una disposició de teclat dels EUA. Les tecles Hangul, Zhuyin i Cangjie es mantenen en les seves posicions estàndard encara que escriguis lletres llatines amb Dvorak, Colemak o AZERTY. Si havies afegit Hangul o Chewing abans d'això, desselecciona'l i torna'l a seleccionar a _Setup > Typing > Input Methods_ per moure-hi les seves tecles; Omarchy no toca un motor amb el qual ja escriguis.

L'escriptura comença en mode llatí. Prem `Super + I` per recórrer els mètodes d'entrada configurats, i `Super + Shift + I` per recórrer-los en sentit contrari. Toca `Shift` per si sol per sortir d'un mètode d'entrada com Pinyin cap a les lletres llatines, i toca'l de nou per tornar-hi, de la manera com funcionen Sogou, Microsoft Pinyin i macOS; `Shift` més una lletra continua escrivint una majúscula. Als teclats japonesos, 全角/半角 alterna l'entrada, 変換 l'activa i 無変換 la desactiva. Amb el coreà, 한/영 canvia a Hangul i 한자 converteix a Hanja, tant si el teu teclat té tecles dedicades com si envia Right Alt i Right Ctrl per a aquestes funcions, com fan molts portàtils, de manera que Right Alt i Right Ctrl no són modificadors normals allà; el prémer per parlar del dictat es manté a F9. `Ctrl + Space` continua disponible per a Tmux i Herdr; `Shift + CapsLock` continua sent la tecla de composició.

L'indicador del teclat apareix a la dreta de la barra quan tens diverses disposicions de teclat o mètodes d'entrada. Fes-hi clic per canviar de llengua d'entrada; el japonès mostra あ per a l'hiragana. Per a les opcions de caràcters japonesos, canvia a japonès, escriu una paraula com ara `nihongo`, i prem Space dues vegades. Prem Enter per acceptar la teva elecció. Si també tens diverses disposicions de teclat, fes clic amb el botó dret a l'indicador per recórrer-les.

Utilitza _Setup > Typing > Keyboard Layouts_ per seleccionar disposicions com ara l'anglès i el francès, entre les mateixes opcions que s'ofereixen durant la instal·lació. Utilitza _Setup > Typing > Input Methods_ per seleccionar quins motors de composició estan actius. Tots dos selectors s'obren dins del menú d'Omarchy amb les teves seleccions actuals marcades. Fes clic o prem Enter per activar o desactivar una opció; cada canvi s'aplica immediatament. Desseleccionar un mètode d'entrada l'elimina del cicle sense desinstal·lar-lo; el teclat continua disponible.

Executa `omarchy setup keyboard` o `omarchy setup input` per obrir els mateixos selectors. Per afegir una llengua des de la línia d'ordres, utilitza `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` o `cangjie5`. Quick, Boshiamy i Array venen en el mateix paquet que Cangjie i apareixen al selector Input Methods. Les teves tecles de canvi personalitzades es conserven. Per a disposicions o tecles alternatives del motor, instal·la `fcitx5-configtool` amb `omarchy pkg add fcitx5-configtool` i executa'l des d'un terminal. Seleccionar una llengua d'entrada no canvia la llengua de l'escriptori. Triar japonès, coreà o xinès a _Setup > Language_ hi afegeix el seu mètode d'entrada quan encara no en tens cap.

Utilitza `Super + I` per recórrer els mètodes d'entrada o les disposicions de teclat, i `Super + Shift + I` per anar en l'altre sentit, de manera que amb tres de configurats pots moure't entre dos veïns. L'indicador d'entrada apareix a la dreta de la barra només quan hi ha més d'un mètode d'entrada o disposició configurat. Aquesta drecera d'escriptori funciona juntament amb les teves tecles de canvi de Fcitx existents; pots substituir-la a `~/.config/hypr/bindings.lua`. Els motors d'entrada i les seqüències de composició utilitzen el servei [Fcitx5](https://fcitx-im.org/) que ja s'executa a cada sessió.

### Utilitza ALT com a SUPER

En alguns teclats, no és còmode utilitzar la tecla meta principal (la tecla Windows/cmd) com a SUPER. Pots canviar això perquè sigui ALT, amb aquest canvi:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
