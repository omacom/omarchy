# Teclat, ratolí, panell tàctil

Hyprland et permet configurar totes les entrades amb molt de detall. Pots canviar la repetició del teclat perquè sigui supersònicament ràpida o fer que el panell tàctil faci servir el desplaçament natural. Tot això ho canvies a `~/.config/hypr/input.lua`, al qual també pots arribar mitjançant _Configuració > Entrada_ al menú d'Omarchy (`Super + Space`). Qualsevol cosa que hi defineixis substitueix els valors per defecte d'Omarchy.

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

Pots [veure totes les opcions d'entrada](https://wiki.hypr.land/Configuring/Basics/Variables/#input) al wiki de Hyprland per a les entrades.

CapsLock funciona com un bloqueig de majúscules normal, i `Shift + CapsLock` és la tecla de composició per als [emojis ràpids](07-hotkeys.md#quick-emojis) i [altres completaments](07-hotkeys.md#quick-completions). Si prefereixes tenir la tecla de composició en un altre lloc, substitueix `omarchy:shift_caps_compose` a `kb_options`. Per exemple, això mou la tecla de composició a Alt dret:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gestos del panell tàctil

També pots activar els [gestos del panell tàctil](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), com ara fer lliscar tres dits per canviar d'espai de treball:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

En portàtils Dell XPS amb panell tàctil hàptic, també pots definir la força del clic a baixa, mitjana o alta a _Activa > Maquinari > Hàptica del panell_.

### Escriure en xinès, japonès i altres llengües

Selecciona japonès, coreà, xinès (simplificat, Pinyin) o xinès (tradicional, Zhuyin) quan l'instal·lador et demani el teclat. Omarchy configura automàticament el teclat i el motor d'entrada corresponent, també durant la configuració de primera arrencada fora de línia. El japonès fa servir Mozc, el coreà fa servir Hangul estàndard de dos conjunts, el xinès simplificat fa servir Pinyin i el xinès tradicional fa servir la disposició Zhuyin estàndard de Chewing. Japonès (teclat dels EUA) ofereix Mozc amb una disposició de teclat dels EUA.

L'escriptura comença en mode llatí. Prem `Super + I` per recórrer els mètodes d'entrada configurats, i `Super + Shift + I` per recórrer-los enrere. Toca `Shift` tot sol per sortir d'un mètode d'entrada com Pinyin cap a les lletres llatines, i toca'l un altre cop per tornar-hi, de la manera com funcionen Sogou, Microsoft Pinyin i macOS; `Shift` més una lletra continua escrivint una majúscula. En teclats japonesos, 全角/半角 commuta l'entrada, 変換 l'activa i 無変換 la desactiva. En una disposició de teclat coreana, les tecles dedicades 한/영 i 한자 canvien a Hangul i converteixen a Hanja. `Ctrl + Space` continua disponible per a Tmux i Herdr; `Shift + CapsLock` continua sent la tecla de composició.

L'indicador del teclat apareix a la dreta de la barra quan tens diverses disposicions de teclat o mètodes d'entrada. Fes-hi clic per canviar de llengua d'entrada; el japonès mostra あ per a l'hiragana. Per a les tries de caràcters japonesos, canvia a japonès, escriu una paraula com ara `nihongo` i després prem Space dues vegades. Prem Enter per acceptar la teva tria. Si també tens diverses disposicions de teclat, fes clic amb el botó dret a l'indicador per recórrer-les.

Fes servir _Configuració > Escriptura > Disposicions de teclat_ per seleccionar disposicions com ara anglès i francès, entre les mateixes opcions que s'ofereixen durant la instal·lació. Fes servir _Configuració > Escriptura > Mètodes d'entrada_ per seleccionar quins motors de composició estan actius. Tots dos selectors s'obren dins del menú d'Omarchy amb les teves seleccions actuals marcades. Fes clic o prem Enter per commutar una tria; cada canvi s'aplica immediatament. Desseleccionar un mètode d'entrada el treu del cicle sense desinstal·lar-lo; el teclat continua disponible.

Executa `omarchy setup keyboard` o `omarchy setup input` per obrir els mateixos selectors. Per afegir una llengua des de la línia d'ordres, fes servir `omarchy setup input mozc`, `hangul`, `pinyin` o `chewing`. Les teves tecles de canvi personalitzades es preserven. Per a disposicions o tecles de motor alternatives, instal·la `fcitx5-configtool` amb `omarchy pkg add fcitx5-configtool` i llança'l des d'un terminal. Seleccionar una llengua d'entrada no canvia la llengua de l'escriptori.

Fes servir `Super + I` per recórrer els mètodes d'entrada o les disposicions de teclat, i `Super + Shift + I` per anar en l'altre sentit, de manera que amb tres de configurats pots moure't entre dos veïns. L'indicador d'entrada apareix a la dreta de la barra només quan hi ha més d'un mètode d'entrada o disposició configurats. Aquesta drecera d'escriptori funciona juntament amb les teves tecles de canvi de Fcitx existents; la pots anul·lar a `~/.config/hypr/bindings.lua`. Els motors d'entrada i les seqüències de composició fan servir el servei [Fcitx5](https://fcitx-im.org/) que ja s'executa a cada sessió.

### Fes servir ALT com a SUPER

En alguns teclats, no és convenient fer servir la tecla meta principal (la tecla de Windows/cmd) com a SUPER. Pots canviar-ho perquè sigui ALT en el seu lloc amb aquest canvi:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
