# Teclado, mouse y trackpad

Hyprland te permite configurar todas tus entradas con gran detalle. Puedes hacer que la repetición del teclado sea supersónicamente rápida o hacer que el trackpad use desplazamiento natural. Todo eso lo cambias en `~/.config/hypr/input.lua`, al que también puedes llegar desde _Configuración > Entrada_ en el menú de Omarchy (`Super + Space`). Todo lo que configures ahí reemplaza los valores predeterminados de Omarchy.

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

CapsLock funciona como un bloqueo de mayúsculas normal, y `Shift + CapsLock` es la tecla de composición para [emojis rápidos](07-hotkeys.md#quick-emojis) y [otros completados rápidos](07-hotkeys.md#quick-completions). Si prefieres tener la tecla de composición en otro lugar, reemplaza `omarchy:shift_caps_compose` en `kb_options`. Por ejemplo, esto mueve la tecla de composición a Right Alt:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### Gestos del trackpad

También puedes activar los [gestos del touchpad](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/), como deslizar tres dedos para cambiar de espacio de trabajo:

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

En las laptops Dell XPS con touchpad háptico, también puedes ajustar la fuerza del clic a baja, media o alta en _Trigger > Hardware > Touchpad Haptics_.

### Escribir en chino, japonés y otros idiomas

Selecciona japonés, coreano, chino (simplificado, Pinyin), Taiwán (Zhuyin) o Hong Kong (Cangjie) cuando el instalador te pregunte por tu teclado. Omarchy configura el teclado y el motor de entrada correspondiente automáticamente, incluso durante la configuración sin conexión del primer arranque. El japonés usa Mozc, el coreano usa Hangul estándar de dos conjuntos, el chino simplificado usa Pinyin, Taiwán usa la disposición Zhuyin estándar de Chewing y Hong Kong usa Cangjie con formas de caracteres de Hong Kong. Japonés (teclado US) proporciona Mozc con una distribución de teclado US. Las teclas de Hangul, Zhuyin y Cangjie se mantienen en sus posiciones estándar incluso cuando escribes letras latinas con Dvorak, Colemak o AZERTY. Si agregaste Hangul o Chewing antes de esto, deselecciónalo y vuelve a seleccionarlo en _Configuración > Escritura > Métodos de entrada_ para mover sus teclas ahí; Omarchy no toca un motor con el que ya escribes.

La escritura comienza en modo latino. Presiona `Super + I` para recorrer los métodos de entrada configurados, y `Super + Shift + I` para recorrerlos en sentido contrario. Toca `Shift` por sí sola para salir de un método de entrada como Pinyin y pasar a letras latinas, y tócala de nuevo para volver, tal como funcionan Sogou, Microsoft Pinyin y macOS; `Shift` más una letra sigue escribiendo una mayúscula. En los teclados japoneses, 全角/半角 alterna la entrada, 変換 la activa y 無変換 la desactiva. Con el coreano, 한/영 cambia Hangul y 한자 convierte a Hanja, ya sea que tu teclado tenga teclas dedicadas o envíe Right Alt y Right Ctrl para eso, como hacen muchas laptops, así que Right Alt y Right Ctrl no son modificadores simples ahí; el dictado por pulsar para hablar se mantiene en F9. `Ctrl + Space` sigue disponible para Tmux y Herdr; `Shift + CapsLock` sigue siendo la tecla de composición.

El indicador de teclado aparece a la derecha de la barra cuando tienes varias distribuciones de teclado o métodos de entrada. Haz clic en él para cambiar de idioma de entrada; el japonés muestra あ para hiragana. Para elegir caracteres en japonés, cambia a japonés, escribe una palabra como `nihongo` y luego presiona Space dos veces. Presiona Enter para aceptar tu elección. Si también tienes varias distribuciones de teclado, haz clic derecho en el indicador para recorrerlas.

Usa _Configuración > Escritura > Distribuciones de teclado_ para seleccionar distribuciones como inglés y francés, entre las mismas opciones que se ofrecen durante la instalación. Usa _Configuración > Escritura > Métodos de entrada_ para seleccionar qué motores de composición están activos. Ambos selectores se abren dentro del menú de Omarchy con tus selecciones actuales marcadas. Haz clic o presiona Enter para activar o desactivar una opción; cada cambio se aplica de inmediato. Deseleccionar un método de entrada lo quita del ciclo sin desinstalarlo; el teclado sigue disponible.

Ejecuta `omarchy setup keyboard` o `omarchy setup input` para abrir los mismos selectores. Para agregar un idioma desde la línea de comandos, usa `omarchy setup input mozc`, `hangul`, `pinyin`, `chewing` o `cangjie5`. Quick, Boshiamy y Array vienen en el mismo paquete que Cangjie y aparecen en el selector de Métodos de entrada. Tus teclas personalizadas para cambiar se conservan. Para distribuciones o teclas alternativas del motor, instala `fcitx5-configtool` con `omarchy pkg add fcitx5-configtool` y ejecútalo desde una terminal. Seleccionar un idioma de entrada no cambia el idioma del escritorio. Elegir japonés, coreano o chino en _Configuración > Idioma_ agrega su método de entrada cuando todavía no tienes ninguno.

Usa `Super + I` para recorrer los métodos de entrada o las distribuciones de teclado, y `Super + Shift + I` para ir en sentido contrario, así que con tres configurados puedes moverte entre dos vecinos. El indicador de entrada aparece a la derecha de la barra solo cuando hay más de un método de entrada o distribución configurados. Este atajo de escritorio funciona junto con tus teclas existentes de cambio de Fcitx; puedes reemplazarlo en `~/.config/hypr/bindings.lua`. Los motores de entrada y las secuencias de composición usan el servicio [Fcitx5](https://fcitx-im.org/) que ya se ejecuta en cada sesión.

### Usar ALT como SUPER

En algunos teclados, no es cómodo usar la tecla meta principal (tecla Windows/cmd) como SUPER. Puedes cambiarla para que sea ALT en su lugar con este cambio:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
