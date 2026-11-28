# Terminal

[Foot](https://codeberg.org/dnkl/foot) es la terminal predeterminada de Omarchy. Es rápida, ligera y compatible hasta con ordenadores viejos. Sin embargo, no admite pestañas ni divisiones nativas.

Si usas Tmux, quizá no te importe, pero si no, también damos soporte completo a _Alacritty_, _Ghostty_ y _Kitty_ como opciones. Elige tu preferencia en _Instalar > Terminal_ en el menú de Omarchy.

Abres una terminal nueva con `Super + Return`. (Esta combinación apuntará automáticamente a la terminal que hayas instalado en _Instalar > Terminal_, y puedes cambiar entre las terminales instaladas en _Configurar > Predeterminados > Terminal_.)

## Tmux

Tmux ofrece una interfaz consistente y programable para paneles, ventanas (también conocidas como pestañas) y sesiones que se pueden reanudar, sin importar tu terminal. Incluso funciona en hosts remotos, así que cuando te conectas por SSH a un servidor puedes usar el mismo enfoque.

Inicias una sesión nueva de Tmux en una terminal nueva con `Super + Alt + Return`, y como Tmux es un proceso persistente, puedes reanudar tu sesión aunque cierres esa terminal. Solo pulsa `Ctrl + Space` (conocida como la tecla prefijo) y luego `s` para ver todas tus sesiones activas.

Omarchy incluye una configuración de Tmux pensada para la ergonomía, con muchos atajos que aprender, así que ten [la hoja de referencia a la mano](07-hotkeys.md#tmux).

## Funciones de disposición de Tmux

Como Tmux es programable, podemos usar funciones para crear disposiciones. Omarchy incluye cuatro funciones para las disposiciones de desarrollo más habituales.

`tdl [agent]` inicia una interfaz dividida en tres partes, parecida a un IDE, con el `$EDITOR` a la izquierda, el agente de IA que elijas a la derecha (como `c` para opencode, `cx` para Claude o `codex` para OpenAI) y luego una terminal abajo.

Así, `tdl c` iniciaría esto (o simplemente `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

También puedes iniciar un segundo agente con `tdl c cx` (opencode + claude) (o simplemente `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

También existe `tds`, que inicia un cuadrado dividido en cuatro con el editor arriba a la izquierda, un observador de diferencias en vivo arriba a la derecha, una terminal abajo a la izquierda y opencode abajo a la derecha.

También puedes iniciar esta disposición para cada subdirectorio del directorio actual con `tdlm [agent]`, y luego navegar con `alt + 1/2/3/4/5/...`:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Por último, puedes iniciar un enjambre de agentes con `tsl [panes] [command]`. Así, `tsl 4 c` te dará una rejilla de cuatro agentes de opencode:

 ![tmux-tsl](images/tmux-tsl.webp)
