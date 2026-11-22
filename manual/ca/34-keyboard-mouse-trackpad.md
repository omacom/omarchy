# Teclat, ratolí, trackpad

Hyprland et permet configurar totes les teves entrades amb molt de detall. Pots fer que la repetició del teclat sigui supersònicament ràpida o fer que el trackpad faci servir el desplaçament natural. Tot això ho canvies a `~/.config/hypr/input.lua`, on també pots arribar mitjançant _Setup > Input_ al menú d'Omarchy (`Super + Space`). Qualsevol cosa que hi defineixis substitueix els valors per defecte d'Omarchy.

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

Pots [veure totes les opcions d'entrada](https://wiki.hypr.land/Configuring/Basics/Variables/#input) a la wiki de Hyprland sobre les entrades.

CapsLock funciona com un Caps Lock normal, i `Shift + CapsLock` és la tecla de composició per als [emojis ràpids](07-hotkeys.md#quick-emojis) i [altres complecions](07-hotkeys.md#quick-completions). Si prefereixes tenir la tecla de composició en un altre lloc, substitueix `omarchy:shift_caps_compose` a `kb_options`. Per exemple, això mou la tecla de composició a Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Tecles de funció

La fila superior d'un teclat de portàtil envia per defecte les tecles multimèdia (volum, brillantor i la resta), i mantenir premuda `Fn` dona F1-F12; `Fn + Esc` ho bloqueja en el sentit contrari fins que la tornis a prémer. La majoria de teclats recorden aquest bloqueig per si mateixos. Els portàtils ASUS i els teclats d'estil Apple ho deixen a Linux, que els inicia amb les tecles multimèdia a cada arrencada. Perquè comencin amb F1-F12, executa `omarchy device keyboard toprow fnkeys` (i `omarchy device keyboard toprow mediakeys` per tornar enrere); en alguns portàtils s'aplica després de reiniciar. Els Mac amb Apple Silicon mantenen la seva pròpia configuració.

### Gestos del trackpad

Llisca pel trackpad per moure't per l'escriptori:

| Gest | Acció |
| --- | --- |
| Tres dits a l'esquerra / a la dreta | Espai de treball anterior / següent, inclosos els buits |
| Tres dits amunt | Activa o desactiva la consola d'IA |
| Tres dits avall | Obre el menú d'Omarchy |
| Quatre dits a l'esquerra / a la dreta | Mou la finestra activa a l'espai de treball anterior / següent |
| Quatre dits avall | Activa o desactiva la pantalla completa |

Per canviar-ne un, desactiva'l a `~/.config/hypr/input.lua` abans d'afegir el teu propi [gest del touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), ja que Hyprland no acceptarà dos gestos amb els mateixos dits i la mateixa direcció:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Per desactivar tots els gestos d'Omarchy, defineix `omarchy_default_gestures = false` a prop de la part superior de `~/.config/hypr/hyprland.lua`, abans que es carreguin els valors per defecte d'Omarchy.

En portàtils Dell XPS amb un touchpad hàptic, també pots definir la força del clic com a baixa, mitjana o alta a _Trigger > Hardware > Touchpad Haptics_.

### Escriure en xinès, japonès i altres llengües

Selecciona japonès, coreà, xinès (simplificat, Pinyin), Taiwan (Zhuyin) o Hong Kong (Cangjie) quan l'instal·lador et demani el teclat. Omarchy configura automàticament el teclat i el motor d'entrada corresponent, també durant la configuració fora de línia de la primera arrencada. El japonès fa servir Mozc, el coreà fa servir el Hangul estàndard de dos conjunts, el xinès simplificat fa servir Pinyin, Taiwan fa servir la disposició Zhuyin estàndard de Chewing, i Hong Kong fa servir Cangjie amb les formes de caràcters de Hong Kong. Japonès (teclat US) proporciona Mozc amb una disposició de teclat US. Les tecles de Hangul, Zhuyin i Cangjie es mantenen en les seves posicions estàndard fins i tot quan escrius lletres llatines amb Dvorak, Colemak o AZERTY. Si vas afegir Hangul o Chewing abans d'això, desselecciona'l i torna'l a seleccionar a _Setup > Keyboard > Input Methods_ per moure-hi les seves tecles; Omarchy no toca un motor amb el qual ja escrius.

L'escriptura comença en mode llatí. Prem `Super + I` per recórrer els mètodes d'entrada configurats, i `Super + Shift + I` per recórrer-los enrere. Toca `Shift` sol per sortir d'un mètode d'entrada com Pinyin cap a les lletres llatines, i toca'l de nou per tornar-hi, tal com funcionen Sogou, Microsoft Pinyin i macOS; `Shift` més una lletra encara escriu una majúscula. En els teclats japonesos, 全角/半角 activa o desactiva l'entrada, 変換 l'activa i 無変換 la desactiva. Amb el coreà, 한/영 canvia Hangul i 한자 converteix a Hanja, tant si el teu teclat té tecles dedicades com si envia Right Alt i Right Ctrl per a aquestes funcions, com fan molts portàtils, de manera que Right Alt i Right Ctrl no són modificadors simples en aquest cas; el dictat s'activa o es desactiva amb Alt + Space. `Ctrl + Space` continua disponible per a Tmux i Herdr; `Shift + CapsLock` continua sent la tecla de composició.

L'indicador de teclat apareix a la dreta de la barra quan tens diverses disposicions de teclat o mètodes d'entrada. Fes-hi clic per canviar de llengua d'entrada; el japonès mostra あ per a l'hiragana. Per a les opcions de caràcters japonesos, canvia a japonès, escriu una paraula com ara `nihongo`, i prem Space dues vegades. Prem Enter per acceptar la teva elecció. Si també tens diverses disposicions de teclat, fes clic amb el botó dret a l'indicador per recórrer-les.

Fes servir _Setup > Keyboard > Keyboard Inputs_ per seleccionar disposicions com ara l'anglès i el francès, entre les mateixes opcions que s'ofereixen durant la instal·lació. Fes servir _Setup > Keyboard > Input Methods_ per seleccionar quins motors de composició estan actius. Tots dos selectors s'obren dins del menú d'Omarchy amb les teves seleccions actuals marcades. Fes clic o prem Enter per activar o desactivar una opció; cada canvi s'aplica immediatament. Desseleccionar un mètode d'entrada l'elimina del cicle sense desinstal·lar-lo; el teclat continua disponible.

Executa `omarchy setup keyboard` o `omarchy setup input` per obrir els mateixos selectors. Per afegir una llengua des de la línia d'ordres, fes servir `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` o `cangjie5`. Quick, Boshiamy i Array venen en el mateix paquet que Cangjie i apareixen al selector Input Methods. Les teves tecles de canvi personalitzades es conserven. Per a disposicions o tecles alternatives del motor, instal·la `fcitx5-configtool` amb `omarchy pkg add fcitx5-configtool` i inicia'l des d'un terminal. Seleccionar una llengua d'entrada no canvia la llengua de l'escriptori. Triar japonès, coreà o xinès a _Setup > Region > Language_ hi afegeix el seu mètode d'entrada quan encara no en tens cap.

Fes servir `Super + I` per recórrer els mètodes d'entrada o les disposicions de teclat, i `Super + Shift + I` per anar en l'altre sentit, de manera que amb tres de configurats pots moure't entre dos veïns. L'indicador d'entrada apareix a la dreta de la barra només quan hi ha més d'un mètode d'entrada o disposició configurat. Aquesta assignació de l'escriptori funciona juntament amb les teves tecles de canvi Fcitx existents; la pots sobreescriure a `~/.config/hypr/bindings.lua`. Els motors d'entrada i les seqüències de composició fan servir el servei [Fcitx5](https://fcitx-im.org/) que ja s'executa en cada sessió.

### Fes servir ALT com a SUPER

En alguns teclats, no és còmode fer servir la tecla meta principal (tecla Windows/cmd) com a SUPER. Pots canviar-ho perquè sigui ALT amb aquest canvi:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
