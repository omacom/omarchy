# Teclat, ratolí, panell tàctil

Hyprland et permet configurar totes les entrades amb molt de detall. Pots fer que la repetició del teclat sigui supersònicament ràpida o fer que el panell tàctil utilitzi el desplaçament natural. Ho canvies tot a `~/.config/hypr/input.lua`, al qual també pots arribar mitjançant _Configuració > Entrada_ al menú d'Omarchy (`Super + Space`). Qualsevol cosa que hi defineixis substitueix els valors predeterminats d'Omarchy.

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

Pots [veure totes les opcions d'entrada](https://wiki.hypr.land/Configuring/Basics/Variables/#input) a la wiki de Hyprland per a les entrades.

CapsLock funciona com un bloqueig de majúscules normal, i `Shift + CapsLock` és la tecla de composició per a [emojis ràpids](07-hotkeys.md#quick-emojis) i [altres complecions](07-hotkeys.md#quick-completions). Si prefereixes tenir la tecla de composició en un altre lloc, substitueix `omarchy:shift_caps_compose` a `kb_options`. Per exemple, això mou la tecla de composició a Alt dret:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Tecles de funció

La fila superior d'un teclat de portàtil envia les tecles multimèdia (volum, brillantor, etc.) per defecte, i si mantens premuda `Fn` obtens F1-F12; `Fn + Esc` ho bloqueja en el sentit contrari fins que ho tornis a prémer. La majoria de teclats recorden aquest bloqueig ells mateixos. Els portàtils ASUS i els teclats d'estil Apple ho deixen en mans de Linux, que els inicia amb les tecles multimèdia a cada arrencament. Perquè comencin amb F1-F12, executa `omarchy device keyboard toprow fnkeys` (i `omarchy device keyboard toprow mediakeys` per tornar enrere); en alguns portàtils pren efecte després d'un reinici. Els Mac amb Apple Silicon mantenen la seva pròpia configuració.

### Gestos del panell tàctil

Fes lliscar els dits sobre el panell tàctil per moure't per l'escriptori:

| Gest | Acció |
| --- | --- |
| Tres dits a l'esquerra / a la dreta | Espai de treball anterior / següent, inclosos els buits |
| Tres dits amunt | Activa o desactiva la consola d'IA |
| Tres dits avall | Obre el menú d'Omarchy |
| Quatre dits a l'esquerra / a la dreta | Mou la finestra activa a l'espai de treball anterior / següent |
| Quatre dits avall | Activa o desactiva la pantalla completa |

Per canviar-ne un, desactiva'l a `~/.config/hypr/input.lua` abans d'afegir el teu propi [gest del panell tàctil](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), ja que Hyprland no acceptarà dos gestos amb els mateixos dits i la mateixa direcció:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Per desactivar tots els gestos d'Omarchy, defineix `omarchy_default_gestures = false` a prop de la part superior de `~/.config/hypr/hyprland.lua`, abans que es carreguin els valors predeterminats d'Omarchy.

Als portàtils Dell XPS amb un panell tàctil hàptic, també pots definir la força del clic en baixa, mitjana o alta a _Activador > Maquinari > Resposta hàptica del panell tàctil_.

### Escriure en xinès, japonès i altres llengües

Selecciona japonès, coreà, xinès (simplificat, Pinyin), Taiwan (Zhuyin) o Hong Kong (Cangjie) quan l'instal·lador et demani el teclat. Omarchy configura automàticament el teclat i el motor d'entrada corresponent, també durant la configuració sense connexió del primer arrencament. El japonès utilitza Mozc, el coreà utilitza Hangul estàndard de dos conjunts, el xinès simplificat utilitza Pinyin, Taiwan utilitza la disposició Zhuyin estàndard de Chewing, i Hong Kong utilitza Cangjie amb formes de caràcters de Hong Kong. Japonès (teclat dels EUA) proporciona Mozc amb una disposició de teclat dels EUA. Les tecles Hangul, Zhuyin i Cangjie es mantenen en les seves posicions estàndard fins i tot quan escrius lletres llatines amb Dvorak, Colemak o AZERTY. Si has afegit Hangul o Chewing abans d'això, deselecciona'l i torna'l a seleccionar a _Configuració > Teclat > Mètodes d'entrada_ per moure-hi les teves tecles; Omarchy no toca un motor amb el qual ja escrius.

L'escriptura comença en mode llatí. Prem `Super + I` per passar cíclicament pels mètodes d'entrada configurats, i `Super + Shift + I` per fer el cicle en sentit invers. Toca `Shift` tot sol per sortir d'un mètode d'entrada com Pinyin i passar a les lletres llatines, i torna'l a tocar per tornar-hi, de la manera com funcionen Sogou, Microsoft Pinyin i macOS; `Shift` més una lletra continua escrivint una majúscula. Als teclats japonesos, 全角/半角 activa o desactiva l'entrada, 変換 l'activa i 無変換 la desactiva. Amb el coreà, 한/영 canvia a Hangul i 한자 converteix a Hanja, tant si el teclat té tecles dedicades com si envia Alt dret i Ctrl dret per a aquestes funcions, com fan molts portàtils, de manera que Alt dret i Ctrl dret no són modificadors normals allà; el dictat s'activa o es desactiva amb Alt + Space. `Ctrl + Space` continua disponible per a Tmux i Herdr; `Shift + CapsLock` continua sent la tecla de composició.

L'indicador del teclat apareix a la dreta de la barra quan tens diverses disposicions de teclat o mètodes d'entrada. Fes-hi clic per canviar de llengua d'entrada; el japonès mostra あ per a hiragana. Per a les opcions de caràcters japonesos, canvia a japonès, escriu una paraula com ara `nihongo` i prem Space dues vegades. Prem Enter per acceptar la teva elecció. Si també tens diverses disposicions de teclat, fes clic amb el botó dret a l'indicador per passar-hi cíclicament.

Utilitza _Configuració > Teclat > Entrades de teclat_ per seleccionar disposicions com l'anglès i el francès, entre les mateixes opcions ofertes durant la instal·lació. Utilitza _Configuració > Teclat > Mètodes d'entrada_ per seleccionar quins motors de composició estan actius. Tots dos selectors s'obren dins del menú d'Omarchy amb les teves seleccions actuals marcades. Fes clic o prem Enter per activar o desactivar una opció; cada canvi s'aplica immediatament. Deseleccionar un mètode d'entrada l'elimina del cicle sense desinstal·lar-lo; el teclat continua disponible.

Executa `omarchy setup keyboard` o `omarchy setup input` per obrir els mateixos selectors. Per afegir una llengua des de la línia d'ordres, utilitza `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` o `cangjie5`. Quick, Boshiamy i Array venen en el mateix paquet que Cangjie i apareixen al selector de Mètodes d'entrada. Les teves tecles de canvi personalitzades es conserven. Per a disposicions o tecles alternatives del motor, instal·la `fcitx5-configtool` amb `omarchy pkg add fcitx5-configtool` i inicia'l des d'un terminal. Seleccionar una llengua d'entrada no canvia la llengua de l'escriptori. Triar japonès, coreà o xinès a _Configuració > Llengua_ hi afegeix el seu mètode d'entrada quan encara no en tens cap.

Utilitza `Super + I` per passar cíclicament pels mètodes d'entrada o les disposicions de teclat, i `Super + Shift + I` per anar en l'altra direcció, de manera que, amb tres de configurats, pots moure't entre dos veïns. L'indicador d'entrada apareix a la dreta de la barra només quan hi ha més d'un mètode d'entrada o disposició configurat. Aquesta drecera d'escriptori funciona juntament amb les teves tecles de canvi existents de Fcitx; la pots anul·lar a `~/.config/hypr/bindings.lua`. Els motors d'entrada i les seqüències de composició utilitzen el servei [Fcitx5](https://fcitx-im.org/) que ja s'executa en cada sessió.

### Utilitza ALT com a SUPER

En alguns teclats, no és còmode utilitzar la tecla meta principal (la tecla Windows/cmd) com a SUPER. Pots canviar-ho perquè sigui ALT, amb aquest canvi:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
