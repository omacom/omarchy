# Teclado, ratón, trackpad

Hyprland te permite configurar todas tus entradas con gran detalle. Puedes hacer que la repetición del teclado sea supersónicamente rápida o hacer que el trackpad use el desplazamiento natural. Todo lo cambias en `~/.config/hypr/input.lua`, al que también puedes llegar vía _Setup > Input_ en el menú de Omarchy (`Super + Space`). Todo lo que configures ahí reemplaza los valores predeterminados de Omarchy.

Aquí tienes un ejemplo:

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

Puedes [ver todas las opciones de entrada](https://wiki.hypr.land/Configuring/Basics/Variables/#input) en la wiki de Hyprland para entradas.

CapsLock funciona como un Bloq Mayús normal, y `Shift + CapsLock` es la tecla de composición para [emojis rápidos](07-hotkeys.md#quick-emojis) y [otras terminaciones](07-hotkeys.md#quick-completions). Si prefieres tener la tecla de composición en otro lugar, reemplaza `omarchy:shift_caps_compose` en `kb_options`. Por ejemplo, esto mueve la tecla de composición a Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gestos del trackpad

Desliza en el trackpad para moverte por el escritorio:

| Gesto | Acción |
| --- | --- |
| Tres dedos a la izquierda / derecha | Espacio de trabajo anterior / siguiente, incluidos los vacíos |
| Tres dedos hacia arriba | Activar o desactivar la consola de IA |
| Tres dedos hacia abajo | Abrir el menú de Omarchy |
| Cuatro dedos a la izquierda / derecha | Mover la ventana activa al espacio de trabajo anterior / siguiente |
| Cuatro dedos hacia abajo | Activar o desactivar pantalla completa |

Para cambiar uno, desactívalo en `~/.config/hypr/input.lua` antes de agregar tu propio [gesto del trackpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), ya que Hyprland no aceptará dos gestos con los mismos dedos y la misma dirección:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Para desactivar todos los gestos de Omarchy, establece `omarchy_default_gestures = false` cerca de la parte superior de `~/.config/hypr/hyprland.lua`, antes de que se carguen los valores predeterminados de Omarchy.

En laptops Dell XPS con un touchpad háptico, también puedes establecer la fuerza del clic en baja, media o alta en _Trigger > Hardware > Touchpad Haptics_.

### Escribir en chino, japonés y otros idiomas

Selecciona japonés, coreano, chino (simplificado, Pinyin), Taiwán (Zhuyin) o Hong Kong (Cangjie) cuando el instalador te pida tu teclado. Omarchy configura el teclado y el motor de entrada correspondiente automáticamente, incluso durante la configuración sin conexión del primer arranque. El japonés usa Mozc, el coreano usa Hangul estándar de dos conjuntos, el chino simplificado usa Pinyin, Taiwán usa la disposición Zhuyin estándar de Chewing, y Hong Kong usa Cangjie con formas de caracteres de Hong Kong. Japonés (teclado US) proporciona Mozc con una distribución de teclado US. Las teclas de Hangul, Zhuyin y Cangjie se mantienen en sus posiciones estándar incluso cuando escribes letras latinas con Dvorak, Colemak o AZERTY. Si agregaste Hangul o Chewing antes de esto, deselecciónalo y vuelve a seleccionarlo en _Setup > Typing > Input Methods_ para mover sus teclas ahí; Omarchy no toca un motor con el que ya escribes.

La escritura comienza en modo latino. Presiona `Super + I` para recorrer los métodos de entrada configurados, y `Super + Shift + I` para recorrerlos en sentido contrario. Toca `Shift` por sí solo para salir de un método de entrada como Pinyin y pasar a letras latinas, y tócalo de nuevo para volver, como funcionan Sogou, Microsoft Pinyin y macOS; `Shift` más una letra sigue escribiendo una mayúscula. En teclados japoneses, 全角/半角 alterna la entrada, 変換 la activa y 無変換 la desactiva. Con coreano, 한/영 cambia Hangul y 한자 convierte a Hanja, ya sea que tu teclado tenga teclas dedicadas o envíe Right Alt y Right Ctrl para ellas, como hacen muchas laptops, así que Right Alt y Right Ctrl no son modificadores simples ahí; el dictado push-to-talk se mantiene en F9. `Ctrl + Space` sigue disponible para Tmux y Herdr; `Shift + CapsLock` sigue siendo la tecla de composición.

El indicador del teclado aparece a la derecha de la barra cuando tienes múltiples distribuciones de teclado o métodos de entrada. Haz clic en él para cambiar los idiomas de entrada; el japonés muestra あ para hiragana. Para opciones de caracteres en japonés, cambia a japonés, escribe una palabra como `nihongo`, luego presiona Space dos veces. Presiona Enter para aceptar tu elección. Si también tienes múltiples distribuciones de teclado, haz clic derecho en el indicador para recorrerlas.

Usa _Setup > Typing > Keyboard Layouts_ para seleccionar distribuciones como inglés y francés, de las mismas opciones ofrecidas durante la instalación. Usa _Setup > Typing > Input Methods_ para seleccionar qué motores de composición están activos. Ambos selectores se abren dentro del menú de Omarchy con tus selecciones actuales marcadas. Haz clic o presiona Enter para activar o desactivar una opción; cada cambio se aplica de inmediato. Deseleccionar un método de entrada lo elimina del ciclo sin desinstalarlo; el teclado sigue disponible.

Ejecuta `omarchy setup keyboard` o `omarchy setup input` para abrir los mismos selectores. Para agregar un idioma desde la línea de comandos, usa `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` o `cangjie5`. Quick, Boshiamy y Array vienen en el mismo paquete que Cangjie y aparecen en el selector de Input Methods. Tus teclas personalizadas para cambiar se conservan. Para distribuciones o teclas alternativas del motor, instala `fcitx5-configtool` con `omarchy pkg add fcitx5-configtool` y ejecútalo desde una terminal. Seleccionar un idioma de entrada no cambia el idioma del escritorio. Elegir japonés, coreano o chino en _Setup > Language_ agrega su método de entrada cuando aún no tienes ninguno.

Usa `Super + I` para recorrer los métodos de entrada o las distribuciones de teclado, y `Super + Shift + I` para ir en la otra dirección, así que con tres configurados puedes moverte entre dos vecinos. El indicador de entrada aparece a la derecha de la barra solo cuando hay más de un método de entrada o distribución configurado. Esta combinación del escritorio funciona junto con tus teclas de cambio de Fcitx existentes; puedes anularla en `~/.config/hypr/bindings.lua`. Los motores de entrada y las secuencias de composición usan el servicio [Fcitx5](https://fcitx-im.org/) que ya se ejecuta en cada sesión.

### Usa ALT como SUPER

En algunos teclados, no es cómodo usar la tecla meta principal (tecla Windows/cmd) como SUPER. Puedes cambiar esto para que sea ALT en su lugar usando este cambio:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
